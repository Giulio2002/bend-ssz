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

# Named nodes belong to expanded compatibility slots, never public type trees.
# Null is allowed here because ordinary Union's first option may be Null.
def unnamed(schema: T.Schema) -> Bool:
  match schema:
    case T.Boolean{}: True{}
    case T.Unsigned{a0}: True{}
    case T.ByteVector{a0}: True{}
    case T.ByteList{a0}: True{}
    case T.BitVector{a0}: True{}
    case T.BitList{a0}: True{}
    case T.Vector{a0, a1}: unnamed(a0)
    case T.ListOf{a0, a1}: unnamed(a0)
    case T.Container{a0, a1}: unnamed(a1)
    case T.Union{a0}: unnamed(a0)
    case T.Null{}: True{}
    case T.Chain{a0, a1}: Bool.and(unnamed(a0), unnamed(a1))
    case T.End{}: True{}
    case T.Repeat{a0}: unnamed(a0)
    case T.Named{a0, a1}: False{}
    case T.ProgressiveList{a0}: unnamed(a0)
    case T.ProgressiveBits{}: True{}
    case T.ProgressiveContainer{a0, a1, a2}: unnamed(a1)
    case T.CompatibleUnion{a0, a1}: unnamed(a1)

law and_equal:
  for +a: Bool
  for +b: Bool
  for +c: Bool
  for +d: Bool
  for ab: {a == b : Bool}
  for cd: {c == d : Bool}
  {Bool.and(a, c) == Bool.and(b, d) : Bool}
def and_equal(a, b, c, d, ab, cd):
  %ab : {Bool.and(a, c) == Bool.and(_, d) : Bool}
  %cd : {Bool.and(a, c) == Bool.and(a, _) : Bool}
  {==}

law equal:
  for +a: T.Schema
  for +b: T.Schema
  for +public: {unnamed(a) == True{} : Bool}
  {I.identical(a, b) == S.identical(a, b) : Bool}
def equal(a, b, public):
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
    case T.Unsigned{a0} T.Unsigned{b0}: %P.width_correct(a0) : {Nat.is_eq(IP.width(a0), IP.width(b0)) == Nat.is_eq(_, SP.byte_width(b0)) : Bool}
      %P.width_correct(b0) : {Nat.is_eq(IP.width(a0), IP.width(b0)) == Nat.is_eq(IP.width(a0), _) : Bool}
      {==}
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
    case T.ByteVector{a0} T.ByteVector{b0}: {==}
    case T.ByteVector{a0} T.ByteList{b0}: {==}
    case T.ByteVector{a0} T.BitVector{b0}: {==}
    case T.ByteVector{a0} T.BitList{b0}: {==}
    case T.ByteVector{a0} T.Vector{T.Boolean{}, b1}: {==}
    case T.ByteVector{a0} T.Vector{T.Unsigned{bc0}, b1}: %P.width_correct(bc0) : {Bool.and(Nat.is_eq(a0, b1), Nat.is_eq(IP.width(bc0), 1n)) == Bool.and(Nat.is_eq(a0, b1), Nat.is_eq(_, 1n)) : Bool}
      {==}
    case T.ByteVector{a0} T.Vector{T.ByteVector{bc0}, b1}: {==}
    case T.ByteVector{a0} T.Vector{T.ByteList{bc0}, b1}: {==}
    case T.ByteVector{a0} T.Vector{T.BitVector{bc0}, b1}: {==}
    case T.ByteVector{a0} T.Vector{T.BitList{bc0}, b1}: {==}
    case T.ByteVector{a0} T.Vector{T.Vector{bc0, bc1}, b1}: {==}
    case T.ByteVector{a0} T.Vector{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ByteVector{a0} T.Vector{T.Container{bc0, bc1}, b1}: {==}
    case T.ByteVector{a0} T.Vector{T.Union{bc0}, b1}: {==}
    case T.ByteVector{a0} T.Vector{T.Null{}, b1}: {==}
    case T.ByteVector{a0} T.Vector{T.Chain{bc0, bc1}, b1}: {==}
    case T.ByteVector{a0} T.Vector{T.End{}, b1}: {==}
    case T.ByteVector{a0} T.Vector{T.Repeat{bc0}, b1}: {==}
    case T.ByteVector{a0} T.Vector{T.Named{bc0, bc1}, b1}: {==}
    case T.ByteVector{a0} T.Vector{T.ProgressiveList{bc0}, b1}: {==}
    case T.ByteVector{a0} T.Vector{T.ProgressiveBits{}, b1}: {==}
    case T.ByteVector{a0} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ByteVector{a0} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: {==}
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
    case T.ByteList{a0} T.ByteList{b0}: {==}
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
    case T.ByteList{a0} T.ListOf{T.Boolean{}, b1}: {==}
    case T.ByteList{a0} T.ListOf{T.Unsigned{bc0}, b1}: %P.width_correct(bc0) : {Bool.and(Nat.is_eq(a0, b1), Nat.is_eq(IP.width(bc0), 1n)) == Bool.and(Nat.is_eq(a0, b1), Nat.is_eq(_, 1n)) : Bool}
      {==}
    case T.ByteList{a0} T.ListOf{T.ByteVector{bc0}, b1}: {==}
    case T.ByteList{a0} T.ListOf{T.ByteList{bc0}, b1}: {==}
    case T.ByteList{a0} T.ListOf{T.BitVector{bc0}, b1}: {==}
    case T.ByteList{a0} T.ListOf{T.BitList{bc0}, b1}: {==}
    case T.ByteList{a0} T.ListOf{T.Vector{bc0, bc1}, b1}: {==}
    case T.ByteList{a0} T.ListOf{T.ListOf{bc0, bc1}, b1}: {==}
    case T.ByteList{a0} T.ListOf{T.Container{bc0, bc1}, b1}: {==}
    case T.ByteList{a0} T.ListOf{T.Union{bc0}, b1}: {==}
    case T.ByteList{a0} T.ListOf{T.Null{}, b1}: {==}
    case T.ByteList{a0} T.ListOf{T.Chain{bc0, bc1}, b1}: {==}
    case T.ByteList{a0} T.ListOf{T.End{}, b1}: {==}
    case T.ByteList{a0} T.ListOf{T.Repeat{bc0}, b1}: {==}
    case T.ByteList{a0} T.ListOf{T.Named{bc0, bc1}, b1}: {==}
    case T.ByteList{a0} T.ListOf{T.ProgressiveList{bc0}, b1}: {==}
    case T.ByteList{a0} T.ListOf{T.ProgressiveBits{}, b1}: {==}
    case T.ByteList{a0} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: {==}
    case T.ByteList{a0} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: {==}
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
    case T.Vector{T.Boolean{}, a1} T.ByteVector{b0}: {==}
    case T.Vector{T.Boolean{}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.Boolean{}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.Boolean{}, a1} T.BitList{b0}: {==}
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Boolean{}), S.identical(T.Boolean{}, T.Boolean{}), {==}, equal(T.Boolean{}, T.Boolean{}, public))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Unsigned{bc0}), S.identical(T.Boolean{}, T.Unsigned{bc0}), {==}, equal(T.Boolean{}, T.Unsigned{bc0}, public))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ByteVector{bc0}), S.identical(T.Boolean{}, T.ByteVector{bc0}), {==}, equal(T.Boolean{}, T.ByteVector{bc0}, public))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ByteList{bc0}), S.identical(T.Boolean{}, T.ByteList{bc0}), {==}, equal(T.Boolean{}, T.ByteList{bc0}, public))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.BitVector{bc0}), S.identical(T.Boolean{}, T.BitVector{bc0}), {==}, equal(T.Boolean{}, T.BitVector{bc0}, public))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.BitList{bc0}), S.identical(T.Boolean{}, T.BitList{bc0}), {==}, equal(T.Boolean{}, T.BitList{bc0}, public))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Vector{bc0, bc1}), S.identical(T.Boolean{}, T.Vector{bc0, bc1}), {==}, equal(T.Boolean{}, T.Vector{bc0, bc1}, public))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ListOf{bc0, bc1}), S.identical(T.Boolean{}, T.ListOf{bc0, bc1}), {==}, equal(T.Boolean{}, T.ListOf{bc0, bc1}, public))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Container{bc0, bc1}), S.identical(T.Boolean{}, T.Container{bc0, bc1}), {==}, equal(T.Boolean{}, T.Container{bc0, bc1}, public))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Union{bc0}), S.identical(T.Boolean{}, T.Union{bc0}), {==}, equal(T.Boolean{}, T.Union{bc0}, public))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Null{}), S.identical(T.Boolean{}, T.Null{}), {==}, equal(T.Boolean{}, T.Null{}, public))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Chain{bc0, bc1}), S.identical(T.Boolean{}, T.Chain{bc0, bc1}), {==}, equal(T.Boolean{}, T.Chain{bc0, bc1}, public))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.End{}), S.identical(T.Boolean{}, T.End{}), {==}, equal(T.Boolean{}, T.End{}, public))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Repeat{bc0}), S.identical(T.Boolean{}, T.Repeat{bc0}), {==}, equal(T.Boolean{}, T.Repeat{bc0}, public))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Named{bc0, bc1}), S.identical(T.Boolean{}, T.Named{bc0, bc1}), {==}, equal(T.Boolean{}, T.Named{bc0, bc1}, public))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ProgressiveList{bc0}), S.identical(T.Boolean{}, T.ProgressiveList{bc0}), {==}, equal(T.Boolean{}, T.ProgressiveList{bc0}, public))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ProgressiveBits{}), S.identical(T.Boolean{}, T.ProgressiveBits{}), {==}, equal(T.Boolean{}, T.ProgressiveBits{}, public))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.Vector{T.Boolean{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.CompatibleUnion{bc0, bc1}), S.identical(T.Boolean{}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.Boolean{}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.Vector{T.Unsigned{ac0}, a1} T.ByteVector{b0}: %P.width_correct(ac0) : {Bool.and(Nat.is_eq(a1, b0), Nat.is_eq(IP.width(ac0), 1n)) == Bool.and(Nat.is_eq(a1, b0), Nat.is_eq(_, 1n)) : Bool}
      {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.BitList{b0}: {==}
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.Boolean{}), S.identical(T.Unsigned{ac0}, T.Boolean{}), {==}, equal(T.Unsigned{ac0}, T.Boolean{}, public))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.Unsigned{bc0}), S.identical(T.Unsigned{ac0}, T.Unsigned{bc0}), {==}, equal(T.Unsigned{ac0}, T.Unsigned{bc0}, public))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.ByteVector{bc0}), S.identical(T.Unsigned{ac0}, T.ByteVector{bc0}), {==}, equal(T.Unsigned{ac0}, T.ByteVector{bc0}, public))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.ByteList{bc0}), S.identical(T.Unsigned{ac0}, T.ByteList{bc0}), {==}, equal(T.Unsigned{ac0}, T.ByteList{bc0}, public))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.BitVector{bc0}), S.identical(T.Unsigned{ac0}, T.BitVector{bc0}), {==}, equal(T.Unsigned{ac0}, T.BitVector{bc0}, public))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.BitList{bc0}), S.identical(T.Unsigned{ac0}, T.BitList{bc0}), {==}, equal(T.Unsigned{ac0}, T.BitList{bc0}, public))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.Vector{bc0, bc1}), S.identical(T.Unsigned{ac0}, T.Vector{bc0, bc1}), {==}, equal(T.Unsigned{ac0}, T.Vector{bc0, bc1}, public))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.ListOf{bc0, bc1}), S.identical(T.Unsigned{ac0}, T.ListOf{bc0, bc1}), {==}, equal(T.Unsigned{ac0}, T.ListOf{bc0, bc1}, public))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.Container{bc0, bc1}), S.identical(T.Unsigned{ac0}, T.Container{bc0, bc1}), {==}, equal(T.Unsigned{ac0}, T.Container{bc0, bc1}, public))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.Union{bc0}), S.identical(T.Unsigned{ac0}, T.Union{bc0}), {==}, equal(T.Unsigned{ac0}, T.Union{bc0}, public))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.Null{}), S.identical(T.Unsigned{ac0}, T.Null{}), {==}, equal(T.Unsigned{ac0}, T.Null{}, public))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.Chain{bc0, bc1}), S.identical(T.Unsigned{ac0}, T.Chain{bc0, bc1}), {==}, equal(T.Unsigned{ac0}, T.Chain{bc0, bc1}, public))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.End{}), S.identical(T.Unsigned{ac0}, T.End{}), {==}, equal(T.Unsigned{ac0}, T.End{}, public))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.Repeat{bc0}), S.identical(T.Unsigned{ac0}, T.Repeat{bc0}), {==}, equal(T.Unsigned{ac0}, T.Repeat{bc0}, public))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.Named{bc0, bc1}), S.identical(T.Unsigned{ac0}, T.Named{bc0, bc1}), {==}, equal(T.Unsigned{ac0}, T.Named{bc0, bc1}, public))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.ProgressiveList{bc0}), S.identical(T.Unsigned{ac0}, T.ProgressiveList{bc0}), {==}, equal(T.Unsigned{ac0}, T.ProgressiveList{bc0}, public))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.ProgressiveBits{}), S.identical(T.Unsigned{ac0}, T.ProgressiveBits{}), {==}, equal(T.Unsigned{ac0}, T.ProgressiveBits{}, public))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.Vector{T.Unsigned{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.Vector{T.ByteVector{ac0}, a1} T.ByteVector{b0}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.BitList{b0}: {==}
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.Boolean{}), S.identical(T.ByteVector{ac0}, T.Boolean{}), {==}, equal(T.ByteVector{ac0}, T.Boolean{}, public))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.Unsigned{bc0}), S.identical(T.ByteVector{ac0}, T.Unsigned{bc0}), {==}, equal(T.ByteVector{ac0}, T.Unsigned{bc0}, public))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.ByteVector{bc0}), S.identical(T.ByteVector{ac0}, T.ByteVector{bc0}), {==}, equal(T.ByteVector{ac0}, T.ByteVector{bc0}, public))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.ByteList{bc0}), S.identical(T.ByteVector{ac0}, T.ByteList{bc0}), {==}, equal(T.ByteVector{ac0}, T.ByteList{bc0}, public))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.BitVector{bc0}), S.identical(T.ByteVector{ac0}, T.BitVector{bc0}), {==}, equal(T.ByteVector{ac0}, T.BitVector{bc0}, public))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.BitList{bc0}), S.identical(T.ByteVector{ac0}, T.BitList{bc0}), {==}, equal(T.ByteVector{ac0}, T.BitList{bc0}, public))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.Vector{bc0, bc1}), S.identical(T.ByteVector{ac0}, T.Vector{bc0, bc1}), {==}, equal(T.ByteVector{ac0}, T.Vector{bc0, bc1}, public))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.ListOf{bc0, bc1}), S.identical(T.ByteVector{ac0}, T.ListOf{bc0, bc1}), {==}, equal(T.ByteVector{ac0}, T.ListOf{bc0, bc1}, public))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.Container{bc0, bc1}), S.identical(T.ByteVector{ac0}, T.Container{bc0, bc1}), {==}, equal(T.ByteVector{ac0}, T.Container{bc0, bc1}, public))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.Union{bc0}), S.identical(T.ByteVector{ac0}, T.Union{bc0}), {==}, equal(T.ByteVector{ac0}, T.Union{bc0}, public))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.Null{}), S.identical(T.ByteVector{ac0}, T.Null{}), {==}, equal(T.ByteVector{ac0}, T.Null{}, public))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.Chain{bc0, bc1}), S.identical(T.ByteVector{ac0}, T.Chain{bc0, bc1}), {==}, equal(T.ByteVector{ac0}, T.Chain{bc0, bc1}, public))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.End{}), S.identical(T.ByteVector{ac0}, T.End{}), {==}, equal(T.ByteVector{ac0}, T.End{}, public))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.Repeat{bc0}), S.identical(T.ByteVector{ac0}, T.Repeat{bc0}), {==}, equal(T.ByteVector{ac0}, T.Repeat{bc0}, public))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.Named{bc0, bc1}), S.identical(T.ByteVector{ac0}, T.Named{bc0, bc1}), {==}, equal(T.ByteVector{ac0}, T.Named{bc0, bc1}, public))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.ProgressiveList{bc0}), S.identical(T.ByteVector{ac0}, T.ProgressiveList{bc0}), {==}, equal(T.ByteVector{ac0}, T.ProgressiveList{bc0}, public))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.ProgressiveBits{}), S.identical(T.ByteVector{ac0}, T.ProgressiveBits{}), {==}, equal(T.ByteVector{ac0}, T.ProgressiveBits{}, public))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.Vector{T.ByteVector{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.Vector{T.ByteList{ac0}, a1} T.ByteVector{b0}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.BitList{b0}: {==}
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.Boolean{}), S.identical(T.ByteList{ac0}, T.Boolean{}), {==}, equal(T.ByteList{ac0}, T.Boolean{}, public))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.Unsigned{bc0}), S.identical(T.ByteList{ac0}, T.Unsigned{bc0}), {==}, equal(T.ByteList{ac0}, T.Unsigned{bc0}, public))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.ByteVector{bc0}), S.identical(T.ByteList{ac0}, T.ByteVector{bc0}), {==}, equal(T.ByteList{ac0}, T.ByteVector{bc0}, public))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.ByteList{bc0}), S.identical(T.ByteList{ac0}, T.ByteList{bc0}), {==}, equal(T.ByteList{ac0}, T.ByteList{bc0}, public))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.BitVector{bc0}), S.identical(T.ByteList{ac0}, T.BitVector{bc0}), {==}, equal(T.ByteList{ac0}, T.BitVector{bc0}, public))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.BitList{bc0}), S.identical(T.ByteList{ac0}, T.BitList{bc0}), {==}, equal(T.ByteList{ac0}, T.BitList{bc0}, public))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.Vector{bc0, bc1}), S.identical(T.ByteList{ac0}, T.Vector{bc0, bc1}), {==}, equal(T.ByteList{ac0}, T.Vector{bc0, bc1}, public))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.ListOf{bc0, bc1}), S.identical(T.ByteList{ac0}, T.ListOf{bc0, bc1}), {==}, equal(T.ByteList{ac0}, T.ListOf{bc0, bc1}, public))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.Container{bc0, bc1}), S.identical(T.ByteList{ac0}, T.Container{bc0, bc1}), {==}, equal(T.ByteList{ac0}, T.Container{bc0, bc1}, public))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.Union{bc0}), S.identical(T.ByteList{ac0}, T.Union{bc0}), {==}, equal(T.ByteList{ac0}, T.Union{bc0}, public))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.Null{}), S.identical(T.ByteList{ac0}, T.Null{}), {==}, equal(T.ByteList{ac0}, T.Null{}, public))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.Chain{bc0, bc1}), S.identical(T.ByteList{ac0}, T.Chain{bc0, bc1}), {==}, equal(T.ByteList{ac0}, T.Chain{bc0, bc1}, public))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.End{}), S.identical(T.ByteList{ac0}, T.End{}), {==}, equal(T.ByteList{ac0}, T.End{}, public))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.Repeat{bc0}), S.identical(T.ByteList{ac0}, T.Repeat{bc0}), {==}, equal(T.ByteList{ac0}, T.Repeat{bc0}, public))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.Named{bc0, bc1}), S.identical(T.ByteList{ac0}, T.Named{bc0, bc1}), {==}, equal(T.ByteList{ac0}, T.Named{bc0, bc1}, public))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.ProgressiveList{bc0}), S.identical(T.ByteList{ac0}, T.ProgressiveList{bc0}), {==}, equal(T.ByteList{ac0}, T.ProgressiveList{bc0}, public))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.ProgressiveBits{}), S.identical(T.ByteList{ac0}, T.ProgressiveBits{}), {==}, equal(T.ByteList{ac0}, T.ProgressiveBits{}, public))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.Vector{T.ByteList{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.Vector{T.BitVector{ac0}, a1} T.ByteVector{b0}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.BitList{b0}: {==}
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.Boolean{}), S.identical(T.BitVector{ac0}, T.Boolean{}), {==}, equal(T.BitVector{ac0}, T.Boolean{}, public))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.Unsigned{bc0}), S.identical(T.BitVector{ac0}, T.Unsigned{bc0}), {==}, equal(T.BitVector{ac0}, T.Unsigned{bc0}, public))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.ByteVector{bc0}), S.identical(T.BitVector{ac0}, T.ByteVector{bc0}), {==}, equal(T.BitVector{ac0}, T.ByteVector{bc0}, public))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.ByteList{bc0}), S.identical(T.BitVector{ac0}, T.ByteList{bc0}), {==}, equal(T.BitVector{ac0}, T.ByteList{bc0}, public))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.BitVector{bc0}), S.identical(T.BitVector{ac0}, T.BitVector{bc0}), {==}, equal(T.BitVector{ac0}, T.BitVector{bc0}, public))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.BitList{bc0}), S.identical(T.BitVector{ac0}, T.BitList{bc0}), {==}, equal(T.BitVector{ac0}, T.BitList{bc0}, public))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.Vector{bc0, bc1}), S.identical(T.BitVector{ac0}, T.Vector{bc0, bc1}), {==}, equal(T.BitVector{ac0}, T.Vector{bc0, bc1}, public))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.ListOf{bc0, bc1}), S.identical(T.BitVector{ac0}, T.ListOf{bc0, bc1}), {==}, equal(T.BitVector{ac0}, T.ListOf{bc0, bc1}, public))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.Container{bc0, bc1}), S.identical(T.BitVector{ac0}, T.Container{bc0, bc1}), {==}, equal(T.BitVector{ac0}, T.Container{bc0, bc1}, public))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.Union{bc0}), S.identical(T.BitVector{ac0}, T.Union{bc0}), {==}, equal(T.BitVector{ac0}, T.Union{bc0}, public))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.Null{}), S.identical(T.BitVector{ac0}, T.Null{}), {==}, equal(T.BitVector{ac0}, T.Null{}, public))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.Chain{bc0, bc1}), S.identical(T.BitVector{ac0}, T.Chain{bc0, bc1}), {==}, equal(T.BitVector{ac0}, T.Chain{bc0, bc1}, public))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.End{}), S.identical(T.BitVector{ac0}, T.End{}), {==}, equal(T.BitVector{ac0}, T.End{}, public))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.Repeat{bc0}), S.identical(T.BitVector{ac0}, T.Repeat{bc0}), {==}, equal(T.BitVector{ac0}, T.Repeat{bc0}, public))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.Named{bc0, bc1}), S.identical(T.BitVector{ac0}, T.Named{bc0, bc1}), {==}, equal(T.BitVector{ac0}, T.Named{bc0, bc1}, public))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.ProgressiveList{bc0}), S.identical(T.BitVector{ac0}, T.ProgressiveList{bc0}), {==}, equal(T.BitVector{ac0}, T.ProgressiveList{bc0}, public))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.ProgressiveBits{}), S.identical(T.BitVector{ac0}, T.ProgressiveBits{}), {==}, equal(T.BitVector{ac0}, T.ProgressiveBits{}, public))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.Vector{T.BitVector{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.Vector{T.BitList{ac0}, a1} T.ByteVector{b0}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.BitList{b0}: {==}
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.Boolean{}), S.identical(T.BitList{ac0}, T.Boolean{}), {==}, equal(T.BitList{ac0}, T.Boolean{}, public))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.Unsigned{bc0}), S.identical(T.BitList{ac0}, T.Unsigned{bc0}), {==}, equal(T.BitList{ac0}, T.Unsigned{bc0}, public))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.ByteVector{bc0}), S.identical(T.BitList{ac0}, T.ByteVector{bc0}), {==}, equal(T.BitList{ac0}, T.ByteVector{bc0}, public))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.ByteList{bc0}), S.identical(T.BitList{ac0}, T.ByteList{bc0}), {==}, equal(T.BitList{ac0}, T.ByteList{bc0}, public))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.BitVector{bc0}), S.identical(T.BitList{ac0}, T.BitVector{bc0}), {==}, equal(T.BitList{ac0}, T.BitVector{bc0}, public))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.BitList{bc0}), S.identical(T.BitList{ac0}, T.BitList{bc0}), {==}, equal(T.BitList{ac0}, T.BitList{bc0}, public))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.Vector{bc0, bc1}), S.identical(T.BitList{ac0}, T.Vector{bc0, bc1}), {==}, equal(T.BitList{ac0}, T.Vector{bc0, bc1}, public))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.ListOf{bc0, bc1}), S.identical(T.BitList{ac0}, T.ListOf{bc0, bc1}), {==}, equal(T.BitList{ac0}, T.ListOf{bc0, bc1}, public))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.Container{bc0, bc1}), S.identical(T.BitList{ac0}, T.Container{bc0, bc1}), {==}, equal(T.BitList{ac0}, T.Container{bc0, bc1}, public))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.Union{bc0}), S.identical(T.BitList{ac0}, T.Union{bc0}), {==}, equal(T.BitList{ac0}, T.Union{bc0}, public))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.Null{}), S.identical(T.BitList{ac0}, T.Null{}), {==}, equal(T.BitList{ac0}, T.Null{}, public))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.Chain{bc0, bc1}), S.identical(T.BitList{ac0}, T.Chain{bc0, bc1}), {==}, equal(T.BitList{ac0}, T.Chain{bc0, bc1}, public))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.End{}), S.identical(T.BitList{ac0}, T.End{}), {==}, equal(T.BitList{ac0}, T.End{}, public))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.Repeat{bc0}), S.identical(T.BitList{ac0}, T.Repeat{bc0}), {==}, equal(T.BitList{ac0}, T.Repeat{bc0}, public))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.Named{bc0, bc1}), S.identical(T.BitList{ac0}, T.Named{bc0, bc1}), {==}, equal(T.BitList{ac0}, T.Named{bc0, bc1}, public))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.ProgressiveList{bc0}), S.identical(T.BitList{ac0}, T.ProgressiveList{bc0}), {==}, equal(T.BitList{ac0}, T.ProgressiveList{bc0}, public))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.ProgressiveBits{}), S.identical(T.BitList{ac0}, T.ProgressiveBits{}), {==}, equal(T.BitList{ac0}, T.ProgressiveBits{}, public))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.Vector{T.BitList{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ByteVector{b0}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.BitList{b0}: {==}
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.Boolean{}), S.identical(T.Vector{ac0, ac1}, T.Boolean{}), {==}, equal(T.Vector{ac0, ac1}, T.Boolean{}, public))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.Unsigned{bc0}), S.identical(T.Vector{ac0, ac1}, T.Unsigned{bc0}), {==}, equal(T.Vector{ac0, ac1}, T.Unsigned{bc0}, public))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.ByteVector{bc0}), S.identical(T.Vector{ac0, ac1}, T.ByteVector{bc0}), {==}, equal(T.Vector{ac0, ac1}, T.ByteVector{bc0}, public))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.ByteList{bc0}), S.identical(T.Vector{ac0, ac1}, T.ByteList{bc0}), {==}, equal(T.Vector{ac0, ac1}, T.ByteList{bc0}, public))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.BitVector{bc0}), S.identical(T.Vector{ac0, ac1}, T.BitVector{bc0}), {==}, equal(T.Vector{ac0, ac1}, T.BitVector{bc0}, public))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.BitList{bc0}), S.identical(T.Vector{ac0, ac1}, T.BitList{bc0}), {==}, equal(T.Vector{ac0, ac1}, T.BitList{bc0}, public))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(T.Vector{ac0, ac1}, T.Vector{bc0, bc1}), {==}, equal(T.Vector{ac0, ac1}, T.Vector{bc0, bc1}, public))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}), {==}, equal(T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}, public))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.Container{bc0, bc1}), S.identical(T.Vector{ac0, ac1}, T.Container{bc0, bc1}), {==}, equal(T.Vector{ac0, ac1}, T.Container{bc0, bc1}, public))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.Union{bc0}), S.identical(T.Vector{ac0, ac1}, T.Union{bc0}), {==}, equal(T.Vector{ac0, ac1}, T.Union{bc0}, public))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.Null{}), S.identical(T.Vector{ac0, ac1}, T.Null{}), {==}, equal(T.Vector{ac0, ac1}, T.Null{}, public))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(T.Vector{ac0, ac1}, T.Chain{bc0, bc1}), {==}, equal(T.Vector{ac0, ac1}, T.Chain{bc0, bc1}, public))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.End{}), S.identical(T.Vector{ac0, ac1}, T.End{}), {==}, equal(T.Vector{ac0, ac1}, T.End{}, public))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.Repeat{bc0}), S.identical(T.Vector{ac0, ac1}, T.Repeat{bc0}), {==}, equal(T.Vector{ac0, ac1}, T.Repeat{bc0}, public))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.Named{bc0, bc1}), S.identical(T.Vector{ac0, ac1}, T.Named{bc0, bc1}), {==}, equal(T.Vector{ac0, ac1}, T.Named{bc0, bc1}, public))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(T.Vector{ac0, ac1}, T.ProgressiveList{bc0}), {==}, equal(T.Vector{ac0, ac1}, T.ProgressiveList{bc0}, public))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.ProgressiveBits{}), S.identical(T.Vector{ac0, ac1}, T.ProgressiveBits{}), {==}, equal(T.Vector{ac0, ac1}, T.ProgressiveBits{}, public))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.Vector{T.Vector{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ByteVector{b0}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.BitList{b0}: {==}
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.Boolean{}), S.identical(T.ListOf{ac0, ac1}, T.Boolean{}), {==}, equal(T.ListOf{ac0, ac1}, T.Boolean{}, public))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.Unsigned{bc0}), S.identical(T.ListOf{ac0, ac1}, T.Unsigned{bc0}), {==}, equal(T.ListOf{ac0, ac1}, T.Unsigned{bc0}, public))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.ByteVector{bc0}), S.identical(T.ListOf{ac0, ac1}, T.ByteVector{bc0}), {==}, equal(T.ListOf{ac0, ac1}, T.ByteVector{bc0}, public))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.ByteList{bc0}), S.identical(T.ListOf{ac0, ac1}, T.ByteList{bc0}), {==}, equal(T.ListOf{ac0, ac1}, T.ByteList{bc0}, public))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.BitVector{bc0}), S.identical(T.ListOf{ac0, ac1}, T.BitVector{bc0}), {==}, equal(T.ListOf{ac0, ac1}, T.BitVector{bc0}, public))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.BitList{bc0}), S.identical(T.ListOf{ac0, ac1}, T.BitList{bc0}), {==}, equal(T.ListOf{ac0, ac1}, T.BitList{bc0}, public))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}), {==}, equal(T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}, public))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}), {==}, equal(T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}, public))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.Container{bc0, bc1}), S.identical(T.ListOf{ac0, ac1}, T.Container{bc0, bc1}), {==}, equal(T.ListOf{ac0, ac1}, T.Container{bc0, bc1}, public))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.Union{bc0}), S.identical(T.ListOf{ac0, ac1}, T.Union{bc0}), {==}, equal(T.ListOf{ac0, ac1}, T.Union{bc0}, public))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.Null{}), S.identical(T.ListOf{ac0, ac1}, T.Null{}), {==}, equal(T.ListOf{ac0, ac1}, T.Null{}, public))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}), {==}, equal(T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}, public))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.End{}), S.identical(T.ListOf{ac0, ac1}, T.End{}), {==}, equal(T.ListOf{ac0, ac1}, T.End{}, public))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.Repeat{bc0}), S.identical(T.ListOf{ac0, ac1}, T.Repeat{bc0}), {==}, equal(T.ListOf{ac0, ac1}, T.Repeat{bc0}, public))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.Named{bc0, bc1}), S.identical(T.ListOf{ac0, ac1}, T.Named{bc0, bc1}), {==}, equal(T.ListOf{ac0, ac1}, T.Named{bc0, bc1}, public))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}), {==}, equal(T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}, public))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.ProgressiveBits{}), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveBits{}), {==}, equal(T.ListOf{ac0, ac1}, T.ProgressiveBits{}, public))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.Vector{T.ListOf{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.Vector{T.Container{ac0, ac1}, a1} T.ByteVector{b0}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.BitList{b0}: {==}
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.Boolean{}), S.identical(T.Container{ac0, ac1}, T.Boolean{}), {==}, equal(T.Container{ac0, ac1}, T.Boolean{}, public))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.Unsigned{bc0}), S.identical(T.Container{ac0, ac1}, T.Unsigned{bc0}), {==}, equal(T.Container{ac0, ac1}, T.Unsigned{bc0}, public))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.ByteVector{bc0}), S.identical(T.Container{ac0, ac1}, T.ByteVector{bc0}), {==}, equal(T.Container{ac0, ac1}, T.ByteVector{bc0}, public))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.ByteList{bc0}), S.identical(T.Container{ac0, ac1}, T.ByteList{bc0}), {==}, equal(T.Container{ac0, ac1}, T.ByteList{bc0}, public))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.BitVector{bc0}), S.identical(T.Container{ac0, ac1}, T.BitVector{bc0}), {==}, equal(T.Container{ac0, ac1}, T.BitVector{bc0}, public))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.BitList{bc0}), S.identical(T.Container{ac0, ac1}, T.BitList{bc0}), {==}, equal(T.Container{ac0, ac1}, T.BitList{bc0}, public))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(T.Container{ac0, ac1}, T.Vector{bc0, bc1}), {==}, equal(T.Container{ac0, ac1}, T.Vector{bc0, bc1}, public))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(T.Container{ac0, ac1}, T.ListOf{bc0, bc1}), {==}, equal(T.Container{ac0, ac1}, T.ListOf{bc0, bc1}, public))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.Container{bc0, bc1}), S.identical(T.Container{ac0, ac1}, T.Container{bc0, bc1}), {==}, equal(T.Container{ac0, ac1}, T.Container{bc0, bc1}, public))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.Union{bc0}), S.identical(T.Container{ac0, ac1}, T.Union{bc0}), {==}, equal(T.Container{ac0, ac1}, T.Union{bc0}, public))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.Null{}), S.identical(T.Container{ac0, ac1}, T.Null{}), {==}, equal(T.Container{ac0, ac1}, T.Null{}, public))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(T.Container{ac0, ac1}, T.Chain{bc0, bc1}), {==}, equal(T.Container{ac0, ac1}, T.Chain{bc0, bc1}, public))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.End{}), S.identical(T.Container{ac0, ac1}, T.End{}), {==}, equal(T.Container{ac0, ac1}, T.End{}, public))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.Repeat{bc0}), S.identical(T.Container{ac0, ac1}, T.Repeat{bc0}), {==}, equal(T.Container{ac0, ac1}, T.Repeat{bc0}, public))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.Named{bc0, bc1}), S.identical(T.Container{ac0, ac1}, T.Named{bc0, bc1}), {==}, equal(T.Container{ac0, ac1}, T.Named{bc0, bc1}, public))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(T.Container{ac0, ac1}, T.ProgressiveList{bc0}), {==}, equal(T.Container{ac0, ac1}, T.ProgressiveList{bc0}, public))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.ProgressiveBits{}), S.identical(T.Container{ac0, ac1}, T.ProgressiveBits{}), {==}, equal(T.Container{ac0, ac1}, T.ProgressiveBits{}, public))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.Vector{T.Container{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.Vector{T.Union{ac0}, a1} T.ByteVector{b0}: {==}
    case T.Vector{T.Union{ac0}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.Union{ac0}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.Union{ac0}, a1} T.BitList{b0}: {==}
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.Boolean{}), S.identical(T.Union{ac0}, T.Boolean{}), {==}, equal(T.Union{ac0}, T.Boolean{}, public))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.Unsigned{bc0}), S.identical(T.Union{ac0}, T.Unsigned{bc0}), {==}, equal(T.Union{ac0}, T.Unsigned{bc0}, public))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.ByteVector{bc0}), S.identical(T.Union{ac0}, T.ByteVector{bc0}), {==}, equal(T.Union{ac0}, T.ByteVector{bc0}, public))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.ByteList{bc0}), S.identical(T.Union{ac0}, T.ByteList{bc0}), {==}, equal(T.Union{ac0}, T.ByteList{bc0}, public))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.BitVector{bc0}), S.identical(T.Union{ac0}, T.BitVector{bc0}), {==}, equal(T.Union{ac0}, T.BitVector{bc0}, public))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.BitList{bc0}), S.identical(T.Union{ac0}, T.BitList{bc0}), {==}, equal(T.Union{ac0}, T.BitList{bc0}, public))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.Vector{bc0, bc1}), S.identical(T.Union{ac0}, T.Vector{bc0, bc1}), {==}, equal(T.Union{ac0}, T.Vector{bc0, bc1}, public))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.ListOf{bc0, bc1}), S.identical(T.Union{ac0}, T.ListOf{bc0, bc1}), {==}, equal(T.Union{ac0}, T.ListOf{bc0, bc1}, public))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.Container{bc0, bc1}), S.identical(T.Union{ac0}, T.Container{bc0, bc1}), {==}, equal(T.Union{ac0}, T.Container{bc0, bc1}, public))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.Union{bc0}), S.identical(T.Union{ac0}, T.Union{bc0}), {==}, equal(T.Union{ac0}, T.Union{bc0}, public))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.Null{}), S.identical(T.Union{ac0}, T.Null{}), {==}, equal(T.Union{ac0}, T.Null{}, public))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.Chain{bc0, bc1}), S.identical(T.Union{ac0}, T.Chain{bc0, bc1}), {==}, equal(T.Union{ac0}, T.Chain{bc0, bc1}, public))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.End{}), S.identical(T.Union{ac0}, T.End{}), {==}, equal(T.Union{ac0}, T.End{}, public))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.Repeat{bc0}), S.identical(T.Union{ac0}, T.Repeat{bc0}), {==}, equal(T.Union{ac0}, T.Repeat{bc0}, public))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.Named{bc0, bc1}), S.identical(T.Union{ac0}, T.Named{bc0, bc1}), {==}, equal(T.Union{ac0}, T.Named{bc0, bc1}, public))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.ProgressiveList{bc0}), S.identical(T.Union{ac0}, T.ProgressiveList{bc0}), {==}, equal(T.Union{ac0}, T.ProgressiveList{bc0}, public))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.ProgressiveBits{}), S.identical(T.Union{ac0}, T.ProgressiveBits{}), {==}, equal(T.Union{ac0}, T.ProgressiveBits{}, public))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.Vector{T.Union{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(T.Union{ac0}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.Union{ac0}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.Vector{T.Null{}, a1} T.ByteVector{b0}: {==}
    case T.Vector{T.Null{}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.Null{}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.Null{}, a1} T.BitList{b0}: {==}
    case T.Vector{T.Null{}, a1} T.Vector{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Boolean{}), S.identical(T.Null{}, T.Boolean{}), {==}, equal(T.Null{}, T.Boolean{}, public))
    case T.Vector{T.Null{}, a1} T.Vector{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Unsigned{bc0}), S.identical(T.Null{}, T.Unsigned{bc0}), {==}, equal(T.Null{}, T.Unsigned{bc0}, public))
    case T.Vector{T.Null{}, a1} T.Vector{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ByteVector{bc0}), S.identical(T.Null{}, T.ByteVector{bc0}), {==}, equal(T.Null{}, T.ByteVector{bc0}, public))
    case T.Vector{T.Null{}, a1} T.Vector{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ByteList{bc0}), S.identical(T.Null{}, T.ByteList{bc0}), {==}, equal(T.Null{}, T.ByteList{bc0}, public))
    case T.Vector{T.Null{}, a1} T.Vector{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.BitVector{bc0}), S.identical(T.Null{}, T.BitVector{bc0}), {==}, equal(T.Null{}, T.BitVector{bc0}, public))
    case T.Vector{T.Null{}, a1} T.Vector{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.BitList{bc0}), S.identical(T.Null{}, T.BitList{bc0}), {==}, equal(T.Null{}, T.BitList{bc0}, public))
    case T.Vector{T.Null{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Vector{bc0, bc1}), S.identical(T.Null{}, T.Vector{bc0, bc1}), {==}, equal(T.Null{}, T.Vector{bc0, bc1}, public))
    case T.Vector{T.Null{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ListOf{bc0, bc1}), S.identical(T.Null{}, T.ListOf{bc0, bc1}), {==}, equal(T.Null{}, T.ListOf{bc0, bc1}, public))
    case T.Vector{T.Null{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Container{bc0, bc1}), S.identical(T.Null{}, T.Container{bc0, bc1}), {==}, equal(T.Null{}, T.Container{bc0, bc1}, public))
    case T.Vector{T.Null{}, a1} T.Vector{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Union{bc0}), S.identical(T.Null{}, T.Union{bc0}), {==}, equal(T.Null{}, T.Union{bc0}, public))
    case T.Vector{T.Null{}, a1} T.Vector{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Null{}), S.identical(T.Null{}, T.Null{}), {==}, equal(T.Null{}, T.Null{}, public))
    case T.Vector{T.Null{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Chain{bc0, bc1}), S.identical(T.Null{}, T.Chain{bc0, bc1}), {==}, equal(T.Null{}, T.Chain{bc0, bc1}, public))
    case T.Vector{T.Null{}, a1} T.Vector{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.End{}), S.identical(T.Null{}, T.End{}), {==}, equal(T.Null{}, T.End{}, public))
    case T.Vector{T.Null{}, a1} T.Vector{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Repeat{bc0}), S.identical(T.Null{}, T.Repeat{bc0}), {==}, equal(T.Null{}, T.Repeat{bc0}, public))
    case T.Vector{T.Null{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Named{bc0, bc1}), S.identical(T.Null{}, T.Named{bc0, bc1}), {==}, equal(T.Null{}, T.Named{bc0, bc1}, public))
    case T.Vector{T.Null{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ProgressiveList{bc0}), S.identical(T.Null{}, T.ProgressiveList{bc0}), {==}, equal(T.Null{}, T.ProgressiveList{bc0}, public))
    case T.Vector{T.Null{}, a1} T.Vector{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ProgressiveBits{}), S.identical(T.Null{}, T.ProgressiveBits{}), {==}, equal(T.Null{}, T.ProgressiveBits{}, public))
    case T.Vector{T.Null{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.Vector{T.Null{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.CompatibleUnion{bc0, bc1}), S.identical(T.Null{}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.Null{}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ByteVector{b0}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.BitList{b0}: {==}
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.Boolean{}), S.identical(T.Chain{ac0, ac1}, T.Boolean{}), {==}, equal(T.Chain{ac0, ac1}, T.Boolean{}, public))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.Unsigned{bc0}), S.identical(T.Chain{ac0, ac1}, T.Unsigned{bc0}), {==}, equal(T.Chain{ac0, ac1}, T.Unsigned{bc0}, public))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.ByteVector{bc0}), S.identical(T.Chain{ac0, ac1}, T.ByteVector{bc0}), {==}, equal(T.Chain{ac0, ac1}, T.ByteVector{bc0}, public))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.ByteList{bc0}), S.identical(T.Chain{ac0, ac1}, T.ByteList{bc0}), {==}, equal(T.Chain{ac0, ac1}, T.ByteList{bc0}, public))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.BitVector{bc0}), S.identical(T.Chain{ac0, ac1}, T.BitVector{bc0}), {==}, equal(T.Chain{ac0, ac1}, T.BitVector{bc0}, public))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.BitList{bc0}), S.identical(T.Chain{ac0, ac1}, T.BitList{bc0}), {==}, equal(T.Chain{ac0, ac1}, T.BitList{bc0}, public))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(T.Chain{ac0, ac1}, T.Vector{bc0, bc1}), {==}, equal(T.Chain{ac0, ac1}, T.Vector{bc0, bc1}, public))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}), {==}, equal(T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}, public))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.Container{bc0, bc1}), S.identical(T.Chain{ac0, ac1}, T.Container{bc0, bc1}), {==}, equal(T.Chain{ac0, ac1}, T.Container{bc0, bc1}, public))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.Union{bc0}), S.identical(T.Chain{ac0, ac1}, T.Union{bc0}), {==}, equal(T.Chain{ac0, ac1}, T.Union{bc0}, public))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.Null{}), S.identical(T.Chain{ac0, ac1}, T.Null{}), {==}, equal(T.Chain{ac0, ac1}, T.Null{}, public))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(T.Chain{ac0, ac1}, T.Chain{bc0, bc1}), {==}, equal(T.Chain{ac0, ac1}, T.Chain{bc0, bc1}, public))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.End{}), S.identical(T.Chain{ac0, ac1}, T.End{}), {==}, equal(T.Chain{ac0, ac1}, T.End{}, public))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.Repeat{bc0}), S.identical(T.Chain{ac0, ac1}, T.Repeat{bc0}), {==}, equal(T.Chain{ac0, ac1}, T.Repeat{bc0}, public))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.Named{bc0, bc1}), S.identical(T.Chain{ac0, ac1}, T.Named{bc0, bc1}), {==}, equal(T.Chain{ac0, ac1}, T.Named{bc0, bc1}, public))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(T.Chain{ac0, ac1}, T.ProgressiveList{bc0}), {==}, equal(T.Chain{ac0, ac1}, T.ProgressiveList{bc0}, public))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.ProgressiveBits{}), S.identical(T.Chain{ac0, ac1}, T.ProgressiveBits{}), {==}, equal(T.Chain{ac0, ac1}, T.ProgressiveBits{}, public))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.Vector{T.Chain{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.Vector{T.End{}, a1} T.ByteVector{b0}: {==}
    case T.Vector{T.End{}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.End{}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.End{}, a1} T.BitList{b0}: {==}
    case T.Vector{T.End{}, a1} T.Vector{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.Boolean{}), S.identical(T.End{}, T.Boolean{}), {==}, equal(T.End{}, T.Boolean{}, public))
    case T.Vector{T.End{}, a1} T.Vector{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.Unsigned{bc0}), S.identical(T.End{}, T.Unsigned{bc0}), {==}, equal(T.End{}, T.Unsigned{bc0}, public))
    case T.Vector{T.End{}, a1} T.Vector{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.ByteVector{bc0}), S.identical(T.End{}, T.ByteVector{bc0}), {==}, equal(T.End{}, T.ByteVector{bc0}, public))
    case T.Vector{T.End{}, a1} T.Vector{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.ByteList{bc0}), S.identical(T.End{}, T.ByteList{bc0}), {==}, equal(T.End{}, T.ByteList{bc0}, public))
    case T.Vector{T.End{}, a1} T.Vector{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.BitVector{bc0}), S.identical(T.End{}, T.BitVector{bc0}), {==}, equal(T.End{}, T.BitVector{bc0}, public))
    case T.Vector{T.End{}, a1} T.Vector{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.BitList{bc0}), S.identical(T.End{}, T.BitList{bc0}), {==}, equal(T.End{}, T.BitList{bc0}, public))
    case T.Vector{T.End{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.Vector{bc0, bc1}), S.identical(T.End{}, T.Vector{bc0, bc1}), {==}, equal(T.End{}, T.Vector{bc0, bc1}, public))
    case T.Vector{T.End{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.ListOf{bc0, bc1}), S.identical(T.End{}, T.ListOf{bc0, bc1}), {==}, equal(T.End{}, T.ListOf{bc0, bc1}, public))
    case T.Vector{T.End{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.Container{bc0, bc1}), S.identical(T.End{}, T.Container{bc0, bc1}), {==}, equal(T.End{}, T.Container{bc0, bc1}, public))
    case T.Vector{T.End{}, a1} T.Vector{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.Union{bc0}), S.identical(T.End{}, T.Union{bc0}), {==}, equal(T.End{}, T.Union{bc0}, public))
    case T.Vector{T.End{}, a1} T.Vector{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.Null{}), S.identical(T.End{}, T.Null{}), {==}, equal(T.End{}, T.Null{}, public))
    case T.Vector{T.End{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.Chain{bc0, bc1}), S.identical(T.End{}, T.Chain{bc0, bc1}), {==}, equal(T.End{}, T.Chain{bc0, bc1}, public))
    case T.Vector{T.End{}, a1} T.Vector{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.End{}), S.identical(T.End{}, T.End{}), {==}, equal(T.End{}, T.End{}, public))
    case T.Vector{T.End{}, a1} T.Vector{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.Repeat{bc0}), S.identical(T.End{}, T.Repeat{bc0}), {==}, equal(T.End{}, T.Repeat{bc0}, public))
    case T.Vector{T.End{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.Named{bc0, bc1}), S.identical(T.End{}, T.Named{bc0, bc1}), {==}, equal(T.End{}, T.Named{bc0, bc1}, public))
    case T.Vector{T.End{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.ProgressiveList{bc0}), S.identical(T.End{}, T.ProgressiveList{bc0}), {==}, equal(T.End{}, T.ProgressiveList{bc0}, public))
    case T.Vector{T.End{}, a1} T.Vector{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.ProgressiveBits{}), S.identical(T.End{}, T.ProgressiveBits{}), {==}, equal(T.End{}, T.ProgressiveBits{}, public))
    case T.Vector{T.End{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.Vector{T.End{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.CompatibleUnion{bc0, bc1}), S.identical(T.End{}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.End{}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.Vector{T.Repeat{ac0}, a1} T.ByteVector{b0}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.BitList{b0}: {==}
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.Boolean{}), S.identical(T.Repeat{ac0}, T.Boolean{}), {==}, equal(T.Repeat{ac0}, T.Boolean{}, public))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.Unsigned{bc0}), S.identical(T.Repeat{ac0}, T.Unsigned{bc0}), {==}, equal(T.Repeat{ac0}, T.Unsigned{bc0}, public))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.ByteVector{bc0}), S.identical(T.Repeat{ac0}, T.ByteVector{bc0}), {==}, equal(T.Repeat{ac0}, T.ByteVector{bc0}, public))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.ByteList{bc0}), S.identical(T.Repeat{ac0}, T.ByteList{bc0}), {==}, equal(T.Repeat{ac0}, T.ByteList{bc0}, public))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.BitVector{bc0}), S.identical(T.Repeat{ac0}, T.BitVector{bc0}), {==}, equal(T.Repeat{ac0}, T.BitVector{bc0}, public))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.BitList{bc0}), S.identical(T.Repeat{ac0}, T.BitList{bc0}), {==}, equal(T.Repeat{ac0}, T.BitList{bc0}, public))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.Vector{bc0, bc1}), S.identical(T.Repeat{ac0}, T.Vector{bc0, bc1}), {==}, equal(T.Repeat{ac0}, T.Vector{bc0, bc1}, public))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.ListOf{bc0, bc1}), S.identical(T.Repeat{ac0}, T.ListOf{bc0, bc1}), {==}, equal(T.Repeat{ac0}, T.ListOf{bc0, bc1}, public))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.Container{bc0, bc1}), S.identical(T.Repeat{ac0}, T.Container{bc0, bc1}), {==}, equal(T.Repeat{ac0}, T.Container{bc0, bc1}, public))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.Union{bc0}), S.identical(T.Repeat{ac0}, T.Union{bc0}), {==}, equal(T.Repeat{ac0}, T.Union{bc0}, public))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.Null{}), S.identical(T.Repeat{ac0}, T.Null{}), {==}, equal(T.Repeat{ac0}, T.Null{}, public))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.Chain{bc0, bc1}), S.identical(T.Repeat{ac0}, T.Chain{bc0, bc1}), {==}, equal(T.Repeat{ac0}, T.Chain{bc0, bc1}, public))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.End{}), S.identical(T.Repeat{ac0}, T.End{}), {==}, equal(T.Repeat{ac0}, T.End{}, public))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.Repeat{bc0}), S.identical(T.Repeat{ac0}, T.Repeat{bc0}), {==}, equal(T.Repeat{ac0}, T.Repeat{bc0}, public))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.Named{bc0, bc1}), S.identical(T.Repeat{ac0}, T.Named{bc0, bc1}), {==}, equal(T.Repeat{ac0}, T.Named{bc0, bc1}, public))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.ProgressiveList{bc0}), S.identical(T.Repeat{ac0}, T.ProgressiveList{bc0}), {==}, equal(T.Repeat{ac0}, T.ProgressiveList{bc0}, public))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.ProgressiveBits{}), S.identical(T.Repeat{ac0}, T.ProgressiveBits{}), {==}, equal(T.Repeat{ac0}, T.ProgressiveBits{}, public))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.Vector{T.Repeat{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.Vector{T.Named{ac0, ac1}, a1} T.ByteVector{b0}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.BitList{b0}: {==}
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.Boolean{}), S.identical(T.Named{ac0, ac1}, T.Boolean{}), {==}, equal(T.Named{ac0, ac1}, T.Boolean{}, public))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.Unsigned{bc0}), S.identical(T.Named{ac0, ac1}, T.Unsigned{bc0}), {==}, equal(T.Named{ac0, ac1}, T.Unsigned{bc0}, public))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.ByteVector{bc0}), S.identical(T.Named{ac0, ac1}, T.ByteVector{bc0}), {==}, equal(T.Named{ac0, ac1}, T.ByteVector{bc0}, public))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.ByteList{bc0}), S.identical(T.Named{ac0, ac1}, T.ByteList{bc0}), {==}, equal(T.Named{ac0, ac1}, T.ByteList{bc0}, public))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.BitVector{bc0}), S.identical(T.Named{ac0, ac1}, T.BitVector{bc0}), {==}, equal(T.Named{ac0, ac1}, T.BitVector{bc0}, public))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.BitList{bc0}), S.identical(T.Named{ac0, ac1}, T.BitList{bc0}), {==}, equal(T.Named{ac0, ac1}, T.BitList{bc0}, public))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(T.Named{ac0, ac1}, T.Vector{bc0, bc1}), {==}, equal(T.Named{ac0, ac1}, T.Vector{bc0, bc1}, public))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(T.Named{ac0, ac1}, T.ListOf{bc0, bc1}), {==}, equal(T.Named{ac0, ac1}, T.ListOf{bc0, bc1}, public))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.Container{bc0, bc1}), S.identical(T.Named{ac0, ac1}, T.Container{bc0, bc1}), {==}, equal(T.Named{ac0, ac1}, T.Container{bc0, bc1}, public))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.Union{bc0}), S.identical(T.Named{ac0, ac1}, T.Union{bc0}), {==}, equal(T.Named{ac0, ac1}, T.Union{bc0}, public))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.Null{}), S.identical(T.Named{ac0, ac1}, T.Null{}), {==}, equal(T.Named{ac0, ac1}, T.Null{}, public))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(T.Named{ac0, ac1}, T.Chain{bc0, bc1}), {==}, equal(T.Named{ac0, ac1}, T.Chain{bc0, bc1}, public))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.End{}), S.identical(T.Named{ac0, ac1}, T.End{}), {==}, equal(T.Named{ac0, ac1}, T.End{}, public))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.Repeat{bc0}), S.identical(T.Named{ac0, ac1}, T.Repeat{bc0}), {==}, equal(T.Named{ac0, ac1}, T.Repeat{bc0}, public))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.Named{bc0, bc1}), S.identical(T.Named{ac0, ac1}, T.Named{bc0, bc1}), {==}, equal(T.Named{ac0, ac1}, T.Named{bc0, bc1}, public))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(T.Named{ac0, ac1}, T.ProgressiveList{bc0}), {==}, equal(T.Named{ac0, ac1}, T.ProgressiveList{bc0}, public))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.ProgressiveBits{}), S.identical(T.Named{ac0, ac1}, T.ProgressiveBits{}), {==}, equal(T.Named{ac0, ac1}, T.ProgressiveBits{}, public))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.Vector{T.Named{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ByteVector{b0}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.BitList{b0}: {==}
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.Boolean{}), S.identical(T.ProgressiveList{ac0}, T.Boolean{}), {==}, equal(T.ProgressiveList{ac0}, T.Boolean{}, public))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.Unsigned{bc0}), S.identical(T.ProgressiveList{ac0}, T.Unsigned{bc0}), {==}, equal(T.ProgressiveList{ac0}, T.Unsigned{bc0}, public))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.ByteVector{bc0}), S.identical(T.ProgressiveList{ac0}, T.ByteVector{bc0}), {==}, equal(T.ProgressiveList{ac0}, T.ByteVector{bc0}, public))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.ByteList{bc0}), S.identical(T.ProgressiveList{ac0}, T.ByteList{bc0}), {==}, equal(T.ProgressiveList{ac0}, T.ByteList{bc0}, public))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.BitVector{bc0}), S.identical(T.ProgressiveList{ac0}, T.BitVector{bc0}), {==}, equal(T.ProgressiveList{ac0}, T.BitVector{bc0}, public))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.BitList{bc0}), S.identical(T.ProgressiveList{ac0}, T.BitList{bc0}), {==}, equal(T.ProgressiveList{ac0}, T.BitList{bc0}, public))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.Vector{bc0, bc1}), S.identical(T.ProgressiveList{ac0}, T.Vector{bc0, bc1}), {==}, equal(T.ProgressiveList{ac0}, T.Vector{bc0, bc1}, public))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}), S.identical(T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}), {==}, equal(T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}, public))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.Container{bc0, bc1}), S.identical(T.ProgressiveList{ac0}, T.Container{bc0, bc1}), {==}, equal(T.ProgressiveList{ac0}, T.Container{bc0, bc1}, public))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.Union{bc0}), S.identical(T.ProgressiveList{ac0}, T.Union{bc0}), {==}, equal(T.ProgressiveList{ac0}, T.Union{bc0}, public))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.Null{}), S.identical(T.ProgressiveList{ac0}, T.Null{}), {==}, equal(T.ProgressiveList{ac0}, T.Null{}, public))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.Chain{bc0, bc1}), S.identical(T.ProgressiveList{ac0}, T.Chain{bc0, bc1}), {==}, equal(T.ProgressiveList{ac0}, T.Chain{bc0, bc1}, public))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.End{}), S.identical(T.ProgressiveList{ac0}, T.End{}), {==}, equal(T.ProgressiveList{ac0}, T.End{}, public))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.Repeat{bc0}), S.identical(T.ProgressiveList{ac0}, T.Repeat{bc0}), {==}, equal(T.ProgressiveList{ac0}, T.Repeat{bc0}, public))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.Named{bc0, bc1}), S.identical(T.ProgressiveList{ac0}, T.Named{bc0, bc1}), {==}, equal(T.ProgressiveList{ac0}, T.Named{bc0, bc1}, public))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.ProgressiveList{bc0}), S.identical(T.ProgressiveList{ac0}, T.ProgressiveList{bc0}), {==}, equal(T.ProgressiveList{ac0}, T.ProgressiveList{bc0}, public))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.ProgressiveBits{}), S.identical(T.ProgressiveList{ac0}, T.ProgressiveBits{}), {==}, equal(T.ProgressiveList{ac0}, T.ProgressiveBits{}, public))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.Vector{T.ProgressiveList{ac0}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.Vector{T.ProgressiveBits{}, a1} T.ByteVector{b0}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.BitList{b0}: {==}
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Boolean{}), S.identical(T.ProgressiveBits{}, T.Boolean{}), {==}, equal(T.ProgressiveBits{}, T.Boolean{}, public))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Unsigned{bc0}), S.identical(T.ProgressiveBits{}, T.Unsigned{bc0}), {==}, equal(T.ProgressiveBits{}, T.Unsigned{bc0}, public))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ByteVector{bc0}), S.identical(T.ProgressiveBits{}, T.ByteVector{bc0}), {==}, equal(T.ProgressiveBits{}, T.ByteVector{bc0}, public))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ByteList{bc0}), S.identical(T.ProgressiveBits{}, T.ByteList{bc0}), {==}, equal(T.ProgressiveBits{}, T.ByteList{bc0}, public))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.BitVector{bc0}), S.identical(T.ProgressiveBits{}, T.BitVector{bc0}), {==}, equal(T.ProgressiveBits{}, T.BitVector{bc0}, public))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.BitList{bc0}), S.identical(T.ProgressiveBits{}, T.BitList{bc0}), {==}, equal(T.ProgressiveBits{}, T.BitList{bc0}, public))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Vector{bc0, bc1}), S.identical(T.ProgressiveBits{}, T.Vector{bc0, bc1}), {==}, equal(T.ProgressiveBits{}, T.Vector{bc0, bc1}, public))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ListOf{bc0, bc1}), S.identical(T.ProgressiveBits{}, T.ListOf{bc0, bc1}), {==}, equal(T.ProgressiveBits{}, T.ListOf{bc0, bc1}, public))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Container{bc0, bc1}), S.identical(T.ProgressiveBits{}, T.Container{bc0, bc1}), {==}, equal(T.ProgressiveBits{}, T.Container{bc0, bc1}, public))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Union{bc0}), S.identical(T.ProgressiveBits{}, T.Union{bc0}), {==}, equal(T.ProgressiveBits{}, T.Union{bc0}, public))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Null{}), S.identical(T.ProgressiveBits{}, T.Null{}), {==}, equal(T.ProgressiveBits{}, T.Null{}, public))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Chain{bc0, bc1}), S.identical(T.ProgressiveBits{}, T.Chain{bc0, bc1}), {==}, equal(T.ProgressiveBits{}, T.Chain{bc0, bc1}, public))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.End{}), S.identical(T.ProgressiveBits{}, T.End{}), {==}, equal(T.ProgressiveBits{}, T.End{}, public))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Repeat{bc0}), S.identical(T.ProgressiveBits{}, T.Repeat{bc0}), {==}, equal(T.ProgressiveBits{}, T.Repeat{bc0}, public))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Named{bc0, bc1}), S.identical(T.ProgressiveBits{}, T.Named{bc0, bc1}), {==}, equal(T.ProgressiveBits{}, T.Named{bc0, bc1}, public))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ProgressiveList{bc0}), S.identical(T.ProgressiveBits{}, T.ProgressiveList{bc0}), {==}, equal(T.ProgressiveBits{}, T.ProgressiveList{bc0}, public))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ProgressiveBits{}), S.identical(T.ProgressiveBits{}, T.ProgressiveBits{}), {==}, equal(T.ProgressiveBits{}, T.ProgressiveBits{}, public))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.Vector{T.ProgressiveBits{}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}), S.identical(T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ByteVector{b0}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.BitList{b0}: {==}
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}, public))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}, public))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}, public))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}, public))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}, public))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}, public))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}, public))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}, public))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}, public))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}, public))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}, public))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}, public))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}, public))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}, public))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}, public))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}, public))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}, public))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.Vector{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ByteVector{b0}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.ByteList{b0}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.BitVector{b0}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.BitList{b0}: {==}
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.Boolean{}), S.identical(T.CompatibleUnion{ac0, ac1}, T.Boolean{}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.Boolean{}, public))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}), S.identical(T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}, public))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}), S.identical(T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}, public))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}), S.identical(T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}, public))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}), S.identical(T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}, public))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}), S.identical(T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}, public))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}, public))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}, public))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}), S.identical(T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}, public))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.Union{bc0}), S.identical(T.CompatibleUnion{ac0, ac1}, T.Union{bc0}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.Union{bc0}, public))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.Null{}), S.identical(T.CompatibleUnion{ac0, ac1}, T.Null{}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.Null{}, public))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}, public))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.End{}), S.identical(T.CompatibleUnion{ac0, ac1}, T.End{}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.End{}, public))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}), S.identical(T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}, public))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}), S.identical(T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}, public))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}, public))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}, public))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.Vector{T.CompatibleUnion{ac0, ac1}, a1} T.Vector{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.ListOf{T.Boolean{}, a1} T.ByteList{b0}: {==}
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
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Boolean{}), S.identical(T.Boolean{}, T.Boolean{}), {==}, equal(T.Boolean{}, T.Boolean{}, public))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Unsigned{bc0}), S.identical(T.Boolean{}, T.Unsigned{bc0}), {==}, equal(T.Boolean{}, T.Unsigned{bc0}, public))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ByteVector{bc0}), S.identical(T.Boolean{}, T.ByteVector{bc0}), {==}, equal(T.Boolean{}, T.ByteVector{bc0}, public))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ByteList{bc0}), S.identical(T.Boolean{}, T.ByteList{bc0}), {==}, equal(T.Boolean{}, T.ByteList{bc0}, public))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.BitVector{bc0}), S.identical(T.Boolean{}, T.BitVector{bc0}), {==}, equal(T.Boolean{}, T.BitVector{bc0}, public))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.BitList{bc0}), S.identical(T.Boolean{}, T.BitList{bc0}), {==}, equal(T.Boolean{}, T.BitList{bc0}, public))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Vector{bc0, bc1}), S.identical(T.Boolean{}, T.Vector{bc0, bc1}), {==}, equal(T.Boolean{}, T.Vector{bc0, bc1}, public))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ListOf{bc0, bc1}), S.identical(T.Boolean{}, T.ListOf{bc0, bc1}), {==}, equal(T.Boolean{}, T.ListOf{bc0, bc1}, public))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Container{bc0, bc1}), S.identical(T.Boolean{}, T.Container{bc0, bc1}), {==}, equal(T.Boolean{}, T.Container{bc0, bc1}, public))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Union{bc0}), S.identical(T.Boolean{}, T.Union{bc0}), {==}, equal(T.Boolean{}, T.Union{bc0}, public))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Null{}), S.identical(T.Boolean{}, T.Null{}), {==}, equal(T.Boolean{}, T.Null{}, public))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Chain{bc0, bc1}), S.identical(T.Boolean{}, T.Chain{bc0, bc1}), {==}, equal(T.Boolean{}, T.Chain{bc0, bc1}, public))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.End{}), S.identical(T.Boolean{}, T.End{}), {==}, equal(T.Boolean{}, T.End{}, public))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Repeat{bc0}), S.identical(T.Boolean{}, T.Repeat{bc0}), {==}, equal(T.Boolean{}, T.Repeat{bc0}, public))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.Named{bc0, bc1}), S.identical(T.Boolean{}, T.Named{bc0, bc1}), {==}, equal(T.Boolean{}, T.Named{bc0, bc1}, public))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ProgressiveList{bc0}), S.identical(T.Boolean{}, T.ProgressiveList{bc0}), {==}, equal(T.Boolean{}, T.ProgressiveList{bc0}, public))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ProgressiveBits{}), S.identical(T.Boolean{}, T.ProgressiveBits{}), {==}, equal(T.Boolean{}, T.ProgressiveBits{}, public))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.Boolean{}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.ListOf{T.Boolean{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Boolean{}, T.CompatibleUnion{bc0, bc1}), S.identical(T.Boolean{}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.Boolean{}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.ListOf{T.Unsigned{ac0}, a1} T.ByteList{b0}: %P.width_correct(ac0) : {Bool.and(Nat.is_eq(a1, b0), Nat.is_eq(IP.width(ac0), 1n)) == Bool.and(Nat.is_eq(a1, b0), Nat.is_eq(_, 1n)) : Bool}
      {==}
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
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.Boolean{}), S.identical(T.Unsigned{ac0}, T.Boolean{}), {==}, equal(T.Unsigned{ac0}, T.Boolean{}, public))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.Unsigned{bc0}), S.identical(T.Unsigned{ac0}, T.Unsigned{bc0}), {==}, equal(T.Unsigned{ac0}, T.Unsigned{bc0}, public))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.ByteVector{bc0}), S.identical(T.Unsigned{ac0}, T.ByteVector{bc0}), {==}, equal(T.Unsigned{ac0}, T.ByteVector{bc0}, public))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.ByteList{bc0}), S.identical(T.Unsigned{ac0}, T.ByteList{bc0}), {==}, equal(T.Unsigned{ac0}, T.ByteList{bc0}, public))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.BitVector{bc0}), S.identical(T.Unsigned{ac0}, T.BitVector{bc0}), {==}, equal(T.Unsigned{ac0}, T.BitVector{bc0}, public))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.BitList{bc0}), S.identical(T.Unsigned{ac0}, T.BitList{bc0}), {==}, equal(T.Unsigned{ac0}, T.BitList{bc0}, public))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.Vector{bc0, bc1}), S.identical(T.Unsigned{ac0}, T.Vector{bc0, bc1}), {==}, equal(T.Unsigned{ac0}, T.Vector{bc0, bc1}, public))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.ListOf{bc0, bc1}), S.identical(T.Unsigned{ac0}, T.ListOf{bc0, bc1}), {==}, equal(T.Unsigned{ac0}, T.ListOf{bc0, bc1}, public))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.Container{bc0, bc1}), S.identical(T.Unsigned{ac0}, T.Container{bc0, bc1}), {==}, equal(T.Unsigned{ac0}, T.Container{bc0, bc1}, public))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.Union{bc0}), S.identical(T.Unsigned{ac0}, T.Union{bc0}), {==}, equal(T.Unsigned{ac0}, T.Union{bc0}, public))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.Null{}), S.identical(T.Unsigned{ac0}, T.Null{}), {==}, equal(T.Unsigned{ac0}, T.Null{}, public))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.Chain{bc0, bc1}), S.identical(T.Unsigned{ac0}, T.Chain{bc0, bc1}), {==}, equal(T.Unsigned{ac0}, T.Chain{bc0, bc1}, public))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.End{}), S.identical(T.Unsigned{ac0}, T.End{}), {==}, equal(T.Unsigned{ac0}, T.End{}, public))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.Repeat{bc0}), S.identical(T.Unsigned{ac0}, T.Repeat{bc0}), {==}, equal(T.Unsigned{ac0}, T.Repeat{bc0}, public))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.Named{bc0, bc1}), S.identical(T.Unsigned{ac0}, T.Named{bc0, bc1}), {==}, equal(T.Unsigned{ac0}, T.Named{bc0, bc1}, public))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.ProgressiveList{bc0}), S.identical(T.Unsigned{ac0}, T.ProgressiveList{bc0}), {==}, equal(T.Unsigned{ac0}, T.ProgressiveList{bc0}, public))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.ProgressiveBits{}), S.identical(T.Unsigned{ac0}, T.ProgressiveBits{}), {==}, equal(T.Unsigned{ac0}, T.ProgressiveBits{}, public))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.Unsigned{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.ListOf{T.Unsigned{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.Unsigned{ac0}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.ListOf{T.ByteVector{ac0}, a1} T.ByteList{b0}: {==}
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
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.Boolean{}), S.identical(T.ByteVector{ac0}, T.Boolean{}), {==}, equal(T.ByteVector{ac0}, T.Boolean{}, public))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.Unsigned{bc0}), S.identical(T.ByteVector{ac0}, T.Unsigned{bc0}), {==}, equal(T.ByteVector{ac0}, T.Unsigned{bc0}, public))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.ByteVector{bc0}), S.identical(T.ByteVector{ac0}, T.ByteVector{bc0}), {==}, equal(T.ByteVector{ac0}, T.ByteVector{bc0}, public))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.ByteList{bc0}), S.identical(T.ByteVector{ac0}, T.ByteList{bc0}), {==}, equal(T.ByteVector{ac0}, T.ByteList{bc0}, public))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.BitVector{bc0}), S.identical(T.ByteVector{ac0}, T.BitVector{bc0}), {==}, equal(T.ByteVector{ac0}, T.BitVector{bc0}, public))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.BitList{bc0}), S.identical(T.ByteVector{ac0}, T.BitList{bc0}), {==}, equal(T.ByteVector{ac0}, T.BitList{bc0}, public))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.Vector{bc0, bc1}), S.identical(T.ByteVector{ac0}, T.Vector{bc0, bc1}), {==}, equal(T.ByteVector{ac0}, T.Vector{bc0, bc1}, public))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.ListOf{bc0, bc1}), S.identical(T.ByteVector{ac0}, T.ListOf{bc0, bc1}), {==}, equal(T.ByteVector{ac0}, T.ListOf{bc0, bc1}, public))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.Container{bc0, bc1}), S.identical(T.ByteVector{ac0}, T.Container{bc0, bc1}), {==}, equal(T.ByteVector{ac0}, T.Container{bc0, bc1}, public))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.Union{bc0}), S.identical(T.ByteVector{ac0}, T.Union{bc0}), {==}, equal(T.ByteVector{ac0}, T.Union{bc0}, public))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.Null{}), S.identical(T.ByteVector{ac0}, T.Null{}), {==}, equal(T.ByteVector{ac0}, T.Null{}, public))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.Chain{bc0, bc1}), S.identical(T.ByteVector{ac0}, T.Chain{bc0, bc1}), {==}, equal(T.ByteVector{ac0}, T.Chain{bc0, bc1}, public))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.End{}), S.identical(T.ByteVector{ac0}, T.End{}), {==}, equal(T.ByteVector{ac0}, T.End{}, public))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.Repeat{bc0}), S.identical(T.ByteVector{ac0}, T.Repeat{bc0}), {==}, equal(T.ByteVector{ac0}, T.Repeat{bc0}, public))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.Named{bc0, bc1}), S.identical(T.ByteVector{ac0}, T.Named{bc0, bc1}), {==}, equal(T.ByteVector{ac0}, T.Named{bc0, bc1}, public))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.ProgressiveList{bc0}), S.identical(T.ByteVector{ac0}, T.ProgressiveList{bc0}), {==}, equal(T.ByteVector{ac0}, T.ProgressiveList{bc0}, public))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.ProgressiveBits{}), S.identical(T.ByteVector{ac0}, T.ProgressiveBits{}), {==}, equal(T.ByteVector{ac0}, T.ProgressiveBits{}, public))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.ByteVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.ListOf{T.ByteVector{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.ByteVector{ac0}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.ListOf{T.ByteList{ac0}, a1} T.ByteList{b0}: {==}
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
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.Boolean{}), S.identical(T.ByteList{ac0}, T.Boolean{}), {==}, equal(T.ByteList{ac0}, T.Boolean{}, public))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.Unsigned{bc0}), S.identical(T.ByteList{ac0}, T.Unsigned{bc0}), {==}, equal(T.ByteList{ac0}, T.Unsigned{bc0}, public))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.ByteVector{bc0}), S.identical(T.ByteList{ac0}, T.ByteVector{bc0}), {==}, equal(T.ByteList{ac0}, T.ByteVector{bc0}, public))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.ByteList{bc0}), S.identical(T.ByteList{ac0}, T.ByteList{bc0}), {==}, equal(T.ByteList{ac0}, T.ByteList{bc0}, public))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.BitVector{bc0}), S.identical(T.ByteList{ac0}, T.BitVector{bc0}), {==}, equal(T.ByteList{ac0}, T.BitVector{bc0}, public))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.BitList{bc0}), S.identical(T.ByteList{ac0}, T.BitList{bc0}), {==}, equal(T.ByteList{ac0}, T.BitList{bc0}, public))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.Vector{bc0, bc1}), S.identical(T.ByteList{ac0}, T.Vector{bc0, bc1}), {==}, equal(T.ByteList{ac0}, T.Vector{bc0, bc1}, public))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.ListOf{bc0, bc1}), S.identical(T.ByteList{ac0}, T.ListOf{bc0, bc1}), {==}, equal(T.ByteList{ac0}, T.ListOf{bc0, bc1}, public))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.Container{bc0, bc1}), S.identical(T.ByteList{ac0}, T.Container{bc0, bc1}), {==}, equal(T.ByteList{ac0}, T.Container{bc0, bc1}, public))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.Union{bc0}), S.identical(T.ByteList{ac0}, T.Union{bc0}), {==}, equal(T.ByteList{ac0}, T.Union{bc0}, public))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.Null{}), S.identical(T.ByteList{ac0}, T.Null{}), {==}, equal(T.ByteList{ac0}, T.Null{}, public))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.Chain{bc0, bc1}), S.identical(T.ByteList{ac0}, T.Chain{bc0, bc1}), {==}, equal(T.ByteList{ac0}, T.Chain{bc0, bc1}, public))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.End{}), S.identical(T.ByteList{ac0}, T.End{}), {==}, equal(T.ByteList{ac0}, T.End{}, public))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.Repeat{bc0}), S.identical(T.ByteList{ac0}, T.Repeat{bc0}), {==}, equal(T.ByteList{ac0}, T.Repeat{bc0}, public))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.Named{bc0, bc1}), S.identical(T.ByteList{ac0}, T.Named{bc0, bc1}), {==}, equal(T.ByteList{ac0}, T.Named{bc0, bc1}, public))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.ProgressiveList{bc0}), S.identical(T.ByteList{ac0}, T.ProgressiveList{bc0}), {==}, equal(T.ByteList{ac0}, T.ProgressiveList{bc0}, public))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.ProgressiveBits{}), S.identical(T.ByteList{ac0}, T.ProgressiveBits{}), {==}, equal(T.ByteList{ac0}, T.ProgressiveBits{}, public))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.ByteList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.ListOf{T.ByteList{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.ByteList{ac0}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.ListOf{T.BitVector{ac0}, a1} T.ByteList{b0}: {==}
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
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.Boolean{}), S.identical(T.BitVector{ac0}, T.Boolean{}), {==}, equal(T.BitVector{ac0}, T.Boolean{}, public))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.Unsigned{bc0}), S.identical(T.BitVector{ac0}, T.Unsigned{bc0}), {==}, equal(T.BitVector{ac0}, T.Unsigned{bc0}, public))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.ByteVector{bc0}), S.identical(T.BitVector{ac0}, T.ByteVector{bc0}), {==}, equal(T.BitVector{ac0}, T.ByteVector{bc0}, public))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.ByteList{bc0}), S.identical(T.BitVector{ac0}, T.ByteList{bc0}), {==}, equal(T.BitVector{ac0}, T.ByteList{bc0}, public))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.BitVector{bc0}), S.identical(T.BitVector{ac0}, T.BitVector{bc0}), {==}, equal(T.BitVector{ac0}, T.BitVector{bc0}, public))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.BitList{bc0}), S.identical(T.BitVector{ac0}, T.BitList{bc0}), {==}, equal(T.BitVector{ac0}, T.BitList{bc0}, public))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.Vector{bc0, bc1}), S.identical(T.BitVector{ac0}, T.Vector{bc0, bc1}), {==}, equal(T.BitVector{ac0}, T.Vector{bc0, bc1}, public))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.ListOf{bc0, bc1}), S.identical(T.BitVector{ac0}, T.ListOf{bc0, bc1}), {==}, equal(T.BitVector{ac0}, T.ListOf{bc0, bc1}, public))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.Container{bc0, bc1}), S.identical(T.BitVector{ac0}, T.Container{bc0, bc1}), {==}, equal(T.BitVector{ac0}, T.Container{bc0, bc1}, public))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.Union{bc0}), S.identical(T.BitVector{ac0}, T.Union{bc0}), {==}, equal(T.BitVector{ac0}, T.Union{bc0}, public))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.Null{}), S.identical(T.BitVector{ac0}, T.Null{}), {==}, equal(T.BitVector{ac0}, T.Null{}, public))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.Chain{bc0, bc1}), S.identical(T.BitVector{ac0}, T.Chain{bc0, bc1}), {==}, equal(T.BitVector{ac0}, T.Chain{bc0, bc1}, public))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.End{}), S.identical(T.BitVector{ac0}, T.End{}), {==}, equal(T.BitVector{ac0}, T.End{}, public))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.Repeat{bc0}), S.identical(T.BitVector{ac0}, T.Repeat{bc0}), {==}, equal(T.BitVector{ac0}, T.Repeat{bc0}, public))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.Named{bc0, bc1}), S.identical(T.BitVector{ac0}, T.Named{bc0, bc1}), {==}, equal(T.BitVector{ac0}, T.Named{bc0, bc1}, public))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.ProgressiveList{bc0}), S.identical(T.BitVector{ac0}, T.ProgressiveList{bc0}), {==}, equal(T.BitVector{ac0}, T.ProgressiveList{bc0}, public))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.ProgressiveBits{}), S.identical(T.BitVector{ac0}, T.ProgressiveBits{}), {==}, equal(T.BitVector{ac0}, T.ProgressiveBits{}, public))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.BitVector{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.ListOf{T.BitVector{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.BitVector{ac0}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.ListOf{T.BitList{ac0}, a1} T.ByteList{b0}: {==}
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
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.Boolean{}), S.identical(T.BitList{ac0}, T.Boolean{}), {==}, equal(T.BitList{ac0}, T.Boolean{}, public))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.Unsigned{bc0}), S.identical(T.BitList{ac0}, T.Unsigned{bc0}), {==}, equal(T.BitList{ac0}, T.Unsigned{bc0}, public))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.ByteVector{bc0}), S.identical(T.BitList{ac0}, T.ByteVector{bc0}), {==}, equal(T.BitList{ac0}, T.ByteVector{bc0}, public))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.ByteList{bc0}), S.identical(T.BitList{ac0}, T.ByteList{bc0}), {==}, equal(T.BitList{ac0}, T.ByteList{bc0}, public))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.BitVector{bc0}), S.identical(T.BitList{ac0}, T.BitVector{bc0}), {==}, equal(T.BitList{ac0}, T.BitVector{bc0}, public))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.BitList{bc0}), S.identical(T.BitList{ac0}, T.BitList{bc0}), {==}, equal(T.BitList{ac0}, T.BitList{bc0}, public))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.Vector{bc0, bc1}), S.identical(T.BitList{ac0}, T.Vector{bc0, bc1}), {==}, equal(T.BitList{ac0}, T.Vector{bc0, bc1}, public))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.ListOf{bc0, bc1}), S.identical(T.BitList{ac0}, T.ListOf{bc0, bc1}), {==}, equal(T.BitList{ac0}, T.ListOf{bc0, bc1}, public))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.Container{bc0, bc1}), S.identical(T.BitList{ac0}, T.Container{bc0, bc1}), {==}, equal(T.BitList{ac0}, T.Container{bc0, bc1}, public))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.Union{bc0}), S.identical(T.BitList{ac0}, T.Union{bc0}), {==}, equal(T.BitList{ac0}, T.Union{bc0}, public))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.Null{}), S.identical(T.BitList{ac0}, T.Null{}), {==}, equal(T.BitList{ac0}, T.Null{}, public))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.Chain{bc0, bc1}), S.identical(T.BitList{ac0}, T.Chain{bc0, bc1}), {==}, equal(T.BitList{ac0}, T.Chain{bc0, bc1}, public))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.End{}), S.identical(T.BitList{ac0}, T.End{}), {==}, equal(T.BitList{ac0}, T.End{}, public))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.Repeat{bc0}), S.identical(T.BitList{ac0}, T.Repeat{bc0}), {==}, equal(T.BitList{ac0}, T.Repeat{bc0}, public))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.Named{bc0, bc1}), S.identical(T.BitList{ac0}, T.Named{bc0, bc1}), {==}, equal(T.BitList{ac0}, T.Named{bc0, bc1}, public))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.ProgressiveList{bc0}), S.identical(T.BitList{ac0}, T.ProgressiveList{bc0}), {==}, equal(T.BitList{ac0}, T.ProgressiveList{bc0}, public))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.ProgressiveBits{}), S.identical(T.BitList{ac0}, T.ProgressiveBits{}), {==}, equal(T.BitList{ac0}, T.ProgressiveBits{}, public))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.BitList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.ListOf{T.BitList{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.BitList{ac0}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ByteList{b0}: {==}
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
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.Boolean{}), S.identical(T.Vector{ac0, ac1}, T.Boolean{}), {==}, equal(T.Vector{ac0, ac1}, T.Boolean{}, public))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.Unsigned{bc0}), S.identical(T.Vector{ac0, ac1}, T.Unsigned{bc0}), {==}, equal(T.Vector{ac0, ac1}, T.Unsigned{bc0}, public))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.ByteVector{bc0}), S.identical(T.Vector{ac0, ac1}, T.ByteVector{bc0}), {==}, equal(T.Vector{ac0, ac1}, T.ByteVector{bc0}, public))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.ByteList{bc0}), S.identical(T.Vector{ac0, ac1}, T.ByteList{bc0}), {==}, equal(T.Vector{ac0, ac1}, T.ByteList{bc0}, public))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.BitVector{bc0}), S.identical(T.Vector{ac0, ac1}, T.BitVector{bc0}), {==}, equal(T.Vector{ac0, ac1}, T.BitVector{bc0}, public))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.BitList{bc0}), S.identical(T.Vector{ac0, ac1}, T.BitList{bc0}), {==}, equal(T.Vector{ac0, ac1}, T.BitList{bc0}, public))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(T.Vector{ac0, ac1}, T.Vector{bc0, bc1}), {==}, equal(T.Vector{ac0, ac1}, T.Vector{bc0, bc1}, public))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}), {==}, equal(T.Vector{ac0, ac1}, T.ListOf{bc0, bc1}, public))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.Container{bc0, bc1}), S.identical(T.Vector{ac0, ac1}, T.Container{bc0, bc1}), {==}, equal(T.Vector{ac0, ac1}, T.Container{bc0, bc1}, public))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.Union{bc0}), S.identical(T.Vector{ac0, ac1}, T.Union{bc0}), {==}, equal(T.Vector{ac0, ac1}, T.Union{bc0}, public))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.Null{}), S.identical(T.Vector{ac0, ac1}, T.Null{}), {==}, equal(T.Vector{ac0, ac1}, T.Null{}, public))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(T.Vector{ac0, ac1}, T.Chain{bc0, bc1}), {==}, equal(T.Vector{ac0, ac1}, T.Chain{bc0, bc1}, public))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.End{}), S.identical(T.Vector{ac0, ac1}, T.End{}), {==}, equal(T.Vector{ac0, ac1}, T.End{}, public))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.Repeat{bc0}), S.identical(T.Vector{ac0, ac1}, T.Repeat{bc0}), {==}, equal(T.Vector{ac0, ac1}, T.Repeat{bc0}, public))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.Named{bc0, bc1}), S.identical(T.Vector{ac0, ac1}, T.Named{bc0, bc1}), {==}, equal(T.Vector{ac0, ac1}, T.Named{bc0, bc1}, public))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(T.Vector{ac0, ac1}, T.ProgressiveList{bc0}), {==}, equal(T.Vector{ac0, ac1}, T.ProgressiveList{bc0}, public))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.ProgressiveBits{}), S.identical(T.Vector{ac0, ac1}, T.ProgressiveBits{}), {==}, equal(T.Vector{ac0, ac1}, T.ProgressiveBits{}, public))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.Vector{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.ListOf{T.Vector{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.Vector{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ByteList{b0}: {==}
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
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.Boolean{}), S.identical(T.ListOf{ac0, ac1}, T.Boolean{}), {==}, equal(T.ListOf{ac0, ac1}, T.Boolean{}, public))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.Unsigned{bc0}), S.identical(T.ListOf{ac0, ac1}, T.Unsigned{bc0}), {==}, equal(T.ListOf{ac0, ac1}, T.Unsigned{bc0}, public))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.ByteVector{bc0}), S.identical(T.ListOf{ac0, ac1}, T.ByteVector{bc0}), {==}, equal(T.ListOf{ac0, ac1}, T.ByteVector{bc0}, public))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.ByteList{bc0}), S.identical(T.ListOf{ac0, ac1}, T.ByteList{bc0}), {==}, equal(T.ListOf{ac0, ac1}, T.ByteList{bc0}, public))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.BitVector{bc0}), S.identical(T.ListOf{ac0, ac1}, T.BitVector{bc0}), {==}, equal(T.ListOf{ac0, ac1}, T.BitVector{bc0}, public))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.BitList{bc0}), S.identical(T.ListOf{ac0, ac1}, T.BitList{bc0}), {==}, equal(T.ListOf{ac0, ac1}, T.BitList{bc0}, public))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}), {==}, equal(T.ListOf{ac0, ac1}, T.Vector{bc0, bc1}, public))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}), {==}, equal(T.ListOf{ac0, ac1}, T.ListOf{bc0, bc1}, public))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.Container{bc0, bc1}), S.identical(T.ListOf{ac0, ac1}, T.Container{bc0, bc1}), {==}, equal(T.ListOf{ac0, ac1}, T.Container{bc0, bc1}, public))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.Union{bc0}), S.identical(T.ListOf{ac0, ac1}, T.Union{bc0}), {==}, equal(T.ListOf{ac0, ac1}, T.Union{bc0}, public))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.Null{}), S.identical(T.ListOf{ac0, ac1}, T.Null{}), {==}, equal(T.ListOf{ac0, ac1}, T.Null{}, public))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}), {==}, equal(T.ListOf{ac0, ac1}, T.Chain{bc0, bc1}, public))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.End{}), S.identical(T.ListOf{ac0, ac1}, T.End{}), {==}, equal(T.ListOf{ac0, ac1}, T.End{}, public))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.Repeat{bc0}), S.identical(T.ListOf{ac0, ac1}, T.Repeat{bc0}), {==}, equal(T.ListOf{ac0, ac1}, T.Repeat{bc0}, public))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.Named{bc0, bc1}), S.identical(T.ListOf{ac0, ac1}, T.Named{bc0, bc1}), {==}, equal(T.ListOf{ac0, ac1}, T.Named{bc0, bc1}, public))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}), {==}, equal(T.ListOf{ac0, ac1}, T.ProgressiveList{bc0}, public))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.ProgressiveBits{}), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveBits{}), {==}, equal(T.ListOf{ac0, ac1}, T.ProgressiveBits{}, public))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.ListOf{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.ListOf{T.ListOf{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.ListOf{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ByteList{b0}: {==}
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
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.Boolean{}), S.identical(T.Container{ac0, ac1}, T.Boolean{}), {==}, equal(T.Container{ac0, ac1}, T.Boolean{}, public))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.Unsigned{bc0}), S.identical(T.Container{ac0, ac1}, T.Unsigned{bc0}), {==}, equal(T.Container{ac0, ac1}, T.Unsigned{bc0}, public))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.ByteVector{bc0}), S.identical(T.Container{ac0, ac1}, T.ByteVector{bc0}), {==}, equal(T.Container{ac0, ac1}, T.ByteVector{bc0}, public))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.ByteList{bc0}), S.identical(T.Container{ac0, ac1}, T.ByteList{bc0}), {==}, equal(T.Container{ac0, ac1}, T.ByteList{bc0}, public))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.BitVector{bc0}), S.identical(T.Container{ac0, ac1}, T.BitVector{bc0}), {==}, equal(T.Container{ac0, ac1}, T.BitVector{bc0}, public))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.BitList{bc0}), S.identical(T.Container{ac0, ac1}, T.BitList{bc0}), {==}, equal(T.Container{ac0, ac1}, T.BitList{bc0}, public))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(T.Container{ac0, ac1}, T.Vector{bc0, bc1}), {==}, equal(T.Container{ac0, ac1}, T.Vector{bc0, bc1}, public))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(T.Container{ac0, ac1}, T.ListOf{bc0, bc1}), {==}, equal(T.Container{ac0, ac1}, T.ListOf{bc0, bc1}, public))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.Container{bc0, bc1}), S.identical(T.Container{ac0, ac1}, T.Container{bc0, bc1}), {==}, equal(T.Container{ac0, ac1}, T.Container{bc0, bc1}, public))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.Union{bc0}), S.identical(T.Container{ac0, ac1}, T.Union{bc0}), {==}, equal(T.Container{ac0, ac1}, T.Union{bc0}, public))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.Null{}), S.identical(T.Container{ac0, ac1}, T.Null{}), {==}, equal(T.Container{ac0, ac1}, T.Null{}, public))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(T.Container{ac0, ac1}, T.Chain{bc0, bc1}), {==}, equal(T.Container{ac0, ac1}, T.Chain{bc0, bc1}, public))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.End{}), S.identical(T.Container{ac0, ac1}, T.End{}), {==}, equal(T.Container{ac0, ac1}, T.End{}, public))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.Repeat{bc0}), S.identical(T.Container{ac0, ac1}, T.Repeat{bc0}), {==}, equal(T.Container{ac0, ac1}, T.Repeat{bc0}, public))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.Named{bc0, bc1}), S.identical(T.Container{ac0, ac1}, T.Named{bc0, bc1}), {==}, equal(T.Container{ac0, ac1}, T.Named{bc0, bc1}, public))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(T.Container{ac0, ac1}, T.ProgressiveList{bc0}), {==}, equal(T.Container{ac0, ac1}, T.ProgressiveList{bc0}, public))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.ProgressiveBits{}), S.identical(T.Container{ac0, ac1}, T.ProgressiveBits{}), {==}, equal(T.Container{ac0, ac1}, T.ProgressiveBits{}, public))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.Container{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.ListOf{T.Container{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.Container{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.ListOf{T.Union{ac0}, a1} T.ByteList{b0}: {==}
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
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.Boolean{}), S.identical(T.Union{ac0}, T.Boolean{}), {==}, equal(T.Union{ac0}, T.Boolean{}, public))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.Unsigned{bc0}), S.identical(T.Union{ac0}, T.Unsigned{bc0}), {==}, equal(T.Union{ac0}, T.Unsigned{bc0}, public))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.ByteVector{bc0}), S.identical(T.Union{ac0}, T.ByteVector{bc0}), {==}, equal(T.Union{ac0}, T.ByteVector{bc0}, public))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.ByteList{bc0}), S.identical(T.Union{ac0}, T.ByteList{bc0}), {==}, equal(T.Union{ac0}, T.ByteList{bc0}, public))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.BitVector{bc0}), S.identical(T.Union{ac0}, T.BitVector{bc0}), {==}, equal(T.Union{ac0}, T.BitVector{bc0}, public))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.BitList{bc0}), S.identical(T.Union{ac0}, T.BitList{bc0}), {==}, equal(T.Union{ac0}, T.BitList{bc0}, public))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.Vector{bc0, bc1}), S.identical(T.Union{ac0}, T.Vector{bc0, bc1}), {==}, equal(T.Union{ac0}, T.Vector{bc0, bc1}, public))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.ListOf{bc0, bc1}), S.identical(T.Union{ac0}, T.ListOf{bc0, bc1}), {==}, equal(T.Union{ac0}, T.ListOf{bc0, bc1}, public))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.Container{bc0, bc1}), S.identical(T.Union{ac0}, T.Container{bc0, bc1}), {==}, equal(T.Union{ac0}, T.Container{bc0, bc1}, public))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.Union{bc0}), S.identical(T.Union{ac0}, T.Union{bc0}), {==}, equal(T.Union{ac0}, T.Union{bc0}, public))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.Null{}), S.identical(T.Union{ac0}, T.Null{}), {==}, equal(T.Union{ac0}, T.Null{}, public))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.Chain{bc0, bc1}), S.identical(T.Union{ac0}, T.Chain{bc0, bc1}), {==}, equal(T.Union{ac0}, T.Chain{bc0, bc1}, public))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.End{}), S.identical(T.Union{ac0}, T.End{}), {==}, equal(T.Union{ac0}, T.End{}, public))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.Repeat{bc0}), S.identical(T.Union{ac0}, T.Repeat{bc0}), {==}, equal(T.Union{ac0}, T.Repeat{bc0}, public))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.Named{bc0, bc1}), S.identical(T.Union{ac0}, T.Named{bc0, bc1}), {==}, equal(T.Union{ac0}, T.Named{bc0, bc1}, public))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.ProgressiveList{bc0}), S.identical(T.Union{ac0}, T.ProgressiveList{bc0}), {==}, equal(T.Union{ac0}, T.ProgressiveList{bc0}, public))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.ProgressiveBits{}), S.identical(T.Union{ac0}, T.ProgressiveBits{}), {==}, equal(T.Union{ac0}, T.ProgressiveBits{}, public))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.Union{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.ListOf{T.Union{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Union{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(T.Union{ac0}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.Union{ac0}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.ListOf{T.Null{}, a1} T.ByteList{b0}: {==}
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
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Boolean{}), S.identical(T.Null{}, T.Boolean{}), {==}, equal(T.Null{}, T.Boolean{}, public))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Unsigned{bc0}), S.identical(T.Null{}, T.Unsigned{bc0}), {==}, equal(T.Null{}, T.Unsigned{bc0}, public))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ByteVector{bc0}), S.identical(T.Null{}, T.ByteVector{bc0}), {==}, equal(T.Null{}, T.ByteVector{bc0}, public))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ByteList{bc0}), S.identical(T.Null{}, T.ByteList{bc0}), {==}, equal(T.Null{}, T.ByteList{bc0}, public))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.BitVector{bc0}), S.identical(T.Null{}, T.BitVector{bc0}), {==}, equal(T.Null{}, T.BitVector{bc0}, public))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.BitList{bc0}), S.identical(T.Null{}, T.BitList{bc0}), {==}, equal(T.Null{}, T.BitList{bc0}, public))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Vector{bc0, bc1}), S.identical(T.Null{}, T.Vector{bc0, bc1}), {==}, equal(T.Null{}, T.Vector{bc0, bc1}, public))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ListOf{bc0, bc1}), S.identical(T.Null{}, T.ListOf{bc0, bc1}), {==}, equal(T.Null{}, T.ListOf{bc0, bc1}, public))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Container{bc0, bc1}), S.identical(T.Null{}, T.Container{bc0, bc1}), {==}, equal(T.Null{}, T.Container{bc0, bc1}, public))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Union{bc0}), S.identical(T.Null{}, T.Union{bc0}), {==}, equal(T.Null{}, T.Union{bc0}, public))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Null{}), S.identical(T.Null{}, T.Null{}), {==}, equal(T.Null{}, T.Null{}, public))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Chain{bc0, bc1}), S.identical(T.Null{}, T.Chain{bc0, bc1}), {==}, equal(T.Null{}, T.Chain{bc0, bc1}, public))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.End{}), S.identical(T.Null{}, T.End{}), {==}, equal(T.Null{}, T.End{}, public))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Repeat{bc0}), S.identical(T.Null{}, T.Repeat{bc0}), {==}, equal(T.Null{}, T.Repeat{bc0}, public))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.Named{bc0, bc1}), S.identical(T.Null{}, T.Named{bc0, bc1}), {==}, equal(T.Null{}, T.Named{bc0, bc1}, public))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ProgressiveList{bc0}), S.identical(T.Null{}, T.ProgressiveList{bc0}), {==}, equal(T.Null{}, T.ProgressiveList{bc0}, public))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ProgressiveBits{}), S.identical(T.Null{}, T.ProgressiveBits{}), {==}, equal(T.Null{}, T.ProgressiveBits{}, public))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.Null{}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.ListOf{T.Null{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Null{}, T.CompatibleUnion{bc0, bc1}), S.identical(T.Null{}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.Null{}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ByteList{b0}: {==}
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
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.Boolean{}), S.identical(T.Chain{ac0, ac1}, T.Boolean{}), {==}, equal(T.Chain{ac0, ac1}, T.Boolean{}, public))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.Unsigned{bc0}), S.identical(T.Chain{ac0, ac1}, T.Unsigned{bc0}), {==}, equal(T.Chain{ac0, ac1}, T.Unsigned{bc0}, public))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.ByteVector{bc0}), S.identical(T.Chain{ac0, ac1}, T.ByteVector{bc0}), {==}, equal(T.Chain{ac0, ac1}, T.ByteVector{bc0}, public))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.ByteList{bc0}), S.identical(T.Chain{ac0, ac1}, T.ByteList{bc0}), {==}, equal(T.Chain{ac0, ac1}, T.ByteList{bc0}, public))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.BitVector{bc0}), S.identical(T.Chain{ac0, ac1}, T.BitVector{bc0}), {==}, equal(T.Chain{ac0, ac1}, T.BitVector{bc0}, public))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.BitList{bc0}), S.identical(T.Chain{ac0, ac1}, T.BitList{bc0}), {==}, equal(T.Chain{ac0, ac1}, T.BitList{bc0}, public))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(T.Chain{ac0, ac1}, T.Vector{bc0, bc1}), {==}, equal(T.Chain{ac0, ac1}, T.Vector{bc0, bc1}, public))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}), {==}, equal(T.Chain{ac0, ac1}, T.ListOf{bc0, bc1}, public))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.Container{bc0, bc1}), S.identical(T.Chain{ac0, ac1}, T.Container{bc0, bc1}), {==}, equal(T.Chain{ac0, ac1}, T.Container{bc0, bc1}, public))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.Union{bc0}), S.identical(T.Chain{ac0, ac1}, T.Union{bc0}), {==}, equal(T.Chain{ac0, ac1}, T.Union{bc0}, public))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.Null{}), S.identical(T.Chain{ac0, ac1}, T.Null{}), {==}, equal(T.Chain{ac0, ac1}, T.Null{}, public))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(T.Chain{ac0, ac1}, T.Chain{bc0, bc1}), {==}, equal(T.Chain{ac0, ac1}, T.Chain{bc0, bc1}, public))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.End{}), S.identical(T.Chain{ac0, ac1}, T.End{}), {==}, equal(T.Chain{ac0, ac1}, T.End{}, public))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.Repeat{bc0}), S.identical(T.Chain{ac0, ac1}, T.Repeat{bc0}), {==}, equal(T.Chain{ac0, ac1}, T.Repeat{bc0}, public))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.Named{bc0, bc1}), S.identical(T.Chain{ac0, ac1}, T.Named{bc0, bc1}), {==}, equal(T.Chain{ac0, ac1}, T.Named{bc0, bc1}, public))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(T.Chain{ac0, ac1}, T.ProgressiveList{bc0}), {==}, equal(T.Chain{ac0, ac1}, T.ProgressiveList{bc0}, public))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.ProgressiveBits{}), S.identical(T.Chain{ac0, ac1}, T.ProgressiveBits{}), {==}, equal(T.Chain{ac0, ac1}, T.ProgressiveBits{}, public))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.Chain{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.ListOf{T.Chain{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.Chain{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.ListOf{T.End{}, a1} T.ByteList{b0}: {==}
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
    case T.ListOf{T.End{}, a1} T.ListOf{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.Boolean{}), S.identical(T.End{}, T.Boolean{}), {==}, equal(T.End{}, T.Boolean{}, public))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.Unsigned{bc0}), S.identical(T.End{}, T.Unsigned{bc0}), {==}, equal(T.End{}, T.Unsigned{bc0}, public))
    case T.ListOf{T.End{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.ByteVector{bc0}), S.identical(T.End{}, T.ByteVector{bc0}), {==}, equal(T.End{}, T.ByteVector{bc0}, public))
    case T.ListOf{T.End{}, a1} T.ListOf{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.ByteList{bc0}), S.identical(T.End{}, T.ByteList{bc0}), {==}, equal(T.End{}, T.ByteList{bc0}, public))
    case T.ListOf{T.End{}, a1} T.ListOf{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.BitVector{bc0}), S.identical(T.End{}, T.BitVector{bc0}), {==}, equal(T.End{}, T.BitVector{bc0}, public))
    case T.ListOf{T.End{}, a1} T.ListOf{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.BitList{bc0}), S.identical(T.End{}, T.BitList{bc0}), {==}, equal(T.End{}, T.BitList{bc0}, public))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.Vector{bc0, bc1}), S.identical(T.End{}, T.Vector{bc0, bc1}), {==}, equal(T.End{}, T.Vector{bc0, bc1}, public))
    case T.ListOf{T.End{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.ListOf{bc0, bc1}), S.identical(T.End{}, T.ListOf{bc0, bc1}), {==}, equal(T.End{}, T.ListOf{bc0, bc1}, public))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.Container{bc0, bc1}), S.identical(T.End{}, T.Container{bc0, bc1}), {==}, equal(T.End{}, T.Container{bc0, bc1}, public))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.Union{bc0}), S.identical(T.End{}, T.Union{bc0}), {==}, equal(T.End{}, T.Union{bc0}, public))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.Null{}), S.identical(T.End{}, T.Null{}), {==}, equal(T.End{}, T.Null{}, public))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.Chain{bc0, bc1}), S.identical(T.End{}, T.Chain{bc0, bc1}), {==}, equal(T.End{}, T.Chain{bc0, bc1}, public))
    case T.ListOf{T.End{}, a1} T.ListOf{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.End{}), S.identical(T.End{}, T.End{}), {==}, equal(T.End{}, T.End{}, public))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.Repeat{bc0}), S.identical(T.End{}, T.Repeat{bc0}), {==}, equal(T.End{}, T.Repeat{bc0}, public))
    case T.ListOf{T.End{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.Named{bc0, bc1}), S.identical(T.End{}, T.Named{bc0, bc1}), {==}, equal(T.End{}, T.Named{bc0, bc1}, public))
    case T.ListOf{T.End{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.ProgressiveList{bc0}), S.identical(T.End{}, T.ProgressiveList{bc0}), {==}, equal(T.End{}, T.ProgressiveList{bc0}, public))
    case T.ListOf{T.End{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.ProgressiveBits{}), S.identical(T.End{}, T.ProgressiveBits{}), {==}, equal(T.End{}, T.ProgressiveBits{}, public))
    case T.ListOf{T.End{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.End{}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.ListOf{T.End{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.End{}, T.CompatibleUnion{bc0, bc1}), S.identical(T.End{}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.End{}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.ListOf{T.Repeat{ac0}, a1} T.ByteList{b0}: {==}
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
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.Boolean{}), S.identical(T.Repeat{ac0}, T.Boolean{}), {==}, equal(T.Repeat{ac0}, T.Boolean{}, public))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.Unsigned{bc0}), S.identical(T.Repeat{ac0}, T.Unsigned{bc0}), {==}, equal(T.Repeat{ac0}, T.Unsigned{bc0}, public))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.ByteVector{bc0}), S.identical(T.Repeat{ac0}, T.ByteVector{bc0}), {==}, equal(T.Repeat{ac0}, T.ByteVector{bc0}, public))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.ByteList{bc0}), S.identical(T.Repeat{ac0}, T.ByteList{bc0}), {==}, equal(T.Repeat{ac0}, T.ByteList{bc0}, public))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.BitVector{bc0}), S.identical(T.Repeat{ac0}, T.BitVector{bc0}), {==}, equal(T.Repeat{ac0}, T.BitVector{bc0}, public))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.BitList{bc0}), S.identical(T.Repeat{ac0}, T.BitList{bc0}), {==}, equal(T.Repeat{ac0}, T.BitList{bc0}, public))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.Vector{bc0, bc1}), S.identical(T.Repeat{ac0}, T.Vector{bc0, bc1}), {==}, equal(T.Repeat{ac0}, T.Vector{bc0, bc1}, public))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.ListOf{bc0, bc1}), S.identical(T.Repeat{ac0}, T.ListOf{bc0, bc1}), {==}, equal(T.Repeat{ac0}, T.ListOf{bc0, bc1}, public))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.Container{bc0, bc1}), S.identical(T.Repeat{ac0}, T.Container{bc0, bc1}), {==}, equal(T.Repeat{ac0}, T.Container{bc0, bc1}, public))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.Union{bc0}), S.identical(T.Repeat{ac0}, T.Union{bc0}), {==}, equal(T.Repeat{ac0}, T.Union{bc0}, public))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.Null{}), S.identical(T.Repeat{ac0}, T.Null{}), {==}, equal(T.Repeat{ac0}, T.Null{}, public))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.Chain{bc0, bc1}), S.identical(T.Repeat{ac0}, T.Chain{bc0, bc1}), {==}, equal(T.Repeat{ac0}, T.Chain{bc0, bc1}, public))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.End{}), S.identical(T.Repeat{ac0}, T.End{}), {==}, equal(T.Repeat{ac0}, T.End{}, public))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.Repeat{bc0}), S.identical(T.Repeat{ac0}, T.Repeat{bc0}), {==}, equal(T.Repeat{ac0}, T.Repeat{bc0}, public))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.Named{bc0, bc1}), S.identical(T.Repeat{ac0}, T.Named{bc0, bc1}), {==}, equal(T.Repeat{ac0}, T.Named{bc0, bc1}, public))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.ProgressiveList{bc0}), S.identical(T.Repeat{ac0}, T.ProgressiveList{bc0}), {==}, equal(T.Repeat{ac0}, T.ProgressiveList{bc0}, public))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.ProgressiveBits{}), S.identical(T.Repeat{ac0}, T.ProgressiveBits{}), {==}, equal(T.Repeat{ac0}, T.ProgressiveBits{}, public))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.Repeat{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.ListOf{T.Repeat{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.Repeat{ac0}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ByteList{b0}: {==}
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
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.Boolean{}), S.identical(T.Named{ac0, ac1}, T.Boolean{}), {==}, equal(T.Named{ac0, ac1}, T.Boolean{}, public))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.Unsigned{bc0}), S.identical(T.Named{ac0, ac1}, T.Unsigned{bc0}), {==}, equal(T.Named{ac0, ac1}, T.Unsigned{bc0}, public))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.ByteVector{bc0}), S.identical(T.Named{ac0, ac1}, T.ByteVector{bc0}), {==}, equal(T.Named{ac0, ac1}, T.ByteVector{bc0}, public))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.ByteList{bc0}), S.identical(T.Named{ac0, ac1}, T.ByteList{bc0}), {==}, equal(T.Named{ac0, ac1}, T.ByteList{bc0}, public))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.BitVector{bc0}), S.identical(T.Named{ac0, ac1}, T.BitVector{bc0}), {==}, equal(T.Named{ac0, ac1}, T.BitVector{bc0}, public))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.BitList{bc0}), S.identical(T.Named{ac0, ac1}, T.BitList{bc0}), {==}, equal(T.Named{ac0, ac1}, T.BitList{bc0}, public))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(T.Named{ac0, ac1}, T.Vector{bc0, bc1}), {==}, equal(T.Named{ac0, ac1}, T.Vector{bc0, bc1}, public))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(T.Named{ac0, ac1}, T.ListOf{bc0, bc1}), {==}, equal(T.Named{ac0, ac1}, T.ListOf{bc0, bc1}, public))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.Container{bc0, bc1}), S.identical(T.Named{ac0, ac1}, T.Container{bc0, bc1}), {==}, equal(T.Named{ac0, ac1}, T.Container{bc0, bc1}, public))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.Union{bc0}), S.identical(T.Named{ac0, ac1}, T.Union{bc0}), {==}, equal(T.Named{ac0, ac1}, T.Union{bc0}, public))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.Null{}), S.identical(T.Named{ac0, ac1}, T.Null{}), {==}, equal(T.Named{ac0, ac1}, T.Null{}, public))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(T.Named{ac0, ac1}, T.Chain{bc0, bc1}), {==}, equal(T.Named{ac0, ac1}, T.Chain{bc0, bc1}, public))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.End{}), S.identical(T.Named{ac0, ac1}, T.End{}), {==}, equal(T.Named{ac0, ac1}, T.End{}, public))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.Repeat{bc0}), S.identical(T.Named{ac0, ac1}, T.Repeat{bc0}), {==}, equal(T.Named{ac0, ac1}, T.Repeat{bc0}, public))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.Named{bc0, bc1}), S.identical(T.Named{ac0, ac1}, T.Named{bc0, bc1}), {==}, equal(T.Named{ac0, ac1}, T.Named{bc0, bc1}, public))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(T.Named{ac0, ac1}, T.ProgressiveList{bc0}), {==}, equal(T.Named{ac0, ac1}, T.ProgressiveList{bc0}, public))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.ProgressiveBits{}), S.identical(T.Named{ac0, ac1}, T.ProgressiveBits{}), {==}, equal(T.Named{ac0, ac1}, T.ProgressiveBits{}, public))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.Named{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.ListOf{T.Named{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.Named{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ByteList{b0}: {==}
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
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.Boolean{}), S.identical(T.ProgressiveList{ac0}, T.Boolean{}), {==}, equal(T.ProgressiveList{ac0}, T.Boolean{}, public))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.Unsigned{bc0}), S.identical(T.ProgressiveList{ac0}, T.Unsigned{bc0}), {==}, equal(T.ProgressiveList{ac0}, T.Unsigned{bc0}, public))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.ByteVector{bc0}), S.identical(T.ProgressiveList{ac0}, T.ByteVector{bc0}), {==}, equal(T.ProgressiveList{ac0}, T.ByteVector{bc0}, public))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.ByteList{bc0}), S.identical(T.ProgressiveList{ac0}, T.ByteList{bc0}), {==}, equal(T.ProgressiveList{ac0}, T.ByteList{bc0}, public))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.BitVector{bc0}), S.identical(T.ProgressiveList{ac0}, T.BitVector{bc0}), {==}, equal(T.ProgressiveList{ac0}, T.BitVector{bc0}, public))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.BitList{bc0}), S.identical(T.ProgressiveList{ac0}, T.BitList{bc0}), {==}, equal(T.ProgressiveList{ac0}, T.BitList{bc0}, public))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.Vector{bc0, bc1}), S.identical(T.ProgressiveList{ac0}, T.Vector{bc0, bc1}), {==}, equal(T.ProgressiveList{ac0}, T.Vector{bc0, bc1}, public))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}), S.identical(T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}), {==}, equal(T.ProgressiveList{ac0}, T.ListOf{bc0, bc1}, public))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.Container{bc0, bc1}), S.identical(T.ProgressiveList{ac0}, T.Container{bc0, bc1}), {==}, equal(T.ProgressiveList{ac0}, T.Container{bc0, bc1}, public))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.Union{bc0}), S.identical(T.ProgressiveList{ac0}, T.Union{bc0}), {==}, equal(T.ProgressiveList{ac0}, T.Union{bc0}, public))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.Null{}), S.identical(T.ProgressiveList{ac0}, T.Null{}), {==}, equal(T.ProgressiveList{ac0}, T.Null{}, public))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.Chain{bc0, bc1}), S.identical(T.ProgressiveList{ac0}, T.Chain{bc0, bc1}), {==}, equal(T.ProgressiveList{ac0}, T.Chain{bc0, bc1}, public))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.End{}), S.identical(T.ProgressiveList{ac0}, T.End{}), {==}, equal(T.ProgressiveList{ac0}, T.End{}, public))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.Repeat{bc0}), S.identical(T.ProgressiveList{ac0}, T.Repeat{bc0}), {==}, equal(T.ProgressiveList{ac0}, T.Repeat{bc0}, public))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.Named{bc0, bc1}), S.identical(T.ProgressiveList{ac0}, T.Named{bc0, bc1}), {==}, equal(T.ProgressiveList{ac0}, T.Named{bc0, bc1}, public))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.ProgressiveList{bc0}), S.identical(T.ProgressiveList{ac0}, T.ProgressiveList{bc0}), {==}, equal(T.ProgressiveList{ac0}, T.ProgressiveList{bc0}, public))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.ProgressiveBits{}), S.identical(T.ProgressiveList{ac0}, T.ProgressiveBits{}), {==}, equal(T.ProgressiveList{ac0}, T.ProgressiveBits{}, public))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.ProgressiveList{ac0}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.ListOf{T.ProgressiveList{ac0}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}), S.identical(T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.ProgressiveList{ac0}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.ListOf{T.ProgressiveBits{}, a1} T.ByteList{b0}: {==}
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
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Boolean{}), S.identical(T.ProgressiveBits{}, T.Boolean{}), {==}, equal(T.ProgressiveBits{}, T.Boolean{}, public))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Unsigned{bc0}), S.identical(T.ProgressiveBits{}, T.Unsigned{bc0}), {==}, equal(T.ProgressiveBits{}, T.Unsigned{bc0}, public))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ByteVector{bc0}), S.identical(T.ProgressiveBits{}, T.ByteVector{bc0}), {==}, equal(T.ProgressiveBits{}, T.ByteVector{bc0}, public))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ByteList{bc0}), S.identical(T.ProgressiveBits{}, T.ByteList{bc0}), {==}, equal(T.ProgressiveBits{}, T.ByteList{bc0}, public))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.BitVector{bc0}), S.identical(T.ProgressiveBits{}, T.BitVector{bc0}), {==}, equal(T.ProgressiveBits{}, T.BitVector{bc0}, public))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.BitList{bc0}), S.identical(T.ProgressiveBits{}, T.BitList{bc0}), {==}, equal(T.ProgressiveBits{}, T.BitList{bc0}, public))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Vector{bc0, bc1}), S.identical(T.ProgressiveBits{}, T.Vector{bc0, bc1}), {==}, equal(T.ProgressiveBits{}, T.Vector{bc0, bc1}, public))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ListOf{bc0, bc1}), S.identical(T.ProgressiveBits{}, T.ListOf{bc0, bc1}), {==}, equal(T.ProgressiveBits{}, T.ListOf{bc0, bc1}, public))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Container{bc0, bc1}), S.identical(T.ProgressiveBits{}, T.Container{bc0, bc1}), {==}, equal(T.ProgressiveBits{}, T.Container{bc0, bc1}, public))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Union{bc0}), S.identical(T.ProgressiveBits{}, T.Union{bc0}), {==}, equal(T.ProgressiveBits{}, T.Union{bc0}, public))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Null{}), S.identical(T.ProgressiveBits{}, T.Null{}), {==}, equal(T.ProgressiveBits{}, T.Null{}, public))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Chain{bc0, bc1}), S.identical(T.ProgressiveBits{}, T.Chain{bc0, bc1}), {==}, equal(T.ProgressiveBits{}, T.Chain{bc0, bc1}, public))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.End{}), S.identical(T.ProgressiveBits{}, T.End{}), {==}, equal(T.ProgressiveBits{}, T.End{}, public))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Repeat{bc0}), S.identical(T.ProgressiveBits{}, T.Repeat{bc0}), {==}, equal(T.ProgressiveBits{}, T.Repeat{bc0}, public))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.Named{bc0, bc1}), S.identical(T.ProgressiveBits{}, T.Named{bc0, bc1}), {==}, equal(T.ProgressiveBits{}, T.Named{bc0, bc1}, public))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ProgressiveList{bc0}), S.identical(T.ProgressiveBits{}, T.ProgressiveList{bc0}), {==}, equal(T.ProgressiveBits{}, T.ProgressiveList{bc0}, public))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ProgressiveBits{}), S.identical(T.ProgressiveBits{}, T.ProgressiveBits{}), {==}, equal(T.ProgressiveBits{}, T.ProgressiveBits{}, public))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.ProgressiveBits{}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.ListOf{T.ProgressiveBits{}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}), S.identical(T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.ProgressiveBits{}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ByteList{b0}: {==}
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
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.Boolean{}, public))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.Unsigned{bc0}, public))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteVector{bc0}, public))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.ByteList{bc0}, public))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitVector{bc0}, public))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.BitList{bc0}, public))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.Vector{bc0, bc1}, public))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.ListOf{bc0, bc1}, public))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.Container{bc0, bc1}, public))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.Union{bc0}, public))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.Null{}, public))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.Chain{bc0, bc1}, public))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.End{}, public))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.Repeat{bc0}, public))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.Named{bc0, bc1}, public))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveList{bc0}, public))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveBits{}, public))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.ListOf{T.ProgressiveContainer{ac0, ac1, ac2}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}), S.identical(T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.ProgressiveContainer{ac0, ac1, ac2}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ByteList{b0}: {==}
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
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Boolean{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.Boolean{}), S.identical(T.CompatibleUnion{ac0, ac1}, T.Boolean{}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.Boolean{}, public))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Unsigned{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}), S.identical(T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.Unsigned{bc0}, public))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ByteVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}), S.identical(T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.ByteVector{bc0}, public))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ByteList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}), S.identical(T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.ByteList{bc0}, public))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.BitVector{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}), S.identical(T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.BitVector{bc0}, public))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.BitList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}), S.identical(T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.BitList{bc0}, public))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Vector{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}), S.identical(T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.Vector{bc0, bc1}, public))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ListOf{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}), S.identical(T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.ListOf{bc0, bc1}, public))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Container{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}), S.identical(T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.Container{bc0, bc1}, public))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Union{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.Union{bc0}), S.identical(T.CompatibleUnion{ac0, ac1}, T.Union{bc0}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.Union{bc0}, public))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Null{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.Null{}), S.identical(T.CompatibleUnion{ac0, ac1}, T.Null{}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.Null{}, public))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Chain{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}), S.identical(T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.Chain{bc0, bc1}, public))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.End{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.End{}), S.identical(T.CompatibleUnion{ac0, ac1}, T.End{}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.End{}, public))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Repeat{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}), S.identical(T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.Repeat{bc0}, public))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.Named{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}), S.identical(T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.Named{bc0, bc1}, public))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ProgressiveList{bc0}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.ProgressiveList{bc0}, public))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ProgressiveBits{}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.ProgressiveBits{}, public))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.ProgressiveContainer{bc0, bc1, bc2}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), S.identical(T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.ProgressiveContainer{bc0, bc1, bc2}, public))
    case T.ListOf{T.CompatibleUnion{ac0, ac1}, a1} T.ListOf{T.CompatibleUnion{bc0, bc1}, b1}: and_equal(Nat.is_eq(a1, b1), Nat.is_eq(a1, b1), I.identical(T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), S.identical(T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}), {==}, equal(T.CompatibleUnion{ac0, ac1}, T.CompatibleUnion{bc0, bc1}, public))
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
    case T.Container{a0, a1} T.Container{b0, b1}: and_equal(I.names_equal(a0, b0), S.names_equal(a0, b0), I.identical(a1, b1), S.identical(a1, b1), M.names_equal(a0, b0), equal(a1, b1, public))
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
    case T.Union{a0} T.Union{b0}: equal(a0, b0, public)
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
    case T.Chain{a0, a1} T.Chain{b0, b1}: and_equal(I.identical(a0, b0), S.identical(a0, b0), I.identical(a1, b1), S.identical(a1, b1), equal(a0, b0, V.and_left(unnamed(a0), unnamed(a1), public)), equal(a1, b1, V.and_right(unnamed(a0), unnamed(a1), public)))
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
    case T.Named{a0, a1} T.Named{b0, b1}: Empty.absurd({I.identical(T.Named{a0, a1}, T.Named{b0, b1}) == S.identical(T.Named{a0, a1}, T.Named{b0, b1}) : Bool}, W.false_true(public))
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
    case T.ProgressiveList{a0} T.ProgressiveList{b0}: equal(a0, b0, public)
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
    case T.ProgressiveContainer{a0, a1, a2} T.ProgressiveContainer{b0, b1, b2}: and_equal(I.names_equal(a0, b0), S.names_equal(a0, b0), Bool.and(I.bools_equal(a2, b2), I.identical(a1, b1)), Bool.and(S.bits_equal(a2, b2), S.identical(a1, b1)), M.names_equal(a0, b0), and_equal(I.bools_equal(a2, b2), S.bits_equal(a2, b2), I.identical(a1, b1), S.identical(a1, b1), M.bits_equal(a2, b2), equal(a1, b1, public)))
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
    case T.CompatibleUnion{a0, a1} T.CompatibleUnion{b0, b1}: and_equal(I.selectors_equal(a0, b0), S.selectors_equal(a0, b0), I.identical(a1, b1), S.identical(a1, b1), M.selectors_equal(a0, b0), equal(a1, b1, public))
