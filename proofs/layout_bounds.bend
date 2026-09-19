import Base
import ../types/schema.bend as T
import ../spec/layout_decoding.bend as S
import ../spec/primitives.bend as P
import ../spec/nat_bytes.bend as N
import ../src/layout.bend as I
import ./layout_slices.bend as Cut
import ./layout_headers.bend as Headers
import ./nat_order.bend as Order

# Mathematical child-size bounds, independent of native integer/resource limits.
def slices(maximum: Nat, xs: +List<+List<U32>>) -> Type:
  match xs:
    case Nil{}: Unit
    case Con{h, t}: {Nat.is_le(List.length(&2, U32, h), maximum) == True{} : Bool} & slices(maximum, t)

def result_bound(maximum: Nat, result: Maybe<&2, +List<+List<U32>>>) -> Type:
  match result:
    case None{}: Unit
    case Some{xs}: slices(maximum, xs)

def header_bound(maximum: Nat, h: T.Header) -> Type:
  match h:
    case T.Inline{xs}: {Nat.is_le(List.length(&2, U32, xs), maximum) == True{} : Bool}
    case T.Offset{n}: Unit

def headers_bound(maximum: Nat, hs: +List<T.Header>) -> Type:
  match hs:
    case Nil{}: Unit
    case Con{h, t}: header_bound(maximum, h) & headers_bound(maximum, t)

def region_bound(maximum: Nat, result: Maybe<&2, S.HeaderRegion>) -> Type:
  match result:
    case None{}: Unit
    case Some{S.HeaderRegion{hs, rest}}: headers_bound(maximum, hs) & {Nat.is_le(List.length(&2, U32, rest), maximum) == True{} : Bool}

law field_bound:
  for +width: Maybe<&2, Nat>
  for +xs: +List<U32>
  for +maximum: Nat
  for sized: {Nat.is_le(List.length(&2, U32, xs), maximum) == True{} : Bool}
  header_bound(maximum, S.field(width, xs))
def field_bound(width, xs, maximum, sized):
  match width:
    case None{}: Unit{}
    case Some{n}: sized

law prepend_header_bound:
  for +h: T.Header
  for +result: Maybe<&2, S.HeaderRegion>
  for +maximum: Nat
  for head: header_bound(maximum, h)
  for tail: region_bound(maximum, result)
  region_bound(maximum, S.prepend_header(h, result))
def prepend_header_bound(h, result, maximum, head, tail):
  match result:
    case None{}: Unit{}
    case Some{S.HeaderRegion{hs, rest}}:
      (fields, payload) = tail
      ((head, fields), payload)

law read_slice_bound:
  for +result: Maybe<&2, S.Slice>
  for +width: Maybe<&2, Nat>
  for +maximum: Nat
  for next: +List<U32> -> Maybe<&2, S.HeaderRegion>
  for sized: Cut.bounded(maximum, result)
  for recur: @+rest: +List<U32> -> {Nat.is_le(List.length(&2, U32, rest), maximum) == True{} : Bool} -> region_bound(maximum, next(rest))
  region_bound(maximum, S.read_slice(result, width, next))
def read_slice_bound(result, width, maximum, next, sized, recur):
  match result:
    case None{}: Unit{}
    case Some{S.Slice{xs, rest}}:
      (prefix, tail) = sized
      prepend_header_bound(S.field(width, xs), next(rest), maximum, field_bound(width, xs, maximum, prefix), recur(rest, tail))

law read_bound:
  for +widths: +List<Maybe<&2, Nat>>
  for +xs: +List<U32>
  for +maximum: Nat
  for sized: {Nat.is_le(List.length(&2, U32, xs), maximum) == True{} : Bool}
  region_bound(maximum, S.read(widths, xs))
def read_bound(widths, xs, maximum, sized):
  match widths:
    case Nil{}: (Unit{}, sized)
    case Con{h, t}: read_slice_bound(S.cut(S.slot(h), xs), h, maximum, rest => S.read(t, rest), Cut.cut_bounds(S.slot(h), xs, maximum, sized), rest => bound => read_bound(t, rest, maximum, bound))

law prepend_bound:
  for +xs: +List<U32>
  for +result: Maybe<&2, +List<+List<U32>>>
  for +maximum: Nat
  for head: {Nat.is_le(List.length(&2, U32, xs), maximum) == True{} : Bool}
  for tail: result_bound(maximum, result)
  result_bound(maximum, S.prepend(xs, result))
def prepend_bound(xs, result, maximum, head, tail):
  match result:
    case None{}: Unit{}
    case Some{ys}: (head, tail)

law sliced_bound:
  for +result: Maybe<&2, S.Slice>
  for +maximum: Nat
  for next: +List<U32> -> Maybe<&2, +List<+List<U32>>>
  for sized: Cut.bounded(maximum, result)
  for recur: @+rest: +List<U32> -> {Nat.is_le(List.length(&2, U32, rest), maximum) == True{} : Bool} -> result_bound(maximum, next(rest))
  result_bound(maximum, S.sliced(result, next))
def sliced_bound(result, maximum, next, sized, recur):
  match result:
    case None{}: Unit{}
    case Some{S.Slice{xs, rest}}:
      (prefix, tail) = sized
      prepend_bound(xs, next(rest), maximum, prefix, recur(rest, tail))

law require_bound:
  for +ok: Bool
  for +maximum: Nat
  for -next: Unit -> Maybe<&2, +List<+List<U32>>>
  for sized: result_bound(maximum, next(Unit{}))
  result_bound(maximum, S.require(ok, next))
def require_bound(ok, maximum, next, sized):
  match ok:
    case False{}: Unit{}
    case True{}: sized

law extents_bound:
  for +fields: +List<T.Header>
  for +position: Nat
  for +total: Nat
  for +payload: +List<U32>
  for +maximum: Nat
  for heads: headers_bound(maximum, fields)
  for sized: {Nat.is_le(List.length(&2, U32, payload), maximum) == True{} : Bool}
  result_bound(maximum, S.extents(fields, position, total, payload))
def extents_bound(fields, position, total, payload, maximum, heads, sized):
  match fields:
    case Nil{}:
      match payload:
        case Nil{}: Unit{}
        case Con{h, t}: Unit{}
    case Con{h, t}:
      match h:
        case T.Inline{xs}:
          (head, tail) = heads
          prepend_bound(xs, S.extents(t, position, total, payload), maximum, head, extents_bound(t, position, total, payload, maximum, tail, sized))
        case T.Offset{start}:
          (head, tail) = heads
          require_bound(Bool.and(Nat.is_eq(start, position), Bool.and(Nat.is_le(start, S.boundary(t, total)), Nat.is_le(S.boundary(t, total), total))), maximum, u => S.sliced(S.cut(Nat.sub(S.boundary(t, total), start), payload), rest => S.extents(t, S.boundary(t, total), total, rest)), sliced_bound(S.cut(Nat.sub(S.boundary(t, total), start), payload), maximum, rest => S.extents(t, S.boundary(t, total), total, rest), Cut.cut_bounds(Nat.sub(S.boundary(t, total), start), payload, maximum, sized), rest => bound => extents_bound(t, S.boundary(t, total), total, rest, maximum, tail, bound)))

law resolve_bound:
  for +region: Maybe<&2, S.HeaderRegion>
  for +base: Nat
  for +total: Nat
  for +maximum: Nat
  for sized: region_bound(maximum, region)
  result_bound(maximum, S.resolve(region, base, total))
def resolve_bound(region, base, total, maximum, sized):
  match region:
    case None{}: Unit{}
    case Some{S.HeaderRegion{fields, payload}}:
      (heads, rest) = sized
      extents_bound(fields, base, total, payload, maximum, heads, rest)

law semantic_bound:
  for +widths: +List<Maybe<&2, Nat>>
  for +xs: +List<U32>
  result_bound(List.length(&2, U32, xs), S.decoding(widths, xs))
def semantic_bound(widths, xs):
  require_bound(Bool.and(P.bytes_domain(xs), N.fits(4n, List.length(&2, U32, xs))), List.length(&2, U32, xs), u => S.resolve(S.read(widths, xs), S.fixed_size(widths), List.length(&2, U32, xs)), resolve_bound(S.read(widths, xs), S.fixed_size(widths), List.length(&2, U32, xs), List.length(&2, U32, xs), read_bound(widths, xs, List.length(&2, U32, xs), Order.reflexive(List.length(&2, U32, xs)))))

law actual_bound:
  for +widths: +List<Maybe<&2, Nat>>
  for +xs: +List<U32>
  result_bound(List.length(&2, U32, xs), I.decode(widths, xs))
def actual_bound(widths, xs):
  %Equal.sym(Maybe<&2, +List<+List<U32>>>, I.decode(widths, xs), S.decoding(widths, xs), Headers.decode_correct(widths, xs)) : result_bound(List.length(&2, U32, xs), _)
  semantic_bound(widths, xs)
