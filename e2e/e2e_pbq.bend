import Base
import ../src/obj.bend as O
import ../proofs/compact/found.bend as FD
import ../proofs/nat_order.bend as Order
import ../proofs/obj/vbuf.bend as VB
import ../proofs/obj/vspec.bend as VSP
import ../proofs/obj/vdepth.bend as VD
import ./e2e_gpb.bend as GPB
import ./e2e_hv.bend as HV
import ./e2e_hvk.bend as HVK
import ./e2e_encp.bend as EP
import ./e2e_encpd.bend as EPD
import ../proofs/compact/reads.bend as RD

# The decoded progressive bit list's size bounds (the encode records' SDPB: K + 8 <= 2^31 and 31 + (K + 1) <= 2^30), from a bound on the
# bytes it was copied from: K = 8 m + h, h <= 7, m + 4 < 2^27 (the window has at most 2^27 - 4 bytes).

def hK2(+K: Nat, +m: Nat, +h: Nat, +hh: {Nat.is_le(h, 7n) == True{} : Bool}, +eK: {K == Nat.add(VSP.x8(m), h) : Nat}, +hm: {Nat.is_lt(Nat.add(4n, m), VB.pw(27n)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(31n, Nat.add(K, 1n)), VB.pw(30n)) == True{} : Bool}:
  +X = VSP.x8(m)
  +hx = GPB.x8lt(Nat.add(4n, m), 27n, hm)
  +eA = Equal.trans(Nat, Nat.add(K, 1n), Nat.add(Nat.add(X, h), 1n), Nat.add(X, Nat.add(h, 1n)), Equal.cong(Nat, Nat, z => Nat.add(z, 1n), K, Nat.add(X, h), eK), FD.nat__add_assoc(X, h, 1n))
  +a1 = FD.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(X, 8n)) == True{} : Bool}, Nat.add(X, Nat.add(h, 1n)), Nat.add(K, 1n), Equal.sym(Nat, Nat.add(K, 1n), Nat.add(X, Nat.add(h, 1n)), eA),
    Order.add_left(X, Nat.add(h, 1n), 8n, Order.add_right(h, 7n, 1n, hh)))
  +a2 = Order.add_left(31n, Nat.add(K, 1n), Nat.add(X, 8n), a1)
  +a3 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(31n, Nat.add(K, 1n)), Nat.add(31n, z)) == True{} : Bool}, Nat.add(X, 8n), Nat.add(8n, X), FD.nat__add_comm(X, 8n), a2)
  FD.nat__le_trans(Nat.add(31n, Nat.add(K, 1n)), Nat.add(39n, X), VB.pw(30n), a3,
    FD.nat__le_trans(Nat.add(39n, X), Nat.add(8n, VSP.x8(Nat.add(4n, m))), VB.pw(30n), Order.add_right(39n, 40n, X, {==}), hx))

def e32(+K: Nat) -> {Nat.add(31n, Nat.add(K, 1n)) == Nat.add(K, 32n) : Nat}:
  Equal.trans(Nat, Nat.add(31n, Nat.add(K, 1n)), Nat.add(Nat.add(K, 1n), 31n), Nat.add(K, 32n), FD.nat__add_comm(31n, Nat.add(K, 1n)),
    Equal.trans(Nat, Nat.add(Nat.add(K, 1n), 31n), Nat.add(K, Nat.add(1n, 31n)), Nat.add(K, 32n), FD.nat__add_assoc(K, 1n, 31n), {==}))

def hK1g(+K: Nat, +k: Nat, +h2: {Nat.is_le(Nat.add(31n, Nat.add(K, 1n)), VB.pw(k)) == True{} : Bool}) -> {Nat.is_le(Nat.add(K, 8n), O.pow2n(1n+k)) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(K, 8n), z) == True{} : Bool}, FD.spec_common__pow2(1n+k), O.pow2n(1n+k), VD.s_pow2_eq(1n+k),
    FD.nat__le_trans(Nat.add(K, 8n), VB.pw(k), FD.spec_common__pow2(1n+k),
      FD.nat__le_trans(Nat.add(K, 8n), Nat.add(31n, Nat.add(K, 1n)), VB.pw(k), FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(K, 8n), z) == True{} : Bool}, Nat.add(K, 32n), Nat.add(31n, Nat.add(K, 1n)), Equal.sym(Nat, Nat.add(31n, Nat.add(K, 1n)), Nat.add(K, 32n), e32(K)), Order.add_left(K, 8n, 32n, {==})), h2),
      FD.nat__pow2_mono(k, 1n+k, FD.nat__le_succ(k))))

def hK1(+K: Nat, +h2: {Nat.is_le(Nat.add(31n, Nat.add(K, 1n)), VB.pw(30n)) == True{} : Bool}) -> {Nat.is_le(Nat.add(K, 8n), O.pow2n(31n)) == True{} : Bool}:
  hK1g(K, 30n, h2)

# the window of 1 + m bytes with at most 2^27 - 4 bytes: m + 4 < 2^27
def hm4(+m: Nat, +len: U32, +e1: {U32.to_nat(len) == 1n+m : Nat}, +hlen: {Nat.is_le(Nat.add(U32.to_nat(len), 4n), VB.pw(27n)) == True{} : Bool}) -> {Nat.is_lt(Nat.add(4n, m), VB.pw(27n)) == True{} : Bool}:
  FD.nat__succ_le_lt(Nat.add(4n, m), VB.pw(27n),
    FD.logic__subst(Nat, z => {Nat.is_le(1n+z, VB.pw(27n)) == True{} : Bool}, Nat.add(m, 4n), Nat.add(4n, m), FD.nat__add_comm(m, 4n),
      FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 4n), VB.pw(27n)) == True{} : Bool}, U32.to_nat(len), 1n+m, e1, hlen)))

# the storage premise of the encode records' progressive bit list (e2e_encp.SDPB) from the hv facts and the size bounds
def sdpbx(-A_: Array<U32>, +K: U32, +dz: Nat, +hd31: {Nat.is_lt(dz, 31n) == True{} : Bool}, +h1: {Nat.is_le(Nat.add(U32.to_nat(K), 8n), O.pow2n(31n)) == True{} : Bool},
    +h2: {Nat.is_le(Nat.add(31n, Nat.add(U32.to_nat(K), 1n)), VB.pw(30n)) == True{} : Bool}, +x: HV.SDX(A_, K, dz)) -> EP.SDPB(O.Bits{A_, K}, 31n):
  (+T, x1) = x
  (+eA, x2) = x1
  (+pT, x3) = x2
  (+hr, +hv) = x3
  +hi = FD.nat__succ_le_lt(U32.to_nat(U32.shrn(K, 5n)), VB.pw(dz), FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dz)) == True{} : Bool}, Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), 1n+U32.to_nat(U32.shrn(K, 5n)), FD.nat__add_comm(U32.to_nat(U32.shrn(K, 5n)), 1n), hr))
  (T, (dz, (K, (Equal.cong(Array<U32>, O.Bits, z => O.Bits{z, K}, A_, FD.array__thaw(U32, T), eA), (pT, (hd31, (h1, (h2, (hr,
    FD.logic__subst(U32, z => {O.bits_above_zero(U32.and(K, 31), z) == True{} : Bool}, VB.slot(T, U32.to_nat(U32.shrn(K, 5n))), RD.wd(T, dz, U32.shrn(K, 5n)),
      Equal.sym(U32, RD.wd(T, dz, U32.shrn(K, 5n)), VB.slot(T, U32.to_nat(U32.shrn(K, 5n))), HVK.wd_slot(dz, T, U32.shrn(K, 5n), U32.to_nat(U32.shrn(K, 5n)), {==}, hd31, hi, pT)), hv))))))))))

# the bit count K = 8 m + h of a window of 1 + m < 2^k bytes: K + 8 <= 2^(3 + k)
def hK32g(+K: Nat, +m: Nat, +h: Nat, +hh: {Nat.is_le(h, 7n) == True{} : Bool}, +eK: {K == Nat.add(VSP.x8(m), h) : Nat}, +k: Nat, +hm: {Nat.is_lt(1n+m, VB.pw(k)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(K, 8n), O.pow2n(3n+k)) == True{} : Bool}:
  +X = VSP.x8(m)
  +hx = GPB.x8lt(1n+m, k, hm)
  +eA = Equal.trans(Nat, Nat.add(K, 8n), Nat.add(Nat.add(X, h), 8n), Nat.add(X, Nat.add(h, 8n)), Equal.cong(Nat, Nat, z => Nat.add(z, 8n), K, Nat.add(X, h), eK), FD.nat__add_assoc(X, h, 8n))
  +a1 = FD.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(X, 15n)) == True{} : Bool}, Nat.add(X, Nat.add(h, 8n)), Nat.add(K, 8n), Equal.sym(Nat, Nat.add(K, 8n), Nat.add(X, Nat.add(h, 8n)), eA),
    Order.add_left(X, Nat.add(h, 8n), 15n, Order.add_right(h, 7n, 8n, hh)))
  +a3 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(K, 8n), z) == True{} : Bool}, Nat.add(X, 15n), Nat.add(15n, X), FD.nat__add_comm(X, 15n), a1)
  FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(K, 8n), z) == True{} : Bool}, VB.pw(3n+k), O.pow2n(3n+k), VD.s_pow2_eq(3n+k),
    FD.nat__le_trans(Nat.add(K, 8n), Nat.add(8n, VSP.x8(1n+m)), VB.pw(3n+k), FD.nat__le_trans(Nat.add(K, 8n), Nat.add(15n, X), Nat.add(8n, VSP.x8(1n+m)), a3, Order.add_right(15n, 16n, X, {==})), hx))

def sdpbxd(-A_: Array<U32>, +K: U32, +dz: Nat, +hd31: {Nat.is_lt(dz, 31n) == True{} : Bool}, +h1: {Nat.is_le(Nat.add(U32.to_nat(K), 8n), O.pow2n(32n)) == True{} : Bool},
    +x: HV.SDX(A_, K, dz)) -> EPD.SDPB(O.Bits{A_, K}, 31n):
  (+T, x1) = x
  (+eA, x2) = x1
  (+pT, x3) = x2
  (+hr, +hv) = x3
  +hi = FD.nat__succ_le_lt(U32.to_nat(U32.shrn(K, 5n)), VB.pw(dz), FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dz)) == True{} : Bool}, Nat.add(U32.to_nat(U32.shrn(K, 5n)), 1n), 1n+U32.to_nat(U32.shrn(K, 5n)), FD.nat__add_comm(U32.to_nat(U32.shrn(K, 5n)), 1n), hr))
  (T, (dz, (K, (Equal.cong(Array<U32>, O.Bits, z => O.Bits{z, K}, A_, FD.array__thaw(U32, T), eA), (pT, (hd31, (h1, (hr,
    FD.logic__subst(U32, z => {O.bits_above_zero(U32.and(K, 31), z) == True{} : Bool}, VB.slot(T, U32.to_nat(U32.shrn(K, 5n))), RD.wd(T, dz, U32.shrn(K, 5n)),
      Equal.sym(U32, RD.wd(T, dz, U32.shrn(K, 5n)), VB.slot(T, U32.to_nat(U32.shrn(K, 5n))), HVK.wd_slot(dz, T, U32.shrn(K, 5n), U32.to_nat(U32.shrn(K, 5n)), {==}, hd31, hi, pT)), hv)))))))))
