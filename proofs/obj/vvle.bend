import Base
import ../../spec/nat_bytes.bend as N
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ../../proofs/nat_bytes.bend as Digits
import ./vspec.bend as VS
import ./vrej.bend as VR
import ./vvl.bend as VVL
import ./vuw.bend as UW

# The encoder of a list of variable-size elements, byte side (hand-written): the bytes of
# the list's region while the runtime's writer (offset j, then element j, for j = 0 .. n-1)
# runs, as a list of bytes EI(P, R, off, Z) with P the elements already written and R
# those still to write: the offsets of P, zeros for those of R, the bytes of P, Z zeros.
# Each write is a UW.SPL splice (the byte model of the runtime's writers, proofs/obj/vuw.bend).

def APP(+a: +List<U32>, +b: +List<U32>) -> +List<U32>: List.append(&2, U32, a, b)
def LEN(+a: +List<U32>) -> Nat: List.length(&2, U32, a)
def LAPP(+a: +List<+List<U32>>, +b: +List<+List<U32>>) -> +List<+List<U32>>: List.append(&2, +List<U32>, a, b)

# ---- lists -------------------------------------------------------------------------------------

law bt_app:
  for +a: +List<U32>
  for +b: +List<U32>
  {VS.bt(LEN(a), APP(a, b)) == a : +List<U32>}
def bt_app(a, b):
  match a:
    case Nil{}: {==}
    case Con{+x, +t}: Equal.cong(+List<U32>, +List<U32>, z => Con{x, z}, VS.bt(LEN(t), APP(t, b)), t, bt_app(t, b))

law bdr_app:
  for +a: +List<U32>
  for +k: Nat
  for +b: +List<U32>
  {VS.bdr(Nat.add(LEN(a), k), APP(a, b)) == VS.bdr(k, b) : +List<U32>}
def bdr_app(a, k, b):
  match a:
    case Nil{}: {==}
    case Con{+x, +t}: bdr_app(t, k, b)

# Writing Y right after a: a, then Y, then b past |Y|.
law spl_mid:
  for +a: +List<U32>
  for +b: +List<U32>
  for +y: +List<U32>
  {UW.SPL(APP(a, b), LEN(a), y) == APP(a, APP(y, VS.bdr(LEN(y), b))) : +List<U32>}
def spl_mid(a, b, y):
  %Equal.sym(+List<U32>, VS.bt(LEN(a), APP(a, b)), a, bt_app(a, b)) :
    {APP(_, APP(y, VS.bdr(Nat.add(LEN(a), LEN(y)), APP(a, b)))) == APP(a, APP(y, VS.bdr(LEN(y), b))) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(Nat.add(LEN(a), LEN(y)), APP(a, b)), VS.bdr(LEN(y), b), bdr_app(a, LEN(y), b)) :
    {APP(a, APP(y, _)) == APP(a, APP(y, VS.bdr(LEN(y), b))) : +List<U32>}
  {==}

law zb_add:
  for +a: Nat
  for +b: Nat
  {UW.ZB(Nat.add(a, b)) == APP(UW.ZB(a), UW.ZB(b)) : +List<U32>}
def zb_add(a, b):
  match a:
    case 0n: {==}
    case 1n+ +p: Equal.cong(+List<U32>, +List<U32>, z => Con{0, z}, UW.ZB(Nat.add(p, b)), APP(UW.ZB(p), UW.ZB(b)), zb_add(p, b))

# Dropping m bytes of m + k zeros and a tail.
law bdr_zb:
  for +m: Nat
  for +k: Nat
  for +c: +List<U32>
  {VS.bdr(m, APP(UW.ZB(Nat.add(m, k)), c)) == APP(UW.ZB(k), c) : +List<U32>}
def bdr_zb(m, k, c):
  match m:
    case 0n: {==}
    case 1n+ +p: bdr_zb(p, k, c)

law len_zb:
  for +n: Nat
  {LEN(UW.ZB(n)) == n : Nat}
def len_zb(n):
  match n:
    case 0n: {==}
    case 1n+ +p: Equal.cong(Nat, Nat, z => 1n+z, LEN(UW.ZB(p)), p, len_zb(p))

# ---- lists of element byte lists ------------------------------------------------------------------

law bcat_app:
  for +p: +List<+List<U32>>
  for +r: +List<+List<U32>>
  {VR.bcat(LAPP(p, r)) == APP(VR.bcat(p), VR.bcat(r)) : +List<U32>}
def bcat_app(p, r):
  match p:
    case Nil{}: {==}
    case Con{+y, +t}:
      %Equal.sym(+List<U32>, VR.bcat(LAPP(t, r)), APP(VR.bcat(t), VR.bcat(r)), bcat_app(t, r)) :
        {APP(y, _) == APP(APP(y, VR.bcat(t)), VR.bcat(r)) : +List<U32>}
      Equal.sym(+List<U32>, APP(APP(y, VR.bcat(t)), VR.bcat(r)), APP(y, APP(VR.bcat(t), VR.bcat(r))), VS.app_assoc(y, VR.bcat(t), VR.bcat(r)))

law cnt_app:
  for +p: +List<+List<U32>>
  for +r: +List<+List<U32>>
  {VVL.CNT(LAPP(p, r)) == Nat.add(VVL.CNT(p), VVL.CNT(r)) : Nat}
def cnt_app(p, r):
  match p:
    case Nil{}: {==}
    case Con{+y, +t}: Equal.cong(Nat, Nat, z => 1n+z, VVL.CNT(LAPP(t, r)), Nat.add(VVL.CNT(t), VVL.CNT(r)), cnt_app(t, r))

law offs_app:
  for +p: +List<+List<U32>>
  for +r: +List<+List<U32>>
  for +off: Nat
  {VVL.OFFS(LAPP(p, r), off) == APP(VVL.OFFS(p, off), VVL.OFFS(r, Nat.add(off, LEN(VR.bcat(p))))) : +List<U32>}
def offs_app(p, r, off):
  match p:
    case Nil{}:
      %Equal.sym(Nat, Nat.add(off, 0n), off, F.nat__add_zero(off)) : {VVL.OFFS(r, off) == VVL.OFFS(r, _) : +List<U32>}
      {==}
    case Con{+y, +t}:
      +o1 = Nat.add(off, LEN(y))
      %Equal.sym(+List<U32>, VVL.OFFS(LAPP(t, r), o1), APP(VVL.OFFS(t, o1), VVL.OFFS(r, Nat.add(o1, LEN(VR.bcat(t))))), offs_app(t, r, o1)) :
        {APP(N.digits(4n, off), _) == APP(APP(N.digits(4n, off), VVL.OFFS(t, o1)), VVL.OFFS(r, Nat.add(off, LEN(APP(y, VR.bcat(t)))))) : +List<U32>}
      %Equal.sym(Nat, LEN(APP(y, VR.bcat(t))), Nat.add(LEN(y), LEN(VR.bcat(t))), VS.len_app(y, VR.bcat(t))) :
        {APP(N.digits(4n, off), APP(VVL.OFFS(t, o1), VVL.OFFS(r, Nat.add(o1, LEN(VR.bcat(t)))))) == APP(APP(N.digits(4n, off), VVL.OFFS(t, o1)), VVL.OFFS(r, Nat.add(off, _))) : +List<U32>}
      %Equal.sym(Nat, Nat.add(Nat.add(off, LEN(y)), LEN(VR.bcat(t))), Nat.add(off, Nat.add(LEN(y), LEN(VR.bcat(t)))), F.nat__add_assoc(off, LEN(y), LEN(VR.bcat(t)))) :
        {APP(N.digits(4n, off), APP(VVL.OFFS(t, o1), VVL.OFFS(r, _))) == APP(APP(N.digits(4n, off), VVL.OFFS(t, o1)), VVL.OFFS(r, Nat.add(off, Nat.add(LEN(y), LEN(VR.bcat(t)))))) : +List<U32>}
      Equal.sym(+List<U32>, APP(APP(N.digits(4n, off), VVL.OFFS(t, o1)), VVL.OFFS(r, Nat.add(off, Nat.add(LEN(y), LEN(VR.bcat(t)))))),
        APP(N.digits(4n, off), APP(VVL.OFFS(t, o1), VVL.OFFS(r, Nat.add(off, Nat.add(LEN(y), LEN(VR.bcat(t))))))),
        VS.app_assoc(N.digits(4n, off), VVL.OFFS(t, o1), VVL.OFFS(r, Nat.add(off, Nat.add(LEN(y), LEN(VR.bcat(t)))))))

# The offsets of p then y: those of p, then y's (after p's bytes).
def offs_snoc(+p: +List<+List<U32>>, +y: +List<U32>, +off: Nat)
    -> {VVL.OFFS(LAPP(p, [y]), off) == APP(VVL.OFFS(p, off), N.digits(4n, Nat.add(off, LEN(VR.bcat(p))))) : +List<U32>}:
  %Equal.sym(+List<U32>, VVL.OFFS(LAPP(p, [y]), off), APP(VVL.OFFS(p, off), VVL.OFFS([y], Nat.add(off, LEN(VR.bcat(p))))), offs_app(p, [y], off)) :
    {_ == APP(VVL.OFFS(p, off), N.digits(4n, Nat.add(off, LEN(VR.bcat(p))))) : +List<U32>}
  Equal.cong(+List<U32>, +List<U32>, z => APP(VVL.OFFS(p, off), z), APP(N.digits(4n, Nat.add(off, LEN(VR.bcat(p)))), []), N.digits(4n, Nat.add(off, LEN(VR.bcat(p)))),
    VS.app_nil(N.digits(4n, Nat.add(off, LEN(VR.bcat(p))))))

def bcat_snoc(+p: +List<+List<U32>>, +y: +List<U32>) -> {VR.bcat(LAPP(p, [y])) == APP(VR.bcat(p), y) : +List<U32>}:
  %Equal.sym(+List<U32>, VR.bcat(LAPP(p, [y])), APP(VR.bcat(p), VR.bcat([y])), bcat_app(p, [y])) : {_ == APP(VR.bcat(p), y) : +List<U32>}
  Equal.cong(+List<U32>, +List<U32>, z => APP(VR.bcat(p), z), APP(y, []), y, VS.app_nil(y))

def cnt_snoc(+p: +List<+List<U32>>, +y: +List<U32>) -> {VVL.CNT(LAPP(p, [y])) == Nat.add(VVL.CNT(p), 1n) : Nat}: cnt_app(p, [y])

# ---- the region's bytes during the write -----------------------------------------------------------

# Before element y's offset is written: P's offsets, zeros for the offsets of y and R,
# P's bytes, Z zeros.
def EI(+p: +List<+List<U32>>, +r: +List<+List<U32>>, +off: Nat, +z: Nat) -> +List<U32>:
  APP(VVL.OFFS(p, off), APP(UW.ZB(A.quad(VVL.CNT(r))), APP(VR.bcat(p), UW.ZB(z))))

# After y's offset, before y's bytes.
def EJ(+p: +List<+List<U32>>, +y: +List<U32>, +r: +List<+List<U32>>, +off: Nat, +z: Nat) -> +List<U32>:
  APP(VVL.OFFS(LAPP(p, [y]), off), APP(UW.ZB(A.quad(VVL.CNT(r))), APP(VR.bcat(p), UW.ZB(z))))

# The offset write: the four digits of off + |P's bytes| at 4 |P|.
law off_step:
  for +p: +List<+List<U32>>
  for +y: +List<U32>
  for +r: +List<+List<U32>>
  for +off: Nat
  for +z: Nat
  {UW.SPL(EI(p, Con{y, r}, off, z), A.quad(VVL.CNT(p)), N.digits(4n, Nat.add(off, LEN(VR.bcat(p))))) == EJ(p, y, r, off, z) : +List<U32>}
def off_step(p, y, r, off, z):
  +O = VVL.OFFS(p, off)
  +D = N.digits(4n, Nat.add(off, LEN(VR.bcat(p))))
  +B = APP(UW.ZB(A.quad(VVL.CNT(r))), APP(VR.bcat(p), UW.ZB(z)))
  %VVL.len_offs(p, off) : {UW.SPL(APP(O, APP(UW.ZB(4n), B)), _, D) == EJ(p, y, r, off, z) : +List<U32>}
  %Equal.sym(+List<U32>, UW.SPL(APP(O, APP(UW.ZB(4n), B)), LEN(O), D), APP(O, APP(D, VS.bdr(LEN(D), APP(UW.ZB(4n), B)))), spl_mid(O, APP(UW.ZB(4n), B), D)) :
    {_ == EJ(p, y, r, off, z) : +List<U32>}
  %Equal.sym(Nat, LEN(D), 4n, Digits.digits_length(4n, Nat.add(off, LEN(VR.bcat(p))))) :
    {APP(O, APP(D, VS.bdr(_, APP(UW.ZB(4n), B)))) == EJ(p, y, r, off, z) : +List<U32>}
  %Equal.sym(+List<U32>, VVL.OFFS(LAPP(p, [y]), off), APP(O, D), offs_snoc(p, y, off)) :
    {APP(O, APP(D, B)) == APP(_, B) : +List<U32>}
  Equal.sym(+List<U32>, APP(APP(O, D), B), APP(O, APP(D, B)), VS.app_assoc(O, D, B))

law bdr_zb0:
  for +m: Nat
  for +k: Nat
  {VS.bdr(m, UW.ZB(Nat.add(m, k))) == UW.ZB(k) : +List<U32>}
def bdr_zb0(m, k):
  match m:
    case 0n: {==}
    case 1n+ +p: bdr_zb0(p, k)

# Writing y and pad zeros onto zeros after a prefix.
def tail_step(+pre: +List<U32>, +y: +List<U32>, +zr: Nat, +pad: Nat, +hp: {Nat.is_le(pad, zr) == True{} : Bool})
    -> {UW.SPL(APP(pre, UW.ZB(Nat.add(LEN(y), zr))), LEN(pre), APP(y, UW.ZB(pad))) == APP(pre, APP(y, UW.ZB(zr))) : +List<U32>}:
  +Y = APP(y, UW.ZB(pad))
  +k = Nat.sub(zr, pad)
  +ez = F.nat__sub_add(zr, pad, hp)
  +eY = Equal.trans(Nat, LEN(Y), Nat.add(LEN(y), LEN(UW.ZB(pad))), Nat.add(LEN(y), pad), VS.len_app(y, UW.ZB(pad)),
    Equal.cong(Nat, Nat, q => Nat.add(LEN(y), q), LEN(UW.ZB(pad)), pad, len_zb(pad)))
  +eZ = Equal.trans(Nat, Nat.add(LEN(y), zr), Nat.add(LEN(y), Nat.add(pad, k)), Nat.add(Nat.add(LEN(y), pad), k),
    Equal.cong(Nat, Nat, q => Nat.add(LEN(y), q), zr, Nat.add(pad, k), Equal.sym(Nat, Nat.add(pad, k), zr, ez)),
    Equal.sym(Nat, Nat.add(Nat.add(LEN(y), pad), k), Nat.add(LEN(y), Nat.add(pad, k)), F.nat__add_assoc(LEN(y), pad, k)))
  %Equal.sym(+List<U32>, UW.SPL(APP(pre, UW.ZB(Nat.add(LEN(y), zr))), LEN(pre), Y), APP(pre, APP(Y, VS.bdr(LEN(Y), UW.ZB(Nat.add(LEN(y), zr))))), spl_mid(pre, UW.ZB(Nat.add(LEN(y), zr)), Y)) :
    {_ == APP(pre, APP(y, UW.ZB(zr))) : +List<U32>}
  %Equal.sym(Nat, LEN(Y), Nat.add(LEN(y), pad), eY) : {APP(pre, APP(Y, VS.bdr(_, UW.ZB(Nat.add(LEN(y), zr))))) == APP(pre, APP(y, UW.ZB(zr))) : +List<U32>}
  %Equal.sym(Nat, Nat.add(LEN(y), zr), Nat.add(Nat.add(LEN(y), pad), k), eZ) : {APP(pre, APP(Y, VS.bdr(Nat.add(LEN(y), pad), UW.ZB(_)))) == APP(pre, APP(y, UW.ZB(zr))) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(Nat.add(LEN(y), pad), UW.ZB(Nat.add(Nat.add(LEN(y), pad), k))), UW.ZB(k), bdr_zb0(Nat.add(LEN(y), pad), k)) :
    {APP(pre, APP(Y, _)) == APP(pre, APP(y, UW.ZB(zr))) : +List<U32>}
  %Equal.sym(+List<U32>, APP(APP(y, UW.ZB(pad)), UW.ZB(k)), APP(y, APP(UW.ZB(pad), UW.ZB(k))), VS.app_assoc(y, UW.ZB(pad), UW.ZB(k))) :
    {APP(pre, _) == APP(pre, APP(y, UW.ZB(zr))) : +List<U32>}
  %Equal.sym(+List<U32>, APP(UW.ZB(pad), UW.ZB(k)), UW.ZB(Nat.add(pad, k)), Equal.sym(+List<U32>, UW.ZB(Nat.add(pad, k)), APP(UW.ZB(pad), UW.ZB(k)), zb_add(pad, k))) :
    {APP(pre, APP(y, _)) == APP(pre, APP(y, UW.ZB(zr))) : +List<U32>}
  %Equal.sym(Nat, Nat.add(pad, k), zr, ez) : {APP(pre, APP(y, UW.ZB(_))) == APP(pre, APP(y, UW.ZB(zr))) : +List<U32>}
  {==}

# The prefix before y's bytes in EJ.
def PJ(+p: +List<+List<U32>>, +y: +List<U32>, +r: +List<+List<U32>>, +off: Nat) -> +List<U32>:
  APP(VVL.OFFS(LAPP(p, [y]), off), APP(UW.ZB(A.quad(VVL.CNT(r))), VR.bcat(p)))

def ej_pj(+p: +List<+List<U32>>, +y: +List<U32>, +r: +List<+List<U32>>, +off: Nat, +z: Nat)
    -> {EJ(p, y, r, off, z) == APP(PJ(p, y, r, off), UW.ZB(z)) : +List<U32>}:
  +O = VVL.OFFS(LAPP(p, [y]), off)
  +Z4 = UW.ZB(A.quad(VVL.CNT(r)))
  +bp = VR.bcat(p)
  Equal.trans(+List<U32>, APP(O, APP(Z4, APP(bp, UW.ZB(z)))), APP(O, APP(APP(Z4, bp), UW.ZB(z))), APP(APP(O, APP(Z4, bp)), UW.ZB(z)),
    Equal.cong(+List<U32>, +List<U32>, q => APP(O, q), APP(Z4, APP(bp, UW.ZB(z))), APP(APP(Z4, bp), UW.ZB(z)), Equal.sym(+List<U32>, APP(APP(Z4, bp), UW.ZB(z)), APP(Z4, APP(bp, UW.ZB(z))), VS.app_assoc(Z4, bp, UW.ZB(z)))),
    Equal.sym(+List<U32>, APP(APP(O, APP(Z4, bp)), UW.ZB(z)), APP(O, APP(APP(Z4, bp), UW.ZB(z))), VS.app_assoc(O, APP(Z4, bp), UW.ZB(z))))

# The element write: y (with pad zeros) after P's bytes.
def el_step(+p: +List<+List<U32>>, +y: +List<U32>, +r: +List<+List<U32>>, +off: Nat, +zr: Nat, +pad: Nat, +hp: {Nat.is_le(pad, zr) == True{} : Bool})
    -> {UW.SPL(EJ(p, y, r, off, Nat.add(LEN(y), zr)), LEN(PJ(p, y, r, off)), APP(y, UW.ZB(pad))) == EI(LAPP(p, [y]), r, off, zr) : +List<U32>}:
  +O = VVL.OFFS(LAPP(p, [y]), off)
  +Z4 = UW.ZB(A.quad(VVL.CNT(r)))
  +bp = VR.bcat(p)
  %Equal.sym(+List<U32>, EJ(p, y, r, off, Nat.add(LEN(y), zr)), APP(PJ(p, y, r, off), UW.ZB(Nat.add(LEN(y), zr))), ej_pj(p, y, r, off, Nat.add(LEN(y), zr))) :
    {UW.SPL(_, LEN(PJ(p, y, r, off)), APP(y, UW.ZB(pad))) == EI(LAPP(p, [y]), r, off, zr) : +List<U32>}
  %Equal.sym(+List<U32>, UW.SPL(APP(PJ(p, y, r, off), UW.ZB(Nat.add(LEN(y), zr))), LEN(PJ(p, y, r, off)), APP(y, UW.ZB(pad))), APP(PJ(p, y, r, off), APP(y, UW.ZB(zr))),
      tail_step(PJ(p, y, r, off), y, zr, pad, hp)) :
    {_ == EI(LAPP(p, [y]), r, off, zr) : +List<U32>}
  %Equal.sym(+List<U32>, VR.bcat(LAPP(p, [y])), APP(bp, y), bcat_snoc(p, y)) :
    {APP(APP(O, APP(Z4, bp)), APP(y, UW.ZB(zr))) == APP(O, APP(Z4, APP(_, UW.ZB(zr)))) : +List<U32>}
  %Equal.sym(+List<U32>, APP(APP(O, APP(Z4, bp)), APP(y, UW.ZB(zr))), APP(O, APP(APP(Z4, bp), APP(y, UW.ZB(zr)))), VS.app_assoc(O, APP(Z4, bp), APP(y, UW.ZB(zr)))) :
    {_ == APP(O, APP(Z4, APP(APP(bp, y), UW.ZB(zr)))) : +List<U32>}
  %Equal.sym(+List<U32>, APP(APP(Z4, bp), APP(y, UW.ZB(zr))), APP(Z4, APP(bp, APP(y, UW.ZB(zr)))), VS.app_assoc(Z4, bp, APP(y, UW.ZB(zr)))) :
    {APP(O, _) == APP(O, APP(Z4, APP(APP(bp, y), UW.ZB(zr)))) : +List<U32>}
  %Equal.sym(+List<U32>, APP(APP(bp, y), UW.ZB(zr)), APP(bp, APP(y, UW.ZB(zr))), VS.app_assoc(bp, y, UW.ZB(zr))) :
    {APP(O, APP(Z4, APP(bp, APP(y, UW.ZB(zr))))) == APP(O, APP(Z4, _)) : +List<U32>}
  {==}
