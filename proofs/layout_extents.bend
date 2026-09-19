import Base
import ../src/layout.bend as I
import ../spec/layout_decoding.bend as S
import ../types/schema.bend as T
import ./layout_slices.bend as Cut

# Lift forward semantic results into the runtime's reversed accumulator.
def collect(acc: +List<+List<U32>>, result: Maybe<&2, +List<+List<U32>>>) -> Maybe<&2, +List<+List<U32>>>:
  match result:
    case None{}: None{}
    case Some{xs}: Some{List.reverse.go(&2, +List<U32>, acc, xs)}

law collect_cons:
  for +xs: +List<U32>
  for +acc: +List<+List<U32>>
  for +result: Maybe<&2, +List<+List<U32>>>
  {collect(xs <> acc, result) == collect(acc, S.prepend(xs, result)) : Maybe<&2, +List<+List<U32>>>}
def collect_cons(xs, acc, result):
  match result:
    case None{}: {==}
    case Some{rest}: {==}

law boundary_correct:
  for +fields: +List<T.Header>
  for +end: Nat
  {I.next_offset(fields, end) == S.boundary(fields, end) : Nat}
def boundary_correct(fields, end):
  match fields:
    case Nil{}: {==}
    case Con{h, t}:
      match h:
        case T.Inline{xs}: boundary_correct(t, end)
        case T.Offset{n}: {==}

def bind(result: Maybe<&2, S.Slice>, next: +List<U32> -> +List<U32> -> Maybe<&2, +List<+List<U32>>>) -> Maybe<&2, +List<+List<U32>>>:
  match result:
    case None{}: None{}
    case Some{S.Slice{xs, rest}}: next(xs, rest)

law bind_source:
  for +result: Maybe<&2, I.Split>
  for -next: +List<U32> -> +List<U32> -> Maybe<&2, +List<+List<U32>>>
  {I.resolved_part(result, next) == bind(Cut.abstract(result), next) : Maybe<&2, +List<+List<U32>>>}
def bind_source(result, next):
  match result:
    case None{}: {==}
    case Some{I.Split{xs, rest}}: {==}

law bind_refinement:
  for +result: Maybe<&2, S.Slice>
  for +acc: +List<+List<U32>>
  for -next: +List<U32> -> +List<U32> -> Maybe<&2, +List<+List<U32>>>
  for -forward: +List<U32> -> Maybe<&2, +List<+List<U32>>>
  for refine: @+xs: +List<U32> -> @+rest: +List<U32> -> {next(xs, rest) == collect(acc, S.prepend(xs, forward(rest))) : Maybe<&2, +List<+List<U32>>>}
  {bind(result, next) == collect(acc, S.sliced(result, forward)) : Maybe<&2, +List<+List<U32>>>}
def bind_refinement(result, acc, next, forward, refine):
  match result:
    case None{}: {==}
    case Some{S.Slice{xs, rest}}: refine(xs, rest)

law split_bind_correct:
  for +n: Nat
  for +payload: +List<U32>
  for +acc: +List<+List<U32>>
  for -next: +List<U32> -> +List<U32> -> Maybe<&2, +List<+List<U32>>>
  for -forward: +List<U32> -> Maybe<&2, +List<+List<U32>>>
  for refine: @+xs: +List<U32> -> @+rest: +List<U32> -> {next(xs, rest) == collect(acc, S.prepend(xs, forward(rest))) : Maybe<&2, +List<+List<U32>>>}
  {I.resolved_part(I.split(n, payload), next) == collect(acc, S.sliced(S.cut(n, payload), forward)) : Maybe<&2, +List<+List<U32>>>}
def split_bind_correct(n, payload, acc, next, forward, refine):
  %Cut.split_correct(n, payload) : {I.resolved_part(I.split(n, payload), next) == collect(acc, S.sliced(_, forward)) : Maybe<&2, +List<+List<U32>>>}
  Equal.trans(Maybe<&2, +List<+List<U32>>>, I.resolved_part(I.split(n, payload), next), bind(Cut.abstract(I.split(n, payload)), next), collect(acc, S.sliced(Cut.abstract(I.split(n, payload)), forward)), bind_source(I.split(n, payload), next), bind_refinement(Cut.abstract(I.split(n, payload)), acc, next, forward, refine))

law gate_correct:
  for +ok: Bool
  for +acc: +List<+List<U32>>
  for -next: Unit -> Maybe<&2, +List<+List<U32>>>
  for -forward: Unit -> Maybe<&2, +List<+List<U32>>>
  for refine: {next(Unit{}) == collect(acc, forward(Unit{})) : Maybe<&2, +List<+List<U32>>>}
  {I.resolve_gate(ok, next) == collect(acc, S.require(ok, forward)) : Maybe<&2, +List<+List<U32>>>}
def gate_correct(ok, acc, next, forward, refine):
  match ok:
    case False{}: {==}
    case True{}: refine

law extent_step:
  for +fields: +List<T.Header>
  for +position: Nat
  for +total: Nat
  for +xs: +List<U32>
  for +acc: +List<+List<U32>>
  for +item: +List<U32>
  for recur: {I.resolve(fields, position, total, xs, item <> acc) == collect(item <> acc, S.extents(fields, position, total, xs)) : Maybe<&2, +List<+List<U32>>>}
  {I.resolve(fields, position, total, xs, item <> acc) == collect(acc, S.prepend(item, S.extents(fields, position, total, xs))) : Maybe<&2, +List<+List<U32>>>}
def extent_step(fields, position, total, xs, acc, item, recur):
  Equal.trans(Maybe<&2, +List<+List<U32>>>, I.resolve(fields, position, total, xs, item <> acc), collect(item <> acc, S.extents(fields, position, total, xs)), collect(acc, S.prepend(item, S.extents(fields, position, total, xs))), recur, collect_cons(item, acc, S.extents(fields, position, total, xs)))

law resolve_correct:
  for +fields: +List<T.Header>
  for +position: Nat
  for +total: Nat
  for +payload: +List<U32>
  for +acc: +List<+List<U32>>
  {I.resolve(fields, position, total, payload, acc) == collect(acc, S.extents(fields, position, total, payload)) : Maybe<&2, +List<+List<U32>>>}
def resolve_correct(fields, position, total, payload, acc):
  match fields:
    case Nil{}:
      match payload:
        case Nil{}: {==}
        case Con{h, t}: {==}
    case Con{h, t}:
      match h:
        case T.Inline{xs}: extent_step(t, position, total, payload, acc, xs, resolve_correct(t, position, total, payload, xs <> acc))
        case T.Offset{start}:
          %boundary_correct(t, total) : {I.resolve(T.Offset{start} <> t, position, total, payload, acc) == collect(acc, S.require(Bool.and(Nat.is_eq(start, position), Bool.and(Nat.is_le(start, _), Nat.is_le(_, total))), u => S.sliced(S.cut(Nat.sub(_, start), payload), rest => S.extents(t, _, total, rest)))) : Maybe<&2, +List<+List<U32>>>}
          gate_correct(Bool.and(Nat.is_eq(start, position), Bool.and(Nat.is_le(start, I.next_offset(t, total)), Nat.is_le(I.next_offset(t, total), total))), acc,
            u => I.resolved_part(I.split(Nat.sub(I.next_offset(t, total), start), payload), ys => rest => I.resolve(t, I.next_offset(t, total), total, rest, ys <> acc)),
            u => S.sliced(S.cut(Nat.sub(I.next_offset(t, total), start), payload), rest => S.extents(t, I.next_offset(t, total), total, rest)),
            split_bind_correct(Nat.sub(I.next_offset(t, total), start), payload, acc,
              ys => rest => I.resolve(t, I.next_offset(t, total), total, rest, ys <> acc),
              rest => S.extents(t, I.next_offset(t, total), total, rest),
              ys => rest => extent_step(t, I.next_offset(t, total), total, rest, acc, ys, resolve_correct(t, I.next_offset(t, total), total, rest, ys <> acc))))

law collect_empty:
  for +result: Maybe<&2, +List<+List<U32>>>
  {collect([], result) == result : Maybe<&2, +List<+List<U32>>>}
def collect_empty(result):
  match result:
    case None{}: {==}
    case Some{xs}: {==}

law extents_correct:
  for +fields: +List<T.Header>
  for +position: Nat
  for +total: Nat
  for +payload: +List<U32>
  {I.resolve(fields, position, total, payload, []) == S.extents(fields, position, total, payload) : Maybe<&2, +List<+List<U32>>>}
def extents_correct(fields, position, total, payload):
  Equal.trans(Maybe<&2, +List<+List<U32>>>, I.resolve(fields, position, total, payload, []), collect([], S.extents(fields, position, total, payload)), S.extents(fields, position, total, payload), resolve_correct(fields, position, total, payload, []), collect_empty(S.extents(fields, position, total, payload)))
