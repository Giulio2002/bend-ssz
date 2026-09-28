import Base
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./vspec.bend as VS
import ./vuw.bend as UW
import ./vvle.bend as VE2
import ../compact/reads.bend as RD
import ./vbuf.bend as VB
import ./vcopy.bend as VC
import ./vfix.bend as VF
import ./vbspec.bend as VZ
import ./vuwd.bend as WD
import ./vrecx.bend as VRX
import ./spec_fixed.bend as FX
import ../../src/obj.bend as O
import ./venc.bend as VE
import ./vdepth.bend as VD

# A container's bytes as a list of pieces (hand-written; for codegen/var_cont_enc.py).
#
# The region of a container written at X0 is the concatenation CAT of its pieces in byte order:
# its fixed fields and offsets, then its variable fields, then the zeros to the end of the last
# word. Before the writer runs, every piece is zeros (UW.ZB); each write turns one piece into its
# bytes (seg_put: a piece of m bytes, written with p zeros after it that fall on the next
# pieces, still zero), and reg_put / reg_zero carry this over the tree's bytes, spliced at X0
# (UW.SPL). A piece whose structure is not closed is kept as PC(m, Y): m bytes, the length
# closed whenever m is (pc_id: it is Y).

def LN(+a: +List<U32>) -> Nat: List.length(&2, U32, a)
def AP(+a: +List<U32>, +b: +List<U32>) -> +List<U32>: List.append(&2, U32, a, b)
def LAP(+a: +List<+List<U32>>, +b: +List<+List<U32>>) -> +List<+List<U32>>: List.append(&2, +List<U32>, a, b)

def CAT(ss: +List<+List<U32>>) -> +List<U32>:
  match ss:
    case Nil{}: []
    case Con{s, t}: List.append(&2, U32, s, CAT(t))

def HD(xs: +List<U32>) -> U32:
  match xs:
    case Nil{}: 0
    case Con{x, t}: x
def TL(xs: +List<U32>) -> +List<U32>:
  match xs:
    case Nil{}: []
    case Con{x, t}: t

# The first k bytes of xs, as k cells.
def PC(k: Nat, +xs: +List<U32>) -> +List<U32>:
  match k:
    case 0n: []
    case 1n+p: Con{HD(xs), PC(p, TL(xs))}

law pc_id:
  for +k: Nat
  for +xs: +List<U32>
  for +h: {LN(xs) == k : Nat}
  {PC(k, xs) == xs : +List<U32>}
def pc_id(k, xs, h):
  match k xs:
    case 0n Nil{}: {==}
    case 0n Con{+x, +t}: Empty.absurd({PC(0n, Con{x, t}) == Con{x, t} : +List<U32>}, F.nat__succ_zero(LN(t), h))
    case 1n+ +p Nil{}: Empty.absurd({PC(1n+p, Nil{}) == Nil{} : +List<U32>}, F.nat__zero_succ(p, h))
    case 1n+ +p Con{+x, +t}: Equal.cong(+List<U32>, +List<U32>, z => Con{x, z}, PC(p, t), t, pc_id(p, t, F.nat__succ_inj(LN(t), p, h)))

law len_pc:
  for +k: Nat
  for +xs: +List<U32>
  {LN(PC(k, xs)) == k : Nat}
def len_pc(k, xs):
  match k:
    case 0n: {==}
    case 1n+ +p: F.nat__succ_cong(LN(PC(p, TL(xs))), p, len_pc(p, TL(xs)))

law cat_lap:
  for +a: +List<+List<U32>>
  for +b: +List<+List<U32>>
  {CAT(LAP(a, b)) == AP(CAT(a), CAT(b)) : +List<U32>}
def cat_lap(a, b):
  match a:
    case Nil{}: {==}
    case Con{+s, +t}:
      %Equal.sym(+List<U32>, CAT(LAP(t, b)), AP(CAT(t), CAT(b)), cat_lap(t, b)) : {AP(s, _) == AP(AP(s, CAT(t)), CAT(b)) : +List<U32>}
      Equal.sym(+List<U32>, AP(AP(s, CAT(t)), CAT(b)), AP(s, AP(CAT(t), CAT(b))), VS.app_assoc(s, CAT(t), CAT(b)))

law len_app:
  for +a: +List<U32>
  for +b: +List<U32>
  {LN(AP(a, b)) == Nat.add(LN(a), LN(b)) : Nat}
def len_app(a, b):
  match a:
    case Nil{}: {==}
    case Con{+x, +t}: F.nat__succ_cong(LN(AP(t, b)), Nat.add(LN(t), LN(b)), len_app(t, b))

law bdr_all:
  for +a: +List<U32>
  for +b: +List<U32>
  {VS.bdr(LN(a), AP(a, b)) == b : +List<U32>}
def bdr_all(a, b):
  match a:
    case Nil{}: {==}
    case Con{+x, +t}: bdr_all(t, b)

# A zero prefix of p bytes is at most the list's length.
law bt_short:
  for +p: Nat
  for +c: +List<U32>
  for +h: {VS.bt(p, c) == UW.ZB(p) : +List<U32>}
  {Nat.is_le(p, LN(c)) == True{} : Bool}
def bt_short(p, c, h):
  match p c:
    case 0n _: F.nat__zero_le(LN(c))
    case 1n+ +q Nil{}: Empty.absurd({Nat.is_le(1n+q, 0n) == True{} : Bool}, F.nat__zero_succ(LN(UW.ZB(q)), Equal.cong(+List<U32>, Nat, z => LN(z), Nil{}, Con{0, UW.ZB(q)}, h)))
    case 1n+ +q Con{+x, +t}: bt_short(q, t, Equal.cong(+List<U32>, +List<U32>, z => TL(z), Con{x, VS.bt(q, t)}, Con{0, UW.ZB(q)}, h))

# c as its p zero bytes then the rest.
def zrest(+p: Nat, +c: +List<U32>, +hp: {VS.bt(p, c) == UW.ZB(p) : +List<U32>}) -> {AP(UW.ZB(p), VS.bdr(p, c)) == c : +List<U32>}:
  %hp : {AP(_, VS.bdr(p, c)) == c : +List<U32>}
  UW.bt_bdr_split(p, c)

# ---- one piece ------------------------------------------------------------------------------------

def SEG(+pre: +List<+List<U32>>, +m: Nat, +post: +List<+List<U32>>) -> +List<U32>: CAT(LAP(pre, Con{UW.ZB(m), post}))

def seg_split(+pre: +List<+List<U32>>, +y: +List<U32>, +post: +List<+List<U32>>) -> {CAT(LAP(pre, Con{y, post})) == AP(CAT(pre), AP(y, CAT(post))) : +List<U32>}:
  cat_lap(pre, Con{y, post})

# Writing Y (m bytes) and p zeros at the piece: the piece is Y.
def seg_put(+pre: +List<+List<U32>>, +m: Nat, +post: +List<+List<U32>>, +Y: +List<U32>, +p: Nat,
    +hY: {LN(Y) == m : Nat}, +hp: {VS.bt(p, CAT(post)) == UW.ZB(p) : +List<U32>})
    -> {UW.SPL(SEG(pre, m, post), LN(CAT(pre)), AP(Y, UW.ZB(p))) == CAT(LAP(pre, Con{Y, post})) : +List<U32>}:
  +a = CAT(pre)
  +c = CAT(post)
  +Yp = AP(Y, UW.ZB(p))
  +e0 = seg_split(pre, UW.ZB(m), post)
  +e1 = VE2.spl_mid(a, AP(UW.ZB(m), c), Yp)
  +eL = Equal.trans(Nat, LN(Yp), Nat.add(LN(Y), LN(UW.ZB(p))), Nat.add(m, p), len_app(Y, UW.ZB(p)),
    Equal.trans(Nat, Nat.add(LN(Y), LN(UW.ZB(p))), Nat.add(m, LN(UW.ZB(p))), Nat.add(m, p), Equal.cong(Nat, Nat, z => Nat.add(z, LN(UW.ZB(p))), LN(Y), m, hY),
      Equal.cong(Nat, Nat, z => Nat.add(m, z), LN(UW.ZB(p)), p, VE2.len_zb(p))))
  +eZ = F.logic__subst(Nat, z => {VS.bdr(z, AP(UW.ZB(m), c)) == c : +List<U32>}, LN(UW.ZB(m)), m, VE2.len_zb(m), bdr_all(UW.ZB(m), c))
  +eB = Equal.trans(+List<U32>, VS.bdr(LN(Yp), AP(UW.ZB(m), c)), VS.bdr(Nat.add(m, p), AP(UW.ZB(m), c)), VS.bdr(p, c),
    Equal.cong(Nat, +List<U32>, z => VS.bdr(z, AP(UW.ZB(m), c)), LN(Yp), Nat.add(m, p), eL),
    Equal.trans(+List<U32>, VS.bdr(Nat.add(m, p), AP(UW.ZB(m), c)), VS.bdr(p, VS.bdr(m, AP(UW.ZB(m), c))), VS.bdr(p, c), UW.bdr_add(m, p, AP(UW.ZB(m), c)),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bdr(p, z), VS.bdr(m, AP(UW.ZB(m), c)), c, eZ)))
  +eT = Equal.trans(+List<U32>, AP(Yp, VS.bdr(LN(Yp), AP(UW.ZB(m), c))), AP(Yp, VS.bdr(p, c)), AP(Y, c),
    Equal.cong(+List<U32>, +List<U32>, z => AP(Yp, z), VS.bdr(LN(Yp), AP(UW.ZB(m), c)), VS.bdr(p, c), eB),
    Equal.trans(+List<U32>, AP(Yp, VS.bdr(p, c)), AP(Y, AP(UW.ZB(p), VS.bdr(p, c))), AP(Y, c), VS.app_assoc(Y, UW.ZB(p), VS.bdr(p, c)),
      Equal.cong(+List<U32>, +List<U32>, z => AP(Y, z), AP(UW.ZB(p), VS.bdr(p, c)), c, zrest(p, c, hp))))
  %Equal.sym(+List<U32>, SEG(pre, m, post), AP(a, AP(UW.ZB(m), c)), e0) : {UW.SPL(_, LN(a), Yp) == CAT(LAP(pre, Con{Y, post})) : +List<U32>}
  %Equal.sym(+List<U32>, UW.SPL(AP(a, AP(UW.ZB(m), c)), LN(a), Yp), AP(a, AP(Yp, VS.bdr(LN(Yp), AP(UW.ZB(m), c)))), e1) : {_ == CAT(LAP(pre, Con{Y, post})) : +List<U32>}
  %Equal.sym(+List<U32>, AP(Yp, VS.bdr(LN(Yp), AP(UW.ZB(m), c))), AP(Y, c), eT) : {AP(a, _) == CAT(LAP(pre, Con{Y, post})) : +List<U32>}
  Equal.sym(+List<U32>, CAT(LAP(pre, Con{Y, post})), AP(a, AP(Y, c)), seg_split(pre, Y, post))

# The zero window at the piece: its m bytes and the p after it.
def seg_zero(+pre: +List<+List<U32>>, +m: Nat, +post: +List<+List<U32>>, +p: Nat, +hp: {VS.bt(p, CAT(post)) == UW.ZB(p) : +List<U32>})
    -> {VS.bt(Nat.add(m, p), VS.bdr(LN(CAT(pre)), SEG(pre, m, post))) == UW.ZB(Nat.add(m, p)) : +List<U32>}:
  +a = CAT(pre)
  +c = CAT(post)
  %Equal.sym(+List<U32>, SEG(pre, m, post), AP(a, AP(UW.ZB(m), c)), seg_split(pre, UW.ZB(m), post)) : {VS.bt(Nat.add(m, p), VS.bdr(LN(a), _)) == UW.ZB(Nat.add(m, p)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(LN(a), AP(a, AP(UW.ZB(m), c))), AP(UW.ZB(m), c), bdr_all(a, AP(UW.ZB(m), c))) : {VS.bt(Nat.add(m, p), _) == UW.ZB(Nat.add(m, p)) : +List<U32>}
  %VE2.len_zb(m) : {VS.bt(Nat.add(_, p), AP(UW.ZB(m), c)) == UW.ZB(Nat.add(m, p)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(Nat.add(LN(UW.ZB(m)), p), AP(UW.ZB(m), c)), AP(UW.ZB(m), VS.bt(p, c)), UW.bt_app_len(UW.ZB(m), p, c)) : {_ == UW.ZB(Nat.add(m, p)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(p, c), UW.ZB(p), hp) : {AP(UW.ZB(m), _) == UW.ZB(Nat.add(m, p)) : +List<U32>}
  Equal.sym(+List<U32>, UW.ZB(Nat.add(m, p)), AP(UW.ZB(m), UW.ZB(p)), VE2.zb_add(m, p))

# The piece and its p zeros lie in the region.
def seg_room(+pre: +List<+List<U32>>, +m: Nat, +post: +List<+List<U32>>, +p: Nat, +hp: {VS.bt(p, CAT(post)) == UW.ZB(p) : +List<U32>})
    -> {Nat.is_le(Nat.add(LN(CAT(pre)), Nat.add(m, p)), LN(SEG(pre, m, post))) == True{} : Bool}:
  +a = CAT(pre)
  +c = CAT(post)
  +eL = Equal.trans(Nat, LN(SEG(pre, m, post)), LN(AP(a, AP(UW.ZB(m), c))), Nat.add(LN(a), Nat.add(m, LN(c))),
    Equal.cong(+List<U32>, Nat, z => LN(z), SEG(pre, m, post), AP(a, AP(UW.ZB(m), c)), seg_split(pre, UW.ZB(m), post)),
    Equal.trans(Nat, LN(AP(a, AP(UW.ZB(m), c))), Nat.add(LN(a), LN(AP(UW.ZB(m), c))), Nat.add(LN(a), Nat.add(m, LN(c))), len_app(a, AP(UW.ZB(m), c)),
      Equal.cong(Nat, Nat, z => Nat.add(LN(a), z), LN(AP(UW.ZB(m), c)), Nat.add(m, LN(c)),
        Equal.trans(Nat, LN(AP(UW.ZB(m), c)), Nat.add(LN(UW.ZB(m)), LN(c)), Nat.add(m, LN(c)), len_app(UW.ZB(m), c),
          Equal.cong(Nat, Nat, z => Nat.add(z, LN(c)), LN(UW.ZB(m)), m, VE2.len_zb(m))))))
  F.logic__subst(Nat, z => {Nat.is_le(Nat.add(LN(a), Nat.add(m, p)), z) == True{} : Bool}, Nat.add(LN(a), Nat.add(m, LN(c))), LN(SEG(pre, m, post)), Equal.sym(Nat, LN(SEG(pre, m, post)), Nat.add(LN(a), Nat.add(m, LN(c))), eL),
    Order.add_left(LN(a), Nat.add(m, p), Nat.add(m, LN(c)), Order.add_left(m, p, LN(c), bt_short(p, c, hp))))

# ---- the region in the tree's bytes ---------------------------------------------------------------

# A write of Y (m bytes) and p zeros at the piece, at X0 + |pre|.
def reg_put(+B0: +List<U32>, +X0: Nat, +pre: +List<+List<U32>>, +m: Nat, +post: +List<+List<U32>>, +Y: +List<U32>, +p: Nat,
    +UB: +List<U32>, +UB2: +List<U32>, +hX: {Nat.is_le(X0, LN(B0)) == True{} : Bool},
    +hI: {UB == UW.SPL(B0, X0, SEG(pre, m, post)) : +List<U32>},
    +hY: {LN(Y) == m : Nat}, +hp: {VS.bt(p, CAT(post)) == UW.ZB(p) : +List<U32>},
    +hop: {UB2 == UW.SPL(UB, Nat.add(X0, LN(CAT(pre))), AP(Y, UW.ZB(p))) : +List<U32>})
    -> {UB2 == UW.SPL(B0, X0, CAT(LAP(pre, Con{Y, post}))) : +List<U32>}:
  +Z = SEG(pre, m, post)
  +a = LN(CAT(pre))
  +Yp = AP(Y, UW.ZB(p))
  +eL = Equal.trans(Nat, LN(Yp), Nat.add(LN(Y), LN(UW.ZB(p))), Nat.add(m, p), len_app(Y, UW.ZB(p)),
    Equal.trans(Nat, Nat.add(LN(Y), LN(UW.ZB(p))), Nat.add(m, LN(UW.ZB(p))), Nat.add(m, p), Equal.cong(Nat, Nat, z => Nat.add(z, LN(UW.ZB(p))), LN(Y), m, hY),
      Equal.cong(Nat, Nat, z => Nat.add(m, z), LN(UW.ZB(p)), p, VE2.len_zb(p))))
  +hroom = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(a, z), LN(Z)) == True{} : Bool}, Nat.add(m, p), LN(Yp), Equal.sym(Nat, LN(Yp), Nat.add(m, p), eL), seg_room(pre, m, post, p, hp))
  +e1 = F.logic__subst(+List<U32>, z => {UB2 == UW.SPL(z, Nat.add(X0, a), Yp) : +List<U32>}, UB, UW.SPL(B0, X0, Z), hI, hop)
  +e2 = Equal.trans(+List<U32>, UB2, UW.SPL(UW.SPL(B0, X0, Z), Nat.add(X0, a), Yp), UW.SPL(B0, X0, UW.SPL(Z, a, Yp)), e1, UW.spl_spl(B0, X0, Z, a, Yp, hX, hroom))
  Equal.trans(+List<U32>, UB2, UW.SPL(B0, X0, UW.SPL(Z, a, Yp)), UW.SPL(B0, X0, CAT(LAP(pre, Con{Y, post}))), e2,
    Equal.cong(+List<U32>, +List<U32>, z => UW.SPL(B0, X0, z), UW.SPL(Z, a, Yp), CAT(LAP(pre, Con{Y, post})), seg_put(pre, m, post, Y, p, hY, hp)))

# The same with no zeros after Y.
def reg_put0(+B0: +List<U32>, +X0: Nat, +pre: +List<+List<U32>>, +m: Nat, +post: +List<+List<U32>>, +Y: +List<U32>,
    +UB: +List<U32>, +UB2: +List<U32>, +hX: {Nat.is_le(X0, LN(B0)) == True{} : Bool},
    +hI: {UB == UW.SPL(B0, X0, SEG(pre, m, post)) : +List<U32>},
    +hY: {LN(Y) == m : Nat}, +hop: {UB2 == UW.SPL(UB, Nat.add(X0, LN(CAT(pre))), Y) : +List<U32>})
    -> {UB2 == UW.SPL(B0, X0, CAT(LAP(pre, Con{Y, post}))) : +List<U32>}:
  reg_put(B0, X0, pre, m, post, Y, 0n, UB, UB2, hX, hI, hY, {==},
    F.logic__subst(+List<U32>, z => {UB2 == UW.SPL(UB, Nat.add(X0, LN(CAT(pre))), z) : +List<U32>}, Y, AP(Y, UW.ZB(0n)), Equal.sym(+List<U32>, AP(Y, []), Y, VS.app_nil(Y)), hop))

# The zero window of the piece and the p bytes after it, in the tree's bytes.
def reg_zero(+B0: +List<U32>, +X0: Nat, +pre: +List<+List<U32>>, +m: Nat, +post: +List<+List<U32>>, +p: Nat,
    +UB: +List<U32>, +hX: {Nat.is_le(X0, LN(B0)) == True{} : Bool},
    +hI: {UB == UW.SPL(B0, X0, SEG(pre, m, post)) : +List<U32>}, +hp: {VS.bt(p, CAT(post)) == UW.ZB(p) : +List<U32>})
    -> {VS.bt(Nat.add(m, p), VS.bdr(Nat.add(X0, LN(CAT(pre))), UB)) == UW.ZB(Nat.add(m, p)) : +List<U32>}:
  +Z = SEG(pre, m, post)
  +a = LN(CAT(pre))
  +hroom = seg_room(pre, m, post, p, hp)
  %Equal.sym(+List<U32>, UB, UW.SPL(B0, X0, Z), hI) : {VS.bt(Nat.add(m, p), VS.bdr(Nat.add(X0, a), _)) == UW.ZB(Nat.add(m, p)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(Nat.add(m, p), VS.bdr(Nat.add(X0, a), UW.SPL(B0, X0, Z))), VS.bt(Nat.add(m, p), VS.bdr(a, Z)), UW.win_spl(B0, X0, Z, a, Nat.add(m, p), hX, hroom)) :
    {_ == UW.ZB(Nat.add(m, p)) : +List<U32>}
  seg_zero(pre, m, post, p, hp)

# The pieces after a piece, all zero: p zeros from them when p fits.
def ZBS(ms: List<&2, Nat>) -> +List<+List<U32>>:
  match ms:
    case Nil{}: []
    case Con{m, t}: Con{UW.ZB(m), ZBS(t)}
def SUM(ms: List<&2, Nat>) -> Nat:
  match ms:
    case Nil{}: 0n
    case Con{m, t}: Nat.add(m, SUM(t))
law cat_zbs:
  for +ms: List<&2, Nat>
  {CAT(ZBS(ms)) == UW.ZB(SUM(ms)) : +List<U32>}
def cat_zbs(ms):
  match ms:
    case Nil{}: {==}
    case Con{+m, +t}:
      %Equal.sym(+List<U32>, CAT(ZBS(t)), UW.ZB(SUM(t)), cat_zbs(t)) : {AP(UW.ZB(m), _) == UW.ZB(Nat.add(m, SUM(t))) : +List<U32>}
      Equal.sym(+List<U32>, UW.ZB(Nat.add(m, SUM(t))), AP(UW.ZB(m), UW.ZB(SUM(t))), VE2.zb_add(m, SUM(t)))
def zbs_pre(+ms: List<&2, Nat>, +p: Nat, +h: {Nat.is_le(p, SUM(ms)) == True{} : Bool}) -> {VS.bt(p, CAT(ZBS(ms))) == UW.ZB(p) : +List<U32>}:
  %Equal.sym(+List<U32>, CAT(ZBS(ms)), UW.ZB(SUM(ms)), cat_zbs(ms)) : {VS.bt(p, _) == UW.ZB(p) : +List<U32>}
  VE2.bt_zb_le(p, SUM(ms), h)
# p <= m zeros from a zero piece followed by anything.
def zb_pre(+m: Nat, +t: +List<+List<U32>>, +p: Nat, +h: {Nat.is_le(p, m) == True{} : Bool}) -> {VS.bt(p, CAT(Con{UW.ZB(m), t})) == UW.ZB(p) : +List<U32>}:
  VE2.bt_app_zb(p, m, CAT(t), h)

# ---- positions of the variable pieces --------------------------------------------------------------

def QX(+y: U32) -> Nat: U32.to_nat(U32.shrn(y, 2n))
def RX(+y: U32) -> Nat: U32.to_nat(U32.and(y, 3))
def rx_lt(+y: U32) -> {Nat.is_lt(RX(y), 4n) == True{} : Bool}: F.nat__le_lt_trans(RX(y), 3n, 4n, RD.and_le(y, 3), {==})

def padb_id(+r: Nat, +m: Nat) -> {Nat.add(Nat.add(r, m), WD.PADB(r, m)) == A.quad(WD.NWN(Nat.add(r, m))) : Nat}:
  +Q = A.quad(WD.NWN(Nat.add(r, m)))
  +hq = VRX.nwn_ge(Nat.add(r, m))
  +hr = F.nat__le_trans(r, Nat.add(r, m), Q, Order.below_sum(r, m), hq)
  +er = F.nat__sub_add(Q, r, hr)
  +hm = VZ.le_cancel(r, m, Nat.sub(Q, r), F.logic__subst(Nat, z => {Nat.is_le(Nat.add(r, m), z) == True{} : Bool}, Q, Nat.add(r, Nat.sub(Q, r)), Equal.sym(Nat, Nat.add(r, Nat.sub(Q, r)), Q, er), hq))
  +em = F.nat__sub_add(Nat.sub(Q, r), m, hm)
  Equal.trans(Nat, Nat.add(Nat.add(r, m), WD.PADB(r, m)), Nat.add(r, Nat.add(m, WD.PADB(r, m))), Q, F.nat__add_assoc(r, m, WD.PADB(r, m)),
    Equal.trans(Nat, Nat.add(r, Nat.add(m, WD.PADB(r, m))), Nat.add(r, Nat.sub(Q, r)), Q, Equal.cong(Nat, Nat, z => Nat.add(r, z), Nat.add(m, WD.PADB(r, m)), Nat.sub(Q, r), em), er))

# The end of L bytes at X0 = 4 q + r, with the zeros to the end of the last word, is a word end.
def e_end2(+q: Nat, +r: Nat, +L: Nat)
    -> {Nat.add(Nat.add(A.quad(q), r), Nat.add(L, WD.PADB(r, L))) == A.quad(WD.NWN(Nat.add(Nat.add(A.quad(q), r), L))) : Nat}:
  +Pd = WD.PADB(r, L)
  +e1 = Equal.trans(Nat, Nat.add(Nat.add(A.quad(q), r), Nat.add(L, Pd)), Nat.add(A.quad(q), Nat.add(Nat.add(r, L), Pd)), A.quad(Nat.add(q, WD.NWN(Nat.add(r, L)))),
    Equal.trans(Nat, Nat.add(Nat.add(A.quad(q), r), Nat.add(L, Pd)), Nat.add(A.quad(q), Nat.add(r, Nat.add(L, Pd))), Nat.add(A.quad(q), Nat.add(Nat.add(r, L), Pd)),
      F.nat__add_assoc(A.quad(q), r, Nat.add(L, Pd)),
      Equal.cong(Nat, Nat, z => Nat.add(A.quad(q), z), Nat.add(r, Nat.add(L, Pd)), Nat.add(Nat.add(r, L), Pd), Equal.sym(Nat, Nat.add(Nat.add(r, L), Pd), Nat.add(r, Nat.add(L, Pd)), F.nat__add_assoc(r, L, Pd)))),
    Equal.trans(Nat, Nat.add(A.quad(q), Nat.add(Nat.add(r, L), Pd)), Nat.add(A.quad(q), A.quad(WD.NWN(Nat.add(r, L)))), A.quad(Nat.add(q, WD.NWN(Nat.add(r, L)))),
      Equal.cong(Nat, Nat, z => Nat.add(A.quad(q), z), Nat.add(Nat.add(r, L), Pd), A.quad(WD.NWN(Nat.add(r, L))), padb_id(r, L)),
      VF.quad_add(q, WD.NWN(Nat.add(r, L)))))
  Equal.trans(Nat, Nat.add(Nat.add(A.quad(q), r), Nat.add(L, Pd)), A.quad(Nat.add(q, WD.NWN(Nat.add(r, L)))), A.quad(WD.NWN(Nat.add(Nat.add(A.quad(q), r), L))),
    e1,
    Equal.cong(Nat, Nat, z => A.quad(z), Nat.add(q, WD.NWN(Nat.add(r, L))), WD.NWN(Nat.add(Nat.add(A.quad(q), r), L)),
      Equal.trans(Nat, Nat.add(q, WD.NWN(Nat.add(r, L))), WD.NWN(Nat.add(A.quad(q), Nat.add(r, L))), WD.NWN(Nat.add(Nat.add(A.quad(q), r), L)),
        Equal.sym(Nat, WD.NWN(Nat.add(A.quad(q), Nat.add(r, L))), Nat.add(q, WD.NWN(Nat.add(r, L))), VRX.nwn_quad(q, Nat.add(r, L))),
        Equal.cong(Nat, Nat, z => WD.NWN(z), Nat.add(A.quad(q), Nat.add(r, L)), Nat.add(Nat.add(A.quad(q), r), L), Equal.sym(Nat, Nat.add(Nat.add(A.quad(q), r), L), Nat.add(A.quad(q), Nat.add(r, L)), F.nat__add_assoc(A.quad(q), r, L))))))

# A piece at a (a <= L) of a region of L bytes at X = 4 q + r: its byte position.
def vposW(+X: U32, +c: U32, +a: Nat, +q: Nat, +r: Nat, +L: Nat, +dd: Nat, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +ec: {U32.to_nat(c) == a : Nat},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +ha: {Nat.is_le(a, L) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool}, +hl32: {Nat.is_lt(Nat.add(Nat.add(A.quad(q), r), L), F.spec_common__pow2(32n)) == True{} : Bool})
    -> {U32.to_nat(U32.add(X, c)) == Nat.add(Nat.add(A.quad(q), r), a) : Nat}:
  +X0 = Nat.add(A.quad(q), r)
  +hb = F.nat__le_lt_trans(Nat.add(a, X0), Nat.add(X0, L), F.spec_common__pow2(32n),
    F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(X0, L)) == True{} : Bool}, Nat.add(X0, a), Nat.add(a, X0), F.nat__add_comm(X0, a), Order.add_left(X0, a, L, ha)),
    hl32)
  +e1 = VB.add_lt32(X, c, X0, e,
    F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(z, X0), F.spec_common__pow2(32n)) == True{} : Bool}, a, U32.to_nat(c), Equal.sym(Nat, U32.to_nat(c), a, ec), hb))
  Equal.trans(Nat, U32.to_nat(U32.add(X, c)), Nat.add(U32.to_nat(c), X0), Nat.add(X0, a), e1,
    Equal.trans(Nat, Nat.add(U32.to_nat(c), X0), Nat.add(a, X0), Nat.add(X0, a), Equal.cong(Nat, Nat, z => Nat.add(z, X0), U32.to_nat(c), a, ec), F.nat__add_comm(a, X0)))

# vposW for a piece strictly inside its region (a < L): no bound on the region's end needed.
def vposS(+X: U32, +c: U32, +a: Nat, +q: Nat, +r: Nat, +L: Nat, +dd: Nat, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +ec: {U32.to_nat(c) == a : Nat},
    +hd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +ha: {Nat.is_lt(a, L) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool})
    -> {U32.to_nat(U32.add(X, c)) == Nat.add(Nat.add(A.quad(q), r), a) : Nat}:
  +X0 = Nat.add(A.quad(q), r)
  +hb = F.nat__lt_le_trans(Nat.add(a, X0), Nat.add(X0, L), F.spec_common__pow2(32n),
    F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(a, X0), z) == True{} : Bool}, Nat.add(L, X0), Nat.add(X0, L), F.nat__add_comm(L, X0), VB.lt_kk(a, L, X0, ha)),
    F.nat__le_trans(Nat.add(X0, L), A.quad(VB.pw(dd)), F.spec_common__pow2(32n), VRX.xend(q, r, L, dd, hl), UW.q32(dd, hd)))
  +e1 = VB.add_lt32(X, c, X0, e,
    F.logic__subst(Nat, z => {Nat.is_lt(Nat.add(z, X0), F.spec_common__pow2(32n)) == True{} : Bool}, a, U32.to_nat(c), Equal.sym(Nat, U32.to_nat(c), a, ec), hb))
  Equal.trans(Nat, U32.to_nat(U32.add(X, c)), Nat.add(U32.to_nat(c), X0), Nat.add(X0, a), e1,
    Equal.trans(Nat, Nat.add(U32.to_nat(c), X0), Nat.add(a, X0), Nat.add(X0, a), Equal.cong(Nat, Nat, z => Nat.add(z, X0), U32.to_nat(c), a, ec), F.nat__add_comm(a, X0)))

def vpos(+X: U32, +c: U32, +a: Nat, +q: Nat, +r: Nat, +L: Nat, +dd: Nat, +e: {U32.to_nat(X) == Nat.add(A.quad(q), r) : Nat}, +ec: {U32.to_nat(c) == a : Nat},
    +hd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +ha: {Nat.is_le(a, L) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool})
    -> {U32.to_nat(U32.add(X, c)) == Nat.add(Nat.add(A.quad(q), r), a) : Nat}:
  +X0 = Nat.add(A.quad(q), r)
  +hb = F.nat__le_trans(Nat.add(a, X0), Nat.add(X0, L), VB.pw(2n+dd),
    F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(X0, L)) == True{} : Bool}, Nat.add(X0, a), Nat.add(a, X0), F.nat__add_comm(X0, a), Order.add_left(X0, a, L, ha)),
    VRX.xend(q, r, L, dd, hl))
  +e1 = VB.add_le_at(X, c, X0, 2n+dd, e, hd,
    F.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, X0), VB.pw(2n+dd)) == True{} : Bool}, a, U32.to_nat(c), Equal.sym(Nat, U32.to_nat(c), a, ec), hb))
  Equal.trans(Nat, U32.to_nat(U32.add(X, c)), Nat.add(U32.to_nat(c), X0), Nat.add(X0, a), e1,
    Equal.trans(Nat, Nat.add(U32.to_nat(c), X0), Nat.add(a, X0), Nat.add(X0, a), Equal.cong(Nat, Nat, z => Nat.add(z, X0), U32.to_nat(c), a, ec), F.nat__add_comm(a, X0)))

# The piece's m bytes at Xc = X0 + a, a + m <= L: the room of its writer.
def croom(+Xc: U32, +q: Nat, +r: Nat, +a: Nat, +m: Nat, +L: Nat, +dd: Nat,
    +epos: {U32.to_nat(Xc) == Nat.add(Nat.add(A.quad(q), r), a) : Nat}, +hk: {Nat.is_le(Nat.add(a, m), L) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(QX(Xc), WD.NWN(Nat.add(RX(Xc), m))), VB.pw(dd)) == True{} : Bool}:
  +X0 = Nat.add(A.quad(q), r)
  +y1 = Nat.add(A.quad(QX(Xc)), Nat.add(RX(Xc), m))
  +e1 = Equal.trans(Nat, y1, Nat.add(Nat.add(A.quad(QX(Xc)), RX(Xc)), m), Nat.add(X0, Nat.add(a, m)),
    Equal.sym(Nat, Nat.add(Nat.add(A.quad(QX(Xc)), RX(Xc)), m), y1, F.nat__add_assoc(A.quad(QX(Xc)), RX(Xc), m)),
    Equal.trans(Nat, Nat.add(Nat.add(A.quad(QX(Xc)), RX(Xc)), m), Nat.add(Nat.add(X0, a), m), Nat.add(X0, Nat.add(a, m)),
      Equal.cong(Nat, Nat, z => Nat.add(z, m), Nat.add(A.quad(QX(Xc)), RX(Xc)), Nat.add(X0, a), Equal.trans(Nat, Nat.add(A.quad(QX(Xc)), RX(Xc)), U32.to_nat(Xc), Nat.add(X0, a), Equal.sym(Nat, U32.to_nat(Xc), Nat.add(A.quad(QX(Xc)), RX(Xc)), VC.split4(Xc)), epos)),
      F.nat__add_assoc(X0, a, m)))
  +h1 = F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(X0, L)) == True{} : Bool}, Nat.add(X0, Nat.add(a, m)), y1, Equal.sym(Nat, y1, Nat.add(X0, Nat.add(a, m)), e1), Order.add_left(X0, Nat.add(a, m), L, hk))
  +h2 = F.logic__subst(Nat, z => {Nat.is_le(y1, z) == True{} : Bool}, Nat.add(X0, L), Nat.add(A.quad(q), Nat.add(r, L)), F.nat__add_assoc(A.quad(q), r, L), h1)
  +h3 = VRX.nwn_mono(y1, Nat.add(A.quad(q), Nat.add(r, L)), h2)
  F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, WD.NWN(y1), Nat.add(QX(Xc), WD.NWN(Nat.add(RX(Xc), m))), VRX.nwn_quad(QX(Xc), Nat.add(RX(Xc), m)),
    F.nat__le_trans(WD.NWN(y1), WD.NWN(Nat.add(A.quad(q), Nat.add(r, L))), VB.pw(dd), h3,
      F.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dd)) == True{} : Bool}, Nat.add(q, WD.NWN(Nat.add(r, L))), WD.NWN(Nat.add(A.quad(q), Nat.add(r, L))),
        Equal.sym(Nat, WD.NWN(Nat.add(A.quad(q), Nat.add(r, L))), Nat.add(q, WD.NWN(Nat.add(r, L))), VRX.nwn_quad(q, Nat.add(r, L))), hl)))

def VME4(+a: Nat, +b: Nat, +h: {Nat.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(A.quad(a), A.quad(b)) == True{} : Bool}:
  F.nat__double_le(Nat.double(a), Nat.double(b), F.nat__double_le(a, b, h))

# The zeros a piece's writer puts after it (to the end of its last word) fit in the S bytes after
# it in the region, when the region ends at a word end: a + m + S = L + PADB(r, L).
def padfit(+Xc: U32, +q: Nat, +r: Nat, +a: Nat, +m: Nat, +L: Nat, +S: Nat,
    +epos: {U32.to_nat(Xc) == Nat.add(Nat.add(A.quad(q), r), a) : Nat}, +hk: {Nat.is_le(Nat.add(a, m), L) == True{} : Bool},
    +eS: {Nat.add(Nat.add(a, m), S) == Nat.add(L, WD.PADB(r, L)) : Nat})
    -> {Nat.is_le(WD.PADB(RX(Xc), m), S) == True{} : Bool}:
  +X0 = Nat.add(A.quad(q), r)
  +pc = WD.PADB(RX(Xc), m)
  +xc = Nat.add(X0, a)
  +ex = Equal.trans(Nat, Nat.add(A.quad(QX(Xc)), RX(Xc)), U32.to_nat(Xc), xc, Equal.sym(Nat, U32.to_nat(Xc), Nat.add(A.quad(QX(Xc)), RX(Xc)), VC.split4(Xc)), epos)
  # the child's end: xc + (m + pc) = 4 NWN(xc + m)
  +ec = F.logic__subst(Nat, z => {Nat.add(z, Nat.add(m, pc)) == A.quad(WD.NWN(Nat.add(z, m))) : Nat}, Nat.add(A.quad(QX(Xc)), RX(Xc)), xc, ex, e_end2(QX(Xc), RX(Xc), m))
  # the region's end: X0 + (L + PADB) = 4 NWN(X0 + L)
  +eR = e_end2(q, r, L)
  +hxm = F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(X0, L)) == True{} : Bool}, Nat.add(X0, Nat.add(a, m)), Nat.add(xc, m), Equal.sym(Nat, Nat.add(xc, m), Nat.add(X0, Nat.add(a, m)), F.nat__add_assoc(X0, a, m)),
    Order.add_left(X0, Nat.add(a, m), L, hk))
  +hq = VME4(WD.NWN(Nat.add(xc, m)), WD.NWN(Nat.add(X0, L)), VRX.nwn_mono(Nat.add(xc, m), Nat.add(X0, L), hxm))
  +h1 = F.logic__subst(Nat, z => {Nat.is_le(z, A.quad(WD.NWN(Nat.add(X0, L)))) == True{} : Bool}, A.quad(WD.NWN(Nat.add(xc, m))), Nat.add(xc, Nat.add(m, pc)), Equal.sym(Nat, Nat.add(xc, Nat.add(m, pc)), A.quad(WD.NWN(Nat.add(xc, m))), ec), hq)
  +h2 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(xc, Nat.add(m, pc)), z) == True{} : Bool}, A.quad(WD.NWN(Nat.add(X0, L))), Nat.add(X0, Nat.add(L, WD.PADB(r, L))), Equal.sym(Nat, Nat.add(X0, Nat.add(L, WD.PADB(r, L))), A.quad(WD.NWN(Nat.add(X0, L))), eR), h1)
  # X0 + (L + PADB) = X0 + ((a + m) + S) = (xc + m) + S; xc + (m + pc) = (xc + m) + pc
  +eRS = Equal.trans(Nat, Nat.add(X0, Nat.add(L, WD.PADB(r, L))), Nat.add(X0, Nat.add(Nat.add(a, m), S)), Nat.add(Nat.add(xc, m), S),
    Equal.cong(Nat, Nat, z => Nat.add(X0, z), Nat.add(L, WD.PADB(r, L)), Nat.add(Nat.add(a, m), S), Equal.sym(Nat, Nat.add(Nat.add(a, m), S), Nat.add(L, WD.PADB(r, L)), eS)),
    Equal.trans(Nat, Nat.add(X0, Nat.add(Nat.add(a, m), S)), Nat.add(Nat.add(X0, Nat.add(a, m)), S), Nat.add(Nat.add(xc, m), S),
      Equal.sym(Nat, Nat.add(Nat.add(X0, Nat.add(a, m)), S), Nat.add(X0, Nat.add(Nat.add(a, m), S)), F.nat__add_assoc(X0, Nat.add(a, m), S)),
      Equal.cong(Nat, Nat, z => Nat.add(z, S), Nat.add(X0, Nat.add(a, m)), Nat.add(xc, m), Equal.sym(Nat, Nat.add(xc, m), Nat.add(X0, Nat.add(a, m)), F.nat__add_assoc(X0, a, m)))))
  +h3 = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(xc, Nat.add(m, pc)), z) == True{} : Bool}, Nat.add(X0, Nat.add(L, WD.PADB(r, L))), Nat.add(Nat.add(xc, m), S), eRS, h2)
  +h4 = F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(Nat.add(xc, m), S)) == True{} : Bool}, Nat.add(xc, Nat.add(m, pc)), Nat.add(Nat.add(xc, m), pc), Equal.sym(Nat, Nat.add(Nat.add(xc, m), pc), Nat.add(xc, Nat.add(m, pc)), F.nat__add_assoc(xc, m, pc)), h3)
  VZ.le_cancel(Nat.add(xc, m), pc, S, h4)

law nwn_up:
  for +y: Nat
  {Nat.is_le(A.quad(WD.NWN(y)), Nat.add(3n, y)) == True{} : Bool}
def nwn_up(y):
  match y:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n+ +z: nwn_up(z)

# The zeros after an unaligned write of whole words' worth: at most 3.
def padb3(+r: Nat, +m: Nat) -> {Nat.is_le(WD.PADB(r, m), 3n) == True{} : Bool}:
  +y = Nat.add(r, m)
  +e1 = padb_id(r, m)
  +h1 = nwn_up(y)
  +h2 = F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(3n, y)) == True{} : Bool}, A.quad(WD.NWN(y)), Nat.add(y, WD.PADB(r, m)), Equal.sym(Nat, Nat.add(y, WD.PADB(r, m)), A.quad(WD.NWN(y)), e1), h1)
  VZ.le_cancel(y, WD.PADB(r, m), 3n, F.logic__subst(Nat, z => {Nat.is_le(Nat.add(y, WD.PADB(r, m)), z) == True{} : Bool}, Nat.add(3n, y), Nat.add(y, 3n), F.nat__add_comm(3n, y), h2))


# ---- written pieces --------------------------------------------------------------------------------

# A write that installs Y as the m-cell piece PC(m, Y).
def reg_putc(+B0: +List<U32>, +X0: Nat, +pre: +List<+List<U32>>, +m: Nat, +post: +List<+List<U32>>, +Y: +List<U32>, +p: Nat,
    +UB: +List<U32>, +UB2: +List<U32>, +hX: {Nat.is_le(X0, LN(B0)) == True{} : Bool},
    +hI: {UB == UW.SPL(B0, X0, SEG(pre, m, post)) : +List<U32>},
    +hY: {LN(Y) == m : Nat}, +hp: {VS.bt(p, CAT(post)) == UW.ZB(p) : +List<U32>},
    +hop: {UB2 == UW.SPL(UB, Nat.add(X0, LN(CAT(pre))), AP(Y, UW.ZB(p))) : +List<U32>})
    -> {UB2 == UW.SPL(B0, X0, CAT(LAP(pre, Con{PC(m, Y), post}))) : +List<U32>}:
  F.logic__subst(+List<U32>, z => {UB2 == UW.SPL(B0, X0, CAT(LAP(pre, Con{z, post}))) : +List<U32>}, Y, PC(m, Y), Equal.sym(+List<U32>, PC(m, Y), Y, pc_id(m, Y, hY)),
    reg_put(B0, X0, pre, m, post, Y, p, UB, UB2, hX, hI, hY, hp, hop))
def reg_putc0(+B0: +List<U32>, +X0: Nat, +pre: +List<+List<U32>>, +m: Nat, +post: +List<+List<U32>>, +Y: +List<U32>,
    +UB: +List<U32>, +UB2: +List<U32>, +hX: {Nat.is_le(X0, LN(B0)) == True{} : Bool},
    +hI: {UB == UW.SPL(B0, X0, SEG(pre, m, post)) : +List<U32>},
    +hY: {LN(Y) == m : Nat}, +hop: {UB2 == UW.SPL(UB, Nat.add(X0, LN(CAT(pre))), Y) : +List<U32>})
    -> {UB2 == UW.SPL(B0, X0, CAT(LAP(pre, Con{PC(m, Y), post}))) : +List<U32>}:
  F.logic__subst(+List<U32>, z => {UB2 == UW.SPL(B0, X0, CAT(LAP(pre, Con{z, post}))) : +List<U32>}, Y, PC(m, Y), Equal.sym(+List<U32>, PC(m, Y), Y, pc_id(m, Y, hY)),
    reg_put0(B0, X0, pre, m, post, Y, UB, UB2, hX, hI, hY, hop))

# The region before the writer: all its pieces zero.
def reg_init(+B: +List<U32>, +X0: Nat, +ms: List<&2, Nat>, +hz: {VS.bt(SUM(ms), VS.bdr(X0, B)) == UW.ZB(SUM(ms)) : +List<U32>})
    -> {B == UW.SPL(B, X0, CAT(ZBS(ms))) : +List<U32>}:
  +i0 = UW.inv_init(B, X0, SUM(ms), UW.ZB(SUM(ms)), hz, VE2.bt_zb_le(SUM(ms), SUM(ms), F.nat__le_refl(SUM(ms))))
  +i1 = F.logic__subst(+List<U32>, z => {B == UW.SPL(B, X0, z) : +List<U32>}, VS.bt(SUM(ms), UW.ZB(SUM(ms))), UW.ZB(SUM(ms)), VE2.bt_zb_le(SUM(ms), SUM(ms), F.nat__le_refl(SUM(ms))), i0)
  F.logic__subst(+List<U32>, z => {B == UW.SPL(B, X0, z) : +List<U32>}, UW.ZB(SUM(ms)), CAT(ZBS(ms)), Equal.sym(+List<U32>, CAT(ZBS(ms)), UW.ZB(SUM(ms)), cat_zbs(ms)), i1)

# Pieces PC(k, y) of a list of lengths ks, and their byte count.
def HDL(ps: +List<+List<U32>>) -> +List<U32>:
  match ps:
    case Nil{}: []
    case Con{y, t}: y
def TLL(ps: +List<+List<U32>>) -> +List<+List<U32>>:
  match ps:
    case Nil{}: []
    case Con{y, t}: t
def PCL(ks: List<&2, Nat>, +ps: +List<+List<U32>>) -> +List<+List<U32>>:
  match ks:
    case Nil{}: []
    case Con{k, t}: Con{PC(k, HDL(ps)), PCL(t, TLL(ps))}
law len_pcl:
  for +ks: List<&2, Nat>
  for +ps: +List<+List<U32>>
  {LN(CAT(PCL(ks, ps))) == SUM(ks) : Nat}
def len_pcl(ks, ps):
  match ks:
    case Nil{}: {==}
    case Con{+k, +t}:
      Equal.trans(Nat, LN(CAT(PCL(Con{k, t}, ps))), Nat.add(LN(PC(k, HDL(ps))), LN(CAT(PCL(t, TLL(ps))))), Nat.add(k, SUM(t)),
        len_app(PC(k, HDL(ps)), CAT(PCL(t, TLL(ps)))),
        Equal.trans(Nat, Nat.add(LN(PC(k, HDL(ps))), LN(CAT(PCL(t, TLL(ps))))), Nat.add(k, LN(CAT(PCL(t, TLL(ps))))), Nat.add(k, SUM(t)),
          Equal.cong(Nat, Nat, z => Nat.add(z, LN(CAT(PCL(t, TLL(ps))))), LN(PC(k, HDL(ps))), k, len_pc(k, HDL(ps))),
          Equal.cong(Nat, Nat, z => Nat.add(k, z), LN(CAT(PCL(t, TLL(ps)))), SUM(t), len_pcl(t, TLL(ps)))))

# The position of a variable piece: the fixed pieces' bytes, then the earlier variable pieces'.
def eposv(+fw: +List<+List<U32>>, +ps: +List<+List<U32>>, +ks: List<&2, Nat>)
    -> {LN(CAT(LAP(fw, PCL(ks, ps)))) == Nat.add(LN(CAT(fw)), SUM(ks)) : Nat}:
  Equal.trans(Nat, LN(CAT(LAP(fw, PCL(ks, ps)))), LN(AP(CAT(fw), CAT(PCL(ks, ps)))), Nat.add(LN(CAT(fw)), SUM(ks)),
    Equal.cong(+List<U32>, Nat, z => LN(z), CAT(LAP(fw, PCL(ks, ps))), AP(CAT(fw), CAT(PCL(ks, ps))), cat_lap(fw, PCL(ks, ps))),
    Equal.trans(Nat, LN(AP(CAT(fw), CAT(PCL(ks, ps)))), Nat.add(LN(CAT(fw)), LN(CAT(PCL(ks, ps)))), Nat.add(LN(CAT(fw)), SUM(ks)),
      len_app(CAT(fw), CAT(PCL(ks, ps))),
      Equal.cong(Nat, Nat, z => Nat.add(LN(CAT(fw)), z), LN(CAT(PCL(ks, ps))), SUM(ks), len_pcl(ks, ps))))

def APPN(+a: List<&2, Nat>, +b: List<&2, Nat>) -> List<&2, Nat>: List.append(&2, Nat, a, b)
law sum_app:
  for +a: List<&2, Nat>
  for +b: List<&2, Nat>
  {SUM(APPN(a, b)) == Nat.add(SUM(a), SUM(b)) : Nat}
def sum_app(a, b):
  match a:
    case Nil{}: {==}
    case Con{+m, +t}:
      %Equal.sym(Nat, SUM(APPN(t, b)), Nat.add(SUM(t), SUM(b)), sum_app(t, b)) : {Nat.add(m, _) == Nat.add(Nat.add(m, SUM(t)), SUM(b)) : Nat}
      Equal.sym(Nat, Nat.add(Nat.add(m, SUM(t)), SUM(b)), Nat.add(m, Nat.add(SUM(t), SUM(b))), F.nat__add_assoc(m, SUM(t), SUM(b)))

# The next cursor: F + SUM(ks) + k = F + SUM(ks ++ [k]).
def sum_snoc(+F0: Nat, +ks: List<&2, Nat>, +k: Nat) -> {Nat.add(Nat.add(F0, SUM(ks)), k) == Nat.add(F0, SUM(APPN(ks, [k]))) : Nat}:
  +e1 = Equal.trans(Nat, SUM(APPN(ks, [k])), Nat.add(SUM(ks), Nat.add(k, 0n)), Nat.add(SUM(ks), k), sum_app(ks, [k]),
    Equal.cong(Nat, Nat, z => Nat.add(SUM(ks), z), Nat.add(k, 0n), k, F.nat__add_zero(k)))
  Equal.trans(Nat, Nat.add(Nat.add(F0, SUM(ks)), k), Nat.add(F0, Nat.add(SUM(ks), k)), Nat.add(F0, SUM(APPN(ks, [k]))), F.nat__add_assoc(F0, SUM(ks), k),
    Equal.cong(Nat, Nat, z => Nat.add(F0, z), Nat.add(SUM(ks), k), SUM(APPN(ks, [k])), Equal.sym(Nat, SUM(APPN(ks, [k])), Nat.add(SUM(ks), k), e1)))

# A variable piece a..a+m of the region's L = F + SUM(pre ++ [m] ++ rest) bytes: a + m <= L.
def pc_room(+F0: Nat, +pre: List<&2, Nat>, +m: Nat, +rest: List<&2, Nat>)
    -> {Nat.is_le(Nat.add(Nat.add(F0, SUM(pre)), m), Nat.add(F0, SUM(APPN(APPN(pre, [m]), rest)))) == True{} : Bool}:
  +e1 = sum_snoc(F0, pre, m)
  F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(F0, SUM(APPN(APPN(pre, [m]), rest)))) == True{} : Bool}, Nat.add(F0, SUM(APPN(pre, [m]))), Nat.add(Nat.add(F0, SUM(pre)), m),
    Equal.sym(Nat, Nat.add(Nat.add(F0, SUM(pre)), m), Nat.add(F0, SUM(APPN(pre, [m]))), e1),
    Order.add_left(F0, SUM(APPN(pre, [m])), SUM(APPN(APPN(pre, [m]), rest)),
      F.logic__subst(Nat, z => {Nat.is_le(SUM(APPN(pre, [m])), z) == True{} : Bool}, Nat.add(SUM(APPN(pre, [m])), SUM(rest)), SUM(APPN(APPN(pre, [m]), rest)),
        Equal.sym(Nat, SUM(APPN(APPN(pre, [m]), rest)), Nat.add(SUM(APPN(pre, [m])), SUM(rest)), sum_app(APPN(pre, [m]), rest)),
        Order.below_sum(SUM(APPN(pre, [m])), SUM(rest)))))

# The bytes after a variable piece: a + m + (SUM(rest) + P) = L + P.
def pc_after(+F0: Nat, +pre: List<&2, Nat>, +m: Nat, +rest: List<&2, Nat>, +P: Nat)
    -> {Nat.add(Nat.add(Nat.add(F0, SUM(pre)), m), SUM(APPN(rest, [P]))) == Nat.add(Nat.add(F0, SUM(APPN(APPN(pre, [m]), rest))), P) : Nat}:
  +a = Nat.add(F0, SUM(APPN(pre, [m])))
  +e1 = sum_snoc(F0, pre, m)
  +e2 = Equal.trans(Nat, SUM(APPN(rest, [P])), Nat.add(SUM(rest), Nat.add(P, 0n)), Nat.add(SUM(rest), P), sum_app(rest, [P]),
    Equal.cong(Nat, Nat, z => Nat.add(SUM(rest), z), Nat.add(P, 0n), P, F.nat__add_zero(P)))
  +e3 = Equal.trans(Nat, Nat.add(F0, SUM(APPN(APPN(pre, [m]), rest))), Nat.add(F0, Nat.add(SUM(APPN(pre, [m])), SUM(rest))), Nat.add(a, SUM(rest)),
    Equal.cong(Nat, Nat, z => Nat.add(F0, z), SUM(APPN(APPN(pre, [m]), rest)), Nat.add(SUM(APPN(pre, [m])), SUM(rest)), sum_app(APPN(pre, [m]), rest)),
    Equal.sym(Nat, Nat.add(a, SUM(rest)), Nat.add(F0, Nat.add(SUM(APPN(pre, [m])), SUM(rest))), F.nat__add_assoc(F0, SUM(APPN(pre, [m])), SUM(rest))))
  Equal.trans(Nat, Nat.add(Nat.add(Nat.add(F0, SUM(pre)), m), SUM(APPN(rest, [P]))), Nat.add(a, Nat.add(SUM(rest), P)), Nat.add(Nat.add(F0, SUM(APPN(APPN(pre, [m]), rest))), P),
    Equal.trans(Nat, Nat.add(Nat.add(Nat.add(F0, SUM(pre)), m), SUM(APPN(rest, [P]))), Nat.add(a, SUM(APPN(rest, [P]))), Nat.add(a, Nat.add(SUM(rest), P)),
      Equal.cong(Nat, Nat, z => Nat.add(z, SUM(APPN(rest, [P]))), Nat.add(Nat.add(F0, SUM(pre)), m), a, e1),
      Equal.cong(Nat, Nat, z => Nat.add(a, z), SUM(APPN(rest, [P])), Nat.add(SUM(rest), P), e2)),
    Equal.trans(Nat, Nat.add(a, Nat.add(SUM(rest), P)), Nat.add(Nat.add(a, SUM(rest)), P), Nat.add(Nat.add(F0, SUM(APPN(APPN(pre, [m]), rest))), P),
      Equal.sym(Nat, Nat.add(Nat.add(a, SUM(rest)), P), Nat.add(a, Nat.add(SUM(rest), P)), F.nat__add_assoc(a, SUM(rest), P)),
      Equal.cong(Nat, Nat, z => Nat.add(z, P), Nat.add(a, SUM(rest)), Nat.add(F0, SUM(APPN(APPN(pre, [m]), rest))), Equal.sym(Nat, Nat.add(F0, SUM(APPN(APPN(pre, [m]), rest))), Nat.add(a, SUM(rest)), e3))))

# The bytes of k words taken from a list of at least k.
law len_wt:
  for +k: Nat
  for +W: List<&2, U32>
  for +h: {Nat.is_le(k, List.length(&2, U32, W)) == True{} : Bool}
  {LN(FX.limbs(VS.wtake(k, W))) == A.quad(k) : Nat}
def len_wt(k, W, h):
  match k W:
    case 0n _: {==}
    case 1n+ +p Nil{}: Empty.absurd({LN(FX.limbs(VS.wtake(1n+p, Nil{}))) == A.quad(1n+p) : Nat}, F.logic__false_true(h))
    case 1n+ +p Con{+x, +t}: Equal.cong(Nat, Nat, z => 4n+z, LN(FX.limbs(VS.wtake(p, t))), A.quad(p), len_wt(p, t, h))

law len_wtk:
  for +k: Nat
  for +W: List<&2, U32>
  for +h: {Nat.is_le(k, List.length(&2, U32, W)) == True{} : Bool}
  {F.spec_common__length(U32, VS.wtake(k, W)) == k : Nat}
def len_wtk(k, W, h):
  match k W:
    case 0n _: {==}
    case 1n+ +p Nil{}: Empty.absurd({F.spec_common__length(U32, VS.wtake(1n+p, Nil{})) == 1n+p : Nat}, F.logic__false_true(h))
    case 1n+ +p Con{+x, +t}: F.nat__succ_cong(F.spec_common__length(U32, VS.wtake(p, t)), p, len_wtk(p, t, h))

# ---- the running cursor ------------------------------------------------------------------------------

# O.padd adds when the sum is below 2^31 (a valid encoding's length, any output depth).
def padd_ddW(+a: U32, +b: U32, +dd: Nat, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool},
    +h: {Nat.is_lt(Nat.add(U32.to_nat(a), U32.to_nat(b)), VB.pw(31n)) == True{} : Bool})
    -> {U32.to_nat(O.padd(a, b)) == Nat.add(U32.to_nat(a), U32.to_nat(b)) : Nat}:
  +ha = F.nat__le_lt_trans(U32.to_nat(a), Nat.add(U32.to_nat(a), U32.to_nat(b)), VB.pw(31n), Order.below_sum(U32.to_nat(a), U32.to_nat(b)), h)
  +hb = F.nat__le_lt_trans(U32.to_nat(b), Nat.add(U32.to_nat(a), U32.to_nat(b)), VB.pw(31n), Order.left_below_sum(U32.to_nat(a), U32.to_nat(b)), h)
  %Equal.sym(U32, O.padd(a, b), U32.add(a, b), VE.padd_ok(a, b, VE.winit(31n, VE.bits32(a)), VE.winit(31n, VE.bits32(b)), VE.small_pad(a, 31n, {==}, ha), VE.small_pad(b, 31n, {==}, hb))) :
    {U32.to_nat(_) == Nat.add(U32.to_nat(a), U32.to_nat(b)) : Nat}
  A.add_le(a, b, F.u32__pow2u(31n), F.logic__subst(Nat, z => {Nat.is_le(Nat.add(U32.to_nat(a), U32.to_nat(b)), z) == True{} : Bool}, VB.pw(31n), U32.to_nat(F.u32__pow2u(31n)),
    Equal.sym(Nat, U32.to_nat(F.u32__pow2u(31n)), VB.pw(31n), F.u32__pow2u_value(31n, {==})), F.nat__lt_le(Nat.add(U32.to_nat(a), U32.to_nat(b)), VB.pw(31n), h)))

def padd_dd(+a: U32, +b: U32, +dd: Nat, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +h: {Nat.is_le(Nat.add(U32.to_nat(a), U32.to_nat(b)), A.quad(VB.pw(dd))) == True{} : Bool})
    -> {U32.to_nat(O.padd(a, b)) == Nat.add(U32.to_nat(a), U32.to_nat(b)) : Nat}:
  +k = Nat.add(3n, dd)
  +hk = F.nat__lt_succ_le(dd, 28n, hd)
  +hq = F.nat__le_lt_trans(A.quad(VB.pw(dd)), VB.pw(2n+dd), VB.pw(k), F.nat__le_refl(A.quad(VB.pw(dd))), F.nat__pow2_lt_succ(2n+dd))
  +hs = F.nat__le_lt_trans(Nat.add(U32.to_nat(a), U32.to_nat(b)), A.quad(VB.pw(dd)), VB.pw(k), h, hq)
  +ha = F.nat__le_lt_trans(U32.to_nat(a), Nat.add(U32.to_nat(a), U32.to_nat(b)), VB.pw(k), Order.below_sum(U32.to_nat(a), U32.to_nat(b)), hs)
  +hb = F.nat__le_lt_trans(U32.to_nat(b), Nat.add(U32.to_nat(a), U32.to_nat(b)), VB.pw(k), Order.left_below_sum(U32.to_nat(a), U32.to_nat(b)), hs)
  %Equal.sym(U32, O.padd(a, b), U32.add(a, b), VE.padd_ok(a, b, VE.winit(31n, VE.bits32(a)), VE.winit(31n, VE.bits32(b)), VE.small_pad(a, k, hk, ha), VE.small_pad(b, k, hk, hb))) :
    {U32.to_nat(_) == Nat.add(U32.to_nat(a), U32.to_nat(b)) : Nat}
  A.add_le(a, b, F.u32__pow2u(k), F.logic__subst(Nat, z => {Nat.is_le(Nat.add(U32.to_nat(a), U32.to_nat(b)), z) == True{} : Bool}, VB.pw(k), U32.to_nat(F.u32__pow2u(k)),
    Equal.sym(Nat, U32.to_nat(F.u32__pow2u(k)), VB.pw(k), F.u32__pow2u_value(k, F.nat__le_lt_trans(k, 31n, 32n, hk, {==}))), F.nat__lt_le(Nat.add(U32.to_nat(a), U32.to_nat(b)), VB.pw(k), hs)))

# The cursor after a variable piece of k bytes: F + SUM(ks ++ [k]).
def cnextW(+cur: U32, +sz: U32, +F0: Nat, +ks: List<&2, Nat>, +k: Nat, +dd: Nat, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool},
    +ec: {U32.to_nat(cur) == Nat.add(F0, SUM(ks)) : Nat}, +es: {U32.to_nat(sz) == k : Nat},
    +hb: {Nat.is_lt(Nat.add(Nat.add(F0, SUM(ks)), k), VB.pw(31n)) == True{} : Bool})
    -> {U32.to_nat(O.padd(cur, sz)) == Nat.add(F0, SUM(APPN(ks, [k]))) : Nat}:
  +e1 = Equal.trans(Nat, Nat.add(U32.to_nat(cur), U32.to_nat(sz)), Nat.add(Nat.add(F0, SUM(ks)), U32.to_nat(sz)), Nat.add(Nat.add(F0, SUM(ks)), k),
    Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(sz)), U32.to_nat(cur), Nat.add(F0, SUM(ks)), ec),
    Equal.cong(Nat, Nat, z => Nat.add(Nat.add(F0, SUM(ks)), z), U32.to_nat(sz), k, es))
  +hb2 = F.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(31n)) == True{} : Bool}, Nat.add(Nat.add(F0, SUM(ks)), k), Nat.add(U32.to_nat(cur), U32.to_nat(sz)),
    Equal.sym(Nat, Nat.add(U32.to_nat(cur), U32.to_nat(sz)), Nat.add(Nat.add(F0, SUM(ks)), k), e1), hb)
  Equal.trans(Nat, U32.to_nat(O.padd(cur, sz)), Nat.add(U32.to_nat(cur), U32.to_nat(sz)), Nat.add(F0, SUM(APPN(ks, [k]))), padd_ddW(cur, sz, dd, hd, hb2),
    Equal.trans(Nat, Nat.add(U32.to_nat(cur), U32.to_nat(sz)), Nat.add(Nat.add(F0, SUM(ks)), k), Nat.add(F0, SUM(APPN(ks, [k]))), e1, sum_snoc(F0, ks, k)))

def cnext(+cur: U32, +sz: U32, +F0: Nat, +ks: List<&2, Nat>, +k: Nat, +dd: Nat, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +ec: {U32.to_nat(cur) == Nat.add(F0, SUM(ks)) : Nat}, +es: {U32.to_nat(sz) == k : Nat},
    +hb: {Nat.is_le(Nat.add(Nat.add(F0, SUM(ks)), k), A.quad(VB.pw(dd))) == True{} : Bool})
    -> {U32.to_nat(O.padd(cur, sz)) == Nat.add(F0, SUM(APPN(ks, [k]))) : Nat}:
  +e1 = Equal.trans(Nat, Nat.add(U32.to_nat(cur), U32.to_nat(sz)), Nat.add(Nat.add(F0, SUM(ks)), U32.to_nat(sz)), Nat.add(Nat.add(F0, SUM(ks)), k),
    Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(sz)), U32.to_nat(cur), Nat.add(F0, SUM(ks)), ec),
    Equal.cong(Nat, Nat, z => Nat.add(Nat.add(F0, SUM(ks)), z), U32.to_nat(sz), k, es))
  +hb2 = F.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(dd))) == True{} : Bool}, Nat.add(Nat.add(F0, SUM(ks)), k), Nat.add(U32.to_nat(cur), U32.to_nat(sz)),
    Equal.sym(Nat, Nat.add(U32.to_nat(cur), U32.to_nat(sz)), Nat.add(Nat.add(F0, SUM(ks)), k), e1), hb)
  Equal.trans(Nat, U32.to_nat(O.padd(cur, sz)), Nat.add(U32.to_nat(cur), U32.to_nat(sz)), Nat.add(F0, SUM(APPN(ks, [k]))), padd_dd(cur, sz, dd, hd, hb2),
    Equal.trans(Nat, Nat.add(U32.to_nat(cur), U32.to_nat(sz)), Nat.add(Nat.add(F0, SUM(ks)), k), Nat.add(F0, SUM(APPN(ks, [k]))), e1, sum_snoc(F0, ks, k)))

# The region's pieces: the fixed ones, the variable ones, the trailing zeros.
def sum_region(+fs: List<&2, Nat>, +ks: List<&2, Nat>, +P: Nat) -> {SUM(APPN(fs, APPN(ks, [P]))) == Nat.add(Nat.add(SUM(fs), SUM(ks)), P) : Nat}:
  +e2 = Equal.trans(Nat, SUM(APPN(ks, [P])), Nat.add(SUM(ks), Nat.add(P, 0n)), Nat.add(SUM(ks), P), sum_app(ks, [P]),
    Equal.cong(Nat, Nat, z => Nat.add(SUM(ks), z), Nat.add(P, 0n), P, F.nat__add_zero(P)))
  Equal.trans(Nat, SUM(APPN(fs, APPN(ks, [P]))), Nat.add(SUM(fs), SUM(APPN(ks, [P]))), Nat.add(Nat.add(SUM(fs), SUM(ks)), P), sum_app(fs, APPN(ks, [P])),
    Equal.trans(Nat, Nat.add(SUM(fs), SUM(APPN(ks, [P]))), Nat.add(SUM(fs), Nat.add(SUM(ks), P)), Nat.add(Nat.add(SUM(fs), SUM(ks)), P),
      Equal.cong(Nat, Nat, z => Nat.add(SUM(fs), z), SUM(APPN(ks, [P])), Nat.add(SUM(ks), P), e2),
      Equal.sym(Nat, Nat.add(Nat.add(SUM(fs), SUM(ks)), P), Nat.add(SUM(fs), Nat.add(SUM(ks), P)), F.nat__add_assoc(SUM(fs), SUM(ks), P))))

# A variable piece's end, a + m <= L <= 4 2^dd (for the cursor bound).
def pc_end(+q: Nat, +r: Nat, +L: Nat, +dd: Nat, +x: Nat, +h: {Nat.is_le(x, L) == True{} : Bool},
    +hl: {Nat.is_le(Nat.add(q, WD.NWN(Nat.add(r, L))), VB.pw(dd)) == True{} : Bool}) -> {Nat.is_le(x, A.quad(VB.pw(dd))) == True{} : Bool}:
  F.nat__le_trans(x, L, A.quad(VB.pw(dd)), h,
    F.nat__le_trans(L, Nat.add(Nat.add(A.quad(q), r), L), A.quad(VB.pw(dd)), Order.left_below_sum(Nat.add(A.quad(q), r), L), VRX.xend(q, r, L, dd, hl)))

# An equation, with its type written out.
def EQN(+a: Nat, +b: Nat, +e: {a == b : Nat}) -> {a == b : Nat}: e

# ceil(L / 4) words, as the runtime computes them, for L within a tree of depth k < 29's bytes.
def nw_nat(+L: U32, +k: Nat, +hk: {Nat.is_lt(k, 29n) == True{} : Bool}, +h: {Nat.is_le(U32.to_nat(L), A.quad(VB.pw(k))) == True{} : Bool})
    -> {VC.NW(L) == WD.NWN(U32.to_nat(L)) : Nat}:
  +Q = A.quad(VB.pw(k))
  +h3 = F.nat__le_trans(3n, 4n, Q, {==}, VME4(1n, VB.pw(k), F.nat__pow2_pos(k)))
  +hab = F.nat__le_trans(Nat.add(U32.to_nat(L), 3n), Nat.add(Q, 3n), Nat.add(Q, Q), Order.add_right(U32.to_nat(L), Q, 3n, h), Order.add_left(Q, 3n, Q, h3))
  +hc = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(U32.to_nat(L), 3n), z) == True{} : Bool}, Nat.add(Q, Q), Nat.double(Q), Equal.sym(Nat, Nat.double(Q), Nat.add(Q, Q), F.lru_nat_algebra__double_self(Q)), hab)
  +hd = F.logic__subst(Nat, z => {Nat.is_le(Nat.add(U32.to_nat(L), 3n), z) == True{} : Bool}, VB.pw(Nat.add(3n, k)), O.pow2n(Nat.add(3n, k)), VD.s_pow2_eq(Nat.add(3n, k)), hc)
  +e1 = VD.shrk(2n, U32.add(L, 3))
  +e2 = VD.s_add_nat(L, 3, Nat.add(3n, k), hk, hd)
  Equal.trans(Nat, VC.NW(L), VD.s_rng(2n, U32.to_nat(U32.add(L, 3))), WD.NWN(U32.to_nat(L)), e1,
    Equal.trans(Nat, VD.s_rng(2n, U32.to_nat(U32.add(L, 3))), VD.s_rng(2n, Nat.add(U32.to_nat(L), 3n)), WD.NWN(U32.to_nat(L)),
      Equal.cong(Nat, Nat, z => VD.s_rng(2n, z), U32.to_nat(U32.add(L, 3)), Nat.add(U32.to_nat(L), 3n), e2),
      Equal.cong(Nat, Nat, z => VD.s_rng(2n, z), Nat.add(U32.to_nat(L), 3n), 3n+U32.to_nat(L), F.nat__add_comm(U32.to_nat(L), 3n))))

# ---- the F0-last forms: a container with fixed pieces of codegen/var_cont_enc.py's BIGPIECE bytes or more
# writes its fixed size F0 (a literal) last in every sum, Nat.add(SUM(..), F0), so a comparison of two such
# sums stops at the variable pieces' lengths and never unfolds F0 (Nat.add recurses on its first argument).

# (a + F) + R = (a + R) + F.
def swap_r(+a: Nat, +F0: Nat, +R: Nat) -> {Nat.add(Nat.add(a, F0), R) == Nat.add(Nat.add(a, R), F0) : Nat}:
  Equal.trans(Nat, Nat.add(Nat.add(a, F0), R), Nat.add(a, Nat.add(F0, R)), Nat.add(Nat.add(a, R), F0), F.nat__add_assoc(a, F0, R),
    Equal.trans(Nat, Nat.add(a, Nat.add(F0, R)), Nat.add(a, Nat.add(R, F0)), Nat.add(Nat.add(a, R), F0),
      Equal.cong(Nat, Nat, z => Nat.add(a, z), Nat.add(F0, R), Nat.add(R, F0), F.nat__add_comm(F0, R)),
      Equal.sym(Nat, Nat.add(Nat.add(a, R), F0), Nat.add(a, Nat.add(R, F0)), F.nat__add_assoc(a, R, F0))))

# The next cursor, F0 last: (SUM(ks) + F) + k = SUM(ks ++ [k]) + F.
def sum_snoc_r(+F0: Nat, +ks: List<&2, Nat>, +k: Nat) -> {Nat.add(Nat.add(SUM(ks), F0), k) == Nat.add(SUM(APPN(ks, [k])), F0) : Nat}:
  +e1 = Equal.trans(Nat, SUM(APPN(ks, [k])), Nat.add(SUM(ks), Nat.add(k, 0n)), Nat.add(SUM(ks), k), sum_app(ks, [k]),
    Equal.cong(Nat, Nat, z => Nat.add(SUM(ks), z), Nat.add(k, 0n), k, F.nat__add_zero(k)))
  Equal.trans(Nat, Nat.add(Nat.add(SUM(ks), F0), k), Nat.add(Nat.add(SUM(ks), k), F0), Nat.add(SUM(APPN(ks, [k])), F0), swap_r(SUM(ks), F0, k),
    Equal.cong(Nat, Nat, z => Nat.add(z, F0), Nat.add(SUM(ks), k), SUM(APPN(ks, [k])), Equal.sym(Nat, SUM(APPN(ks, [k])), Nat.add(SUM(ks), k), e1)))

# pc_room, F0 last; the region's size L as its use site names it, equal to SUM(ks) + F0.
def pc_room_r0(+F0: Nat, +pre: List<&2, Nat>, +m: Nat, +rest: List<&2, Nat>)
    -> {Nat.is_le(Nat.add(Nat.add(SUM(pre), F0), m), Nat.add(SUM(APPN(APPN(pre, [m]), rest)), F0)) == True{} : Bool}:
  +e1 = sum_snoc_r(F0, pre, m)
  F.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(SUM(APPN(APPN(pre, [m]), rest)), F0)) == True{} : Bool}, Nat.add(SUM(APPN(pre, [m])), F0), Nat.add(Nat.add(SUM(pre), F0), m),
    Equal.sym(Nat, Nat.add(Nat.add(SUM(pre), F0), m), Nat.add(SUM(APPN(pre, [m])), F0), e1),
    Order.add_right(SUM(APPN(pre, [m])), SUM(APPN(APPN(pre, [m]), rest)), F0,
      F.logic__subst(Nat, z => {Nat.is_le(SUM(APPN(pre, [m])), z) == True{} : Bool}, Nat.add(SUM(APPN(pre, [m])), SUM(rest)), SUM(APPN(APPN(pre, [m]), rest)),
        Equal.sym(Nat, SUM(APPN(APPN(pre, [m]), rest)), Nat.add(SUM(APPN(pre, [m])), SUM(rest)), sum_app(APPN(pre, [m]), rest)),
        Order.below_sum(SUM(APPN(pre, [m])), SUM(rest)))))

def pc_room_r(+F0: Nat, +pre: List<&2, Nat>, +m: Nat, +rest: List<&2, Nat>, +L: Nat, +ks: List<&2, Nat>,
    +eks: {APPN(APPN(pre, [m]), rest) == ks : List<&2, Nat>}, +eL: {Nat.add(SUM(ks), F0) == L : Nat})
    -> {Nat.is_le(Nat.add(Nat.add(SUM(pre), F0), m), L) == True{} : Bool}:
  +e1 = Equal.trans(Nat, Nat.add(SUM(APPN(APPN(pre, [m]), rest)), F0), Nat.add(SUM(ks), F0), L,
    Equal.cong(List<&2, Nat>, Nat, z => Nat.add(SUM(z), F0), APPN(APPN(pre, [m]), rest), ks, eks), eL)
  F.logic__subst(Nat, z => {Nat.is_le(Nat.add(Nat.add(SUM(pre), F0), m), z) == True{} : Bool}, Nat.add(SUM(APPN(APPN(pre, [m]), rest)), F0), L, e1, pc_room_r0(F0, pre, m, rest))

# pc_after, F0 last.
def pc_after_r0(+F0: Nat, +pre: List<&2, Nat>, +m: Nat, +rest: List<&2, Nat>, +P: Nat)
    -> {Nat.add(Nat.add(Nat.add(SUM(pre), F0), m), SUM(APPN(rest, [P]))) == Nat.add(Nat.add(SUM(APPN(APPN(pre, [m]), rest)), F0), P) : Nat}:
  +e1 = sum_snoc_r(F0, pre, m)
  +e2 = Equal.trans(Nat, SUM(APPN(rest, [P])), Nat.add(SUM(rest), Nat.add(P, 0n)), Nat.add(SUM(rest), P), sum_app(rest, [P]),
    Equal.cong(Nat, Nat, z => Nat.add(SUM(rest), z), Nat.add(P, 0n), P, F.nat__add_zero(P)))
  +e3 = sum_app(APPN(pre, [m]), rest)
  +e4 = Equal.trans(Nat, Nat.add(Nat.add(SUM(APPN(pre, [m])), F0), Nat.add(SUM(rest), P)), Nat.add(Nat.add(Nat.add(SUM(APPN(pre, [m])), F0), SUM(rest)), P),
    Nat.add(Nat.add(Nat.add(SUM(APPN(pre, [m])), SUM(rest)), F0), P),
    Equal.sym(Nat, Nat.add(Nat.add(Nat.add(SUM(APPN(pre, [m])), F0), SUM(rest)), P), Nat.add(Nat.add(SUM(APPN(pre, [m])), F0), Nat.add(SUM(rest), P)),
      F.nat__add_assoc(Nat.add(SUM(APPN(pre, [m])), F0), SUM(rest), P)),
    Equal.cong(Nat, Nat, z => Nat.add(z, P), Nat.add(Nat.add(SUM(APPN(pre, [m])), F0), SUM(rest)), Nat.add(Nat.add(SUM(APPN(pre, [m])), SUM(rest)), F0),
      swap_r(SUM(APPN(pre, [m])), F0, SUM(rest))))
  Equal.trans(Nat, Nat.add(Nat.add(Nat.add(SUM(pre), F0), m), SUM(APPN(rest, [P]))), Nat.add(Nat.add(SUM(APPN(pre, [m])), F0), SUM(APPN(rest, [P]))),
    Nat.add(Nat.add(SUM(APPN(APPN(pre, [m]), rest)), F0), P),
    Equal.cong(Nat, Nat, z => Nat.add(z, SUM(APPN(rest, [P]))), Nat.add(Nat.add(SUM(pre), F0), m), Nat.add(SUM(APPN(pre, [m])), F0), e1),
    Equal.trans(Nat, Nat.add(Nat.add(SUM(APPN(pre, [m])), F0), SUM(APPN(rest, [P]))), Nat.add(Nat.add(SUM(APPN(pre, [m])), F0), Nat.add(SUM(rest), P)),
      Nat.add(Nat.add(SUM(APPN(APPN(pre, [m]), rest)), F0), P),
      Equal.cong(Nat, Nat, z => Nat.add(Nat.add(SUM(APPN(pre, [m])), F0), z), SUM(APPN(rest, [P])), Nat.add(SUM(rest), P), e2),
      Equal.trans(Nat, Nat.add(Nat.add(SUM(APPN(pre, [m])), F0), Nat.add(SUM(rest), P)), Nat.add(Nat.add(Nat.add(SUM(APPN(pre, [m])), SUM(rest)), F0), P),
        Nat.add(Nat.add(SUM(APPN(APPN(pre, [m]), rest)), F0), P), e4,
        Equal.cong(Nat, Nat, z => Nat.add(Nat.add(z, F0), P), Nat.add(SUM(APPN(pre, [m])), SUM(rest)), SUM(APPN(APPN(pre, [m]), rest)),
          Equal.sym(Nat, SUM(APPN(APPN(pre, [m]), rest)), Nat.add(SUM(APPN(pre, [m])), SUM(rest)), e3)))))

def pc_after_r(+F0: Nat, +pre: List<&2, Nat>, +m: Nat, +rest: List<&2, Nat>, +P: Nat, +L: Nat, +ks: List<&2, Nat>,
    +eks: {APPN(APPN(pre, [m]), rest) == ks : List<&2, Nat>}, +eL: {Nat.add(SUM(ks), F0) == L : Nat})
    -> {Nat.add(Nat.add(Nat.add(SUM(pre), F0), m), SUM(APPN(rest, [P]))) == Nat.add(L, P) : Nat}:
  +e1 = Equal.trans(Nat, Nat.add(SUM(APPN(APPN(pre, [m]), rest)), F0), Nat.add(SUM(ks), F0), L,
    Equal.cong(List<&2, Nat>, Nat, z => Nat.add(SUM(z), F0), APPN(APPN(pre, [m]), rest), ks, eks), eL)
  F.logic__subst(Nat, z => {Nat.add(Nat.add(Nat.add(SUM(pre), F0), m), SUM(APPN(rest, [P]))) == Nat.add(z, P) : Nat}, Nat.add(SUM(APPN(APPN(pre, [m]), rest)), F0), L, e1,
    pc_after_r0(F0, pre, m, rest, P))

# cnext, F0 last.
def cnext_rW(+cur: U32, +sz: U32, +F0: Nat, +ks: List<&2, Nat>, +k: Nat, +dd: Nat, +hd: {Nat.is_lt(dd, 31n) == True{} : Bool},
    +ec: {U32.to_nat(cur) == Nat.add(SUM(ks), F0) : Nat}, +es: {U32.to_nat(sz) == k : Nat},
    +hb: {Nat.is_lt(Nat.add(Nat.add(SUM(ks), F0), k), VB.pw(31n)) == True{} : Bool})
    -> {U32.to_nat(O.padd(cur, sz)) == Nat.add(SUM(APPN(ks, [k])), F0) : Nat}:
  +e1 = Equal.trans(Nat, Nat.add(U32.to_nat(cur), U32.to_nat(sz)), Nat.add(Nat.add(SUM(ks), F0), U32.to_nat(sz)), Nat.add(Nat.add(SUM(ks), F0), k),
    Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(sz)), U32.to_nat(cur), Nat.add(SUM(ks), F0), ec),
    Equal.cong(Nat, Nat, z => Nat.add(Nat.add(SUM(ks), F0), z), U32.to_nat(sz), k, es))
  +hb2 = F.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(31n)) == True{} : Bool}, Nat.add(Nat.add(SUM(ks), F0), k), Nat.add(U32.to_nat(cur), U32.to_nat(sz)),
    Equal.sym(Nat, Nat.add(U32.to_nat(cur), U32.to_nat(sz)), Nat.add(Nat.add(SUM(ks), F0), k), e1), hb)
  Equal.trans(Nat, U32.to_nat(O.padd(cur, sz)), Nat.add(U32.to_nat(cur), U32.to_nat(sz)), Nat.add(SUM(APPN(ks, [k])), F0), padd_ddW(cur, sz, dd, hd, hb2),
    Equal.trans(Nat, Nat.add(U32.to_nat(cur), U32.to_nat(sz)), Nat.add(Nat.add(SUM(ks), F0), k), Nat.add(SUM(APPN(ks, [k])), F0), e1, sum_snoc_r(F0, ks, k)))

def cnext_r(+cur: U32, +sz: U32, +F0: Nat, +ks: List<&2, Nat>, +k: Nat, +dd: Nat, +hd: {Nat.is_lt(dd, 29n) == True{} : Bool},
    +ec: {U32.to_nat(cur) == Nat.add(SUM(ks), F0) : Nat}, +es: {U32.to_nat(sz) == k : Nat},
    +hb: {Nat.is_le(Nat.add(Nat.add(SUM(ks), F0), k), A.quad(VB.pw(dd))) == True{} : Bool})
    -> {U32.to_nat(O.padd(cur, sz)) == Nat.add(SUM(APPN(ks, [k])), F0) : Nat}:
  +e1 = Equal.trans(Nat, Nat.add(U32.to_nat(cur), U32.to_nat(sz)), Nat.add(Nat.add(SUM(ks), F0), U32.to_nat(sz)), Nat.add(Nat.add(SUM(ks), F0), k),
    Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(sz)), U32.to_nat(cur), Nat.add(SUM(ks), F0), ec),
    Equal.cong(Nat, Nat, z => Nat.add(Nat.add(SUM(ks), F0), z), U32.to_nat(sz), k, es))
  +hb2 = F.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(dd))) == True{} : Bool}, Nat.add(Nat.add(SUM(ks), F0), k), Nat.add(U32.to_nat(cur), U32.to_nat(sz)),
    Equal.sym(Nat, Nat.add(U32.to_nat(cur), U32.to_nat(sz)), Nat.add(Nat.add(SUM(ks), F0), k), e1), hb)
  Equal.trans(Nat, U32.to_nat(O.padd(cur, sz)), Nat.add(U32.to_nat(cur), U32.to_nat(sz)), Nat.add(SUM(APPN(ks, [k])), F0), padd_dd(cur, sz, dd, hd, hb2),
    Equal.trans(Nat, Nat.add(U32.to_nat(cur), U32.to_nat(sz)), Nat.add(Nat.add(SUM(ks), F0), k), Nat.add(SUM(APPN(ks, [k])), F0), e1, sum_snoc_r(F0, ks, k)))

# sum_region, F0 last: the fixed pieces' sizes fs sum to F0.
def sum_region_r(+fs: List<&2, Nat>, +ks: List<&2, Nat>, +P: Nat, +F0: Nat, +eF: {SUM(fs) == F0 : Nat})
    -> {SUM(APPN(fs, APPN(ks, [P]))) == Nat.add(Nat.add(SUM(ks), F0), P) : Nat}:
  Equal.trans(Nat, SUM(APPN(fs, APPN(ks, [P]))), Nat.add(Nat.add(SUM(fs), SUM(ks)), P), Nat.add(Nat.add(SUM(ks), F0), P), sum_region(fs, ks, P),
    Equal.trans(Nat, Nat.add(Nat.add(SUM(fs), SUM(ks)), P), Nat.add(Nat.add(SUM(ks), SUM(fs)), P), Nat.add(Nat.add(SUM(ks), F0), P),
      Equal.cong(Nat, Nat, z => Nat.add(z, P), Nat.add(SUM(fs), SUM(ks)), Nat.add(SUM(ks), SUM(fs)), F.nat__add_comm(SUM(fs), SUM(ks))),
      Equal.cong(Nat, Nat, z => Nat.add(Nat.add(SUM(ks), z), P), SUM(fs), F0, eF)))

# eposv, F0 last.
def eposv_r(+fw: +List<+List<U32>>, +ps: +List<+List<U32>>, +ks: List<&2, Nat>)
    -> {LN(CAT(LAP(fw, PCL(ks, ps)))) == Nat.add(SUM(ks), LN(CAT(fw))) : Nat}:
  Equal.trans(Nat, LN(CAT(LAP(fw, PCL(ks, ps)))), Nat.add(LN(CAT(fw)), SUM(ks)), Nat.add(SUM(ks), LN(CAT(fw))), eposv(fw, ps, ks), F.nat__add_comm(LN(CAT(fw)), SUM(ks)))
