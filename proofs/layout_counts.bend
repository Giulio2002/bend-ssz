import Base
import ../types/schema.bend as T
import ../spec/layout_decoding.bend as S
import ../src/layout.bend as I
import ../spec/primitives.bend as P
import ../spec/nat_bytes.bend as N
import ./layout_headers.bend as Headers

# Successful layout decoding returns exactly one slice per declared field.
# This unrestricted invariant is needed for generic decoder traversal bounds.
def count(n: Nat, result: Maybe<&2, +List<+List<U32>>>) -> Type:
  match result:
    case None{}: Unit
    case Some{xs}: {List.length(&2, +List<U32>, xs) == n : Nat}

law prepend_count:
  for +xs: +List<U32>
  for +result: Maybe<&2, +List<+List<U32>>>
  for +n: Nat
  for sized: count(n, result)
  count(1n+n, S.prepend(xs, result))
def prepend_count(xs, result, n, sized):
  match result:
    case None{}: Unit{}
    case Some{ys}: Equal.cong(Nat, Nat, k => 1n+k, List.length(&2, +List<U32>, ys), n, sized)

law sliced_count:
  for +result: Maybe<&2, S.Slice>
  for +n: Nat
  for next: +List<U32> -> Maybe<&2, +List<+List<U32>>>
  for recur: @+rest: +List<U32> -> count(n, next(rest))
  count(1n+n, S.sliced(result, next))
def sliced_count(result, n, next, recur):
  match result:
    case None{}: Unit{}
    case Some{S.Slice{xs, rest}}: prepend_count(xs, next(rest), n, recur(rest))

law required_count:
  for +ok: Bool
  for +n: Nat
  for -next: Unit -> Maybe<&2, +List<+List<U32>>>
  for sized: count(n, next(Unit{}))
  count(n, S.require(ok, next))
def required_count(ok, n, next, sized):
  match ok:
    case False{}: Unit{}
    case True{}: sized

law extents_count:
  for +fields: +List<T.Header>
  for +position: Nat
  for +total: Nat
  for +payload: +List<U32>
  count(List.length(&2, T.Header, fields), S.extents(fields, position, total, payload))
def extents_count(fields, position, total, payload):
  match fields:
    case Nil{}:
      match payload:
        case Nil{}: {==}
        case Con{h, t}: Unit{}
    case Con{h, t}:
      match h:
        case T.Inline{xs}: prepend_count(xs, S.extents(t, position, total, payload), List.length(&2, T.Header, t), extents_count(t, position, total, payload))
        case T.Offset{start}:
          required_count(Bool.and(Nat.is_eq(start, position), Bool.and(Nat.is_le(start, S.boundary(t, total)), Nat.is_le(S.boundary(t, total), total))), 1n+List.length(&2, T.Header, t), u => S.sliced(S.cut(Nat.sub(S.boundary(t, total), start), payload), rest => S.extents(t, S.boundary(t, total), total, rest)), sliced_count(S.cut(Nat.sub(S.boundary(t, total), start), payload), List.length(&2, T.Header, t), rest => S.extents(t, S.boundary(t, total), total, rest), rest => extents_count(t, S.boundary(t, total), total, rest)))

def header_count(n: Nat, result: Maybe<&2, S.HeaderRegion>) -> Type:
  match result:
    case None{}: Unit
    case Some{S.HeaderRegion{fields, payload}}: {List.length(&2, T.Header, fields) == n : Nat}

law prepend_header_count:
  for +item: T.Header
  for +result: Maybe<&2, S.HeaderRegion>
  for +n: Nat
  for sized: header_count(n, result)
  header_count(1n+n, S.prepend_header(item, result))
def prepend_header_count(item, result, n, sized):
  match result:
    case None{}: Unit{}
    case Some{S.HeaderRegion{fields, payload}}: Equal.cong(Nat, Nat, k => 1n+k, List.length(&2, T.Header, fields), n, sized)

law read_slice_count:
  for +result: Maybe<&2, S.Slice>
  for +width: Maybe<&2, Nat>
  for +n: Nat
  for next: +List<U32> -> Maybe<&2, S.HeaderRegion>
  for recur: @+rest: +List<U32> -> header_count(n, next(rest))
  header_count(1n+n, S.read_slice(result, width, next))
def read_slice_count(result, width, n, next, recur):
  match result:
    case None{}: Unit{}
    case Some{S.Slice{xs, rest}}: prepend_header_count(S.field(width, xs), next(rest), n, recur(rest))

law read_count:
  for +widths: +List<Maybe<&2, Nat>>
  for +xs: +List<U32>
  header_count(List.length(&2, Maybe<&2, Nat>, widths), S.read(widths, xs))
def read_count(widths, xs):
  match widths:
    case Nil{}: {==}
    case Con{h, t}: read_slice_count(S.cut(S.slot(h), xs), h, List.length(&2, Maybe<&2, Nat>, t), rest => S.read(t, rest), rest => read_count(t, rest))

law resolve_count:
  for +region: Maybe<&2, S.HeaderRegion>
  for +base: Nat
  for +total: Nat
  for +n: Nat
  for sized: header_count(n, region)
  count(n, S.resolve(region, base, total))
def resolve_count(region, base, total, n, sized):
  match region:
    case None{}: Unit{}
    case Some{S.HeaderRegion{fields, payload}}:
      %sized : count(_, S.extents(fields, base, total, payload))
      extents_count(fields, base, total, payload)

law semantic_count:
  for +widths: +List<Maybe<&2, Nat>>
  for +xs: +List<U32>
  count(List.length(&2, Maybe<&2, Nat>, widths), S.decoding(widths, xs))
def semantic_count(widths, xs):
  required_count(Bool.and(P.bytes_domain(xs), N.fits(4n, List.length(&2, U32, xs))), List.length(&2, Maybe<&2, Nat>, widths), u => S.resolve(S.read(widths, xs), S.fixed_size(widths), List.length(&2, U32, xs)), resolve_count(S.read(widths, xs), S.fixed_size(widths), List.length(&2, U32, xs), List.length(&2, Maybe<&2, Nat>, widths), read_count(widths, xs)))

law actual_count:
  for +widths: +List<Maybe<&2, Nat>>
  for +xs: +List<U32>
  count(List.length(&2, Maybe<&2, Nat>, widths), I.decode(widths, xs))
def actual_count(widths, xs):
  %Equal.sym(Maybe<&2, +List<+List<U32>>>, I.decode(widths, xs), S.decoding(widths, xs), Headers.decode_correct(widths, xs)) : count(List.length(&2, Maybe<&2, Nat>, widths), _)
  semantic_count(widths, xs)
