import Base
import ../types/schema.bend as T
import ../spec/compatibility.bend as S
import ./primitive_invariants.bend as V

def evidence(+mode: S.Judgement, +a: T.Schema, +b: T.Schema) -> Type:
  Exists(S.Derivation, witness => {S.derives(witness, mode, a, b) == True{} : Bool})

law vector:
  for +a: T.Schema
  for +b: T.Schema
  for +n: Nat
  for +m: Nat
  for size: {Nat.is_eq(n, m) == True{} : Bool}
  for child: S.compatible(a, b)
  S.compatible(T.Vector{a, n}, T.Vector{b, m})
def vector(a, b, n, m, size, child):
  (+w, correct) = child
  (S.Step{w}, V.and_true(Nat.is_eq(n, m), S.derives(w, S.Pair{}, a, b), size, correct))

law list:
  for +a: T.Schema
  for +b: T.Schema
  for +n: Nat
  for +m: Nat
  for size: {Nat.is_eq(n, m) == True{} : Bool}
  for child: S.compatible(a, b)
  S.compatible(T.ListOf{a, n}, T.ListOf{b, m})
def list(a, b, n, m, size, child):
  (+w, correct) = child
  (S.Step{w}, V.and_true(Nat.is_eq(n, m), S.derives(w, S.Pair{}, a, b), size, correct))

law progressive_list:
  for +a: T.Schema
  for +b: T.Schema
  for child: S.compatible(a, b)
  S.compatible(T.ProgressiveList{a}, T.ProgressiveList{b})
def progressive_list(a, b, child):
  (+w, correct) = child
  (S.Step{w}, correct)

law named:
  for +na: String
  for +nb: String
  for +a: T.Schema
  for +b: T.Schema
  for names: {String.eq(na, nb) == True{} : Bool}
  for child: S.compatible(a, b)
  S.compatible(T.Named{na, a}, T.Named{nb, b})
def named(na, nb, a, b, names, child):
  (+w, correct) = child
  (S.Step{w}, V.and_true(String.eq(na, nb), S.derives(w, S.Pair{}, a, b), names, correct))

law container:
  for +na: +List<String>
  for +nb: +List<String>
  for +a: T.Schema
  for +b: T.Schema
  for names: {S.names_equal(na, nb) == True{} : Bool}
  for child: S.compatible(a, b)
  S.compatible(T.Container{na, a}, T.Container{nb, b})
def container(na, nb, a, b, names, child):
  (+w, correct) = child
  (S.Step{w}, V.and_true(S.names_equal(na, nb), S.derives(w, S.Pair{}, a, b), names, correct))

law chain:
  for +a: T.Schema
  for +at: T.Schema
  for +b: T.Schema
  for +bt: T.Schema
  for head: S.compatible(a, b)
  for tail: S.compatible(at, bt)
  S.compatible(T.Chain{a, at}, T.Chain{b, bt})
def chain(a, at, b, bt, head, tail):
  (+wh, eh) = head
  (+wt, et) = tail
  (S.Fork{wh, wt}, V.and_true(S.derives(wh, S.Pair{}, a, b), S.derives(wt, S.Pair{}, at, bt), eh, et))

law all:
  for +head: T.Schema
  for +tail: T.Schema
  for +b: T.Schema
  for row: evidence(S.Row{}, head, b)
  for rest: evidence(S.All{}, tail, b)
  evidence(S.All{}, T.Chain{head, tail}, b)
def all(head, tail, b, row, rest):
  (+wh, eh) = row
  (+wt, et) = rest
  (S.Fork{wh, wt}, V.and_true(S.derives(wh, S.Row{}, head, b), S.derives(wt, S.All{}, tail, b), eh, et))

law row:
  for +a: T.Schema
  for +head: T.Schema
  for +tail: T.Schema
  for item: S.compatible(a, head)
  for rest: evidence(S.Row{}, a, tail)
  evidence(S.Row{}, a, T.Chain{head, tail})
def row(a, head, tail, item, rest):
  (+wh, eh) = item
  (+wt, et) = rest
  (S.Fork{wh, wt}, V.and_true(S.derives(wh, S.Pair{}, a, head), S.derives(wt, S.Row{}, a, tail), eh, et))

law union:
  for +sa: +List<U32>
  for +sb: +List<U32>
  for +a: T.Schema
  for +b: T.Schema
  for options: evidence(S.All{}, a, b)
  S.compatible(T.CompatibleUnion{sa, a}, T.CompatibleUnion{sb, b})
def union(sa, sb, a, b, options):
  (+w, correct) = options
  (S.Step{w}, correct)

law skip_both:
  for +a: T.Schema
  for +b: T.Schema
  for rest: evidence(S.Slots{}, a, b)
  evidence(S.Slots{}, T.Chain{T.Null{}, a}, T.Chain{T.Null{}, b})
def skip_both(a, b, rest):
  (+w, correct) = rest
  (S.Step{w}, correct)

law skip_left:
  for +a: T.Schema
  for +name: String
  for +field: T.Schema
  for +b: T.Schema
  for rest: evidence(S.Slots{}, a, b)
  evidence(S.Slots{}, T.Chain{T.Null{}, a}, T.Chain{T.Named{name, field}, b})
def skip_left(a, name, field, b, rest):
  (+w, correct) = rest
  (S.Step{w}, correct)

law skip_right:
  for +name: String
  for +field: T.Schema
  for +a: T.Schema
  for +b: T.Schema
  for rest: evidence(S.Slots{}, a, b)
  evidence(S.Slots{}, T.Chain{T.Named{name, field}, a}, T.Chain{T.Null{}, b})
def skip_right(name, field, a, b, rest):
  (+w, correct) = rest
  (S.Step{w}, correct)

law slots_named:
  for +na: String
  for +fa: T.Schema
  for +a: T.Schema
  for +nb: String
  for +fb: T.Schema
  for +b: T.Schema
  for names: {String.eq(na, nb) == True{} : Bool}
  for fields: S.compatible(fa, fb)
  for rest: evidence(S.Slots{}, a, b)
  evidence(S.Slots{}, T.Chain{T.Named{na, fa}, a}, T.Chain{T.Named{nb, fb}, b})
def slots_named(na, fa, a, nb, fb, b, names, fields, rest):
  (+wh, eh) = fields
  (+wt, et) = rest
  (S.Fork{wh, wt}, V.and_true(String.eq(na, nb), Bool.and(S.derives(wh, S.Pair{}, fa, fb), S.derives(wt, S.Slots{}, a, b)), names, V.and_true(S.derives(wh, S.Pair{}, fa, fb), S.derives(wt, S.Slots{}, a, b), eh, et)))

law progressive_container:
  for +na: +List<String>
  for +fa: T.Schema
  for +aa: +List<Bool>
  for +nb: +List<String>
  for +fb: T.Schema
  for +ab: +List<Bool>
  for positions: {S.shared_positions(S.slots(aa, na, fa), S.slots(ab, nb, fb), 0n) == True{} : Bool}
  for fields: evidence(S.Slots{}, S.slots(aa, na, fa), S.slots(ab, nb, fb))
  S.compatible(T.ProgressiveContainer{na, fa, aa}, T.ProgressiveContainer{nb, fb, ab})
def progressive_container(na, fa, aa, nb, fb, ab, positions, fields):
  (+w, correct) = fields
  (S.Step{w}, V.and_true(S.shared_positions(S.slots(aa, na, fa), S.slots(ab, nb, fb), 0n), S.derives(w, S.Slots{}, S.slots(aa, na, fa), S.slots(ab, nb, fb)), positions, correct))
