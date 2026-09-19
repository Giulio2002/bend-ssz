import Base

# Arithmetic digit i = floor(x / 2^i) mod 2, in increasing significance.
def octet(+x: U32) -> +List<Bool>:
  [U32.is_eq(U32.mod(U32.div(x, 1), 2), 1), U32.is_eq(U32.mod(U32.div(x, 2), 2), 1), U32.is_eq(U32.mod(U32.div(x, 4), 2), 1), U32.is_eq(U32.mod(U32.div(x, 8), 2), 1), U32.is_eq(U32.mod(U32.div(x, 16), 2), 1), U32.is_eq(U32.mod(U32.div(x, 32), 2), 1), U32.is_eq(U32.mod(U32.div(x, 64), 2), 1), U32.is_eq(U32.mod(U32.div(x, 128), 2), 1)]
