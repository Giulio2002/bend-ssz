import Base
import ../types/schema.bend as T
import ../src/schema.bend as I

law Vector:
  for +fuel: Nat
  for +a: T.Schema
  for +b: T.Schema
  for +n: Nat
  for +m: Nat
  {I.compatible_go(1n+fuel, 0, T.Vector{a, n}, T.Vector{b, m}) == Bool.and(Nat.is_eq(n, m), I.compatible_go(fuel, 0, a, b)) : Bool}
def Vector(fuel, a, b, n, m):
  match a b:
    case T.Boolean{} T.Boolean{}: {==}
    case T.Boolean{} T.Unsigned{b0}: {==}
    case T.Boolean{} T.ByteVector{b0}: {==}
    case T.Boolean{} T.ByteList{b0}: {==}
    case T.Boolean{} T.BitVector{b0}: {==}
    case T.Boolean{} T.BitList{b0}: {==}
    case T.Boolean{} T.Vector{b0, b1}: {==}
    case T.Boolean{} T.ListOf{b0, b1}: {==}
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
    case T.Unsigned{a0} T.Vector{b0, b1}: {==}
    case T.Unsigned{a0} T.ListOf{b0, b1}: {==}
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
    case T.ByteVector{a0} T.ByteVector{b0}: {==}
    case T.ByteVector{a0} T.ByteList{b0}: {==}
    case T.ByteVector{a0} T.BitVector{b0}: {==}
    case T.ByteVector{a0} T.BitList{b0}: {==}
    case T.ByteVector{a0} T.Vector{b0, b1}: {==}
    case T.ByteVector{a0} T.ListOf{b0, b1}: {==}
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
    case T.ByteList{a0} T.ByteList{b0}: {==}
    case T.ByteList{a0} T.BitVector{b0}: {==}
    case T.ByteList{a0} T.BitList{b0}: {==}
    case T.ByteList{a0} T.Vector{b0, b1}: {==}
    case T.ByteList{a0} T.ListOf{b0, b1}: {==}
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
    case T.BitVector{a0} T.Vector{b0, b1}: {==}
    case T.BitVector{a0} T.ListOf{b0, b1}: {==}
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
    case T.BitList{a0} T.Vector{b0, b1}: {==}
    case T.BitList{a0} T.ListOf{b0, b1}: {==}
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
    case T.Vector{a0, a1} T.Boolean{}: {==}
    case T.Vector{a0, a1} T.Unsigned{b0}: {==}
    case T.Vector{a0, a1} T.ByteVector{b0}: {==}
    case T.Vector{a0, a1} T.ByteList{b0}: {==}
    case T.Vector{a0, a1} T.BitVector{b0}: {==}
    case T.Vector{a0, a1} T.BitList{b0}: {==}
    case T.Vector{a0, a1} T.Vector{b0, b1}: {==}
    case T.Vector{a0, a1} T.ListOf{b0, b1}: {==}
    case T.Vector{a0, a1} T.Container{b0, b1}: {==}
    case T.Vector{a0, a1} T.Union{b0}: {==}
    case T.Vector{a0, a1} T.Null{}: {==}
    case T.Vector{a0, a1} T.Chain{b0, b1}: {==}
    case T.Vector{a0, a1} T.End{}: {==}
    case T.Vector{a0, a1} T.Repeat{b0}: {==}
    case T.Vector{a0, a1} T.Named{b0, b1}: {==}
    case T.Vector{a0, a1} T.ProgressiveList{b0}: {==}
    case T.Vector{a0, a1} T.ProgressiveBits{}: {==}
    case T.Vector{a0, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Vector{a0, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ListOf{a0, a1} T.Boolean{}: {==}
    case T.ListOf{a0, a1} T.Unsigned{b0}: {==}
    case T.ListOf{a0, a1} T.ByteVector{b0}: {==}
    case T.ListOf{a0, a1} T.ByteList{b0}: {==}
    case T.ListOf{a0, a1} T.BitVector{b0}: {==}
    case T.ListOf{a0, a1} T.BitList{b0}: {==}
    case T.ListOf{a0, a1} T.Vector{b0, b1}: {==}
    case T.ListOf{a0, a1} T.ListOf{b0, b1}: {==}
    case T.ListOf{a0, a1} T.Container{b0, b1}: {==}
    case T.ListOf{a0, a1} T.Union{b0}: {==}
    case T.ListOf{a0, a1} T.Null{}: {==}
    case T.ListOf{a0, a1} T.Chain{b0, b1}: {==}
    case T.ListOf{a0, a1} T.End{}: {==}
    case T.ListOf{a0, a1} T.Repeat{b0}: {==}
    case T.ListOf{a0, a1} T.Named{b0, b1}: {==}
    case T.ListOf{a0, a1} T.ProgressiveList{b0}: {==}
    case T.ListOf{a0, a1} T.ProgressiveBits{}: {==}
    case T.ListOf{a0, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ListOf{a0, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Container{a0, a1} T.Boolean{}: {==}
    case T.Container{a0, a1} T.Unsigned{b0}: {==}
    case T.Container{a0, a1} T.ByteVector{b0}: {==}
    case T.Container{a0, a1} T.ByteList{b0}: {==}
    case T.Container{a0, a1} T.BitVector{b0}: {==}
    case T.Container{a0, a1} T.BitList{b0}: {==}
    case T.Container{a0, a1} T.Vector{b0, b1}: {==}
    case T.Container{a0, a1} T.ListOf{b0, b1}: {==}
    case T.Container{a0, a1} T.Container{b0, b1}: {==}
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
    case T.Union{a0} T.Vector{b0, b1}: {==}
    case T.Union{a0} T.ListOf{b0, b1}: {==}
    case T.Union{a0} T.Container{b0, b1}: {==}
    case T.Union{a0} T.Union{b0}: {==}
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
    case T.Null{} T.Vector{b0, b1}: {==}
    case T.Null{} T.ListOf{b0, b1}: {==}
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
    case T.Chain{a0, a1} T.Vector{b0, b1}: {==}
    case T.Chain{a0, a1} T.ListOf{b0, b1}: {==}
    case T.Chain{a0, a1} T.Container{b0, b1}: {==}
    case T.Chain{a0, a1} T.Union{b0}: {==}
    case T.Chain{a0, a1} T.Null{}: {==}
    case T.Chain{a0, a1} T.Chain{b0, b1}: {==}
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
    case T.End{} T.Vector{b0, b1}: {==}
    case T.End{} T.ListOf{b0, b1}: {==}
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
    case T.Repeat{a0} T.Vector{b0, b1}: {==}
    case T.Repeat{a0} T.ListOf{b0, b1}: {==}
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
    case T.Named{a0, a1} T.Vector{b0, b1}: {==}
    case T.Named{a0, a1} T.ListOf{b0, b1}: {==}
    case T.Named{a0, a1} T.Container{b0, b1}: {==}
    case T.Named{a0, a1} T.Union{b0}: {==}
    case T.Named{a0, a1} T.Null{}: {==}
    case T.Named{a0, a1} T.Chain{b0, b1}: {==}
    case T.Named{a0, a1} T.End{}: {==}
    case T.Named{a0, a1} T.Repeat{b0}: {==}
    case T.Named{a0, a1} T.Named{b0, b1}: {==}
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
    case T.ProgressiveList{a0} T.Vector{b0, b1}: {==}
    case T.ProgressiveList{a0} T.ListOf{b0, b1}: {==}
    case T.ProgressiveList{a0} T.Container{b0, b1}: {==}
    case T.ProgressiveList{a0} T.Union{b0}: {==}
    case T.ProgressiveList{a0} T.Null{}: {==}
    case T.ProgressiveList{a0} T.Chain{b0, b1}: {==}
    case T.ProgressiveList{a0} T.End{}: {==}
    case T.ProgressiveList{a0} T.Repeat{b0}: {==}
    case T.ProgressiveList{a0} T.Named{b0, b1}: {==}
    case T.ProgressiveList{a0} T.ProgressiveList{b0}: {==}
    case T.ProgressiveList{a0} T.ProgressiveBits{}: {==}
    case T.ProgressiveList{a0} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ProgressiveList{a0} T.CompatibleUnion{b0, b1}: {==}
    case T.ProgressiveBits{} T.Boolean{}: {==}
    case T.ProgressiveBits{} T.Unsigned{b0}: {==}
    case T.ProgressiveBits{} T.ByteVector{b0}: {==}
    case T.ProgressiveBits{} T.ByteList{b0}: {==}
    case T.ProgressiveBits{} T.BitVector{b0}: {==}
    case T.ProgressiveBits{} T.BitList{b0}: {==}
    case T.ProgressiveBits{} T.Vector{b0, b1}: {==}
    case T.ProgressiveBits{} T.ListOf{b0, b1}: {==}
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
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{b0, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{b0, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Container{b0, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Union{b0}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Null{}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Chain{b0, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.End{}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Repeat{b0}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Named{b0, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveList{b0}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveBits{}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.CompatibleUnion{b0, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Boolean{}: {==}
    case T.CompatibleUnion{a0, a1} T.Unsigned{b0}: {==}
    case T.CompatibleUnion{a0, a1} T.ByteVector{b0}: {==}
    case T.CompatibleUnion{a0, a1} T.ByteList{b0}: {==}
    case T.CompatibleUnion{a0, a1} T.BitVector{b0}: {==}
    case T.CompatibleUnion{a0, a1} T.BitList{b0}: {==}
    case T.CompatibleUnion{a0, a1} T.Vector{b0, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ListOf{b0, b1}: {==}
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
    case T.CompatibleUnion{a0, a1} T.CompatibleUnion{b0, b1}: {==}

law ListOf:
  for +fuel: Nat
  for +a: T.Schema
  for +b: T.Schema
  for +n: Nat
  for +m: Nat
  {I.compatible_go(1n+fuel, 0, T.ListOf{a, n}, T.ListOf{b, m}) == Bool.and(Nat.is_eq(n, m), I.compatible_go(fuel, 0, a, b)) : Bool}
def ListOf(fuel, a, b, n, m):
  match a b:
    case T.Boolean{} T.Boolean{}: {==}
    case T.Boolean{} T.Unsigned{b0}: {==}
    case T.Boolean{} T.ByteVector{b0}: {==}
    case T.Boolean{} T.ByteList{b0}: {==}
    case T.Boolean{} T.BitVector{b0}: {==}
    case T.Boolean{} T.BitList{b0}: {==}
    case T.Boolean{} T.Vector{b0, b1}: {==}
    case T.Boolean{} T.ListOf{b0, b1}: {==}
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
    case T.Unsigned{a0} T.Vector{b0, b1}: {==}
    case T.Unsigned{a0} T.ListOf{b0, b1}: {==}
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
    case T.ByteVector{a0} T.ByteVector{b0}: {==}
    case T.ByteVector{a0} T.ByteList{b0}: {==}
    case T.ByteVector{a0} T.BitVector{b0}: {==}
    case T.ByteVector{a0} T.BitList{b0}: {==}
    case T.ByteVector{a0} T.Vector{b0, b1}: {==}
    case T.ByteVector{a0} T.ListOf{b0, b1}: {==}
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
    case T.ByteList{a0} T.ByteList{b0}: {==}
    case T.ByteList{a0} T.BitVector{b0}: {==}
    case T.ByteList{a0} T.BitList{b0}: {==}
    case T.ByteList{a0} T.Vector{b0, b1}: {==}
    case T.ByteList{a0} T.ListOf{b0, b1}: {==}
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
    case T.BitVector{a0} T.Vector{b0, b1}: {==}
    case T.BitVector{a0} T.ListOf{b0, b1}: {==}
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
    case T.BitList{a0} T.Vector{b0, b1}: {==}
    case T.BitList{a0} T.ListOf{b0, b1}: {==}
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
    case T.Vector{a0, a1} T.Boolean{}: {==}
    case T.Vector{a0, a1} T.Unsigned{b0}: {==}
    case T.Vector{a0, a1} T.ByteVector{b0}: {==}
    case T.Vector{a0, a1} T.ByteList{b0}: {==}
    case T.Vector{a0, a1} T.BitVector{b0}: {==}
    case T.Vector{a0, a1} T.BitList{b0}: {==}
    case T.Vector{a0, a1} T.Vector{b0, b1}: {==}
    case T.Vector{a0, a1} T.ListOf{b0, b1}: {==}
    case T.Vector{a0, a1} T.Container{b0, b1}: {==}
    case T.Vector{a0, a1} T.Union{b0}: {==}
    case T.Vector{a0, a1} T.Null{}: {==}
    case T.Vector{a0, a1} T.Chain{b0, b1}: {==}
    case T.Vector{a0, a1} T.End{}: {==}
    case T.Vector{a0, a1} T.Repeat{b0}: {==}
    case T.Vector{a0, a1} T.Named{b0, b1}: {==}
    case T.Vector{a0, a1} T.ProgressiveList{b0}: {==}
    case T.Vector{a0, a1} T.ProgressiveBits{}: {==}
    case T.Vector{a0, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.Vector{a0, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.ListOf{a0, a1} T.Boolean{}: {==}
    case T.ListOf{a0, a1} T.Unsigned{b0}: {==}
    case T.ListOf{a0, a1} T.ByteVector{b0}: {==}
    case T.ListOf{a0, a1} T.ByteList{b0}: {==}
    case T.ListOf{a0, a1} T.BitVector{b0}: {==}
    case T.ListOf{a0, a1} T.BitList{b0}: {==}
    case T.ListOf{a0, a1} T.Vector{b0, b1}: {==}
    case T.ListOf{a0, a1} T.ListOf{b0, b1}: {==}
    case T.ListOf{a0, a1} T.Container{b0, b1}: {==}
    case T.ListOf{a0, a1} T.Union{b0}: {==}
    case T.ListOf{a0, a1} T.Null{}: {==}
    case T.ListOf{a0, a1} T.Chain{b0, b1}: {==}
    case T.ListOf{a0, a1} T.End{}: {==}
    case T.ListOf{a0, a1} T.Repeat{b0}: {==}
    case T.ListOf{a0, a1} T.Named{b0, b1}: {==}
    case T.ListOf{a0, a1} T.ProgressiveList{b0}: {==}
    case T.ListOf{a0, a1} T.ProgressiveBits{}: {==}
    case T.ListOf{a0, a1} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ListOf{a0, a1} T.CompatibleUnion{b0, b1}: {==}
    case T.Container{a0, a1} T.Boolean{}: {==}
    case T.Container{a0, a1} T.Unsigned{b0}: {==}
    case T.Container{a0, a1} T.ByteVector{b0}: {==}
    case T.Container{a0, a1} T.ByteList{b0}: {==}
    case T.Container{a0, a1} T.BitVector{b0}: {==}
    case T.Container{a0, a1} T.BitList{b0}: {==}
    case T.Container{a0, a1} T.Vector{b0, b1}: {==}
    case T.Container{a0, a1} T.ListOf{b0, b1}: {==}
    case T.Container{a0, a1} T.Container{b0, b1}: {==}
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
    case T.Union{a0} T.Vector{b0, b1}: {==}
    case T.Union{a0} T.ListOf{b0, b1}: {==}
    case T.Union{a0} T.Container{b0, b1}: {==}
    case T.Union{a0} T.Union{b0}: {==}
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
    case T.Null{} T.Vector{b0, b1}: {==}
    case T.Null{} T.ListOf{b0, b1}: {==}
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
    case T.Chain{a0, a1} T.Vector{b0, b1}: {==}
    case T.Chain{a0, a1} T.ListOf{b0, b1}: {==}
    case T.Chain{a0, a1} T.Container{b0, b1}: {==}
    case T.Chain{a0, a1} T.Union{b0}: {==}
    case T.Chain{a0, a1} T.Null{}: {==}
    case T.Chain{a0, a1} T.Chain{b0, b1}: {==}
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
    case T.End{} T.Vector{b0, b1}: {==}
    case T.End{} T.ListOf{b0, b1}: {==}
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
    case T.Repeat{a0} T.Vector{b0, b1}: {==}
    case T.Repeat{a0} T.ListOf{b0, b1}: {==}
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
    case T.Named{a0, a1} T.Vector{b0, b1}: {==}
    case T.Named{a0, a1} T.ListOf{b0, b1}: {==}
    case T.Named{a0, a1} T.Container{b0, b1}: {==}
    case T.Named{a0, a1} T.Union{b0}: {==}
    case T.Named{a0, a1} T.Null{}: {==}
    case T.Named{a0, a1} T.Chain{b0, b1}: {==}
    case T.Named{a0, a1} T.End{}: {==}
    case T.Named{a0, a1} T.Repeat{b0}: {==}
    case T.Named{a0, a1} T.Named{b0, b1}: {==}
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
    case T.ProgressiveList{a0} T.Vector{b0, b1}: {==}
    case T.ProgressiveList{a0} T.ListOf{b0, b1}: {==}
    case T.ProgressiveList{a0} T.Container{b0, b1}: {==}
    case T.ProgressiveList{a0} T.Union{b0}: {==}
    case T.ProgressiveList{a0} T.Null{}: {==}
    case T.ProgressiveList{a0} T.Chain{b0, b1}: {==}
    case T.ProgressiveList{a0} T.End{}: {==}
    case T.ProgressiveList{a0} T.Repeat{b0}: {==}
    case T.ProgressiveList{a0} T.Named{b0, b1}: {==}
    case T.ProgressiveList{a0} T.ProgressiveList{b0}: {==}
    case T.ProgressiveList{a0} T.ProgressiveBits{}: {==}
    case T.ProgressiveList{a0} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ProgressiveList{a0} T.CompatibleUnion{b0, b1}: {==}
    case T.ProgressiveBits{} T.Boolean{}: {==}
    case T.ProgressiveBits{} T.Unsigned{b0}: {==}
    case T.ProgressiveBits{} T.ByteVector{b0}: {==}
    case T.ProgressiveBits{} T.ByteList{b0}: {==}
    case T.ProgressiveBits{} T.BitVector{b0}: {==}
    case T.ProgressiveBits{} T.BitList{b0}: {==}
    case T.ProgressiveBits{} T.Vector{b0, b1}: {==}
    case T.ProgressiveBits{} T.ListOf{b0, b1}: {==}
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
    case T.ProgressiveContainer{a0, a1, a2} T.Vector{b0, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ListOf{b0, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Container{b0, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Union{b0}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Null{}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Chain{b0, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.End{}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Repeat{b0}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.Named{b0, b1}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveList{b0}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveBits{}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveContainer{b0, b1, b2}: {==}
    case T.ProgressiveContainer{a0, a1, a2} T.CompatibleUnion{b0, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.Boolean{}: {==}
    case T.CompatibleUnion{a0, a1} T.Unsigned{b0}: {==}
    case T.CompatibleUnion{a0, a1} T.ByteVector{b0}: {==}
    case T.CompatibleUnion{a0, a1} T.ByteList{b0}: {==}
    case T.CompatibleUnion{a0, a1} T.BitVector{b0}: {==}
    case T.CompatibleUnion{a0, a1} T.BitList{b0}: {==}
    case T.CompatibleUnion{a0, a1} T.Vector{b0, b1}: {==}
    case T.CompatibleUnion{a0, a1} T.ListOf{b0, b1}: {==}
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
    case T.CompatibleUnion{a0, a1} T.CompatibleUnion{b0, b1}: {==}
