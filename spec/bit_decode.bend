import Base
import ./bit_decoding.bend as Octets
import ./bitfields.bend as Fields
import ./primitives.bend as P
import ./bit_packing.bend as Packing

# Independent arithmetic digit expansion of the supplied byte sequence.
def expand(xs: +List<U32>) -> +List<Bool>:
  match xs:
    case Nil{}: []
    case Con{h, t}: List.append(&2, Bool, Octets.octet(h), expand(t))

def all_zero(bits: +List<Bool>) -> Bool:
  match bits:
    case Nil{}: True{}
    case Con{h, t}: Bool.and(Bool.not(h), all_zero(t))

def accept(ok: Bool, bits: +List<Bool>) -> Maybe<&2, +List<Bool>>:
  match ok:
    case False{}: None{}
    case True{}: Some{bits}

def cons(b: Bool, r: Maybe<&2, +List<Bool>>) -> Maybe<&2, +List<Bool>>:
  match r:
    case None{}: None{}
    case Some{xs}: Some{b <> xs}

# Consume exactly size bits and require zero unused bits in the last octet.
def take(size: Nat, bits: +List<Bool>) -> Maybe<&2, +List<Bool>>:
  match size:
    case 0n: accept(all_zero(bits), [])
    case 1n+p:
      match bits:
        case Nil{}: None{}
        case Con{h, t}: cons(h, take(p, t))

def vector_checked(ok: Bool, size: Nat, xs: +List<U32>) -> Maybe<&2, +List<Bool>>:
  match ok:
    case False{}: None{}
    case True{}: take(size, expand(xs))

def bitvector_deserialize(+size: Nat, +xs: +List<U32>) -> Maybe<&2, +List<Bool>>:
  vector_checked(Bool.and(Nat.is_lt(0n, size), P.byte_scope(Packing.byte_count(size), xs)), size, xs)

# Scan from the most significant end of the final byte. There may be at most
# seven unused zero bits. A zero final byte therefore never borrows a delimiter
# from an earlier byte.
def delimiter(reversed: +List<Bool>, room: Nat) -> Maybe<&2, +List<Bool>>:
  match reversed:
    case Nil{}: None{}
    case Con{h, t}:
      match h:
        case True{}: Some{List.reverse(&2, Bool, t)}
        case False{}:
          match room:
            case 0n: None{}
            case 1n+p: delimiter(t, p)

def bounded(capacity: Nat, r: Maybe<&2, +List<Bool>>) -> Maybe<&2, +List<Bool>>:
  match r:
    case None{}: None{}
    case Some{+bits}: accept(Fields.list_domain(capacity, bits), bits)

def list_checked(ok: Bool, capacity: Nat, xs: +List<U32>) -> Maybe<&2, +List<Bool>>:
  match ok:
    case False{}: None{}
    case True{}: bounded(capacity, delimiter(List.reverse(&2, Bool, expand(xs)), 7n))

def bitlist_deserialize(capacity: Nat, +xs: +List<U32>) -> Maybe<&2, +List<Bool>>:
  list_checked(P.bytes_domain(xs), capacity, xs)
