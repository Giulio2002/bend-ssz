import Base
import ../../src/primitives.bend as I
import ../../spec/layout.bend as Layout
import ../../spec/primitives.bend as SP
import ../../spec/nat_bytes.bend as N
import ../../types/schema.bend as S
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ../../proofs/primitive_invariants.bend as V
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vdig.bend as VG
import ./vmv.bend as VV
import ./vbitc.bend as VBC
import ./vnest.bend as VN
import ./vua.bend as UA
import ./vua_win.bend as UW
import ./vua_rd.bend as UR
import ./vbuf.bend as VB
import ./vmul.bend as VM

# GENERATED from vrc.bend.in by record_list_offset_windows (codegen). Do not edit.
# Containers of three variable fields at a byte window: the window's split, and the
# offset layout of three variable parts (no fixed part).

# A window of a + b bytes is its first a bytes, then the b after them.
def splitWX(+t: F.array__Tree<U32>, +y: Nat, +a: Nat, +b: Nat)
    -> {UW.WX(t, y, Nat.add(a, b)) == List.append(&2, U32, UW.WX(t, y, a), UW.WX(t, Nat.add(a, y), b)) : +List<U32>}:
  %Equal.sym(+List<U32>, VS.bt(Nat.add(a, b), VS.bdr(y, UA.BYT(t))), List.append(&2, U32, VS.bt(a, VS.bdr(y, UA.BYT(t))), VS.bt(b, VS.bdr(a, VS.bdr(y, UA.BYT(t))))),
      VBC.bt_split(a, b, VS.bdr(y, UA.BYT(t)))) :
    {_ == List.append(&2, U32, UW.WX(t, y, a), UW.WX(t, Nat.add(a, y), b)) : +List<U32>}
  %VN.bdr_add(y, a, UA.BYT(t)) :
    {List.append(&2, U32, UW.WX(t, y, a), VS.bt(b, _)) == List.append(&2, U32, UW.WX(t, y, a), UW.WX(t, Nat.add(a, y), b)) : +List<U32>}
  %F.nat__add_comm(y, a) :
    {List.append(&2, U32, UW.WX(t, y, a), VS.bt(b, VS.bdr(Nat.add(y, a), UA.BYT(t)))) == List.append(&2, U32, UW.WX(t, y, a), VS.bt(b, VS.bdr(_, UA.BYT(t)))) : +List<U32>}
  {==}

def PV3(+Y0: +List<U32>, +Y1: +List<U32>, +Y2: +List<U32>) -> +List<S.Part>: [S.Variable{Y0}, S.Variable{Y1}, S.Variable{Y2}]

def fp3v(+Y0: +List<U32>, +Y1: +List<U32>, +Y2: +List<U32>, +o0: U32, +o1: U32, +o2: U32,
    +e0: {U32.to_nat(o0) == 12n : Nat}, +e1: {U32.to_nat(o1) == Nat.add(12n, List.length(&2, U32, Y0)) : Nat},
    +e2: {U32.to_nat(o2) == Nat.add(Nat.add(12n, List.length(&2, U32, Y0)), List.length(&2, U32, Y1)) : Nat})
    -> {Layout.fixed_parts(PV3(Y0, Y1, Y2), 12n) == FX.limbs([o0, o1, o2]) : +List<U32>}:
  +X1 = Nat.add(12n, List.length(&2, U32, Y0))
  +X2 = Nat.add(Nat.add(12n, List.length(&2, U32, Y0)), List.length(&2, U32, Y1))
  %e0 : {List.append(&2, U32, N.digits(4n, _), List.append(&2, U32, N.digits(4n, X1), List.append(&2, U32, N.digits(4n, X2), []))) == FX.limbs([o0, o1, o2]) : +List<U32>}
  %e1 : {List.append(&2, U32, N.digits(4n, U32.to_nat(o0)), List.append(&2, U32, N.digits(4n, _), List.append(&2, U32, N.digits(4n, X2), []))) == FX.limbs([o0, o1, o2]) : +List<U32>}
  %e2 : {List.append(&2, U32, N.digits(4n, U32.to_nat(o0)), List.append(&2, U32, N.digits(4n, U32.to_nat(o1)), List.append(&2, U32, N.digits(4n, _), []))) == FX.limbs([o0, o1, o2]) : +List<U32>}
  %Equal.sym(+List<U32>, N.digits(4n, U32.to_nat(o0)), I.limb(o0), VG.digits_limb(o0)) :
    {List.append(&2, U32, _, List.append(&2, U32, N.digits(4n, U32.to_nat(o1)), List.append(&2, U32, N.digits(4n, U32.to_nat(o2)), []))) == FX.limbs([o0, o1, o2]) : +List<U32>}
  %Equal.sym(+List<U32>, N.digits(4n, U32.to_nat(o1)), I.limb(o1), VG.digits_limb(o1)) :
    {List.append(&2, U32, I.limb(o0), List.append(&2, U32, _, List.append(&2, U32, N.digits(4n, U32.to_nat(o2)), []))) == FX.limbs([o0, o1, o2]) : +List<U32>}
  %Equal.sym(+List<U32>, N.digits(4n, U32.to_nat(o2)), I.limb(o2), VG.digits_limb(o2)) :
    {List.append(&2, U32, I.limb(o0), List.append(&2, U32, I.limb(o1), List.append(&2, U32, _, []))) == FX.limbs([o0, o1, o2]) : +List<U32>}
  {==}

def pay3v(+Y0: +List<U32>, +Y1: +List<U32>, +Y2: +List<U32>)
    -> {Layout.payloads(PV3(Y0, Y1, Y2)) == List.append(&2, U32, Y0, List.append(&2, U32, Y1, Y2)) : +List<U32>}:
  %Equal.sym(+List<U32>, List.append(&2, U32, Y2, []), Y2, VS.app_nil(Y2)) :
    {List.append(&2, U32, Y0, List.append(&2, U32, Y1, _)) == List.append(&2, U32, Y0, List.append(&2, U32, Y1, Y2)) : +List<U32>}
  {==}

# The offset layout of three variable parts: the offset words, then the payloads.
def enc3v(+Y0: +List<U32>, +Y1: +List<U32>, +Y2: +List<U32>, +o0: U32, +o1: U32, +o2: U32,
    +v0: {SP.bytes_domain(Y0) == True{} : Bool}, +v1: {SP.bytes_domain(Y1) == True{} : Bool}, +v2: {SP.bytes_domain(Y2) == True{} : Bool},
    +e0: {U32.to_nat(o0) == 12n : Nat}, +e1: {U32.to_nat(o1) == Nat.add(12n, List.length(&2, U32, Y0)) : Nat},
    +e2: {U32.to_nat(o2) == Nat.add(Nat.add(12n, List.length(&2, U32, Y0)), List.length(&2, U32, Y1)) : Nat},
    +fit: {N.fits(4n, Nat.add(U32.to_nat(o2), List.length(&2, U32, Y2))) == True{} : Bool})
    -> {Layout.encoding(PV3(Y0, Y1, Y2)) == Some{List.append(&2, U32, FX.limbs([o0, o1, o2]), List.append(&2, U32, Y0, List.append(&2, U32, Y1, Y2)))} : Maybe<&2, +List<U32>>}:
  VV.enc_gen(PV3(Y0, Y1, Y2), 12n, FX.limbs([o0, o1, o2]), List.append(&2, U32, Y0, List.append(&2, U32, Y1, Y2)), {==},
    fp3v(Y0, Y1, Y2, o0, o1, o2, e0, e1, e2), pay3v(Y0, Y1, Y2),
    V.and_true(SP.bytes_domain(Y0), Layout.bytes_valid([S.Variable{Y1}, S.Variable{Y2}]), v0, V.and_true(SP.bytes_domain(Y1), Layout.bytes_valid([S.Variable{Y2}]), v1, V.and_true(SP.bytes_domain(Y2), True{}, v2, {==}))),
    VV.fit3(12n, o2, Y0, Y1, Y2, e2, fit))

# The four window bytes at k are the limbs of the word at x + k.
def wbytes(+d: Nat, +t: F.array__Tree<U32>, +x: Nat, +k: Nat, +L: Nat, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(Nat.add(k, x), 4n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {VS.bt(4n, VS.bdr(k, UW.WX(t, x, Nat.add(k, 4n+L)))) == FX.limbs([UR.RWN(t, Nat.add(k, x))]) : +List<U32>}:
  %Equal.sym(+List<U32>, VS.bdr(k, UW.WX(t, x, Nat.add(k, 4n+L))), UW.WX(t, Nat.add(k, x), 4n+L), UW.tailWX(t, x, k, 4n+L)) :
    {VS.bt(4n, _) == FX.limbs([UR.RWN(t, Nat.add(k, x))]) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(4n, VS.bt(Nat.add(4n, L), VS.bdr(Nat.add(k, x), UA.BYT(t)))), VS.bt(4n, VS.bdr(Nat.add(k, x), UA.BYT(t))), VS.bt_bt(4n, L, VS.bdr(Nat.add(k, x), UA.BYT(t)))) :
    {_ == FX.limbs([UR.RWN(t, Nat.add(k, x))]) : +List<U32>}
  Equal.sym(+List<U32>, FX.limbs([UR.RWN(t, Nat.add(k, x))]), VS.bt(4n, VS.bdr(Nat.add(k, x), UA.BYT(t))), UR.rwn_bytes(d, t, Nat.add(k, x), pf, h))

# a <= b and x + b <= P: (a + x) + (b - a) <= P.
def winb(+a: U32, +b: U32, +x: Nat, +P: Nat, +hab: {U32.is_le(a, b) == True{} : Bool}, +hb: {Nat.is_le(Nat.add(x, U32.to_nat(b)), P) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(U32.to_nat(a), x), U32.to_nat(U32.sub(b, a))), P) == True{} : Bool}:
  +A0 = U32.to_nat(a)
  +S0 = U32.to_nat(U32.sub(b, a))
  +e = Equal.trans(Nat, Nat.add(Nat.add(A0, x), S0), Nat.add(A0, Nat.add(x, S0)), Nat.add(x, U32.to_nat(b)), F.nat__add_assoc(A0, x, S0),
    Equal.trans(Nat, Nat.add(A0, Nat.add(x, S0)), Nat.add(x, Nat.add(A0, S0)), Nat.add(x, U32.to_nat(b)), F.lru_nat_algebra__add_swap(A0, x, S0),
      Equal.cong(Nat, Nat, z => Nat.add(x, z), Nat.add(A0, S0), U32.to_nat(b), VM.sub_eq(b, a, hab))))
  F.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, Nat.add(x, U32.to_nat(b)), Nat.add(Nat.add(A0, x), S0), Equal.sym(Nat, Nat.add(Nat.add(A0, x), S0), Nat.add(x, U32.to_nat(b)), e), hb)

# b = a + s: b + x = s + (a + x).
def pnext(+a: Nat, +b: Nat, +s: Nat, +x: Nat, +e: {b == Nat.add(a, s) : Nat}) -> {Nat.add(b, x) == Nat.add(s, Nat.add(a, x)) : Nat}:
  %Equal.sym(Nat, b, Nat.add(a, s), e) : {Nat.add(_, x) == Nat.add(s, Nat.add(a, x)) : Nat}
  Equal.trans(Nat, Nat.add(Nat.add(a, s), x), Nat.add(a, Nat.add(s, x)), Nat.add(s, Nat.add(a, x)), F.nat__add_assoc(a, s, x), F.lru_nat_algebra__add_swap(a, s, x))

def varpay(ps: +List<S.Part>) -> +List<U32>:
  match ps:
    case Con{S.Variable{xs}, Nil{}}: xs
    case _: []

def var_inj(+a: +List<U32>, +b: +List<U32>, +e: {Some{[S.Variable{a}]} == Some{[S.Variable{b}]} : Maybe<&2, +List<S.Part>>}) -> {a == b : +List<U32>}:
  Equal.cong(+List<S.Part>, +List<U32>, z => varpay(z), [S.Variable{a}], [S.Variable{b}], F.logic__some_inj(+List<S.Part>, [S.Variable{a}], [S.Variable{b}], e))

# The layout of three variable parts, and its length.
def OUTV(+Y0: +List<U32>, +Y1: +List<U32>, +Y2: +List<U32>) -> +List<U32>:
  List.append(&2, U32, Layout.fixed_parts(PV3(Y0, Y1, Y2), Layout.fixed_size(PV3(Y0, Y1, Y2))), Layout.payloads(PV3(Y0, Y1, Y2)))

def lenOUT(+Y0: +List<U32>, +Y1: +List<U32>, +Y2: +List<U32>)
    -> {List.length(&2, U32, OUTV(Y0, Y1, Y2)) == Nat.add(12n, Nat.add(List.length(&2, U32, Y0), Nat.add(List.length(&2, U32, Y1), List.length(&2, U32, Y2)))) : Nat}:
  +RHS = Nat.add(12n, Nat.add(List.length(&2, U32, Y0), Nat.add(List.length(&2, U32, Y1), List.length(&2, U32, Y2))))
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, Y0, List.append(&2, U32, Y1, List.append(&2, U32, Y2, [])))),
      Nat.add(List.length(&2, U32, Y0), List.length(&2, U32, List.append(&2, U32, Y1, List.append(&2, U32, Y2, [])))), VS.len_app(Y0, List.append(&2, U32, Y1, List.append(&2, U32, Y2, [])))) :
    {12n+_ == RHS : Nat}
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, Y1, List.append(&2, U32, Y2, []))), Nat.add(List.length(&2, U32, Y1), List.length(&2, U32, List.append(&2, U32, Y2, []))), VS.len_app(Y1, List.append(&2, U32, Y2, []))) :
    {12n+Nat.add(List.length(&2, U32, Y0), _) == RHS : Nat}
  %Equal.sym(+List<U32>, List.append(&2, U32, Y2, []), Y2, VS.app_nil(Y2)) :
    {12n+Nat.add(List.length(&2, U32, Y0), Nat.add(List.length(&2, U32, Y1), List.length(&2, U32, _))) == RHS : Nat}
  {==}
