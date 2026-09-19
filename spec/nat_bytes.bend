import Base
import ./primitives.bend as P

# SSZ mix_in_length uses exactly 32 little-endian bytes. More generally the
# width-byte domain is characterized by a zero quotient after width divisions
# by 256 (equivalently n < 256^width). No machine-width cast defines the domain.
def fits(width: Nat, +n: Nat) -> Bool:
  match width:
    case 0n: Nat.is_eq(n, 0n)
    case 1n+p: fits(p, Nat.div(n, 256n))

def digits(width: Nat, +n: Nat) -> +List<U32>:
  match width:
    case 0n: []
    case 1n+p: U32.from_nat(Nat.mod(n, 256n)) <> digits(p, Nat.div(n, 256n))

def encoding(+width: Nat, +n: Nat) -> Maybe<&2, +List<U32>>:
  P.optional(fits(width, n), digits(width, n))

# Mathematical interpretation of little-endian bytes, used to state exact
# conversion rather than only equality of two encoding algorithms.
def value(xs: +List<U32>) -> Nat:
  match xs:
    case Nil{}: 0n
    case Con{h, t}: Nat.add(U32.to_nat(h), Nat.mul(value(t), 256n))
