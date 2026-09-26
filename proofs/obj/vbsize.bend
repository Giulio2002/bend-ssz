import Base
import ../compact/found.bend as FD
import ../compact/arith.bend as A
import ./vbuf.bend as VB
import ./vu32.bend as VU
import ./vfix.bend as VF
import ./vspec.bend as VS
import ./vbspec.bend as VZ
import ./vfits.bend as VFT
import ../../spec/nat_bytes.bend as N
import ../../proofs/nat_order.bend as Order

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

# ---- the fixed size of a header of symbolic segments ----------------------------------------------
# lsum over segments whose lengths are given by hypotheses: an element such as a symbolic
# 6156-word segment is never unfolded (comparing it against its unfolding unrolls 6144 steps).

def lsum_nil() -> {VZ.lsum([]) == 0n : Nat}: {==}

def lsum_c(+c: +List<U32>, +r: +List<+List<U32>>, +C: Nat, +R: Nat, +hc: {List.length(&2, U32, c) == C : Nat}, +hr: {VZ.lsum(r) == R : Nat})
    -> {VZ.lsum(Con{c, r}) == Nat.add(C, R) : Nat}:
  %hc : {VZ.lsum(Con{c, r}) == Nat.add(_, R) : Nat}
  %hr : {VZ.lsum(Con{c, r}) == Nat.add(List.length(&2, U32, c), _) : Nat}
  {==}

def fsz_lsum(+pre: +List<+List<U32>>, +post: +List<+List<U32>>, +P: Nat, +Q: Nat, +hp: {VZ.lsum(pre) == P : Nat}, +hq: {VZ.lsum(post) == Q : Nat})
    -> {VS.FSZ(pre, post) == Nat.add(A.quad(P), 4n+A.quad(Q)) : Nat}:
  %Equal.sym(Nat, VS.FSZ(pre, post), Nat.add(A.quad(VZ.lsum(pre)), 4n+A.quad(VZ.lsum(post))), VZ.fsz_eq(pre, post)) :
    {_ == Nat.add(A.quad(P), 4n+A.quad(Q)) : Nat}
  %Equal.sym(Nat, VZ.lsum(pre), P, hp) : {Nat.add(A.quad(_), 4n+A.quad(VZ.lsum(post))) == Nat.add(A.quad(P), 4n+A.quad(Q)) : Nat}
  %Equal.sym(Nat, VZ.lsum(post), Q, hq) : {Nat.add(A.quad(P), 4n+A.quad(_)) == Nat.add(A.quad(P), 4n+A.quad(Q)) : Nat}
  {==}

# ---- windows and segment lists, one step at a time ------------------------------------------------

def win0(+m: Nat, +p: Nat, +X: List<&2, U32>) -> {VF.WIN(m, Nat.add(0n, p), X) == VS.wtake(m, VB.wdr(p, X)) : List<&2, U32>}: {==}

def win_nil(+p: Nat, +X: List<&2, U32>) -> {VF.WIN(0n, p, X) == [] : List<&2, U32>}: {==}

def cat_cons(+a: +List<U32>, +r: +List<+List<U32>>) -> {VZ.cat(Con{a, r}) == VF.app(a, VZ.cat(r)) : List<&2, U32>}: {==}

def cat_nil() -> {VZ.cat([]) == [] : List<&2, U32>}: {==}

def len_WIN(+m: Nat, +p: Nat, +X: List<&2, U32>, +h: {Nat.is_le(Nat.add(m, p), VB.len(X)) == True{} : Bool})
    -> {FD.spec_common__length(U32, VF.WIN(m, p, X)) == m : Nat}:
  VZ.len_win(m, p, X, h)

# A size of at most 4 2^d bytes (d < 30) fits in four bytes; x stays symbolic here, so a size
# starting with a large literal is not unrolled against 2^(2 + d).
def fitq(+d: Nat, +x: Nat, +h: {Nat.is_le(x, A.quad(VB.pw(d))) == True{} : Bool}, +hd: {Nat.is_lt(d, 30n) == True{} : Bool})
    -> {N.fits(4n, x) == True{} : Bool}:
  VFT.fits4(2n+d, x, h, hd)

# The header's size F plus the child's bytes Y (at most l bytes, F + l = len <= 4 2^d) fits in four bytes.
def fit_b(+d: Nat, +F: Nat, +l: U32, +len: U32, +Y: +List<U32>, +hY: {Nat.is_le(List.length(&2, U32, Y), U32.to_nat(l)) == True{} : Bool},
    +en: {Nat.add(F, U32.to_nat(l)) == U32.to_nat(len) : Nat}, +hl: {Nat.is_le(U32.to_nat(len), A.quad(VB.pw(d))) == True{} : Bool},
    +hd: {Nat.is_lt(d, 30n) == True{} : Bool}) -> {N.fits(4n, Nat.add(F, List.length(&2, U32, Y))) == True{} : Bool}:
  +h0 = FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(len), Nat.add(F, U32.to_nat(l)), Equal.sym(Nat, Nat.add(F, U32.to_nat(l)), U32.to_nat(len), en), hl)
  fitq(d, Nat.add(F, List.length(&2, U32, Y)), FD.nat__le_trans(Nat.add(F, List.length(&2, U32, Y)), Nat.add(F, U32.to_nat(l)), A.quad(VB.pw(d)), Order.add_left(F, List.length(&2, U32, Y), U32.to_nat(l), hY), h0), hd)
