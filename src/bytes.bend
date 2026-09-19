import Base
import ./primitives.bend as P

# Tail-recursive traversal: large byte wrappers must not consume the JS stack.
def scope_go(xs: +List<U32>, n: Nat, ok: Bool) -> Bool:
  match xs n:
    case Nil{} 0n: ok
    case Nil{} 1n+p: False{}
    case Con{h, t} 0n: False{}
    case Con{h, t} 1n+p: scope_go(t, p, Bool.and(ok, U32.is_lt(h, 256)))

# Four base-256 quotient steps must leave no high serialized-size digits.
def size_fits(n: Nat) -> Bool:
  Nat.is_eq(Nat.div(Nat.div(Nat.div(Nat.div(n, 256n), 256n), 256n), 256n), 0n)

# Byte-vector aliases enforce exact length, byte range, and the normative
# sequence serialization bound: total bytes must be strictly below 2^32.
def vector_valid(+n: Nat, xs: +List<U32>) -> Bool:
  match n:
    case 0n: False{}
    case 1n+p: Bool.and(scope_go(xs, 1n+p, True{}), size_fits(1n+p))

def vector_serialize(+n: Nat, +xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  P.accept_bytes(vector_valid(n, xs), xs)

def vector_deserialize(n: Nat, xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  vector_serialize(n, xs)

# Materialize one chunk fragment: 0..32 bytes, right-padding to 32.
# Empty fragments give a zero padding leaf, not the result of full pack([]).
# General multi-chunk packing and vector Merkle roots remain separate work.
def chunk_scope(xs: +List<U32>, n: Nat) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{h, t}:
      match n:
        case 0n: False{}
        case 1n+p: Bool.and(U32.is_lt(h, 256), chunk_scope(t, p))

def chunk_valid(xs: +List<U32>) -> Bool:
  chunk_scope(xs, 32n)

def chunk_checked(ok: Bool, xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}: Some{P.pad(32n, xs)}

def pack_chunk(+xs: +List<U32>) -> Maybe<&2, +List<U32>>:
  chunk_checked(chunk_valid(xs), xs)
