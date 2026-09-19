import Base
import ../src/lists.bend as I
import ./packing.bend as Pack

law length_go_correct:
  for -A: Data
  for +xs: +List<A>
  for +acc: Nat
  {I.length_go(A, xs, acc) == Nat.add(List.length(&2, A, xs), acc) : Nat}
def length_go_correct(A, xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Pack.add_succ(List.length(&2, A, t), acc) : {I.length_go(A, t, 1n+acc) == _ : Nat}
      length_go_correct(A, t, 1n+acc)

law length_correct:
  for -A: Data
  for +xs: +List<A>
  {I.length(A, xs) == List.length(&2, A, xs) : Nat}
def length_correct(A, xs):
  Equal.trans(Nat, I.length(A, xs), Nat.add(List.length(&2, A, xs), 0n), List.length(&2, A, xs), length_go_correct(A, xs, 0n), Pack.add_zero(List.length(&2, A, xs)))

law reverse_acc:
  for -A: Data
  for +xs: +List<A>
  for +ys: +List<A>
  for +zs: +List<A>
  {List.reverse.go(&2, A, List.reverse.go(&2, A, xs, ys), zs) == List.reverse.go(&2, A, ys, List.append(&2, A, xs, zs)) : +List<A>}
def reverse_acc(A, xs, ys, zs):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: reverse_acc(A, t, h <> ys, zs)

law append_correct:
  for -A: Data
  for +xs: +List<A>
  for +ys: +List<A>
  {I.append(A, xs, ys) == List.append(&2, A, xs, ys) : +List<A>}
def append_correct(A, xs, ys): reverse_acc(A, xs, [], ys)

law replicate_cons:
  for -A: Data
  for +n: Nat
  for +x: A
  for +acc: +List<A>
  {I.replicate_go(A, n, x, x <> acc) == x <> I.replicate_go(A, n, x, acc) : +List<A>}
def replicate_cons(A, n, x, acc):
  match n:
    case 0n: {==}
    case 1n+p: replicate_cons(A, p, x, x <> acc)

law replicate_correct:
  for -A: Data
  for +n: Nat
  for +x: A
  {I.replicate(A, n, x) == List.replicate(A, n, x) : +List<A>}
def replicate_correct(A, n, x):
  match n:
    case 0n: {==}
    case 1n+p:
      Equal.trans(+List<A>, I.replicate_go(A, p, x, [x]), x <> I.replicate(A, p, x), x <> List.replicate(A, p, x), replicate_cons(A, p, x, []), Equal.cong(+List<A>, +List<A>, xs => x <> xs, I.replicate(A, p, x), List.replicate(A, p, x), replicate_correct(A, p, x)))

law append_length:
  for -A: Data
  for +xs: +List<A>
  for +ys: +List<A>
  {List.length(&2, A, List.append(&2, A, xs, ys)) == Nat.add(List.length(&2, A, xs), List.length(&2, A, ys)) : Nat}
def append_length(A, xs, ys):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Equal.cong(Nat, Nat, n => 1n+n, List.length(&2, A, List.append(&2, A, t, ys)), Nat.add(List.length(&2, A, t), List.length(&2, A, ys)), append_length(A, t, ys))

law reverse_append:
  for -A: Data
  for +xs: +List<A>
  for +ys: +List<A>
  for +acc: +List<A>
  {List.reverse.go(&2, A, List.append(&2, A, xs, ys), acc) == List.reverse.go(&2, A, ys, List.reverse.go(&2, A, xs, acc)) : +List<A>}
def reverse_append(A, xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: reverse_append(A, t, ys, h <> acc)

law append_empty:
  for -A: Data
  for +xs: +List<A>
  {List.append(&2, A, xs, []) == xs : +List<A>}
def append_empty(A, xs):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Equal.cong(+List<A>, +List<A>, ys => h <> ys, List.append(&2, A, t, []), t, append_empty(A, t))

law reverse_twice:
  for -A: Data
  for +xs: +List<A>
  {List.reverse(&2, A, List.reverse(&2, A, xs)) == xs : +List<A>}
def reverse_twice(A, xs):
  Equal.trans(+List<A>, List.reverse(&2, A, List.reverse(&2, A, xs)), List.append(&2, A, xs, []), xs, reverse_acc(A, xs, [], []), append_empty(A, xs))

law reverse_acc_append:
  for -A: Data
  for +xs: +List<A>
  for +ys: +List<A>
  for +zs: +List<A>
  {List.reverse.go(&2, A, xs, List.append(&2, A, ys, zs)) == List.append(&2, A, List.reverse.go(&2, A, xs, ys), zs) : +List<A>}
def reverse_acc_append(A, xs, ys, zs):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: reverse_acc_append(A, t, h <> ys, zs)

law append_associative:
  for -A: Data
  for +xs: +List<A>
  for +ys: +List<A>
  for +zs: +List<A>
  {List.append(&2, A, List.append(&2, A, xs, ys), zs) == List.append(&2, A, xs, List.append(&2, A, ys, zs)) : +List<A>}
def append_associative(A, xs, ys, zs):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Equal.cong(+List<A>, +List<A>, tail => h <> tail, List.append(&2, A, List.append(&2, A, t, ys), zs), List.append(&2, A, t, List.append(&2, A, ys, zs)), append_associative(A, t, ys, zs))
