import Base
import ../../spec/primitives.bend as SP
import ../../spec/layout.bend as Layout
import ../../spec/nat_bytes.bend as N
import ../../types/schema.bend as S
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ./vspec.bend as VS
import ./vrej.bend as VR

# The offset layout of a list of n variable parts y_0 .. y_{n-1} (spec/layout.bend),
# over arbitrary byte lists: n offsets of four bytes (the j-th is 4 n + |y_0| + .. +
# |y_{j-1}|), then the parts' bytes. For the lists of variable-size elements of
# codegen/var_vlist.py.

def VP(ys: +List<+List<U32>>) -> +List<S.Part>:
  match ys:
    case Nil{}: []
    case Con{y, r}: Con{S.Variable{y}, VP(r)}

def OFFS(ys: +List<+List<U32>>, +off: Nat) -> +List<U32>:
  match ys:
    case Nil{}: []
    case Con{y, r}: List.append(&2, U32, N.digits(4n, off), OFFS(r, Nat.add(off, List.length(&2, U32, y))))

def CNT(ys: +List<+List<U32>>) -> Nat:
  match ys:
    case Nil{}: 0n
    case Con{y, r}: 1n+CNT(r)

law vp_size:
  for +ys: +List<+List<U32>>
  {Layout.fixed_size(VP(ys)) == A.quad(CNT(ys)) : Nat}
def vp_size(ys):
  match ys:
    case Nil{}: {==}
    case Con{+y, +r}: Equal.cong(Nat, Nat, z => 4n+z, Layout.fixed_size(VP(r)), A.quad(CNT(r)), vp_size(r))

law vp_pay:
  for +ys: +List<+List<U32>>
  {Layout.payloads(VP(ys)) == VR.bcat(ys) : +List<U32>}
def vp_pay(ys):
  match ys:
    case Nil{}: {==}
    case Con{+y, +r}: Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, y, z), Layout.payloads(VP(r)), VR.bcat(r), vp_pay(r))

law vp_fp:
  for +ys: +List<+List<U32>>
  for +off: Nat
  {Layout.fixed_parts(VP(ys), off) == OFFS(ys, off) : +List<U32>}
def vp_fp(ys, off):
  match ys:
    case Nil{}: {==}
    case Con{+y, +r}:
      Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, N.digits(4n, off), z),
        Layout.fixed_parts(VP(r), Nat.add(off, List.length(&2, U32, y))), OFFS(r, Nat.add(off, List.length(&2, U32, y))), vp_fp(r, Nat.add(off, List.length(&2, U32, y))))

# The layout of the parts, when their bytes are valid and fit.
law vp_enc:
  for +ys: +List<+List<U32>>
  for +hv: {Layout.bytes_valid(VP(ys)) == True{} : Bool}
  for +fit: {N.fits(4n, Nat.add(A.quad(CNT(ys)), List.length(&2, U32, VR.bcat(ys)))) == True{} : Bool}
  {Layout.encoding(VP(ys)) == Some{List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys))} : Maybe<&2, +List<U32>>}
def vp_enc(ys, hv, fit):
  +ps = VP(ys)
  %Equal.sym(Nat, Layout.fixed_size(ps), A.quad(CNT(ys)), vp_size(ys)) :
    {SP.optional(Bool.and(Layout.bytes_valid(ps), N.fits(4n, Nat.add(_, List.length(&2, U32, Layout.payloads(ps))))), List.append(&2, U32, Layout.fixed_parts(ps, _), Layout.payloads(ps))) == Some{List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, Layout.payloads(ps), VR.bcat(ys), vp_pay(ys)) :
    {SP.optional(Bool.and(Layout.bytes_valid(ps), N.fits(4n, Nat.add(A.quad(CNT(ys)), List.length(&2, U32, _)))), List.append(&2, U32, Layout.fixed_parts(ps, A.quad(CNT(ys))), _)) == Some{List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, Layout.fixed_parts(ps, A.quad(CNT(ys))), OFFS(ys, A.quad(CNT(ys))), vp_fp(ys, A.quad(CNT(ys)))) :
    {SP.optional(Bool.and(Layout.bytes_valid(ps), N.fits(4n, Nat.add(A.quad(CNT(ys)), List.length(&2, U32, VR.bcat(ys))))), List.append(&2, U32, _, VR.bcat(ys))) == Some{List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, Layout.bytes_valid(ps), True{}, hv) :
    {SP.optional(Bool.and(_, N.fits(4n, Nat.add(A.quad(CNT(ys)), List.length(&2, U32, VR.bcat(ys))))), List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys))) == Some{List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, N.fits(4n, Nat.add(A.quad(CNT(ys)), List.length(&2, U32, VR.bcat(ys)))), True{}, fit) :
    {SP.optional(Bool.and(True{}, _), List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys))) == Some{List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys))} : Maybe<&2, +List<U32>>}
  {==}

law vp_valid:
  for +y: +List<U32>
  for +r: +List<+List<U32>>
  for +hy: {SP.bytes_domain(y) == True{} : Bool}
  for +hr: {Layout.bytes_valid(VP(r)) == True{} : Bool}
  {Layout.bytes_valid(VP(Con{y, r})) == True{} : Bool}
def vp_valid(y, r, hy, hr):
  %Equal.sym(Bool, SP.bytes_domain(y), True{}, hy) : {Bool.and(_, Layout.bytes_valid(VP(r))) == True{} : Bool}
  %Equal.sym(Bool, Layout.bytes_valid(VP(r)), True{}, hr) : {Bool.and(True{}, _) == True{} : Bool}
  {==}

law len_bcat_cons:
  for +y: +List<U32>
  for +r: +List<+List<U32>>
  {List.length(&2, U32, VR.bcat(Con{y, r})) == Nat.add(List.length(&2, U32, y), List.length(&2, U32, VR.bcat(r))) : Nat}
def len_bcat_cons(y, r):
  VS.len_app(y, VR.bcat(r))
