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
import ./vbuf.bend as VB
import ./vfix.bend as VF
import ./vcopy.bend as VC
import ./vlist.bend as VL
import ./vdig.bend as VG

# GENERATED from vmv.bend.in by multi_variable_field_codec_laws (codegen). Do not edit.
# The offset layout of a container with THREE variable fields (spec/layout.bend),
# and the window of a decoded list's storage. Everything is stated over word lists
# and symbolic sizes; no closed large number is evaluated.

# ---- Layout.encoding from its pieces ---------------------------------------------------------

law enc_gen:
  for +ps: +List<S.Part>
  for +FS: Nat
  for +FP: +List<U32>
  for +PAY: +List<U32>
  for +hs: {Layout.fixed_size(ps) == FS : Nat}
  for +hf: {Layout.fixed_parts(ps, FS) == FP : +List<U32>}
  for +hp: {Layout.payloads(ps) == PAY : +List<U32>}
  for +hv: {Layout.bytes_valid(ps) == True{} : Bool}
  for +fit: {N.fits(4n, Nat.add(FS, List.length(&2, U32, PAY))) == True{} : Bool}
  {Layout.encoding(ps) == Some{List.append(&2, U32, FP, PAY)} : Maybe<&2, +List<U32>>}
def enc_gen(ps, FS, FP, PAY, hs, hf, hp, hv, fit):
  %Equal.sym(Nat, Layout.fixed_size(ps), FS, hs) :
    {SP.optional(Bool.and(Layout.bytes_valid(ps), N.fits(4n, Nat.add(_, List.length(&2, U32, Layout.payloads(ps))))), List.append(&2, U32, Layout.fixed_parts(ps, _), Layout.payloads(ps))) == Some{List.append(&2, U32, FP, PAY)} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, Layout.payloads(ps), PAY, hp) :
    {SP.optional(Bool.and(Layout.bytes_valid(ps), N.fits(4n, Nat.add(FS, List.length(&2, U32, _)))), List.append(&2, U32, Layout.fixed_parts(ps, FS), _)) == Some{List.append(&2, U32, FP, PAY)} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, Layout.fixed_parts(ps, FS), FP, hf) :
    {SP.optional(Bool.and(Layout.bytes_valid(ps), N.fits(4n, Nat.add(FS, List.length(&2, U32, PAY)))), List.append(&2, U32, _, PAY)) == Some{List.append(&2, U32, FP, PAY)} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, Layout.bytes_valid(ps), True{}, hv) :
    {SP.optional(Bool.and(_, N.fits(4n, Nat.add(FS, List.length(&2, U32, PAY)))), List.append(&2, U32, FP, PAY)) == Some{List.append(&2, U32, FP, PAY)} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, N.fits(4n, Nat.add(FS, List.length(&2, U32, PAY))), True{}, fit) :
    {SP.optional(Bool.and(True{}, _), List.append(&2, U32, FP, PAY)) == Some{List.append(&2, U32, FP, PAY)} : Maybe<&2, +List<U32>>}
  {==}

# ---- one fixed part, three variable parts, then fixed parts ------------------------------------

def P3(+A: +List<U32>, +Y0: +List<U32>, +Y1: +List<U32>, +Y2: +List<U32>, +post: +List<+List<U32>>) -> +List<S.Part>:
  Con{S.Fixed{FX.limbs(A)}, Con{S.Variable{Y0}, Con{S.Variable{Y1}, Con{S.Variable{Y2}, FX.fparts(post)}}}}

def F3(+A: +List<U32>, +post: +List<+List<U32>>) -> Nat:
  Nat.add(List.length(&2, U32, FX.limbs(A)), 12n+List.length(&2, U32, FX.flat(post)))

law p3_size:
  for +A: +List<U32>
  for +Y0: +List<U32>
  for +Y1: +List<U32>
  for +Y2: +List<U32>
  for +post: +List<+List<U32>>
  {Layout.fixed_size(P3(A, Y0, Y1, Y2, post)) == F3(A, post) : Nat}
def p3_size(A, Y0, Y1, Y2, post):
  %Equal.sym(Nat, Layout.fixed_size(FX.fparts(post)), List.length(&2, U32, FX.flat(post)), VS.fixed_size_fparts(post)) :
    {Nat.add(List.length(&2, U32, FX.limbs(A)), Nat.add(4n, Nat.add(4n, Nat.add(4n, _)))) == F3(A, post) : Nat}
  {==}

law p3_pay:
  for +A: +List<U32>
  for +Y0: +List<U32>
  for +Y1: +List<U32>
  for +Y2: +List<U32>
  for +post: +List<+List<U32>>
  {Layout.payloads(P3(A, Y0, Y1, Y2, post)) == List.append(&2, U32, Y0, List.append(&2, U32, Y1, Y2)) : +List<U32>}
def p3_pay(A, Y0, Y1, Y2, post):
  %Equal.sym(+List<U32>, Layout.payloads(FX.fparts(post)), [], VS.payloads_fparts(post)) :
    {List.append(&2, U32, Y0, List.append(&2, U32, Y1, List.append(&2, U32, Y2, _))) == List.append(&2, U32, Y0, List.append(&2, U32, Y1, Y2)) : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, Y2, []), Y2, VS.app_nil(Y2)) :
    {List.append(&2, U32, Y0, List.append(&2, U32, Y1, _)) == List.append(&2, U32, Y0, List.append(&2, U32, Y1, Y2)) : +List<U32>}
  {==}

# The fixed section: A's bytes, the three offsets (the words o0, o1, o2), post's bytes.
law p3_fp:
  for +A: +List<U32>
  for +Y0: +List<U32>
  for +Y1: +List<U32>
  for +Y2: +List<U32>
  for +post: +List<+List<U32>>
  for +off: Nat
  for +o0: U32
  for +o1: U32
  for +o2: U32
  for +e0: {U32.to_nat(o0) == off : Nat}
  for +e1: {U32.to_nat(o1) == Nat.add(off, List.length(&2, U32, Y0)) : Nat}
  for +e2: {U32.to_nat(o2) == Nat.add(Nat.add(off, List.length(&2, U32, Y0)), List.length(&2, U32, Y1)) : Nat}
  {Layout.fixed_parts(P3(A, Y0, Y1, Y2, post), off) == List.append(&2, U32, FX.limbs(A), List.append(&2, U32, FX.limbs([o0, o1, o2]), FX.flat(post))) : +List<U32>}
def p3_fp(A, Y0, Y1, Y2, post, off, o0, o1, o2, e0, e1, e2):
  +X1 = Nat.add(off, List.length(&2, U32, Y0))
  +X2 = Nat.add(Nat.add(off, List.length(&2, U32, Y0)), List.length(&2, U32, Y1))
  +X3 = Nat.add(Nat.add(Nat.add(off, List.length(&2, U32, Y0)), List.length(&2, U32, Y1)), List.length(&2, U32, Y2))
  +R = List.append(&2, U32, FX.limbs(A), List.append(&2, U32, FX.limbs([o0, o1, o2]), FX.flat(post)))
  %Equal.sym(+List<U32>, Layout.fixed_parts(FX.fparts(post), X3), FX.flat(post), VS.fixed_parts_fparts(post, X3)) :
    {List.append(&2, U32, FX.limbs(A), List.append(&2, U32, N.digits(4n, off), List.append(&2, U32, N.digits(4n, X1), List.append(&2, U32, N.digits(4n, X2), _)))) == R : +List<U32>}
  %e0 :
    {List.append(&2, U32, FX.limbs(A), List.append(&2, U32, N.digits(4n, _), List.append(&2, U32, N.digits(4n, X1), List.append(&2, U32, N.digits(4n, X2), FX.flat(post))))) == R : +List<U32>}
  %e1 :
    {List.append(&2, U32, FX.limbs(A), List.append(&2, U32, N.digits(4n, U32.to_nat(o0)), List.append(&2, U32, N.digits(4n, _), List.append(&2, U32, N.digits(4n, X2), FX.flat(post))))) == R : +List<U32>}
  %e2 :
    {List.append(&2, U32, FX.limbs(A), List.append(&2, U32, N.digits(4n, U32.to_nat(o0)), List.append(&2, U32, N.digits(4n, U32.to_nat(o1)), List.append(&2, U32, N.digits(4n, _), FX.flat(post))))) == R : +List<U32>}
  %Equal.sym(+List<U32>, N.digits(4n, U32.to_nat(o0)), I.limb(o0), VG.digits_limb(o0)) :
    {List.append(&2, U32, FX.limbs(A), List.append(&2, U32, _, List.append(&2, U32, N.digits(4n, U32.to_nat(o1)), List.append(&2, U32, N.digits(4n, U32.to_nat(o2)), FX.flat(post))))) == R : +List<U32>}
  %Equal.sym(+List<U32>, N.digits(4n, U32.to_nat(o1)), I.limb(o1), VG.digits_limb(o1)) :
    {List.append(&2, U32, FX.limbs(A), List.append(&2, U32, I.limb(o0), List.append(&2, U32, _, List.append(&2, U32, N.digits(4n, U32.to_nat(o2)), FX.flat(post))))) == R : +List<U32>}
  %Equal.sym(+List<U32>, N.digits(4n, U32.to_nat(o2)), I.limb(o2), VG.digits_limb(o2)) :
    {List.append(&2, U32, FX.limbs(A), List.append(&2, U32, I.limb(o0), List.append(&2, U32, I.limb(o1), List.append(&2, U32, _, FX.flat(post))))) == R : +List<U32>}
  {==}

law p3_valid:
  for +A: +List<U32>
  for +Z0: +List<U32>
  for +Z1: +List<U32>
  for +Z2: +List<U32>
  for +post: +List<+List<U32>>
  {Layout.bytes_valid(P3(A, FX.limbs(Z0), FX.limbs(Z1), FX.limbs(Z2), post)) == True{} : Bool}
def p3_valid(A, Z0, Z1, Z2, post):
  +r2 = V.and_true(SP.bytes_domain(FX.limbs(Z2)), Layout.bytes_valid(FX.fparts(post)), FX.domain_limbs(Z2), FX.valid_fparts(post))
  +r1 = V.and_true(SP.bytes_domain(FX.limbs(Z1)), Layout.bytes_valid(Con{S.Variable{FX.limbs(Z2)}, FX.fparts(post)}), FX.domain_limbs(Z1), r2)
  +r0 = V.and_true(SP.bytes_domain(FX.limbs(Z0)), Layout.bytes_valid(Con{S.Variable{FX.limbs(Z1)}, Con{S.Variable{FX.limbs(Z2)}, FX.fparts(post)}}), FX.domain_limbs(Z0), r1)
  V.and_true(SP.bytes_domain(FX.limbs(A)), Layout.bytes_valid(Con{S.Variable{FX.limbs(Z0)}, Con{S.Variable{FX.limbs(Z1)}, Con{S.Variable{FX.limbs(Z2)}, FX.fparts(post)}}}), FX.domain_limbs(A), r0)

def fit3(+FS: Nat, +o2: U32, +Y0: +List<U32>, +Y1: +List<U32>, +Y2: +List<U32>,
    +e2: {U32.to_nat(o2) == Nat.add(Nat.add(FS, List.length(&2, U32, Y0)), List.length(&2, U32, Y1)) : Nat},
    +fit: {N.fits(4n, Nat.add(U32.to_nat(o2), List.length(&2, U32, Y2))) == True{} : Bool})
    -> {N.fits(4n, Nat.add(FS, List.length(&2, U32, List.append(&2, U32, Y0, List.append(&2, U32, Y1, Y2))))) == True{} : Bool}:
  +z0 = List.length(&2, U32, Y0)
  +z1 = List.length(&2, U32, Y1)
  +z2 = List.length(&2, U32, Y2)
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, Y0, List.append(&2, U32, Y1, Y2))), Nat.add(z0, List.length(&2, U32, List.append(&2, U32, Y1, Y2))), VS.len_app(Y0, List.append(&2, U32, Y1, Y2))) :
    {N.fits(4n, Nat.add(FS, _)) == True{} : Bool}
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, Y1, Y2)), Nat.add(z1, z2), VS.len_app(Y1, Y2)) :
    {N.fits(4n, Nat.add(FS, Nat.add(z0, _))) == True{} : Bool}
  %F.nat__add_assoc(FS, z0, Nat.add(z1, z2)) : {N.fits(4n, _) == True{} : Bool}
  %F.nat__add_assoc(Nat.add(FS, z0), z1, z2) : {N.fits(4n, _) == True{} : Bool}
  %e2 : {N.fits(4n, Nat.add(_, z2)) == True{} : Bool}
  fit

# The layout of [A | three variable parts | post]: the limbs of A, of the offset words,
# of post, then the three payloads, when the offset words hold the layout's offsets.
law enc3:
  for +A: +List<U32>
  for +Z0: +List<U32>
  for +Z1: +List<U32>
  for +Z2: +List<U32>
  for +post: +List<+List<U32>>
  for +o0: U32
  for +o1: U32
  for +o2: U32
  for +e0: {U32.to_nat(o0) == F3(A, post) : Nat}
  for +e1: {U32.to_nat(o1) == Nat.add(U32.to_nat(o0), List.length(&2, U32, FX.limbs(Z0))) : Nat}
  for +e2: {U32.to_nat(o2) == Nat.add(U32.to_nat(o1), List.length(&2, U32, FX.limbs(Z1))) : Nat}
  for +fit: {N.fits(4n, Nat.add(U32.to_nat(o2), List.length(&2, U32, FX.limbs(Z2)))) == True{} : Bool}
  {Layout.encoding(P3(A, FX.limbs(Z0), FX.limbs(Z1), FX.limbs(Z2), post)) == Some{List.append(&2, U32, List.append(&2, U32, FX.limbs(A), List.append(&2, U32, FX.limbs([o0, o1, o2]), FX.flat(post))), List.append(&2, U32, FX.limbs(Z0), List.append(&2, U32, FX.limbs(Z1), FX.limbs(Z2))))} : Maybe<&2, +List<U32>>}
def enc3(A, Z0, Z1, Z2, post, o0, o1, o2, e0, e1, e2, fit):
  +FS = F3(A, post)
  +z0 = List.length(&2, U32, FX.limbs(Z0))
  +z1 = List.length(&2, U32, FX.limbs(Z1))
  +e1b = Equal.trans(Nat, U32.to_nat(o1), Nat.add(U32.to_nat(o0), z0), Nat.add(FS, z0), e1, Equal.cong(Nat, Nat, z => Nat.add(z, z0), U32.to_nat(o0), FS, e0))
  +e2b = Equal.trans(Nat, U32.to_nat(o2), Nat.add(U32.to_nat(o1), z1), Nat.add(Nat.add(FS, z0), z1), e2, Equal.cong(Nat, Nat, z => Nat.add(z, z1), U32.to_nat(o1), Nat.add(FS, z0), e1b))
  +ps = P3(A, FX.limbs(Z0), FX.limbs(Z1), FX.limbs(Z2), post)
  enc_gen(ps, FS, List.append(&2, U32, FX.limbs(A), List.append(&2, U32, FX.limbs([o0, o1, o2]), FX.flat(post))),
    List.append(&2, U32, FX.limbs(Z0), List.append(&2, U32, FX.limbs(Z1), FX.limbs(Z2))),
    p3_size(A, FX.limbs(Z0), FX.limbs(Z1), FX.limbs(Z2), post),
    p3_fp(A, FX.limbs(Z0), FX.limbs(Z1), FX.limbs(Z2), post, FS, o0, o1, o2, e0, e1b, e2b),
    p3_pay(A, FX.limbs(Z0), FX.limbs(Z1), FX.limbs(Z2), post),
    p3_valid(A, Z0, Z1, Z2, post),
    fit3(FS, o2, FX.limbs(Z0), FX.limbs(Z1), FX.limbs(Z2), e2b, fit))

# ---- the window of a decoded list --------------------------------------------------------------

# The first m words of a list's storage (m = its word count, from word q of the buffer)
# are the buffer's words q .. q + m.
def win(+d: Nat, +t: F.array__Tree<U32>, +L: U32, +m: Nat, +q: Nat,
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hL: {Nat.is_le(U32.to_nat(L), A.quad(VB.pw(d))) == True{} : Bool}, +em: {U32.to_nat(L) == A.quad(m) : Nat},
    +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(VL.DZ(L))) == True{} : Bool},
    +hs: {Nat.is_le(Nat.add(VC.NW(L), q), VB.pw(d)) == True{} : Bool})
    -> {VS.wtake(m, F.array__slots(U32, VB.mone(VC.NW(L), q, 0n, VL.DZ(L), VC.ZT(VL.DZ(L)), t))) == VS.wtake(m, VB.wdr(q, F.array__slots(U32, t))) : List<&2, U32>}:
  +S = F.array__slots(U32, t)
  +Z = F.array__slots(U32, VC.ZT(VL.DZ(L)))
  %VL.nwm(d, L, m, hd, hL, em) :
    {VS.wtake(_, F.array__slots(U32, VB.mone(VC.NW(L), q, 0n, VL.DZ(L), VC.ZT(VL.DZ(L)), t))) == VS.wtake(_, VB.wdr(q, S)) : List<&2, U32>}
  %Equal.sym(List<&2, U32>, F.array__slots(U32, VB.mone(VC.NW(L), q, 0n, VL.DZ(L), VC.ZT(VL.DZ(L)), t)), VB.lm(VC.NW(L), q, 0n, Z, S),
      VB.slots_mone(VC.NW(L), q, 0n, VL.DZ(L), VC.ZT(VL.DZ(L)), t, F.array__trep_perfect(U32, VL.DZ(L), 0), hr)) :
    {VS.wtake(VC.NW(L), _) == VS.wtake(VC.NW(L), VB.wdr(q, S)) : List<&2, U32>}
  VB.lm_win(VC.NW(L), q, 0n, Z, S,
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(VC.NW(L), 0n), z) == True{} : Bool}, VB.pw(VL.DZ(L)), VB.len(Z),
      Equal.sym(Nat, VB.len(Z), VB.pw(VL.DZ(L)), F.array__slots_length(U32, VL.DZ(L), VC.ZT(VL.DZ(L)), F.array__trep_perfect(U32, VL.DZ(L), 0))), hr),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(VC.NW(L), q), z) == True{} : Bool}, VB.pw(d), VB.len(S),
      Equal.sym(Nat, VB.len(S), VB.pw(d), F.array__slots_length(U32, d, t, pf)), hs))

# m words of a list's storage lie in it: m <= its length.
def hl_st(+d: Nat, +t: F.array__Tree<U32>, +L: U32, +m: Nat, +q: Nat, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hL: {Nat.is_le(U32.to_nat(L), A.quad(VB.pw(d))) == True{} : Bool}, +em: {U32.to_nat(L) == A.quad(m) : Nat},
    +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(VL.DZ(L))) == True{} : Bool})
    -> {Nat.is_le(m, F.spec_common__length(U32, F.array__slots(U32, VB.mone(VC.NW(L), q, 0n, VL.DZ(L), VC.ZT(VL.DZ(L)), t)))) == True{} : Bool}:
  %Equal.sym(Nat, F.spec_common__length(U32, F.array__slots(U32, VB.mone(VC.NW(L), q, 0n, VL.DZ(L), VC.ZT(VL.DZ(L)), t))), VB.pw(VL.DZ(L)),
      F.array__slots_length(U32, VL.DZ(L), VB.mone(VC.NW(L), q, 0n, VL.DZ(L), VC.ZT(VL.DZ(L)), t),
        VB.mone_perfect(VC.NW(L), q, 0n, VL.DZ(L), VC.ZT(VL.DZ(L)), t, F.array__trep_perfect(U32, VL.DZ(L), 0)))) :
    {Nat.is_le(m, _) == True{} : Bool}
  %VL.nwm(d, L, m, hd, hL, em) : {Nat.is_le(_, VB.pw(VL.DZ(L))) == True{} : Bool}
  F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(VL.DZ(L))) == True{} : Bool}, Nat.add(VC.NW(L), 0n), VC.NW(L), F.nat__add_zero(VC.NW(L)), hr)

# ---- the same with no depth bound: the list length (VL.nwmA) bounds the storage ----

# The first m words of a list's storage (m = its word count, from word q of the buffer)
# are the buffer's words q .. q + m.
def winA(+d: Nat, +t: F.array__Tree<U32>, +L: U32, +m: Nat, +q: Nat,
    +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +em: {U32.to_nat(L) == A.quad(m) : Nat},
    +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(VL.DZ(L))) == True{} : Bool},
    +hs: {Nat.is_le(Nat.add(VC.NW(L), q), VB.pw(d)) == True{} : Bool})
    -> {VS.wtake(m, F.array__slots(U32, VB.mone(VC.NW(L), q, 0n, VL.DZ(L), VC.ZT(VL.DZ(L)), t))) == VS.wtake(m, VB.wdr(q, F.array__slots(U32, t))) : List<&2, U32>}:
  +S = F.array__slots(U32, t)
  +Z = F.array__slots(U32, VC.ZT(VL.DZ(L)))
  %VL.nwmA(L, m, em) :
    {VS.wtake(_, F.array__slots(U32, VB.mone(VC.NW(L), q, 0n, VL.DZ(L), VC.ZT(VL.DZ(L)), t))) == VS.wtake(_, VB.wdr(q, S)) : List<&2, U32>}
  %Equal.sym(List<&2, U32>, F.array__slots(U32, VB.mone(VC.NW(L), q, 0n, VL.DZ(L), VC.ZT(VL.DZ(L)), t)), VB.lm(VC.NW(L), q, 0n, Z, S),
      VB.slots_mone(VC.NW(L), q, 0n, VL.DZ(L), VC.ZT(VL.DZ(L)), t, F.array__trep_perfect(U32, VL.DZ(L), 0), hr)) :
    {VS.wtake(VC.NW(L), _) == VS.wtake(VC.NW(L), VB.wdr(q, S)) : List<&2, U32>}
  VB.lm_win(VC.NW(L), q, 0n, Z, S,
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(VC.NW(L), 0n), z) == True{} : Bool}, VB.pw(VL.DZ(L)), VB.len(Z),
      Equal.sym(Nat, VB.len(Z), VB.pw(VL.DZ(L)), F.array__slots_length(U32, VL.DZ(L), VC.ZT(VL.DZ(L)), F.array__trep_perfect(U32, VL.DZ(L), 0))), hr),
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(VC.NW(L), q), z) == True{} : Bool}, VB.pw(d), VB.len(S),
      Equal.sym(Nat, VB.len(S), VB.pw(d), F.array__slots_length(U32, d, t, pf)), hs))

# m words of a list's storage lie in it: m <= its length.
def hl_stA(+d: Nat, +t: F.array__Tree<U32>, +L: U32, +m: Nat, +q: Nat, +em: {U32.to_nat(L) == A.quad(m) : Nat},
    +hr: {Nat.is_le(Nat.add(VC.NW(L), 0n), VB.pw(VL.DZ(L))) == True{} : Bool})
    -> {Nat.is_le(m, F.spec_common__length(U32, F.array__slots(U32, VB.mone(VC.NW(L), q, 0n, VL.DZ(L), VC.ZT(VL.DZ(L)), t)))) == True{} : Bool}:
  %Equal.sym(Nat, F.spec_common__length(U32, F.array__slots(U32, VB.mone(VC.NW(L), q, 0n, VL.DZ(L), VC.ZT(VL.DZ(L)), t))), VB.pw(VL.DZ(L)),
      F.array__slots_length(U32, VL.DZ(L), VB.mone(VC.NW(L), q, 0n, VL.DZ(L), VC.ZT(VL.DZ(L)), t),
        VB.mone_perfect(VC.NW(L), q, 0n, VL.DZ(L), VC.ZT(VL.DZ(L)), t, F.array__trep_perfect(U32, VL.DZ(L), 0)))) :
    {Nat.is_le(m, _) == True{} : Bool}
  %VL.nwmA(L, m, em) : {Nat.is_le(_, VB.pw(VL.DZ(L))) == True{} : Bool}
  F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(VL.DZ(L))) == True{} : Bool}, Nat.add(VC.NW(L), 0n), VC.NW(L), F.nat__add_zero(VC.NW(L)), hr)
