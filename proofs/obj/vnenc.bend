import Base
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./vdepth.bend as VD
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vfix.bend as VF
import ../../spec/primitives.bend as SP
import ../../spec/layout.bend as Layout
import ../../spec/nat_bytes.bend as N
import ../../types/schema.bend as S
import ../../src/primitives.bend as I
import ./vdig.bend as VG

# Small Nat facts for the encoders of nested variable-size containers
# (codegen/var_nest_enc.py).

law rngq:
  for +x: Nat
  {VD.s_rng(2n, 3n+A.quad(x)) == x : Nat}
def rngq(x):
  match x:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, VD.s_rng(2n, 3n+A.quad(p)), p, rngq(p)) : {1n+_ == 1n+p : Nat}
      {==}

def sw(+a: Nat, +b: Nat, +c: Nat) -> {Nat.add(a, Nat.add(b, c)) == Nat.add(b, Nat.add(a, c)) : Nat}:
  Equal.trans(Nat, Nat.add(a, Nat.add(b, c)), Nat.add(Nat.add(a, b), c), Nat.add(b, Nat.add(a, c)),
    Equal.sym(Nat, Nat.add(Nat.add(a, b), c), Nat.add(a, Nat.add(b, c)), F.nat__add_assoc(a, b, c)),
    Equal.trans(Nat, Nat.add(Nat.add(a, b), c), Nat.add(Nat.add(b, a), c), Nat.add(b, Nat.add(a, c)),
      Equal.cong(Nat, Nat, z => Nat.add(z, c), Nat.add(a, b), Nat.add(b, a), F.nat__add_comm(a, b)),
      F.nat__add_assoc(b, a, c)))

def le_add2(+a: Nat, +b: Nat, +c: Nat, +d: Nat, +hab: {Nat.is_le(a, b) == True{} : Bool}, +hcd: {Nat.is_le(c, d) == True{} : Bool})
    -> {Nat.is_le(Nat.add(a, c), Nat.add(b, d)) == True{} : Bool}:
  F.nat__le_trans(Nat.add(a, c), Nat.add(b, c), Nat.add(b, d), Order.add_right(a, b, c, hab), Order.add_left(b, c, d, hcd))

# x + z <= z + (x + y)
def le_zx(+z: Nat, +x: Nat, +y: Nat) -> {Nat.is_le(Nat.add(x, z), Nat.add(z, Nat.add(x, y))) == True{} : Bool}:
  %F.nat__add_comm(z, x) : {Nat.is_le(_, Nat.add(z, Nat.add(x, y))) == True{} : Bool}
  Order.add_left(z, x, Nat.add(x, y), Order.below_sum(x, y))

# y + (z + x) = z + (x + y)
def e_yzx(+z: Nat, +x: Nat, +y: Nat) -> {Nat.add(y, Nat.add(z, x)) == Nat.add(z, Nat.add(x, y)) : Nat}:
  Equal.trans(Nat, Nat.add(y, Nat.add(z, x)), Nat.add(z, Nat.add(y, x)), Nat.add(z, Nat.add(x, y)), sw(y, z, x),
    Equal.cong(Nat, Nat, q => Nat.add(z, q), Nat.add(y, x), Nat.add(x, y), F.nat__add_comm(y, x)))

# A window split at a + p (instead of p + a).
def win_split2(+a: Nat, +b: Nat, +p: Nat, +X: List<&2, U32>)
    -> {VF.WIN(Nat.add(a, b), p, X) == VF.app(VF.WIN(a, p, X), VF.WIN(b, Nat.add(a, p), X)) : List<&2, U32>}:
  %F.nat__add_comm(p, a) : {VF.WIN(Nat.add(a, b), p, X) == VF.app(VF.WIN(a, p, X), VF.WIN(b, _, X)) : List<&2, U32>}
  VF.win_split(a, b, p, X)

# Windows before or after the copy of n words (VB.mone) to position j.
def pm_lo(+n: Nat, +j: Nat, +dd: Nat, +D: F.array__Tree<U32>, +S: F.array__Tree<U32>, +m: Nat, +p: Nat,
    +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}, +hj: {Nat.is_le(Nat.add(n, j), VB.pw(dd)) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(n, j), p) == True{} : Bool})
    -> {VF.WIN(m, p, F.array__slots(U32, VB.mone(n, 0n, j, dd, D, S))) == VF.WIN(m, p, F.array__slots(U32, D)) : List<&2, U32>}:
  %Equal.sym(List<&2, U32>, F.array__slots(U32, VB.mone(n, 0n, j, dd, D, S)), VB.lm(n, 0n, j, F.array__slots(U32, D), F.array__slots(U32, S)), VB.slots_mone(n, 0n, j, dd, D, S, pf, hj)) :
    {VF.WIN(m, p, _) == VF.WIN(m, p, F.array__slots(U32, D)) : List<&2, U32>}
  VF.lm_lo(n, 0n, j, m, p, F.array__slots(U32, D), F.array__slots(U32, S), h)

def pm_hi(+n: Nat, +j: Nat, +dd: Nat, +D: F.array__Tree<U32>, +S: F.array__Tree<U32>, +m: Nat, +p: Nat,
    +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}, +hj: {Nat.is_le(Nat.add(n, j), VB.pw(dd)) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(m, p), j) == True{} : Bool})
    -> {VF.WIN(m, p, F.array__slots(U32, VB.mone(n, 0n, j, dd, D, S))) == VF.WIN(m, p, F.array__slots(U32, D)) : List<&2, U32>}:
  %Equal.sym(List<&2, U32>, F.array__slots(U32, VB.mone(n, 0n, j, dd, D, S)), VB.lm(n, 0n, j, F.array__slots(U32, D), F.array__slots(U32, S)), VB.slots_mone(n, 0n, j, dd, D, S, pf, hj)) :
    {VF.WIN(m, p, _) == VF.WIN(m, p, F.array__slots(U32, D)) : List<&2, U32>}
  VF.lm_hi(n, 0n, j, m, p, F.array__slots(U32, D), F.array__slots(U32, S), h)

# The copy's own window holds the source's first n words.
def pm_own(+n: Nat, +j: Nat, +dd: Nat, +D: F.array__Tree<U32>, +dw: Nat, +S: F.array__Tree<U32>,
    +pf: {F.array__perfect(U32, dd, D) == True{} : Bool}, +pfS: {F.array__perfect(U32, dw, S) == True{} : Bool},
    +hj: {Nat.is_le(Nat.add(n, j), VB.pw(dd)) == True{} : Bool}, +hs: {Nat.is_le(Nat.add(n, 0n), VB.pw(dw)) == True{} : Bool})
    -> {VF.WIN(n, j, F.array__slots(U32, VB.mone(n, 0n, j, dd, D, S))) == VS.wtake(n, F.array__slots(U32, S)) : List<&2, U32>}:
  %Equal.sym(List<&2, U32>, F.array__slots(U32, VB.mone(n, 0n, j, dd, D, S)), VB.lm(n, 0n, j, F.array__slots(U32, D), F.array__slots(U32, S)), VB.slots_mone(n, 0n, j, dd, D, S, pf, hj)) :
    {VF.WIN(n, j, _) == VS.wtake(n, F.array__slots(U32, S)) : List<&2, U32>}
  VB.lm_win(n, 0n, j, F.array__slots(U32, D), F.array__slots(U32, S),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(n, j), z) == True{} : Bool}, VB.pw(dd), VB.len(F.array__slots(U32, D)), Equal.sym(Nat, VB.len(F.array__slots(U32, D)), VB.pw(dd), F.array__slots_length(U32, dd, D, pf)), hj),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(n, 0n), z) == True{} : Bool}, VB.pw(dw), VB.len(F.array__slots(U32, S)), Equal.sym(Nat, VB.len(F.array__slots(U32, S)), VB.pw(dw), F.array__slots_length(U32, dw, S, pfS)), hs))

law dbl_add:
  for +k: Nat
  {Nat.double(k) == Nat.add(k, k) : Nat}
def dbl_add(k):
  match k:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, Nat.add(p, 1n+p), 1n+Nat.add(p, p), F.nat__add_succ(p, p)) : {2n+Nat.double(p) == 1n+_ : Nat}
      %dbl_add(p) : {2n+Nat.double(p) == 2n+_ : Nat}
      {==}

# a < K and b < K: 2 + (a + b) <= 2 K.
def le_q(+a: Nat, +b: Nat, +K: Nat, +ha: {Nat.is_le(1n+a, K) == True{} : Bool}, +hb: {Nat.is_le(1n+b, K) == True{} : Bool})
    -> {Nat.is_le(Nat.add(2n, Nat.add(a, b)), Nat.double(K)) == True{} : Bool}:
  %Equal.sym(Nat, Nat.double(K), Nat.add(K, K), dbl_add(K)) : {Nat.is_le(Nat.add(2n, Nat.add(a, b)), _) == True{} : Bool}
  %F.nat__add_succ(a, b) : {Nat.is_le(1n+_, Nat.add(K, K)) == True{} : Bool}
  le_add2(1n+a, K, 1n+b, K, ha, hb)

# The offset layout of two variable parts: offsets 8 and 8 + |Y1| (the digits D1), then the payloads.
def enc2(+Y1: +List<U32>, +Y2: +List<U32>, +D1: +List<U32>,
    +v1: {SP.bytes_domain(Y1) == True{} : Bool}, +v2: {SP.bytes_domain(Y2) == True{} : Bool},
    +fit: {N.fits(4n, Nat.add(8n, List.length(&2, U32, List.append(&2, U32, Y1, Y2)))) == True{} : Bool},
    +ed: {N.digits(4n, Nat.add(8n, List.length(&2, U32, Y1))) == D1 : +List<U32>})
    -> {Layout.encoding([S.Variable{Y1}, S.Variable{Y2}]) == Some{List.append(&2, U32, List.append(&2, U32, N.digits(4n, 8n), D1), List.append(&2, U32, Y1, Y2))} : Maybe<&2, +List<U32>>}:
  %Equal.sym(+List<U32>, List.append(&2, U32, Y2, []), Y2, VS.app_nil(Y2)) :
    {SP.optional(Bool.and(Layout.bytes_valid([S.Variable{Y1}, S.Variable{Y2}]), N.fits(4n, Nat.add(8n, List.length(&2, U32, List.append(&2, U32, Y1, _))))),
       List.append(&2, U32, List.append(&2, U32, N.digits(4n, 8n), List.append(&2, U32, N.digits(4n, Nat.add(8n, List.length(&2, U32, Y1))), [])), List.append(&2, U32, Y1, _))) == Some{List.append(&2, U32, List.append(&2, U32, N.digits(4n, 8n), D1), List.append(&2, U32, Y1, Y2))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, Layout.bytes_valid([S.Variable{Y1}, S.Variable{Y2}]), True{}, F.logic__and_intro(SP.bytes_domain(Y1), Layout.bytes_valid([S.Variable{Y2}]), v1, F.logic__and_intro(SP.bytes_domain(Y2), True{}, v2, {==}))) :
    {SP.optional(Bool.and(_, N.fits(4n, Nat.add(8n, List.length(&2, U32, List.append(&2, U32, Y1, Y2))))),
       List.append(&2, U32, List.append(&2, U32, N.digits(4n, 8n), List.append(&2, U32, N.digits(4n, Nat.add(8n, List.length(&2, U32, Y1))), [])), List.append(&2, U32, Y1, Y2))) == Some{List.append(&2, U32, List.append(&2, U32, N.digits(4n, 8n), D1), List.append(&2, U32, Y1, Y2))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, N.fits(4n, Nat.add(8n, List.length(&2, U32, List.append(&2, U32, Y1, Y2)))), True{}, fit) :
    {SP.optional(Bool.and(True{}, _),
       List.append(&2, U32, List.append(&2, U32, N.digits(4n, 8n), List.append(&2, U32, N.digits(4n, Nat.add(8n, List.length(&2, U32, Y1))), [])), List.append(&2, U32, Y1, Y2))) == Some{List.append(&2, U32, List.append(&2, U32, N.digits(4n, 8n), D1), List.append(&2, U32, Y1, Y2))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, N.digits(4n, Nat.add(8n, List.length(&2, U32, Y1))), D1, ed) :
    {Some{List.append(&2, U32, List.append(&2, U32, N.digits(4n, 8n), List.append(&2, U32, _, [])), List.append(&2, U32, Y1, Y2))} == Some{List.append(&2, U32, List.append(&2, U32, N.digits(4n, 8n), D1), List.append(&2, U32, Y1, Y2))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, List.append(&2, U32, D1, []), D1, VS.app_nil(D1)) :
    {Some{List.append(&2, U32, List.append(&2, U32, N.digits(4n, 8n), _), List.append(&2, U32, Y1, Y2))} == Some{List.append(&2, U32, List.append(&2, U32, N.digits(4n, 8n), D1), List.append(&2, U32, Y1, Y2))} : Maybe<&2, +List<U32>>}
  {==}

# 4 + a <= K and 4 + b <= K: 8 + (a + b) <= 2 K.
def le_q4(+a: Nat, +b: Nat, +K: Nat, +ha: {Nat.is_le(4n+a, K) == True{} : Bool}, +hb: {Nat.is_le(4n+b, K) == True{} : Bool})
    -> {Nat.is_le(Nat.add(8n, Nat.add(a, b)), Nat.double(K)) == True{} : Bool}:
  %Equal.sym(Nat, Nat.double(K), Nat.add(K, K), dbl_add(K)) : {Nat.is_le(Nat.add(8n, Nat.add(a, b)), _) == True{} : Bool}
  %sw(a, 4n, b) : {Nat.is_le(4n+_, Nat.add(K, K)) == True{} : Bool}
  le_add2(4n+a, K, 4n+b, K, ha, hb)

# The digits of the second offset are the limbs of the word x holding it.
def ed_g(+x: U32, +Y: +List<U32>, +e: {U32.to_nat(x) == Nat.add(8n, List.length(&2, U32, Y)) : Nat})
    -> {N.digits(4n, Nat.add(8n, List.length(&2, U32, Y))) == I.limb(x) : +List<U32>}:
  %e : {N.digits(4n, _) == I.limb(x) : +List<U32>}
  VG.digits_limb(x)
