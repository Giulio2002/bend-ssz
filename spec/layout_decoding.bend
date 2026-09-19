import Base
import ../types/schema.bend as T
import ./primitives.bend as P
import ./nat_bytes.bend as N

# Declarative forward slices of the normative fixed/variable layout. There is
# no traversal fuel and no source/proof dependency. A short slice is failure.
type Slice is Data:
  Slice{prefix: +List<U32>, rest: +List<U32>}

def prepend_slice(x: U32, result: Maybe<&2, Slice>) -> Maybe<&2, Slice>:
  match result:
    case None{}: None{}
    case Some{Slice{xs, rest}}: Some{Slice{x <> xs, rest}}

def cut(n: Nat, xs: +List<U32>) -> Maybe<&2, Slice>:
  match n:
    case 0n: Some{Slice{[], xs}}
    case 1n+p:
      match xs:
        case Nil{}: None{}
        case Con{h, t}: prepend_slice(h, cut(p, t))

def slot(width: Maybe<&2, Nat>) -> Nat:
  match width:
    case None{}: 4n
    case Some{n}: n

def fixed_size(widths: +List<Maybe<&2, Nat>>) -> Nat:
  match widths:
    case Nil{}: 0n
    case Con{h, t}: Nat.add(slot(h), fixed_size(t))

type HeaderRegion is Data:
  HeaderRegion{fields: +List<T.Header>, payload: +List<U32>}

def prepend_header(field: T.Header, result: Maybe<&2, HeaderRegion>) -> Maybe<&2, HeaderRegion>:
  match result:
    case None{}: None{}
    case Some{HeaderRegion{fields, payload}}: Some{HeaderRegion{field <> fields, payload}}

# Offsets use the independent primitive uint32 coefficient semantics. read
# supplies exactly four bytes; decoding checks the entire input byte domain.
# Thus the arithmetic word has no discarded high coefficient.
def field(width: Maybe<&2, Nat>, xs: +List<U32>) -> T.Header:
  match width:
    case None{}: T.Offset{U32.to_nat(P.limb_value(xs, 0n))}
    case Some{n}: T.Inline{xs}

def read_slice(result: Maybe<&2, Slice>, width: Maybe<&2, Nat>, tail: +List<U32> -> Maybe<&2, HeaderRegion>) -> Maybe<&2, HeaderRegion>:
  match result:
    case None{}: None{}
    case Some{Slice{xs, rest}}: prepend_header(field(width, xs), tail(rest))

def read(widths: +List<Maybe<&2, Nat>>, xs: +List<U32>) -> Maybe<&2, HeaderRegion>:
  match widths:
    case Nil{}: Some{HeaderRegion{[], xs}}
    case Con{+h, t}: read_slice(cut(slot(h), xs), h, rest => read(t, rest))

def boundary(fields: +List<T.Header>, end: Nat) -> Nat:
  match fields:
    case Nil{}: end
    case Con{h, t}:
      match h:
        case T.Inline{xs}: boundary(t, end)
        case T.Offset{n}: n

def prepend(xs: +List<U32>, result: Maybe<&2, +List<+List<U32>>>) -> Maybe<&2, +List<+List<U32>>>:
  match result:
    case None{}: None{}
    case Some{rest}: Some{xs <> rest}

def sliced(result: Maybe<&2, Slice>, tail: +List<U32> -> Maybe<&2, +List<+List<U32>>>) -> Maybe<&2, +List<+List<U32>>>:
  match result:
    case None{}: None{}
    case Some{Slice{xs, rest}}: prepend(xs, tail(rest))

def require(ok: Bool, next: Unit -> Maybe<&2, +List<+List<U32>>>) -> Maybe<&2, +List<+List<U32>>>:
  match ok:
    case False{}: None{}
    case True{}: next(Unit{})

# First offset equals the complete fixed region. Each variable extent ends at
# the next offset (or total size), is nonnegative, and is within the input.
# Equality of successive offsets is allowed: it encodes an empty child.
# Fixed children retain their declaration positions among variable children.
def extents(fields: +List<T.Header>, +position: Nat, +total: Nat, payload: +List<U32>) -> Maybe<&2, +List<+List<U32>>>:
  match fields:
    case Nil{}:
      match payload:
        case Nil{}: Some{[]}
        case Con{h, t}: None{}
    case Con{h, +t}:
      match h:
        case T.Inline{xs}: prepend(xs, extents(t, position, total, payload))
        case T.Offset{+start}:
          +end = boundary(t, total)
          require(Bool.and(Nat.is_eq(start, position), Bool.and(Nat.is_le(start, end), Nat.is_le(end, total))), u => sliced(cut(Nat.sub(end, start), payload), rest => extents(t, end, total, rest)))

def resolve(region: Maybe<&2, HeaderRegion>, base: Nat, total: Nat) -> Maybe<&2, +List<+List<U32>>>:
  match region:
    case None{}: None{}
    case Some{HeaderRegion{fields, payload}}: extents(fields, base, total, payload)

# The byte domain and strict uint32 total-size assertion are serialization
# requirements, rather than implementation resource bounds.
def decoding(+widths: +List<Maybe<&2, Nat>>, +xs: +List<U32>) -> Maybe<&2, +List<+List<U32>>>:
  require(Bool.and(P.bytes_domain(xs), N.fits(4n, List.length(&2, U32, xs))), u => resolve(read(widths, xs), fixed_size(widths), List.length(&2, U32, xs)))
