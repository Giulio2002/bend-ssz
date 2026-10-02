import Base
import ../../src/obj.bend as O
import ../../spec/nat_bytes.bend as N
import ../compact/found_generated.bend as F
import ../../proofs/nat_order.bend as Order
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vdepth.bend as VD
import ./vfits.bend as VFT

# Closed bounds of a list window whose limit is a power of two (List[uint64, 2^p]),
# symbolically: 8 * 2^p = 2^(p + 3) by induction, never as unary numbers. The
# evaluated forms of these facts (31 + 8 * 131072 <= 2^21 and its relatives)
# counted a million unary steps each (var_win's hyL, hWZ, specwD: 5 s per module).
# Every size is threaded as a parameter with an equation, so an instance at
# literal sizes compares small literals only.

law x8_dbl:
  for +y: Nat
  {VS.x8(Nat.double(y)) == Nat.double(VS.x8(y)) : Nat}
def x8_dbl(y):
  match y:
    case 0n: {==}
    case 1n+c:
      %Equal.sym(Nat, VS.x8(Nat.double(c)), Nat.double(VS.x8(c)), x8_dbl(c)) :
        {16n+_ == Nat.double(8n+VS.x8(c)) : Nat}
      {==}

# 8 * 2^p = 2^r when r = p + 3.
law x8p:
  for +p: Nat
  for +r: Nat
  for +er: {r == 3n+p : Nat}
  {VS.x8(F.spec_common__pow2(p)) == F.spec_common__pow2(r) : Nat}
def x8p(p, r, er):
  match p:
    case 0n:
      %Equal.sym(Nat, r, 3n+0n, er) : {VS.x8(F.spec_common__pow2(0n)) == F.spec_common__pow2(_) : Nat}
      {==}
    case 1n+ +k:
      %Equal.sym(Nat, r, 3n+(1n+k), er) : {VS.x8(F.spec_common__pow2(1n+k)) == F.spec_common__pow2(_) : Nat}
      %Equal.sym(Nat, VS.x8(Nat.double(F.spec_common__pow2(k))), Nat.double(VS.x8(F.spec_common__pow2(k))), x8_dbl(F.spec_common__pow2(k))) :
        {_ == F.spec_common__pow2(4n+k) : Nat}
      %Equal.sym(Nat, VS.x8(F.spec_common__pow2(k)), F.spec_common__pow2(3n+k), x8p(k, 3n+k, {==})) :
        {Nat.double(_) == F.spec_common__pow2(4n+k) : Nat}
      {==}

# 8 * N for N = 2^p, as 2^(1 + j) (j = p + 2).
def x8n(+n: U32, +p: Nat, +j: Nat, +en: {n == F.u32__pow2u(p) : U32}, +hp: {Nat.is_lt(p, 32n) == True{} : Bool},
    +ej: {1n+j == 3n+p : Nat}) -> {VS.x8(U32.to_nat(n)) == F.spec_common__pow2(1n+j) : Nat}:
  +e1 = Equal.trans(Nat, U32.to_nat(n), U32.to_nat(F.u32__pow2u(p)), F.spec_common__pow2(p),
    Equal.cong(U32, Nat, z => U32.to_nat(z), n, F.u32__pow2u(p), en), F.u32__pow2u_value(p, hp))
  %Equal.sym(Nat, U32.to_nat(n), F.spec_common__pow2(p), e1) : {VS.x8(_) == F.spec_common__pow2(1n+j) : Nat}
  x8p(p, 1n+j, ej)

# 31 + 8 N < 2^q for N = 2^p, q = p + 4 (p >= 2).
def ylt(+n: U32, +p: Nat, +j: Nat, +q: Nat, +en: {n == F.u32__pow2u(p) : U32}, +hp: {Nat.is_lt(p, 32n) == True{} : Bool},
    +ej: {1n+j == 3n+p : Nat}, +eq: {q == 2n+j : Nat}, +h4: {Nat.is_le(4n, j) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(31n, VS.x8(U32.to_nat(n))), VB.pw(q)) == True{} : Bool}:
  +P = F.spec_common__pow2(1n+j)
  %Equal.sym(Nat, VS.x8(U32.to_nat(n)), P, x8n(n, p, j, en, hp, ej)) : {Nat.is_lt(Nat.add(31n, _), VB.pw(q)) == True{} : Bool}
  %Equal.sym(Nat, q, 2n+j, eq) : {Nat.is_lt(Nat.add(31n, P), VB.pw(_)) == True{} : Bool}
  +h32 = F.nat__pow2_mono(5n, 1n+j, h4)
  +h31 = F.nat__succ_le_lt(31n, P, h32)
  +hlt = F.nat__lt_add_left(31n, P, P, h31)
  %Equal.sym(Nat, Nat.add(31n, P), Nat.add(P, 31n), F.nat__add_comm(31n, P)) : {Nat.is_lt(_, Nat.double(P)) == True{} : Bool}
  %Equal.sym(Nat, Nat.double(P), Nat.add(P, P), Order.double_add(P)) : {Nat.is_lt(Nat.add(P, 31n), _) == True{} : Bool}
  hlt

def yle(+n: U32, +p: Nat, +j: Nat, +q: Nat, +en: {n == F.u32__pow2u(p) : U32}, +hp: {Nat.is_lt(p, 32n) == True{} : Bool},
    +ej: {1n+j == 3n+p : Nat}, +eq: {q == 2n+j : Nat}, +h4: {Nat.is_le(4n, j) == True{} : Bool})
    -> {Nat.is_le(Nat.add(31n, VS.x8(U32.to_nat(n))), VB.pw(q)) == True{} : Bool}:
  F.nat__lt_le(Nat.add(31n, VS.x8(U32.to_nat(n))), VB.pw(q), ylt(n, p, j, q, en, hp, ej, eq, h4))

# ((31 + 8 N) >> 2) + 8 <= 2^k for k = q - 1.
def wzb(+n: U32, +p: Nat, +j: Nat, +q: Nat, +k: Nat, +en: {n == F.u32__pow2u(p) : U32}, +hp: {Nat.is_lt(p, 32n) == True{} : Bool},
    +ej: {1n+j == 3n+p : Nat}, +eq: {q == 2n+j : Nat}, +ek: {k == 1n+j : Nat}, +h4: {Nat.is_le(4n, j) == True{} : Bool})
    -> {Nat.is_le(Nat.add(VD.s_rng(2n, Nat.add(31n, VS.x8(U32.to_nat(n)))), 8n), O.pow2n(k)) == True{} : Bool}:
  +Y = Nat.add(31n, VS.x8(U32.to_nat(n)))
  +hy = ylt(n, p, j, q, en, hp, ej, eq, h4)
  +hy2 = F.logic__subst(Nat, z => {Nat.is_lt(Y, z) == True{} : Bool}, VB.pw(q), O.pow2n(q), VD.s_pow2_eq(q), hy)
  +hy3 = F.logic__subst(Nat, z => {Nat.is_lt(Y, O.pow2n(z)) == True{} : Bool}, q, 2n+j, eq, hy2)
  +hs = VD.rlt(2n, j, Y, hy3)
  +Q = O.pow2n(j)
  +s = VD.s_rng(2n, Y)
  +h8s = F.nat__pow2_mono(3n, j, F.nat__le_trans(3n, 4n, j, {==}, h4))
  +h8 = F.logic__subst(Nat, z => {Nat.is_le(8n, z) == True{} : Bool}, F.spec_common__pow2(j), Q, VD.s_pow2_eq(j), h8s)
  +l1 = Order.add_right(s, Q, 8n, F.nat__lt_le(s, Q, hs))
  +l2 = Order.add_left(Q, 8n, Q, h8)
  +l3 = F.nat__le_trans(Nat.add(s, 8n), Nat.add(Q, 8n), Nat.add(Q, Q), l1, l2)
  %Equal.sym(Nat, k, 1n+j, ek) : {Nat.is_le(Nat.add(s, 8n), O.pow2n(_)) == True{} : Bool}
  F.logic__subst(Nat, z => {Nat.is_le(Nat.add(s, 8n), z) == True{} : Bool}, Nat.add(Q, Q), Nat.double(Q), Equal.sym(Nat, Nat.double(Q), Nat.add(Q, Q), Order.double_add(Q)), l3)

# The encoding width of 8 N bytes: N.fits(4, 8 N) (8 N = 2^r, r < 32).
def fitb(+n: U32, +p: Nat, +j: Nat, +en: {n == F.u32__pow2u(p) : U32}, +hp: {Nat.is_lt(p, 32n) == True{} : Bool},
    +ej: {1n+j == 3n+p : Nat}, +hr: {Nat.is_lt(1n+j, 32n) == True{} : Bool})
    -> {N.fits(4n, VS.x8(U32.to_nat(n))) == True{} : Bool}:
  +P = F.spec_common__pow2(1n+j)
  VFT.fits4(1n+j, VS.x8(U32.to_nat(n)),
    F.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, P, VS.x8(U32.to_nat(n)), Equal.sym(Nat, VS.x8(U32.to_nat(n)), P, x8n(n, p, j, en, hp, ej)), F.nat__le_refl(P)),
    hr)
