import Base
import ./bit_decode.bend as Decode
import ./bit_packing.bend as Bits
import ./primitives.bend as P

# Public values are lists of Bool, so every element has the legal bit domain.
def vector_valid(+size: Nat, bits: +List<Bool>) -> Bool:
  match size:
    case 0n: False{}
    case 1n+p: Nat.is_eq(List.length(&2, Bool, bits), 1n+p)

def list_valid(capacity: Nat, bits: +List<Bool>) -> Bool:
  Nat.is_le(List.length(&2, Bool, bits), capacity)

def bitvector_serialize(+size: Nat, +bits: +List<Bool>) -> Maybe<&2, +List<U32>>:
  P.accept_bytes(vector_valid(size, bits), Bits.pack(bits))

def bitlist_serialize(+capacity: Nat, +bits: +List<Bool>) -> Maybe<&2, +List<U32>>:
  P.accept_bytes(list_valid(capacity, bits), Bits.pack(List.append(&2, Bool, bits, [True{}])))


def bitvector_deserialize(size: Nat, xs: +List<U32>) -> Maybe<&2, +List<Bool>>:
  Decode.bitvector_deserialize(size, xs)

def bitlist_deserialize(capacity: Nat, xs: +List<U32>) -> Maybe<&2, +List<Bool>>:
  Decode.bitlist_deserialize(capacity, xs)
