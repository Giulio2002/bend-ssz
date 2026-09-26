import Base
import ../../src/primitives.bend as I
import ../../spec/primitives.bend as SP
import ../../spec/nat_bytes.bend as N
import ../../proofs/codec_inverse.bend as CI
import ../../proofs/integer_decoding.bend as ID
import ../../proofs/layout_offset_value.bend as LOV
import ../../proofs/offset_digits.bend as OD
import ../../proofs/primitive_invariants.bend as V

# The spec's four little-endian digits of a word's value are the word's limbs:
# an offset field written as a U32 is the spec's offset encoding.

def value_limb(+x: U32) -> {N.value(I.limb(x)) == U32.to_nat(x) : Nat}:
  +dom = V.limb_domain(x)
  Equal.trans(Nat, N.value(I.limb(x)), U32.to_nat(SP.limb_value(I.limb(x), 0n)), U32.to_nat(x),
    Equal.sym(Nat, U32.to_nat(SP.limb_value(I.limb(x), 0n)), N.value(I.limb(x)), LOV.scope_value(I.limb(x), dom)),
    Equal.cong(U32, Nat, u => U32.to_nat(u), SP.limb_value(I.limb(x), 0n), x,
      Equal.trans(U32, SP.limb_value(I.limb(x), 0n), I.read_limb(I.limb(x), 0n), x,
        Equal.sym(U32, I.read_limb(I.limb(x), 0n), SP.limb_value(I.limb(x), 0n), ID.read_limb_correct(I.limb(x), 0n, dom)),
        CI.limb_inverse(x))))

law digits_limb:
  for +x: U32
  {N.digits(4n, U32.to_nat(x)) == I.limb(x) : +List<U32>}
def digits_limb(x):
  %value_limb(x) : {N.digits(4n, _) == I.limb(x) : +List<U32>}
  OD.digits_of_value(4n, I.limb(x), {==}, V.limb_domain(x))
