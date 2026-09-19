import Base
import ./nat_order.bend as Order
import ../spec/primitives.bend as P
import ./primitive_invariants.bend as V
import ../src/layout.bend as I
import ../spec/layout_decoding.bend as S
import ./lists.bend as L

law reverse_cons_acc:
  for +acc: +List<U32>
  for +h: U32
  for +tail: +List<U32>
  {List.reverse.go(&2, U32, h <> acc, tail) == List.reverse.go(&2, U32, acc, h <> tail) : +List<U32>}
def reverse_cons_acc(acc, h, tail): {==}

law split_prefix_acc:
  for +prefix: +List<U32>
  for +rest: +List<U32>
  for +acc: +List<U32>
  {I.split_go(List.length(&2, U32, prefix), List.append(&2, U32, prefix, rest), acc) == Some{I.Split{List.reverse.go(&2, U32, acc, prefix), rest}} : Maybe<&2, I.Split>}
def split_prefix_acc(prefix, rest, acc):
  match prefix:
    case Nil{}: {==}
    case Con{h, t}: split_prefix_acc(t, rest, h <> acc)

law split_prefix:
  for +prefix: +List<U32>
  for +rest: +List<U32>
  {I.split(List.length(&2, U32, prefix), List.append(&2, U32, prefix, rest)) == Some{I.Split{prefix, rest}} : Maybe<&2, I.Split>}
def split_prefix(prefix, rest): split_prefix_acc(prefix, rest, [])

law cut_prefix:
  for +prefix: +List<U32>
  for +rest: +List<U32>
  {S.cut(List.length(&2, U32, prefix), List.append(&2, U32, prefix, rest)) == Some{S.Slice{prefix, rest}} : Maybe<&2, S.Slice>}
def cut_prefix(prefix, rest):
  match prefix:
    case Nil{}: {==}
    case Con{h, t}: Equal.cong(Maybe<&2, S.Slice>, Maybe<&2, S.Slice>, result => S.prepend_slice(h, result), S.cut(List.length(&2, U32, t), List.append(&2, U32, t, rest)), Some{S.Slice{t, rest}}, cut_prefix(t, rest))

law split_short_acc:
  for +xs: +List<U32>
  for +extra: Nat
  for +acc: +List<U32>
  {I.split_go(Nat.add(List.length(&2, U32, xs), 1n+extra), xs, acc) == None{} : Maybe<&2, I.Split>}
def split_short_acc(xs, extra, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: split_short_acc(t, extra, h <> acc)

law split_short:
  for +xs: +List<U32>
  for +extra: Nat
  {I.split(Nat.add(List.length(&2, U32, xs), 1n+extra), xs) == None{} : Maybe<&2, I.Split>}
def split_short(xs, extra): split_short_acc(xs, extra, [])

# Proof-only representation map; the specification never calls this map or
# the implementation. At the public empty accumulator it is just cut.
def abstract(result: Maybe<&2, I.Split>) -> Maybe<&2, S.Slice>:
  match result:
    case None{}: None{}
    case Some{I.Split{xs, rest}}: Some{S.Slice{xs, rest}}

def extend(acc: +List<U32>, result: Maybe<&2, S.Slice>) -> Maybe<&2, S.Slice>:
  match result:
    case None{}: None{}
    case Some{S.Slice{xs, rest}}: Some{S.Slice{List.reverse.go(&2, U32, acc, xs), rest}}

law extend_cons:
  for +h: U32
  for +acc: +List<U32>
  for +result: Maybe<&2, S.Slice>
  {extend(h <> acc, result) == extend(acc, S.prepend_slice(h, result)) : Maybe<&2, S.Slice>}
def extend_cons(h, acc, result):
  match result:
    case None{}: {==}
    case Some{S.Slice{xs, rest}}: {==}

law split_acc_correct:
  for +n: Nat
  for +xs: +List<U32>
  for +acc: +List<U32>
  {abstract(I.split_go(n, xs, acc)) == extend(acc, S.cut(n, xs)) : Maybe<&2, S.Slice>}
def split_acc_correct(n, xs, acc):
  match n:
    case 0n: {==}
    case 1n+p:
      match xs:
        case Nil{}: {==}
        case Con{h, t}:
          Equal.trans(Maybe<&2, S.Slice>, abstract(I.split_go(p, t, h <> acc)), extend(h <> acc, S.cut(p, t)), extend(acc, S.prepend_slice(h, S.cut(p, t))), split_acc_correct(p, t, h <> acc), extend_cons(h, acc, S.cut(p, t)))

law extend_empty:
  for +result: Maybe<&2, S.Slice>
  {extend([], result) == result : Maybe<&2, S.Slice>}
def extend_empty(result):
  match result:
    case None{}: {==}
    case Some{S.Slice{xs, rest}}: {==}

law split_correct:
  for +n: Nat
  for +xs: +List<U32>
  {abstract(I.split(n, xs)) == S.cut(n, xs) : Maybe<&2, S.Slice>}
def split_correct(n, xs):
  Equal.trans(Maybe<&2, S.Slice>, abstract(I.split(n, xs)), extend([], S.cut(n, xs)), S.cut(n, xs), split_acc_correct(n, xs, []), extend_empty(S.cut(n, xs)))

# Successful slices partition the byte domain; failure has no output value.
def domain(result: Maybe<&2, S.Slice>) -> Bool:
  match result:
    case None{}: True{}
    case Some{S.Slice{prefix, rest}}: Bool.and(P.bytes_domain(prefix), P.bytes_domain(rest))

law prepend_domain:
  for +h: U32
  for +result: Maybe<&2, S.Slice>
  for byte: {U32.is_lt(h, 256) == True{} : Bool}
  for +valid: {domain(result) == True{} : Bool}
  {domain(S.prepend_slice(h, result)) == True{} : Bool}
def prepend_domain(h, result, byte, valid):
  match result:
    case None{}: {==}
    case Some{S.Slice{prefix, rest}}:
      V.and_true(Bool.and(U32.is_lt(h, 256), P.bytes_domain(prefix)), P.bytes_domain(rest), V.and_true(U32.is_lt(h, 256), P.bytes_domain(prefix), byte, V.and_left(P.bytes_domain(prefix), P.bytes_domain(rest), valid)), V.and_right(P.bytes_domain(prefix), P.bytes_domain(rest), valid))

law cut_domain:
  for +n: Nat
  for +xs: +List<U32>
  for +valid: {P.bytes_domain(xs) == True{} : Bool}
  {domain(S.cut(n, xs)) == True{} : Bool}
def cut_domain(n, xs, valid):
  match n:
    case 0n: valid
    case 1n+p:
      match xs:
        case Nil{}: {==}
        case Con{h, t}: prepend_domain(h, S.cut(p, t), V.and_left(U32.is_lt(h, 256), P.bytes_domain(t), valid), cut_domain(p, t, V.and_right(U32.is_lt(h, 256), P.bytes_domain(t), valid)))

# In addition to byte-domain preservation, a successful cut consumes exactly n
# elements and reconstructs the entire original input without loss or overlap.
def partition(n: Nat, xs: +List<U32>, result: Maybe<&2, S.Slice>) -> Type:
  match result:
    case None{}: Unit
    case Some{S.Slice{prefix, rest}}:
      {List.length(&2, U32, prefix) == n : Nat} & {List.append(&2, U32, prefix, rest) == xs : +List<U32>}

law prepend_partition:
  for +h: U32
  for +n: Nat
  for +xs: +List<U32>
  for +result: Maybe<&2, S.Slice>
  for exact: partition(n, xs, result)
  partition(1n+n, h <> xs, S.prepend_slice(h, result))
def prepend_partition(h, n, xs, result, exact):
  match result:
    case None{}: Unit{}
    case Some{S.Slice{prefix, rest}}:
      (length, content) = exact
      (Equal.cong(Nat, Nat, k => 1n+k, List.length(&2, U32, prefix), n, length), Equal.cong(+List<U32>, +List<U32>, tail => h <> tail, List.append(&2, U32, prefix, rest), xs, content))

law cut_partition:
  for +n: Nat
  for +xs: +List<U32>
  partition(n, xs, S.cut(n, xs))
def cut_partition(n, xs):
  match n:
    case 0n: ({==}, {==})
    case 1n+p:
      match xs:
        case Nil{}: Unit{}
        case Con{h, t}: prepend_partition(h, p, t, S.cut(p, t), cut_partition(p, t))

law split_partition:
  for +n: Nat
  for +xs: +List<U32>
  partition(n, xs, abstract(I.split(n, xs)))
def split_partition(n, xs):
  %Equal.sym(Maybe<&2, S.Slice>, abstract(I.split(n, xs)), S.cut(n, xs), split_correct(n, xs)) : partition(n, xs, _)
  cut_partition(n, xs)

law partition_length:
  for +n: Nat
  for +xs: +List<U32>
  for +prefix: +List<U32>
  for +rest: +List<U32>
  for exact: partition(n, xs, Some{S.Slice{prefix, rest}})
  {Nat.add(n, List.length(&2, U32, rest)) == List.length(&2, U32, xs) : Nat}
def partition_length(n, xs, prefix, rest, exact):
  (length, content) = exact
  %length : {Nat.add(_, List.length(&2, U32, rest)) == List.length(&2, U32, xs) : Nat}
  %content : {Nat.add(List.length(&2, U32, prefix), List.length(&2, U32, rest)) == List.length(&2, U32, _) : Nat}
  Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, prefix, rest)), Nat.add(List.length(&2, U32, prefix), List.length(&2, U32, rest)), L.append_length(U32, prefix, rest))

law accepted_split_partition:
  for +n: Nat
  for +xs: +List<U32>
  for +prefix: +List<U32>
  for +rest: +List<U32>
  for accepted: {I.split(n, xs) == Some{I.Split{prefix, rest}} : Maybe<&2, I.Split>}
  partition(n, xs, Some{S.Slice{prefix, rest}})
def accepted_split_partition(n, xs, prefix, rest, accepted):
  %accepted : partition(n, xs, abstract(_))
  split_partition(n, xs)

law split_consumed_length:
  for +n: Nat
  for +xs: +List<U32>
  for +prefix: +List<U32>
  for +rest: +List<U32>
  for accepted: {I.split(n, xs) == Some{I.Split{prefix, rest}} : Maybe<&2, I.Split>}
  {Nat.add(n, List.length(&2, U32, rest)) == List.length(&2, U32, xs) : Nat}
def split_consumed_length(n, xs, prefix, rest, accepted):
  partition_length(n, xs, prefix, rest, accepted_split_partition(n, xs, prefix, rest, accepted))

law split_consumes_at_most:
  for +n: Nat
  for +xs: +List<U32>
  for +prefix: +List<U32>
  for +rest: +List<U32>
  for accepted: {I.split(n, xs) == Some{I.Split{prefix, rest}} : Maybe<&2, I.Split>}
  {Nat.is_le(n, List.length(&2, U32, xs)) == True{} : Bool}
def split_consumes_at_most(n, xs, prefix, rest, accepted):
  %split_consumed_length(n, xs, prefix, rest, accepted) : {Nat.is_le(n, _) == True{} : Bool}
  Order.below_sum(n, List.length(&2, U32, rest))

law partition_prefix_bound:
  for +n: Nat
  for +xs: +List<U32>
  for +prefix: +List<U32>
  for +rest: +List<U32>
  for exact: partition(n, xs, Some{S.Slice{prefix, rest}})
  {Nat.is_le(List.length(&2, U32, prefix), List.length(&2, U32, xs)) == True{} : Bool}
def partition_prefix_bound(n, xs, prefix, rest, exact):
  (length, content) = exact
  %content : {Nat.is_le(List.length(&2, U32, prefix), List.length(&2, U32, _)) == True{} : Bool}
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, prefix, rest)), Nat.add(List.length(&2, U32, prefix), List.length(&2, U32, rest)), L.append_length(U32, prefix, rest)) : {Nat.is_le(List.length(&2, U32, prefix), _) == True{} : Bool}
  Order.below_sum(List.length(&2, U32, prefix), List.length(&2, U32, rest))

law partition_rest_bound:
  for +n: Nat
  for +xs: +List<U32>
  for +prefix: +List<U32>
  for +rest: +List<U32>
  for exact: partition(n, xs, Some{S.Slice{prefix, rest}})
  {Nat.is_le(List.length(&2, U32, rest), List.length(&2, U32, xs)) == True{} : Bool}
def partition_rest_bound(n, xs, prefix, rest, exact):
  %partition_length(n, xs, prefix, rest, exact) : {Nat.is_le(List.length(&2, U32, rest), _) == True{} : Bool}
  Order.left_below_sum(n, List.length(&2, U32, rest))

def bounded(maximum: Nat, result: Maybe<&2, S.Slice>) -> Type:
  match result:
    case None{}: Unit
    case Some{S.Slice{prefix, rest}}:
      {Nat.is_le(List.length(&2, U32, prefix), maximum) == True{} : Bool} & {Nat.is_le(List.length(&2, U32, rest), maximum) == True{} : Bool}

law partition_bounds:
  for +n: Nat
  for +xs: +List<U32>
  for +result: Maybe<&2, S.Slice>
  for +maximum: Nat
  for +input_bound: {Nat.is_le(List.length(&2, U32, xs), maximum) == True{} : Bool}
  for exact: partition(n, xs, result)
  bounded(maximum, result)
def partition_bounds(n, xs, result, maximum, input_bound, exact):
  match result:
    case None{}: Unit{}
    case Some{S.Slice{prefix, rest}}:
      (+length, +content) = exact
      (Order.transitive(List.length(&2, U32, prefix), List.length(&2, U32, xs), maximum, partition_prefix_bound(n, xs, prefix, rest, (length, content)), input_bound), Order.transitive(List.length(&2, U32, rest), List.length(&2, U32, xs), maximum, partition_rest_bound(n, xs, prefix, rest, (length, content)), input_bound))

law cut_bounds:
  for +n: Nat
  for +xs: +List<U32>
  for +maximum: Nat
  for input_bound: {Nat.is_le(List.length(&2, U32, xs), maximum) == True{} : Bool}
  bounded(maximum, S.cut(n, xs))
def cut_bounds(n, xs, maximum, input_bound):
  partition_bounds(n, xs, S.cut(n, xs), maximum, input_bound, cut_partition(n, xs))
