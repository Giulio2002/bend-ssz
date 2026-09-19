import Base
import ./bit_packing.bend as Bits

# SSZ illegal-types: Bitvector[0] is illegal. Bitlist capacity zero is legal.
def vector_domain(+size: Nat, bits: +List<Bool>) -> Bool:
  Bool.and(Nat.is_lt(0n, size), Nat.is_eq(List.length(&2, Bool, bits), size))

def list_domain(capacity: Nat, bits: +List<Bool>) -> Bool:
  Nat.is_le(List.length(&2, Bool, bits), capacity)

def encoding(ok: Bool, bits: +List<Bool>) -> Maybe<&2, +List<U32>>:
  match ok:
    case False{}: None{}
    case True{}: Some{Bits.pack(bits)}

def vector_encoding(+size: Nat, +bits: +List<Bool>) -> Maybe<&2, +List<U32>>:
  encoding(vector_domain(size, bits), bits)

# Normative delimiter is the next bit after the data, including when the data
# ends on a byte boundary. Remaining high bits of the final byte are zero.
def list_encoding(+capacity: Nat, +bits: +List<Bool>) -> Maybe<&2, +List<U32>>:
  encoding(list_domain(capacity, bits), List.append(&2, Bool, bits, [True{}]))
