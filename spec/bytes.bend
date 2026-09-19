import Base
import ./primitives.bend as P

# Four base-256 quotient steps must leave no high serialized-size digits.
def size_fits(n: Nat) -> Bool:
  Nat.is_eq(Nat.div(Nat.div(Nat.div(Nat.div(n, 256n), 256n), 256n), 256n), 0n)

# SSZ vector[byte, n] requires n>0, exact byte scope, and the sequence
# serializer total-size assertion n < 2^32. Encoding is the bytes unchanged.
def vector_domain(+n: Nat, xs: +List<U32>) -> Bool:
  match n:
    case 0n: False{}
    case 1n+p: Bool.and(P.byte_scope(1n+p, xs), size_fits(1n+p))

def vector_encoding(+n: Nat, +xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  P.optional(vector_domain(n, xs), xs)

def vector_decoding(+n: Nat, +xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  P.optional(vector_domain(n, xs), xs)

# Right-pad a supplied chunk fragment to 32 bytes. Empty means a zero padding
# leaf here; full normative pack([]) must instead yield an empty chunk list.
def chunk_domain(+xs: +List<U32>) -> Bool:
  Bool.and(Nat.is_le(List.length(&2, U32, xs), 32n), P.bytes_domain(xs))

def chunk_encoding(+xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  P.optional(chunk_domain(xs), List.append(&2, U32, xs,
    P.zero_bytes(Nat.sub(32n, List.length(&2, U32, xs)))))
