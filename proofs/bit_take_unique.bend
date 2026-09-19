import Base
import ../src/bit_decode.bend as D
import ./word_facts.bend as W
import ./primitive_invariants.bend as V

def present(r: Maybe<&2, +List<Bool>>) -> Bool:
  match r:
    case None{}: False{}
    case Some{xs}: True{}

def head(r: Maybe<&2, +List<Bool>>) -> Bool:
  match r:
    case None{}: False{}
    case Some{xs}:
      match xs:
        case Nil{}: False{}
        case Con{h, t}: h

def tail(r: Maybe<&2, +List<Bool>>) -> Maybe<&2, +List<Bool>>:
  match r:
    case None{}: None{}
    case Some{xs}:
      match xs:
        case Nil{}: None{}
        case Con{h, t}: Some{t}

law cons_present:
  for b: Bool
  for +r: Maybe<&2, +List<Bool>>
  {present(D.cons(b, r)) == present(r) : Bool}
def cons_present(b, r):
  match r:
    case None{}: {==}
    case Some{xs}: {==}

law cons_tail:
  for b: Bool
  for +r: Maybe<&2, +List<Bool>>
  {tail(D.cons(b, r)) == r : Maybe<&2, +List<Bool>>}
def cons_tail(b, r):
  match r:
    case None{}: {==}
    case Some{xs}: {==}

law cons_head:
  for +b: Bool
  for +r: Maybe<&2, +List<Bool>>
  for e: {present(r) == True{} : Bool}
  {head(D.cons(b, r)) == b : Bool}
def cons_head(b, r, e):
  match r:
    case None{}: Empty.absurd({head(D.cons(b, None{})) == b : Bool}, W.false_true(e))
    case Some{xs}: {==}

law accept_present:
  for +ok: Bool
  for bits: +List<Bool>
  {present(D.accept(ok, bits)) == ok : Bool}
def accept_present(ok, bits):
  match ok:
    case False{}: {==}
    case True{}: {==}

def predecessor(n: Nat) -> Nat:
  match n:
    case 0n: 0n
    case 1n+p: p

law successor_injective:
  for +a: Nat
  for +b: Nat
  for e: {1n+a == 1n+b : Nat}
  {a == b : Nat}
def successor_injective(a, b, e):
  Equal.cong(Nat, Nat, predecessor, 1n+a, 1n+b, e)

law not_true_false:
  for +b: Bool
  for e: {Bool.not(b) == True{} : Bool}
  {b == False{} : Bool}
def not_true_false(b, e):
  match b:
    case False{}: {==}
    case True{}: Empty.absurd({True{} == False{} : Bool}, W.false_true(e))

# Equal-length all-zero tails are identical; this is not an assumption that
# padding may have arbitrary values.
law zero_unique:
  for +xs: +List<Bool>
  for +ys: +List<Bool>
  for size: {List.length(&2, Bool, xs) == List.length(&2, Bool, ys) : Nat}
  for +ex: {D.all_zero(xs) == True{} : Bool}
  for +ey: {D.all_zero(ys) == True{} : Bool}
  {xs == ys : +List<Bool>}
def zero_unique(xs, ys, size, ex, ey):
  match xs ys:
    case Nil{} Nil{}: {==}
    case Nil{} Con{h, t}:
      Empty.absurd({[] == h <> t : +List<Bool>}, W.false_true(Equal.cong(Nat, Bool, n => Nat.is_eq(n, 0n), 1n+List.length(&2, Bool, t), 0n, Equal.sym(Nat, 0n, 1n+List.length(&2, Bool, t), size))))
    case Con{h, t} Nil{}:
      Empty.absurd({h <> t == [] : +List<Bool>}, W.false_true(Equal.cong(Nat, Bool, n => Nat.is_eq(n, 0n), 1n+List.length(&2, Bool, t), 0n, size)))
    case Con{h, t} Con{k, u}:
      %Equal.sym(Bool, h, False{}, not_true_false(h, V.and_left(Bool.not(h), D.all_zero(t), ex))) : {_ <> t == k <> u : +List<Bool>}
      %Equal.sym(Bool, k, False{}, not_true_false(k, V.and_left(Bool.not(k), D.all_zero(u), ey))) : {False{} <> t == _ <> u : +List<Bool>}
      Equal.cong(+List<Bool>, +List<Bool>, zs => False{} <> zs, t, u, zero_unique(t, u, successor_injective(List.length(&2, Bool, t), List.length(&2, Bool, u), size), V.and_right(Bool.not(h), D.all_zero(t), ex), V.and_right(Bool.not(k), D.all_zero(u), ey)))

law cons_inputs_equal:
  for +h: Bool
  for +r: Maybe<&2, +List<Bool>>
  for +k: Bool
  for +s: Maybe<&2, +List<Bool>>
  for e: {D.cons(h, r) == D.cons(k, s) : Maybe<&2, +List<Bool>>}
  {r == s : Maybe<&2, +List<Bool>>}
def cons_inputs_equal(h, r, k, s, e):
  Equal.trans(Maybe<&2, +List<Bool>>, r, tail(D.cons(h, r)), s,
    Equal.sym(Maybe<&2, +List<Bool>>, tail(D.cons(h, r)), r, cons_tail(h, r)),
    Equal.trans(Maybe<&2, +List<Bool>>, tail(D.cons(h, r)), tail(D.cons(k, s)), s,
      Equal.cong(Maybe<&2, +List<Bool>>, Maybe<&2, +List<Bool>>, tail, D.cons(h, r), D.cons(k, s), e), cons_tail(k, s)))

law cons_heads_equal:
  for +h: Bool
  for +r: Maybe<&2, +List<Bool>>
  for +k: Bool
  for +s: Maybe<&2, +List<Bool>>
  for +e: {D.cons(h, r) == D.cons(k, s) : Maybe<&2, +List<Bool>>}
  for +ok: {present(r) == True{} : Bool}
  {h == k : Bool}
def cons_heads_equal(h, r, k, s, e, ok):
  Equal.trans(Bool, h, head(D.cons(h, r)), k, Equal.sym(Bool, head(D.cons(h, r)), h, cons_head(h, r, ok)),
    Equal.trans(Bool, head(D.cons(h, r)), head(D.cons(k, s)), k,
      Equal.cong(Maybe<&2, +List<Bool>>, Bool, head, D.cons(h, r), D.cons(k, s), e),
      cons_head(k, s, Equal.trans(Bool, present(s), present(r), True{}, Equal.cong(Maybe<&2, +List<Bool>>, Bool, present, s, r, Equal.sym(Maybe<&2, +List<Bool>>, r, s, cons_inputs_equal(h, r, k, s, e))), ok))))

law take_unique:
  for +n: Nat
  for +xs: +List<Bool>
  for +ys: +List<Bool>
  for size: {List.length(&2, Bool, xs) == List.length(&2, Bool, ys) : Nat}
  for +e: {D.take(n, xs) == D.take(n, ys) : Maybe<&2, +List<Bool>>}
  for +ok: {present(D.take(n, xs)) == True{} : Bool}
  {xs == ys : +List<Bool>}
def take_unique(n, xs, ys, size, e, ok):
  match n:
    case 0n:
      zero_unique(xs, ys, size,
        Equal.trans(Bool, D.all_zero(xs), present(D.accept(D.all_zero(xs), [])), True{}, Equal.sym(Bool, present(D.accept(D.all_zero(xs), [])), D.all_zero(xs), accept_present(D.all_zero(xs), [])), ok),
        Equal.trans(Bool, D.all_zero(ys), present(D.accept(D.all_zero(ys), [])), True{}, Equal.sym(Bool, present(D.accept(D.all_zero(ys), [])), D.all_zero(ys), accept_present(D.all_zero(ys), [])), Equal.trans(Bool, present(D.take(0n, ys)), present(D.take(0n, xs)), True{}, Equal.cong(Maybe<&2, +List<Bool>>, Bool, present, D.take(0n, ys), D.take(0n, xs), Equal.sym(Maybe<&2, +List<Bool>>, D.take(0n, xs), D.take(0n, ys), e)), ok)))
    case 1n+p:
      match xs ys:
        case Nil{} Nil{}: {==}
        case Nil{} Con{k, u}: Empty.absurd({[] == k <> u : +List<Bool>}, W.false_true(ok))
        case Con{h, t} Nil{}:
          Empty.absurd({h <> t == [] : +List<Bool>}, W.false_true(Equal.trans(Bool, present(None{}), present(D.take(1n+p, h <> t)), True{}, Equal.cong(Maybe<&2, +List<Bool>>, Bool, present, None{}, D.take(1n+p, h <> t), Equal.sym(Maybe<&2, +List<Bool>>, D.take(1n+p, h <> t), None{}, e)), ok)))
        case Con{h, t} Con{k, u}:
          +tail_ok = Equal.trans(Bool, present(D.take(p, t)), present(D.cons(h, D.take(p, t))), True{}, Equal.sym(Bool, present(D.cons(h, D.take(p, t))), present(D.take(p, t)), cons_present(h, D.take(p, t))), ok)
          %cons_heads_equal(h, D.take(p, t), k, D.take(p, u), e, tail_ok) : {h <> t == _ <> u : +List<Bool>}
          Equal.cong(+List<Bool>, +List<Bool>, zs => h <> zs, t, u, take_unique(p, t, u, successor_injective(List.length(&2, Bool, t), List.length(&2, Bool, u), size), cons_inputs_equal(h, D.take(p, t), k, D.take(p, u), e), tail_ok))
