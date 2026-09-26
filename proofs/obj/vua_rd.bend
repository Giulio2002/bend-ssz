import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../src/primitives.bend as I
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vnest.bend as VN
import ./vbitc.bend as VBC
import ./vcopy.bend as VC
import ./vbrt.bend as VR
import ../../proofs/nat_order.bend as Order
import ./vua.bend as UA

# The unaligned-offset layer, U3: the runtime's fixed-size scalar reads at ANY
# byte offset X. A uint64 is two four-byte reads (rd64_any), whose limbs are
# the buffer's spec bytes [X, X + 8) (rd64_bytes). (uint32 and offsets are
# UA.rd_any, bytes and bools VR.byte_at_ok, byte vectors vua_sc.copy_in_ua*.)

def X4(+X: U32) -> U32: U32.add(X, 4)

# x + 8 == 4 + (x + 4)
def e84(+x: Nat) -> {Nat.add(x, 8n) == 4n+Nat.add(x, 4n) : Nat}:
  %Equal.sym(Nat, Nat.add(x, 4n), Nat.add(4n, x), F.nat__add_comm(x, 4n)) : {Nat.add(x, 8n) == 4n+_ : Nat}
  F.nat__add_comm(x, 8n)

# The second word's offset: X + 4 without wrap.
def ex4(+d: Nat, +X: U32, +hd: {Nat.is_lt(d, 30n) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(U32.to_nat(X), 8n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {U32.to_nat(X4(X)) == Nat.add(U32.to_nat(X), 4n) : Nat}:
  +h8 = F.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, Nat.add(U32.to_nat(X), 8n), 4n+Nat.add(U32.to_nat(X), 4n), e84(U32.to_nat(X)), h)
  +hl = F.nat__lt_le_trans(Nat.add(4n, U32.to_nat(X)), 4n+Nat.add(U32.to_nat(X), 4n), VB.pw(2n+d),
    F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(4n, U32.to_nat(X)), 4n+z) == True{} : Bool}, Nat.add(4n, U32.to_nat(X)), Nat.add(U32.to_nat(X), 4n), F.nat__add_comm(4n, U32.to_nat(X)),
      F.nat__le_lt_trans(Nat.add(4n, U32.to_nat(X)), Nat.add(4n, U32.to_nat(X)), 4n+Nat.add(4n, U32.to_nat(X)), F.nat__le_refl(Nat.add(4n, U32.to_nat(X))), VB.lt_kk(0n, 4n, Nat.add(4n, U32.to_nat(X)), {==}))),
    h8)
  Equal.trans(Nat, U32.to_nat(X4(X)), Nat.add(4n, U32.to_nat(X)), Nat.add(U32.to_nat(X), 4n),
    VB.add_at(X, 4, U32.to_nat(X), 2n+d, {==}, hd, hl), F.nat__add_comm(4n, U32.to_nat(X)))

def h4(+d: Nat, +X: U32, +hd: {Nat.is_lt(d, 30n) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(U32.to_nat(X), 8n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat(X4(X)), 4n), A.quad(VB.pw(d))) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(X4(X)), Nat.add(U32.to_nat(X), 4n), ex4(d, X, hd, h)) : {Nat.is_le(Nat.add(_, 4n), A.quad(VB.pw(d))) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(Nat.add(U32.to_nat(X), 4n), 4n), Nat.add(U32.to_nat(X), 8n), F.nat__add_assoc(U32.to_nat(X), 4n, 4n)) : {Nat.is_le(_, A.quad(VB.pw(d))) == True{} : Bool}
  h

def h0(+d: Nat, +X: U32, +h: {Nat.is_le(Nat.add(U32.to_nat(X), 8n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(Nat.add(U32.to_nat(X), 4n), A.quad(VB.pw(d))) == True{} : Bool}:
  F.nat__le_trans(Nat.add(U32.to_nat(X), 4n), Nat.add(U32.to_nat(X), 8n), A.quad(VB.pw(d)),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(U32.to_nat(X), 4n), z) == True{} : Bool}, 4n+Nat.add(U32.to_nat(X), 4n), Nat.add(U32.to_nat(X), 8n),
      Equal.sym(Nat, Nat.add(U32.to_nat(X), 8n), 4n+Nat.add(U32.to_nat(X), 4n), e84(U32.to_nat(X))), A.le_skip(4n, Nat.add(U32.to_nat(X), 4n))),
    h)

# U3: the uint64 read at any offset X with X + 8 <= 4 2^d.
law rd64_any:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +X: U32
  for +hd: {Nat.is_lt(d, 30n) == True{} : Bool}
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +h: {Nat.is_le(Nat.add(U32.to_nat(X), 8n), A.quad(VB.pw(d))) == True{} : Bool}
  {O.rd_u64(UA.BF(t, n), X) == (UA.BF(t, n), O.U64{UA.RW(t, X), UA.RW(t, X4(X))}) : B.Buf & O.U64}
def rd64_any(d, t, n, X, hd, pf, h):
  +hd31 = F.nat__lt_trans(d, 30n, 31n, hd, {==})
  %Equal.sym(B.Buf & U32, B.read32(UA.BF(t, n), X), (UA.BF(t, n), UA.RW(t, X)), UA.rd_any(d, t, n, X, hd31, pf, h0(d, X, h))) :
    {O.u64_of(B.read64_lo(X, _)) == (UA.BF(t, n), O.U64{UA.RW(t, X), UA.RW(t, X4(X))}) : B.Buf & O.U64}
  %Equal.sym(B.Buf & U32, B.read32(UA.BF(t, n), X4(X)), (UA.BF(t, n), UA.RW(t, X4(X))), UA.rd_any(d, t, n, X4(X), hd31, pf, h4(d, X, hd, h))) :
    {O.u64_of(B.read64_hi(UA.RW(t, X), _)) == (UA.BF(t, n), O.U64{UA.RW(t, X), UA.RW(t, X4(X))}) : B.Buf & O.U64}
  {==}

# U3, bytes: the limbs of the two words are the spec bytes [X, X + 8).
law rd64_bytes:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +X: U32
  for +hd: {Nat.is_lt(d, 30n) == True{} : Bool}
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +h: {Nat.is_le(Nat.add(U32.to_nat(X), 8n), A.quad(VB.pw(d))) == True{} : Bool}
  {FX.limbs([UA.RW(t, X), UA.RW(t, X4(X))]) == VS.bt(8n, VS.bdr(U32.to_nat(X), UA.BYT(t))) : +List<U32>}
def rd64_bytes(d, t, X, hd, pf, h):
  +x = U32.to_nat(X)
  +Y = VS.bdr(x, UA.BYT(t))
  +a = UA.RW(t, X)
  +b = UA.RW(t, X4(X))
  %Equal.sym(+List<U32>, VS.bt(Nat.add(4n, 4n), Y), List.append(&2, U32, VS.bt(4n, Y), VS.bt(4n, VS.bdr(4n, Y))), VBC.bt_split(4n, 4n, Y)) :
    {List.append(&2, U32, I.limb(a), List.append(&2, U32, I.limb(b), [])) == _ : +List<U32>}
  %VN.bdr_add(x, 4n, UA.BYT(t)) :
    {List.append(&2, U32, I.limb(a), List.append(&2, U32, I.limb(b), [])) == List.append(&2, U32, VS.bt(4n, Y), VS.bt(4n, _)) : +List<U32>}
  %ex4(d, X, hd, h) :
    {List.append(&2, U32, I.limb(a), List.append(&2, U32, I.limb(b), [])) == List.append(&2, U32, VS.bt(4n, Y), VS.bt(4n, VS.bdr(_, UA.BYT(t)))) : +List<U32>}
  %UA.rd_bytes(d, t, X4(X), pf, h4(d, X, hd, h)) :
    {List.append(&2, U32, I.limb(a), List.append(&2, U32, I.limb(b), [])) == List.append(&2, U32, VS.bt(4n, Y), _) : +List<U32>}
  %UA.rd_bytes(d, t, X, pf, h0(d, X, h)) :
    {List.append(&2, U32, I.limb(a), List.append(&2, U32, I.limb(b), [])) == List.append(&2, U32, _, List.append(&2, U32, I.limb(b), [])) : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, I.limb(a), []), I.limb(a), VS.app_nil(I.limb(a))) :
    {List.append(&2, U32, I.limb(a), List.append(&2, U32, I.limb(b), [])) == List.append(&2, U32, _, List.append(&2, U32, I.limb(b), [])) : +List<U32>}
  {==}

# ---- words at a Nat byte position -----------------------------------------------------------

# k / 4 and k mod 4.
def d4(k: Nat) -> Nat:
  match k:
    case 0n: 0n
    case 1n: 0n
    case 2n: 0n
    case 3n: 0n
    case 4n+p: 1n+d4(p)

def m4(k: Nat) -> Nat:
  match k:
    case 0n: 0n
    case 1n: 1n
    case 2n: 2n
    case 3n: 3n
    case 4n+p: m4(p)

law d4_eq:
  for +q: Nat
  for +r: Nat
  for +hr: {Nat.is_lt(r, 4n) == True{} : Bool}
  {d4(Nat.add(A.quad(q), r)) == q : Nat}
def d4_eq(q, r, hr):
  match q r:
    case 0n 0n: {==}
    case 0n 1n: {==}
    case 0n 2n: {==}
    case 0n 3n: {==}
    case 0n 4n+s: Empty.absurd({d4(Nat.add(A.quad(0n), 4n+s)) == 0n : Nat}, F.nat__lt_zero_absurd(s, hr))
    case 1n+ +p _: Equal.cong(Nat, Nat, z => 1n+z, d4(Nat.add(A.quad(p), r)), p, d4_eq(p, r, hr))

law m4_eq:
  for +q: Nat
  for +r: Nat
  for +hr: {Nat.is_lt(r, 4n) == True{} : Bool}
  {m4(Nat.add(A.quad(q), r)) == r : Nat}
def m4_eq(q, r, hr):
  match q r:
    case 0n 0n: {==}
    case 0n 1n: {==}
    case 0n 2n: {==}
    case 0n 3n: {==}
    case 0n 4n+s: Empty.absurd({m4(Nat.add(A.quad(0n), 4n+s)) == 4n+s : Nat}, F.nat__lt_zero_absurd(s, hr))
    case 1n+ +p _: m4_eq(p, r, hr)

law dm4:
  for +k: Nat
  {Nat.add(A.quad(d4(k)), m4(k)) == k : Nat}
def dm4(k):
  match k:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n+ +p: Equal.cong(Nat, Nat, z => 4n+z, Nat.add(A.quad(d4(p)), m4(p)), p, dm4(p))

law m4_lt:
  for +k: Nat
  {Nat.is_lt(m4(k), 4n) == True{} : Bool}
def m4_lt(k):
  match k:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n+ +p: m4_lt(p)

# The four bytes at Nat position k, as the runtime's word join.
def RWN(+t: F.array__Tree<U32>, +k: Nat) -> U32: UA.jn(m4(k), VB.slot(t, d4(k)), VB.slot(t, 1n+d4(k)))

def rw_n(+t: F.array__Tree<U32>, +X: U32) -> {UA.RW(t, X) == RWN(t, U32.to_nat(X)) : U32}:
  +e = VC.split4(X)
  +hr = UA.rx_lt(X)
  %Equal.sym(Nat, U32.to_nat(X), Nat.add(A.quad(VR.QX(X)), VR.RX(X)), e) : {UA.RW(t, X) == RWN(t, _) : U32}
  %Equal.sym(Nat, m4(Nat.add(A.quad(VR.QX(X)), VR.RX(X))), VR.RX(X), m4_eq(VR.QX(X), VR.RX(X), hr)) :
    {UA.RW(t, X) == UA.jn(_, VB.slot(t, d4(Nat.add(A.quad(VR.QX(X)), VR.RX(X)))), VB.slot(t, 1n+d4(Nat.add(A.quad(VR.QX(X)), VR.RX(X))))) : U32}
  %Equal.sym(Nat, d4(Nat.add(A.quad(VR.QX(X)), VR.RX(X))), VR.QX(X), d4_eq(VR.QX(X), VR.RX(X), hr)) :
    {UA.RW(t, X) == UA.jn(VR.RX(X), VB.slot(t, _), VB.slot(t, 1n+_)) : U32}
  {==}

# The four-byte read at an offset X at Nat position k.
def rwx(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +X: U32, +k: Nat, +eX: {U32.to_nat(X) == k : Nat},
    +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(k, 4n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {B.read32(UA.BF(t, n), X) == (UA.BF(t, n), RWN(t, k)) : B.Buf & U32}:
  %eX : {B.read32(UA.BF(t, n), X) == (UA.BF(t, n), RWN(t, _)) : B.Buf & U32}
  %rw_n(t, X) : {B.read32(UA.BF(t, n), X) == (UA.BF(t, n), _) : B.Buf & U32}
  UA.rd_any(d, t, n, X, hd, pf, F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 4n), A.quad(VB.pw(d))) == True{} : Bool}, k, U32.to_nat(X), Equal.sym(Nat, U32.to_nat(X), k, eX), h))

# The limbs of the word at k are the spec bytes [k, k + 4).
def rwn_bytes(+d: Nat, +t: F.array__Tree<U32>, +k: Nat, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(k, 4n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {FX.limbs([RWN(t, k)]) == VS.bt(4n, VS.bdr(k, UA.BYT(t))) : +List<U32>}:
  +q = d4(k)
  +r = m4(k)
  +h2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 4n), A.quad(VB.pw(d))) == True{} : Bool}, k, Nat.add(A.quad(q), r), Equal.sym(Nat, Nat.add(A.quad(q), r), k, dm4(k)), h)
  +eL = Equal.sym(Nat, VB.len(UA.SL(t)), VB.pw(d), F.array__slots_length(U32, d, t, pf))
  %dm4(k) : {FX.limbs([RWN(t, k)]) == VS.bt(4n, VS.bdr(_, UA.BYT(t))) : +List<U32>}
  UA.bytes_r(UA.SL(t), q, r, m4_lt(k),
    F.logic__subst(Nat, z => {Nat.is_lt(q, z) == True{} : Bool}, VB.pw(d), VB.len(UA.SL(t)), eL, UA.q0_lt(q, r, VB.pw(d), h2)),
    hp => F.logic__subst(Nat, z => {Nat.is_lt(1n+q, z) == True{} : Bool}, VB.pw(d), VB.len(UA.SL(t)), eL, UA.q1_lt(q, r, VB.pw(d), hp, h2)))

# m consecutive words from position k.
def RWS(m: Nat, +t: F.array__Tree<U32>, +k: Nat) -> List<&2, U32>:
  match m:
    case 0n: []
    case 1n+p: Con{RWN(t, k), RWS(p, t, 4n+k)}

law rws_bytes:
  for +m: Nat
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +k: Nat
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +h: {Nat.is_le(Nat.add(k, A.quad(m)), A.quad(VB.pw(d))) == True{} : Bool}
  {FX.limbs(RWS(m, t, k)) == VS.bt(A.quad(m), VS.bdr(k, UA.BYT(t))) : +List<U32>}
def rws_bytes(m, d, t, k, pf, h):
  match m:
    case 0n: {==}
    case 1n+ +p:
      +Y = VS.bdr(k, UA.BYT(t))
      +v = RWN(t, k)
      +h4 = F.nat__le_trans(Nat.add(k, 4n), Nat.add(k, A.quad(1n+p)), A.quad(VB.pw(d)),
        Order.add_left(k, 4n, A.quad(1n+p), Order.below_sum(4n, A.quad(p))), h)
      +hp = F.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, Nat.add(k, Nat.add(4n, A.quad(p))), Nat.add(4n, Nat.add(k, A.quad(p))),
        F.lru_nat_algebra__add_swap(k, 4n, A.quad(p)), h)
      %Equal.sym(+List<U32>, VS.bt(Nat.add(4n, A.quad(p)), Y), List.append(&2, U32, VS.bt(4n, Y), VS.bt(A.quad(p), VS.bdr(4n, Y))), VBC.bt_split(4n, A.quad(p), Y)) :
        {List.append(&2, U32, I.limb(v), FX.limbs(RWS(p, t, 4n+k))) == _ : +List<U32>}
      %VN.bdr_add(k, 4n, UA.BYT(t)) :
        {List.append(&2, U32, I.limb(v), FX.limbs(RWS(p, t, 4n+k))) == List.append(&2, U32, VS.bt(4n, Y), VS.bt(A.quad(p), _)) : +List<U32>}
      %Equal.sym(Nat, Nat.add(k, 4n), Nat.add(4n, k), F.nat__add_comm(k, 4n)) :
        {List.append(&2, U32, I.limb(v), FX.limbs(RWS(p, t, 4n+k))) == List.append(&2, U32, VS.bt(4n, Y), VS.bt(A.quad(p), VS.bdr(_, UA.BYT(t)))) : +List<U32>}
      %Equal.sym(+List<U32>, FX.limbs(RWS(p, t, 4n+k)), VS.bt(A.quad(p), VS.bdr(4n+k, UA.BYT(t))), rws_bytes(p, d, t, 4n+k, pf, hp)) :
        {List.append(&2, U32, I.limb(v), _) == List.append(&2, U32, VS.bt(4n, Y), VS.bt(A.quad(p), VS.bdr(4n+k, UA.BYT(t)))) : +List<U32>}
      %rwn_bytes(d, t, k, pf, h4) :
        {List.append(&2, U32, I.limb(v), VS.bt(A.quad(p), VS.bdr(4n+k, UA.BYT(t)))) == List.append(&2, U32, _, VS.bt(A.quad(p), VS.bdr(4n+k, UA.BYT(t)))) : +List<U32>}
      %Equal.sym(+List<U32>, List.append(&2, U32, I.limb(v), []), I.limb(v), VS.app_nil(I.limb(v))) :
        {List.append(&2, U32, I.limb(v), VS.bt(A.quad(p), VS.bdr(4n+k, UA.BYT(t)))) == List.append(&2, U32, _, VS.bt(A.quad(p), VS.bdr(4n+k, UA.BYT(t)))) : +List<U32>}
      {==}

# Room for word c of a field of s bytes at x: (c + x) + 4 <= P from x + s <= P, c + 4 <= s.
def roomw(+x: Nat, +s: Nat, +c: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(x, s), P) == True{} : Bool}, +hc: {Nat.is_le(Nat.add(c, 4n), s) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(c, x), 4n), P) == True{} : Bool}:
  +e = Equal.trans(Nat, Nat.add(Nat.add(c, x), 4n), Nat.add(c, Nat.add(x, 4n)), Nat.add(x, Nat.add(c, 4n)),
    F.nat__add_assoc(c, x, 4n), F.lru_nat_algebra__add_swap(c, x, 4n))
  F.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, Nat.add(x, Nat.add(c, 4n)), Nat.add(Nat.add(c, x), 4n), Equal.sym(Nat, Nat.add(Nat.add(c, x), 4n), Nat.add(x, Nat.add(c, 4n)), e),
    F.nat__le_trans(Nat.add(x, Nat.add(c, 4n)), Nat.add(x, s), P, Order.add_left(x, Nat.add(c, 4n), s, hc), h))

# Room for a sub-field of s2 bytes at c inside a field of s bytes at x.
def roomf(+x: Nat, +s: Nat, +c: Nat, +s2: Nat, +P: Nat, +h: {Nat.is_le(Nat.add(x, s), P) == True{} : Bool}, +hc: {Nat.is_le(Nat.add(c, s2), s) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(c, x), s2), P) == True{} : Bool}:
  +e = Equal.trans(Nat, Nat.add(Nat.add(c, x), s2), Nat.add(c, Nat.add(x, s2)), Nat.add(x, Nat.add(c, s2)),
    F.nat__add_assoc(c, x, s2), F.lru_nat_algebra__add_swap(c, x, s2))
  F.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, Nat.add(x, Nat.add(c, s2)), Nat.add(Nat.add(c, x), s2), Equal.sym(Nat, Nat.add(Nat.add(c, x), s2), Nat.add(x, Nat.add(c, s2)), e),
    F.nat__le_trans(Nat.add(x, Nat.add(c, s2)), Nat.add(x, s), P, Order.add_left(x, Nat.add(c, s2), s, hc), h))

# off + c at position c + x, for c + x < 4 2^d (d < 30).
def offx(+d: Nat, +off: U32, +c: U32, +x: Nat, +e: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 30n) == True{} : Bool},
    +h: {Nat.is_lt(Nat.add(U32.to_nat(c), x), A.quad(VB.pw(d))) == True{} : Bool})
    -> {U32.to_nat(U32.add(off, c)) == Nat.add(U32.to_nat(c), x) : Nat}:
  VB.add_at(off, c, x, 2n+d, e, hd, h)
