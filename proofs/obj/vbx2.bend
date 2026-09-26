import Base
import ../../spec/primitives.bend as SP
import ../../spec/layout.bend as Layout
import ../../spec/nat_bytes.bend as N
import ../../types/schema.bend as S
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ../../proofs/primitive_invariants.bend as V
import ./spec_fixed.bend as FX
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vrej.bend as VR
import ./vnest.bend as VN
import ./vbitc.bend as VBC
import ./vua.bend as UA
import ./vua_win.bend as UW

# The offset layout of a container whose first two fields are variable (two
# variable parts y0, y1, then fixed parts post), over arbitrary byte lists and
# symbolic sizes (LightClientFinalityUpdate: two LightClientHeaders, then the
# finality branch, the sync aggregate and the slot), and byte windows at any
# offset split in two.

def PR2(+y0: +List<U32>, +y1: +List<U32>, +post: +List<+List<U32>>) -> +List<S.Part>:
  Con{S.Variable{y0}, Con{S.Variable{y1}, VR.bfix(post)}}

def F2(+post: +List<+List<U32>>) -> Nat: 4n+4n+VR.lens(post)

# The header: the two offsets and the fixed parts' bytes.
def R2(+y0: +List<U32>, +post: +List<+List<U32>>) -> +List<U32>:
  List.append(&2, U32, N.digits(4n, F2(post)), List.append(&2, U32, N.digits(4n, Nat.add(F2(post), List.length(&2, U32, y0))), VR.bcat(post)))

def OUT2(+y0: +List<U32>, +y1: +List<U32>, +post: +List<+List<U32>>) -> +List<U32>:
  List.append(&2, U32, R2(y0, post), List.append(&2, U32, y0, y1))

def OUTL(+y0: +List<U32>, +y1: +List<U32>, +post: +List<+List<U32>>) -> +List<U32>:
  List.append(&2, U32, Layout.fixed_parts(PR2(y0, y1, post), Layout.fixed_size(PR2(y0, y1, post))), Layout.payloads(PR2(y0, y1, post)))

law out2:
  for +y0: +List<U32>
  for +y1: +List<U32>
  for +post: +List<+List<U32>>
  {OUTL(y0, y1, post) == OUT2(y0, y1, post) : +List<U32>}
def out2(y0, y1, post):
  +ps = PR2(y0, y1, post)
  +X1 = Nat.add(F2(post), List.length(&2, U32, y0))
  +X2 = Nat.add(Nat.add(F2(post), List.length(&2, U32, y0)), List.length(&2, U32, y1))
  %Equal.sym(Nat, Layout.fixed_size(VR.bfix(post)), VR.lens(post), VR.size_bfix(post)) :
    {List.append(&2, U32, Layout.fixed_parts(ps, Nat.add(4n, Nat.add(4n, _))), Layout.payloads(ps)) == OUT2(y0, y1, post) : +List<U32>}
  %Equal.sym(+List<U32>, Layout.fixed_parts(VR.bfix(post), X2), VR.bcat(post), VR.fp_bfix(post, X2)) :
    {List.append(&2, U32, List.append(&2, U32, N.digits(4n, F2(post)), List.append(&2, U32, N.digits(4n, X1), _)), Layout.payloads(ps)) == OUT2(y0, y1, post) : +List<U32>}
  %Equal.sym(+List<U32>, Layout.payloads(VR.bfix(post)), [], VR.pay_bfix(post)) :
    {List.append(&2, U32, R2(y0, post), List.append(&2, U32, y0, List.append(&2, U32, y1, _))) == OUT2(y0, y1, post) : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, y1, []), y1, VS.app_nil(y1)) :
    {List.append(&2, U32, R2(y0, post), List.append(&2, U32, y0, _)) == OUT2(y0, y1, post) : +List<U32>}
  {==}

law valid2:
  for +y0: +List<U32>
  for +y1: +List<U32>
  for +post: +List<+List<U32>>
  for +h0: {SP.bytes_domain(y0) == True{} : Bool}
  for +h1: {SP.bytes_domain(y1) == True{} : Bool}
  for +hp: {Layout.bytes_valid(VR.bfix(post)) == True{} : Bool}
  {Layout.bytes_valid(PR2(y0, y1, post)) == True{} : Bool}
def valid2(y0, y1, post, h0, h1, hp):
  V.and_true(SP.bytes_domain(y0), Layout.bytes_valid(Con{S.Variable{y1}, VR.bfix(post)}), h0,
    V.and_true(SP.bytes_domain(y1), Layout.bytes_valid(VR.bfix(post)), h1, hp))

def len_r2(+y0: +List<U32>, +post: +List<+List<U32>>) -> {List.length(&2, U32, R2(y0, post)) == F2(post) : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, VR.bcat(post)), VR.lens(post), VR.len_bcat(post)) : {4n+4n+_ == F2(post) : Nat}
  {==}

# The layout of [y0 | y1 | post]: the offsets F2 and F2 + |y0|, the fixed bytes, y0, y1.
law enc2:
  for +y0: +List<U32>
  for +y1: +List<U32>
  for +post: +List<+List<U32>>
  for +hv: {Layout.bytes_valid(PR2(y0, y1, post)) == True{} : Bool}
  for +fit: {N.fits(4n, Nat.add(F2(post), List.length(&2, U32, List.append(&2, U32, y0, List.append(&2, U32, y1, []))))) == True{} : Bool}
  {Layout.encoding(PR2(y0, y1, post)) == Some{OUT2(y0, y1, post)} : Maybe<&2, +List<U32>>}
def enc2(y0, y1, post, hv, fit):
  +ps = PR2(y0, y1, post)
  %Equal.sym(Nat, Layout.fixed_size(VR.bfix(post)), VR.lens(post), VR.size_bfix(post)) :
    {SP.optional(Bool.and(Layout.bytes_valid(ps), N.fits(4n, Nat.add(4n+4n+_, List.length(&2, U32, Layout.payloads(ps))))), OUTL(y0, y1, post)) == Some{OUT2(y0, y1, post)} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, Layout.payloads(VR.bfix(post)), [], VR.pay_bfix(post)) :
    {SP.optional(Bool.and(Layout.bytes_valid(ps), N.fits(4n, Nat.add(F2(post), List.length(&2, U32, List.append(&2, U32, y0, List.append(&2, U32, y1, _)))))), OUTL(y0, y1, post)) == Some{OUT2(y0, y1, post)} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, Layout.bytes_valid(ps), True{}, hv) :
    {SP.optional(Bool.and(_, N.fits(4n, Nat.add(F2(post), List.length(&2, U32, List.append(&2, U32, y0, List.append(&2, U32, y1, [])))))), OUTL(y0, y1, post)) == Some{OUT2(y0, y1, post)} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, N.fits(4n, Nat.add(F2(post), List.length(&2, U32, List.append(&2, U32, y0, List.append(&2, U32, y1, []))))), True{}, fit) :
    {SP.optional(Bool.and(True{}, _), OUTL(y0, y1, post)) == Some{OUT2(y0, y1, post)} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, OUTL(y0, y1, post), OUT2(y0, y1, post), out2(y0, y1, post)) : {SP.optional(True{}, _) == Some{OUT2(y0, y1, post)} : Maybe<&2, +List<U32>>}
  {==}

# ---- what a layout of that shape says about its bytes -----------------------------------------------

def o2_b0(+y0: +List<U32>, +y1: +List<U32>, +post: +List<+List<U32>>)
    -> {VS.bt(4n, VS.bdr(0n, OUT2(y0, y1, post))) == N.digits(4n, F2(post)) : +List<U32>}:
  {==}

def o2_b1(+y0: +List<U32>, +y1: +List<U32>, +post: +List<+List<U32>>)
    -> {VS.bt(4n, VS.bdr(4n, OUT2(y0, y1, post))) == N.digits(4n, Nat.add(F2(post), List.length(&2, U32, y0))) : +List<U32>}:
  {==}

law o2_len:
  for +y0: +List<U32>
  for +y1: +List<U32>
  for +post: +List<+List<U32>>
  {List.length(&2, U32, OUT2(y0, y1, post)) == Nat.add(F2(post), Nat.add(List.length(&2, U32, y0), List.length(&2, U32, y1))) : Nat}
def o2_len(y0, y1, post):
  %Equal.sym(Nat, List.length(&2, U32, OUT2(y0, y1, post)), Nat.add(List.length(&2, U32, R2(y0, post)), List.length(&2, U32, List.append(&2, U32, y0, y1))),
      VS.len_app(R2(y0, post), List.append(&2, U32, y0, y1))) :
    {_ == Nat.add(F2(post), Nat.add(List.length(&2, U32, y0), List.length(&2, U32, y1))) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, R2(y0, post)), F2(post), len_r2(y0, post)) :
    {Nat.add(_, List.length(&2, U32, List.append(&2, U32, y0, y1))) == Nat.add(F2(post), Nat.add(List.length(&2, U32, y0), List.length(&2, U32, y1))) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, y0, y1)), Nat.add(List.length(&2, U32, y0), List.length(&2, U32, y1)), VS.len_app(y0, y1)) :
    {Nat.add(F2(post), _) == Nat.add(F2(post), Nat.add(List.length(&2, U32, y0), List.length(&2, U32, y1))) : Nat}
  {==}

law o2_dr:
  for +y0: +List<U32>
  for +y1: +List<U32>
  for +post: +List<+List<U32>>
  {VS.bdr(F2(post), OUT2(y0, y1, post)) == List.append(&2, U32, y0, y1) : +List<U32>}
def o2_dr(y0, y1, post):
  %len_r2(y0, post) :
    {VS.bdr(_, OUT2(y0, y1, post)) == List.append(&2, U32, y0, y1) : +List<U32>}
  VS.bdr_app(R2(y0, post), List.append(&2, U32, y0, y1))

# ---- byte lists split in two --------------------------------------------------------------------

law bt_lenapp:
  for +xs: +List<U32>
  for +R: +List<U32>
  {VS.bt(List.length(&2, U32, xs), List.append(&2, U32, xs, R)) == xs : +List<U32>}
def bt_lenapp(xs, R):
  match xs:
    case Nil{}: {==}
    case Con{+h, +t}: Equal.cong(+List<U32>, +List<U32>, z => Con{h, z}, VS.bt(List.length(&2, U32, t), List.append(&2, U32, t, R)), t, bt_lenapp(t, R))

# A window of a + b bytes is its first a bytes, then the b bytes after them.
def splitWX(+t: F.array__Tree<U32>, +x: Nat, +a: Nat, +b: Nat)
    -> {UW.WX(t, x, Nat.add(a, b)) == List.append(&2, U32, UW.WX(t, x, a), UW.WX(t, Nat.add(a, x), b)) : +List<U32>}:
  %Equal.sym(+List<U32>, VS.bt(Nat.add(a, b), VS.bdr(x, UA.BYT(t))), List.append(&2, U32, VS.bt(a, VS.bdr(x, UA.BYT(t))), VS.bt(b, VS.bdr(a, VS.bdr(x, UA.BYT(t))))),
      VBC.bt_split(a, b, VS.bdr(x, UA.BYT(t)))) :
    {_ == List.append(&2, U32, UW.WX(t, x, a), UW.WX(t, Nat.add(a, x), b)) : +List<U32>}
  %VN.bdr_add(x, a, UA.BYT(t)) :
    {List.append(&2, U32, VS.bt(a, VS.bdr(x, UA.BYT(t))), VS.bt(b, _)) == List.append(&2, U32, UW.WX(t, x, a), UW.WX(t, Nat.add(a, x), b)) : +List<U32>}
  %F.nat__add_comm(x, a) :
    {List.append(&2, U32, VS.bt(a, VS.bdr(x, UA.BYT(t))), VS.bt(b, VS.bdr(Nat.add(x, a), UA.BYT(t)))) == List.append(&2, U32, UW.WX(t, x, a), VS.bt(b, VS.bdr(_, UA.BYT(t)))) : +List<U32>}
  {==}

# The two halves of a window that is y0 ++ y1.
def wx_fst(+t: F.array__Tree<U32>, +x: Nat, +y0: +List<U32>, +y1: +List<U32>,
    +e: {UW.WX(t, x, Nat.add(List.length(&2, U32, y0), List.length(&2, U32, y1))) == List.append(&2, U32, y0, y1) : +List<U32>})
    -> {y0 == UW.WX(t, x, List.length(&2, U32, y0)) : +List<U32>}:
  +k0 = List.length(&2, U32, y0)
  +k1 = List.length(&2, U32, y1)
  %bt_lenapp(y0, y1) : {_ == UW.WX(t, x, k0) : +List<U32>}
  %e : {VS.bt(k0, _) == UW.WX(t, x, k0) : +List<U32>}
  VS.bt_bt(k0, k1, VS.bdr(x, UA.BYT(t)))

def wx_snd(+t: F.array__Tree<U32>, +x: Nat, +y0: +List<U32>, +y1: +List<U32>,
    +e: {UW.WX(t, x, Nat.add(List.length(&2, U32, y0), List.length(&2, U32, y1))) == List.append(&2, U32, y0, y1) : +List<U32>})
    -> {y1 == UW.WX(t, Nat.add(List.length(&2, U32, y0), x), List.length(&2, U32, y1)) : +List<U32>}:
  +k0 = List.length(&2, U32, y0)
  +k1 = List.length(&2, U32, y1)
  %VS.bdr_app(y0, y1) : {_ == UW.WX(t, Nat.add(k0, x), k1) : +List<U32>}
  %e : {VS.bdr(k0, _) == UW.WX(t, Nat.add(k0, x), k1) : +List<U32>}
  UW.tailWX(t, x, k0, k1)
