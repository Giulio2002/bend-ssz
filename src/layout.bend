import Base
import ./lists.bend as Lists
import ../types/schema.bend as T
import ./nat_bytes.bend as NatBytes
import ./bytes.bend as Bytes
import ./primitives.bend as P
import ./packing.bend as Pack

# Generic four-byte-offset layout, independent of element codecs.
def append(a: Maybe<&2, +List<U32>>, b: Maybe<&2, +List<U32>>) -> Maybe<&2, +List<U32>>:
  match a b:
    case None{} None{}: None{}
    case None{} Some{y}: None{}
    case Some{x} None{}: None{}
    case Some{x} Some{y}: Some{Lists.append(U32, x, y)}

def fixed_length(parts: +List<T.Part>, acc: Nat) -> Nat:
  match parts:
    case Nil{}: acc
    case Con{h, t}:
      match h:
        case T.Fixed{xs}: fixed_length(t, Nat.add(acc, Lists.length(U32, xs)))
        case T.Variable{xs}: fixed_length(t, Nat.add(acc, 4n))

def finish(fixed: +List<U32>, variable: +List<U32>) -> Maybe<&2, +List<U32>>:
  +out = List.reverse.go(&2, U32, fixed, List.reverse(&2, U32, variable))
  P.accept_bytes(Bool.and(Bytes.size_fits(Lists.length(U32, out)), Pack.valid_go(out, True{})), out)

def offset_append(offset: Maybe<&2, +List<U32>>, fixed: +List<U32>, next: +List<U32> -> Maybe<&2, +List<U32>>) -> Maybe<&2, +List<U32>>:
  match offset:
    case None{}: None{}
    case Some{xs}: next(List.reverse.go(&2, U32, xs, fixed))

def encode_go(parts: +List<T.Part>, +cursor: Nat, fixed: +List<U32>, variable: +List<U32>) -> Maybe<&2, +List<U32>>:
  match parts:
    case Nil{}: finish(fixed, variable)
    case Con{h, t}:
      match h:
        case T.Fixed{xs}: encode_go(t, cursor, List.reverse.go(&2, U32, xs, fixed), variable)
        case T.Variable{+xs}:
          offset_append(NatBytes.encode(4n, cursor), fixed, f => encode_go(t, Nat.add(cursor, Lists.length(U32, xs)), f, List.reverse.go(&2, U32, xs, variable)))

def encode(+parts: +List<T.Part>) -> Maybe<&2, +List<U32>>:
  encode_go(parts, fixed_length(parts, 0n), [], [])

# Prefix extraction always signals short input, rather than silently truncating.
type Split is Data:
  Split{prefix: +List<U32>, rest: +List<U32>}

def split_go(n: Nat, xs: +List<U32>, acc: +List<U32>) -> Maybe<&2, Split>:
  match n:
    case 0n: Some{Split{List.reverse(&2, U32, acc), xs}}
    case 1n+p:
      match xs:
        case Nil{}: None{}
        case Con{h, t}: split_go(p, t, h <> acc)

def split(n: Nat, xs: +List<U32>) -> Maybe<&2, Split>: split_go(n, xs, [])

def offset(+xs: +List<U32>) -> Nat:
  U32.to_nat(P.read_limb(xs, 0n))

def header_length(widths: +List<Maybe<&2, Nat>>, acc: Nat) -> Nat:
  match widths:
    case Nil{}: acc
    case Con{h, t}:
      match h:
        case None{}: header_length(t, Nat.add(acc, 4n))
        case Some{n}: header_length(t, Nat.add(acc, n))

def next_offset(headers: +List<T.Header>, fallback: Nat) -> Nat:
  match headers:
    case Nil{}: fallback
    case Con{h, t}:
      match h:
        case T.Inline{xs}: next_offset(t, fallback)
        case T.Offset{n}: n

def resolved_part(result: Maybe<&2, Split>, next: +List<U32> -> +List<U32> -> Maybe<&2, +List<+List<U32>>>) -> Maybe<&2, +List<+List<U32>>>:
  match result:
    case None{}: None{}
    case Some{s}:
      Split{xs, rest} = s
      next(xs, rest)

def slices_done(xs: +List<U32>, acc: +List<+List<U32>>) -> Maybe<&2, +List<+List<U32>>>:
  match xs:
    case Nil{}: Some{List.reverse(&2, +List<U32>, acc)}
    case Con{h, t}: None{}

def resolve_gate(ok: Bool, next: Unit -> Maybe<&2, +List<+List<U32>>>) -> Maybe<&2, +List<+List<U32>>>:
  match ok:
    case False{}: None{}
    case True{}: next(Unit{})

def resolve(headers: +List<T.Header>, +cursor: Nat, +total: Nat, xs: +List<U32>, acc: +List<+List<U32>>) -> Maybe<&2, +List<+List<U32>>>:
  match headers:
    case Nil{}: slices_done(xs, acc)
    case Con{h, +t}:
      match h:
        case T.Inline{ys}: resolve(t, cursor, total, xs, ys <> acc)
        case T.Offset{+start}:
          +end = next_offset(t, total)
          resolve_gate(Bool.and(Nat.is_eq(start, cursor), Bool.and(Nat.is_le(start, end), Nat.is_le(end, total))), u =>
            resolved_part(split(Nat.sub(end, start), xs), ys => rest => resolve(t, end, total, rest, ys <> acc)))

def read_header(result: Maybe<&2, Split>, width: Maybe<&2, Nat>, next: T.Header -> +List<U32> -> Maybe<&2, +List<+List<U32>>>) -> Maybe<&2, +List<+List<U32>>>:
  match result:
    case None{}: None{}
    case Some{s}:
      Split{xs, rest} = s
      match width:
        case None{}: next(T.Offset{offset(xs)}, rest)
        case Some{n}: next(T.Inline{xs}, rest)

def slot(width: Maybe<&2, Nat>) -> Nat:
  match width:
    case None{}: 4n
    case Some{n}: n

def headers(widths: +List<Maybe<&2, Nat>>, +base: Nat, +total: Nat, xs: +List<U32>, acc: +List<T.Header>) -> Maybe<&2, +List<+List<U32>>>:
  match widths:
    case Nil{}: resolve(List.reverse(&2, T.Header, acc), base, total, xs, [])
    case Con{+h, t}: read_header(split(slot(h), xs), h, item => rest => headers(t, base, total, rest, item <> acc))

def decode_gate(ok: Bool, +widths: +List<Maybe<&2, Nat>>, +xs: +List<U32>) -> Maybe<&2, +List<+List<U32>>>:
  match ok:
    case False{}: None{}
    case True{}: headers(widths, header_length(widths, 0n), Lists.length(U32, xs), xs, [])

def decode(widths: +List<Maybe<&2, Nat>>, +xs: +List<U32>) -> Maybe<&2, +List<+List<U32>>>:
  decode_gate(Bool.and(Bytes.size_fits(Lists.length(U32, xs)), Pack.valid_go(xs, True{})), widths, xs)
