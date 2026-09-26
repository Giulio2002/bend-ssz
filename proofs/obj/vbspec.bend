import Base
import ../../src/primitives.bend as I
import ../../spec/primitives.bend as SP
import ../../spec/layout.bend as Layout
import ../../spec/codec.bend as Codec
import ../../spec/nat_bytes.bend as N
import ../../types/schema.bend as S
import ../../proofs/primitive_invariants.bend as V
import ../../proofs/nat_order.bend as Order
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vdepth.bend as VD
import ./vcopy.bend as VC
import ./vbytes.bend as VY
import ./vfix.bend as VF
import ./vrej.bend as VR

# Byte lists at any length, specification side (codegen/var_bytes.py): the
# parts of a ByteList value, the offset layout of fixed parts of words around
# one variable part of arbitrary bytes, and the bytes of the masked copy.

law bd_bt:
  for +m: Nat
  for +X: +List<U32>
  for +h: {SP.bytes_domain(X) == True{} : Bool}
  {SP.bytes_domain(VS.bt(m, X)) == True{} : Bool}
def bd_bt(m, X, h):
  match m X:
    case 0n +X0: {==}
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+x, +t}:
      V.and_true(U32.is_lt(x, 256), SP.bytes_domain(VS.bt(p, t)), V.and_left(U32.is_lt(x, 256), SP.bytes_domain(t), h),
        bd_bt(p, t, V.and_right(U32.is_lt(x, 256), SP.bytes_domain(t), h)))

# The first m bytes of the limbs of any words are bytes.
def bd_btl(+m: Nat, +W: List<&2, U32>) -> {SP.bytes_domain(VS.bt(m, FX.limbs(W))) == True{} : Bool}:
  bd_bt(m, FX.limbs(W), FX.domain_limbs(W))

# A ByteList value within its limit is one variable part.
law bl_parts:
  for +cap: Nat
  for +xs: +List<U32>
  for +hdom: {SP.bytes_domain(xs) == True{} : Bool}
  for +hlen: {Nat.is_le(List.length(&2, U32, xs), cap) == True{} : Bool}
  for +hfit: {N.fits(4n, List.length(&2, U32, xs)) == True{} : Bool}
  {Codec.parts(S.BytesValue{xs}, S.ByteList{cap}) == Some{[S.Variable{xs}]} : Maybe<&2, +List<S.Part>>}
def bl_parts(cap, xs, hdom, hlen, hfit):
  %Equal.sym(Bool, SP.bytes_domain(xs), True{}, hdom) :
    {Codec.one(SP.optional(Bool.and(Bool.and(_, Nat.is_le(List.length(&2, U32, xs), cap)), N.fits(4n, List.length(&2, U32, xs))), xs), None{}) == Some{[S.Variable{xs}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Bool, Nat.is_le(List.length(&2, U32, xs), cap), True{}, hlen) :
    {Codec.one(SP.optional(Bool.and(Bool.and(True{}, _), N.fits(4n, List.length(&2, U32, xs))), xs), None{}) == Some{[S.Variable{xs}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Bool, N.fits(4n, List.length(&2, U32, xs)), True{}, hfit) :
    {Codec.one(SP.optional(Bool.and(Bool.and(True{}, True{}), _), xs), None{}) == Some{[S.Variable{xs}]} : Maybe<&2, +List<S.Part>>}
  {==}

# ---- fixed parts of words around one variable part of any bytes ------------------------------

law fpv_validb:
  for +pre: +List<+List<U32>>
  for +Y: +List<U32>
  for +post: +List<+List<U32>>
  for +hY: {SP.bytes_domain(Y) == True{} : Bool}
  {Layout.bytes_valid(VS.fpv(pre, Y, post)) == True{} : Bool}
def fpv_validb(pre, Y, post, hY):
  match pre:
    case Nil{}: V.and_true(SP.bytes_domain(Y), Layout.bytes_valid(FX.fparts(post)), hY, FX.valid_fparts(post))
    case Con{+ws, +t}: V.and_true(SP.bytes_domain(FX.limbs(ws)), Layout.bytes_valid(VS.fpv(t, Y, post)), FX.domain_limbs(ws), fpv_validb(t, Y, post, hY))

def encb_go(+pre: +List<+List<U32>>, +Y: +List<U32>, +post: +List<+List<U32>>, +hY: {SP.bytes_domain(Y) == True{} : Bool}, +b: Bool,
    +eb: {N.fits(4n, Nat.add(Layout.fixed_size(VS.fpv(pre, Y, post)), List.length(&2, U32, Layout.payloads(VS.fpv(pre, Y, post))))) == b : Bool},
    +fit: {b == True{} : Bool})
    -> {Layout.encoding(VS.fpv(pre, Y, post)) == Some{List.append(&2, U32, Layout.fixed_parts(VS.fpv(pre, Y, post), Layout.fixed_size(VS.fpv(pre, Y, post))), Layout.payloads(VS.fpv(pre, Y, post)))} : Maybe<&2, +List<U32>>}:
  %Equal.sym(Bool, Layout.bytes_valid(VS.fpv(pre, Y, post)), True{}, fpv_validb(pre, Y, post, hY)) :
    {SP.optional(Bool.and(_, N.fits(4n, Nat.add(Layout.fixed_size(VS.fpv(pre, Y, post)), List.length(&2, U32, Layout.payloads(VS.fpv(pre, Y, post)))))), List.append(&2, U32, Layout.fixed_parts(VS.fpv(pre, Y, post), Layout.fixed_size(VS.fpv(pre, Y, post))), Layout.payloads(VS.fpv(pre, Y, post)))) == Some{List.append(&2, U32, Layout.fixed_parts(VS.fpv(pre, Y, post), Layout.fixed_size(VS.fpv(pre, Y, post))), Layout.payloads(VS.fpv(pre, Y, post)))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, N.fits(4n, Nat.add(Layout.fixed_size(VS.fpv(pre, Y, post)), List.length(&2, U32, Layout.payloads(VS.fpv(pre, Y, post))))), True{}, Equal.trans(Bool, N.fits(4n, Nat.add(Layout.fixed_size(VS.fpv(pre, Y, post)), List.length(&2, U32, Layout.payloads(VS.fpv(pre, Y, post))))), b, True{}, eb, fit)) :
    {SP.optional(Bool.and(True{}, _), List.append(&2, U32, Layout.fixed_parts(VS.fpv(pre, Y, post), Layout.fixed_size(VS.fpv(pre, Y, post))), Layout.payloads(VS.fpv(pre, Y, post)))) == Some{List.append(&2, U32, Layout.fixed_parts(VS.fpv(pre, Y, post), Layout.fixed_size(VS.fpv(pre, Y, post))), Layout.payloads(VS.fpv(pre, Y, post)))} : Maybe<&2, +List<U32>>}
  {==}

def encb_eb(+pre: +List<+List<U32>>, +Y: +List<U32>, +post: +List<+List<U32>>,
    +fit: {N.fits(4n, Nat.add(VS.FSZ(pre, post), List.length(&2, U32, Y))) == True{} : Bool})
    -> {N.fits(4n, Nat.add(Layout.fixed_size(VS.fpv(pre, Y, post)), List.length(&2, U32, Layout.payloads(VS.fpv(pre, Y, post))))) == True{} : Bool}:
  %Equal.sym(Nat, Layout.fixed_size(VS.fpv(pre, Y, post)), VS.FSZ(pre, post), VS.fpv_size(pre, Y, post)) :
    {N.fits(4n, Nat.add(_, List.length(&2, U32, Layout.payloads(VS.fpv(pre, Y, post))))) == True{} : Bool}
  %Equal.sym(+List<U32>, Layout.payloads(VS.fpv(pre, Y, post)), List.append(&2, U32, Y, []), VS.fpv_pay(pre, Y, post)) :
    {N.fits(4n, Nat.add(VS.FSZ(pre, post), List.length(&2, U32, _))) == True{} : Bool}
  %Equal.sym(+List<U32>, List.append(&2, U32, Y, []), Y, VS.app_nil(Y)) :
    {N.fits(4n, Nat.add(VS.FSZ(pre, post), List.length(&2, U32, _))) == True{} : Bool}
  fit

# The offset encoding of fixed parts of words around one variable part of bytes Y.
law enc_fpvb:
  for +pre: +List<+List<U32>>
  for +Y: +List<U32>
  for +post: +List<+List<U32>>
  for +hY: {SP.bytes_domain(Y) == True{} : Bool}
  for +fit: {N.fits(4n, Nat.add(VS.FSZ(pre, post), List.length(&2, U32, Y))) == True{} : Bool}
  {Layout.encoding(VS.fpv(pre, Y, post)) == Some{List.append(&2, U32, List.append(&2, U32, FX.flat(pre), List.append(&2, U32, N.digits(4n, VS.FSZ(pre, post)), FX.flat(post))), Y)} : Maybe<&2, +List<U32>>}
def enc_fpvb(pre, Y, post, hY, fit):
  %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding(VS.fpv(pre, Y, post)),
      Some{List.append(&2, U32, Layout.fixed_parts(VS.fpv(pre, Y, post), Layout.fixed_size(VS.fpv(pre, Y, post))), Layout.payloads(VS.fpv(pre, Y, post)))},
      encb_go(pre, Y, post, hY, True{}, encb_eb(pre, Y, post, fit), {==})) :
    {_ == Some{List.append(&2, U32, List.append(&2, U32, FX.flat(pre), List.append(&2, U32, N.digits(4n, VS.FSZ(pre, post)), FX.flat(post))), Y)} : Maybe<&2, +List<U32>>}
  %Equal.sym(Nat, Layout.fixed_size(VS.fpv(pre, Y, post)), VS.FSZ(pre, post), VS.fpv_size(pre, Y, post)) :
    {Some{List.append(&2, U32, Layout.fixed_parts(VS.fpv(pre, Y, post), _), Layout.payloads(VS.fpv(pre, Y, post)))} == Some{List.append(&2, U32, List.append(&2, U32, FX.flat(pre), List.append(&2, U32, N.digits(4n, VS.FSZ(pre, post)), FX.flat(post))), Y)} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, Layout.fixed_parts(VS.fpv(pre, Y, post), VS.FSZ(pre, post)), List.append(&2, U32, FX.flat(pre), List.append(&2, U32, N.digits(4n, VS.FSZ(pre, post)), FX.flat(post))), VS.fpv_fp(pre, Y, post, VS.FSZ(pre, post))) :
    {Some{List.append(&2, U32, _, Layout.payloads(VS.fpv(pre, Y, post)))} == Some{List.append(&2, U32, List.append(&2, U32, FX.flat(pre), List.append(&2, U32, N.digits(4n, VS.FSZ(pre, post)), FX.flat(post))), Y)} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, Layout.payloads(VS.fpv(pre, Y, post)), List.append(&2, U32, Y, []), VS.fpv_pay(pre, Y, post)) :
    {Some{List.append(&2, U32, List.append(&2, U32, FX.flat(pre), List.append(&2, U32, N.digits(4n, VS.FSZ(pre, post)), FX.flat(post))), _)} == Some{List.append(&2, U32, List.append(&2, U32, FX.flat(pre), List.append(&2, U32, N.digits(4n, VS.FSZ(pre, post)), FX.flat(post))), Y)} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, List.append(&2, U32, Y, []), Y, VS.app_nil(Y)) :
    {Some{List.append(&2, U32, List.append(&2, U32, FX.flat(pre), List.append(&2, U32, N.digits(4n, VS.FSZ(pre, post)), FX.flat(post))), _)} == Some{List.append(&2, U32, List.append(&2, U32, FX.flat(pre), List.append(&2, U32, N.digits(4n, VS.FSZ(pre, post)), FX.flat(post))), Y)} : Maybe<&2, +List<U32>>}
  {==}

# ---- the bytes of the masked copy --------------------------------------------------------------

# L <= 4 NW(L): the copied words cover the L bytes.
def quad_nw_ge(+L: U32, +k: Nat, +hk: {Nat.is_lt(k, 31n) == True{} : Bool}, +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(L), A.quad(VC.NW(L))) == True{} : Bool}:
  %Equal.sym(Nat, VC.NW(L), VD.s_rng(2n, Nat.add(3n, U32.to_nat(L))), VC.eNW(L, k, hk, hy)) : {Nat.is_le(U32.to_nat(L), A.quad(_)) == True{} : Bool}
  F.nat__le_trans(Nat.add(3n, U32.to_nat(L)), 1n+Nat.double(VD.s_h2(Nat.add(3n, U32.to_nat(L)))), 3n+A.quad(VD.s_rng(2n, Nat.add(3n, U32.to_nat(L)))), VC.h2_up(Nat.add(3n, U32.to_nat(L))),
    Order.double_monotone(VD.s_h2(Nat.add(3n, U32.to_nat(L))), 1n+Nat.double(VD.s_h2(VD.s_h2(Nat.add(3n, U32.to_nat(L))))), VC.h2_up(VD.s_h2(Nat.add(3n, U32.to_nat(L))))))

# The first L bytes of the masked copy of the L bytes at word j are those bytes.
law ybytes:
  for +L: U32
  for +dz: Nat
  for +j: Nat
  for +t: F.array__Tree<U32>
  for +k: Nat
  for +hk: {Nat.is_lt(k, 31n) == True{} : Bool}
  for +hy: {Nat.is_le(VC.YL(L), VB.pw(k)) == True{} : Bool}
  for +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(dz)) == True{} : Bool}
  for +hs: {Nat.is_le(Nat.add(VC.NW(L), j), VB.len(F.array__slots(U32, t))) == True{} : Bool}
  {VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, VY.MK(L, dz, VB.mone(VC.NW(L), j, 0n, dz, VC.ZT(dz), t))))) == VS.bt(U32.to_nat(L), FX.limbs(VB.wdr(j, F.array__slots(U32, t)))) : +List<U32>}
def ybytes(L, dz, j, t, k, hk, hy, hr, hs):
  +Mo = VB.mone(VC.NW(L), j, 0n, dz, VC.ZT(dz), t)
  +pz = F.array__trep_perfect(U32, dz, 0)
  +hr1 = F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dz)) == True{} : Bool}, Nat.add(VC.NW(L), 0n), VC.NW(L), F.nat__add_zero(VC.NW(L)), hr)
  +LM = VB.lm(VC.NW(L), j, 0n, F.array__slots(U32, VC.ZT(dz)), F.array__slots(U32, t))
  +hq = quad_nw_ge(L, k, hk, hy)
  +hz = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(VC.NW(L), 0n), z) == True{} : Bool}, VB.pw(dz), VB.len(F.array__slots(U32, VC.ZT(dz))),
    Equal.sym(Nat, VB.len(F.array__slots(U32, VC.ZT(dz))), VB.pw(dz), F.array__slots_length(U32, dz, VC.ZT(dz), pz)), hr)
  %Equal.sym(+List<U32>, VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, VY.MK(L, dz, Mo)))), VS.bt(U32.to_nat(L), FX.limbs(F.array__slots(U32, Mo))),
      VY.mk_bytes(L, dz, Mo, k, hk, hy, hr1, VB.mone_perfect(VC.NW(L), j, 0n, dz, VC.ZT(dz), t, pz))) :
    {_ == VS.bt(U32.to_nat(L), FX.limbs(VB.wdr(j, F.array__slots(U32, t)))) : +List<U32>}
  %Equal.sym(List<&2, U32>, F.array__slots(U32, Mo), LM, VB.slots_mone(VC.NW(L), j, 0n, dz, VC.ZT(dz), t, pz, hr)) :
    {VS.bt(U32.to_nat(L), FX.limbs(_)) == VS.bt(U32.to_nat(L), FX.limbs(VB.wdr(j, F.array__slots(U32, t)))) : +List<U32>}
  %VY.bt_take(VC.NW(L), U32.to_nat(L), LM, hq) :
    {_ == VS.bt(U32.to_nat(L), FX.limbs(VB.wdr(j, F.array__slots(U32, t)))) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(VC.NW(L), VB.wdr(0n, LM)), VS.wtake(VC.NW(L), VB.wdr(j, F.array__slots(U32, t))),
      VB.lm_win(VC.NW(L), j, 0n, F.array__slots(U32, VC.ZT(dz)), F.array__slots(U32, t), hz, hs)) :
    {VS.bt(U32.to_nat(L), FX.limbs(_)) == VS.bt(U32.to_nat(L), FX.limbs(VB.wdr(j, F.array__slots(U32, t)))) : +List<U32>}
  VY.bt_take(VC.NW(L), U32.to_nat(L), VB.wdr(j, F.array__slots(U32, t)), hq)

law bt_len_le:
  for +m: Nat
  for +X: +List<U32>
  {Nat.is_le(List.length(&2, U32, VS.bt(m, X)), m) == True{} : Bool}
def bt_len_le(m, X):
  match m X:
    case 0n +X0: {==}
    case 1n+ +p Nil{}: Order.zero_le(1n+p)
    case 1n+ +p Con{+x, +t}: bt_len_le(p, t)

law wdr_len_le:
  for +H: Nat
  for +i: Nat
  for +W: List<&2, U32>
  for +h: {Nat.is_le(Nat.add(H, i), VB.len(W)) == True{} : Bool}
  {Nat.is_le(H, VB.len(VB.wdr(i, W))) == True{} : Bool}
def wdr_len_le(H, i, W, h):
  match i W:
    case 0n +W0: F.logic__subst(Nat, z => {Nat.is_le(z, VB.len(W0)) == True{} : Bool}, Nat.add(H, 0n), H, F.nat__add_zero(H), h)
    case 1n+ +p Nil{}:
      Empty.absurd({Nat.is_le(H, VB.len(VB.wdr(1n+p, Nil{}))) == True{} : Bool}, F.logic__false_true(
        F.logic__subst(Nat, z => {Nat.is_le(z, 0n) == True{} : Bool}, Nat.add(H, 1n+p), 1n+Nat.add(H, p), F.nat__add_succ(H, p), h)))
    case 1n+ +p Con{+x, +t}:
      wdr_len_le(H, p, t, F.logic__subst(Nat, z => {Nat.is_le(z, 1n+VB.len(t)) == True{} : Bool}, Nat.add(H, 1n+p), 1n+Nat.add(H, p), F.nat__add_succ(H, p), h))

law wdr_len:
  for +i: Nat
  for +W: List<&2, U32>
  for +h: {Nat.is_le(i, VB.len(W)) == True{} : Bool}
  {Nat.add(i, VB.len(VB.wdr(i, W))) == VB.len(W) : Nat}
def wdr_len(i, W, h):
  match i W:
    case 0n +W0: {==}
    case 1n+ +p Nil{}: Empty.absurd({Nat.add(1n+p, VB.len(VB.wdr(1n+p, Nil{}))) == VB.len(Nil{}) : Nat}, F.logic__false_true(h))
    case 1n+ +p Con{+x, +t}:
      %Equal.sym(Nat, Nat.add(p, VB.len(VB.wdr(p, t))), VB.len(t), wdr_len(p, t, h)) : {1n+_ == 1n+VB.len(t) : Nat}
      {==}

law le_cancel:
  for +a: Nat
  for +x: Nat
  for +y: Nat
  for +h: {Nat.is_le(Nat.add(a, x), Nat.add(a, y)) == True{} : Bool}
  {Nat.is_le(x, y) == True{} : Bool}
def le_cancel(a, x, y, h):
  match a:
    case 0n: h
    case 1n+ +p: le_cancel(p, x, y, h)

law len_list:
  for +W: List<&2, U32>
  {List.length(&2, U32, W) == F.spec_common__length(U32, W) : Nat}
def len_list(W):
  match W:
    case Nil{}: {==}
    case Con{+h, +t}:
      %Equal.sym(Nat, List.length(&2, U32, t), F.spec_common__length(U32, t), len_list(t)) : {1n+_ == 1n+F.spec_common__length(U32, t) : Nat}
      {==}

# The limbs of the words from i on of a tree of 2^d words hold every window of 4 i + len <= 4 2^d bytes.
def win_room(+d: Nat, +t: F.array__Tree<U32>, +i: Nat, +len: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(len), List.length(&2, U32, FX.limbs(VB.wdr(i, F.array__slots(U32, t))))) == True{} : Bool}:
  +S = F.array__slots(U32, t)
  +eS = F.array__slots_length(U32, d, t, pf)
  +hiS = F.logic__subst(Nat, z => {Nat.is_le(i, z) == True{} : Bool}, VB.pw(d), VB.len(S), Equal.sym(Nat, VB.len(S), VB.pw(d), eS),
    VC.quad_inv(i, VB.pw(d), F.nat__le_trans(A.quad(i), Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d)), Order.below_sum(A.quad(i), U32.to_nat(len)), hw)))
  +e1 = Equal.trans(Nat, Nat.add(i, VB.len(VB.wdr(i, S))), VB.len(S), VB.pw(d), wdr_len(i, S, hiS), eS)
  +e2 = Equal.trans(Nat, Nat.add(A.quad(i), A.quad(VB.len(VB.wdr(i, S)))), A.quad(Nat.add(i, VB.len(VB.wdr(i, S)))), A.quad(VB.pw(d)),
    VF.quad_add(i, VB.len(VB.wdr(i, S))), Equal.cong(Nat, Nat, z => A.quad(z), Nat.add(i, VB.len(VB.wdr(i, S))), VB.pw(d), e1))
  %Equal.sym(Nat, List.length(&2, U32, FX.limbs(VB.wdr(i, S))), FX.wlen(VB.wdr(i, S)), VS.len_limbs(VB.wdr(i, S))) : {Nat.is_le(U32.to_nat(len), _) == True{} : Bool}
  %Equal.sym(Nat, FX.wlen(VB.wdr(i, S)), A.quad(List.length(&2, U32, VB.wdr(i, S))), VS.wlen_quad(VB.wdr(i, S))) : {Nat.is_le(U32.to_nat(len), _) == True{} : Bool}
  %Equal.sym(Nat, List.length(&2, U32, VB.wdr(i, S)), VB.len(VB.wdr(i, S)), len_list(VB.wdr(i, S))) : {Nat.is_le(U32.to_nat(len), A.quad(_)) == True{} : Bool}
  le_cancel(A.quad(i), U32.to_nat(len), A.quad(VB.len(VB.wdr(i, S))),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), z) == True{} : Bool}, A.quad(VB.pw(d)), Nat.add(A.quad(i), A.quad(VB.len(VB.wdr(i, S)))), Equal.sym(Nat, Nat.add(A.quad(i), A.quad(VB.len(VB.wdr(i, S)))), A.quad(VB.pw(d)), e2), hw))

# The payload of the offset layout starts after the fixed size.
law out_dr:
  for +pre: +List<+List<U32>>
  for +Y: +List<U32>
  for +post: +List<+List<U32>>
  {VS.bdr(Nat.add(VR.lens(pre), 4n+VR.lens(post)), VR.OUT(pre, Y, post)) == Y : +List<U32>}
def out_dr(pre, Y, post):
  +D = List.append(&2, U32, N.digits(4n, VR.FZ(pre, post)), VR.bcat(post))
  +Pf = List.append(&2, U32, VR.bcat(pre), D)
  +eL = Equal.trans(Nat, List.length(&2, U32, Pf), Nat.add(List.length(&2, U32, VR.bcat(pre)), List.length(&2, U32, D)), Nat.add(VR.lens(pre), 4n+VR.lens(post)),
    VS.len_app(VR.bcat(pre), D),
    Equal.trans(Nat, Nat.add(List.length(&2, U32, VR.bcat(pre)), List.length(&2, U32, D)), Nat.add(VR.lens(pre), List.length(&2, U32, D)), Nat.add(VR.lens(pre), 4n+VR.lens(post)),
      Equal.cong(Nat, Nat, z => Nat.add(z, List.length(&2, U32, D)), List.length(&2, U32, VR.bcat(pre)), VR.lens(pre), VR.len_bcat(pre)),
      Equal.cong(Nat, Nat, z => Nat.add(VR.lens(pre), z), List.length(&2, U32, D), 4n+VR.lens(post),
        Equal.trans(Nat, List.length(&2, U32, D), Nat.add(List.length(&2, U32, N.digits(4n, VR.FZ(pre, post))), List.length(&2, U32, VR.bcat(post))), 4n+VR.lens(post),
          VS.len_app(N.digits(4n, VR.FZ(pre, post)), VR.bcat(post)),
          Equal.cong(Nat, Nat, z => 4n+z, List.length(&2, U32, VR.bcat(post)), VR.lens(post), VR.len_bcat(post))))))
  %Equal.sym(+List<U32>, VR.OUT(pre, Y, post), VR.OUTX(pre, Y, post), VR.out_eq(pre, Y, post)) :
    {VS.bdr(Nat.add(VR.lens(pre), 4n+VR.lens(post)), _) == Y : +List<U32>}
  %eL : {VS.bdr(_, List.append(&2, U32, Pf, Y)) == Y : +List<U32>}
  VS.bdr_app(Pf, Y)

# ---- headers of word segments (some of them symbolic) ------------------------------------------

def cat(wss: +List<+List<U32>>) -> List<&2, U32>:
  match wss:
    case Nil{}: []
    case Con{ws, t}: VF.app(ws, cat(t))

law flat_cat:
  for +wss: +List<+List<U32>>
  {FX.flat(wss) == FX.limbs(cat(wss)) : +List<U32>}
def flat_cat(wss):
  match wss:
    case Nil{}: {==}
    case Con{+ws, +t}:
      %Equal.sym(+List<U32>, FX.flat(t), FX.limbs(cat(t)), flat_cat(t)) : {List.append(&2, U32, FX.limbs(ws), _) == FX.limbs(VF.app(ws, cat(t))) : +List<U32>}
      Equal.sym(+List<U32>, FX.limbs(VF.app(ws, cat(t))), List.append(&2, U32, FX.limbs(ws), FX.limbs(cat(t))), VF.limbs_app(ws, cat(t)))

# The offset layout's fixed bytes are the limbs of the concatenated segments.
law hdr_flat:
  for +pre: +List<+List<U32>>
  for +x: U32
  for +post: +List<+List<U32>>
  {List.append(&2, U32, FX.flat(pre), List.append(&2, U32, FX.limbs([x]), FX.flat(post))) == FX.limbs(cat(List.append(&2, +List<U32>, pre, Con{[x], post}))) : +List<U32>}
def hdr_flat(pre, x, post):
  match pre:
    case Nil{}:
      %Equal.sym(+List<U32>, FX.flat(post), FX.limbs(cat(post)), flat_cat(post)) : {List.append(&2, U32, FX.limbs([x]), _) == FX.limbs(VF.app([x], cat(post))) : +List<U32>}
      Equal.sym(+List<U32>, FX.limbs(VF.app([x], cat(post))), List.append(&2, U32, FX.limbs([x]), FX.limbs(cat(post))), VF.limbs_app([x], cat(post)))
    case Con{+ws, +t}:
      +R = List.append(&2, U32, FX.limbs([x]), FX.flat(post))
      %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, FX.limbs(ws), FX.flat(t)), R), List.append(&2, U32, FX.limbs(ws), List.append(&2, U32, FX.flat(t), R)), VS.app_assoc(FX.limbs(ws), FX.flat(t), R)) : {_ == FX.limbs(VF.app(ws, cat(List.append(&2, +List<U32>, t, Con{[x], post})))) : +List<U32>}
      %Equal.sym(+List<U32>, List.append(&2, U32, FX.flat(t), R), FX.limbs(cat(List.append(&2, +List<U32>, t, Con{[x], post}))), hdr_flat(t, x, post)) :
        {List.append(&2, U32, FX.limbs(ws), _) == FX.limbs(VF.app(ws, cat(List.append(&2, +List<U32>, t, Con{[x], post})))) : +List<U32>}
      Equal.sym(+List<U32>, FX.limbs(VF.app(ws, cat(List.append(&2, +List<U32>, t, Con{[x], post})))), List.append(&2, U32, FX.limbs(ws), FX.limbs(cat(List.append(&2, +List<U32>, t, Con{[x], post})))),
        VF.limbs_app(ws, cat(List.append(&2, +List<U32>, t, Con{[x], post}))))

def lsum(wss: +List<+List<U32>>) -> Nat:
  match wss:
    case Nil{}: 0n
    case Con{ws, t}: Nat.add(List.length(&2, U32, ws), lsum(t))

law len_flat:
  for +wss: +List<+List<U32>>
  {List.length(&2, U32, FX.flat(wss)) == A.quad(lsum(wss)) : Nat}
def len_flat(wss):
  match wss:
    case Nil{}: {==}
    case Con{+ws, +t}:
      %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, FX.limbs(ws), FX.flat(t))), Nat.add(List.length(&2, U32, FX.limbs(ws)), List.length(&2, U32, FX.flat(t))), VS.len_app(FX.limbs(ws), FX.flat(t))) :
        {_ == A.quad(Nat.add(List.length(&2, U32, ws), lsum(t))) : Nat}
      %Equal.sym(Nat, List.length(&2, U32, FX.flat(t)), A.quad(lsum(t)), len_flat(t)) : {Nat.add(List.length(&2, U32, FX.limbs(ws)), _) == A.quad(Nat.add(List.length(&2, U32, ws), lsum(t))) : Nat}
      %Equal.sym(Nat, List.length(&2, U32, FX.limbs(ws)), FX.wlen(ws), VS.len_limbs(ws)) : {Nat.add(_, A.quad(lsum(t))) == A.quad(Nat.add(List.length(&2, U32, ws), lsum(t))) : Nat}
      %Equal.sym(Nat, FX.wlen(ws), A.quad(List.length(&2, U32, ws)), VS.wlen_quad(ws)) : {Nat.add(_, A.quad(lsum(t))) == A.quad(Nat.add(List.length(&2, U32, ws), lsum(t))) : Nat}
      VF.quad_add(List.length(&2, U32, ws), lsum(t))

def fsz_eq(+pre: +List<+List<U32>>, +post: +List<+List<U32>>) -> {VS.FSZ(pre, post) == Nat.add(A.quad(lsum(pre)), 4n+A.quad(lsum(post))) : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, FX.flat(pre)), A.quad(lsum(pre)), len_flat(pre)) : {Nat.add(_, 4n+List.length(&2, U32, FX.flat(post))) == Nat.add(A.quad(lsum(pre)), 4n+A.quad(lsum(post))) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, FX.flat(post)), A.quad(lsum(post)), len_flat(post)) : {Nat.add(A.quad(lsum(pre)), 4n+_) == Nat.add(A.quad(lsum(pre)), 4n+A.quad(lsum(post))) : Nat}
  {==}

law len_sapp:
  for +a: List<&2, U32>
  for +b: List<&2, U32>
  {List.length(&2, U32, VF.app(a, b)) == Nat.add(List.length(&2, U32, a), List.length(&2, U32, b)) : Nat}
def len_sapp(a, b):
  match a:
    case Nil{}: {==}
    case Con{+h, +t}:
      %Equal.sym(Nat, List.length(&2, U32, VF.app(t, b)), Nat.add(List.length(&2, U32, t), List.length(&2, U32, b)), len_sapp(t, b)) : {1n+_ == 1n+Nat.add(List.length(&2, U32, t), List.length(&2, U32, b)) : Nat}
      {==}

law len_take:
  for +m: Nat
  for +W: List<&2, U32>
  for +h: {Nat.is_le(m, VB.len(W)) == True{} : Bool}
  {F.spec_common__length(U32, VS.wtake(m, W)) == m : Nat}
def len_take(m, W, h):
  match m W:
    case 0n +W0: {==}
    case 1n+ +p Nil{}: Empty.absurd({F.spec_common__length(U32, VS.wtake(1n+p, Nil{})) == 1n+p : Nat}, F.logic__false_true(h))
    case 1n+ +p Con{+x, +t}:
      %Equal.sym(Nat, F.spec_common__length(U32, VS.wtake(p, t)), p, len_take(p, t, h)) : {1n+_ == 1n+p : Nat}
      {==}

# A window of m words at p of a list of length at least m + p has m words.
def len_win(+m: Nat, +p: Nat, +X: List<&2, U32>, +h: {Nat.is_le(Nat.add(m, p), VB.len(X)) == True{} : Bool})
    -> {F.spec_common__length(U32, VS.wtake(m, VB.wdr(p, X))) == m : Nat}:
  len_take(m, VB.wdr(p, X), wdr_len_le(m, p, X, h))
