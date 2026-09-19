import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../src/primitives.bend as P
import ./primitive_invariants.bend as V
import ./word_facts.bend as W
import ./compatibility_choice.bend as Choice

type Mode is Data:
  Pair{}
  All{}
  Row{}
  Slots{}

def code(mode: Mode) -> U32:
  match mode:
    case Pair{}: 0
    case All{}: 1
    case Row{}: 2
    case Slots{}: 3

# Increasing fuel preserves every successful auxiliary/public-mode traversal.
# Sufficiency of the public input-derived budget remains a separate obligation.
law monotone:
  for +fuel: Nat
  for +extra: Nat
  for +mode: Mode
  for +a: T.Schema
  for +b: T.Schema
  for +accepted: {I.compatible_go(fuel, code(mode), a, b) == True{} : Bool}
  {I.compatible_go(Nat.add(fuel, extra), code(mode), a, b) == True{} : Bool}
def monotone(fuel, extra, mode, a, b, accepted):
  match fuel:
    case 0n: Empty.absurd({I.compatible_go(extra, code(mode), a, b) == True{} : Bool}, W.false_true(accepted))
    case 1n+p:
      match mode:
        case All{}:
          match a:
            case T.Boolean{}: accepted
            case T.Unsigned{x0}: accepted
            case T.ByteVector{x0}: accepted
            case T.ByteList{x0}: accepted
            case T.BitVector{x0}: accepted
            case T.BitList{x0}: accepted
            case T.Vector{x0, x1}: accepted
            case T.ListOf{x0, x1}: accepted
            case T.Container{x0, x1}: accepted
            case T.Union{x0}: accepted
            case T.Null{}: accepted
            case T.Chain{x0, x1}: V.and_true(I.compatible_go(Nat.add(p, extra), 2, x0, b), I.compatible_go(Nat.add(p, extra), 1, x1, b), monotone(p, extra, Row{}, x0, b, V.and_left(I.compatible_go(p, 2, x0, b), I.compatible_go(p, 1, x1, b), accepted)), monotone(p, extra, All{}, x1, b, V.and_right(I.compatible_go(p, 2, x0, b), I.compatible_go(p, 1, x1, b), accepted)))
            case T.End{}: accepted
            case T.Repeat{x0}: accepted
            case T.Named{x0, x1}: accepted
            case T.ProgressiveList{x0}: accepted
            case T.ProgressiveBits{}: accepted
            case T.ProgressiveContainer{x0, x1, x2}: accepted
            case T.CompatibleUnion{x0, x1}: accepted
        case Row{}:
          match b:
            case T.Boolean{}: accepted
            case T.Unsigned{x0}: accepted
            case T.ByteVector{x0}: accepted
            case T.ByteList{x0}: accepted
            case T.BitVector{x0}: accepted
            case T.BitList{x0}: accepted
            case T.Vector{x0, x1}: accepted
            case T.ListOf{x0, x1}: accepted
            case T.Container{x0, x1}: accepted
            case T.Union{x0}: accepted
            case T.Null{}: accepted
            case T.Chain{x0, x1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, a, x0), I.compatible_go(Nat.add(p, extra), 2, a, x1), monotone(p, extra, Pair{}, a, x0, V.and_left(I.compatible_go(p, 0, a, x0), I.compatible_go(p, 2, a, x1), accepted)), monotone(p, extra, Row{}, a, x1, V.and_right(I.compatible_go(p, 0, a, x0), I.compatible_go(p, 2, a, x1), accepted)))
            case T.End{}: accepted
            case T.Repeat{x0}: accepted
            case T.Named{x0, x1}: accepted
            case T.ProgressiveList{x0}: accepted
            case T.ProgressiveBits{}: accepted
            case T.ProgressiveContainer{x0, x1, x2}: accepted
            case T.CompatibleUnion{x0, x1}: accepted
        case Slots{}:
          match a b:
            case T.Boolean{} T.Boolean{}: accepted
            case T.Boolean{} T.Unsigned{b0}: accepted
            case T.Boolean{} T.ByteVector{b0}: accepted
            case T.Boolean{} T.ByteList{b0}: accepted
            case T.Boolean{} T.BitVector{b0}: accepted
            case T.Boolean{} T.BitList{b0}: accepted
            case T.Boolean{} T.Vector{b0, b1}: accepted
            case T.Boolean{} T.ListOf{b0, b1}: accepted
            case T.Boolean{} T.Container{b0, b1}: accepted
            case T.Boolean{} T.Union{b0}: accepted
            case T.Boolean{} T.Null{}: accepted
            case T.Boolean{} T.Chain{T.Boolean{}, b1}: accepted
            case T.Boolean{} T.Chain{T.Unsigned{bc0}, b1}: accepted
            case T.Boolean{} T.Chain{T.ByteVector{bc0}, b1}: accepted
            case T.Boolean{} T.Chain{T.ByteList{bc0}, b1}: accepted
            case T.Boolean{} T.Chain{T.BitVector{bc0}, b1}: accepted
            case T.Boolean{} T.Chain{T.BitList{bc0}, b1}: accepted
            case T.Boolean{} T.Chain{T.Vector{bc0, bc1}, b1}: accepted
            case T.Boolean{} T.Chain{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Boolean{} T.Chain{T.Container{bc0, bc1}, b1}: accepted
            case T.Boolean{} T.Chain{T.Union{bc0}, b1}: accepted
            case T.Boolean{} T.Chain{T.Null{}, b1}: accepted
            case T.Boolean{} T.Chain{T.Chain{bc0, bc1}, b1}: accepted
            case T.Boolean{} T.Chain{T.End{}, b1}: accepted
            case T.Boolean{} T.Chain{T.Repeat{bc0}, b1}: accepted
            case T.Boolean{} T.Chain{T.Named{bc0, bc1}, b1}: accepted
            case T.Boolean{} T.Chain{T.ProgressiveList{bc0}, b1}: accepted
            case T.Boolean{} T.Chain{T.ProgressiveBits{}, b1}: accepted
            case T.Boolean{} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Boolean{} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Boolean{} T.End{}: accepted
            case T.Boolean{} T.Repeat{b0}: accepted
            case T.Boolean{} T.Named{b0, b1}: accepted
            case T.Boolean{} T.ProgressiveList{b0}: accepted
            case T.Boolean{} T.ProgressiveBits{}: accepted
            case T.Boolean{} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Boolean{} T.CompatibleUnion{b0, b1}: accepted
            case T.Unsigned{a0} T.Boolean{}: accepted
            case T.Unsigned{a0} T.Unsigned{b0}: accepted
            case T.Unsigned{a0} T.ByteVector{b0}: accepted
            case T.Unsigned{a0} T.ByteList{b0}: accepted
            case T.Unsigned{a0} T.BitVector{b0}: accepted
            case T.Unsigned{a0} T.BitList{b0}: accepted
            case T.Unsigned{a0} T.Vector{b0, b1}: accepted
            case T.Unsigned{a0} T.ListOf{b0, b1}: accepted
            case T.Unsigned{a0} T.Container{b0, b1}: accepted
            case T.Unsigned{a0} T.Union{b0}: accepted
            case T.Unsigned{a0} T.Null{}: accepted
            case T.Unsigned{a0} T.Chain{T.Boolean{}, b1}: accepted
            case T.Unsigned{a0} T.Chain{T.Unsigned{bc0}, b1}: accepted
            case T.Unsigned{a0} T.Chain{T.ByteVector{bc0}, b1}: accepted
            case T.Unsigned{a0} T.Chain{T.ByteList{bc0}, b1}: accepted
            case T.Unsigned{a0} T.Chain{T.BitVector{bc0}, b1}: accepted
            case T.Unsigned{a0} T.Chain{T.BitList{bc0}, b1}: accepted
            case T.Unsigned{a0} T.Chain{T.Vector{bc0, bc1}, b1}: accepted
            case T.Unsigned{a0} T.Chain{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Unsigned{a0} T.Chain{T.Container{bc0, bc1}, b1}: accepted
            case T.Unsigned{a0} T.Chain{T.Union{bc0}, b1}: accepted
            case T.Unsigned{a0} T.Chain{T.Null{}, b1}: accepted
            case T.Unsigned{a0} T.Chain{T.Chain{bc0, bc1}, b1}: accepted
            case T.Unsigned{a0} T.Chain{T.End{}, b1}: accepted
            case T.Unsigned{a0} T.Chain{T.Repeat{bc0}, b1}: accepted
            case T.Unsigned{a0} T.Chain{T.Named{bc0, bc1}, b1}: accepted
            case T.Unsigned{a0} T.Chain{T.ProgressiveList{bc0}, b1}: accepted
            case T.Unsigned{a0} T.Chain{T.ProgressiveBits{}, b1}: accepted
            case T.Unsigned{a0} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Unsigned{a0} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Unsigned{a0} T.End{}: accepted
            case T.Unsigned{a0} T.Repeat{b0}: accepted
            case T.Unsigned{a0} T.Named{b0, b1}: accepted
            case T.Unsigned{a0} T.ProgressiveList{b0}: accepted
            case T.Unsigned{a0} T.ProgressiveBits{}: accepted
            case T.Unsigned{a0} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Unsigned{a0} T.CompatibleUnion{b0, b1}: accepted
            case T.ByteVector{a0} T.Boolean{}: accepted
            case T.ByteVector{a0} T.Unsigned{b0}: accepted
            case T.ByteVector{a0} T.ByteVector{b0}: accepted
            case T.ByteVector{a0} T.ByteList{b0}: accepted
            case T.ByteVector{a0} T.BitVector{b0}: accepted
            case T.ByteVector{a0} T.BitList{b0}: accepted
            case T.ByteVector{a0} T.Vector{b0, b1}: accepted
            case T.ByteVector{a0} T.ListOf{b0, b1}: accepted
            case T.ByteVector{a0} T.Container{b0, b1}: accepted
            case T.ByteVector{a0} T.Union{b0}: accepted
            case T.ByteVector{a0} T.Null{}: accepted
            case T.ByteVector{a0} T.Chain{T.Boolean{}, b1}: accepted
            case T.ByteVector{a0} T.Chain{T.Unsigned{bc0}, b1}: accepted
            case T.ByteVector{a0} T.Chain{T.ByteVector{bc0}, b1}: accepted
            case T.ByteVector{a0} T.Chain{T.ByteList{bc0}, b1}: accepted
            case T.ByteVector{a0} T.Chain{T.BitVector{bc0}, b1}: accepted
            case T.ByteVector{a0} T.Chain{T.BitList{bc0}, b1}: accepted
            case T.ByteVector{a0} T.Chain{T.Vector{bc0, bc1}, b1}: accepted
            case T.ByteVector{a0} T.Chain{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ByteVector{a0} T.Chain{T.Container{bc0, bc1}, b1}: accepted
            case T.ByteVector{a0} T.Chain{T.Union{bc0}, b1}: accepted
            case T.ByteVector{a0} T.Chain{T.Null{}, b1}: accepted
            case T.ByteVector{a0} T.Chain{T.Chain{bc0, bc1}, b1}: accepted
            case T.ByteVector{a0} T.Chain{T.End{}, b1}: accepted
            case T.ByteVector{a0} T.Chain{T.Repeat{bc0}, b1}: accepted
            case T.ByteVector{a0} T.Chain{T.Named{bc0, bc1}, b1}: accepted
            case T.ByteVector{a0} T.Chain{T.ProgressiveList{bc0}, b1}: accepted
            case T.ByteVector{a0} T.Chain{T.ProgressiveBits{}, b1}: accepted
            case T.ByteVector{a0} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ByteVector{a0} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ByteVector{a0} T.End{}: accepted
            case T.ByteVector{a0} T.Repeat{b0}: accepted
            case T.ByteVector{a0} T.Named{b0, b1}: accepted
            case T.ByteVector{a0} T.ProgressiveList{b0}: accepted
            case T.ByteVector{a0} T.ProgressiveBits{}: accepted
            case T.ByteVector{a0} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ByteVector{a0} T.CompatibleUnion{b0, b1}: accepted
            case T.ByteList{a0} T.Boolean{}: accepted
            case T.ByteList{a0} T.Unsigned{b0}: accepted
            case T.ByteList{a0} T.ByteVector{b0}: accepted
            case T.ByteList{a0} T.ByteList{b0}: accepted
            case T.ByteList{a0} T.BitVector{b0}: accepted
            case T.ByteList{a0} T.BitList{b0}: accepted
            case T.ByteList{a0} T.Vector{b0, b1}: accepted
            case T.ByteList{a0} T.ListOf{b0, b1}: accepted
            case T.ByteList{a0} T.Container{b0, b1}: accepted
            case T.ByteList{a0} T.Union{b0}: accepted
            case T.ByteList{a0} T.Null{}: accepted
            case T.ByteList{a0} T.Chain{T.Boolean{}, b1}: accepted
            case T.ByteList{a0} T.Chain{T.Unsigned{bc0}, b1}: accepted
            case T.ByteList{a0} T.Chain{T.ByteVector{bc0}, b1}: accepted
            case T.ByteList{a0} T.Chain{T.ByteList{bc0}, b1}: accepted
            case T.ByteList{a0} T.Chain{T.BitVector{bc0}, b1}: accepted
            case T.ByteList{a0} T.Chain{T.BitList{bc0}, b1}: accepted
            case T.ByteList{a0} T.Chain{T.Vector{bc0, bc1}, b1}: accepted
            case T.ByteList{a0} T.Chain{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ByteList{a0} T.Chain{T.Container{bc0, bc1}, b1}: accepted
            case T.ByteList{a0} T.Chain{T.Union{bc0}, b1}: accepted
            case T.ByteList{a0} T.Chain{T.Null{}, b1}: accepted
            case T.ByteList{a0} T.Chain{T.Chain{bc0, bc1}, b1}: accepted
            case T.ByteList{a0} T.Chain{T.End{}, b1}: accepted
            case T.ByteList{a0} T.Chain{T.Repeat{bc0}, b1}: accepted
            case T.ByteList{a0} T.Chain{T.Named{bc0, bc1}, b1}: accepted
            case T.ByteList{a0} T.Chain{T.ProgressiveList{bc0}, b1}: accepted
            case T.ByteList{a0} T.Chain{T.ProgressiveBits{}, b1}: accepted
            case T.ByteList{a0} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ByteList{a0} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ByteList{a0} T.End{}: accepted
            case T.ByteList{a0} T.Repeat{b0}: accepted
            case T.ByteList{a0} T.Named{b0, b1}: accepted
            case T.ByteList{a0} T.ProgressiveList{b0}: accepted
            case T.ByteList{a0} T.ProgressiveBits{}: accepted
            case T.ByteList{a0} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ByteList{a0} T.CompatibleUnion{b0, b1}: accepted
            case T.BitVector{a0} T.Boolean{}: accepted
            case T.BitVector{a0} T.Unsigned{b0}: accepted
            case T.BitVector{a0} T.ByteVector{b0}: accepted
            case T.BitVector{a0} T.ByteList{b0}: accepted
            case T.BitVector{a0} T.BitVector{b0}: accepted
            case T.BitVector{a0} T.BitList{b0}: accepted
            case T.BitVector{a0} T.Vector{b0, b1}: accepted
            case T.BitVector{a0} T.ListOf{b0, b1}: accepted
            case T.BitVector{a0} T.Container{b0, b1}: accepted
            case T.BitVector{a0} T.Union{b0}: accepted
            case T.BitVector{a0} T.Null{}: accepted
            case T.BitVector{a0} T.Chain{T.Boolean{}, b1}: accepted
            case T.BitVector{a0} T.Chain{T.Unsigned{bc0}, b1}: accepted
            case T.BitVector{a0} T.Chain{T.ByteVector{bc0}, b1}: accepted
            case T.BitVector{a0} T.Chain{T.ByteList{bc0}, b1}: accepted
            case T.BitVector{a0} T.Chain{T.BitVector{bc0}, b1}: accepted
            case T.BitVector{a0} T.Chain{T.BitList{bc0}, b1}: accepted
            case T.BitVector{a0} T.Chain{T.Vector{bc0, bc1}, b1}: accepted
            case T.BitVector{a0} T.Chain{T.ListOf{bc0, bc1}, b1}: accepted
            case T.BitVector{a0} T.Chain{T.Container{bc0, bc1}, b1}: accepted
            case T.BitVector{a0} T.Chain{T.Union{bc0}, b1}: accepted
            case T.BitVector{a0} T.Chain{T.Null{}, b1}: accepted
            case T.BitVector{a0} T.Chain{T.Chain{bc0, bc1}, b1}: accepted
            case T.BitVector{a0} T.Chain{T.End{}, b1}: accepted
            case T.BitVector{a0} T.Chain{T.Repeat{bc0}, b1}: accepted
            case T.BitVector{a0} T.Chain{T.Named{bc0, bc1}, b1}: accepted
            case T.BitVector{a0} T.Chain{T.ProgressiveList{bc0}, b1}: accepted
            case T.BitVector{a0} T.Chain{T.ProgressiveBits{}, b1}: accepted
            case T.BitVector{a0} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.BitVector{a0} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.BitVector{a0} T.End{}: accepted
            case T.BitVector{a0} T.Repeat{b0}: accepted
            case T.BitVector{a0} T.Named{b0, b1}: accepted
            case T.BitVector{a0} T.ProgressiveList{b0}: accepted
            case T.BitVector{a0} T.ProgressiveBits{}: accepted
            case T.BitVector{a0} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.BitVector{a0} T.CompatibleUnion{b0, b1}: accepted
            case T.BitList{a0} T.Boolean{}: accepted
            case T.BitList{a0} T.Unsigned{b0}: accepted
            case T.BitList{a0} T.ByteVector{b0}: accepted
            case T.BitList{a0} T.ByteList{b0}: accepted
            case T.BitList{a0} T.BitVector{b0}: accepted
            case T.BitList{a0} T.BitList{b0}: accepted
            case T.BitList{a0} T.Vector{b0, b1}: accepted
            case T.BitList{a0} T.ListOf{b0, b1}: accepted
            case T.BitList{a0} T.Container{b0, b1}: accepted
            case T.BitList{a0} T.Union{b0}: accepted
            case T.BitList{a0} T.Null{}: accepted
            case T.BitList{a0} T.Chain{T.Boolean{}, b1}: accepted
            case T.BitList{a0} T.Chain{T.Unsigned{bc0}, b1}: accepted
            case T.BitList{a0} T.Chain{T.ByteVector{bc0}, b1}: accepted
            case T.BitList{a0} T.Chain{T.ByteList{bc0}, b1}: accepted
            case T.BitList{a0} T.Chain{T.BitVector{bc0}, b1}: accepted
            case T.BitList{a0} T.Chain{T.BitList{bc0}, b1}: accepted
            case T.BitList{a0} T.Chain{T.Vector{bc0, bc1}, b1}: accepted
            case T.BitList{a0} T.Chain{T.ListOf{bc0, bc1}, b1}: accepted
            case T.BitList{a0} T.Chain{T.Container{bc0, bc1}, b1}: accepted
            case T.BitList{a0} T.Chain{T.Union{bc0}, b1}: accepted
            case T.BitList{a0} T.Chain{T.Null{}, b1}: accepted
            case T.BitList{a0} T.Chain{T.Chain{bc0, bc1}, b1}: accepted
            case T.BitList{a0} T.Chain{T.End{}, b1}: accepted
            case T.BitList{a0} T.Chain{T.Repeat{bc0}, b1}: accepted
            case T.BitList{a0} T.Chain{T.Named{bc0, bc1}, b1}: accepted
            case T.BitList{a0} T.Chain{T.ProgressiveList{bc0}, b1}: accepted
            case T.BitList{a0} T.Chain{T.ProgressiveBits{}, b1}: accepted
            case T.BitList{a0} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.BitList{a0} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.BitList{a0} T.End{}: accepted
            case T.BitList{a0} T.Repeat{b0}: accepted
            case T.BitList{a0} T.Named{b0, b1}: accepted
            case T.BitList{a0} T.ProgressiveList{b0}: accepted
            case T.BitList{a0} T.ProgressiveBits{}: accepted
            case T.BitList{a0} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.BitList{a0} T.CompatibleUnion{b0, b1}: accepted
            case T.Vector{a0, a1} T.Boolean{}: accepted
            case T.Vector{a0, a1} T.Unsigned{b0}: accepted
            case T.Vector{a0, a1} T.ByteVector{b0}: accepted
            case T.Vector{a0, a1} T.ByteList{b0}: accepted
            case T.Vector{a0, a1} T.BitVector{b0}: accepted
            case T.Vector{a0, a1} T.BitList{b0}: accepted
            case T.Vector{a0, a1} T.Vector{b0, b1}: accepted
            case T.Vector{a0, a1} T.ListOf{b0, b1}: accepted
            case T.Vector{a0, a1} T.Container{b0, b1}: accepted
            case T.Vector{a0, a1} T.Union{b0}: accepted
            case T.Vector{a0, a1} T.Null{}: accepted
            case T.Vector{a0, a1} T.Chain{T.Boolean{}, b1}: accepted
            case T.Vector{a0, a1} T.Chain{T.Unsigned{bc0}, b1}: accepted
            case T.Vector{a0, a1} T.Chain{T.ByteVector{bc0}, b1}: accepted
            case T.Vector{a0, a1} T.Chain{T.ByteList{bc0}, b1}: accepted
            case T.Vector{a0, a1} T.Chain{T.BitVector{bc0}, b1}: accepted
            case T.Vector{a0, a1} T.Chain{T.BitList{bc0}, b1}: accepted
            case T.Vector{a0, a1} T.Chain{T.Vector{bc0, bc1}, b1}: accepted
            case T.Vector{a0, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Vector{a0, a1} T.Chain{T.Container{bc0, bc1}, b1}: accepted
            case T.Vector{a0, a1} T.Chain{T.Union{bc0}, b1}: accepted
            case T.Vector{a0, a1} T.Chain{T.Null{}, b1}: accepted
            case T.Vector{a0, a1} T.Chain{T.Chain{bc0, bc1}, b1}: accepted
            case T.Vector{a0, a1} T.Chain{T.End{}, b1}: accepted
            case T.Vector{a0, a1} T.Chain{T.Repeat{bc0}, b1}: accepted
            case T.Vector{a0, a1} T.Chain{T.Named{bc0, bc1}, b1}: accepted
            case T.Vector{a0, a1} T.Chain{T.ProgressiveList{bc0}, b1}: accepted
            case T.Vector{a0, a1} T.Chain{T.ProgressiveBits{}, b1}: accepted
            case T.Vector{a0, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Vector{a0, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Vector{a0, a1} T.End{}: accepted
            case T.Vector{a0, a1} T.Repeat{b0}: accepted
            case T.Vector{a0, a1} T.Named{b0, b1}: accepted
            case T.Vector{a0, a1} T.ProgressiveList{b0}: accepted
            case T.Vector{a0, a1} T.ProgressiveBits{}: accepted
            case T.Vector{a0, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Vector{a0, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ListOf{a0, a1} T.Boolean{}: accepted
            case T.ListOf{a0, a1} T.Unsigned{b0}: accepted
            case T.ListOf{a0, a1} T.ByteVector{b0}: accepted
            case T.ListOf{a0, a1} T.ByteList{b0}: accepted
            case T.ListOf{a0, a1} T.BitVector{b0}: accepted
            case T.ListOf{a0, a1} T.BitList{b0}: accepted
            case T.ListOf{a0, a1} T.Vector{b0, b1}: accepted
            case T.ListOf{a0, a1} T.ListOf{b0, b1}: accepted
            case T.ListOf{a0, a1} T.Container{b0, b1}: accepted
            case T.ListOf{a0, a1} T.Union{b0}: accepted
            case T.ListOf{a0, a1} T.Null{}: accepted
            case T.ListOf{a0, a1} T.Chain{T.Boolean{}, b1}: accepted
            case T.ListOf{a0, a1} T.Chain{T.Unsigned{bc0}, b1}: accepted
            case T.ListOf{a0, a1} T.Chain{T.ByteVector{bc0}, b1}: accepted
            case T.ListOf{a0, a1} T.Chain{T.ByteList{bc0}, b1}: accepted
            case T.ListOf{a0, a1} T.Chain{T.BitVector{bc0}, b1}: accepted
            case T.ListOf{a0, a1} T.Chain{T.BitList{bc0}, b1}: accepted
            case T.ListOf{a0, a1} T.Chain{T.Vector{bc0, bc1}, b1}: accepted
            case T.ListOf{a0, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ListOf{a0, a1} T.Chain{T.Container{bc0, bc1}, b1}: accepted
            case T.ListOf{a0, a1} T.Chain{T.Union{bc0}, b1}: accepted
            case T.ListOf{a0, a1} T.Chain{T.Null{}, b1}: accepted
            case T.ListOf{a0, a1} T.Chain{T.Chain{bc0, bc1}, b1}: accepted
            case T.ListOf{a0, a1} T.Chain{T.End{}, b1}: accepted
            case T.ListOf{a0, a1} T.Chain{T.Repeat{bc0}, b1}: accepted
            case T.ListOf{a0, a1} T.Chain{T.Named{bc0, bc1}, b1}: accepted
            case T.ListOf{a0, a1} T.Chain{T.ProgressiveList{bc0}, b1}: accepted
            case T.ListOf{a0, a1} T.Chain{T.ProgressiveBits{}, b1}: accepted
            case T.ListOf{a0, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ListOf{a0, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ListOf{a0, a1} T.End{}: accepted
            case T.ListOf{a0, a1} T.Repeat{b0}: accepted
            case T.ListOf{a0, a1} T.Named{b0, b1}: accepted
            case T.ListOf{a0, a1} T.ProgressiveList{b0}: accepted
            case T.ListOf{a0, a1} T.ProgressiveBits{}: accepted
            case T.ListOf{a0, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ListOf{a0, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Container{a0, a1} T.Boolean{}: accepted
            case T.Container{a0, a1} T.Unsigned{b0}: accepted
            case T.Container{a0, a1} T.ByteVector{b0}: accepted
            case T.Container{a0, a1} T.ByteList{b0}: accepted
            case T.Container{a0, a1} T.BitVector{b0}: accepted
            case T.Container{a0, a1} T.BitList{b0}: accepted
            case T.Container{a0, a1} T.Vector{b0, b1}: accepted
            case T.Container{a0, a1} T.ListOf{b0, b1}: accepted
            case T.Container{a0, a1} T.Container{b0, b1}: accepted
            case T.Container{a0, a1} T.Union{b0}: accepted
            case T.Container{a0, a1} T.Null{}: accepted
            case T.Container{a0, a1} T.Chain{T.Boolean{}, b1}: accepted
            case T.Container{a0, a1} T.Chain{T.Unsigned{bc0}, b1}: accepted
            case T.Container{a0, a1} T.Chain{T.ByteVector{bc0}, b1}: accepted
            case T.Container{a0, a1} T.Chain{T.ByteList{bc0}, b1}: accepted
            case T.Container{a0, a1} T.Chain{T.BitVector{bc0}, b1}: accepted
            case T.Container{a0, a1} T.Chain{T.BitList{bc0}, b1}: accepted
            case T.Container{a0, a1} T.Chain{T.Vector{bc0, bc1}, b1}: accepted
            case T.Container{a0, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Container{a0, a1} T.Chain{T.Container{bc0, bc1}, b1}: accepted
            case T.Container{a0, a1} T.Chain{T.Union{bc0}, b1}: accepted
            case T.Container{a0, a1} T.Chain{T.Null{}, b1}: accepted
            case T.Container{a0, a1} T.Chain{T.Chain{bc0, bc1}, b1}: accepted
            case T.Container{a0, a1} T.Chain{T.End{}, b1}: accepted
            case T.Container{a0, a1} T.Chain{T.Repeat{bc0}, b1}: accepted
            case T.Container{a0, a1} T.Chain{T.Named{bc0, bc1}, b1}: accepted
            case T.Container{a0, a1} T.Chain{T.ProgressiveList{bc0}, b1}: accepted
            case T.Container{a0, a1} T.Chain{T.ProgressiveBits{}, b1}: accepted
            case T.Container{a0, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Container{a0, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Container{a0, a1} T.End{}: accepted
            case T.Container{a0, a1} T.Repeat{b0}: accepted
            case T.Container{a0, a1} T.Named{b0, b1}: accepted
            case T.Container{a0, a1} T.ProgressiveList{b0}: accepted
            case T.Container{a0, a1} T.ProgressiveBits{}: accepted
            case T.Container{a0, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Container{a0, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Union{a0} T.Boolean{}: accepted
            case T.Union{a0} T.Unsigned{b0}: accepted
            case T.Union{a0} T.ByteVector{b0}: accepted
            case T.Union{a0} T.ByteList{b0}: accepted
            case T.Union{a0} T.BitVector{b0}: accepted
            case T.Union{a0} T.BitList{b0}: accepted
            case T.Union{a0} T.Vector{b0, b1}: accepted
            case T.Union{a0} T.ListOf{b0, b1}: accepted
            case T.Union{a0} T.Container{b0, b1}: accepted
            case T.Union{a0} T.Union{b0}: accepted
            case T.Union{a0} T.Null{}: accepted
            case T.Union{a0} T.Chain{T.Boolean{}, b1}: accepted
            case T.Union{a0} T.Chain{T.Unsigned{bc0}, b1}: accepted
            case T.Union{a0} T.Chain{T.ByteVector{bc0}, b1}: accepted
            case T.Union{a0} T.Chain{T.ByteList{bc0}, b1}: accepted
            case T.Union{a0} T.Chain{T.BitVector{bc0}, b1}: accepted
            case T.Union{a0} T.Chain{T.BitList{bc0}, b1}: accepted
            case T.Union{a0} T.Chain{T.Vector{bc0, bc1}, b1}: accepted
            case T.Union{a0} T.Chain{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Union{a0} T.Chain{T.Container{bc0, bc1}, b1}: accepted
            case T.Union{a0} T.Chain{T.Union{bc0}, b1}: accepted
            case T.Union{a0} T.Chain{T.Null{}, b1}: accepted
            case T.Union{a0} T.Chain{T.Chain{bc0, bc1}, b1}: accepted
            case T.Union{a0} T.Chain{T.End{}, b1}: accepted
            case T.Union{a0} T.Chain{T.Repeat{bc0}, b1}: accepted
            case T.Union{a0} T.Chain{T.Named{bc0, bc1}, b1}: accepted
            case T.Union{a0} T.Chain{T.ProgressiveList{bc0}, b1}: accepted
            case T.Union{a0} T.Chain{T.ProgressiveBits{}, b1}: accepted
            case T.Union{a0} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Union{a0} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Union{a0} T.End{}: accepted
            case T.Union{a0} T.Repeat{b0}: accepted
            case T.Union{a0} T.Named{b0, b1}: accepted
            case T.Union{a0} T.ProgressiveList{b0}: accepted
            case T.Union{a0} T.ProgressiveBits{}: accepted
            case T.Union{a0} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Union{a0} T.CompatibleUnion{b0, b1}: accepted
            case T.Null{} T.Boolean{}: accepted
            case T.Null{} T.Unsigned{b0}: accepted
            case T.Null{} T.ByteVector{b0}: accepted
            case T.Null{} T.ByteList{b0}: accepted
            case T.Null{} T.BitVector{b0}: accepted
            case T.Null{} T.BitList{b0}: accepted
            case T.Null{} T.Vector{b0, b1}: accepted
            case T.Null{} T.ListOf{b0, b1}: accepted
            case T.Null{} T.Container{b0, b1}: accepted
            case T.Null{} T.Union{b0}: accepted
            case T.Null{} T.Null{}: accepted
            case T.Null{} T.Chain{T.Boolean{}, b1}: accepted
            case T.Null{} T.Chain{T.Unsigned{bc0}, b1}: accepted
            case T.Null{} T.Chain{T.ByteVector{bc0}, b1}: accepted
            case T.Null{} T.Chain{T.ByteList{bc0}, b1}: accepted
            case T.Null{} T.Chain{T.BitVector{bc0}, b1}: accepted
            case T.Null{} T.Chain{T.BitList{bc0}, b1}: accepted
            case T.Null{} T.Chain{T.Vector{bc0, bc1}, b1}: accepted
            case T.Null{} T.Chain{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Null{} T.Chain{T.Container{bc0, bc1}, b1}: accepted
            case T.Null{} T.Chain{T.Union{bc0}, b1}: accepted
            case T.Null{} T.Chain{T.Null{}, b1}: accepted
            case T.Null{} T.Chain{T.Chain{bc0, bc1}, b1}: accepted
            case T.Null{} T.Chain{T.End{}, b1}: accepted
            case T.Null{} T.Chain{T.Repeat{bc0}, b1}: accepted
            case T.Null{} T.Chain{T.Named{bc0, bc1}, b1}: accepted
            case T.Null{} T.Chain{T.ProgressiveList{bc0}, b1}: accepted
            case T.Null{} T.Chain{T.ProgressiveBits{}, b1}: accepted
            case T.Null{} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Null{} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Null{} T.End{}: accepted
            case T.Null{} T.Repeat{b0}: accepted
            case T.Null{} T.Named{b0, b1}: accepted
            case T.Null{} T.ProgressiveList{b0}: accepted
            case T.Null{} T.ProgressiveBits{}: accepted
            case T.Null{} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Null{} T.CompatibleUnion{b0, b1}: accepted
            case T.Chain{T.Boolean{}, a1} T.Boolean{}: accepted
            case T.Chain{T.Boolean{}, a1} T.Unsigned{b0}: accepted
            case T.Chain{T.Boolean{}, a1} T.ByteVector{b0}: accepted
            case T.Chain{T.Boolean{}, a1} T.ByteList{b0}: accepted
            case T.Chain{T.Boolean{}, a1} T.BitVector{b0}: accepted
            case T.Chain{T.Boolean{}, a1} T.BitList{b0}: accepted
            case T.Chain{T.Boolean{}, a1} T.Vector{b0, b1}: accepted
            case T.Chain{T.Boolean{}, a1} T.ListOf{b0, b1}: accepted
            case T.Chain{T.Boolean{}, a1} T.Container{b0, b1}: accepted
            case T.Chain{T.Boolean{}, a1} T.Union{b0}: accepted
            case T.Chain{T.Boolean{}, a1} T.Null{}: accepted
            case T.Chain{T.Boolean{}, a1} T.Chain{T.Boolean{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Boolean{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Boolean{}, T.Boolean{}, V.and_left(I.compatible_go(p, 0, T.Boolean{}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Boolean{}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Boolean{}, a1} T.Chain{T.Unsigned{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Unsigned{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Boolean{}, T.Unsigned{bc0}, V.and_left(I.compatible_go(p, 0, T.Boolean{}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Boolean{}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Boolean{}, a1} T.Chain{T.ByteVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.ByteVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Boolean{}, T.ByteVector{bc0}, V.and_left(I.compatible_go(p, 0, T.Boolean{}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Boolean{}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Boolean{}, a1} T.Chain{T.ByteList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.ByteList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Boolean{}, T.ByteList{bc0}, V.and_left(I.compatible_go(p, 0, T.Boolean{}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Boolean{}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Boolean{}, a1} T.Chain{T.BitVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.BitVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Boolean{}, T.BitVector{bc0}, V.and_left(I.compatible_go(p, 0, T.Boolean{}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Boolean{}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Boolean{}, a1} T.Chain{T.BitList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.BitList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Boolean{}, T.BitList{bc0}, V.and_left(I.compatible_go(p, 0, T.Boolean{}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Boolean{}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Boolean{}, a1} T.Chain{T.Vector{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Vector{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Boolean{}, T.Vector{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Boolean{}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Boolean{}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Boolean{}, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.ListOf{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Boolean{}, T.ListOf{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Boolean{}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Boolean{}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Boolean{}, a1} T.Chain{T.Container{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Container{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Boolean{}, T.Container{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Boolean{}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Boolean{}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Boolean{}, a1} T.Chain{T.Union{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Union{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Boolean{}, T.Union{bc0}, V.and_left(I.compatible_go(p, 0, T.Boolean{}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Boolean{}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Boolean{}, a1} T.Chain{T.Null{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Boolean{}, a1} T.Chain{T.Chain{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Chain{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Boolean{}, T.Chain{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Boolean{}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Boolean{}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Boolean{}, a1} T.Chain{T.End{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.End{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Boolean{}, T.End{}, V.and_left(I.compatible_go(p, 0, T.Boolean{}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Boolean{}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Boolean{}, a1} T.Chain{T.Repeat{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Repeat{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Boolean{}, T.Repeat{bc0}, V.and_left(I.compatible_go(p, 0, T.Boolean{}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Boolean{}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Boolean{}, a1} T.Chain{T.Named{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Named{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Boolean{}, T.Named{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Boolean{}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Boolean{}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Boolean{}, a1} T.Chain{T.ProgressiveList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.ProgressiveList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Boolean{}, T.ProgressiveList{bc0}, V.and_left(I.compatible_go(p, 0, T.Boolean{}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Boolean{}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Boolean{}, a1} T.Chain{T.ProgressiveBits{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.ProgressiveBits{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Boolean{}, T.ProgressiveBits{}, V.and_left(I.compatible_go(p, 0, T.Boolean{}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Boolean{}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Boolean{}, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_left(I.compatible_go(p, 0, T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Boolean{}, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Boolean{}, T.CompatibleUnion{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Boolean{}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Boolean{}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Boolean{}, a1} T.End{}: accepted
            case T.Chain{T.Boolean{}, a1} T.Repeat{b0}: accepted
            case T.Chain{T.Boolean{}, a1} T.Named{b0, b1}: accepted
            case T.Chain{T.Boolean{}, a1} T.ProgressiveList{b0}: accepted
            case T.Chain{T.Boolean{}, a1} T.ProgressiveBits{}: accepted
            case T.Chain{T.Boolean{}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Chain{T.Boolean{}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Chain{T.Unsigned{ac0}, a1} T.Boolean{}: accepted
            case T.Chain{T.Unsigned{ac0}, a1} T.Unsigned{b0}: accepted
            case T.Chain{T.Unsigned{ac0}, a1} T.ByteVector{b0}: accepted
            case T.Chain{T.Unsigned{ac0}, a1} T.ByteList{b0}: accepted
            case T.Chain{T.Unsigned{ac0}, a1} T.BitVector{b0}: accepted
            case T.Chain{T.Unsigned{ac0}, a1} T.BitList{b0}: accepted
            case T.Chain{T.Unsigned{ac0}, a1} T.Vector{b0, b1}: accepted
            case T.Chain{T.Unsigned{ac0}, a1} T.ListOf{b0, b1}: accepted
            case T.Chain{T.Unsigned{ac0}, a1} T.Container{b0, b1}: accepted
            case T.Chain{T.Unsigned{ac0}, a1} T.Union{b0}: accepted
            case T.Chain{T.Unsigned{ac0}, a1} T.Null{}: accepted
            case T.Chain{T.Unsigned{ac0}, a1} T.Chain{T.Boolean{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Boolean{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Boolean{}, V.and_left(I.compatible_go(p, 0, T.Unsigned{ac0}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Unsigned{ac0}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Unsigned{ac0}, a1} T.Chain{T.Unsigned{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Unsigned{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Unsigned{bc0}, V.and_left(I.compatible_go(p, 0, T.Unsigned{ac0}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Unsigned{ac0}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Unsigned{ac0}, a1} T.Chain{T.ByteVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.ByteVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.ByteVector{bc0}, V.and_left(I.compatible_go(p, 0, T.Unsigned{ac0}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Unsigned{ac0}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Unsigned{ac0}, a1} T.Chain{T.ByteList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.ByteList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.ByteList{bc0}, V.and_left(I.compatible_go(p, 0, T.Unsigned{ac0}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Unsigned{ac0}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Unsigned{ac0}, a1} T.Chain{T.BitVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.BitVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.BitVector{bc0}, V.and_left(I.compatible_go(p, 0, T.Unsigned{ac0}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Unsigned{ac0}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Unsigned{ac0}, a1} T.Chain{T.BitList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.BitList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.BitList{bc0}, V.and_left(I.compatible_go(p, 0, T.Unsigned{ac0}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Unsigned{ac0}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Unsigned{ac0}, a1} T.Chain{T.Vector{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Vector{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Vector{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Unsigned{ac0}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Unsigned{ac0}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Unsigned{ac0}, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.ListOf{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Unsigned{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Unsigned{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Unsigned{ac0}, a1} T.Chain{T.Container{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Container{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Container{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Unsigned{ac0}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Unsigned{ac0}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Unsigned{ac0}, a1} T.Chain{T.Union{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Union{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Union{bc0}, V.and_left(I.compatible_go(p, 0, T.Unsigned{ac0}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Unsigned{ac0}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Unsigned{ac0}, a1} T.Chain{T.Null{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Unsigned{ac0}, a1} T.Chain{T.Chain{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Chain{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Chain{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Unsigned{ac0}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Unsigned{ac0}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Unsigned{ac0}, a1} T.Chain{T.End{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.End{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.End{}, V.and_left(I.compatible_go(p, 0, T.Unsigned{ac0}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Unsigned{ac0}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Unsigned{ac0}, a1} T.Chain{T.Repeat{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Repeat{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Repeat{bc0}, V.and_left(I.compatible_go(p, 0, T.Unsigned{ac0}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Unsigned{ac0}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Unsigned{ac0}, a1} T.Chain{T.Named{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Named{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Named{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Unsigned{ac0}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Unsigned{ac0}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Unsigned{ac0}, a1} T.Chain{T.ProgressiveList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.ProgressiveList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.ProgressiveList{bc0}, V.and_left(I.compatible_go(p, 0, T.Unsigned{ac0}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Unsigned{ac0}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Unsigned{ac0}, a1} T.Chain{T.ProgressiveBits{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.ProgressiveBits{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.ProgressiveBits{}, V.and_left(I.compatible_go(p, 0, T.Unsigned{ac0}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Unsigned{ac0}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Unsigned{ac0}, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_left(I.compatible_go(p, 0, T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Unsigned{ac0}, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Unsigned{ac0}, a1} T.End{}: accepted
            case T.Chain{T.Unsigned{ac0}, a1} T.Repeat{b0}: accepted
            case T.Chain{T.Unsigned{ac0}, a1} T.Named{b0, b1}: accepted
            case T.Chain{T.Unsigned{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.Chain{T.Unsigned{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.Chain{T.Unsigned{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Chain{T.Unsigned{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Chain{T.ByteVector{ac0}, a1} T.Boolean{}: accepted
            case T.Chain{T.ByteVector{ac0}, a1} T.Unsigned{b0}: accepted
            case T.Chain{T.ByteVector{ac0}, a1} T.ByteVector{b0}: accepted
            case T.Chain{T.ByteVector{ac0}, a1} T.ByteList{b0}: accepted
            case T.Chain{T.ByteVector{ac0}, a1} T.BitVector{b0}: accepted
            case T.Chain{T.ByteVector{ac0}, a1} T.BitList{b0}: accepted
            case T.Chain{T.ByteVector{ac0}, a1} T.Vector{b0, b1}: accepted
            case T.Chain{T.ByteVector{ac0}, a1} T.ListOf{b0, b1}: accepted
            case T.Chain{T.ByteVector{ac0}, a1} T.Container{b0, b1}: accepted
            case T.Chain{T.ByteVector{ac0}, a1} T.Union{b0}: accepted
            case T.Chain{T.ByteVector{ac0}, a1} T.Null{}: accepted
            case T.Chain{T.ByteVector{ac0}, a1} T.Chain{T.Boolean{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Boolean{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Boolean{}, V.and_left(I.compatible_go(p, 0, T.ByteVector{ac0}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteVector{ac0}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteVector{ac0}, a1} T.Chain{T.Unsigned{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Unsigned{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Unsigned{bc0}, V.and_left(I.compatible_go(p, 0, T.ByteVector{ac0}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteVector{ac0}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteVector{ac0}, a1} T.Chain{T.ByteVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.ByteVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.ByteVector{bc0}, V.and_left(I.compatible_go(p, 0, T.ByteVector{ac0}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteVector{ac0}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteVector{ac0}, a1} T.Chain{T.ByteList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.ByteList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.ByteList{bc0}, V.and_left(I.compatible_go(p, 0, T.ByteVector{ac0}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteVector{ac0}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteVector{ac0}, a1} T.Chain{T.BitVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.BitVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.BitVector{bc0}, V.and_left(I.compatible_go(p, 0, T.ByteVector{ac0}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteVector{ac0}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteVector{ac0}, a1} T.Chain{T.BitList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.BitList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.BitList{bc0}, V.and_left(I.compatible_go(p, 0, T.ByteVector{ac0}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteVector{ac0}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteVector{ac0}, a1} T.Chain{T.Vector{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Vector{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Vector{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ByteVector{ac0}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteVector{ac0}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteVector{ac0}, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.ListOf{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ByteVector{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteVector{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteVector{ac0}, a1} T.Chain{T.Container{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Container{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Container{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ByteVector{ac0}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteVector{ac0}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteVector{ac0}, a1} T.Chain{T.Union{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Union{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Union{bc0}, V.and_left(I.compatible_go(p, 0, T.ByteVector{ac0}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteVector{ac0}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteVector{ac0}, a1} T.Chain{T.Null{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.ByteVector{ac0}, a1} T.Chain{T.Chain{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Chain{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Chain{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ByteVector{ac0}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteVector{ac0}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteVector{ac0}, a1} T.Chain{T.End{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.End{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.End{}, V.and_left(I.compatible_go(p, 0, T.ByteVector{ac0}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteVector{ac0}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteVector{ac0}, a1} T.Chain{T.Repeat{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Repeat{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Repeat{bc0}, V.and_left(I.compatible_go(p, 0, T.ByteVector{ac0}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteVector{ac0}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteVector{ac0}, a1} T.Chain{T.Named{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Named{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Named{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ByteVector{ac0}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteVector{ac0}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteVector{ac0}, a1} T.Chain{T.ProgressiveList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.ProgressiveList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.ProgressiveList{bc0}, V.and_left(I.compatible_go(p, 0, T.ByteVector{ac0}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteVector{ac0}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteVector{ac0}, a1} T.Chain{T.ProgressiveBits{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.ProgressiveBits{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.ProgressiveBits{}, V.and_left(I.compatible_go(p, 0, T.ByteVector{ac0}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteVector{ac0}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteVector{ac0}, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_left(I.compatible_go(p, 0, T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteVector{ac0}, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteVector{ac0}, a1} T.End{}: accepted
            case T.Chain{T.ByteVector{ac0}, a1} T.Repeat{b0}: accepted
            case T.Chain{T.ByteVector{ac0}, a1} T.Named{b0, b1}: accepted
            case T.Chain{T.ByteVector{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.Chain{T.ByteVector{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.Chain{T.ByteVector{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Chain{T.ByteVector{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Chain{T.ByteList{ac0}, a1} T.Boolean{}: accepted
            case T.Chain{T.ByteList{ac0}, a1} T.Unsigned{b0}: accepted
            case T.Chain{T.ByteList{ac0}, a1} T.ByteVector{b0}: accepted
            case T.Chain{T.ByteList{ac0}, a1} T.ByteList{b0}: accepted
            case T.Chain{T.ByteList{ac0}, a1} T.BitVector{b0}: accepted
            case T.Chain{T.ByteList{ac0}, a1} T.BitList{b0}: accepted
            case T.Chain{T.ByteList{ac0}, a1} T.Vector{b0, b1}: accepted
            case T.Chain{T.ByteList{ac0}, a1} T.ListOf{b0, b1}: accepted
            case T.Chain{T.ByteList{ac0}, a1} T.Container{b0, b1}: accepted
            case T.Chain{T.ByteList{ac0}, a1} T.Union{b0}: accepted
            case T.Chain{T.ByteList{ac0}, a1} T.Null{}: accepted
            case T.Chain{T.ByteList{ac0}, a1} T.Chain{T.Boolean{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Boolean{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Boolean{}, V.and_left(I.compatible_go(p, 0, T.ByteList{ac0}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteList{ac0}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteList{ac0}, a1} T.Chain{T.Unsigned{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Unsigned{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Unsigned{bc0}, V.and_left(I.compatible_go(p, 0, T.ByteList{ac0}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteList{ac0}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteList{ac0}, a1} T.Chain{T.ByteVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.ByteVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.ByteVector{bc0}, V.and_left(I.compatible_go(p, 0, T.ByteList{ac0}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteList{ac0}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteList{ac0}, a1} T.Chain{T.ByteList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.ByteList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.ByteList{bc0}, V.and_left(I.compatible_go(p, 0, T.ByteList{ac0}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteList{ac0}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteList{ac0}, a1} T.Chain{T.BitVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.BitVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.BitVector{bc0}, V.and_left(I.compatible_go(p, 0, T.ByteList{ac0}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteList{ac0}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteList{ac0}, a1} T.Chain{T.BitList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.BitList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.BitList{bc0}, V.and_left(I.compatible_go(p, 0, T.ByteList{ac0}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteList{ac0}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteList{ac0}, a1} T.Chain{T.Vector{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Vector{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Vector{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ByteList{ac0}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteList{ac0}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteList{ac0}, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.ListOf{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ByteList{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteList{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteList{ac0}, a1} T.Chain{T.Container{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Container{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Container{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ByteList{ac0}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteList{ac0}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteList{ac0}, a1} T.Chain{T.Union{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Union{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Union{bc0}, V.and_left(I.compatible_go(p, 0, T.ByteList{ac0}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteList{ac0}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteList{ac0}, a1} T.Chain{T.Null{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.ByteList{ac0}, a1} T.Chain{T.Chain{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Chain{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Chain{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ByteList{ac0}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteList{ac0}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteList{ac0}, a1} T.Chain{T.End{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.End{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.End{}, V.and_left(I.compatible_go(p, 0, T.ByteList{ac0}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteList{ac0}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteList{ac0}, a1} T.Chain{T.Repeat{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Repeat{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Repeat{bc0}, V.and_left(I.compatible_go(p, 0, T.ByteList{ac0}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteList{ac0}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteList{ac0}, a1} T.Chain{T.Named{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Named{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Named{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ByteList{ac0}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteList{ac0}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteList{ac0}, a1} T.Chain{T.ProgressiveList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.ProgressiveList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.ProgressiveList{bc0}, V.and_left(I.compatible_go(p, 0, T.ByteList{ac0}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteList{ac0}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteList{ac0}, a1} T.Chain{T.ProgressiveBits{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.ProgressiveBits{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.ProgressiveBits{}, V.and_left(I.compatible_go(p, 0, T.ByteList{ac0}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteList{ac0}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteList{ac0}, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_left(I.compatible_go(p, 0, T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteList{ac0}, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ByteList{ac0}, a1} T.End{}: accepted
            case T.Chain{T.ByteList{ac0}, a1} T.Repeat{b0}: accepted
            case T.Chain{T.ByteList{ac0}, a1} T.Named{b0, b1}: accepted
            case T.Chain{T.ByteList{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.Chain{T.ByteList{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.Chain{T.ByteList{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Chain{T.ByteList{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Chain{T.BitVector{ac0}, a1} T.Boolean{}: accepted
            case T.Chain{T.BitVector{ac0}, a1} T.Unsigned{b0}: accepted
            case T.Chain{T.BitVector{ac0}, a1} T.ByteVector{b0}: accepted
            case T.Chain{T.BitVector{ac0}, a1} T.ByteList{b0}: accepted
            case T.Chain{T.BitVector{ac0}, a1} T.BitVector{b0}: accepted
            case T.Chain{T.BitVector{ac0}, a1} T.BitList{b0}: accepted
            case T.Chain{T.BitVector{ac0}, a1} T.Vector{b0, b1}: accepted
            case T.Chain{T.BitVector{ac0}, a1} T.ListOf{b0, b1}: accepted
            case T.Chain{T.BitVector{ac0}, a1} T.Container{b0, b1}: accepted
            case T.Chain{T.BitVector{ac0}, a1} T.Union{b0}: accepted
            case T.Chain{T.BitVector{ac0}, a1} T.Null{}: accepted
            case T.Chain{T.BitVector{ac0}, a1} T.Chain{T.Boolean{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Boolean{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Boolean{}, V.and_left(I.compatible_go(p, 0, T.BitVector{ac0}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitVector{ac0}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitVector{ac0}, a1} T.Chain{T.Unsigned{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Unsigned{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Unsigned{bc0}, V.and_left(I.compatible_go(p, 0, T.BitVector{ac0}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitVector{ac0}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitVector{ac0}, a1} T.Chain{T.ByteVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.ByteVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.ByteVector{bc0}, V.and_left(I.compatible_go(p, 0, T.BitVector{ac0}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitVector{ac0}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitVector{ac0}, a1} T.Chain{T.ByteList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.ByteList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.ByteList{bc0}, V.and_left(I.compatible_go(p, 0, T.BitVector{ac0}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitVector{ac0}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitVector{ac0}, a1} T.Chain{T.BitVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.BitVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.BitVector{bc0}, V.and_left(I.compatible_go(p, 0, T.BitVector{ac0}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitVector{ac0}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitVector{ac0}, a1} T.Chain{T.BitList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.BitList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.BitList{bc0}, V.and_left(I.compatible_go(p, 0, T.BitVector{ac0}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitVector{ac0}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitVector{ac0}, a1} T.Chain{T.Vector{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Vector{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Vector{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.BitVector{ac0}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitVector{ac0}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitVector{ac0}, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.ListOf{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.BitVector{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitVector{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitVector{ac0}, a1} T.Chain{T.Container{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Container{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Container{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.BitVector{ac0}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitVector{ac0}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitVector{ac0}, a1} T.Chain{T.Union{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Union{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Union{bc0}, V.and_left(I.compatible_go(p, 0, T.BitVector{ac0}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitVector{ac0}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitVector{ac0}, a1} T.Chain{T.Null{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.BitVector{ac0}, a1} T.Chain{T.Chain{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Chain{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Chain{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.BitVector{ac0}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitVector{ac0}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitVector{ac0}, a1} T.Chain{T.End{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.End{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.End{}, V.and_left(I.compatible_go(p, 0, T.BitVector{ac0}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitVector{ac0}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitVector{ac0}, a1} T.Chain{T.Repeat{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Repeat{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Repeat{bc0}, V.and_left(I.compatible_go(p, 0, T.BitVector{ac0}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitVector{ac0}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitVector{ac0}, a1} T.Chain{T.Named{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Named{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Named{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.BitVector{ac0}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitVector{ac0}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitVector{ac0}, a1} T.Chain{T.ProgressiveList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.ProgressiveList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.ProgressiveList{bc0}, V.and_left(I.compatible_go(p, 0, T.BitVector{ac0}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitVector{ac0}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitVector{ac0}, a1} T.Chain{T.ProgressiveBits{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.ProgressiveBits{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.ProgressiveBits{}, V.and_left(I.compatible_go(p, 0, T.BitVector{ac0}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitVector{ac0}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitVector{ac0}, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_left(I.compatible_go(p, 0, T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitVector{ac0}, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitVector{ac0}, a1} T.End{}: accepted
            case T.Chain{T.BitVector{ac0}, a1} T.Repeat{b0}: accepted
            case T.Chain{T.BitVector{ac0}, a1} T.Named{b0, b1}: accepted
            case T.Chain{T.BitVector{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.Chain{T.BitVector{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.Chain{T.BitVector{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Chain{T.BitVector{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Chain{T.BitList{ac0}, a1} T.Boolean{}: accepted
            case T.Chain{T.BitList{ac0}, a1} T.Unsigned{b0}: accepted
            case T.Chain{T.BitList{ac0}, a1} T.ByteVector{b0}: accepted
            case T.Chain{T.BitList{ac0}, a1} T.ByteList{b0}: accepted
            case T.Chain{T.BitList{ac0}, a1} T.BitVector{b0}: accepted
            case T.Chain{T.BitList{ac0}, a1} T.BitList{b0}: accepted
            case T.Chain{T.BitList{ac0}, a1} T.Vector{b0, b1}: accepted
            case T.Chain{T.BitList{ac0}, a1} T.ListOf{b0, b1}: accepted
            case T.Chain{T.BitList{ac0}, a1} T.Container{b0, b1}: accepted
            case T.Chain{T.BitList{ac0}, a1} T.Union{b0}: accepted
            case T.Chain{T.BitList{ac0}, a1} T.Null{}: accepted
            case T.Chain{T.BitList{ac0}, a1} T.Chain{T.Boolean{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Boolean{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Boolean{}, V.and_left(I.compatible_go(p, 0, T.BitList{ac0}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitList{ac0}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitList{ac0}, a1} T.Chain{T.Unsigned{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Unsigned{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Unsigned{bc0}, V.and_left(I.compatible_go(p, 0, T.BitList{ac0}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitList{ac0}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitList{ac0}, a1} T.Chain{T.ByteVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.ByteVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitList{ac0}, T.ByteVector{bc0}, V.and_left(I.compatible_go(p, 0, T.BitList{ac0}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitList{ac0}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitList{ac0}, a1} T.Chain{T.ByteList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.ByteList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitList{ac0}, T.ByteList{bc0}, V.and_left(I.compatible_go(p, 0, T.BitList{ac0}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitList{ac0}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitList{ac0}, a1} T.Chain{T.BitVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.BitVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitList{ac0}, T.BitVector{bc0}, V.and_left(I.compatible_go(p, 0, T.BitList{ac0}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitList{ac0}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitList{ac0}, a1} T.Chain{T.BitList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.BitList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitList{ac0}, T.BitList{bc0}, V.and_left(I.compatible_go(p, 0, T.BitList{ac0}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitList{ac0}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitList{ac0}, a1} T.Chain{T.Vector{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Vector{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Vector{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.BitList{ac0}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitList{ac0}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitList{ac0}, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitList{ac0}, T.ListOf{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.BitList{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitList{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitList{ac0}, a1} T.Chain{T.Container{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Container{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Container{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.BitList{ac0}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitList{ac0}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitList{ac0}, a1} T.Chain{T.Union{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Union{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Union{bc0}, V.and_left(I.compatible_go(p, 0, T.BitList{ac0}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitList{ac0}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitList{ac0}, a1} T.Chain{T.Null{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.BitList{ac0}, a1} T.Chain{T.Chain{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Chain{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Chain{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.BitList{ac0}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitList{ac0}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitList{ac0}, a1} T.Chain{T.End{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.End{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitList{ac0}, T.End{}, V.and_left(I.compatible_go(p, 0, T.BitList{ac0}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitList{ac0}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitList{ac0}, a1} T.Chain{T.Repeat{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Repeat{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Repeat{bc0}, V.and_left(I.compatible_go(p, 0, T.BitList{ac0}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitList{ac0}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitList{ac0}, a1} T.Chain{T.Named{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Named{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Named{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.BitList{ac0}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitList{ac0}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitList{ac0}, a1} T.Chain{T.ProgressiveList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.ProgressiveList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitList{ac0}, T.ProgressiveList{bc0}, V.and_left(I.compatible_go(p, 0, T.BitList{ac0}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitList{ac0}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitList{ac0}, a1} T.Chain{T.ProgressiveBits{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.ProgressiveBits{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitList{ac0}, T.ProgressiveBits{}, V.and_left(I.compatible_go(p, 0, T.BitList{ac0}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitList{ac0}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitList{ac0}, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_left(I.compatible_go(p, 0, T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitList{ac0}, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.BitList{ac0}, a1} T.End{}: accepted
            case T.Chain{T.BitList{ac0}, a1} T.Repeat{b0}: accepted
            case T.Chain{T.BitList{ac0}, a1} T.Named{b0, b1}: accepted
            case T.Chain{T.BitList{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.Chain{T.BitList{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.Chain{T.BitList{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Chain{T.BitList{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Boolean{}: accepted
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Unsigned{b0}: accepted
            case T.Chain{T.Vector{ac0, ac1}, a1} T.ByteVector{b0}: accepted
            case T.Chain{T.Vector{ac0, ac1}, a1} T.ByteList{b0}: accepted
            case T.Chain{T.Vector{ac0, ac1}, a1} T.BitVector{b0}: accepted
            case T.Chain{T.Vector{ac0, ac1}, a1} T.BitList{b0}: accepted
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Vector{b0, b1}: accepted
            case T.Chain{T.Vector{ac0, ac1}, a1} T.ListOf{b0, b1}: accepted
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Container{b0, b1}: accepted
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Union{b0}: accepted
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Null{}: accepted
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Chain{T.Boolean{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Boolean{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Boolean{}, V.and_left(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Chain{T.Unsigned{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Unsigned{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Unsigned{bc0}, V.and_left(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Chain{T.ByteVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.ByteVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.ByteVector{bc0}, V.and_left(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Chain{T.ByteList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.ByteList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.ByteList{bc0}, V.and_left(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Chain{T.BitVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.BitVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.BitVector{bc0}, V.and_left(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Chain{T.BitList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.BitList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.BitList{bc0}, V.and_left(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Chain{T.Vector{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Vector{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Vector{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Chain{T.Container{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Container{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Container{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Chain{T.Union{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Union{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Union{bc0}, V.and_left(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Chain{T.Null{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Chain{T.Chain{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Chain{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Chain{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Chain{T.End{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.End{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.End{}, V.and_left(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Chain{T.Repeat{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Repeat{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Repeat{bc0}, V.and_left(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Chain{T.Named{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Named{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Named{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Chain{T.ProgressiveList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.ProgressiveList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.ProgressiveList{bc0}, V.and_left(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Chain{T.ProgressiveBits{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.ProgressiveBits{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.ProgressiveBits{}, V.and_left(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_left(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Vector{ac0, ac1}, a1} T.End{}: accepted
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Repeat{b0}: accepted
            case T.Chain{T.Vector{ac0, ac1}, a1} T.Named{b0, b1}: accepted
            case T.Chain{T.Vector{ac0, ac1}, a1} T.ProgressiveList{b0}: accepted
            case T.Chain{T.Vector{ac0, ac1}, a1} T.ProgressiveBits{}: accepted
            case T.Chain{T.Vector{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Chain{T.Vector{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Boolean{}: accepted
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Unsigned{b0}: accepted
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.ByteVector{b0}: accepted
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.ByteList{b0}: accepted
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.BitVector{b0}: accepted
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.BitList{b0}: accepted
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Vector{b0, b1}: accepted
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.ListOf{b0, b1}: accepted
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Container{b0, b1}: accepted
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Union{b0}: accepted
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Null{}: accepted
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Chain{T.Boolean{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Boolean{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Boolean{}, V.and_left(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Chain{T.Unsigned{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Unsigned{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Unsigned{bc0}, V.and_left(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Chain{T.ByteVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.ByteVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.ByteVector{bc0}, V.and_left(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Chain{T.ByteList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.ByteList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.ByteList{bc0}, V.and_left(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Chain{T.BitVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.BitVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.BitVector{bc0}, V.and_left(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Chain{T.BitList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.BitList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.BitList{bc0}, V.and_left(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Chain{T.Vector{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Chain{T.Container{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Container{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Container{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Chain{T.Union{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Union{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Union{bc0}, V.and_left(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Chain{T.Null{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Chain{T.Chain{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Chain{T.End{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.End{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.End{}, V.and_left(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Chain{T.Repeat{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Repeat{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Repeat{bc0}, V.and_left(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Chain{T.Named{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Named{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Named{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Chain{T.ProgressiveList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}, V.and_left(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Chain{T.ProgressiveBits{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.ProgressiveBits{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.ProgressiveBits{}, V.and_left(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_left(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.End{}: accepted
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Repeat{b0}: accepted
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.Named{b0, b1}: accepted
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.ProgressiveList{b0}: accepted
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.ProgressiveBits{}: accepted
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Chain{T.ListOf{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Chain{T.Container{ac0, ac1}, a1} T.Boolean{}: accepted
            case T.Chain{T.Container{ac0, ac1}, a1} T.Unsigned{b0}: accepted
            case T.Chain{T.Container{ac0, ac1}, a1} T.ByteVector{b0}: accepted
            case T.Chain{T.Container{ac0, ac1}, a1} T.ByteList{b0}: accepted
            case T.Chain{T.Container{ac0, ac1}, a1} T.BitVector{b0}: accepted
            case T.Chain{T.Container{ac0, ac1}, a1} T.BitList{b0}: accepted
            case T.Chain{T.Container{ac0, ac1}, a1} T.Vector{b0, b1}: accepted
            case T.Chain{T.Container{ac0, ac1}, a1} T.ListOf{b0, b1}: accepted
            case T.Chain{T.Container{ac0, ac1}, a1} T.Container{b0, b1}: accepted
            case T.Chain{T.Container{ac0, ac1}, a1} T.Union{b0}: accepted
            case T.Chain{T.Container{ac0, ac1}, a1} T.Null{}: accepted
            case T.Chain{T.Container{ac0, ac1}, a1} T.Chain{T.Boolean{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Boolean{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Boolean{}, V.and_left(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Container{ac0, ac1}, a1} T.Chain{T.Unsigned{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Unsigned{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Unsigned{bc0}, V.and_left(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Container{ac0, ac1}, a1} T.Chain{T.ByteVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.ByteVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.ByteVector{bc0}, V.and_left(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Container{ac0, ac1}, a1} T.Chain{T.ByteList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.ByteList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.ByteList{bc0}, V.and_left(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Container{ac0, ac1}, a1} T.Chain{T.BitVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.BitVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.BitVector{bc0}, V.and_left(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Container{ac0, ac1}, a1} T.Chain{T.BitList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.BitList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.BitList{bc0}, V.and_left(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Container{ac0, ac1}, a1} T.Chain{T.Vector{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Vector{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Vector{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Container{ac0, ac1}, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.ListOf{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Container{ac0, ac1}, a1} T.Chain{T.Container{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Container{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Container{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Container{ac0, ac1}, a1} T.Chain{T.Union{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Union{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Union{bc0}, V.and_left(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Container{ac0, ac1}, a1} T.Chain{T.Null{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Container{ac0, ac1}, a1} T.Chain{T.Chain{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Chain{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Chain{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Container{ac0, ac1}, a1} T.Chain{T.End{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.End{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.End{}, V.and_left(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Container{ac0, ac1}, a1} T.Chain{T.Repeat{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Repeat{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Repeat{bc0}, V.and_left(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Container{ac0, ac1}, a1} T.Chain{T.Named{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Named{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Named{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Container{ac0, ac1}, a1} T.Chain{T.ProgressiveList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.ProgressiveList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.ProgressiveList{bc0}, V.and_left(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Container{ac0, ac1}, a1} T.Chain{T.ProgressiveBits{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.ProgressiveBits{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.ProgressiveBits{}, V.and_left(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Container{ac0, ac1}, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_left(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Container{ac0, ac1}, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Container{ac0, ac1}, a1} T.End{}: accepted
            case T.Chain{T.Container{ac0, ac1}, a1} T.Repeat{b0}: accepted
            case T.Chain{T.Container{ac0, ac1}, a1} T.Named{b0, b1}: accepted
            case T.Chain{T.Container{ac0, ac1}, a1} T.ProgressiveList{b0}: accepted
            case T.Chain{T.Container{ac0, ac1}, a1} T.ProgressiveBits{}: accepted
            case T.Chain{T.Container{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Chain{T.Container{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Chain{T.Union{ac0}, a1} T.Boolean{}: accepted
            case T.Chain{T.Union{ac0}, a1} T.Unsigned{b0}: accepted
            case T.Chain{T.Union{ac0}, a1} T.ByteVector{b0}: accepted
            case T.Chain{T.Union{ac0}, a1} T.ByteList{b0}: accepted
            case T.Chain{T.Union{ac0}, a1} T.BitVector{b0}: accepted
            case T.Chain{T.Union{ac0}, a1} T.BitList{b0}: accepted
            case T.Chain{T.Union{ac0}, a1} T.Vector{b0, b1}: accepted
            case T.Chain{T.Union{ac0}, a1} T.ListOf{b0, b1}: accepted
            case T.Chain{T.Union{ac0}, a1} T.Container{b0, b1}: accepted
            case T.Chain{T.Union{ac0}, a1} T.Union{b0}: accepted
            case T.Chain{T.Union{ac0}, a1} T.Null{}: accepted
            case T.Chain{T.Union{ac0}, a1} T.Chain{T.Boolean{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Boolean{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Union{ac0}, T.Boolean{}, V.and_left(I.compatible_go(p, 0, T.Union{ac0}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Union{ac0}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Union{ac0}, a1} T.Chain{T.Unsigned{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Unsigned{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Union{ac0}, T.Unsigned{bc0}, V.and_left(I.compatible_go(p, 0, T.Union{ac0}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Union{ac0}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Union{ac0}, a1} T.Chain{T.ByteVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.ByteVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Union{ac0}, T.ByteVector{bc0}, V.and_left(I.compatible_go(p, 0, T.Union{ac0}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Union{ac0}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Union{ac0}, a1} T.Chain{T.ByteList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.ByteList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Union{ac0}, T.ByteList{bc0}, V.and_left(I.compatible_go(p, 0, T.Union{ac0}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Union{ac0}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Union{ac0}, a1} T.Chain{T.BitVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.BitVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Union{ac0}, T.BitVector{bc0}, V.and_left(I.compatible_go(p, 0, T.Union{ac0}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Union{ac0}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Union{ac0}, a1} T.Chain{T.BitList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.BitList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Union{ac0}, T.BitList{bc0}, V.and_left(I.compatible_go(p, 0, T.Union{ac0}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Union{ac0}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Union{ac0}, a1} T.Chain{T.Vector{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Vector{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Union{ac0}, T.Vector{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Union{ac0}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Union{ac0}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Union{ac0}, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Union{ac0}, T.ListOf{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Union{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Union{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Union{ac0}, a1} T.Chain{T.Container{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Container{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Union{ac0}, T.Container{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Union{ac0}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Union{ac0}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Union{ac0}, a1} T.Chain{T.Union{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Union{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Union{ac0}, T.Union{bc0}, V.and_left(I.compatible_go(p, 0, T.Union{ac0}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Union{ac0}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Union{ac0}, a1} T.Chain{T.Null{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Union{ac0}, a1} T.Chain{T.Chain{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Chain{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Union{ac0}, T.Chain{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Union{ac0}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Union{ac0}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Union{ac0}, a1} T.Chain{T.End{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.End{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Union{ac0}, T.End{}, V.and_left(I.compatible_go(p, 0, T.Union{ac0}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Union{ac0}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Union{ac0}, a1} T.Chain{T.Repeat{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Repeat{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Union{ac0}, T.Repeat{bc0}, V.and_left(I.compatible_go(p, 0, T.Union{ac0}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Union{ac0}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Union{ac0}, a1} T.Chain{T.Named{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Named{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Union{ac0}, T.Named{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Union{ac0}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Union{ac0}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Union{ac0}, a1} T.Chain{T.ProgressiveList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.ProgressiveList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Union{ac0}, T.ProgressiveList{bc0}, V.and_left(I.compatible_go(p, 0, T.Union{ac0}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Union{ac0}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Union{ac0}, a1} T.Chain{T.ProgressiveBits{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.ProgressiveBits{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Union{ac0}, T.ProgressiveBits{}, V.and_left(I.compatible_go(p, 0, T.Union{ac0}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Union{ac0}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Union{ac0}, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_left(I.compatible_go(p, 0, T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Union{ac0}, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Union{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Union{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Union{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Union{ac0}, a1} T.End{}: accepted
            case T.Chain{T.Union{ac0}, a1} T.Repeat{b0}: accepted
            case T.Chain{T.Union{ac0}, a1} T.Named{b0, b1}: accepted
            case T.Chain{T.Union{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.Chain{T.Union{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.Chain{T.Union{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Chain{T.Union{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Chain{T.Null{}, a1} T.Boolean{}: accepted
            case T.Chain{T.Null{}, a1} T.Unsigned{b0}: accepted
            case T.Chain{T.Null{}, a1} T.ByteVector{b0}: accepted
            case T.Chain{T.Null{}, a1} T.ByteList{b0}: accepted
            case T.Chain{T.Null{}, a1} T.BitVector{b0}: accepted
            case T.Chain{T.Null{}, a1} T.BitList{b0}: accepted
            case T.Chain{T.Null{}, a1} T.Vector{b0, b1}: accepted
            case T.Chain{T.Null{}, a1} T.ListOf{b0, b1}: accepted
            case T.Chain{T.Null{}, a1} T.Container{b0, b1}: accepted
            case T.Chain{T.Null{}, a1} T.Union{b0}: accepted
            case T.Chain{T.Null{}, a1} T.Null{}: accepted
            case T.Chain{T.Null{}, a1} T.Chain{T.Boolean{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Null{}, a1} T.Chain{T.Unsigned{bc0}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Null{}, a1} T.Chain{T.ByteVector{bc0}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Null{}, a1} T.Chain{T.ByteList{bc0}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Null{}, a1} T.Chain{T.BitVector{bc0}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Null{}, a1} T.Chain{T.BitList{bc0}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Null{}, a1} T.Chain{T.Vector{bc0, bc1}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Null{}, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Null{}, a1} T.Chain{T.Container{bc0, bc1}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Null{}, a1} T.Chain{T.Union{bc0}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Null{}, a1} T.Chain{T.Null{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Null{}, a1} T.Chain{T.Chain{bc0, bc1}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Null{}, a1} T.Chain{T.End{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Null{}, a1} T.Chain{T.Repeat{bc0}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Null{}, a1} T.Chain{T.Named{bc0, bc1}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Null{}, a1} T.Chain{T.ProgressiveList{bc0}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Null{}, a1} T.Chain{T.ProgressiveBits{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Null{}, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Null{}, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Null{}, a1} T.End{}: accepted
            case T.Chain{T.Null{}, a1} T.Repeat{b0}: accepted
            case T.Chain{T.Null{}, a1} T.Named{b0, b1}: accepted
            case T.Chain{T.Null{}, a1} T.ProgressiveList{b0}: accepted
            case T.Chain{T.Null{}, a1} T.ProgressiveBits{}: accepted
            case T.Chain{T.Null{}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Chain{T.Null{}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Boolean{}: accepted
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Unsigned{b0}: accepted
            case T.Chain{T.Chain{ac0, ac1}, a1} T.ByteVector{b0}: accepted
            case T.Chain{T.Chain{ac0, ac1}, a1} T.ByteList{b0}: accepted
            case T.Chain{T.Chain{ac0, ac1}, a1} T.BitVector{b0}: accepted
            case T.Chain{T.Chain{ac0, ac1}, a1} T.BitList{b0}: accepted
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Vector{b0, b1}: accepted
            case T.Chain{T.Chain{ac0, ac1}, a1} T.ListOf{b0, b1}: accepted
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Container{b0, b1}: accepted
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Union{b0}: accepted
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Null{}: accepted
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Chain{T.Boolean{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Boolean{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Boolean{}, V.and_left(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Chain{T.Unsigned{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Unsigned{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Unsigned{bc0}, V.and_left(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Chain{T.ByteVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.ByteVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.ByteVector{bc0}, V.and_left(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Chain{T.ByteList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.ByteList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.ByteList{bc0}, V.and_left(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Chain{T.BitVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.BitVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.BitVector{bc0}, V.and_left(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Chain{T.BitList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.BitList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.BitList{bc0}, V.and_left(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Chain{T.Vector{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Vector{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Vector{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Chain{T.Container{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Container{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Container{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Chain{T.Union{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Union{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Union{bc0}, V.and_left(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Chain{T.Null{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Chain{T.Chain{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Chain{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Chain{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Chain{T.End{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.End{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.End{}, V.and_left(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Chain{T.Repeat{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Repeat{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Repeat{bc0}, V.and_left(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Chain{T.Named{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Named{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Named{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Chain{T.ProgressiveList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.ProgressiveList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.ProgressiveList{bc0}, V.and_left(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Chain{T.ProgressiveBits{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.ProgressiveBits{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.ProgressiveBits{}, V.and_left(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_left(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Chain{ac0, ac1}, a1} T.End{}: accepted
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Repeat{b0}: accepted
            case T.Chain{T.Chain{ac0, ac1}, a1} T.Named{b0, b1}: accepted
            case T.Chain{T.Chain{ac0, ac1}, a1} T.ProgressiveList{b0}: accepted
            case T.Chain{T.Chain{ac0, ac1}, a1} T.ProgressiveBits{}: accepted
            case T.Chain{T.Chain{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Chain{T.Chain{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Chain{T.End{}, a1} T.Boolean{}: accepted
            case T.Chain{T.End{}, a1} T.Unsigned{b0}: accepted
            case T.Chain{T.End{}, a1} T.ByteVector{b0}: accepted
            case T.Chain{T.End{}, a1} T.ByteList{b0}: accepted
            case T.Chain{T.End{}, a1} T.BitVector{b0}: accepted
            case T.Chain{T.End{}, a1} T.BitList{b0}: accepted
            case T.Chain{T.End{}, a1} T.Vector{b0, b1}: accepted
            case T.Chain{T.End{}, a1} T.ListOf{b0, b1}: accepted
            case T.Chain{T.End{}, a1} T.Container{b0, b1}: accepted
            case T.Chain{T.End{}, a1} T.Union{b0}: accepted
            case T.Chain{T.End{}, a1} T.Null{}: accepted
            case T.Chain{T.End{}, a1} T.Chain{T.Boolean{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Boolean{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.End{}, T.Boolean{}, V.and_left(I.compatible_go(p, 0, T.End{}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.End{}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.End{}, a1} T.Chain{T.Unsigned{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Unsigned{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.End{}, T.Unsigned{bc0}, V.and_left(I.compatible_go(p, 0, T.End{}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.End{}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.End{}, a1} T.Chain{T.ByteVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.ByteVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.End{}, T.ByteVector{bc0}, V.and_left(I.compatible_go(p, 0, T.End{}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.End{}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.End{}, a1} T.Chain{T.ByteList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.ByteList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.End{}, T.ByteList{bc0}, V.and_left(I.compatible_go(p, 0, T.End{}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.End{}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.End{}, a1} T.Chain{T.BitVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.BitVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.End{}, T.BitVector{bc0}, V.and_left(I.compatible_go(p, 0, T.End{}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.End{}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.End{}, a1} T.Chain{T.BitList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.BitList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.End{}, T.BitList{bc0}, V.and_left(I.compatible_go(p, 0, T.End{}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.End{}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.End{}, a1} T.Chain{T.Vector{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Vector{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.End{}, T.Vector{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.End{}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.End{}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.End{}, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.ListOf{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.End{}, T.ListOf{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.End{}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.End{}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.End{}, a1} T.Chain{T.Container{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Container{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.End{}, T.Container{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.End{}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.End{}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.End{}, a1} T.Chain{T.Union{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Union{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.End{}, T.Union{bc0}, V.and_left(I.compatible_go(p, 0, T.End{}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.End{}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.End{}, a1} T.Chain{T.Null{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.End{}, a1} T.Chain{T.Chain{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Chain{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.End{}, T.Chain{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.End{}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.End{}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.End{}, a1} T.Chain{T.End{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.End{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.End{}, T.End{}, V.and_left(I.compatible_go(p, 0, T.End{}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.End{}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.End{}, a1} T.Chain{T.Repeat{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Repeat{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.End{}, T.Repeat{bc0}, V.and_left(I.compatible_go(p, 0, T.End{}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.End{}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.End{}, a1} T.Chain{T.Named{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Named{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.End{}, T.Named{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.End{}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.End{}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.End{}, a1} T.Chain{T.ProgressiveList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.ProgressiveList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.End{}, T.ProgressiveList{bc0}, V.and_left(I.compatible_go(p, 0, T.End{}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.End{}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.End{}, a1} T.Chain{T.ProgressiveBits{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.ProgressiveBits{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.End{}, T.ProgressiveBits{}, V.and_left(I.compatible_go(p, 0, T.End{}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.End{}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.End{}, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_left(I.compatible_go(p, 0, T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.End{}, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.End{}, T.CompatibleUnion{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.End{}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.End{}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.End{}, a1} T.End{}: accepted
            case T.Chain{T.End{}, a1} T.Repeat{b0}: accepted
            case T.Chain{T.End{}, a1} T.Named{b0, b1}: accepted
            case T.Chain{T.End{}, a1} T.ProgressiveList{b0}: accepted
            case T.Chain{T.End{}, a1} T.ProgressiveBits{}: accepted
            case T.Chain{T.End{}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Chain{T.End{}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Chain{T.Repeat{ac0}, a1} T.Boolean{}: accepted
            case T.Chain{T.Repeat{ac0}, a1} T.Unsigned{b0}: accepted
            case T.Chain{T.Repeat{ac0}, a1} T.ByteVector{b0}: accepted
            case T.Chain{T.Repeat{ac0}, a1} T.ByteList{b0}: accepted
            case T.Chain{T.Repeat{ac0}, a1} T.BitVector{b0}: accepted
            case T.Chain{T.Repeat{ac0}, a1} T.BitList{b0}: accepted
            case T.Chain{T.Repeat{ac0}, a1} T.Vector{b0, b1}: accepted
            case T.Chain{T.Repeat{ac0}, a1} T.ListOf{b0, b1}: accepted
            case T.Chain{T.Repeat{ac0}, a1} T.Container{b0, b1}: accepted
            case T.Chain{T.Repeat{ac0}, a1} T.Union{b0}: accepted
            case T.Chain{T.Repeat{ac0}, a1} T.Null{}: accepted
            case T.Chain{T.Repeat{ac0}, a1} T.Chain{T.Boolean{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Boolean{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Boolean{}, V.and_left(I.compatible_go(p, 0, T.Repeat{ac0}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Repeat{ac0}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Repeat{ac0}, a1} T.Chain{T.Unsigned{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Unsigned{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Unsigned{bc0}, V.and_left(I.compatible_go(p, 0, T.Repeat{ac0}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Repeat{ac0}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Repeat{ac0}, a1} T.Chain{T.ByteVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.ByteVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.ByteVector{bc0}, V.and_left(I.compatible_go(p, 0, T.Repeat{ac0}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Repeat{ac0}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Repeat{ac0}, a1} T.Chain{T.ByteList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.ByteList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.ByteList{bc0}, V.and_left(I.compatible_go(p, 0, T.Repeat{ac0}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Repeat{ac0}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Repeat{ac0}, a1} T.Chain{T.BitVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.BitVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.BitVector{bc0}, V.and_left(I.compatible_go(p, 0, T.Repeat{ac0}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Repeat{ac0}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Repeat{ac0}, a1} T.Chain{T.BitList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.BitList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.BitList{bc0}, V.and_left(I.compatible_go(p, 0, T.Repeat{ac0}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Repeat{ac0}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Repeat{ac0}, a1} T.Chain{T.Vector{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Vector{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Vector{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Repeat{ac0}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Repeat{ac0}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Repeat{ac0}, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.ListOf{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Repeat{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Repeat{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Repeat{ac0}, a1} T.Chain{T.Container{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Container{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Container{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Repeat{ac0}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Repeat{ac0}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Repeat{ac0}, a1} T.Chain{T.Union{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Union{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Union{bc0}, V.and_left(I.compatible_go(p, 0, T.Repeat{ac0}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Repeat{ac0}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Repeat{ac0}, a1} T.Chain{T.Null{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Repeat{ac0}, a1} T.Chain{T.Chain{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Chain{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Chain{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Repeat{ac0}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Repeat{ac0}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Repeat{ac0}, a1} T.Chain{T.End{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.End{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.End{}, V.and_left(I.compatible_go(p, 0, T.Repeat{ac0}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Repeat{ac0}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Repeat{ac0}, a1} T.Chain{T.Repeat{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Repeat{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Repeat{bc0}, V.and_left(I.compatible_go(p, 0, T.Repeat{ac0}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Repeat{ac0}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Repeat{ac0}, a1} T.Chain{T.Named{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Named{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Named{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Repeat{ac0}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Repeat{ac0}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Repeat{ac0}, a1} T.Chain{T.ProgressiveList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.ProgressiveList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.ProgressiveList{bc0}, V.and_left(I.compatible_go(p, 0, T.Repeat{ac0}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Repeat{ac0}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Repeat{ac0}, a1} T.Chain{T.ProgressiveBits{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.ProgressiveBits{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.ProgressiveBits{}, V.and_left(I.compatible_go(p, 0, T.Repeat{ac0}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Repeat{ac0}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Repeat{ac0}, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_left(I.compatible_go(p, 0, T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Repeat{ac0}, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Repeat{ac0}, a1} T.End{}: accepted
            case T.Chain{T.Repeat{ac0}, a1} T.Repeat{b0}: accepted
            case T.Chain{T.Repeat{ac0}, a1} T.Named{b0, b1}: accepted
            case T.Chain{T.Repeat{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.Chain{T.Repeat{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.Chain{T.Repeat{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Chain{T.Repeat{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Chain{T.Named{ac0, ac1}, a1} T.Boolean{}: accepted
            case T.Chain{T.Named{ac0, ac1}, a1} T.Unsigned{b0}: accepted
            case T.Chain{T.Named{ac0, ac1}, a1} T.ByteVector{b0}: accepted
            case T.Chain{T.Named{ac0, ac1}, a1} T.ByteList{b0}: accepted
            case T.Chain{T.Named{ac0, ac1}, a1} T.BitVector{b0}: accepted
            case T.Chain{T.Named{ac0, ac1}, a1} T.BitList{b0}: accepted
            case T.Chain{T.Named{ac0, ac1}, a1} T.Vector{b0, b1}: accepted
            case T.Chain{T.Named{ac0, ac1}, a1} T.ListOf{b0, b1}: accepted
            case T.Chain{T.Named{ac0, ac1}, a1} T.Container{b0, b1}: accepted
            case T.Chain{T.Named{ac0, ac1}, a1} T.Union{b0}: accepted
            case T.Chain{T.Named{ac0, ac1}, a1} T.Null{}: accepted
            case T.Chain{T.Named{ac0, ac1}, a1} T.Chain{T.Boolean{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Boolean{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Boolean{}, V.and_left(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Named{ac0, ac1}, a1} T.Chain{T.Unsigned{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Unsigned{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Unsigned{bc0}, V.and_left(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Named{ac0, ac1}, a1} T.Chain{T.ByteVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.ByteVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.ByteVector{bc0}, V.and_left(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Named{ac0, ac1}, a1} T.Chain{T.ByteList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.ByteList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.ByteList{bc0}, V.and_left(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Named{ac0, ac1}, a1} T.Chain{T.BitVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.BitVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.BitVector{bc0}, V.and_left(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Named{ac0, ac1}, a1} T.Chain{T.BitList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.BitList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.BitList{bc0}, V.and_left(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Named{ac0, ac1}, a1} T.Chain{T.Vector{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Vector{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Vector{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Named{ac0, ac1}, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.ListOf{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Named{ac0, ac1}, a1} T.Chain{T.Container{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Container{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Container{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Named{ac0, ac1}, a1} T.Chain{T.Union{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Union{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Union{bc0}, V.and_left(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Named{ac0, ac1}, a1} T.Chain{T.Null{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.Named{ac0, ac1}, a1} T.Chain{T.Chain{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Chain{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Chain{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Named{ac0, ac1}, a1} T.Chain{T.End{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.End{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.End{}, V.and_left(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Named{ac0, ac1}, a1} T.Chain{T.Repeat{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Repeat{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Repeat{bc0}, V.and_left(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Named{ac0, ac1}, a1} T.Chain{T.Named{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Named{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Named{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Named{ac0, ac1}, a1} T.Chain{T.ProgressiveList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.ProgressiveList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.ProgressiveList{bc0}, V.and_left(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Named{ac0, ac1}, a1} T.Chain{T.ProgressiveBits{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.ProgressiveBits{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.ProgressiveBits{}, V.and_left(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Named{ac0, ac1}, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_left(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Named{ac0, ac1}, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.Named{ac0, ac1}, a1} T.End{}: accepted
            case T.Chain{T.Named{ac0, ac1}, a1} T.Repeat{b0}: accepted
            case T.Chain{T.Named{ac0, ac1}, a1} T.Named{b0, b1}: accepted
            case T.Chain{T.Named{ac0, ac1}, a1} T.ProgressiveList{b0}: accepted
            case T.Chain{T.Named{ac0, ac1}, a1} T.ProgressiveBits{}: accepted
            case T.Chain{T.Named{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Chain{T.Named{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Boolean{}: accepted
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Unsigned{b0}: accepted
            case T.Chain{T.ProgressiveList{ac0}, a1} T.ByteVector{b0}: accepted
            case T.Chain{T.ProgressiveList{ac0}, a1} T.ByteList{b0}: accepted
            case T.Chain{T.ProgressiveList{ac0}, a1} T.BitVector{b0}: accepted
            case T.Chain{T.ProgressiveList{ac0}, a1} T.BitList{b0}: accepted
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Vector{b0, b1}: accepted
            case T.Chain{T.ProgressiveList{ac0}, a1} T.ListOf{b0, b1}: accepted
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Container{b0, b1}: accepted
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Union{b0}: accepted
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Null{}: accepted
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Chain{T.Boolean{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Boolean{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Boolean{}, V.and_left(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Chain{T.Unsigned{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Unsigned{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Unsigned{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Chain{T.ByteVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.ByteVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.ByteVector{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Chain{T.ByteList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.ByteList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.ByteList{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Chain{T.BitVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.BitVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.BitVector{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Chain{T.BitList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.BitList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.BitList{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Chain{T.Vector{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Vector{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Vector{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Chain{T.Container{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Container{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Container{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Chain{T.Union{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Union{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Union{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Chain{T.Null{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Chain{T.Chain{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Chain{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Chain{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Chain{T.End{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.End{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.End{}, V.and_left(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Chain{T.Repeat{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Repeat{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Repeat{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Chain{T.Named{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Named{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Named{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Chain{T.ProgressiveList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.ProgressiveList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.ProgressiveList{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Chain{T.ProgressiveBits{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.ProgressiveBits{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.ProgressiveBits{}, V.and_left(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_left(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveList{ac0}, a1} T.End{}: accepted
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Repeat{b0}: accepted
            case T.Chain{T.ProgressiveList{ac0}, a1} T.Named{b0, b1}: accepted
            case T.Chain{T.ProgressiveList{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.Chain{T.ProgressiveList{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.Chain{T.ProgressiveList{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Chain{T.ProgressiveList{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Chain{T.ProgressiveBits{}, a1} T.Boolean{}: accepted
            case T.Chain{T.ProgressiveBits{}, a1} T.Unsigned{b0}: accepted
            case T.Chain{T.ProgressiveBits{}, a1} T.ByteVector{b0}: accepted
            case T.Chain{T.ProgressiveBits{}, a1} T.ByteList{b0}: accepted
            case T.Chain{T.ProgressiveBits{}, a1} T.BitVector{b0}: accepted
            case T.Chain{T.ProgressiveBits{}, a1} T.BitList{b0}: accepted
            case T.Chain{T.ProgressiveBits{}, a1} T.Vector{b0, b1}: accepted
            case T.Chain{T.ProgressiveBits{}, a1} T.ListOf{b0, b1}: accepted
            case T.Chain{T.ProgressiveBits{}, a1} T.Container{b0, b1}: accepted
            case T.Chain{T.ProgressiveBits{}, a1} T.Union{b0}: accepted
            case T.Chain{T.ProgressiveBits{}, a1} T.Null{}: accepted
            case T.Chain{T.ProgressiveBits{}, a1} T.Chain{T.Boolean{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Boolean{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Boolean{}, V.and_left(I.compatible_go(p, 0, T.ProgressiveBits{}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveBits{}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveBits{}, a1} T.Chain{T.Unsigned{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Unsigned{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Unsigned{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveBits{}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveBits{}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveBits{}, a1} T.Chain{T.ByteVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.ByteVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.ByteVector{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveBits{}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveBits{}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveBits{}, a1} T.Chain{T.ByteList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.ByteList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.ByteList{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveBits{}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveBits{}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveBits{}, a1} T.Chain{T.BitVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.BitVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.BitVector{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveBits{}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveBits{}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveBits{}, a1} T.Chain{T.BitList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.BitList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.BitList{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveBits{}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveBits{}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveBits{}, a1} T.Chain{T.Vector{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Vector{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Vector{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ProgressiveBits{}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveBits{}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveBits{}, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.ListOf{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.ListOf{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ProgressiveBits{}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveBits{}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveBits{}, a1} T.Chain{T.Container{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Container{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Container{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ProgressiveBits{}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveBits{}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveBits{}, a1} T.Chain{T.Union{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Union{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Union{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveBits{}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveBits{}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveBits{}, a1} T.Chain{T.Null{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.ProgressiveBits{}, a1} T.Chain{T.Chain{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Chain{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Chain{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ProgressiveBits{}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveBits{}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveBits{}, a1} T.Chain{T.End{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.End{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.End{}, V.and_left(I.compatible_go(p, 0, T.ProgressiveBits{}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveBits{}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveBits{}, a1} T.Chain{T.Repeat{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Repeat{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Repeat{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveBits{}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveBits{}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveBits{}, a1} T.Chain{T.Named{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Named{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Named{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ProgressiveBits{}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveBits{}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveBits{}, a1} T.Chain{T.ProgressiveList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.ProgressiveList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.ProgressiveList{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveBits{}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveBits{}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveBits{}, a1} T.Chain{T.ProgressiveBits{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.ProgressiveBits{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.ProgressiveBits{}, V.and_left(I.compatible_go(p, 0, T.ProgressiveBits{}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveBits{}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveBits{}, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_left(I.compatible_go(p, 0, T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveBits{}, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveBits{}, a1} T.End{}: accepted
            case T.Chain{T.ProgressiveBits{}, a1} T.Repeat{b0}: accepted
            case T.Chain{T.ProgressiveBits{}, a1} T.Named{b0, b1}: accepted
            case T.Chain{T.ProgressiveBits{}, a1} T.ProgressiveList{b0}: accepted
            case T.Chain{T.ProgressiveBits{}, a1} T.ProgressiveBits{}: accepted
            case T.Chain{T.ProgressiveBits{}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Chain{T.ProgressiveBits{}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Boolean{}: accepted
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Unsigned{b0}: accepted
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ByteVector{b0}: accepted
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ByteList{b0}: accepted
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.BitVector{b0}: accepted
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.BitList{b0}: accepted
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{b0, b1}: accepted
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{b0, b1}: accepted
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Container{b0, b1}: accepted
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Union{b0}: accepted
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Null{}: accepted
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{T.Boolean{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}, V.and_left(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{T.Unsigned{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{T.ByteVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{T.ByteList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{T.BitVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{T.BitList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{T.Vector{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{T.Container{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{T.Union{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{T.Null{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{T.Chain{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{T.End{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}, V.and_left(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{T.Repeat{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{T.Named{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{T.ProgressiveList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}, V.and_left(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{T.ProgressiveBits{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}, V.and_left(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_left(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.End{}: accepted
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Repeat{b0}: accepted
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Named{b0, b1}: accepted
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ProgressiveList{b0}: accepted
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ProgressiveBits{}: accepted
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Chain{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Boolean{}: accepted
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Unsigned{b0}: accepted
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.ByteVector{b0}: accepted
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.ByteList{b0}: accepted
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.BitVector{b0}: accepted
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.BitList{b0}: accepted
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{b0, b1}: accepted
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{b0, b1}: accepted
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Container{b0, b1}: accepted
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Union{b0}: accepted
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Null{}: accepted
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{T.Boolean{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Boolean{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Boolean{}, V.and_left(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Boolean{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{T.Unsigned{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}, V.and_left(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{T.ByteVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}, V.and_left(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{T.ByteList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}, V.and_left(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{T.BitVector{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}, V.and_left(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{T.BitList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}, V.and_left(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{T.Vector{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{T.Container{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{T.Union{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Union{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Union{bc0}, V.and_left(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Union{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{T.Null{}, b1}: monotone(p, extra, Slots{}, a1, b1, accepted)
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{T.Chain{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{T.End{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.End{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.End{}, V.and_left(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.End{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{T.Repeat{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}, V.and_left(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{T.Named{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{T.ProgressiveList{bc0}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}, V.and_left(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{T.ProgressiveBits{}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}, V.and_left(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_left(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(Nat.add(p, extra), 3, a1, b1), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_left(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)), monotone(p, extra, Slots{}, a1, b1, V.and_right(I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), I.compatible_go(p, 3, a1, b1), accepted)))
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.End{}: accepted
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Repeat{b0}: accepted
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.Named{b0, b1}: accepted
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.ProgressiveList{b0}: accepted
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.ProgressiveBits{}: accepted
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Chain{T.CompatibleUnion{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.End{} T.Boolean{}: accepted
            case T.End{} T.Unsigned{b0}: accepted
            case T.End{} T.ByteVector{b0}: accepted
            case T.End{} T.ByteList{b0}: accepted
            case T.End{} T.BitVector{b0}: accepted
            case T.End{} T.BitList{b0}: accepted
            case T.End{} T.Vector{b0, b1}: accepted
            case T.End{} T.ListOf{b0, b1}: accepted
            case T.End{} T.Container{b0, b1}: accepted
            case T.End{} T.Union{b0}: accepted
            case T.End{} T.Null{}: accepted
            case T.End{} T.Chain{T.Boolean{}, b1}: accepted
            case T.End{} T.Chain{T.Unsigned{bc0}, b1}: accepted
            case T.End{} T.Chain{T.ByteVector{bc0}, b1}: accepted
            case T.End{} T.Chain{T.ByteList{bc0}, b1}: accepted
            case T.End{} T.Chain{T.BitVector{bc0}, b1}: accepted
            case T.End{} T.Chain{T.BitList{bc0}, b1}: accepted
            case T.End{} T.Chain{T.Vector{bc0, bc1}, b1}: accepted
            case T.End{} T.Chain{T.ListOf{bc0, bc1}, b1}: accepted
            case T.End{} T.Chain{T.Container{bc0, bc1}, b1}: accepted
            case T.End{} T.Chain{T.Union{bc0}, b1}: accepted
            case T.End{} T.Chain{T.Null{}, b1}: accepted
            case T.End{} T.Chain{T.Chain{bc0, bc1}, b1}: accepted
            case T.End{} T.Chain{T.End{}, b1}: accepted
            case T.End{} T.Chain{T.Repeat{bc0}, b1}: accepted
            case T.End{} T.Chain{T.Named{bc0, bc1}, b1}: accepted
            case T.End{} T.Chain{T.ProgressiveList{bc0}, b1}: accepted
            case T.End{} T.Chain{T.ProgressiveBits{}, b1}: accepted
            case T.End{} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.End{} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.End{} T.End{}: accepted
            case T.End{} T.Repeat{b0}: accepted
            case T.End{} T.Named{b0, b1}: accepted
            case T.End{} T.ProgressiveList{b0}: accepted
            case T.End{} T.ProgressiveBits{}: accepted
            case T.End{} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.End{} T.CompatibleUnion{b0, b1}: accepted
            case T.Repeat{a0} T.Boolean{}: accepted
            case T.Repeat{a0} T.Unsigned{b0}: accepted
            case T.Repeat{a0} T.ByteVector{b0}: accepted
            case T.Repeat{a0} T.ByteList{b0}: accepted
            case T.Repeat{a0} T.BitVector{b0}: accepted
            case T.Repeat{a0} T.BitList{b0}: accepted
            case T.Repeat{a0} T.Vector{b0, b1}: accepted
            case T.Repeat{a0} T.ListOf{b0, b1}: accepted
            case T.Repeat{a0} T.Container{b0, b1}: accepted
            case T.Repeat{a0} T.Union{b0}: accepted
            case T.Repeat{a0} T.Null{}: accepted
            case T.Repeat{a0} T.Chain{T.Boolean{}, b1}: accepted
            case T.Repeat{a0} T.Chain{T.Unsigned{bc0}, b1}: accepted
            case T.Repeat{a0} T.Chain{T.ByteVector{bc0}, b1}: accepted
            case T.Repeat{a0} T.Chain{T.ByteList{bc0}, b1}: accepted
            case T.Repeat{a0} T.Chain{T.BitVector{bc0}, b1}: accepted
            case T.Repeat{a0} T.Chain{T.BitList{bc0}, b1}: accepted
            case T.Repeat{a0} T.Chain{T.Vector{bc0, bc1}, b1}: accepted
            case T.Repeat{a0} T.Chain{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Repeat{a0} T.Chain{T.Container{bc0, bc1}, b1}: accepted
            case T.Repeat{a0} T.Chain{T.Union{bc0}, b1}: accepted
            case T.Repeat{a0} T.Chain{T.Null{}, b1}: accepted
            case T.Repeat{a0} T.Chain{T.Chain{bc0, bc1}, b1}: accepted
            case T.Repeat{a0} T.Chain{T.End{}, b1}: accepted
            case T.Repeat{a0} T.Chain{T.Repeat{bc0}, b1}: accepted
            case T.Repeat{a0} T.Chain{T.Named{bc0, bc1}, b1}: accepted
            case T.Repeat{a0} T.Chain{T.ProgressiveList{bc0}, b1}: accepted
            case T.Repeat{a0} T.Chain{T.ProgressiveBits{}, b1}: accepted
            case T.Repeat{a0} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Repeat{a0} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Repeat{a0} T.End{}: accepted
            case T.Repeat{a0} T.Repeat{b0}: accepted
            case T.Repeat{a0} T.Named{b0, b1}: accepted
            case T.Repeat{a0} T.ProgressiveList{b0}: accepted
            case T.Repeat{a0} T.ProgressiveBits{}: accepted
            case T.Repeat{a0} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Repeat{a0} T.CompatibleUnion{b0, b1}: accepted
            case T.Named{a0, a1} T.Boolean{}: accepted
            case T.Named{a0, a1} T.Unsigned{b0}: accepted
            case T.Named{a0, a1} T.ByteVector{b0}: accepted
            case T.Named{a0, a1} T.ByteList{b0}: accepted
            case T.Named{a0, a1} T.BitVector{b0}: accepted
            case T.Named{a0, a1} T.BitList{b0}: accepted
            case T.Named{a0, a1} T.Vector{b0, b1}: accepted
            case T.Named{a0, a1} T.ListOf{b0, b1}: accepted
            case T.Named{a0, a1} T.Container{b0, b1}: accepted
            case T.Named{a0, a1} T.Union{b0}: accepted
            case T.Named{a0, a1} T.Null{}: accepted
            case T.Named{a0, a1} T.Chain{T.Boolean{}, b1}: accepted
            case T.Named{a0, a1} T.Chain{T.Unsigned{bc0}, b1}: accepted
            case T.Named{a0, a1} T.Chain{T.ByteVector{bc0}, b1}: accepted
            case T.Named{a0, a1} T.Chain{T.ByteList{bc0}, b1}: accepted
            case T.Named{a0, a1} T.Chain{T.BitVector{bc0}, b1}: accepted
            case T.Named{a0, a1} T.Chain{T.BitList{bc0}, b1}: accepted
            case T.Named{a0, a1} T.Chain{T.Vector{bc0, bc1}, b1}: accepted
            case T.Named{a0, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Named{a0, a1} T.Chain{T.Container{bc0, bc1}, b1}: accepted
            case T.Named{a0, a1} T.Chain{T.Union{bc0}, b1}: accepted
            case T.Named{a0, a1} T.Chain{T.Null{}, b1}: accepted
            case T.Named{a0, a1} T.Chain{T.Chain{bc0, bc1}, b1}: accepted
            case T.Named{a0, a1} T.Chain{T.End{}, b1}: accepted
            case T.Named{a0, a1} T.Chain{T.Repeat{bc0}, b1}: accepted
            case T.Named{a0, a1} T.Chain{T.Named{bc0, bc1}, b1}: accepted
            case T.Named{a0, a1} T.Chain{T.ProgressiveList{bc0}, b1}: accepted
            case T.Named{a0, a1} T.Chain{T.ProgressiveBits{}, b1}: accepted
            case T.Named{a0, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Named{a0, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Named{a0, a1} T.End{}: accepted
            case T.Named{a0, a1} T.Repeat{b0}: accepted
            case T.Named{a0, a1} T.Named{b0, b1}: accepted
            case T.Named{a0, a1} T.ProgressiveList{b0}: accepted
            case T.Named{a0, a1} T.ProgressiveBits{}: accepted
            case T.Named{a0, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Named{a0, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ProgressiveList{a0} T.Boolean{}: accepted
            case T.ProgressiveList{a0} T.Unsigned{b0}: accepted
            case T.ProgressiveList{a0} T.ByteVector{b0}: accepted
            case T.ProgressiveList{a0} T.ByteList{b0}: accepted
            case T.ProgressiveList{a0} T.BitVector{b0}: accepted
            case T.ProgressiveList{a0} T.BitList{b0}: accepted
            case T.ProgressiveList{a0} T.Vector{b0, b1}: accepted
            case T.ProgressiveList{a0} T.ListOf{b0, b1}: accepted
            case T.ProgressiveList{a0} T.Container{b0, b1}: accepted
            case T.ProgressiveList{a0} T.Union{b0}: accepted
            case T.ProgressiveList{a0} T.Null{}: accepted
            case T.ProgressiveList{a0} T.Chain{T.Boolean{}, b1}: accepted
            case T.ProgressiveList{a0} T.Chain{T.Unsigned{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.Chain{T.ByteVector{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.Chain{T.ByteList{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.Chain{T.BitVector{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.Chain{T.BitList{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.Chain{T.Vector{bc0, bc1}, b1}: accepted
            case T.ProgressiveList{a0} T.Chain{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ProgressiveList{a0} T.Chain{T.Container{bc0, bc1}, b1}: accepted
            case T.ProgressiveList{a0} T.Chain{T.Union{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.Chain{T.Null{}, b1}: accepted
            case T.ProgressiveList{a0} T.Chain{T.Chain{bc0, bc1}, b1}: accepted
            case T.ProgressiveList{a0} T.Chain{T.End{}, b1}: accepted
            case T.ProgressiveList{a0} T.Chain{T.Repeat{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.Chain{T.Named{bc0, bc1}, b1}: accepted
            case T.ProgressiveList{a0} T.Chain{T.ProgressiveList{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.Chain{T.ProgressiveBits{}, b1}: accepted
            case T.ProgressiveList{a0} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ProgressiveList{a0} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ProgressiveList{a0} T.End{}: accepted
            case T.ProgressiveList{a0} T.Repeat{b0}: accepted
            case T.ProgressiveList{a0} T.Named{b0, b1}: accepted
            case T.ProgressiveList{a0} T.ProgressiveList{b0}: accepted
            case T.ProgressiveList{a0} T.ProgressiveBits{}: accepted
            case T.ProgressiveList{a0} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ProgressiveList{a0} T.CompatibleUnion{b0, b1}: accepted
            case T.ProgressiveBits{} T.Boolean{}: accepted
            case T.ProgressiveBits{} T.Unsigned{b0}: accepted
            case T.ProgressiveBits{} T.ByteVector{b0}: accepted
            case T.ProgressiveBits{} T.ByteList{b0}: accepted
            case T.ProgressiveBits{} T.BitVector{b0}: accepted
            case T.ProgressiveBits{} T.BitList{b0}: accepted
            case T.ProgressiveBits{} T.Vector{b0, b1}: accepted
            case T.ProgressiveBits{} T.ListOf{b0, b1}: accepted
            case T.ProgressiveBits{} T.Container{b0, b1}: accepted
            case T.ProgressiveBits{} T.Union{b0}: accepted
            case T.ProgressiveBits{} T.Null{}: accepted
            case T.ProgressiveBits{} T.Chain{T.Boolean{}, b1}: accepted
            case T.ProgressiveBits{} T.Chain{T.Unsigned{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.Chain{T.ByteVector{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.Chain{T.ByteList{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.Chain{T.BitVector{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.Chain{T.BitList{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.Chain{T.Vector{bc0, bc1}, b1}: accepted
            case T.ProgressiveBits{} T.Chain{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ProgressiveBits{} T.Chain{T.Container{bc0, bc1}, b1}: accepted
            case T.ProgressiveBits{} T.Chain{T.Union{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.Chain{T.Null{}, b1}: accepted
            case T.ProgressiveBits{} T.Chain{T.Chain{bc0, bc1}, b1}: accepted
            case T.ProgressiveBits{} T.Chain{T.End{}, b1}: accepted
            case T.ProgressiveBits{} T.Chain{T.Repeat{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.Chain{T.Named{bc0, bc1}, b1}: accepted
            case T.ProgressiveBits{} T.Chain{T.ProgressiveList{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.Chain{T.ProgressiveBits{}, b1}: accepted
            case T.ProgressiveBits{} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ProgressiveBits{} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ProgressiveBits{} T.End{}: accepted
            case T.ProgressiveBits{} T.Repeat{b0}: accepted
            case T.ProgressiveBits{} T.Named{b0, b1}: accepted
            case T.ProgressiveBits{} T.ProgressiveList{b0}: accepted
            case T.ProgressiveBits{} T.ProgressiveBits{}: accepted
            case T.ProgressiveBits{} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ProgressiveBits{} T.CompatibleUnion{b0, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Boolean{}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Unsigned{b0}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ByteVector{b0}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ByteList{b0}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.BitVector{b0}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.BitList{b0}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Vector{b0, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ListOf{b0, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Container{b0, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Union{b0}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Null{}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Chain{T.Boolean{}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Chain{T.Unsigned{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Chain{T.ByteVector{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Chain{T.ByteList{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Chain{T.BitVector{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Chain{T.BitList{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Chain{T.Vector{bc0, bc1}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Chain{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Chain{T.Container{bc0, bc1}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Chain{T.Union{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Chain{T.Null{}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Chain{T.Chain{bc0, bc1}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Chain{T.End{}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Chain{T.Repeat{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Chain{T.Named{bc0, bc1}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Chain{T.ProgressiveList{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Chain{T.ProgressiveBits{}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.End{}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Repeat{b0}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Named{b0, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveList{b0}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveBits{}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.CompatibleUnion{b0, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Boolean{}: accepted
            case T.CompatibleUnion{a0, a1} T.Unsigned{b0}: accepted
            case T.CompatibleUnion{a0, a1} T.ByteVector{b0}: accepted
            case T.CompatibleUnion{a0, a1} T.ByteList{b0}: accepted
            case T.CompatibleUnion{a0, a1} T.BitVector{b0}: accepted
            case T.CompatibleUnion{a0, a1} T.BitList{b0}: accepted
            case T.CompatibleUnion{a0, a1} T.Vector{b0, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ListOf{b0, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Container{b0, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Union{b0}: accepted
            case T.CompatibleUnion{a0, a1} T.Null{}: accepted
            case T.CompatibleUnion{a0, a1} T.Chain{T.Boolean{}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Chain{T.Unsigned{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Chain{T.ByteVector{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Chain{T.ByteList{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Chain{T.BitVector{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Chain{T.BitList{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Chain{T.Vector{bc0, bc1}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Chain{T.ListOf{bc0, bc1}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Chain{T.Container{bc0, bc1}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Chain{T.Union{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Chain{T.Null{}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Chain{T.Chain{bc0, bc1}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Chain{T.End{}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Chain{T.Repeat{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Chain{T.Named{bc0, bc1}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Chain{T.ProgressiveList{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Chain{T.ProgressiveBits{}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Chain{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Chain{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.End{}: accepted
            case T.CompatibleUnion{a0, a1} T.Repeat{b0}: accepted
            case T.CompatibleUnion{a0, a1} T.Named{b0, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ProgressiveList{b0}: accepted
            case T.CompatibleUnion{a0, a1} T.ProgressiveBits{}: accepted
            case T.CompatibleUnion{a0, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.CompatibleUnion{a0, a1} T.CompatibleUnion{b0, b1}: accepted
        case Pair{}:
          match a b:
            case T.Boolean{} T.Boolean{}: accepted
            case T.Boolean{} T.Unsigned{b0}: accepted
            case T.Boolean{} T.ByteVector{b0}: accepted
            case T.Boolean{} T.ByteList{b0}: accepted
            case T.Boolean{} T.BitVector{b0}: accepted
            case T.Boolean{} T.BitList{b0}: accepted
            case T.Boolean{} T.Vector{T.Boolean{}, b1}: accepted
            case T.Boolean{} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.Boolean{} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.Boolean{} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.Boolean{} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.Boolean{} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.Boolean{} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.Boolean{} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Boolean{} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.Boolean{} T.Vector{T.Union{bc0}, b1}: accepted
            case T.Boolean{} T.Vector{T.Null{}, b1}: accepted
            case T.Boolean{} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.Boolean{} T.Vector{T.End{}, b1}: accepted
            case T.Boolean{} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.Boolean{} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.Boolean{} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.Boolean{} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.Boolean{} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Boolean{} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Boolean{} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Boolean{} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Boolean{} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Boolean{} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Boolean{} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Boolean{} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Boolean{} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Boolean{} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Boolean{} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Boolean{} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Boolean{} T.ListOf{T.Null{}, b1}: accepted
            case T.Boolean{} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Boolean{} T.ListOf{T.End{}, b1}: accepted
            case T.Boolean{} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Boolean{} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Boolean{} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Boolean{} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Boolean{} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Boolean{} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Boolean{} T.Container{b0, b1}: accepted
            case T.Boolean{} T.Union{b0}: accepted
            case T.Boolean{} T.Null{}: accepted
            case T.Boolean{} T.Chain{b0, b1}: accepted
            case T.Boolean{} T.End{}: accepted
            case T.Boolean{} T.Repeat{b0}: accepted
            case T.Boolean{} T.Named{b0, b1}: accepted
            case T.Boolean{} T.ProgressiveList{b0}: accepted
            case T.Boolean{} T.ProgressiveBits{}: accepted
            case T.Boolean{} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Boolean{} T.CompatibleUnion{b0, b1}: accepted
            case T.Unsigned{a0} T.Boolean{}: accepted
            case T.Unsigned{a0} T.Unsigned{b0}: accepted
            case T.Unsigned{a0} T.ByteVector{b0}: accepted
            case T.Unsigned{a0} T.ByteList{b0}: accepted
            case T.Unsigned{a0} T.BitVector{b0}: accepted
            case T.Unsigned{a0} T.BitList{b0}: accepted
            case T.Unsigned{a0} T.Vector{T.Boolean{}, b1}: accepted
            case T.Unsigned{a0} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.Unsigned{a0} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.Unsigned{a0} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.Unsigned{a0} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.Unsigned{a0} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.Unsigned{a0} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.Unsigned{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Unsigned{a0} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.Unsigned{a0} T.Vector{T.Union{bc0}, b1}: accepted
            case T.Unsigned{a0} T.Vector{T.Null{}, b1}: accepted
            case T.Unsigned{a0} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.Unsigned{a0} T.Vector{T.End{}, b1}: accepted
            case T.Unsigned{a0} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.Unsigned{a0} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.Unsigned{a0} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.Unsigned{a0} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.Unsigned{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Unsigned{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Unsigned{a0} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Unsigned{a0} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Unsigned{a0} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Unsigned{a0} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Unsigned{a0} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Unsigned{a0} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Unsigned{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Unsigned{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Unsigned{a0} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Unsigned{a0} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Unsigned{a0} T.ListOf{T.Null{}, b1}: accepted
            case T.Unsigned{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Unsigned{a0} T.ListOf{T.End{}, b1}: accepted
            case T.Unsigned{a0} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Unsigned{a0} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Unsigned{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Unsigned{a0} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Unsigned{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Unsigned{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Unsigned{a0} T.Container{b0, b1}: accepted
            case T.Unsigned{a0} T.Union{b0}: accepted
            case T.Unsigned{a0} T.Null{}: accepted
            case T.Unsigned{a0} T.Chain{b0, b1}: accepted
            case T.Unsigned{a0} T.End{}: accepted
            case T.Unsigned{a0} T.Repeat{b0}: accepted
            case T.Unsigned{a0} T.Named{b0, b1}: accepted
            case T.Unsigned{a0} T.ProgressiveList{b0}: accepted
            case T.Unsigned{a0} T.ProgressiveBits{}: accepted
            case T.Unsigned{a0} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Unsigned{a0} T.CompatibleUnion{b0, b1}: accepted
            case T.ByteVector{a0} T.Boolean{}: accepted
            case T.ByteVector{a0} T.Unsigned{b0}: accepted
            case T.ByteVector{a0} T.ByteVector{b0}: accepted
            case T.ByteVector{a0} T.ByteList{b0}: accepted
            case T.ByteVector{a0} T.BitVector{b0}: accepted
            case T.ByteVector{a0} T.BitList{b0}: accepted
            case T.ByteVector{a0} T.Vector{T.Boolean{}, b1}: accepted
            case T.ByteVector{a0} T.Vector{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a0, b1), Nat.is_eq(P.width(bc0), 1n), V.and_left(Nat.is_eq(a0, b1), Nat.is_eq(P.width(bc0), 1n), accepted), V.and_right(Nat.is_eq(a0, b1), Nat.is_eq(P.width(bc0), 1n), accepted))
            case T.ByteVector{a0} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ByteVector{a0} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ByteVector{a0} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ByteVector{a0} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ByteVector{a0} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ByteVector{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ByteVector{a0} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ByteVector{a0} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ByteVector{a0} T.Vector{T.Null{}, b1}: accepted
            case T.ByteVector{a0} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ByteVector{a0} T.Vector{T.End{}, b1}: accepted
            case T.ByteVector{a0} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ByteVector{a0} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ByteVector{a0} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ByteVector{a0} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ByteVector{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ByteVector{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ByteVector{a0} T.ListOf{T.Boolean{}, b1}: accepted
            case T.ByteVector{a0} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.ByteVector{a0} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.ByteVector{a0} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.ByteVector{a0} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.ByteVector{a0} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.ByteVector{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.ByteVector{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ByteVector{a0} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.ByteVector{a0} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.ByteVector{a0} T.ListOf{T.Null{}, b1}: accepted
            case T.ByteVector{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.ByteVector{a0} T.ListOf{T.End{}, b1}: accepted
            case T.ByteVector{a0} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.ByteVector{a0} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.ByteVector{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.ByteVector{a0} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.ByteVector{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ByteVector{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ByteVector{a0} T.Container{b0, b1}: accepted
            case T.ByteVector{a0} T.Union{b0}: accepted
            case T.ByteVector{a0} T.Null{}: accepted
            case T.ByteVector{a0} T.Chain{b0, b1}: accepted
            case T.ByteVector{a0} T.End{}: accepted
            case T.ByteVector{a0} T.Repeat{b0}: accepted
            case T.ByteVector{a0} T.Named{b0, b1}: accepted
            case T.ByteVector{a0} T.ProgressiveList{b0}: accepted
            case T.ByteVector{a0} T.ProgressiveBits{}: accepted
            case T.ByteVector{a0} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ByteVector{a0} T.CompatibleUnion{b0, b1}: accepted
            case T.ByteList{a0} T.Boolean{}: accepted
            case T.ByteList{a0} T.Unsigned{b0}: accepted
            case T.ByteList{a0} T.ByteVector{b0}: accepted
            case T.ByteList{a0} T.ByteList{b0}: accepted
            case T.ByteList{a0} T.BitVector{b0}: accepted
            case T.ByteList{a0} T.BitList{b0}: accepted
            case T.ByteList{a0} T.Vector{T.Boolean{}, b1}: accepted
            case T.ByteList{a0} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ByteList{a0} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ByteList{a0} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ByteList{a0} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ByteList{a0} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ByteList{a0} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ByteList{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ByteList{a0} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ByteList{a0} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ByteList{a0} T.Vector{T.Null{}, b1}: accepted
            case T.ByteList{a0} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ByteList{a0} T.Vector{T.End{}, b1}: accepted
            case T.ByteList{a0} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ByteList{a0} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ByteList{a0} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ByteList{a0} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ByteList{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ByteList{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ByteList{a0} T.ListOf{T.Boolean{}, b1}: accepted
            case T.ByteList{a0} T.ListOf{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a0, b1), Nat.is_eq(P.width(bc0), 1n), V.and_left(Nat.is_eq(a0, b1), Nat.is_eq(P.width(bc0), 1n), accepted), V.and_right(Nat.is_eq(a0, b1), Nat.is_eq(P.width(bc0), 1n), accepted))
            case T.ByteList{a0} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.ByteList{a0} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.ByteList{a0} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.ByteList{a0} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.ByteList{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.ByteList{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ByteList{a0} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.ByteList{a0} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.ByteList{a0} T.ListOf{T.Null{}, b1}: accepted
            case T.ByteList{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.ByteList{a0} T.ListOf{T.End{}, b1}: accepted
            case T.ByteList{a0} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.ByteList{a0} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.ByteList{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.ByteList{a0} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.ByteList{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ByteList{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ByteList{a0} T.Container{b0, b1}: accepted
            case T.ByteList{a0} T.Union{b0}: accepted
            case T.ByteList{a0} T.Null{}: accepted
            case T.ByteList{a0} T.Chain{b0, b1}: accepted
            case T.ByteList{a0} T.End{}: accepted
            case T.ByteList{a0} T.Repeat{b0}: accepted
            case T.ByteList{a0} T.Named{b0, b1}: accepted
            case T.ByteList{a0} T.ProgressiveList{b0}: accepted
            case T.ByteList{a0} T.ProgressiveBits{}: accepted
            case T.ByteList{a0} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ByteList{a0} T.CompatibleUnion{b0, b1}: accepted
            case T.BitVector{a0} T.Boolean{}: accepted
            case T.BitVector{a0} T.Unsigned{b0}: accepted
            case T.BitVector{a0} T.ByteVector{b0}: accepted
            case T.BitVector{a0} T.ByteList{b0}: accepted
            case T.BitVector{a0} T.BitVector{b0}: accepted
            case T.BitVector{a0} T.BitList{b0}: accepted
            case T.BitVector{a0} T.Vector{T.Boolean{}, b1}: accepted
            case T.BitVector{a0} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.BitVector{a0} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.BitVector{a0} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.BitVector{a0} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.BitVector{a0} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.BitVector{a0} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.BitVector{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.BitVector{a0} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.BitVector{a0} T.Vector{T.Union{bc0}, b1}: accepted
            case T.BitVector{a0} T.Vector{T.Null{}, b1}: accepted
            case T.BitVector{a0} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.BitVector{a0} T.Vector{T.End{}, b1}: accepted
            case T.BitVector{a0} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.BitVector{a0} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.BitVector{a0} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.BitVector{a0} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.BitVector{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.BitVector{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.BitVector{a0} T.ListOf{T.Boolean{}, b1}: accepted
            case T.BitVector{a0} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.BitVector{a0} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.BitVector{a0} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.BitVector{a0} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.BitVector{a0} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.BitVector{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.BitVector{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.BitVector{a0} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.BitVector{a0} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.BitVector{a0} T.ListOf{T.Null{}, b1}: accepted
            case T.BitVector{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.BitVector{a0} T.ListOf{T.End{}, b1}: accepted
            case T.BitVector{a0} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.BitVector{a0} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.BitVector{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.BitVector{a0} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.BitVector{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.BitVector{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.BitVector{a0} T.Container{b0, b1}: accepted
            case T.BitVector{a0} T.Union{b0}: accepted
            case T.BitVector{a0} T.Null{}: accepted
            case T.BitVector{a0} T.Chain{b0, b1}: accepted
            case T.BitVector{a0} T.End{}: accepted
            case T.BitVector{a0} T.Repeat{b0}: accepted
            case T.BitVector{a0} T.Named{b0, b1}: accepted
            case T.BitVector{a0} T.ProgressiveList{b0}: accepted
            case T.BitVector{a0} T.ProgressiveBits{}: accepted
            case T.BitVector{a0} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.BitVector{a0} T.CompatibleUnion{b0, b1}: accepted
            case T.BitList{a0} T.Boolean{}: accepted
            case T.BitList{a0} T.Unsigned{b0}: accepted
            case T.BitList{a0} T.ByteVector{b0}: accepted
            case T.BitList{a0} T.ByteList{b0}: accepted
            case T.BitList{a0} T.BitVector{b0}: accepted
            case T.BitList{a0} T.BitList{b0}: accepted
            case T.BitList{a0} T.Vector{T.Boolean{}, b1}: accepted
            case T.BitList{a0} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.BitList{a0} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.BitList{a0} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.BitList{a0} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.BitList{a0} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.BitList{a0} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.BitList{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.BitList{a0} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.BitList{a0} T.Vector{T.Union{bc0}, b1}: accepted
            case T.BitList{a0} T.Vector{T.Null{}, b1}: accepted
            case T.BitList{a0} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.BitList{a0} T.Vector{T.End{}, b1}: accepted
            case T.BitList{a0} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.BitList{a0} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.BitList{a0} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.BitList{a0} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.BitList{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.BitList{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.BitList{a0} T.ListOf{T.Boolean{}, b1}: accepted
            case T.BitList{a0} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.BitList{a0} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.BitList{a0} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.BitList{a0} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.BitList{a0} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.BitList{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.BitList{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.BitList{a0} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.BitList{a0} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.BitList{a0} T.ListOf{T.Null{}, b1}: accepted
            case T.BitList{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.BitList{a0} T.ListOf{T.End{}, b1}: accepted
            case T.BitList{a0} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.BitList{a0} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.BitList{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.BitList{a0} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.BitList{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.BitList{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.BitList{a0} T.Container{b0, b1}: accepted
            case T.BitList{a0} T.Union{b0}: accepted
            case T.BitList{a0} T.Null{}: accepted
            case T.BitList{a0} T.Chain{b0, b1}: accepted
            case T.BitList{a0} T.End{}: accepted
            case T.BitList{a0} T.Repeat{b0}: accepted
            case T.BitList{a0} T.Named{b0, b1}: accepted
            case T.BitList{a0} T.ProgressiveList{b0}: accepted
            case T.BitList{a0} T.ProgressiveBits{}: accepted
            case T.BitList{a0} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.BitList{a0} T.CompatibleUnion{b0, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.Boolean{}: accepted
            case T.Vector{T.Boolean{}, a1} T.Unsigned{b0}: accepted
            case T.Vector{T.Boolean{}, a1} T.ByteVector{b0}: accepted
            case T.Vector{T.Boolean{}, a1} T.ByteList{b0}: accepted
            case T.Vector{T.Boolean{}, a1} T.BitVector{b0}: accepted
            case T.Vector{T.Boolean{}, a1} T.BitList{b0}: accepted
            case T.Vector{T.Boolean{}, a1} T.Vector{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Boolean{}), accepted)))
            case T.Vector{T.Boolean{}, a1} T.Vector{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Unsigned{bc0}), accepted)))
            case T.Vector{T.Boolean{}, a1} T.Vector{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ByteVector{bc0}), accepted)))
            case T.Vector{T.Boolean{}, a1} T.Vector{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ByteList{bc0}), accepted)))
            case T.Vector{T.Boolean{}, a1} T.Vector{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.BitVector{bc0}), accepted)))
            case T.Vector{T.Boolean{}, a1} T.Vector{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.BitList{bc0}), accepted)))
            case T.Vector{T.Boolean{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Vector{bc0, bc1}), accepted)))
            case T.Vector{T.Boolean{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ListOf{bc0, bc1}), accepted)))
            case T.Vector{T.Boolean{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Container{bc0, bc1}), accepted)))
            case T.Vector{T.Boolean{}, a1} T.Vector{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Union{bc0}), accepted)))
            case T.Vector{T.Boolean{}, a1} T.Vector{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Null{}), accepted)))
            case T.Vector{T.Boolean{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Chain{bc0, bc1}), accepted)))
            case T.Vector{T.Boolean{}, a1} T.Vector{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.End{}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.End{}), accepted)))
            case T.Vector{T.Boolean{}, a1} T.Vector{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Repeat{bc0}), accepted)))
            case T.Vector{T.Boolean{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Named{bc0, bc1}), accepted)))
            case T.Vector{T.Boolean{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ProgressiveList{bc0}), accepted)))
            case T.Vector{T.Boolean{}, a1} T.Vector{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ProgressiveBits{}), accepted)))
            case T.Vector{T.Boolean{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.Vector{T.Boolean{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.Vector{T.Boolean{}, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.Container{b0, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.Union{b0}: accepted
            case T.Vector{T.Boolean{}, a1} T.Null{}: accepted
            case T.Vector{T.Boolean{}, a1} T.Chain{b0, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.End{}: accepted
            case T.Vector{T.Boolean{}, a1} T.Repeat{b0}: accepted
            case T.Vector{T.Boolean{}, a1} T.Named{b0, b1}: accepted
            case T.Vector{T.Boolean{}, a1} T.ProgressiveList{b0}: accepted
            case T.Vector{T.Boolean{}, a1} T.ProgressiveBits{}: accepted
            case T.Vector{T.Boolean{}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Vector{T.Boolean{}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.Boolean{}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.Unsigned{b0}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ByteVector{b0}: V.and_true(Nat.is_eq(a1, b0), Nat.is_eq(P.width(ac0), 1n), V.and_left(Nat.is_eq(a1, b0), Nat.is_eq(P.width(ac0), 1n), accepted), V.and_right(Nat.is_eq(a1, b0), Nat.is_eq(P.width(ac0), 1n), accepted))
            case T.Vector{T.Unsigned{ac0}, a1} T.ByteList{b0}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.BitVector{b0}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.BitList{b0}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Boolean{}), accepted)))
            case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Unsigned{bc0}), accepted)))
            case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ByteVector{bc0}), accepted)))
            case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ByteList{bc0}), accepted)))
            case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.BitVector{bc0}), accepted)))
            case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.BitList{bc0}), accepted)))
            case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Vector{bc0, bc1}), accepted)))
            case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ListOf{bc0, bc1}), accepted)))
            case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Container{bc0, bc1}), accepted)))
            case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Union{bc0}), accepted)))
            case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Null{}), accepted)))
            case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Chain{bc0, bc1}), accepted)))
            case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.End{}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.End{}), accepted)))
            case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Repeat{bc0}), accepted)))
            case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Named{bc0, bc1}), accepted)))
            case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ProgressiveList{bc0}), accepted)))
            case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ProgressiveBits{}), accepted)))
            case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.Container{b0, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.Union{b0}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.Null{}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.Chain{b0, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.End{}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.Repeat{b0}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.Named{b0, b1}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Vector{T.Unsigned{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.Boolean{}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.Unsigned{b0}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ByteVector{b0}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ByteList{b0}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.BitVector{b0}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.BitList{b0}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Boolean{}), accepted)))
            case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Unsigned{bc0}), accepted)))
            case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ByteVector{bc0}), accepted)))
            case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ByteList{bc0}), accepted)))
            case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.BitVector{bc0}), accepted)))
            case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.BitList{bc0}), accepted)))
            case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Vector{bc0, bc1}), accepted)))
            case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ListOf{bc0, bc1}), accepted)))
            case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Container{bc0, bc1}), accepted)))
            case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Union{bc0}), accepted)))
            case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Null{}), accepted)))
            case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Chain{bc0, bc1}), accepted)))
            case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.End{}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.End{}), accepted)))
            case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Repeat{bc0}), accepted)))
            case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Named{bc0, bc1}), accepted)))
            case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ProgressiveList{bc0}), accepted)))
            case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ProgressiveBits{}), accepted)))
            case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.Container{b0, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.Union{b0}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.Null{}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.Chain{b0, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.End{}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.Repeat{b0}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.Named{b0, b1}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Vector{T.ByteVector{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.Boolean{}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.Unsigned{b0}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ByteVector{b0}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ByteList{b0}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.BitVector{b0}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.BitList{b0}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Boolean{}), accepted)))
            case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Unsigned{bc0}), accepted)))
            case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ByteVector{bc0}), accepted)))
            case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ByteList{bc0}), accepted)))
            case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.BitVector{bc0}), accepted)))
            case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.BitList{bc0}), accepted)))
            case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Vector{bc0, bc1}), accepted)))
            case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ListOf{bc0, bc1}), accepted)))
            case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Container{bc0, bc1}), accepted)))
            case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Union{bc0}), accepted)))
            case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Null{}), accepted)))
            case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Chain{bc0, bc1}), accepted)))
            case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.End{}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.End{}), accepted)))
            case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Repeat{bc0}), accepted)))
            case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Named{bc0, bc1}), accepted)))
            case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ProgressiveList{bc0}), accepted)))
            case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ProgressiveBits{}), accepted)))
            case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.Container{b0, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.Union{b0}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.Null{}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.Chain{b0, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.End{}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.Repeat{b0}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.Named{b0, b1}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Vector{T.ByteList{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.Boolean{}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.Unsigned{b0}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ByteVector{b0}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ByteList{b0}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.BitVector{b0}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.BitList{b0}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Boolean{}), accepted)))
            case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Unsigned{bc0}), accepted)))
            case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ByteVector{bc0}), accepted)))
            case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ByteList{bc0}), accepted)))
            case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.BitVector{bc0}), accepted)))
            case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.BitList{bc0}), accepted)))
            case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Vector{bc0, bc1}), accepted)))
            case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ListOf{bc0, bc1}), accepted)))
            case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Container{bc0, bc1}), accepted)))
            case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Union{bc0}), accepted)))
            case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Null{}), accepted)))
            case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Chain{bc0, bc1}), accepted)))
            case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.End{}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.End{}), accepted)))
            case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Repeat{bc0}), accepted)))
            case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Named{bc0, bc1}), accepted)))
            case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ProgressiveList{bc0}), accepted)))
            case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ProgressiveBits{}), accepted)))
            case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.Container{b0, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.Union{b0}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.Null{}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.Chain{b0, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.End{}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.Repeat{b0}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.Named{b0, b1}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Vector{T.BitVector{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.Boolean{}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.Unsigned{b0}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ByteVector{b0}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ByteList{b0}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.BitVector{b0}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.BitList{b0}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Boolean{}), accepted)))
            case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Unsigned{bc0}), accepted)))
            case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ByteVector{bc0}), accepted)))
            case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ByteList{bc0}), accepted)))
            case T.Vector{T.BitList{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.BitVector{bc0}), accepted)))
            case T.Vector{T.BitList{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.BitList{bc0}), accepted)))
            case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Vector{bc0, bc1}), accepted)))
            case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ListOf{bc0, bc1}), accepted)))
            case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Container{bc0, bc1}), accepted)))
            case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Union{bc0}), accepted)))
            case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Null{}), accepted)))
            case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Chain{bc0, bc1}), accepted)))
            case T.Vector{T.BitList{ac0}, a1} T.Vector{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.End{}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.End{}), accepted)))
            case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Repeat{bc0}), accepted)))
            case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Named{bc0, bc1}), accepted)))
            case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ProgressiveList{bc0}), accepted)))
            case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ProgressiveBits{}), accepted)))
            case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.Vector{T.BitList{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.Container{b0, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.Union{b0}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.Null{}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.Chain{b0, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.End{}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.Repeat{b0}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.Named{b0, b1}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Vector{T.BitList{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Boolean{}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Unsigned{b0}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ByteVector{b0}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ByteList{b0}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.BitVector{b0}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.BitList{b0}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Boolean{}), accepted)))
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Unsigned{bc0}), accepted)))
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ByteVector{bc0}), accepted)))
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ByteList{bc0}), accepted)))
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.BitVector{bc0}), accepted)))
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.BitList{bc0}), accepted)))
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Vector{bc0, bc1}), accepted)))
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}), accepted)))
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Container{bc0, bc1}), accepted)))
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Union{bc0}), accepted)))
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Null{}), accepted)))
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Chain{bc0, bc1}), accepted)))
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.End{}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.End{}), accepted)))
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Repeat{bc0}), accepted)))
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Named{bc0, bc1}), accepted)))
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ProgressiveList{bc0}), accepted)))
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ProgressiveBits{}), accepted)))
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Container{b0, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Union{b0}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Null{}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Chain{b0, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.End{}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Repeat{b0}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.Named{b0, b1}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ProgressiveList{b0}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ProgressiveBits{}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Vector{T.Vector{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Boolean{}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Unsigned{b0}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ByteVector{b0}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ByteList{b0}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.BitVector{b0}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.BitList{b0}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Boolean{}), accepted)))
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Unsigned{bc0}), accepted)))
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ByteVector{bc0}), accepted)))
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ByteList{bc0}), accepted)))
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.BitVector{bc0}), accepted)))
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.BitList{bc0}), accepted)))
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}), accepted)))
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}), accepted)))
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Container{bc0, bc1}), accepted)))
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Union{bc0}), accepted)))
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Null{}), accepted)))
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}), accepted)))
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.End{}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.End{}), accepted)))
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Repeat{bc0}), accepted)))
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Named{bc0, bc1}), accepted)))
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}), accepted)))
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ProgressiveBits{}), accepted)))
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Container{b0, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Union{b0}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Null{}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Chain{b0, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.End{}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Repeat{b0}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.Named{b0, b1}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ProgressiveList{b0}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ProgressiveBits{}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Vector{T.ListOf{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.Boolean{}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.Unsigned{b0}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ByteVector{b0}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ByteList{b0}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.BitVector{b0}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.BitList{b0}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Boolean{}), accepted)))
            case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Unsigned{bc0}), accepted)))
            case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ByteVector{bc0}), accepted)))
            case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ByteList{bc0}), accepted)))
            case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.BitVector{bc0}), accepted)))
            case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.BitList{bc0}), accepted)))
            case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Vector{bc0, bc1}), accepted)))
            case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ListOf{bc0, bc1}), accepted)))
            case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Container{bc0, bc1}), accepted)))
            case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Union{bc0}), accepted)))
            case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Null{}), accepted)))
            case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Chain{bc0, bc1}), accepted)))
            case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.End{}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.End{}), accepted)))
            case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Repeat{bc0}), accepted)))
            case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Named{bc0, bc1}), accepted)))
            case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ProgressiveList{bc0}), accepted)))
            case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ProgressiveBits{}), accepted)))
            case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.Container{b0, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.Union{b0}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.Null{}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.Chain{b0, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.End{}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.Repeat{b0}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.Named{b0, b1}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ProgressiveList{b0}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ProgressiveBits{}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Vector{T.Container{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.Boolean{}: accepted
            case T.Vector{T.Union{ac0}, a1} T.Unsigned{b0}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ByteVector{b0}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ByteList{b0}: accepted
            case T.Vector{T.Union{ac0}, a1} T.BitVector{b0}: accepted
            case T.Vector{T.Union{ac0}, a1} T.BitList{b0}: accepted
            case T.Vector{T.Union{ac0}, a1} T.Vector{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Boolean{}), accepted)))
            case T.Vector{T.Union{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Unsigned{bc0}), accepted)))
            case T.Vector{T.Union{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ByteVector{bc0}), accepted)))
            case T.Vector{T.Union{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ByteList{bc0}), accepted)))
            case T.Vector{T.Union{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.BitVector{bc0}), accepted)))
            case T.Vector{T.Union{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.BitList{bc0}), accepted)))
            case T.Vector{T.Union{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Vector{bc0, bc1}), accepted)))
            case T.Vector{T.Union{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ListOf{bc0, bc1}), accepted)))
            case T.Vector{T.Union{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Container{bc0, bc1}), accepted)))
            case T.Vector{T.Union{ac0}, a1} T.Vector{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Union{bc0}), accepted)))
            case T.Vector{T.Union{ac0}, a1} T.Vector{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Null{}), accepted)))
            case T.Vector{T.Union{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Chain{bc0, bc1}), accepted)))
            case T.Vector{T.Union{ac0}, a1} T.Vector{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.End{}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.End{}), accepted)))
            case T.Vector{T.Union{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Repeat{bc0}), accepted)))
            case T.Vector{T.Union{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Named{bc0, bc1}), accepted)))
            case T.Vector{T.Union{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ProgressiveList{bc0}), accepted)))
            case T.Vector{T.Union{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ProgressiveBits{}), accepted)))
            case T.Vector{T.Union{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.Vector{T.Union{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.Container{b0, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.Union{b0}: accepted
            case T.Vector{T.Union{ac0}, a1} T.Null{}: accepted
            case T.Vector{T.Union{ac0}, a1} T.Chain{b0, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.End{}: accepted
            case T.Vector{T.Union{ac0}, a1} T.Repeat{b0}: accepted
            case T.Vector{T.Union{ac0}, a1} T.Named{b0, b1}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.Vector{T.Union{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Vector{T.Union{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Vector{T.Null{}, a1} T.Boolean{}: accepted
            case T.Vector{T.Null{}, a1} T.Unsigned{b0}: accepted
            case T.Vector{T.Null{}, a1} T.ByteVector{b0}: accepted
            case T.Vector{T.Null{}, a1} T.ByteList{b0}: accepted
            case T.Vector{T.Null{}, a1} T.BitVector{b0}: accepted
            case T.Vector{T.Null{}, a1} T.BitList{b0}: accepted
            case T.Vector{T.Null{}, a1} T.Vector{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Boolean{}), accepted)))
            case T.Vector{T.Null{}, a1} T.Vector{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Unsigned{bc0}), accepted)))
            case T.Vector{T.Null{}, a1} T.Vector{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ByteVector{bc0}), accepted)))
            case T.Vector{T.Null{}, a1} T.Vector{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ByteList{bc0}), accepted)))
            case T.Vector{T.Null{}, a1} T.Vector{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.BitVector{bc0}), accepted)))
            case T.Vector{T.Null{}, a1} T.Vector{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.BitList{bc0}), accepted)))
            case T.Vector{T.Null{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Vector{bc0, bc1}), accepted)))
            case T.Vector{T.Null{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ListOf{bc0, bc1}), accepted)))
            case T.Vector{T.Null{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Container{bc0, bc1}), accepted)))
            case T.Vector{T.Null{}, a1} T.Vector{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Union{bc0}), accepted)))
            case T.Vector{T.Null{}, a1} T.Vector{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Null{}), accepted)))
            case T.Vector{T.Null{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Chain{bc0, bc1}), accepted)))
            case T.Vector{T.Null{}, a1} T.Vector{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.End{}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.End{}), accepted)))
            case T.Vector{T.Null{}, a1} T.Vector{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Repeat{bc0}), accepted)))
            case T.Vector{T.Null{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Named{bc0, bc1}), accepted)))
            case T.Vector{T.Null{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ProgressiveList{bc0}), accepted)))
            case T.Vector{T.Null{}, a1} T.Vector{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ProgressiveBits{}), accepted)))
            case T.Vector{T.Null{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.Vector{T.Null{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.Vector{T.Null{}, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Vector{T.Null{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Vector{T.Null{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Vector{T.Null{}, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Vector{T.Null{}, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Vector{T.Null{}, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Vector{T.Null{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Vector{T.Null{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Vector{T.Null{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Vector{T.Null{}, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Vector{T.Null{}, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Vector{T.Null{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Vector{T.Null{}, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Vector{T.Null{}, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Vector{T.Null{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Vector{T.Null{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Vector{T.Null{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Vector{T.Null{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Vector{T.Null{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Vector{T.Null{}, a1} T.Container{b0, b1}: accepted
            case T.Vector{T.Null{}, a1} T.Union{b0}: accepted
            case T.Vector{T.Null{}, a1} T.Null{}: accepted
            case T.Vector{T.Null{}, a1} T.Chain{b0, b1}: accepted
            case T.Vector{T.Null{}, a1} T.End{}: accepted
            case T.Vector{T.Null{}, a1} T.Repeat{b0}: accepted
            case T.Vector{T.Null{}, a1} T.Named{b0, b1}: accepted
            case T.Vector{T.Null{}, a1} T.ProgressiveList{b0}: accepted
            case T.Vector{T.Null{}, a1} T.ProgressiveBits{}: accepted
            case T.Vector{T.Null{}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Vector{T.Null{}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Boolean{}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Unsigned{b0}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ByteVector{b0}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ByteList{b0}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.BitVector{b0}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.BitList{b0}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Boolean{}), accepted)))
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Unsigned{bc0}), accepted)))
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ByteVector{bc0}), accepted)))
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ByteList{bc0}), accepted)))
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.BitVector{bc0}), accepted)))
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.BitList{bc0}), accepted)))
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Vector{bc0, bc1}), accepted)))
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}), accepted)))
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Container{bc0, bc1}), accepted)))
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Union{bc0}), accepted)))
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Null{}), accepted)))
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Chain{bc0, bc1}), accepted)))
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.End{}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.End{}), accepted)))
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Repeat{bc0}), accepted)))
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Named{bc0, bc1}), accepted)))
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ProgressiveList{bc0}), accepted)))
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ProgressiveBits{}), accepted)))
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Container{b0, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Union{b0}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Null{}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Chain{b0, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.End{}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Repeat{b0}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.Named{b0, b1}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ProgressiveList{b0}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ProgressiveBits{}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Vector{T.Chain{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Vector{T.End{}, a1} T.Boolean{}: accepted
            case T.Vector{T.End{}, a1} T.Unsigned{b0}: accepted
            case T.Vector{T.End{}, a1} T.ByteVector{b0}: accepted
            case T.Vector{T.End{}, a1} T.ByteList{b0}: accepted
            case T.Vector{T.End{}, a1} T.BitVector{b0}: accepted
            case T.Vector{T.End{}, a1} T.BitList{b0}: accepted
            case T.Vector{T.End{}, a1} T.Vector{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.End{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Boolean{}), accepted)))
            case T.Vector{T.End{}, a1} T.Vector{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.End{}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Unsigned{bc0}), accepted)))
            case T.Vector{T.End{}, a1} T.Vector{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.End{}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ByteVector{bc0}), accepted)))
            case T.Vector{T.End{}, a1} T.Vector{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.End{}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ByteList{bc0}), accepted)))
            case T.Vector{T.End{}, a1} T.Vector{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.End{}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.BitVector{bc0}), accepted)))
            case T.Vector{T.End{}, a1} T.Vector{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.End{}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.BitList{bc0}), accepted)))
            case T.Vector{T.End{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.End{}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Vector{bc0, bc1}), accepted)))
            case T.Vector{T.End{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.End{}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ListOf{bc0, bc1}), accepted)))
            case T.Vector{T.End{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.End{}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Container{bc0, bc1}), accepted)))
            case T.Vector{T.End{}, a1} T.Vector{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.End{}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Union{bc0}), accepted)))
            case T.Vector{T.End{}, a1} T.Vector{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.End{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Null{}), accepted)))
            case T.Vector{T.End{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.End{}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Chain{bc0, bc1}), accepted)))
            case T.Vector{T.End{}, a1} T.Vector{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.End{}), accepted), monotone(p, extra, Pair{}, T.End{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.End{}), accepted)))
            case T.Vector{T.End{}, a1} T.Vector{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.End{}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Repeat{bc0}), accepted)))
            case T.Vector{T.End{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.End{}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Named{bc0, bc1}), accepted)))
            case T.Vector{T.End{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.End{}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ProgressiveList{bc0}), accepted)))
            case T.Vector{T.End{}, a1} T.Vector{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.End{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ProgressiveBits{}), accepted)))
            case T.Vector{T.End{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.Vector{T.End{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.End{}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.Vector{T.End{}, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Vector{T.End{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Vector{T.End{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Vector{T.End{}, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Vector{T.End{}, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Vector{T.End{}, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Vector{T.End{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Vector{T.End{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Vector{T.End{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Vector{T.End{}, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Vector{T.End{}, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Vector{T.End{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Vector{T.End{}, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Vector{T.End{}, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Vector{T.End{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Vector{T.End{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Vector{T.End{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Vector{T.End{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Vector{T.End{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Vector{T.End{}, a1} T.Container{b0, b1}: accepted
            case T.Vector{T.End{}, a1} T.Union{b0}: accepted
            case T.Vector{T.End{}, a1} T.Null{}: accepted
            case T.Vector{T.End{}, a1} T.Chain{b0, b1}: accepted
            case T.Vector{T.End{}, a1} T.End{}: accepted
            case T.Vector{T.End{}, a1} T.Repeat{b0}: accepted
            case T.Vector{T.End{}, a1} T.Named{b0, b1}: accepted
            case T.Vector{T.End{}, a1} T.ProgressiveList{b0}: accepted
            case T.Vector{T.End{}, a1} T.ProgressiveBits{}: accepted
            case T.Vector{T.End{}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Vector{T.End{}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.Boolean{}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.Unsigned{b0}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ByteVector{b0}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ByteList{b0}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.BitVector{b0}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.BitList{b0}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Boolean{}), accepted)))
            case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Unsigned{bc0}), accepted)))
            case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ByteVector{bc0}), accepted)))
            case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ByteList{bc0}), accepted)))
            case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.BitVector{bc0}), accepted)))
            case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.BitList{bc0}), accepted)))
            case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Vector{bc0, bc1}), accepted)))
            case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ListOf{bc0, bc1}), accepted)))
            case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Container{bc0, bc1}), accepted)))
            case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Union{bc0}), accepted)))
            case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Null{}), accepted)))
            case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Chain{bc0, bc1}), accepted)))
            case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.End{}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.End{}), accepted)))
            case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Repeat{bc0}), accepted)))
            case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Named{bc0, bc1}), accepted)))
            case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ProgressiveList{bc0}), accepted)))
            case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ProgressiveBits{}), accepted)))
            case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.Container{b0, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.Union{b0}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.Null{}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.Chain{b0, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.End{}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.Repeat{b0}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.Named{b0, b1}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Vector{T.Repeat{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.Boolean{}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.Unsigned{b0}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ByteVector{b0}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ByteList{b0}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.BitVector{b0}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.BitList{b0}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Boolean{}), accepted)))
            case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Unsigned{bc0}), accepted)))
            case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ByteVector{bc0}), accepted)))
            case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ByteList{bc0}), accepted)))
            case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.BitVector{bc0}), accepted)))
            case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.BitList{bc0}), accepted)))
            case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Vector{bc0, bc1}), accepted)))
            case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ListOf{bc0, bc1}), accepted)))
            case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Container{bc0, bc1}), accepted)))
            case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Union{bc0}), accepted)))
            case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Null{}), accepted)))
            case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Chain{bc0, bc1}), accepted)))
            case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.End{}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.End{}), accepted)))
            case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Repeat{bc0}), accepted)))
            case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Named{bc0, bc1}), accepted)))
            case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ProgressiveList{bc0}), accepted)))
            case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ProgressiveBits{}), accepted)))
            case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.Container{b0, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.Union{b0}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.Null{}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.Chain{b0, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.End{}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.Repeat{b0}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.Named{b0, b1}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ProgressiveList{b0}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ProgressiveBits{}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Vector{T.Named{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Boolean{}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Unsigned{b0}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ByteVector{b0}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ByteList{b0}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.BitVector{b0}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.BitList{b0}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Boolean{}), accepted)))
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Unsigned{bc0}), accepted)))
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ByteVector{bc0}), accepted)))
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ByteList{bc0}), accepted)))
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.BitVector{bc0}), accepted)))
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.BitList{bc0}), accepted)))
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Vector{bc0, bc1}), accepted)))
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}), accepted)))
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Container{bc0, bc1}), accepted)))
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Union{bc0}), accepted)))
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Null{}), accepted)))
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Chain{bc0, bc1}), accepted)))
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.End{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.End{}), accepted)))
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Repeat{bc0}), accepted)))
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Named{bc0, bc1}), accepted)))
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ProgressiveList{bc0}), accepted)))
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ProgressiveBits{}), accepted)))
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Container{b0, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Union{b0}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Null{}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Chain{b0, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.End{}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Repeat{b0}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.Named{b0, b1}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Vector{T.ProgressiveList{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.Boolean{}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.Unsigned{b0}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ByteVector{b0}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ByteList{b0}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.BitVector{b0}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.BitList{b0}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Boolean{}), accepted)))
            case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Unsigned{bc0}), accepted)))
            case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ByteVector{bc0}), accepted)))
            case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ByteList{bc0}), accepted)))
            case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.BitVector{bc0}), accepted)))
            case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.BitList{bc0}), accepted)))
            case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Vector{bc0, bc1}), accepted)))
            case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ListOf{bc0, bc1}), accepted)))
            case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Container{bc0, bc1}), accepted)))
            case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Union{bc0}), accepted)))
            case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Null{}), accepted)))
            case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Chain{bc0, bc1}), accepted)))
            case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.End{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.End{}), accepted)))
            case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Repeat{bc0}), accepted)))
            case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Named{bc0, bc1}), accepted)))
            case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ProgressiveList{bc0}), accepted)))
            case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ProgressiveBits{}), accepted)))
            case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.Container{b0, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.Union{b0}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.Null{}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.Chain{b0, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.End{}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.Repeat{b0}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.Named{b0, b1}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ProgressiveList{b0}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ProgressiveBits{}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Vector{T.ProgressiveBits{}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Boolean{}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Unsigned{b0}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ByteVector{b0}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ByteList{b0}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.BitVector{b0}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.BitList{b0}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}), accepted)))
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}), accepted)))
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}), accepted)))
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}), accepted)))
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}), accepted)))
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}), accepted)))
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}), accepted)))
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}), accepted)))
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}), accepted)))
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}), accepted)))
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}), accepted)))
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}), accepted)))
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}), accepted)))
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}), accepted)))
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}), accepted)))
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}), accepted)))
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}), accepted)))
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Container{b0, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Union{b0}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Null{}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{b0, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.End{}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Repeat{b0}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Named{b0, b1}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ProgressiveList{b0}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ProgressiveBits{}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Boolean{}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Unsigned{b0}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ByteVector{b0}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ByteList{b0}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.BitVector{b0}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.BitList{b0}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Boolean{}), accepted)))
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}), accepted)))
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}), accepted)))
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}), accepted)))
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}), accepted)))
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}), accepted)))
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}), accepted)))
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}), accepted)))
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}), accepted)))
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Union{bc0}), accepted)))
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Null{}), accepted)))
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}), accepted)))
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.End{}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.End{}), accepted)))
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}), accepted)))
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}), accepted)))
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}), accepted)))
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}), accepted)))
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Container{b0, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Union{b0}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Null{}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{b0, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.End{}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Repeat{b0}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Named{b0, b1}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ProgressiveList{b0}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ProgressiveBits{}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Boolean{}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Unsigned{b0}: accepted
            case T.ListOf{T.Boolean{}, a1} T.ByteVector{b0}: accepted
            case T.ListOf{T.Boolean{}, a1} T.ByteList{b0}: accepted
            case T.ListOf{T.Boolean{}, a1} T.BitVector{b0}: accepted
            case T.ListOf{T.Boolean{}, a1} T.BitList{b0}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Vector{T.Null{}, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Vector{T.End{}, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Boolean{}), accepted)))
            case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Unsigned{bc0}), accepted)))
            case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ByteVector{bc0}), accepted)))
            case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ByteList{bc0}), accepted)))
            case T.ListOf{T.Boolean{}, a1} T.ListOf{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.BitVector{bc0}), accepted)))
            case T.ListOf{T.Boolean{}, a1} T.ListOf{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.BitList{bc0}), accepted)))
            case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Vector{bc0, bc1}), accepted)))
            case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ListOf{bc0, bc1}), accepted)))
            case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Container{bc0, bc1}), accepted)))
            case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Union{bc0}), accepted)))
            case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Null{}), accepted)))
            case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Chain{bc0, bc1}), accepted)))
            case T.ListOf{T.Boolean{}, a1} T.ListOf{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.End{}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.End{}), accepted)))
            case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Repeat{bc0}), accepted)))
            case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.Named{bc0, bc1}), accepted)))
            case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ProgressiveList{bc0}), accepted)))
            case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ProgressiveBits{}), accepted)))
            case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.ListOf{T.Boolean{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Boolean{}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Boolean{}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Boolean{}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.ListOf{T.Boolean{}, a1} T.Container{b0, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Union{b0}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Null{}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Chain{b0, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.End{}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Repeat{b0}: accepted
            case T.ListOf{T.Boolean{}, a1} T.Named{b0, b1}: accepted
            case T.ListOf{T.Boolean{}, a1} T.ProgressiveList{b0}: accepted
            case T.ListOf{T.Boolean{}, a1} T.ProgressiveBits{}: accepted
            case T.ListOf{T.Boolean{}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ListOf{T.Boolean{}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Boolean{}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Unsigned{b0}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.ByteVector{b0}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.ByteList{b0}: V.and_true(Nat.is_eq(a1, b0), Nat.is_eq(P.width(ac0), 1n), V.and_left(Nat.is_eq(a1, b0), Nat.is_eq(P.width(ac0), 1n), accepted), V.and_right(Nat.is_eq(a1, b0), Nat.is_eq(P.width(ac0), 1n), accepted))
            case T.ListOf{T.Unsigned{ac0}, a1} T.BitVector{b0}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.BitList{b0}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Null{}, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.End{}, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Boolean{}), accepted)))
            case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Unsigned{bc0}), accepted)))
            case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ByteVector{bc0}), accepted)))
            case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ByteList{bc0}), accepted)))
            case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.BitVector{bc0}), accepted)))
            case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.BitList{bc0}), accepted)))
            case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Vector{bc0, bc1}), accepted)))
            case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ListOf{bc0, bc1}), accepted)))
            case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Container{bc0, bc1}), accepted)))
            case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Union{bc0}), accepted)))
            case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Null{}), accepted)))
            case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Chain{bc0, bc1}), accepted)))
            case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.End{}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.End{}), accepted)))
            case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Repeat{bc0}), accepted)))
            case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.Named{bc0, bc1}), accepted)))
            case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ProgressiveList{bc0}), accepted)))
            case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ProgressiveBits{}), accepted)))
            case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.ListOf{T.Unsigned{ac0}, a1} T.Container{b0, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Union{b0}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Null{}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Chain{b0, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.End{}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Repeat{b0}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.Named{b0, b1}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ListOf{T.Unsigned{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Boolean{}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Unsigned{b0}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.ByteVector{b0}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.ByteList{b0}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.BitVector{b0}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.BitList{b0}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Null{}, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.End{}, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Boolean{}), accepted)))
            case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Unsigned{bc0}), accepted)))
            case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ByteVector{bc0}), accepted)))
            case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ByteList{bc0}), accepted)))
            case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.BitVector{bc0}), accepted)))
            case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.BitList{bc0}), accepted)))
            case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Vector{bc0, bc1}), accepted)))
            case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ListOf{bc0, bc1}), accepted)))
            case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Container{bc0, bc1}), accepted)))
            case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Union{bc0}), accepted)))
            case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Null{}), accepted)))
            case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Chain{bc0, bc1}), accepted)))
            case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.End{}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.End{}), accepted)))
            case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Repeat{bc0}), accepted)))
            case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.Named{bc0, bc1}), accepted)))
            case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ProgressiveList{bc0}), accepted)))
            case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ProgressiveBits{}), accepted)))
            case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.ListOf{T.ByteVector{ac0}, a1} T.Container{b0, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Union{b0}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Null{}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Chain{b0, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.End{}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Repeat{b0}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.Named{b0, b1}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ListOf{T.ByteVector{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Boolean{}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Unsigned{b0}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.ByteVector{b0}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.ByteList{b0}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.BitVector{b0}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.BitList{b0}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Null{}, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.End{}, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Boolean{}), accepted)))
            case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Unsigned{bc0}), accepted)))
            case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ByteVector{bc0}), accepted)))
            case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ByteList{bc0}), accepted)))
            case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.BitVector{bc0}), accepted)))
            case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.BitList{bc0}), accepted)))
            case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Vector{bc0, bc1}), accepted)))
            case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ListOf{bc0, bc1}), accepted)))
            case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Container{bc0, bc1}), accepted)))
            case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Union{bc0}), accepted)))
            case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Null{}), accepted)))
            case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Chain{bc0, bc1}), accepted)))
            case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.End{}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.End{}), accepted)))
            case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Repeat{bc0}), accepted)))
            case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.Named{bc0, bc1}), accepted)))
            case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ProgressiveList{bc0}), accepted)))
            case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ProgressiveBits{}), accepted)))
            case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.ListOf{T.ByteList{ac0}, a1} T.Container{b0, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Union{b0}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Null{}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Chain{b0, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.End{}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Repeat{b0}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.Named{b0, b1}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ListOf{T.ByteList{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Boolean{}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Unsigned{b0}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.ByteVector{b0}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.ByteList{b0}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.BitVector{b0}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.BitList{b0}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Null{}, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.End{}, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Boolean{}), accepted)))
            case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Unsigned{bc0}), accepted)))
            case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ByteVector{bc0}), accepted)))
            case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ByteList{bc0}), accepted)))
            case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.BitVector{bc0}), accepted)))
            case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.BitList{bc0}), accepted)))
            case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Vector{bc0, bc1}), accepted)))
            case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ListOf{bc0, bc1}), accepted)))
            case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Container{bc0, bc1}), accepted)))
            case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Union{bc0}), accepted)))
            case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Null{}), accepted)))
            case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Chain{bc0, bc1}), accepted)))
            case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.End{}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.End{}), accepted)))
            case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Repeat{bc0}), accepted)))
            case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.Named{bc0, bc1}), accepted)))
            case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ProgressiveList{bc0}), accepted)))
            case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ProgressiveBits{}), accepted)))
            case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.ListOf{T.BitVector{ac0}, a1} T.Container{b0, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Union{b0}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Null{}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Chain{b0, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.End{}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Repeat{b0}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.Named{b0, b1}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ListOf{T.BitVector{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Boolean{}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Unsigned{b0}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.ByteVector{b0}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.ByteList{b0}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.BitVector{b0}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.BitList{b0}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Null{}, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.End{}, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Boolean{}), accepted)))
            case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Unsigned{bc0}), accepted)))
            case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ByteVector{bc0}), accepted)))
            case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ByteList{bc0}), accepted)))
            case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.BitVector{bc0}), accepted)))
            case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.BitList{bc0}), accepted)))
            case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Vector{bc0, bc1}), accepted)))
            case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ListOf{bc0, bc1}), accepted)))
            case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Container{bc0, bc1}), accepted)))
            case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Union{bc0}), accepted)))
            case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Null{}), accepted)))
            case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Chain{bc0, bc1}), accepted)))
            case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.End{}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.End{}), accepted)))
            case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Repeat{bc0}), accepted)))
            case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.Named{bc0, bc1}), accepted)))
            case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ProgressiveList{bc0}), accepted)))
            case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ProgressiveBits{}), accepted)))
            case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.ListOf{T.BitList{ac0}, a1} T.Container{b0, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Union{b0}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Null{}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Chain{b0, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.End{}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Repeat{b0}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.Named{b0, b1}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ListOf{T.BitList{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Boolean{}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Unsigned{b0}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ByteVector{b0}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ByteList{b0}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.BitVector{b0}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.BitList{b0}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.End{}, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Boolean{}), accepted)))
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Unsigned{bc0}), accepted)))
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ByteVector{bc0}), accepted)))
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ByteList{bc0}), accepted)))
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.BitVector{bc0}), accepted)))
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.BitList{bc0}), accepted)))
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Vector{bc0, bc1}), accepted)))
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}), accepted)))
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Container{bc0, bc1}), accepted)))
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Union{bc0}), accepted)))
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Null{}), accepted)))
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Chain{bc0, bc1}), accepted)))
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.End{}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.End{}), accepted)))
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Repeat{bc0}), accepted)))
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.Named{bc0, bc1}), accepted)))
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ProgressiveList{bc0}), accepted)))
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ProgressiveBits{}), accepted)))
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Container{b0, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Union{b0}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Null{}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Chain{b0, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.End{}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Repeat{b0}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.Named{b0, b1}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ProgressiveList{b0}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ProgressiveBits{}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ListOf{T.Vector{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Boolean{}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Unsigned{b0}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ByteVector{b0}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ByteList{b0}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.BitVector{b0}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.BitList{b0}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.End{}, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Boolean{}), accepted)))
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Unsigned{bc0}), accepted)))
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ByteVector{bc0}), accepted)))
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ByteList{bc0}), accepted)))
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.BitVector{bc0}), accepted)))
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.BitList{bc0}), accepted)))
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}), accepted)))
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}), accepted)))
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Container{bc0, bc1}), accepted)))
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Union{bc0}), accepted)))
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Null{}), accepted)))
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}), accepted)))
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.End{}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.End{}), accepted)))
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Repeat{bc0}), accepted)))
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.Named{bc0, bc1}), accepted)))
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}), accepted)))
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ProgressiveBits{}), accepted)))
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Container{b0, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Union{b0}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Null{}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Chain{b0, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.End{}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Repeat{b0}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.Named{b0, b1}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ProgressiveList{b0}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ProgressiveBits{}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ListOf{T.ListOf{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Boolean{}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Unsigned{b0}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ByteVector{b0}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ByteList{b0}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.BitVector{b0}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.BitList{b0}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.End{}, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Boolean{}), accepted)))
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Unsigned{bc0}), accepted)))
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ByteVector{bc0}), accepted)))
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ByteList{bc0}), accepted)))
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.BitVector{bc0}), accepted)))
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.BitList{bc0}), accepted)))
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Vector{bc0, bc1}), accepted)))
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ListOf{bc0, bc1}), accepted)))
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Container{bc0, bc1}), accepted)))
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Union{bc0}), accepted)))
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Null{}), accepted)))
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Chain{bc0, bc1}), accepted)))
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.End{}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.End{}), accepted)))
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Repeat{bc0}), accepted)))
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.Named{bc0, bc1}), accepted)))
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ProgressiveList{bc0}), accepted)))
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ProgressiveBits{}), accepted)))
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Container{b0, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Union{b0}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Null{}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Chain{b0, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.End{}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Repeat{b0}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.Named{b0, b1}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ProgressiveList{b0}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ProgressiveBits{}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ListOf{T.Container{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Boolean{}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Unsigned{b0}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.ByteVector{b0}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.ByteList{b0}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.BitVector{b0}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.BitList{b0}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Null{}, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Vector{T.End{}, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Boolean{}), accepted)))
            case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Unsigned{bc0}), accepted)))
            case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ByteVector{bc0}), accepted)))
            case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ByteList{bc0}), accepted)))
            case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.BitVector{bc0}), accepted)))
            case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.BitList{bc0}), accepted)))
            case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Vector{bc0, bc1}), accepted)))
            case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ListOf{bc0, bc1}), accepted)))
            case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Container{bc0, bc1}), accepted)))
            case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Union{bc0}), accepted)))
            case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Null{}), accepted)))
            case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Chain{bc0, bc1}), accepted)))
            case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.End{}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.End{}), accepted)))
            case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Repeat{bc0}), accepted)))
            case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.Named{bc0, bc1}), accepted)))
            case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ProgressiveList{bc0}), accepted)))
            case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ProgressiveBits{}), accepted)))
            case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Union{ac0}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Union{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Union{ac0}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.ListOf{T.Union{ac0}, a1} T.Container{b0, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Union{b0}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Null{}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Chain{b0, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.End{}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Repeat{b0}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.Named{b0, b1}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ListOf{T.Union{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.Boolean{}: accepted
            case T.ListOf{T.Null{}, a1} T.Unsigned{b0}: accepted
            case T.ListOf{T.Null{}, a1} T.ByteVector{b0}: accepted
            case T.ListOf{T.Null{}, a1} T.ByteList{b0}: accepted
            case T.ListOf{T.Null{}, a1} T.BitVector{b0}: accepted
            case T.ListOf{T.Null{}, a1} T.BitList{b0}: accepted
            case T.ListOf{T.Null{}, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.Vector{T.Null{}, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.Vector{T.End{}, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.ListOf{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Boolean{}), accepted)))
            case T.ListOf{T.Null{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Unsigned{bc0}), accepted)))
            case T.ListOf{T.Null{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ByteVector{bc0}), accepted)))
            case T.ListOf{T.Null{}, a1} T.ListOf{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ByteList{bc0}), accepted)))
            case T.ListOf{T.Null{}, a1} T.ListOf{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.BitVector{bc0}), accepted)))
            case T.ListOf{T.Null{}, a1} T.ListOf{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.BitList{bc0}), accepted)))
            case T.ListOf{T.Null{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Vector{bc0, bc1}), accepted)))
            case T.ListOf{T.Null{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ListOf{bc0, bc1}), accepted)))
            case T.ListOf{T.Null{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Container{bc0, bc1}), accepted)))
            case T.ListOf{T.Null{}, a1} T.ListOf{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Union{bc0}), accepted)))
            case T.ListOf{T.Null{}, a1} T.ListOf{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Null{}), accepted)))
            case T.ListOf{T.Null{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Chain{bc0, bc1}), accepted)))
            case T.ListOf{T.Null{}, a1} T.ListOf{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.End{}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.End{}), accepted)))
            case T.ListOf{T.Null{}, a1} T.ListOf{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Repeat{bc0}), accepted)))
            case T.ListOf{T.Null{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.Named{bc0, bc1}), accepted)))
            case T.ListOf{T.Null{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ProgressiveList{bc0}), accepted)))
            case T.ListOf{T.Null{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ProgressiveBits{}), accepted)))
            case T.ListOf{T.Null{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.ListOf{T.Null{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Null{}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Null{}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Null{}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.ListOf{T.Null{}, a1} T.Container{b0, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.Union{b0}: accepted
            case T.ListOf{T.Null{}, a1} T.Null{}: accepted
            case T.ListOf{T.Null{}, a1} T.Chain{b0, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.End{}: accepted
            case T.ListOf{T.Null{}, a1} T.Repeat{b0}: accepted
            case T.ListOf{T.Null{}, a1} T.Named{b0, b1}: accepted
            case T.ListOf{T.Null{}, a1} T.ProgressiveList{b0}: accepted
            case T.ListOf{T.Null{}, a1} T.ProgressiveBits{}: accepted
            case T.ListOf{T.Null{}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ListOf{T.Null{}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Boolean{}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Unsigned{b0}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ByteVector{b0}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ByteList{b0}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.BitVector{b0}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.BitList{b0}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.End{}, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Boolean{}), accepted)))
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Unsigned{bc0}), accepted)))
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ByteVector{bc0}), accepted)))
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ByteList{bc0}), accepted)))
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.BitVector{bc0}), accepted)))
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.BitList{bc0}), accepted)))
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Vector{bc0, bc1}), accepted)))
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}), accepted)))
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Container{bc0, bc1}), accepted)))
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Union{bc0}), accepted)))
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Null{}), accepted)))
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Chain{bc0, bc1}), accepted)))
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.End{}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.End{}), accepted)))
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Repeat{bc0}), accepted)))
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.Named{bc0, bc1}), accepted)))
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ProgressiveList{bc0}), accepted)))
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ProgressiveBits{}), accepted)))
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Container{b0, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Union{b0}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Null{}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Chain{b0, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.End{}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Repeat{b0}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.Named{b0, b1}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ProgressiveList{b0}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ProgressiveBits{}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ListOf{T.Chain{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ListOf{T.End{}, a1} T.Boolean{}: accepted
            case T.ListOf{T.End{}, a1} T.Unsigned{b0}: accepted
            case T.ListOf{T.End{}, a1} T.ByteVector{b0}: accepted
            case T.ListOf{T.End{}, a1} T.ByteList{b0}: accepted
            case T.ListOf{T.End{}, a1} T.BitVector{b0}: accepted
            case T.ListOf{T.End{}, a1} T.BitList{b0}: accepted
            case T.ListOf{T.End{}, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.ListOf{T.End{}, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ListOf{T.End{}, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ListOf{T.End{}, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ListOf{T.End{}, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ListOf{T.End{}, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ListOf{T.End{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ListOf{T.End{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ListOf{T.End{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ListOf{T.End{}, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ListOf{T.End{}, a1} T.Vector{T.Null{}, b1}: accepted
            case T.ListOf{T.End{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ListOf{T.End{}, a1} T.Vector{T.End{}, b1}: accepted
            case T.ListOf{T.End{}, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ListOf{T.End{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ListOf{T.End{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ListOf{T.End{}, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ListOf{T.End{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ListOf{T.End{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ListOf{T.End{}, a1} T.ListOf{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.End{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Boolean{}), accepted)))
            case T.ListOf{T.End{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.End{}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Unsigned{bc0}), accepted)))
            case T.ListOf{T.End{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.End{}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ByteVector{bc0}), accepted)))
            case T.ListOf{T.End{}, a1} T.ListOf{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.End{}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ByteList{bc0}), accepted)))
            case T.ListOf{T.End{}, a1} T.ListOf{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.End{}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.BitVector{bc0}), accepted)))
            case T.ListOf{T.End{}, a1} T.ListOf{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.End{}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.BitList{bc0}), accepted)))
            case T.ListOf{T.End{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.End{}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Vector{bc0, bc1}), accepted)))
            case T.ListOf{T.End{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.End{}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ListOf{bc0, bc1}), accepted)))
            case T.ListOf{T.End{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.End{}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Container{bc0, bc1}), accepted)))
            case T.ListOf{T.End{}, a1} T.ListOf{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.End{}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Union{bc0}), accepted)))
            case T.ListOf{T.End{}, a1} T.ListOf{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.End{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Null{}), accepted)))
            case T.ListOf{T.End{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.End{}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Chain{bc0, bc1}), accepted)))
            case T.ListOf{T.End{}, a1} T.ListOf{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.End{}), accepted), monotone(p, extra, Pair{}, T.End{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.End{}), accepted)))
            case T.ListOf{T.End{}, a1} T.ListOf{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.End{}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Repeat{bc0}), accepted)))
            case T.ListOf{T.End{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.End{}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.Named{bc0, bc1}), accepted)))
            case T.ListOf{T.End{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.End{}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ProgressiveList{bc0}), accepted)))
            case T.ListOf{T.End{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.End{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ProgressiveBits{}), accepted)))
            case T.ListOf{T.End{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.ListOf{T.End{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.End{}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.End{}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.End{}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.ListOf{T.End{}, a1} T.Container{b0, b1}: accepted
            case T.ListOf{T.End{}, a1} T.Union{b0}: accepted
            case T.ListOf{T.End{}, a1} T.Null{}: accepted
            case T.ListOf{T.End{}, a1} T.Chain{b0, b1}: accepted
            case T.ListOf{T.End{}, a1} T.End{}: accepted
            case T.ListOf{T.End{}, a1} T.Repeat{b0}: accepted
            case T.ListOf{T.End{}, a1} T.Named{b0, b1}: accepted
            case T.ListOf{T.End{}, a1} T.ProgressiveList{b0}: accepted
            case T.ListOf{T.End{}, a1} T.ProgressiveBits{}: accepted
            case T.ListOf{T.End{}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ListOf{T.End{}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Boolean{}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Unsigned{b0}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.ByteVector{b0}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.ByteList{b0}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.BitVector{b0}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.BitList{b0}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Null{}, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.End{}, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Boolean{}), accepted)))
            case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Unsigned{bc0}), accepted)))
            case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ByteVector{bc0}), accepted)))
            case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ByteList{bc0}), accepted)))
            case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.BitVector{bc0}), accepted)))
            case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.BitList{bc0}), accepted)))
            case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Vector{bc0, bc1}), accepted)))
            case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ListOf{bc0, bc1}), accepted)))
            case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Container{bc0, bc1}), accepted)))
            case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Union{bc0}), accepted)))
            case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Null{}), accepted)))
            case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Chain{bc0, bc1}), accepted)))
            case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.End{}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.End{}), accepted)))
            case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Repeat{bc0}), accepted)))
            case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.Named{bc0, bc1}), accepted)))
            case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ProgressiveList{bc0}), accepted)))
            case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ProgressiveBits{}), accepted)))
            case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.ListOf{T.Repeat{ac0}, a1} T.Container{b0, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Union{b0}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Null{}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Chain{b0, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.End{}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Repeat{b0}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.Named{b0, b1}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ListOf{T.Repeat{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Boolean{}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Unsigned{b0}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ByteVector{b0}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ByteList{b0}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.BitVector{b0}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.BitList{b0}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.End{}, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Boolean{}), accepted)))
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Unsigned{bc0}), accepted)))
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ByteVector{bc0}), accepted)))
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ByteList{bc0}), accepted)))
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.BitVector{bc0}), accepted)))
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.BitList{bc0}), accepted)))
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Vector{bc0, bc1}), accepted)))
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ListOf{bc0, bc1}), accepted)))
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Container{bc0, bc1}), accepted)))
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Union{bc0}), accepted)))
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Null{}), accepted)))
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Chain{bc0, bc1}), accepted)))
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.End{}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.End{}), accepted)))
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Repeat{bc0}), accepted)))
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.Named{bc0, bc1}), accepted)))
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ProgressiveList{bc0}), accepted)))
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ProgressiveBits{}), accepted)))
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Container{b0, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Union{b0}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Null{}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Chain{b0, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.End{}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Repeat{b0}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.Named{b0, b1}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ProgressiveList{b0}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ProgressiveBits{}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ListOf{T.Named{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Boolean{}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Unsigned{b0}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ByteVector{b0}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ByteList{b0}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.BitVector{b0}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.BitList{b0}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Null{}, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.End{}, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Boolean{}), accepted)))
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Unsigned{bc0}), accepted)))
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ByteVector{bc0}), accepted)))
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ByteList{bc0}), accepted)))
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.BitVector{bc0}), accepted)))
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.BitList{bc0}), accepted)))
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Vector{bc0, bc1}), accepted)))
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}), accepted)))
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Container{bc0, bc1}), accepted)))
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Union{bc0}), accepted)))
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Null{}), accepted)))
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Chain{bc0, bc1}), accepted)))
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.End{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.End{}), accepted)))
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Repeat{bc0}), accepted)))
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.Named{bc0, bc1}), accepted)))
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ProgressiveList{bc0}), accepted)))
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ProgressiveBits{}), accepted)))
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Container{b0, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Union{b0}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Null{}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Chain{b0, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.End{}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Repeat{b0}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.Named{b0, b1}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ProgressiveList{b0}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ProgressiveBits{}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ListOf{T.ProgressiveList{ac0}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Boolean{}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Unsigned{b0}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.ByteVector{b0}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.ByteList{b0}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.BitVector{b0}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.BitList{b0}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Null{}, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.End{}, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Boolean{}), accepted)))
            case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Unsigned{bc0}), accepted)))
            case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ByteVector{bc0}), accepted)))
            case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ByteList{bc0}), accepted)))
            case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.BitVector{bc0}), accepted)))
            case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.BitList{bc0}), accepted)))
            case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Vector{bc0, bc1}), accepted)))
            case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ListOf{bc0, bc1}), accepted)))
            case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Container{bc0, bc1}), accepted)))
            case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Union{bc0}), accepted)))
            case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Null{}), accepted)))
            case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Chain{bc0, bc1}), accepted)))
            case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.End{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.End{}), accepted)))
            case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Repeat{bc0}), accepted)))
            case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.Named{bc0, bc1}), accepted)))
            case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ProgressiveList{bc0}), accepted)))
            case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ProgressiveBits{}), accepted)))
            case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.ListOf{T.ProgressiveBits{}, a1} T.Container{b0, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Union{b0}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Null{}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Chain{b0, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.End{}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Repeat{b0}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.Named{b0, b1}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.ProgressiveList{b0}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.ProgressiveBits{}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ListOf{T.ProgressiveBits{}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Boolean{}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Unsigned{b0}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ByteVector{b0}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ByteList{b0}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.BitVector{b0}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.BitList{b0}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Null{}, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.End{}, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}), accepted)))
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}), accepted)))
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}), accepted)))
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}), accepted)))
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}), accepted)))
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}), accepted)))
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}), accepted)))
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}), accepted)))
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}), accepted)))
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}), accepted)))
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}), accepted)))
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}), accepted)))
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}), accepted)))
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}), accepted)))
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}), accepted)))
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}), accepted)))
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}), accepted)))
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Container{b0, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Union{b0}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Null{}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Chain{b0, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.End{}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Repeat{b0}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Named{b0, b1}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ProgressiveList{b0}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ProgressiveBits{}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Boolean{}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Unsigned{b0}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ByteVector{b0}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ByteList{b0}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.BitVector{b0}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.BitList{b0}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.End{}, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Boolean{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Boolean{}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Boolean{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Boolean{}), accepted)))
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}), accepted)))
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}), accepted)))
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}), accepted)))
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}), accepted)))
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}), accepted)))
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}), accepted)))
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}), accepted)))
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}), accepted)))
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Union{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Union{bc0}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Union{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Union{bc0}), accepted)))
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Null{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Null{}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Null{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Null{}), accepted)))
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}), accepted)))
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.End{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.End{}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.End{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.End{}), accepted)))
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}), accepted)))
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}), accepted)))
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}), accepted)))
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}), accepted)))
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), accepted)))
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: V.and_true(Nat.is_eq(a1, b1), I.compatible_go(Nat.add(p, extra), 0, T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), V.and_left(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted), monotone(p, extra, Pair{}, T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, V.and_right(Nat.is_eq(a1, b1), I.compatible_go(p, 0, T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), accepted)))
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Container{b0, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Union{b0}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Null{}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Chain{b0, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.End{}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Repeat{b0}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.Named{b0, b1}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ProgressiveList{b0}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ProgressiveBits{}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Container{a0, a1} T.Boolean{}: accepted
            case T.Container{a0, a1} T.Unsigned{b0}: accepted
            case T.Container{a0, a1} T.ByteVector{b0}: accepted
            case T.Container{a0, a1} T.ByteList{b0}: accepted
            case T.Container{a0, a1} T.BitVector{b0}: accepted
            case T.Container{a0, a1} T.BitList{b0}: accepted
            case T.Container{a0, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.Container{a0, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.Container{a0, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.Container{a0, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.Container{a0, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.Container{a0, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.Container{a0, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.Container{a0, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Container{a0, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.Container{a0, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.Container{a0, a1} T.Vector{T.Null{}, b1}: accepted
            case T.Container{a0, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.Container{a0, a1} T.Vector{T.End{}, b1}: accepted
            case T.Container{a0, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.Container{a0, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.Container{a0, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.Container{a0, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.Container{a0, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Container{a0, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Container{a0, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Container{a0, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Container{a0, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Container{a0, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Container{a0, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Container{a0, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Container{a0, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Container{a0, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Container{a0, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Container{a0, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Container{a0, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Container{a0, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Container{a0, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Container{a0, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Container{a0, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Container{a0, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Container{a0, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Container{a0, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Container{a0, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Container{a0, a1} T.Container{b0, b1}: V.and_true(I.names_equal(a0, b0), I.compatible_go(Nat.add(p, extra), 0, a1, b1), V.and_left(I.names_equal(a0, b0), I.compatible_go(p, 0, a1, b1), accepted), monotone(p, extra, Pair{}, a1, b1, V.and_right(I.names_equal(a0, b0), I.compatible_go(p, 0, a1, b1), accepted)))
            case T.Container{a0, a1} T.Union{b0}: accepted
            case T.Container{a0, a1} T.Null{}: accepted
            case T.Container{a0, a1} T.Chain{b0, b1}: accepted
            case T.Container{a0, a1} T.End{}: accepted
            case T.Container{a0, a1} T.Repeat{b0}: accepted
            case T.Container{a0, a1} T.Named{b0, b1}: accepted
            case T.Container{a0, a1} T.ProgressiveList{b0}: accepted
            case T.Container{a0, a1} T.ProgressiveBits{}: accepted
            case T.Container{a0, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Container{a0, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.Union{a0} T.Boolean{}: accepted
            case T.Union{a0} T.Unsigned{b0}: accepted
            case T.Union{a0} T.ByteVector{b0}: accepted
            case T.Union{a0} T.ByteList{b0}: accepted
            case T.Union{a0} T.BitVector{b0}: accepted
            case T.Union{a0} T.BitList{b0}: accepted
            case T.Union{a0} T.Vector{T.Boolean{}, b1}: accepted
            case T.Union{a0} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.Union{a0} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.Union{a0} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.Union{a0} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.Union{a0} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.Union{a0} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.Union{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Union{a0} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.Union{a0} T.Vector{T.Union{bc0}, b1}: accepted
            case T.Union{a0} T.Vector{T.Null{}, b1}: accepted
            case T.Union{a0} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.Union{a0} T.Vector{T.End{}, b1}: accepted
            case T.Union{a0} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.Union{a0} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.Union{a0} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.Union{a0} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.Union{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Union{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Union{a0} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Union{a0} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Union{a0} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Union{a0} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Union{a0} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Union{a0} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Union{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Union{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Union{a0} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Union{a0} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Union{a0} T.ListOf{T.Null{}, b1}: accepted
            case T.Union{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Union{a0} T.ListOf{T.End{}, b1}: accepted
            case T.Union{a0} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Union{a0} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Union{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Union{a0} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Union{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Union{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Union{a0} T.Container{b0, b1}: accepted
            case T.Union{a0} T.Union{b0}: accepted
            case T.Union{a0} T.Null{}: accepted
            case T.Union{a0} T.Chain{b0, b1}: accepted
            case T.Union{a0} T.End{}: accepted
            case T.Union{a0} T.Repeat{b0}: accepted
            case T.Union{a0} T.Named{b0, b1}: accepted
            case T.Union{a0} T.ProgressiveList{b0}: accepted
            case T.Union{a0} T.ProgressiveBits{}: accepted
            case T.Union{a0} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Union{a0} T.CompatibleUnion{b0, b1}: accepted
            case T.Null{} T.Boolean{}: accepted
            case T.Null{} T.Unsigned{b0}: accepted
            case T.Null{} T.ByteVector{b0}: accepted
            case T.Null{} T.ByteList{b0}: accepted
            case T.Null{} T.BitVector{b0}: accepted
            case T.Null{} T.BitList{b0}: accepted
            case T.Null{} T.Vector{T.Boolean{}, b1}: accepted
            case T.Null{} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.Null{} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.Null{} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.Null{} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.Null{} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.Null{} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.Null{} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Null{} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.Null{} T.Vector{T.Union{bc0}, b1}: accepted
            case T.Null{} T.Vector{T.Null{}, b1}: accepted
            case T.Null{} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.Null{} T.Vector{T.End{}, b1}: accepted
            case T.Null{} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.Null{} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.Null{} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.Null{} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.Null{} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Null{} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Null{} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Null{} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Null{} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Null{} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Null{} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Null{} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Null{} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Null{} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Null{} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Null{} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Null{} T.ListOf{T.Null{}, b1}: accepted
            case T.Null{} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Null{} T.ListOf{T.End{}, b1}: accepted
            case T.Null{} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Null{} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Null{} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Null{} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Null{} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Null{} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Null{} T.Container{b0, b1}: accepted
            case T.Null{} T.Union{b0}: accepted
            case T.Null{} T.Null{}: accepted
            case T.Null{} T.Chain{b0, b1}: accepted
            case T.Null{} T.End{}: accepted
            case T.Null{} T.Repeat{b0}: accepted
            case T.Null{} T.Named{b0, b1}: accepted
            case T.Null{} T.ProgressiveList{b0}: accepted
            case T.Null{} T.ProgressiveBits{}: accepted
            case T.Null{} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Null{} T.CompatibleUnion{b0, b1}: accepted
            case T.Chain{a0, a1} T.Boolean{}: accepted
            case T.Chain{a0, a1} T.Unsigned{b0}: accepted
            case T.Chain{a0, a1} T.ByteVector{b0}: accepted
            case T.Chain{a0, a1} T.ByteList{b0}: accepted
            case T.Chain{a0, a1} T.BitVector{b0}: accepted
            case T.Chain{a0, a1} T.BitList{b0}: accepted
            case T.Chain{a0, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.Chain{a0, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.Chain{a0, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.Chain{a0, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.Chain{a0, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.Chain{a0, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.Chain{a0, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.Chain{a0, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Chain{a0, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.Chain{a0, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.Chain{a0, a1} T.Vector{T.Null{}, b1}: accepted
            case T.Chain{a0, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.Chain{a0, a1} T.Vector{T.End{}, b1}: accepted
            case T.Chain{a0, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.Chain{a0, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.Chain{a0, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.Chain{a0, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.Chain{a0, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Chain{a0, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Chain{a0, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Chain{a0, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Chain{a0, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Chain{a0, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Chain{a0, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Chain{a0, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Chain{a0, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Chain{a0, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Chain{a0, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Chain{a0, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Chain{a0, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Chain{a0, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Chain{a0, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Chain{a0, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Chain{a0, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Chain{a0, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Chain{a0, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Chain{a0, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Chain{a0, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Chain{a0, a1} T.Container{b0, b1}: accepted
            case T.Chain{a0, a1} T.Union{b0}: accepted
            case T.Chain{a0, a1} T.Null{}: accepted
            case T.Chain{a0, a1} T.Chain{b0, b1}: V.and_true(I.compatible_go(Nat.add(p, extra), 0, a0, b0), I.compatible_go(Nat.add(p, extra), 0, a1, b1), monotone(p, extra, Pair{}, a0, b0, V.and_left(I.compatible_go(p, 0, a0, b0), I.compatible_go(p, 0, a1, b1), accepted)), monotone(p, extra, Pair{}, a1, b1, V.and_right(I.compatible_go(p, 0, a0, b0), I.compatible_go(p, 0, a1, b1), accepted)))
            case T.Chain{a0, a1} T.End{}: accepted
            case T.Chain{a0, a1} T.Repeat{b0}: accepted
            case T.Chain{a0, a1} T.Named{b0, b1}: accepted
            case T.Chain{a0, a1} T.ProgressiveList{b0}: accepted
            case T.Chain{a0, a1} T.ProgressiveBits{}: accepted
            case T.Chain{a0, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Chain{a0, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.End{} T.Boolean{}: accepted
            case T.End{} T.Unsigned{b0}: accepted
            case T.End{} T.ByteVector{b0}: accepted
            case T.End{} T.ByteList{b0}: accepted
            case T.End{} T.BitVector{b0}: accepted
            case T.End{} T.BitList{b0}: accepted
            case T.End{} T.Vector{T.Boolean{}, b1}: accepted
            case T.End{} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.End{} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.End{} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.End{} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.End{} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.End{} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.End{} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.End{} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.End{} T.Vector{T.Union{bc0}, b1}: accepted
            case T.End{} T.Vector{T.Null{}, b1}: accepted
            case T.End{} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.End{} T.Vector{T.End{}, b1}: accepted
            case T.End{} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.End{} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.End{} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.End{} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.End{} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.End{} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.End{} T.ListOf{T.Boolean{}, b1}: accepted
            case T.End{} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.End{} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.End{} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.End{} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.End{} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.End{} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.End{} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.End{} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.End{} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.End{} T.ListOf{T.Null{}, b1}: accepted
            case T.End{} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.End{} T.ListOf{T.End{}, b1}: accepted
            case T.End{} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.End{} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.End{} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.End{} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.End{} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.End{} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.End{} T.Container{b0, b1}: accepted
            case T.End{} T.Union{b0}: accepted
            case T.End{} T.Null{}: accepted
            case T.End{} T.Chain{b0, b1}: accepted
            case T.End{} T.End{}: accepted
            case T.End{} T.Repeat{b0}: accepted
            case T.End{} T.Named{b0, b1}: accepted
            case T.End{} T.ProgressiveList{b0}: accepted
            case T.End{} T.ProgressiveBits{}: accepted
            case T.End{} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.End{} T.CompatibleUnion{b0, b1}: accepted
            case T.Repeat{a0} T.Boolean{}: accepted
            case T.Repeat{a0} T.Unsigned{b0}: accepted
            case T.Repeat{a0} T.ByteVector{b0}: accepted
            case T.Repeat{a0} T.ByteList{b0}: accepted
            case T.Repeat{a0} T.BitVector{b0}: accepted
            case T.Repeat{a0} T.BitList{b0}: accepted
            case T.Repeat{a0} T.Vector{T.Boolean{}, b1}: accepted
            case T.Repeat{a0} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.Repeat{a0} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.Repeat{a0} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.Repeat{a0} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.Repeat{a0} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.Repeat{a0} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.Repeat{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Repeat{a0} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.Repeat{a0} T.Vector{T.Union{bc0}, b1}: accepted
            case T.Repeat{a0} T.Vector{T.Null{}, b1}: accepted
            case T.Repeat{a0} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.Repeat{a0} T.Vector{T.End{}, b1}: accepted
            case T.Repeat{a0} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.Repeat{a0} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.Repeat{a0} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.Repeat{a0} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.Repeat{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Repeat{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Repeat{a0} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Repeat{a0} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Repeat{a0} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Repeat{a0} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Repeat{a0} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Repeat{a0} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Repeat{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Repeat{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Repeat{a0} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Repeat{a0} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Repeat{a0} T.ListOf{T.Null{}, b1}: accepted
            case T.Repeat{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Repeat{a0} T.ListOf{T.End{}, b1}: accepted
            case T.Repeat{a0} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Repeat{a0} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Repeat{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Repeat{a0} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Repeat{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Repeat{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Repeat{a0} T.Container{b0, b1}: accepted
            case T.Repeat{a0} T.Union{b0}: accepted
            case T.Repeat{a0} T.Null{}: accepted
            case T.Repeat{a0} T.Chain{b0, b1}: accepted
            case T.Repeat{a0} T.End{}: accepted
            case T.Repeat{a0} T.Repeat{b0}: accepted
            case T.Repeat{a0} T.Named{b0, b1}: accepted
            case T.Repeat{a0} T.ProgressiveList{b0}: accepted
            case T.Repeat{a0} T.ProgressiveBits{}: accepted
            case T.Repeat{a0} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Repeat{a0} T.CompatibleUnion{b0, b1}: accepted
            case T.Named{a0, a1} T.Boolean{}: accepted
            case T.Named{a0, a1} T.Unsigned{b0}: accepted
            case T.Named{a0, a1} T.ByteVector{b0}: accepted
            case T.Named{a0, a1} T.ByteList{b0}: accepted
            case T.Named{a0, a1} T.BitVector{b0}: accepted
            case T.Named{a0, a1} T.BitList{b0}: accepted
            case T.Named{a0, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.Named{a0, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.Named{a0, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.Named{a0, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.Named{a0, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.Named{a0, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.Named{a0, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.Named{a0, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Named{a0, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.Named{a0, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.Named{a0, a1} T.Vector{T.Null{}, b1}: accepted
            case T.Named{a0, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.Named{a0, a1} T.Vector{T.End{}, b1}: accepted
            case T.Named{a0, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.Named{a0, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.Named{a0, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.Named{a0, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.Named{a0, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Named{a0, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Named{a0, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.Named{a0, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.Named{a0, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.Named{a0, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.Named{a0, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.Named{a0, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.Named{a0, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.Named{a0, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.Named{a0, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.Named{a0, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.Named{a0, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.Named{a0, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.Named{a0, a1} T.ListOf{T.End{}, b1}: accepted
            case T.Named{a0, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.Named{a0, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.Named{a0, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.Named{a0, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.Named{a0, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.Named{a0, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.Named{a0, a1} T.Container{b0, b1}: accepted
            case T.Named{a0, a1} T.Union{b0}: accepted
            case T.Named{a0, a1} T.Null{}: accepted
            case T.Named{a0, a1} T.Chain{b0, b1}: accepted
            case T.Named{a0, a1} T.End{}: accepted
            case T.Named{a0, a1} T.Repeat{b0}: accepted
            case T.Named{a0, a1} T.Named{b0, b1}: V.and_true(String.eq(a0, b0), I.compatible_go(Nat.add(p, extra), 0, a1, b1), V.and_left(String.eq(a0, b0), I.compatible_go(p, 0, a1, b1), accepted), monotone(p, extra, Pair{}, a1, b1, V.and_right(String.eq(a0, b0), I.compatible_go(p, 0, a1, b1), accepted)))
            case T.Named{a0, a1} T.ProgressiveList{b0}: accepted
            case T.Named{a0, a1} T.ProgressiveBits{}: accepted
            case T.Named{a0, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.Named{a0, a1} T.CompatibleUnion{b0, b1}: accepted
            case T.ProgressiveList{a0} T.Boolean{}: accepted
            case T.ProgressiveList{a0} T.Unsigned{b0}: accepted
            case T.ProgressiveList{a0} T.ByteVector{b0}: accepted
            case T.ProgressiveList{a0} T.ByteList{b0}: accepted
            case T.ProgressiveList{a0} T.BitVector{b0}: accepted
            case T.ProgressiveList{a0} T.BitList{b0}: accepted
            case T.ProgressiveList{a0} T.Vector{T.Boolean{}, b1}: accepted
            case T.ProgressiveList{a0} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ProgressiveList{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ProgressiveList{a0} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ProgressiveList{a0} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.Vector{T.Null{}, b1}: accepted
            case T.ProgressiveList{a0} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ProgressiveList{a0} T.Vector{T.End{}, b1}: accepted
            case T.ProgressiveList{a0} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ProgressiveList{a0} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ProgressiveList{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ProgressiveList{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ProgressiveList{a0} T.ListOf{T.Boolean{}, b1}: accepted
            case T.ProgressiveList{a0} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.ProgressiveList{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ProgressiveList{a0} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.ProgressiveList{a0} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.ListOf{T.Null{}, b1}: accepted
            case T.ProgressiveList{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.ProgressiveList{a0} T.ListOf{T.End{}, b1}: accepted
            case T.ProgressiveList{a0} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.ProgressiveList{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.ProgressiveList{a0} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.ProgressiveList{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ProgressiveList{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ProgressiveList{a0} T.Container{b0, b1}: accepted
            case T.ProgressiveList{a0} T.Union{b0}: accepted
            case T.ProgressiveList{a0} T.Null{}: accepted
            case T.ProgressiveList{a0} T.Chain{b0, b1}: accepted
            case T.ProgressiveList{a0} T.End{}: accepted
            case T.ProgressiveList{a0} T.Repeat{b0}: accepted
            case T.ProgressiveList{a0} T.Named{b0, b1}: accepted
            case T.ProgressiveList{a0} T.ProgressiveList{b0}: monotone(p, extra, Pair{}, a0, b0, accepted)
            case T.ProgressiveList{a0} T.ProgressiveBits{}: accepted
            case T.ProgressiveList{a0} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ProgressiveList{a0} T.CompatibleUnion{b0, b1}: accepted
            case T.ProgressiveBits{} T.Boolean{}: accepted
            case T.ProgressiveBits{} T.Unsigned{b0}: accepted
            case T.ProgressiveBits{} T.ByteVector{b0}: accepted
            case T.ProgressiveBits{} T.ByteList{b0}: accepted
            case T.ProgressiveBits{} T.BitVector{b0}: accepted
            case T.ProgressiveBits{} T.BitList{b0}: accepted
            case T.ProgressiveBits{} T.Vector{T.Boolean{}, b1}: accepted
            case T.ProgressiveBits{} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ProgressiveBits{} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ProgressiveBits{} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ProgressiveBits{} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.Vector{T.Null{}, b1}: accepted
            case T.ProgressiveBits{} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ProgressiveBits{} T.Vector{T.End{}, b1}: accepted
            case T.ProgressiveBits{} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ProgressiveBits{} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ProgressiveBits{} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ProgressiveBits{} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ProgressiveBits{} T.ListOf{T.Boolean{}, b1}: accepted
            case T.ProgressiveBits{} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.ProgressiveBits{} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ProgressiveBits{} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.ProgressiveBits{} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.ListOf{T.Null{}, b1}: accepted
            case T.ProgressiveBits{} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.ProgressiveBits{} T.ListOf{T.End{}, b1}: accepted
            case T.ProgressiveBits{} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.ProgressiveBits{} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.ProgressiveBits{} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.ProgressiveBits{} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ProgressiveBits{} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ProgressiveBits{} T.Container{b0, b1}: accepted
            case T.ProgressiveBits{} T.Union{b0}: accepted
            case T.ProgressiveBits{} T.Null{}: accepted
            case T.ProgressiveBits{} T.Chain{b0, b1}: accepted
            case T.ProgressiveBits{} T.End{}: accepted
            case T.ProgressiveBits{} T.Repeat{b0}: accepted
            case T.ProgressiveBits{} T.Named{b0, b1}: accepted
            case T.ProgressiveBits{} T.ProgressiveList{b0}: accepted
            case T.ProgressiveBits{} T.ProgressiveBits{}: accepted
            case T.ProgressiveBits{} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.ProgressiveBits{} T.CompatibleUnion{b0, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Boolean{}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Unsigned{b0}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ByteVector{b0}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ByteList{b0}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.BitVector{b0}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.BitList{b0}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Boolean{}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Union{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Null{}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.End{}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Boolean{}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Null{}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.End{}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Container{b0, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Union{b0}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Null{}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Chain{b0, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.End{}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Repeat{b0}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.Named{b0, b1}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveList{b0}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveBits{}: accepted
            case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveContainer{b0, b1, b2}: Choice.monotone(I.identical(T.ProgressiveContainer{a0, a1, a2}, T.ProgressiveContainer{b0, b1, b2}), Bool.and(I.shared_positions(I.active_fields(a2, a0, a1), I.active_fields(b2, b0, b1), 0n), I.compatible_go(p, 3, I.active_fields(a2, a0, a1), I.active_fields(b2, b0, b1))), Bool.and(I.shared_positions(I.active_fields(a2, a0, a1), I.active_fields(b2, b0, b1), 0n), I.compatible_go(Nat.add(p, extra), 3, I.active_fields(a2, a0, a1), I.active_fields(b2, b0, b1))), accepted_tail => V.and_true(I.shared_positions(I.active_fields(a2, a0, a1), I.active_fields(b2, b0, b1), 0n), I.compatible_go(Nat.add(p, extra), 3, I.active_fields(a2, a0, a1), I.active_fields(b2, b0, b1)), V.and_left(I.shared_positions(I.active_fields(a2, a0, a1), I.active_fields(b2, b0, b1), 0n), I.compatible_go(p, 3, I.active_fields(a2, a0, a1), I.active_fields(b2, b0, b1)), accepted_tail), monotone(p, extra, Slots{}, I.active_fields(a2, a0, a1), I.active_fields(b2, b0, b1), V.and_right(I.shared_positions(I.active_fields(a2, a0, a1), I.active_fields(b2, b0, b1), 0n), I.compatible_go(p, 3, I.active_fields(a2, a0, a1), I.active_fields(b2, b0, b1)), accepted_tail))), accepted)
            case T.ProgressiveContainer{a0, a1, a2} T.CompatibleUnion{b0, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Boolean{}: accepted
            case T.CompatibleUnion{a0, a1} T.Unsigned{b0}: accepted
            case T.CompatibleUnion{a0, a1} T.ByteVector{b0}: accepted
            case T.CompatibleUnion{a0, a1} T.ByteList{b0}: accepted
            case T.CompatibleUnion{a0, a1} T.BitVector{b0}: accepted
            case T.CompatibleUnion{a0, a1} T.BitList{b0}: accepted
            case T.CompatibleUnion{a0, a1} T.Vector{T.Boolean{}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Vector{T.Unsigned{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Vector{T.ByteVector{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Vector{T.ByteList{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Vector{T.BitVector{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Vector{T.BitList{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Vector{T.Vector{bc0, bc1}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Vector{T.Container{bc0, bc1}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Vector{T.Union{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Vector{T.Null{}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Vector{T.Chain{bc0, bc1}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Vector{T.End{}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Vector{T.Repeat{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Vector{T.Named{bc0, bc1}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Vector{T.ProgressiveList{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Vector{T.ProgressiveBits{}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ListOf{T.Boolean{}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ListOf{T.Unsigned{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ListOf{T.ByteVector{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ListOf{T.ByteList{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ListOf{T.BitVector{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ListOf{T.BitList{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ListOf{T.Container{bc0, bc1}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ListOf{T.Union{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ListOf{T.Null{}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ListOf{T.End{}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ListOf{T.Repeat{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ListOf{T.Named{bc0, bc1}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ListOf{T.ProgressiveBits{}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Container{b0, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.Union{b0}: accepted
            case T.CompatibleUnion{a0, a1} T.Null{}: accepted
            case T.CompatibleUnion{a0, a1} T.Chain{b0, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.End{}: accepted
            case T.CompatibleUnion{a0, a1} T.Repeat{b0}: accepted
            case T.CompatibleUnion{a0, a1} T.Named{b0, b1}: accepted
            case T.CompatibleUnion{a0, a1} T.ProgressiveList{b0}: accepted
            case T.CompatibleUnion{a0, a1} T.ProgressiveBits{}: accepted
            case T.CompatibleUnion{a0, a1} T.ProgressiveContainer{b0, b1, b2}: accepted
            case T.CompatibleUnion{a0, a1} T.CompatibleUnion{b0, b1}: Choice.monotone(I.identical(T.CompatibleUnion{a0, a1}, T.CompatibleUnion{b0, b1}), I.compatible_go(p, 1, a1, b1), I.compatible_go(Nat.add(p, extra), 1, a1, b1), accepted_tail => monotone(p, extra, All{}, a1, b1, accepted_tail), accepted)
