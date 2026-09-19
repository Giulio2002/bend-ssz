import Base
import ../types/schema.bend as T
import ./primitives.bend as P

# SSZ compatible-Merkleization inference rules. A finite derivation is a
# mathematical witness, with no fixed/input-sized resource budget. Its checker
# recurses on the witness, not on the implementation's fuel or return value.
# Pair is the public judgement; All/Row/Slots are explicit auxiliary judgements.
type Judgement is Data:
  Pair{}
  All{}
  Row{}
  Slots{}

type Derivation is Data:
  Leaf{}
  Step{child: Derivation}
  Fork{left: Derivation, right: Derivation}

def names_equal(a: +List<String>, b: +List<String>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x, xs} Con{y, ys}: Bool.and(String.eq(x, y), names_equal(xs, ys))
    case _ _: False{}

def bits_equal(a: +List<Bool>, b: +List<Bool>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x, xs} Con{y, ys}: Bool.and(Bool.not(Bool.xor(x, y)), bits_equal(xs, ys))
    case _ _: False{}

def selectors_equal(a: +List<U32>, b: +List<U32>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x, xs} Con{y, ys}: Bool.and(U32.is_eq(x, y), selectors_equal(xs, ys))
    case _ _: False{}

# Structural SSZ type identity, including byte/uint8 aliases. Ordinary unions
# use identity of options, not merely compatibility of different option types.
def identical(a: T.Schema, b: T.Schema) -> Bool:
  match a b:
    case T.Boolean{} T.Boolean{}: True{}
    case T.Unsigned{x} T.Unsigned{y}: Nat.is_eq(P.byte_width(x), P.byte_width(y))
    case T.ByteVector{x} T.ByteVector{y}: Nat.is_eq(x, y)
    case T.ByteList{x} T.ByteList{y}: Nat.is_eq(x, y)
    case T.ByteVector{x} T.Vector{T.Unsigned{w}, y}: Bool.and(Nat.is_eq(x, y), Nat.is_eq(P.byte_width(w), 1n))
    case T.Vector{T.Unsigned{w}, x} T.ByteVector{y}: Bool.and(Nat.is_eq(x, y), Nat.is_eq(P.byte_width(w), 1n))
    case T.ByteList{x} T.ListOf{T.Unsigned{w}, y}: Bool.and(Nat.is_eq(x, y), Nat.is_eq(P.byte_width(w), 1n))
    case T.ListOf{T.Unsigned{w}, x} T.ByteList{y}: Bool.and(Nat.is_eq(x, y), Nat.is_eq(P.byte_width(w), 1n))
    case T.BitVector{x} T.BitVector{y}: Nat.is_eq(x, y)
    case T.BitList{x} T.BitList{y}: Nat.is_eq(x, y)
    case T.Vector{x, n} T.Vector{y, m}: Bool.and(Nat.is_eq(n, m), identical(x, y))
    case T.ListOf{x, n} T.ListOf{y, m}: Bool.and(Nat.is_eq(n, m), identical(x, y))
    case T.ProgressiveList{x} T.ProgressiveList{y}: identical(x, y)
    case T.ProgressiveBits{} T.ProgressiveBits{}: True{}
    case T.Container{na, fa} T.Container{nb, fb}: Bool.and(names_equal(na, nb), identical(fa, fb))
    case T.ProgressiveContainer{na, fa, aa} T.ProgressiveContainer{nb, fb, ab}: Bool.and(names_equal(na, nb), Bool.and(bits_equal(aa, ab), identical(fa, fb)))
    case T.Union{x} T.Union{y}: identical(x, y)
    case T.CompatibleUnion{sx, x} T.CompatibleUnion{sy, y}: Bool.and(selectors_equal(sx, sy), identical(x, y))
    case T.Chain{h, t} T.Chain{i, u}: Bool.and(identical(h, i), identical(t, u))
    case T.Named{n, x} T.Named{m, y}: Bool.and(String.eq(n, m), identical(x, y))
    case T.Null{} T.Null{}: True{}
    case T.End{} T.End{}: True{}
    case _ _: False{}

# Full active-slot sequences, including gaps, preserve original positions.
def slots(active: +List<Bool>, names: +List<String>, fields: T.Schema) -> T.Schema:
  match active:
    case Nil{}: T.End{}
    case Con{False{}, tail}: T.Chain{T.Null{}, slots(tail, names, fields)}
    case Con{True{}, tail}:
      match names fields:
        case Con{name, ns} T.Chain{field, fs}: T.Chain{T.Named{name, field}, slots(tail, ns, fs)}
        case _ _: T.End{}

def shift(position: Maybe<&2, Nat>) -> Maybe<&2, Nat>:
  match position:
    case None{}: None{}
    case Some{p}: Some{1n+p}

def choose(found: Bool, tail: Maybe<&2, Nat>) -> Maybe<&2, Nat>:
  match found:
    case True{}: Some{0n}
    case False{}: shift(tail)

def position(+name: String, fields: T.Schema) -> Maybe<&2, Nat>:
  match fields:
    case T.Chain{T.Named{n, s}, tail}: choose(String.eq(name, n), position(name, tail))
    case T.Chain{other, tail}: shift(position(name, tail))
    case _: None{}

def agrees(expected: Nat, position: Maybe<&2, Nat>) -> Bool:
  match position:
    case None{}: True{}
    case Some{actual}: Nat.is_eq(expected, actual)

def shared_positions(a: T.Schema, +b: T.Schema, +index: Nat) -> Bool:
  match a:
    case T.Chain{T.Named{n, s}, tail}: Bool.and(agrees(index, position(n, b)), shared_positions(tail, b, 1n+index))
    case T.Chain{other, tail}: shared_positions(tail, b, 1n+index)
    case _: True{}

def derives(witness: Derivation, judgement: Judgement, +a: T.Schema, +b: T.Schema) -> Bool:
  match witness:
    case Leaf{}:
      match judgement:
        case Pair{}: identical(a, b)
        case All{}:
          match a:
            case T.End{}: True{}
            case _: False{}
        case Row{}:
          match b:
            case T.End{}: True{}
            case _: False{}
        case Slots{}:
          match a b:
            case T.End{} _: True{}
            case _ T.End{}: True{}
            case _ _: False{}
    case Step{child}:
      match judgement:
        case Pair{}:
          match a b:
            case T.Vector{x, n} T.Vector{y, m}: Bool.and(Nat.is_eq(n, m), derives(child, Pair{}, x, y))
            case T.ListOf{x, n} T.ListOf{y, m}: Bool.and(Nat.is_eq(n, m), derives(child, Pair{}, x, y))
            case T.ProgressiveList{x} T.ProgressiveList{y}: derives(child, Pair{}, x, y)
            case T.Container{na, fa} T.Container{nb, fb}: Bool.and(names_equal(na, nb), derives(child, Pair{}, fa, fb))
            case T.ProgressiveContainer{na, fa, aa} T.ProgressiveContainer{nb, fb, ab}: Bool.and(shared_positions(slots(aa, na, fa), slots(ab, nb, fb), 0n), derives(child, Slots{}, slots(aa, na, fa), slots(ab, nb, fb)))
            case T.Named{na, fa} T.Named{nb, fb}: Bool.and(String.eq(na, nb), derives(child, Pair{}, fa, fb))
            case T.CompatibleUnion{sa, fa} T.CompatibleUnion{sb, fb}: derives(child, All{}, fa, fb)
            case _ _: False{}
        case Slots{}:
          match a b:
            case T.Chain{T.Null{}, at} T.Chain{bh, bt}: derives(child, Slots{}, at, bt)
            case T.Chain{ah, at} T.Chain{T.Null{}, bt}: derives(child, Slots{}, at, bt)
            case _ _: False{}
        case _: False{}
    case Fork{left, right}:
      match judgement:
        case Pair{}:
          match a b:
            case T.Chain{ah, at} T.Chain{bh, bt}: Bool.and(derives(left, Pair{}, ah, bh), derives(right, Pair{}, at, bt))
            case _ _: False{}
        case All{}:
          match a:
            case T.Chain{h, t}: Bool.and(derives(left, Row{}, h, b), derives(right, All{}, t, b))
            case _: False{}
        case Row{}:
          match b:
            case T.Chain{h, t}: Bool.and(derives(left, Pair{}, a, h), derives(right, Row{}, a, t))
            case _: False{}
        case Slots{}:
          match a b:
            case T.Chain{T.Named{na, fa}, at} T.Chain{T.Named{nb, fb}, bt}: Bool.and(String.eq(na, nb), Bool.and(derives(left, Pair{}, fa, fb), derives(right, Slots{}, at, bt)))
            case _ _: False{}

def compatible(+a: T.Schema, +b: T.Schema) -> Type:
  Exists(Derivation, witness => {derives(witness, Pair{}, a, b) == True{} : Bool})

def mutually_compatible(+options: T.Schema) -> Type:
  Exists(Derivation, witness => {derives(witness, All{}, options, options) == True{} : Bool})
