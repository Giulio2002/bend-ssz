import Base
import ../src/obj.bend as O
import ../proofs/compact/found.bend as FD
import ../proofs/compact/arith.bend as A
import ../proofs/nat_order.bend as Order
import ../proofs/obj/vbuf.bend as VB

# A variable field's window of a container window (its offsets in order inside it): its length is at most the window's.
def lwd(+O: U32, +E: U32, +len: U32, +h1: {Nat.is_le(U32.to_nat(O), U32.to_nat(E)) == True{} : Bool}, +h2: {Nat.is_le(U32.to_nat(E), U32.to_nat(len)) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(U32.sub(E, O)), U32.to_nat(len)) == True{} : Bool}:
  FD.nat__le_trans(U32.to_nat(U32.sub(E, O)), U32.to_nat(E), U32.to_nat(len),
    FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(U32.sub(E, O)), z) == True{} : Bool}, Nat.add(U32.to_nat(O), U32.to_nat(U32.sub(E, O))), U32.to_nat(E),
      Equal.trans(Nat, Nat.add(U32.to_nat(O), U32.to_nat(U32.sub(E, O))), Nat.add(U32.to_nat(O), Nat.sub(U32.to_nat(E), U32.to_nat(O))), U32.to_nat(E),
        Equal.cong(Nat, Nat, z => Nat.add(U32.to_nat(O), z), U32.to_nat(U32.sub(E, O)), Nat.sub(U32.to_nat(E), U32.to_nat(O)), FD.u32__sub_nat(E, O, h1)),
        FD.nat__sub_add(U32.to_nat(E), U32.to_nat(O), h1)),
      A.le_skip(U32.to_nat(O), U32.to_nat(U32.sub(E, O)))), h2)

# its length plus 4 within 2^27 from the window's
def hlc(+L: Nat, +n: Nat, +hl: {Nat.is_le(L, n) == True{} : Bool}, +h27: {Nat.is_le(Nat.add(n, 4n), VB.pw(27n)) == True{} : Bool}) -> {Nat.is_le(Nat.add(L, 4n), VB.pw(27n)) == True{} : Bool}:
  FD.nat__le_trans(Nat.add(L, 4n), Nat.add(n, 4n), VB.pw(27n), Order.add_right(L, n, 4n, hl), h27)
