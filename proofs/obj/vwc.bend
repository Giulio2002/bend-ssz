import Base
import ../../src/primitives.bend as I
import ../../spec/primitives.bend as SP
import ../../spec/layout.bend as Layout
import ../../spec/codec.bend as Codec
import ../../spec/nat_bytes.bend as N
import ../../types/schema.bend as S
import ../compact/found_generated.bend as F
import ../../proofs/decode_facts.bend as DF
import ./vspec.bend as VS
import ./vnest.bend as VN
import ./vdig.bend as VG
import ./vua_win.bend as UW

# The offset layout of a container's parts, one part at a time (codegen/var_winx_c.py): its
# fixed section, fixed size and validity, and skipping the bytes of the parts before a field.

law fp_fix:
  for +xs: +List<U32>
  for +r: +List<S.Part>
  for +off: Nat
  for +R: +List<U32>
  for +e: {Layout.fixed_parts(r, off) == R : +List<U32>}
  {Layout.fixed_parts(Con{S.Fixed{xs}, r}, off) == List.append(&2, U32, xs, R) : +List<U32>}
def fp_fix(xs, r, off, R, e):
  Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, xs, z), Layout.fixed_parts(r, off), R, e)

# A variable part's offset field: the limbs of a word w whose value is the offset.
law fp_var:
  for +y: +List<U32>
  for +r: +List<S.Part>
  for +off: Nat
  for +w: U32
  for +R: +List<U32>
  for +ew: {U32.to_nat(w) == off : Nat}
  for +e: {Layout.fixed_parts(r, Nat.add(off, List.length(&2, U32, y))) == R : +List<U32>}
  {Layout.fixed_parts(Con{S.Variable{y}, r}, off) == List.append(&2, U32, I.limb(w), R) : +List<U32>}
def fp_var(y, r, off, w, R, ew, e):
  +dl = Equal.trans(+List<U32>, N.digits(4n, off), N.digits(4n, U32.to_nat(w)), I.limb(w),
    Equal.cong(Nat, +List<U32>, z => N.digits(4n, z), off, U32.to_nat(w), Equal.sym(Nat, U32.to_nat(w), off, ew)), VG.digits_limb(w))
  %Equal.sym(+List<U32>, N.digits(4n, off), I.limb(w), dl) : {List.append(&2, U32, _, Layout.fixed_parts(r, Nat.add(off, List.length(&2, U32, y)))) == List.append(&2, U32, I.limb(w), R) : +List<U32>}
  Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, I.limb(w), z), Layout.fixed_parts(r, Nat.add(off, List.length(&2, U32, y))), R, e)

law bv_fix:
  for +xs: +List<U32>
  for +r: +List<S.Part>
  for +hx: {SP.bytes_domain(xs) == True{} : Bool}
  for +hr: {Layout.bytes_valid(r) == True{} : Bool}
  {Layout.bytes_valid(Con{S.Fixed{xs}, r}) == True{} : Bool}
def bv_fix(xs, r, hx, hr):
  %Equal.sym(Bool, SP.bytes_domain(xs), True{}, hx) : {Bool.and(_, Layout.bytes_valid(r)) == True{} : Bool}
  %Equal.sym(Bool, Layout.bytes_valid(r), True{}, hr) : {Bool.and(True{}, _) == True{} : Bool}
  {==}

law bv_var:
  for +y: +List<U32>
  for +r: +List<S.Part>
  for +hy: {SP.bytes_domain(y) == True{} : Bool}
  for +hr: {Layout.bytes_valid(r) == True{} : Bool}
  {Layout.bytes_valid(Con{S.Variable{y}, r}) == True{} : Bool}
def bv_var(y, r, hy, hr):
  %Equal.sym(Bool, SP.bytes_domain(y), True{}, hy) : {Bool.and(_, Layout.bytes_valid(r)) == True{} : Bool}
  %Equal.sym(Bool, Layout.bytes_valid(r), True{}, hr) : {Bool.and(True{}, _) == True{} : Bool}
  {==}

law fs_fix:
  for +xs: +List<U32>
  for +r: +List<S.Part>
  for +s: Nat
  for +k: Nat
  for +hl: {List.length(&2, U32, xs) == s : Nat}
  for +hr: {Layout.fixed_size(r) == k : Nat}
  {Layout.fixed_size(Con{S.Fixed{xs}, r}) == Nat.add(s, k) : Nat}
def fs_fix(xs, r, s, k, hl, hr):
  %Equal.sym(Nat, List.length(&2, U32, xs), s, hl) : {Nat.add(_, Layout.fixed_size(r)) == Nat.add(s, k) : Nat}
  Equal.cong(Nat, Nat, z => Nat.add(s, z), Layout.fixed_size(r), k, hr)

law fs_var:
  for +y: +List<U32>
  for +r: +List<S.Part>
  for +k: Nat
  for +hr: {Layout.fixed_size(r) == k : Nat}
  {Layout.fixed_size(Con{S.Variable{y}, r}) == Nat.add(4n, k) : Nat}
def fs_var(y, r, k, hr):
  Equal.cong(Nat, Nat, z => Nat.add(4n, z), Layout.fixed_size(r), k, hr)

# The fixed section has the parts' fixed size.
law fp_len:
  for +ps: +List<S.Part>
  for +off: Nat
  {List.length(&2, U32, Layout.fixed_parts(ps, off)) == Layout.fixed_size(ps) : Nat}
def fp_len(ps, off):
  match ps:
    case Nil{}: {==}
    case Con{S.Fixed{+xs}, +r}:
      %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, xs, Layout.fixed_parts(r, off))), Nat.add(List.length(&2, U32, xs), List.length(&2, U32, Layout.fixed_parts(r, off))), VS.len_app(xs, Layout.fixed_parts(r, off))) :
        {_ == Nat.add(List.length(&2, U32, xs), Layout.fixed_size(r)) : Nat}
      Equal.cong(Nat, Nat, z => Nat.add(List.length(&2, U32, xs), z), List.length(&2, U32, Layout.fixed_parts(r, off)), Layout.fixed_size(r), fp_len(r, off))
    case Con{S.Variable{+y}, +r}:
      +o2 = Nat.add(off, List.length(&2, U32, y))
      %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, N.digits(4n, off), Layout.fixed_parts(r, o2))), Nat.add(List.length(&2, U32, N.digits(4n, off)), List.length(&2, U32, Layout.fixed_parts(r, o2))), VS.len_app(N.digits(4n, off), Layout.fixed_parts(r, o2))) :
        {_ == Nat.add(4n, Layout.fixed_size(r)) : Nat}
      Equal.cong(Nat, Nat, z => Nat.add(4n, z), List.length(&2, U32, Layout.fixed_parts(r, o2)), Layout.fixed_size(r), fp_len(r, o2))

# Skipping a piece of s bytes.
law bdr_skip:
  for +xs: +List<U32>
  for +s: Nat
  for +k: Nat
  for +R: +List<U32>
  for +hl: {List.length(&2, U32, xs) == s : Nat}
  {VS.bdr(Nat.add(s, k), List.append(&2, U32, xs, R)) == VS.bdr(k, R) : +List<U32>}
def bdr_skip(xs, s, k, R, hl):
  %hl : {VS.bdr(Nat.add(_, k), List.append(&2, U32, xs, R)) == VS.bdr(k, R) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(Nat.add(List.length(&2, U32, xs), k), List.append(&2, U32, xs, R)), VS.bdr(k, VS.bdr(List.length(&2, U32, xs), List.append(&2, U32, xs, R))), VN.bdr_add(List.length(&2, U32, xs), k, List.append(&2, U32, xs, R))) : {_ == VS.bdr(k, R) : +List<U32>}
  Equal.cong(+List<U32>, +List<U32>, z => VS.bdr(k, z), VS.bdr(List.length(&2, U32, xs), List.append(&2, U32, xs, R)), R, VS.bdr_app(xs, R))

# The parts of a list value are at most one variable part.
def rq_single(+b: Bool, +m: Maybe<&2, +List<S.Part>>) -> DF.single_result(None{}, Codec.require(b, Codec.aggregate(m, None{}))):
  match b:
    case False{}: Unit{}
    case True{}: UW.vs_agg(m)

law lsingle:
  for +s: S.Schema
  for +n: Nat
  for +h: S.Value
  DF.single_result(None{}, Codec.parts(h, S.ListOf{s, n}))
def lsingle(s, n, h):
  match h:
    case S.Sequence{+items}: rq_single(Nat.is_le(Codec.count(items), n), Codec.parts(items, S.Repeat{s}))
    case S.BooleanValue{+b0}: Unit{}
    case S.UnsignedValue{+u0}: Unit{}
    case S.BytesValue{+xs0}: Unit{}
    case S.BitsValue{+bs0}: Unit{}
    case S.Items{+hd0, +tl0}: Unit{}
    case S.EmptyItems{}: Unit{}
    case S.Selected{+sel0, +sv0}: Unit{}
    case S.NullValue{}: Unit{}
