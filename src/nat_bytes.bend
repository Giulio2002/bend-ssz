import Base

# Exact-width little-endian conversion. Residual high digits are rejected,
# rather than narrowed through a machine integer or silently discarded.
def prepend(byte: U32, tail: Maybe<&2, +List<U32>>) -> Maybe<&2, +List<U32>>:
  match tail:
    case None{}: None{}
    case Some{xs}: Some{byte <> xs}

def zero_gate(zero: Bool) -> Maybe<&2, +List<U32>>:
  match zero:
    case False{}: None{}
    case True{}: Some{[]}

def encode_pair(qr: Nat & Nat, tail: Nat -> Maybe<&2, +List<U32>>) -> Maybe<&2, +List<U32>>:
  (q, r) = qr
  prepend(U32.from_nat(r), tail(q))

def encode(width: Nat, n: Nat) -> Maybe<&2, +List<U32>>:
  match width:
    case 0n: zero_gate(Nat.is_eq(n, 0n))
    case 1n+p:
      encode_pair(Nat.divmod(n, 256n), q => encode(p, q))
