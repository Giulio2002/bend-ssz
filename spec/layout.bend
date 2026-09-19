import Base
import ../types/schema.bend as T
import ./nat_bytes.bend as N
import ./primitives.bend as P

# Normative SSZ serialization, vectors/containers/lists: compute the entire
# fixed region first, interleave uint32 offsets, then concatenate payloads.
# Parts contain already independently serialized child values. This module
# specifies only the layout; child codec correctness is a separate obligation.
def slot(part: T.Part) -> Nat:
  match part:
    case T.Fixed{xs}: List.length(&2, U32, xs)
    case T.Variable{xs}: 4n

def fixed_size(parts: +List<T.Part>) -> Nat:
  match parts:
    case Nil{}: 0n
    case Con{h, t}: Nat.add(slot(h), fixed_size(t))

def payloads(parts: +List<T.Part>) -> +List<U32>:
  match parts:
    case Nil{}: []
    case Con{h, t}:
      match h:
        case T.Fixed{xs}: payloads(t)
        case T.Variable{xs}: List.append(&2, U32, xs, payloads(t))

def fixed_parts(parts: +List<T.Part>, +offset: Nat) -> +List<U32>:
  match parts:
    case Nil{}: []
    case Con{h, t}:
      match h:
        case T.Fixed{xs}: List.append(&2, U32, xs, fixed_parts(t, offset))
        case T.Variable{+xs}: List.append(&2, U32, N.digits(4n, offset), fixed_parts(t, Nat.add(offset, List.length(&2, U32, xs))))

def bytes_valid(parts: +List<T.Part>) -> Bool:
  match parts:
    case Nil{}: True{}
    case Con{h, t}:
      match h:
        case T.Fixed{xs}: Bool.and(P.bytes_domain(xs), bytes_valid(t))
        case T.Variable{xs}: Bool.and(P.bytes_domain(xs), bytes_valid(t))

def encoding(+parts: +List<T.Part>) -> Maybe<&2, +List<U32>>:
  +fixed = fixed_size(parts)
  +variable = payloads(parts)
  P.optional(Bool.and(bytes_valid(parts), N.fits(4n, Nat.add(fixed, List.length(&2, U32, variable)))), List.append(&2, U32, fixed_parts(parts, fixed), variable))

# Every serialized uint32 offset must be representable. The public size bound
# entails this condition; it is exposed to prove that digit extraction cannot
# silently truncate an offset.
def offsets_fit(parts: +List<T.Part>, +offset: Nat) -> Bool:
  match parts:
    case Nil{}: True{}
    case Con{h, t}:
      match h:
        case T.Fixed{xs}: offsets_fit(t, offset)
        case T.Variable{xs}: Bool.and(N.fits(4n, offset), offsets_fit(t, Nat.add(offset, List.length(&2, U32, xs))))
