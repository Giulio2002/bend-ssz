import Base
import ../../types/schema.bend as S
import ../../spec/primitives.bend as SP
import ../../spec/layout.bend as Layout
import ../../spec/codec.bend as Codec
import ../../spec/nat_bytes.bend as N
import ../../spec/bitfields.bend as Bits
import ../../spec/bit_packing.bend as Bp
import ../../proofs/primitive_invariants.bend as V
import ../../proofs/nat_order.bend as Order
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vcopy.bend as VC
import ./vdepth.bend as VD
import ./vlist.bend as VLS
import ./vbitl.bend as VBL
import ./vrej.bend as VRJ

# Containers of fixed fields around one bit list: the offset layout with an
# arbitrary (byte-domain) payload, the spec parts of a bit list value, and the
# word count of a window after a header.

# ---- the offset layout with any byte payload ------------------------------------------------

law fpv_validb:
  for +pre: +List<+List<U32>>
  for +Y: +List<U32>
  for +post: +List<+List<U32>>
  for +dom: {SP.bytes_domain(Y) == True{} : Bool}
  {Layout.bytes_valid(VS.fpv(pre, Y, post)) == True{} : Bool}
def fpv_validb(pre, Y, post, dom):
  match pre:
    case Nil{}: V.and_true(SP.bytes_domain(Y), Layout.bytes_valid(FX.fparts(post)), dom, FX.valid_fparts(post))
    case Con{+ws, +t}: V.and_true(SP.bytes_domain(FX.limbs(ws)), Layout.bytes_valid(VS.fpv(t, Y, post)), FX.domain_limbs(ws), fpv_validb(t, Y, post, dom))

def FSZ(+pre: +List<+List<U32>>, +post: +List<+List<U32>>) -> Nat: VS.FSZ(pre, post)

law enc_fpvb:
  for +pre: +List<+List<U32>>
  for +Y: +List<U32>
  for +post: +List<+List<U32>>
  for +dom: {SP.bytes_domain(Y) == True{} : Bool}
  for +fit: {N.fits(4n, Nat.add(FSZ(pre, post), List.length(&2, U32, Y))) == True{} : Bool}
  {Layout.encoding(VS.fpv(pre, Y, post)) == Some{List.append(&2, U32, List.append(&2, U32, FX.flat(pre), List.append(&2, U32, N.digits(4n, FSZ(pre, post)), FX.flat(post))), Y)} : Maybe<&2, +List<U32>>}
def enc_fpvb(pre, Y, post, dom, fit):
  +P = VS.fpv(pre, Y, post)
  +R = List.append(&2, U32, List.append(&2, U32, FX.flat(pre), List.append(&2, U32, N.digits(4n, FSZ(pre, post)), FX.flat(post))), Y)
  %Equal.sym(Bool, Layout.bytes_valid(P), True{}, fpv_validb(pre, Y, post, dom)) :
    {SP.optional(Bool.and(_, N.fits(4n, Nat.add(Layout.fixed_size(P), List.length(&2, U32, Layout.payloads(P))))), List.append(&2, U32, Layout.fixed_parts(P, Layout.fixed_size(P)), Layout.payloads(P))) == Some{R} : Maybe<&2, +List<U32>>}
  %Equal.sym(Nat, Layout.fixed_size(P), FSZ(pre, post), VS.fpv_size(pre, Y, post)) :
    {SP.optional(Bool.and(True{}, N.fits(4n, Nat.add(_, List.length(&2, U32, Layout.payloads(P))))), List.append(&2, U32, Layout.fixed_parts(P, _), Layout.payloads(P))) == Some{R} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, Layout.payloads(P), List.append(&2, U32, Y, []), VS.fpv_pay(pre, Y, post)) :
    {SP.optional(Bool.and(True{}, N.fits(4n, Nat.add(FSZ(pre, post), List.length(&2, U32, _)))), List.append(&2, U32, Layout.fixed_parts(P, FSZ(pre, post)), _)) == Some{R} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, List.append(&2, U32, Y, []), Y, VS.app_nil(Y)) :
    {SP.optional(Bool.and(True{}, N.fits(4n, Nat.add(FSZ(pre, post), List.length(&2, U32, _)))), List.append(&2, U32, Layout.fixed_parts(P, FSZ(pre, post)), _)) == Some{R} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, N.fits(4n, Nat.add(FSZ(pre, post), List.length(&2, U32, Y))), True{}, fit) :
    {SP.optional(Bool.and(True{}, _), List.append(&2, U32, Layout.fixed_parts(P, FSZ(pre, post)), Y)) == Some{R} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, Layout.fixed_parts(P, FSZ(pre, post)), List.append(&2, U32, FX.flat(pre), List.append(&2, U32, N.digits(4n, FSZ(pre, post)), FX.flat(post))), VS.fpv_fp(pre, Y, post, FSZ(pre, post))) :
    {SP.optional(True{}, List.append(&2, U32, _, Y)) == Some{R} : Maybe<&2, +List<U32>>}
  {==}

# ---- a bit list value --------------------------------------------------------------------------

# The spec parts of the value bits of a byte string: one variable part, the string.
law bl_parts:
  for +bs: +List<U32>
  for +cap: Nat
  for +dom: {SP.bytes_domain(bs) == True{} : Bool}
  for +nz: {U32.is_eq(VBL.lastb(bs), 0) == False{} : Bool}
  for +hl: {Nat.is_le(List.length(&2, Bool, VBL.bl(bs)), cap) == True{} : Bool}
  {Codec.parts(S.BitsValue{VBL.bl(bs)}, S.BitList{cap}) == Some{[S.Variable{bs}]} : Maybe<&2, +List<S.Part>>}
def bl_parts(bs, cap, dom, nz, hl):
  %Equal.sym(Bool, Nat.is_le(List.length(&2, Bool, VBL.bl(bs)), cap), True{}, hl) :
    {Codec.one(Bits.encoding(_, List.append(&2, Bool, VBL.bl(bs), [True{}])), None{}) == Some{[S.Variable{bs}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, VBL.bl(bs), [True{}])), bs, VBL.bl_pack(bs, dom, nz)) :
    {Codec.one(Some{_}, None{}) == Some{[S.Variable{bs}]} : Maybe<&2, +List<S.Part>>}
  {==}

# ---- byte strings ------------------------------------------------------------------------------

law btn:
  for +b: Nat
  {[] == VS.bt(b, []) : +List<U32>}
def btn(b):
  match b:
    case 0n: {==}
    case 1n+ +p: {==}

law bt_split:
  for +a: Nat
  for +b: Nat
  for +xs: +List<U32>
  {VS.bt(Nat.add(a, b), xs) == List.append(&2, U32, VS.bt(a, xs), VS.bt(b, VS.bdr(a, xs))) : +List<U32>}
def bt_split(a, b, xs):
  match a xs:
    case 0n _: {==}
    case 1n+ +p Nil{}: btn(b)
    case 1n+ +p Con{+x, +t}:
      %Equal.sym(+List<U32>, VS.bt(Nat.add(p, b), t), List.append(&2, U32, VS.bt(p, t), VS.bt(b, VS.bdr(p, t))), bt_split(p, b, t)) :
        {x <> _ == x <> List.append(&2, U32, VS.bt(p, t), VS.bt(b, VS.bdr(p, t))) : +List<U32>}
      {==}

# ---- the words of a window after a header of H words -----------------------------------------

law h2_add:
  for +k: Nat
  for +y: Nat
  {VD.s_h2(Nat.add(Nat.double(k), y)) == Nat.add(k, VD.s_h2(y)) : Nat}
def h2_add(k, y):
  match k:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, VD.s_h2(Nat.add(Nat.double(p), y)), Nat.add(p, VD.s_h2(y)), h2_add(p, y)) : {1n+_ == 1n+Nat.add(p, VD.s_h2(y)) : Nat}
      {==}

law rng2_add:
  for +h: Nat
  for +y: Nat
  {VD.s_rng(2n, Nat.add(A.quad(h), y)) == Nat.add(h, VD.s_rng(2n, y)) : Nat}
def rng2_add(h, y):
  %Equal.sym(Nat, VD.s_h2(Nat.add(Nat.double(Nat.double(h)), y)), Nat.add(Nat.double(h), VD.s_h2(y)), h2_add(Nat.double(h), y)) : {VD.s_h2(_) == Nat.add(h, VD.s_h2(VD.s_h2(y))) : Nat}
  h2_add(h, VD.s_h2(y))

# ceil(L / 4) + H words for 4 H + L <= 4 2^d bytes.
def nwH(+d: Nat, +L: U32, +h: Nat, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(h), U32.to_nat(L)), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(Nat.add(VC.NW(L), h), VB.pw(d)) == True{} : Bool}:
  +hL = F.nat__le_trans(U32.to_nat(L), Nat.add(A.quad(h), U32.to_nat(L)), A.quad(VB.pw(d)), Order.left_below_sum(A.quad(h), U32.to_nat(L)), hw)
  %Equal.sym(Nat, VC.NW(L), VD.s_rng(2n, 3n+U32.to_nat(L)), VC.eNW(L, VLS.KK(d), VLS.kk_lt(d, hd), VLS.hyn(d, L, hL))) : {Nat.is_le(Nat.add(_, h), VB.pw(d)) == True{} : Bool}
  %F.nat__add_comm(h, VD.s_rng(2n, 3n+U32.to_nat(L))) : {Nat.is_le(_, VB.pw(d)) == True{} : Bool}
  %rng2_add(h, 3n+U32.to_nat(L)) : {Nat.is_le(_, VB.pw(d)) == True{} : Bool}
  %VLS.rng2_q(VB.pw(d)) : {Nat.is_le(VD.s_rng(2n, Nat.add(A.quad(h), 3n+U32.to_nat(L))), _) == True{} : Bool}
  VC.rng_mono(2n, Nat.add(A.quad(h), 3n+U32.to_nat(L)), 3n+A.quad(VB.pw(d)),
    F.logic__subst(Nat, z => {Nat.is_le(z, 3n+A.quad(VB.pw(d))) == True{} : Bool}, 3n+Nat.add(A.quad(h), U32.to_nat(L)), Nat.add(A.quad(h), 3n+U32.to_nat(L)),
      Equal.sym(Nat, Nat.add(A.quad(h), 3n+U32.to_nat(L)), 3n+Nat.add(A.quad(h), U32.to_nat(L)), F.lru_nat_algebra__add_swap(A.quad(h), 3n, U32.to_nat(L))), hw))

# ---- the offset layout's payload -----------------------------------------------------------------

def lenHead(+pre: +List<+List<U32>>, +post: +List<+List<U32>>)
    -> {List.length(&2, U32, List.append(&2, U32, VRJ.bcat(pre), List.append(&2, U32, N.digits(4n, VRJ.FZ(pre, post)), VRJ.bcat(post)))) == VRJ.FZ(pre, post) : Nat}:
  +D = List.append(&2, U32, N.digits(4n, VRJ.FZ(pre, post)), VRJ.bcat(post))
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, VRJ.bcat(pre), D)), Nat.add(List.length(&2, U32, VRJ.bcat(pre)), List.length(&2, U32, D)), VS.len_app(VRJ.bcat(pre), D)) :
    {_ == VRJ.FZ(pre, post) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, D), Nat.add(List.length(&2, U32, N.digits(4n, VRJ.FZ(pre, post))), List.length(&2, U32, VRJ.bcat(post))), VS.len_app(N.digits(4n, VRJ.FZ(pre, post)), VRJ.bcat(post))) :
    {Nat.add(List.length(&2, U32, VRJ.bcat(pre)), _) == VRJ.FZ(pre, post) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, VRJ.bcat(pre)), VRJ.lens(pre), VRJ.len_bcat(pre)) :
    {Nat.add(_, Nat.add(List.length(&2, U32, N.digits(4n, VRJ.FZ(pre, post))), List.length(&2, U32, VRJ.bcat(post)))) == VRJ.FZ(pre, post) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, VRJ.bcat(post)), VRJ.lens(post), VRJ.len_bcat(post)) :
    {Nat.add(VRJ.lens(pre), Nat.add(List.length(&2, U32, N.digits(4n, VRJ.FZ(pre, post))), _)) == VRJ.FZ(pre, post) : Nat}
  {==}

# The payload follows the FZ bytes of the fixed region.
law out_tail:
  for +pre: +List<+List<U32>>
  for +Y: +List<U32>
  for +post: +List<+List<U32>>
  {VS.bdr(VRJ.FZ(pre, post), VRJ.OUT(pre, Y, post)) == Y : +List<U32>}
def out_tail(pre, Y, post):
  +A = List.append(&2, U32, VRJ.bcat(pre), List.append(&2, U32, N.digits(4n, VRJ.FZ(pre, post)), VRJ.bcat(post)))
  %Equal.sym(+List<U32>, VRJ.OUT(pre, Y, post), VRJ.OUTX(pre, Y, post), VRJ.out_eq(pre, Y, post)) : {VS.bdr(VRJ.FZ(pre, post), _) == Y : +List<U32>}
  %lenHead(pre, post) : {VS.bdr(_, List.append(&2, U32, A, Y)) == Y : +List<U32>}
  VS.bdr_app(A, Y)
