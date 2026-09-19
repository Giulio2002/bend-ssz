import Base

def octet(+x: U32) -> +List<Bool>:
  [U32.is_eq(U32.and(U32.shrn(x, 0n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 1n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 2n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 3n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 4n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 5n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 6n), 1), 1), U32.is_eq(U32.and(U32.shrn(x, 7n), 1), 1)]
