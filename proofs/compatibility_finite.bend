import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../spec/compatibility.bend as S
import ./compatibility_monotone.bend as Mono
import ./primitive_invariants.bend as V
import ./nat_algebra.bend as A
import ./compatibility_choice.bend as Choice
import ./compatibility_equations.bend as Equations

def code(mode: S.Judgement) -> U32:
  match mode:
    case S.Pair{}: 0
    case S.All{}: 1
    case S.Row{}: 2
    case S.Slots{}: 3

# An operational witness, not an independent definition of SSZ compatibility.
def finite(+mode: S.Judgement, +a: T.Schema, +b: T.Schema) -> Type:
  Exists(Nat, fuel => {I.compatible_go(fuel, code(mode), a, b) == True{} : Bool})

law lift:
  for +fuel: Nat
  for +extra: Nat
  for +mode: S.Judgement
  for +a: T.Schema
  for +b: T.Schema
  for accepted: {I.compatible_go(fuel, code(mode), a, b) == True{} : Bool}
  {I.compatible_go(Nat.add(fuel, extra), code(mode), a, b) == True{} : Bool}
def lift(fuel, extra, mode, a, b, accepted):
  match mode:
    case S.Pair{}: Mono.monotone(fuel, extra, Mono.Pair{}, a, b, accepted)
    case S.All{}: Mono.monotone(fuel, extra, Mono.All{}, a, b, accepted)
    case S.Row{}: Mono.monotone(fuel, extra, Mono.Row{}, a, b, accepted)
    case S.Slots{}: Mono.monotone(fuel, extra, Mono.Slots{}, a, b, accepted)

law lift_right:
  for +left: Nat
  for +right: Nat
  for +mode: S.Judgement
  for +a: T.Schema
  for +b: T.Schema
  for accepted: {I.compatible_go(right, code(mode), a, b) == True{} : Bool}
  {I.compatible_go(Nat.add(left, right), code(mode), a, b) == True{} : Bool}
def lift_right(left, right, mode, a, b, accepted):
  %A.add_commute(right, left) : {I.compatible_go(_, code(mode), a, b) == True{} : Bool}
  lift(right, left, mode, a, b, accepted)

law Vector:
  for +x: T.Schema
  for +y: T.Schema
  for +n: Nat
  for +m: Nat
  for meta: {Nat.is_eq(n, m) == True{} : Bool}
  for child: finite(S.Pair{}, x, y)
  finite(S.Pair{}, T.Vector{x, n}, T.Vector{y, m})
def Vector(x, y, n, m, meta, child):
  (+fuel, accepted) = child
  (1n+fuel, %Equal.sym(Bool, I.compatible_go(1n+fuel, 0, T.Vector{x, n}, T.Vector{y, m}), Bool.and(Nat.is_eq(n, m), I.compatible_go(fuel, 0, x, y)), Equations.Vector(fuel, x, y, n, m)) : {_ == True{} : Bool}
    V.and_true(Nat.is_eq(n, m), I.compatible_go(fuel, 0, x, y), meta, accepted))

law ListOf:
  for +x: T.Schema
  for +y: T.Schema
  for +n: Nat
  for +m: Nat
  for meta: {Nat.is_eq(n, m) == True{} : Bool}
  for child: finite(S.Pair{}, x, y)
  finite(S.Pair{}, T.ListOf{x, n}, T.ListOf{y, m})
def ListOf(x, y, n, m, meta, child):
  (+fuel, accepted) = child
  (1n+fuel, %Equal.sym(Bool, I.compatible_go(1n+fuel, 0, T.ListOf{x, n}, T.ListOf{y, m}), Bool.and(Nat.is_eq(n, m), I.compatible_go(fuel, 0, x, y)), Equations.ListOf(fuel, x, y, n, m)) : {_ == True{} : Bool}
    V.and_true(Nat.is_eq(n, m), I.compatible_go(fuel, 0, x, y), meta, accepted))

law Container:
  for +x: T.Schema
  for +y: T.Schema
  for +n: +List<String>
  for +m: +List<String>
  for meta: {I.names_equal(n, m) == True{} : Bool}
  for child: finite(S.Pair{}, x, y)
  finite(S.Pair{}, T.Container{n, x}, T.Container{m, y})
def Container(x, y, n, m, meta, child):
  (+fuel, accepted) = child
  (1n+fuel, V.and_true(I.names_equal(n, m), I.compatible_go(fuel, 0, x, y), meta, accepted))

law Named:
  for +x: T.Schema
  for +y: T.Schema
  for +n: String
  for +m: String
  for meta: {String.eq(n, m) == True{} : Bool}
  for child: finite(S.Pair{}, x, y)
  finite(S.Pair{}, T.Named{n, x}, T.Named{m, y})
def Named(x, y, n, m, meta, child):
  (+fuel, accepted) = child
  (1n+fuel, V.and_true(String.eq(n, m), I.compatible_go(fuel, 0, x, y), meta, accepted))

law progressive_list:
  for +x: T.Schema
  for +y: T.Schema
  for child: finite(S.Pair{}, x, y)
  finite(S.Pair{}, T.ProgressiveList{x}, T.ProgressiveList{y})
def progressive_list(x, y, child):
  (+fuel, accepted) = child
  (1n+fuel, accepted)

law chain:
  for +ah: T.Schema
  for +at: T.Schema
  for +bh: T.Schema
  for +bt: T.Schema
  for left: finite(S.Pair{}, ah, bh)
  for right: finite(S.Pair{}, at, bt)
  finite(S.Pair{}, T.Chain{ah, at}, T.Chain{bh, bt})
def chain(ah, at, bh, bt, left, right):
  (+lf, lok) = left
  (+rf, rok) = right
  (1n+Nat.add(lf, rf), V.and_true(I.compatible_go(Nat.add(lf, rf), code(S.Pair{}), ah, bh), I.compatible_go(Nat.add(lf, rf), code(S.Pair{}), at, bt), lift(lf, rf, S.Pair{}, ah, bh, lok), lift_right(lf, rf, S.Pair{}, at, bt, rok)))

law all:
  for +h: T.Schema
  for +t: T.Schema
  for +b: T.Schema
  for left: finite(S.Row{}, h, b)
  for right: finite(S.All{}, t, b)
  finite(S.All{}, T.Chain{h, t}, b)
def all(h, t, b, left, right):
  (+lf, lok) = left
  (+rf, rok) = right
  (1n+Nat.add(lf, rf), V.and_true(I.compatible_go(Nat.add(lf, rf), code(S.Row{}), h, b), I.compatible_go(Nat.add(lf, rf), code(S.All{}), t, b), lift(lf, rf, S.Row{}, h, b, lok), lift_right(lf, rf, S.All{}, t, b, rok)))

law row:
  for +a: T.Schema
  for +h: T.Schema
  for +t: T.Schema
  for left: finite(S.Pair{}, a, h)
  for right: finite(S.Row{}, a, t)
  finite(S.Row{}, a, T.Chain{h, t})
def row(a, h, t, left, right):
  (+lf, lok) = left
  (+rf, rok) = right
  (1n+Nat.add(lf, rf), V.and_true(I.compatible_go(Nat.add(lf, rf), code(S.Pair{}), a, h), I.compatible_go(Nat.add(lf, rf), code(S.Row{}), a, t), lift(lf, rf, S.Pair{}, a, h, lok), lift_right(lf, rf, S.Row{}, a, t, rok)))

law slots:
  for +na: String
  for +fa: T.Schema
  for +at: T.Schema
  for +nb: String
  for +fb: T.Schema
  for +bt: T.Schema
  for left: finite(S.Pair{}, T.Named{na, fa}, T.Named{nb, fb})
  for right: finite(S.Slots{}, at, bt)
  finite(S.Slots{}, T.Chain{T.Named{na, fa}, at}, T.Chain{T.Named{nb, fb}, bt})
def slots(na, fa, at, nb, fb, bt, left, right):
  (+lf, lok) = left
  (+rf, rok) = right
  (1n+Nat.add(lf, rf), V.and_true(I.compatible_go(Nat.add(lf, rf), code(S.Pair{}), T.Named{na, fa}, T.Named{nb, fb}), I.compatible_go(Nat.add(lf, rf), code(S.Slots{}), at, bt), lift(lf, rf, S.Pair{}, T.Named{na, fa}, T.Named{nb, fb}, lok), lift_right(lf, rf, S.Slots{}, at, bt, rok)))

law compatible_union:
  for +sa: +List<U32>
  for +sb: +List<U32>
  for +a: T.Schema
  for +b: T.Schema
  for child: finite(S.All{}, a, b)
  finite(S.Pair{}, T.CompatibleUnion{sa, a}, T.CompatibleUnion{sb, b})
def compatible_union(sa, sb, a, b, child):
  (+fuel, accepted) = child
  (1n+fuel, Choice.recursive_accepts(I.identical(T.CompatibleUnion{sa, a}, T.CompatibleUnion{sb, b}), I.compatible_go(fuel, 1, a, b), accepted))

law progressive:
  for +na: +List<String>
  for +fa: T.Schema
  for +aa: +List<Bool>
  for +nb: +List<String>
  for +fb: T.Schema
  for +ab: +List<Bool>
  for positions: {I.shared_positions(I.active_fields(aa, na, fa), I.active_fields(ab, nb, fb), 0n) == True{} : Bool}
  for child: finite(S.Slots{}, I.active_fields(aa, na, fa), I.active_fields(ab, nb, fb))
  finite(S.Pair{}, T.ProgressiveContainer{na, fa, aa}, T.ProgressiveContainer{nb, fb, ab})
def progressive(na, fa, aa, nb, fb, ab, positions, child):
  (+fuel, accepted) = child
  (1n+fuel, Choice.recursive_accepts(I.identical(T.ProgressiveContainer{na, fa, aa}, T.ProgressiveContainer{nb, fb, ab}), Bool.and(I.shared_positions(I.active_fields(aa, na, fa), I.active_fields(ab, nb, fb), 0n), I.compatible_go(fuel, 3, I.active_fields(aa, na, fa), I.active_fields(ab, nb, fb))), V.and_true(I.shared_positions(I.active_fields(aa, na, fa), I.active_fields(ab, nb, fb), 0n), I.compatible_go(fuel, 3, I.active_fields(aa, na, fa), I.active_fields(ab, nb, fb)), positions, accepted)))

law slots_end_left:
  for +other: T.Schema
  finite(S.Slots{}, T.End{}, other)
def slots_end_left(other):
  match other:
    case T.Boolean{}: (1n, {==})
    case T.Unsigned{x0}: (1n, {==})
    case T.ByteVector{x0}: (1n, {==})
    case T.ByteList{x0}: (1n, {==})
    case T.BitVector{x0}: (1n, {==})
    case T.BitList{x0}: (1n, {==})
    case T.Vector{x0, x1}: (1n, {==})
    case T.ListOf{x0, x1}: (1n, {==})
    case T.Container{x0, x1}: (1n, {==})
    case T.Union{x0}: (1n, {==})
    case T.Null{}: (1n, {==})
    case T.Chain{T.Boolean{}, x1}: (1n, {==})
    case T.Chain{T.Unsigned{xc0}, x1}: (1n, {==})
    case T.Chain{T.ByteVector{xc0}, x1}: (1n, {==})
    case T.Chain{T.ByteList{xc0}, x1}: (1n, {==})
    case T.Chain{T.BitVector{xc0}, x1}: (1n, {==})
    case T.Chain{T.BitList{xc0}, x1}: (1n, {==})
    case T.Chain{T.Vector{xc0, xc1}, x1}: (1n, {==})
    case T.Chain{T.ListOf{xc0, xc1}, x1}: (1n, {==})
    case T.Chain{T.Container{xc0, xc1}, x1}: (1n, {==})
    case T.Chain{T.Union{xc0}, x1}: (1n, {==})
    case T.Chain{T.Null{}, x1}: (1n, {==})
    case T.Chain{T.Chain{xc0, xc1}, x1}: (1n, {==})
    case T.Chain{T.End{}, x1}: (1n, {==})
    case T.Chain{T.Repeat{xc0}, x1}: (1n, {==})
    case T.Chain{T.Named{xc0, xc1}, x1}: (1n, {==})
    case T.Chain{T.ProgressiveList{xc0}, x1}: (1n, {==})
    case T.Chain{T.ProgressiveBits{}, x1}: (1n, {==})
    case T.Chain{T.ProgressiveContainer{xc0, xc1, xc2}, x1}: (1n, {==})
    case T.Chain{T.CompatibleUnion{xc0, xc1}, x1}: (1n, {==})
    case T.End{}: (1n, {==})
    case T.Repeat{x0}: (1n, {==})
    case T.Named{x0, x1}: (1n, {==})
    case T.ProgressiveList{x0}: (1n, {==})
    case T.ProgressiveBits{}: (1n, {==})
    case T.ProgressiveContainer{x0, x1, x2}: (1n, {==})
    case T.CompatibleUnion{x0, x1}: (1n, {==})

law slots_end_right:
  for +other: T.Schema
  finite(S.Slots{}, other, T.End{})
def slots_end_right(other):
  match other:
    case T.Boolean{}: (1n, {==})
    case T.Unsigned{x0}: (1n, {==})
    case T.ByteVector{x0}: (1n, {==})
    case T.ByteList{x0}: (1n, {==})
    case T.BitVector{x0}: (1n, {==})
    case T.BitList{x0}: (1n, {==})
    case T.Vector{x0, x1}: (1n, {==})
    case T.ListOf{x0, x1}: (1n, {==})
    case T.Container{x0, x1}: (1n, {==})
    case T.Union{x0}: (1n, {==})
    case T.Null{}: (1n, {==})
    case T.Chain{T.Boolean{}, x1}: (1n, {==})
    case T.Chain{T.Unsigned{xc0}, x1}: (1n, {==})
    case T.Chain{T.ByteVector{xc0}, x1}: (1n, {==})
    case T.Chain{T.ByteList{xc0}, x1}: (1n, {==})
    case T.Chain{T.BitVector{xc0}, x1}: (1n, {==})
    case T.Chain{T.BitList{xc0}, x1}: (1n, {==})
    case T.Chain{T.Vector{xc0, xc1}, x1}: (1n, {==})
    case T.Chain{T.ListOf{xc0, xc1}, x1}: (1n, {==})
    case T.Chain{T.Container{xc0, xc1}, x1}: (1n, {==})
    case T.Chain{T.Union{xc0}, x1}: (1n, {==})
    case T.Chain{T.Null{}, x1}: (1n, {==})
    case T.Chain{T.Chain{xc0, xc1}, x1}: (1n, {==})
    case T.Chain{T.End{}, x1}: (1n, {==})
    case T.Chain{T.Repeat{xc0}, x1}: (1n, {==})
    case T.Chain{T.Named{xc0, xc1}, x1}: (1n, {==})
    case T.Chain{T.ProgressiveList{xc0}, x1}: (1n, {==})
    case T.Chain{T.ProgressiveBits{}, x1}: (1n, {==})
    case T.Chain{T.ProgressiveContainer{xc0, xc1, xc2}, x1}: (1n, {==})
    case T.Chain{T.CompatibleUnion{xc0, xc1}, x1}: (1n, {==})
    case T.End{}: (1n, {==})
    case T.Repeat{x0}: (1n, {==})
    case T.Named{x0, x1}: (1n, {==})
    case T.ProgressiveList{x0}: (1n, {==})
    case T.ProgressiveBits{}: (1n, {==})
    case T.ProgressiveContainer{x0, x1, x2}: (1n, {==})
    case T.CompatibleUnion{x0, x1}: (1n, {==})

law skip_left:
  for +at: T.Schema
  for +bh: T.Schema
  for +bt: T.Schema
  for child: finite(S.Slots{}, at, bt)
  finite(S.Slots{}, T.Chain{T.Null{}, at}, T.Chain{bh, bt})
def skip_left(at, bh, bt, child):
  match bh:
    case T.Boolean{}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.Unsigned{x0}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.ByteVector{x0}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.ByteList{x0}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.BitVector{x0}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.BitList{x0}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.Vector{x0, x1}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.ListOf{x0, x1}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.Container{x0, x1}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.Union{x0}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.Null{}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.Chain{x0, x1}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.End{}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.Repeat{x0}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.Named{x0, x1}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.ProgressiveList{x0}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.ProgressiveBits{}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.ProgressiveContainer{x0, x1, x2}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.CompatibleUnion{x0, x1}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)

law skip_right:
  for +ah: T.Schema
  for +at: T.Schema
  for +bt: T.Schema
  for child: finite(S.Slots{}, at, bt)
  finite(S.Slots{}, T.Chain{ah, at}, T.Chain{T.Null{}, bt})
def skip_right(ah, at, bt, child):
  match ah:
    case T.Boolean{}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.Unsigned{x0}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.ByteVector{x0}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.ByteList{x0}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.BitVector{x0}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.BitList{x0}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.Vector{x0, x1}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.ListOf{x0, x1}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.Container{x0, x1}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.Union{x0}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.Null{}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.Chain{x0, x1}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.End{}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.Repeat{x0}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.Named{x0, x1}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.ProgressiveList{x0}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.ProgressiveBits{}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.ProgressiveContainer{x0, x1, x2}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)
    case T.CompatibleUnion{x0, x1}:
      (+fuel, accepted) = child
      (1n+fuel, accepted)

law slots_named:
  for +na: String
  for +fa: T.Schema
  for +at: T.Schema
  for +nb: String
  for +fb: T.Schema
  for +bt: T.Schema
  for names: {String.eq(na, nb) == True{} : Bool}
  for head: finite(S.Pair{}, fa, fb)
  for tail: finite(S.Slots{}, at, bt)
  finite(S.Slots{}, T.Chain{T.Named{na, fa}, at}, T.Chain{T.Named{nb, fb}, bt})
def slots_named(na, fa, at, nb, fb, bt, names, head, tail):
  slots(na, fa, at, nb, fb, bt, Named(fa, fb, na, nb, names, head), tail)
