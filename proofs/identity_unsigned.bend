import Base
import ../types/schema.bend as T
import ../types/primitive.bend as P
import ../spec/compatibility.bend as S
import ./identity_logic.bend as L

law false_conjunction:
  for +a: Bool
  for +b: Bool
  for no: {b == False{} : Bool}
  {False{} == Bool.and(a, b) : Bool}
def false_conjunction(a, b, no):
  %Equal.sym(Bool, b, False{}, no) : {False{} == Bool.and(a, _) : Bool}
  L.and_right_false(a)

law Vector_left:
  for +child: T.Schema
  for +n: Nat
  for +w: P.Width
  {S.identical(T.Vector{child, n}, T.Unsigned{w}) == False{} : Bool}
def Vector_left(child, n, w):
  match child:
    case T.Boolean{}: {==}
    case T.Unsigned{x0}: {==}
    case T.ByteVector{x0}: {==}
    case T.ByteList{x0}: {==}
    case T.BitVector{x0}: {==}
    case T.BitList{x0}: {==}
    case T.Vector{x0, x1}: {==}
    case T.ListOf{x0, x1}: {==}
    case T.Container{x0, x1}: {==}
    case T.Union{x0}: {==}
    case T.Null{}: {==}
    case T.Chain{x0, x1}: {==}
    case T.End{}: {==}
    case T.Repeat{x0}: {==}
    case T.Named{x0, x1}: {==}
    case T.ProgressiveList{x0}: {==}
    case T.ProgressiveBits{}: {==}
    case T.ProgressiveContainer{x0, x1, x2}: {==}
    case T.CompatibleUnion{x0, x1}: {==}

law Vector_right:
  for +child: T.Schema
  for +n: Nat
  for +w: P.Width
  {S.identical(T.Unsigned{w}, T.Vector{child, n}) == False{} : Bool}
def Vector_right(child, n, w):
  match child:
    case T.Boolean{}: {==}
    case T.Unsigned{x0}: {==}
    case T.ByteVector{x0}: {==}
    case T.ByteList{x0}: {==}
    case T.BitVector{x0}: {==}
    case T.BitList{x0}: {==}
    case T.Vector{x0, x1}: {==}
    case T.ListOf{x0, x1}: {==}
    case T.Container{x0, x1}: {==}
    case T.Union{x0}: {==}
    case T.Null{}: {==}
    case T.Chain{x0, x1}: {==}
    case T.End{}: {==}
    case T.Repeat{x0}: {==}
    case T.Named{x0, x1}: {==}
    case T.ProgressiveList{x0}: {==}
    case T.ProgressiveBits{}: {==}
    case T.ProgressiveContainer{x0, x1, x2}: {==}
    case T.CompatibleUnion{x0, x1}: {==}

law ListOf_left:
  for +child: T.Schema
  for +n: Nat
  for +w: P.Width
  {S.identical(T.ListOf{child, n}, T.Unsigned{w}) == False{} : Bool}
def ListOf_left(child, n, w):
  match child:
    case T.Boolean{}: {==}
    case T.Unsigned{x0}: {==}
    case T.ByteVector{x0}: {==}
    case T.ByteList{x0}: {==}
    case T.BitVector{x0}: {==}
    case T.BitList{x0}: {==}
    case T.Vector{x0, x1}: {==}
    case T.ListOf{x0, x1}: {==}
    case T.Container{x0, x1}: {==}
    case T.Union{x0}: {==}
    case T.Null{}: {==}
    case T.Chain{x0, x1}: {==}
    case T.End{}: {==}
    case T.Repeat{x0}: {==}
    case T.Named{x0, x1}: {==}
    case T.ProgressiveList{x0}: {==}
    case T.ProgressiveBits{}: {==}
    case T.ProgressiveContainer{x0, x1, x2}: {==}
    case T.CompatibleUnion{x0, x1}: {==}

law ListOf_right:
  for +child: T.Schema
  for +n: Nat
  for +w: P.Width
  {S.identical(T.Unsigned{w}, T.ListOf{child, n}) == False{} : Bool}
def ListOf_right(child, n, w):
  match child:
    case T.Boolean{}: {==}
    case T.Unsigned{x0}: {==}
    case T.ByteVector{x0}: {==}
    case T.ByteList{x0}: {==}
    case T.BitVector{x0}: {==}
    case T.BitList{x0}: {==}
    case T.Vector{x0, x1}: {==}
    case T.ListOf{x0, x1}: {==}
    case T.Container{x0, x1}: {==}
    case T.Union{x0}: {==}
    case T.Null{}: {==}
    case T.Chain{x0, x1}: {==}
    case T.End{}: {==}
    case T.Repeat{x0}: {==}
    case T.Named{x0, x1}: {==}
    case T.ProgressiveList{x0}: {==}
    case T.ProgressiveBits{}: {==}
    case T.ProgressiveContainer{x0, x1, x2}: {==}
    case T.CompatibleUnion{x0, x1}: {==}
