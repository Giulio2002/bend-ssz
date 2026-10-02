import Base
import ../../src/obj.bend as O
import ../compact/found_generated.bend as F
import ../compact/arith.bend as A
import ../nat_order.bend as Order
import ../../spec/nat_bytes.bend as N
import ./vbuf.bend as VB
import ./vcopy.bend as VC
import ./vdepth.bend as VD
import ./vfits.bend as VFT
import ./arr_vec_generated.bend as AV
import ./vspec.bend as VS

# Hand-written. Facts about a large byte size L that is a power of two, 2^p, stated over
# U32.to_nat(L) and VB.pw(..). No statement holds a closed Nat literal of the size, and none
# evaluates a closed power of two: relating the U32 2097152 to the Nat literal 2097152n (or
# computing m8(65536n), A.quad(524288n), N.fits(4n, 2097152n)) was unary work of millions of
# steps per fact (codegen/var_fixx.py's big vectors, codegen/var_winb.py's layout).
# Instances pass L's power by eL: {L == F.u32__pow2u(p)}, a 32-bit {==}.

def false_true(e: {False{} == True{} : Bool}) -> Empty: F.logic__false_true(e)

law pw_pos:
  for +b: Nat
  {Nat.is_le(1n, VB.pw(b)) == True{} : Bool}
def pw_pos(b):
  match b:
    case 0n: {==}
    case 1n+ +q: F.nat__le_trans(1n, VB.pw(q), Nat.double(VB.pw(q)), pw_pos(q), F.nat__double_self_le(VB.pw(q)))

law pw_mono:
  for +a: Nat
  for +b: Nat
  for +h: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(VB.pw(a), VB.pw(b)) == True{} : Bool}
def pw_mono(a, b, h):
  match a b:
    case 0n _: pw_pos(b)
    case 1n+p 0n: Empty.absurd({Nat.is_le(VB.pw(1n+p), VB.pw(0n)) == True{} : Bool}, false_true(h))
    case 1n+ +p 1n+ +q: F.nat__double_le(VB.pw(p), VB.pw(q), pw_mono(p, q, h))

# The U32 2^p is VB.pw(p).
def u32pow(+L: U32, +p: Nat, +eL: {L == F.u32__pow2u(p) : U32}, +hp: {Nat.is_lt(p, 32n) == True{} : Bool})
    -> {U32.to_nat(L) == VB.pw(p) : Nat}:
  %Equal.sym(U32, L, F.u32__pow2u(p), eL) : {U32.to_nat(_) == VB.pw(p) : Nat}
  F.u32__pow2u_value(p, hp)

# ceil((4P + 3) / 4) = P, as two halvings.
law h2q:
  for +P: Nat
  {VD.s_h2(VD.s_h2(Nat.add(A.quad(P), 3n))) == P : Nat}
def h2q(P):
  match P:
    case 0n: {==}
    case 1n+ +Q:
      %Equal.sym(Nat, VD.s_h2(VD.s_h2(Nat.add(A.quad(Q), 3n))), Q, h2q(Q)) : {1n+_ == 1n+Q : Nat}
      {==}

# 4P + 3 <= 8P for P >= 1
def e83(+P: Nat, +hP: {Nat.is_le(1n, P) == True{} : Bool})
    -> {Nat.is_le(Nat.add(A.quad(P), 3n), Nat.double(Nat.double(Nat.double(P)))) == True{} : Bool}:
  match P:
    case 0n: Empty.absurd({Nat.is_le(Nat.add(A.quad(0n), 3n), Nat.double(Nat.double(Nat.double(0n)))) == True{} : Bool}, false_true(hP))
    case 1n+ +Q:
      +E = Nat.double(Nat.double(Nat.double(Q)))
      +h1 = F.nat__le_trans(A.quad(Q), E, 1n+E, F.nat__double_self_le(A.quad(Q)), F.nat__le_succ(E))
      F.logic__subst(Nat, z => {Nat.is_le(z, 4n+E) == True{} : Bool}, Nat.add(3n, A.quad(Q)), Nat.add(A.quad(Q), 3n), F.nat__add_comm(3n, A.quad(Q)), h1)

# The words of 2^(2+q) bytes: VC.NW(L) = 2^q, within a zero storage of depth dz >= q.
def nw_pow(+L: U32, +q: Nat, +dz: Nat, +eL: {L == F.u32__pow2u(2n+q) : U32}, +hq: {Nat.is_lt(3n+q, 32n) == True{} : Bool},
    +hqd: {Nat.is_le(q, dz) == True{} : Bool})
    -> {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool}:
  +P = VB.pw(q)
  +hq2 = F.nat__lt_trans(2n+q, 3n+q, 32n, F.nat__lt_succ(2n+q), hq)
  +eN = u32pow(L, 2n+q, eL, hq2)
  +hA = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 3n), U32.to_nat(F.u32__pow2u(3n+q))) == True{} : Bool}, A.quad(P), U32.to_nat(L), Equal.sym(Nat, U32.to_nat(L), A.quad(P), eN),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(P), 3n), z) == True{} : Bool}, VB.pw(3n+q), U32.to_nat(F.u32__pow2u(3n+q)), Equal.sym(Nat, U32.to_nat(F.u32__pow2u(3n+q)), VB.pw(3n+q), F.u32__pow2u_value(3n+q, hq)),
      e83(P, pw_pos(q))))
  +eadd = A.add_le(L, 3, F.u32__pow2u(3n+q), hA)
  +eW = Equal.trans(Nat, VC.NW(L), VD.s_rng(2n, U32.to_nat(U32.add(L, 3))), P,
    VD.shrk(2n, U32.add(L, 3)),
    Equal.trans(Nat, VD.s_rng(2n, U32.to_nat(U32.add(L, 3))), VD.s_rng(2n, Nat.add(A.quad(P), 3n)), P,
      Equal.cong(Nat, Nat, z => VD.s_rng(2n, z), U32.to_nat(U32.add(L, 3)), Nat.add(A.quad(P), 3n),
        Equal.trans(Nat, U32.to_nat(U32.add(L, 3)), Nat.add(U32.to_nat(L), 3n), Nat.add(A.quad(P), 3n), eadd,
          Equal.cong(Nat, Nat, z => Nat.add(z, 3n), U32.to_nat(L), A.quad(P), eN))),
      h2q(P)))
  %Equal.sym(Nat, VC.NW(L), P, eW) : {Nat.is_le(Nat.add(_, 0n), VB.pw(dz)) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(P, 0n), P, F.nat__add_zero(P)) : {Nat.is_le(_, VB.pw(dz)) == True{} : Bool}
  pw_mono(q, dz, hqd)

# 31 + 2^p <= 2^k for 5 <= p, p + 1 <= k.
def yl_pow(+L: U32, +p: Nat, +k: Nat, +eL: {L == F.u32__pow2u(p) : U32}, +hp: {Nat.is_lt(p, 32n) == True{} : Bool},
    +h5: {Nat.is_le(5n, p) == True{} : Bool}, +hk: {Nat.is_le(1n+p, k) == True{} : Bool})
    -> {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool}:
  +P = VB.pw(p)
  +h31 = F.nat__le_trans(31n, VB.pw(5n), P, {==}, pw_mono(5n, p, h5))
  +h1 = F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(P, P)) == True{} : Bool}, Nat.add(P, 31n), Nat.add(31n, P), F.nat__add_comm(P, 31n), F.nat__le_add_left(31n, P, P, h31))
  +eD = Equal.trans(Nat, Nat.double(P), Nat.add(P, Nat.add(P, 0n)), Nat.add(P, P), F.u32__double_pow(P), Equal.cong(Nat, Nat, z => Nat.add(P, z), Nat.add(P, 0n), P, F.nat__add_zero(P)))
  +h2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(31n, P), z) == True{} : Bool}, Nat.add(P, P), Nat.double(P), Equal.sym(Nat, Nat.double(P), Nat.add(P, P), eD), h1)
  %Equal.sym(Nat, U32.to_nat(L), P, u32pow(L, p, eL, hp)) : {Nat.is_le(Nat.add(31n, _), VB.pw(k)) == True{} : Bool}
  F.nat__le_trans(Nat.add(31n, P), VB.pw(1n+p), VB.pw(k), h2, pw_mono(1n+p, k, hk))

law m8_d3:
  for +x: Nat
  {AV.m8(x) == Nat.double(Nat.double(Nat.double(x))) : Nat}
def m8_d3(x):
  match x:
    case 0n: {==}
    case 1n+ +q:
      %Equal.sym(Nat, AV.m8(q), Nat.double(Nat.double(Nat.double(q))), m8_d3(q)) : {8n+_ == 8n+Nat.double(Nat.double(Nat.double(q))) : Nat}
      {==}

# The words and bytes of a vector of k = 2^e 32-byte elements: 4 m8(k) = 2^r, r = 5 + e.
def es_pow(+L: U32, +k: Nat, +e: Nat, +r: Nat, +ek: {k == VB.pw(e) : Nat}, +er: {r == 5n+e : Nat}, +eL: {L == F.u32__pow2u(r) : U32},
    +hr: {Nat.is_lt(r, 32n) == True{} : Bool})
    -> {Nat.is_eq(A.quad(AV.m8(k)), U32.to_nat(L)) == True{} : Bool}:
  +P = VB.pw(e)
  %Equal.sym(Nat, U32.to_nat(L), VB.pw(r), u32pow(L, r, eL, hr)) : {Nat.is_eq(A.quad(AV.m8(k)), _) == True{} : Bool}
  %Equal.sym(Nat, r, 5n+e, er) : {Nat.is_eq(A.quad(AV.m8(k)), VB.pw(_)) == True{} : Bool}
  %Equal.sym(Nat, k, P, ek) : {Nat.is_eq(A.quad(AV.m8(_)), VB.pw(5n+e)) == True{} : Bool}
  %Equal.sym(Nat, AV.m8(P), Nat.double(Nat.double(Nat.double(P))), m8_d3(P)) : {Nat.is_eq(A.quad(_), VB.pw(5n+e)) == True{} : Bool}
  F.nat__is_eq_refl(VB.pw(5n+e))

# The spec's size bound for 2^r bytes.
def fits_pow(+L: U32, +r: Nat, +eL: {L == F.u32__pow2u(r) : U32}, +hr: {Nat.is_lt(r, 32n) == True{} : Bool})
    -> {N.fits(4n, Nat.add(U32.to_nat(L), 0n)) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(U32.to_nat(L), 0n), U32.to_nat(L), F.nat__add_zero(U32.to_nat(L))) : {N.fits(4n, _) == True{} : Bool}
  %Equal.sym(Nat, U32.to_nat(L), VB.pw(r), u32pow(L, r, eL, hr)) : {N.fits(4n, _) == True{} : Bool}
  VFT.fits4(r, VB.pw(r), F.nat__le_refl(VB.pw(r)), hr)

# 0 < k = 2^e
def pos_pow(+k: Nat, +e: Nat, +ek: {k == VB.pw(e) : Nat}) -> {Nat.is_lt(0n, k) == True{} : Bool}:
  %Equal.sym(Nat, k, VB.pw(e), ek) : {Nat.is_lt(0n, _) == True{} : Bool}
  F.nat__succ_le_lt(0n, VB.pw(e), pw_pos(e))

law m2_d1:
  for +x: Nat
  {AV.m2(x) == Nat.double(x) : Nat}
def m2_d1(x):
  match x:
    case 0n: {==}
    case 1n+ +q:
      %Equal.sym(Nat, AV.m2(q), Nat.double(q), m2_d1(q)) : {2n+_ == 2n+Nat.double(q) : Nat}
      {==}

# The words and bytes of a vector of k = 2^e 8-byte elements: 4 m2(k) = 2^r, r = 3 + e.
def es_pow2(+L: U32, +k: Nat, +e: Nat, +r: Nat, +ek: {k == VB.pw(e) : Nat}, +er: {r == 3n+e : Nat}, +eL: {L == F.u32__pow2u(r) : U32},
    +hr: {Nat.is_lt(r, 32n) == True{} : Bool})
    -> {Nat.is_eq(A.quad(AV.m2(k)), U32.to_nat(L)) == True{} : Bool}:
  +P = VB.pw(e)
  %Equal.sym(Nat, U32.to_nat(L), VB.pw(r), u32pow(L, r, eL, hr)) : {Nat.is_eq(A.quad(AV.m2(k)), _) == True{} : Bool}
  %Equal.sym(Nat, r, 3n+e, er) : {Nat.is_eq(A.quad(AV.m2(k)), VB.pw(_)) == True{} : Bool}
  %Equal.sym(Nat, k, P, ek) : {Nat.is_eq(A.quad(AV.m2(_)), VB.pw(3n+e)) == True{} : Bool}
  %Equal.sym(Nat, AV.m2(P), Nat.double(P), m2_d1(P)) : {Nat.is_eq(A.quad(_), VB.pw(3n+e)) == True{} : Bool}
  F.nat__is_eq_refl(VB.pw(3n+e))

law mul32:
  for +x: Nat
  {Nat.mul(x, 32n) == Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(x))))) : Nat}
def mul32(x):
  match x:
    case 0n: {==}
    case 1n+ +q:
      %Equal.sym(Nat, Nat.mul(q, 32n), Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(q))))), mul32(q)) :
        {Nat.add(32n, _) == 32n+Nat.double(Nat.double(Nat.double(Nat.double(Nat.double(q))))) : Nat}
      {==}

law mul8:
  for +x: Nat
  {Nat.mul(x, 8n) == Nat.double(Nat.double(Nat.double(x))) : Nat}
def mul8(x):
  match x:
    case 0n: {==}
    case 1n+ +q:
      %Equal.sym(Nat, Nat.mul(q, 8n), Nat.double(Nat.double(Nat.double(q))), mul8(q)) :
        {Nat.add(8n, _) == 8n+Nat.double(Nat.double(Nat.double(q))) : Nat}
      {==}

# The spec's fixed size of a vector of k = 2^e elements of 32 (8) bytes is the U32 L = 2^r bytes.
def fz32(+k: Nat, +e: Nat, +r: Nat, +L: U32, +ek: {k == VB.pw(e) : Nat}, +er: {r == 5n+e : Nat}, +eL: {L == F.u32__pow2u(r) : U32},
    +hr: {Nat.is_lt(r, 32n) == True{} : Bool}) -> {Nat.mul(k, 32n) == U32.to_nat(L) : Nat}:
  %Equal.sym(Nat, U32.to_nat(L), VB.pw(r), u32pow(L, r, eL, hr)) : {Nat.mul(k, 32n) == _ : Nat}
  %Equal.sym(Nat, r, 5n+e, er) : {Nat.mul(k, 32n) == VB.pw(_) : Nat}
  %Equal.sym(Nat, k, VB.pw(e), ek) : {Nat.mul(_, 32n) == VB.pw(5n+e) : Nat}
  mul32(VB.pw(e))
def fz8(+k: Nat, +e: Nat, +r: Nat, +L: U32, +ek: {k == VB.pw(e) : Nat}, +er: {r == 3n+e : Nat}, +eL: {L == F.u32__pow2u(r) : U32},
    +hr: {Nat.is_lt(r, 32n) == True{} : Bool}) -> {Nat.mul(k, 8n) == U32.to_nat(L) : Nat}:
  %Equal.sym(Nat, U32.to_nat(L), VB.pw(r), u32pow(L, r, eL, hr)) : {Nat.mul(k, 8n) == _ : Nat}
  %Equal.sym(Nat, r, 3n+e, er) : {Nat.mul(k, 8n) == VB.pw(_) : Nat}
  %Equal.sym(Nat, k, VB.pw(e), ek) : {Nat.mul(_, 8n) == VB.pw(3n+e) : Nat}
  mul8(VB.pw(e))

# ---- closed sizes around a large list limit ------------------------------------------
# A closed Nat built from a list's byte limit 8 * M (M = 2^p) and small constants is carried
# as {x == Nat.add(c, VB.pw(s))} with small literals c and s, and bounded by ble/blt; the
# closed power itself is never evaluated (codegen/lim_pow.py builds the terms).

law two_pw:
  for +P: Nat
  {Nat.add(P, P) == Nat.double(P) : Nat}
def two_pw(P):
  Equal.sym(Nat, Nat.double(P), Nat.add(P, P),
    Equal.trans(Nat, Nat.double(P), Nat.add(P, Nat.add(P, 0n)), Nat.add(P, P), F.u32__double_pow(P), Equal.cong(Nat, Nat, z => Nat.add(P, z), Nat.add(P, 0n), P, F.nat__add_zero(P))))

# 8 M = 0 + 2^q, q = 3 + p
def x8pw(+M: U32, +p: Nat, +q: Nat, +eM: {M == F.u32__pow2u(p) : U32}, +hp: {Nat.is_lt(p, 32n) == True{} : Bool}, +eq: {q == 3n+p : Nat})
    -> {VS.x8(U32.to_nat(M)) == Nat.add(0n, VB.pw(q)) : Nat}:
  %Equal.sym(Nat, U32.to_nat(M), VB.pw(p), u32pow(M, p, eM, hp)) : {VS.x8(_) == Nat.add(0n, VB.pw(q)) : Nat}
  %Equal.sym(Nat, VS.x8(VB.pw(p)), VB.d3(VB.pw(p)), VB.x8_d3(VB.pw(p))) : {_ == Nat.add(0n, VB.pw(q)) : Nat}
  %Equal.sym(Nat, q, 3n+p, eq) : {VB.d3(VB.pw(p)) == Nat.add(0n, VB.pw(_)) : Nat}
  {==}

# 2 M = 0 + 2^s, s = 1 + p
def dblpw(+M: U32, +p: Nat, +s: Nat, +eM: {M == F.u32__pow2u(p) : U32}, +hp: {Nat.is_lt(p, 32n) == True{} : Bool}, +es: {s == 1n+p : Nat})
    -> {Nat.double(U32.to_nat(M)) == Nat.add(0n, VB.pw(s)) : Nat}:
  %Equal.sym(Nat, U32.to_nat(M), VB.pw(p), u32pow(M, p, eM, hp)) : {Nat.double(_) == Nat.add(0n, VB.pw(s)) : Nat}
  %Equal.sym(Nat, s, 1n+p, es) : {Nat.double(VB.pw(p)) == Nat.add(0n, VB.pw(_)) : Nat}
  {==}

# a + (c + 2^s) = d + 2^s, d = a + c
def eadd(+a: Nat, +x: Nat, +c: Nat, +s: Nat, +d: Nat, +ex: {x == Nat.add(c, VB.pw(s)) : Nat}, +ed: {d == Nat.add(a, c) : Nat})
    -> {Nat.add(a, x) == Nat.add(d, VB.pw(s)) : Nat}:
  %Equal.sym(Nat, x, Nat.add(c, VB.pw(s)), ex) : {Nat.add(a, _) == Nat.add(d, VB.pw(s)) : Nat}
  %Equal.sym(Nat, d, Nat.add(a, c), ed) : {Nat.add(a, Nat.add(c, VB.pw(s))) == Nat.add(_, VB.pw(s)) : Nat}
  Equal.sym(Nat, Nat.add(Nat.add(a, c), VB.pw(s)), Nat.add(a, Nat.add(c, VB.pw(s))), F.nat__add_assoc(a, c, VB.pw(s)))

# (c + 2^s) + a = d + 2^s, d = c + a
def eaddr(+x: Nat, +a: Nat, +c: Nat, +s: Nat, +d: Nat, +ex: {x == Nat.add(c, VB.pw(s)) : Nat}, +ed: {d == Nat.add(c, a) : Nat})
    -> {Nat.add(x, a) == Nat.add(d, VB.pw(s)) : Nat}:
  +P = VB.pw(s)
  %Equal.sym(Nat, x, Nat.add(c, P), ex) : {Nat.add(_, a) == Nat.add(d, VB.pw(s)) : Nat}
  %Equal.sym(Nat, d, Nat.add(c, a), ed) : {Nat.add(Nat.add(c, P), a) == Nat.add(_, VB.pw(s)) : Nat}
  %Equal.sym(Nat, Nat.add(Nat.add(c, P), a), Nat.add(c, Nat.add(P, a)), F.nat__add_assoc(c, P, a)) : {_ == Nat.add(Nat.add(c, a), P) : Nat}
  %Equal.sym(Nat, Nat.add(P, a), Nat.add(a, P), F.nat__add_comm(P, a)) : {Nat.add(c, _) == Nat.add(Nat.add(c, a), P) : Nat}
  Equal.sym(Nat, Nat.add(Nat.add(c, a), P), Nat.add(c, Nat.add(a, P)), F.nat__add_assoc(c, a, P))

# floor((2P + c) / 2) = P + floor(c / 2)
law h2dbl:
  for +P: Nat
  for +c: Nat
  {VD.s_h2(Nat.add(Nat.double(P), c)) == Nat.add(P, VD.s_h2(c)) : Nat}
def h2dbl(P, c):
  match P:
    case 0n: {==}
    case 1n+ +Q:
      %Equal.sym(Nat, VD.s_h2(Nat.add(Nat.double(Q), c)), Nat.add(Q, VD.s_h2(c)), h2dbl(Q, c)) : {1n+_ == 1n+Nat.add(Q, VD.s_h2(c)) : Nat}
      {==}

# floor((c + 2^s) / 4) = d + 2^t, s = 2 + t, d = floor(c / 4)
def erng(+x: Nat, +c: Nat, +s: Nat, +t: Nat, +d: Nat, +ex: {x == Nat.add(c, VB.pw(s)) : Nat}, +es: {s == 2n+t : Nat}, +ed: {d == VD.s_rng(2n, c) : Nat})
    -> {VD.s_rng(2n, x) == Nat.add(d, VB.pw(t)) : Nat}:
  +P = VB.pw(t)
  %Equal.sym(Nat, x, Nat.add(c, VB.pw(s)), ex) : {VD.s_rng(2n, _) == Nat.add(d, VB.pw(t)) : Nat}
  %Equal.sym(Nat, s, 2n+t, es) : {VD.s_rng(2n, Nat.add(c, VB.pw(_))) == Nat.add(d, VB.pw(t)) : Nat}
  %Equal.sym(Nat, d, VD.s_rng(2n, c), ed) : {VD.s_rng(2n, Nat.add(c, VB.pw(2n+t))) == Nat.add(_, VB.pw(t)) : Nat}
  %Equal.sym(Nat, Nat.add(c, VB.pw(2n+t)), Nat.add(VB.pw(2n+t), c), F.nat__add_comm(c, VB.pw(2n+t))) : {VD.s_rng(2n, _) == Nat.add(VD.s_rng(2n, c), P) : Nat}
  +S = VD.s_h2(VD.s_h2(c))
  Equal.trans(Nat, VD.s_h2(VD.s_h2(Nat.add(Nat.double(Nat.double(P)), c))), Nat.add(P, S), Nat.add(S, P),
    Equal.trans(Nat, VD.s_h2(VD.s_h2(Nat.add(Nat.double(Nat.double(P)), c))), VD.s_h2(Nat.add(Nat.double(P), VD.s_h2(c))), Nat.add(P, S),
      Equal.cong(Nat, Nat, z => VD.s_h2(z), VD.s_h2(Nat.add(Nat.double(Nat.double(P)), c)), Nat.add(Nat.double(P), VD.s_h2(c)), h2dbl(Nat.double(P), c)),
      h2dbl(P, VD.s_h2(c))),
    F.nat__add_comm(P, S))

# (c1 + 2^s) = d + 2^t, d = c1 + c2, t = 1 + s
def esum(+x: Nat, +y: Nat, +c1: Nat, +c2: Nat, +d: Nat, +s: Nat, +t: Nat,
    +ex: {x == Nat.add(c1, VB.pw(s)) : Nat}, +ey: {y == Nat.add(c2, VB.pw(s)) : Nat}, +ed: {d == Nat.add(c1, c2) : Nat}, +et: {t == 1n+s : Nat})
    -> {Nat.add(x, y) == Nat.add(d, VB.pw(t)) : Nat}:
  +P = VB.pw(s)
  %Equal.sym(Nat, x, Nat.add(c1, P), ex) : {Nat.add(_, y) == Nat.add(d, VB.pw(t)) : Nat}
  %Equal.sym(Nat, y, Nat.add(c2, P), ey) : {Nat.add(Nat.add(c1, P), _) == Nat.add(d, VB.pw(t)) : Nat}
  %Equal.sym(Nat, d, Nat.add(c1, c2), ed) : {Nat.add(Nat.add(c1, P), Nat.add(c2, P)) == Nat.add(_, VB.pw(t)) : Nat}
  %Equal.sym(Nat, t, 1n+s, et) : {Nat.add(Nat.add(c1, P), Nat.add(c2, P)) == Nat.add(Nat.add(c1, c2), VB.pw(_)) : Nat}
  +R = Nat.add(Nat.add(c1, c2), VB.pw(1n+s))
  %Equal.sym(Nat, Nat.add(Nat.add(c1, P), Nat.add(c2, P)), Nat.add(c1, Nat.add(P, Nat.add(c2, P))), F.nat__add_assoc(c1, P, Nat.add(c2, P))) : {_ == R : Nat}
  %Equal.sym(Nat, Nat.add(P, Nat.add(c2, P)), Nat.add(Nat.add(P, c2), P), Equal.sym(Nat, Nat.add(Nat.add(P, c2), P), Nat.add(P, Nat.add(c2, P)), F.nat__add_assoc(P, c2, P))) : {Nat.add(c1, _) == R : Nat}
  %Equal.sym(Nat, Nat.add(P, c2), Nat.add(c2, P), F.nat__add_comm(P, c2)) : {Nat.add(c1, Nat.add(_, P)) == R : Nat}
  %Equal.sym(Nat, Nat.add(Nat.add(c2, P), P), Nat.add(c2, Nat.add(P, P)), F.nat__add_assoc(c2, P, P)) : {Nat.add(c1, _) == R : Nat}
  %Equal.sym(Nat, Nat.add(c1, Nat.add(c2, Nat.add(P, P))), Nat.add(Nat.add(c1, c2), Nat.add(P, P)), Equal.sym(Nat, Nat.add(Nat.add(c1, c2), Nat.add(P, P)), Nat.add(c1, Nat.add(c2, Nat.add(P, P))), F.nat__add_assoc(c1, c2, Nat.add(P, P)))) : {_ == R : Nat}
  %Equal.sym(Nat, Nat.add(P, P), Nat.double(P), two_pw(P)) : {Nat.add(Nat.add(c1, c2), _) == R : Nat}
  {==}

# c + 2^s <= 2^r for c <= 2^k, k <= s, s + 1 <= r
def ble(+x: Nat, +c: Nat, +k: Nat, +s: Nat, +r: Nat, +ex: {x == Nat.add(c, VB.pw(s)) : Nat}, +hc: {Nat.is_le(c, VB.pw(k)) == True{} : Bool},
    +hk: {Nat.is_le(k, s) == True{} : Bool}, +hr: {Nat.is_le(1n+s, r) == True{} : Bool})
    -> {Nat.is_le(x, VB.pw(r)) == True{} : Bool}:
  +P = VB.pw(s)
  +h1 = Order.add_right(c, P, P, F.nat__le_trans(c, VB.pw(k), P, hc, pw_mono(k, s, hk)))
  +h2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(c, P), z) == True{} : Bool}, Nat.add(P, P), Nat.double(P), two_pw(P), h1)
  %Equal.sym(Nat, x, Nat.add(c, P), ex) : {Nat.is_le(_, VB.pw(r)) == True{} : Bool}
  F.nat__le_trans(Nat.add(c, P), VB.pw(1n+s), VB.pw(r), h2, pw_mono(1n+s, r, hr))

def bleq(+x: Nat, +s: Nat, +ex: {x == Nat.add(0n, VB.pw(s)) : Nat}) -> {Nat.is_le(x, VB.pw(s)) == True{} : Bool}:
  %Equal.sym(Nat, x, Nat.add(0n, VB.pw(s)), ex) : {Nat.is_le(_, VB.pw(s)) == True{} : Bool}
  F.nat__le_refl(VB.pw(s))

# c + 2^s < 2^r for c + 1 <= 2^k, k <= s, s + 1 <= r
def blt(+x: Nat, +c: Nat, +k: Nat, +s: Nat, +r: Nat, +ex: {x == Nat.add(c, VB.pw(s)) : Nat}, +hc: {Nat.is_le(1n+c, VB.pw(k)) == True{} : Bool},
    +hk: {Nat.is_le(k, s) == True{} : Bool}, +hr: {Nat.is_le(1n+s, r) == True{} : Bool})
    -> {Nat.is_lt(x, VB.pw(r)) == True{} : Bool}:
  F.nat__succ_le_lt(x, VB.pw(r), ble(1n+x, 1n+c, k, s, r, Equal.cong(Nat, Nat, z => 1n+z, x, Nat.add(c, VB.pw(s)), ex), hc, hk, hr))

# The bound 2^r as a U32 2^r, as O.pow2n(r), as F.spec_common__pow2(r); the spec's fits test.
def bleu(+x: Nat, +r: Nat, +B: U32, +hx: {Nat.is_le(x, VB.pw(r)) == True{} : Bool}, +eB: {B == F.u32__pow2u(r) : U32}, +hr: {Nat.is_lt(r, 32n) == True{} : Bool})
    -> {Nat.is_le(x, U32.to_nat(B)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(B), VB.pw(r), u32pow(B, r, eB, hr)) : {Nat.is_le(x, _) == True{} : Bool}
  hx
def blep(+x: Nat, +r: Nat, +hx: {Nat.is_le(x, VB.pw(r)) == True{} : Bool}) -> {Nat.is_le(x, O.pow2n(r)) == True{} : Bool}:
  %Equal.sym(Nat, O.pow2n(r), VB.pw(r), Equal.sym(Nat, VB.pw(r), O.pow2n(r), VD.s_pow2_eq(r))) : {Nat.is_le(x, _) == True{} : Bool}
  hx
def bles(+x: Nat, +r: Nat, +hx: {Nat.is_le(x, VB.pw(r)) == True{} : Bool}) -> {Nat.is_le(x, F.spec_common__pow2(r)) == True{} : Bool}: hx
def bfit(+x: Nat, +r: Nat, +hx: {Nat.is_le(x, VB.pw(r)) == True{} : Bool}, +hr: {Nat.is_lt(r, 32n) == True{} : Bool})
    -> {N.fits(4n, x) == True{} : Bool}:
  VFT.fits4(r, x, hx, hr)

# 4 * 2^k = 2^r, r = 2 + k (e2e_cap states its bounds as A.quad(2^k)).
def quadpw(+k: Nat, +r: Nat, +er: {r == 2n+k : Nat}) -> {A.quad(F.spec_common__pow2(k)) == F.spec_common__pow2(r) : Nat}:
  %Equal.sym(Nat, r, 2n+k, er) : {A.quad(F.spec_common__pow2(k)) == F.spec_common__pow2(_) : Nat}
  {==}
