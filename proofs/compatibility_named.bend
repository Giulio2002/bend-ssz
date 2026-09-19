import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ./compatibility_monotone.bend as M
import ./packing.bend as Pack
import ./primitive_invariants.bend as V
import ./word_facts.bend as W

law successor:
  for +n: Nat
  {Nat.add(n, 1n) == 1n+n : Nat}
def successor(n):
  Equal.trans(Nat, Nat.add(n, 1n), 1n+Nat.add(n, 0n), 1n+n, Pack.add_succ(n, 0n), Equal.cong(Nat, Nat, x => 1n+x, Nat.add(n, 0n), n, Pack.add_zero(n)))

law pair_step:
  for +fuel: Nat
  for +a: T.Schema
  for +b: T.Schema
  for accepted: {I.compatible_go(fuel, 0, a, b) == True{} : Bool}
  {I.compatible_go(1n+fuel, 0, a, b) == True{} : Bool}
def pair_step(fuel, a, b, accepted):
  %successor(fuel) : {I.compatible_go(_, 0, a, b) == True{} : Bool}
  M.monotone(fuel, 1n, M.Pair{}, a, b, accepted)

law names:
  for +fuel: Nat
  for +na: String
  for +a: T.Schema
  for +nb: String
  for +b: T.Schema
  for accepted: {I.compatible_go(fuel, 0, T.Named{na, a}, T.Named{nb, b}) == True{} : Bool}
  {String.eq(na, nb) == True{} : Bool}
def names(fuel, na, a, nb, b, accepted):
  match fuel:
    case 0n: Empty.absurd({String.eq(na, nb) == True{} : Bool}, W.false_true(accepted))
    case 1n+p: V.and_left(String.eq(na, nb), I.compatible_go(p, 0, a, b), accepted)

law child:
  for +fuel: Nat
  for +na: String
  for +a: T.Schema
  for +nb: String
  for +b: T.Schema
  for accepted: {I.compatible_go(fuel, 0, T.Named{na, a}, T.Named{nb, b}) == True{} : Bool}
  {I.compatible_go(fuel, 0, a, b) == True{} : Bool}
def child(fuel, na, a, nb, b, accepted):
  match fuel:
    case 0n: Empty.absurd({I.compatible_go(0n, 0, a, b) == True{} : Bool}, W.false_true(accepted))
    case 1n+p: pair_step(p, a, b, V.and_right(String.eq(na, nb), I.compatible_go(p, 0, a, b), accepted))
