import Base
import ../compact/found.bend as FD
import ../compact/arith.bend as A
import ./vbuf.bend as VB
import ./vu32.bend as VU
import ./vfix.bend as VF

# Window size facts with the header size symbolic: F (bytes, a U32), Fn = U32.to_nat(F),
# H (words) with A.quad(H) = Fn. A name with a large fixed header (LightClientBootstrap: 24820
# bytes) instantiates them with closed proofs of eF and eH; stated at the literal, the same facts
# make the checker compare 24820-deep unary Nats against symbolic ones and overflow its stack.

def le_fs(+F: U32, +Fn: Nat, +eF: {U32.to_nat(F) == Fn : Nat}, +len: U32, +ha: {U32.is_le(F, len) == True{} : Bool})
    -> {Nat.is_le(Fn, U32.to_nat(len)) == True{} : Bool}:
  %eF : {Nat.is_le(_, U32.to_nat(len)) == True{} : Bool}
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(F, len), Nat.is_le(U32.to_nat(F), U32.to_nat(len)), VU.le_u32(F, len), ha)

def en_fs(+F: U32, +Fn: Nat, +eF: {U32.to_nat(F) == Fn : Nat}, +len: U32, +l: U32, +el: {U32.sub(len, F) == l : U32},
    +ha: {U32.is_le(F, len) == True{} : Bool}) -> {Nat.add(Fn, U32.to_nat(l)) == U32.to_nat(len) : Nat}:
  %el : {Nat.add(Fn, U32.to_nat(_)) == U32.to_nat(len) : Nat}
  %Equal.sym(Nat, U32.to_nat(U32.sub(len, F)), Nat.sub(U32.to_nat(len), U32.to_nat(F)), FD.u32__sub_nat(len, F, le_fs(F, U32.to_nat(F), {==}, len, ha))) :
    {Nat.add(Fn, _) == U32.to_nat(len) : Nat}
  %Equal.sym(Nat, U32.to_nat(F), Fn, eF) : {Nat.add(Fn, Nat.sub(U32.to_nat(len), _)) == U32.to_nat(len) : Nat}
  FD.nat__sub_add(U32.to_nat(len), Fn, le_fs(F, Fn, eF, len, ha))

# The window after the header, (4 (H + i), l), lies in the buffer when (4 i, len) does and Fn + l = len.
def hw_y(+d: Nat, +i: Nat, +len: U32, +H: Nat, +Fn: Nat, +l: U32, +eH: {A.quad(H) == Fn : Nat},
    +en: {Nat.add(Fn, U32.to_nat(l)) == U32.to_nat(len) : Nat},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(Nat.add(A.quad(Nat.add(H, i)), U32.to_nat(l)), A.quad(VB.pw(d))) == True{} : Bool}:
  %VF.quad_add(H, i) : {Nat.is_le(Nat.add(_, U32.to_nat(l)), A.quad(VB.pw(d))) == True{} : Bool}
  %Equal.sym(Nat, A.quad(H), Fn, eH) : {Nat.is_le(Nat.add(Nat.add(_, A.quad(i)), U32.to_nat(l)), A.quad(VB.pw(d))) == True{} : Bool}
  %FD.nat__add_comm(A.quad(i), Fn) : {Nat.is_le(Nat.add(_, U32.to_nat(l)), A.quad(VB.pw(d))) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(Nat.add(A.quad(i), Fn), U32.to_nat(l)), Nat.add(A.quad(i), Nat.add(Fn, U32.to_nat(l))), FD.nat__add_assoc(A.quad(i), Fn, U32.to_nat(l))) :
    {Nat.is_le(_, A.quad(VB.pw(d))) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(Fn, U32.to_nat(l)), U32.to_nat(len), en) : {Nat.is_le(Nat.add(A.quad(i), _), A.quad(VB.pw(d))) == True{} : Bool}
  hw
