@@ SYMX @@

# ---- positions as x + c (a literal second argument never unfolds) --------------------------------

def eocX(@CW, +hF: {Nat.is_le(@FSn, U32.to_nat(len)) == True{} : Bool}, +c: U32, +k: Nat, +ec: {U32.to_nat(c) == k : Nat}, +hk: {Nat.is_le(k, @FSn) == True{} : Bool})
    -> {U32.to_nat(U32.add(off, c)) == Nat.add(x, k) : Nat}:
  Equal.trans(Nat, U32.to_nat(U32.add(off, c)), Nat.add(k, x), Nat.add(x, k), eoc(@CWA, hF, c, k, ec, hk), FD.nat__add_comm(k, x))

def roomFX(@CW, +hF: {Nat.is_le(@FSn, U32.to_nat(len)) == True{} : Bool}, +c: Nat, +s: Nat, +hc: {Nat.is_le(Nat.add(c, s), @FSn) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(x, c), s), A.quad(VB.pw(d))) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, s), A.quad(VB.pw(d))) == True{} : Bool}, Nat.add(c, x), Nat.add(x, c), FD.nat__add_comm(c, x), roomF(@CWA, hF, c, s, hc))

def rdFX(@CW, +hF: {Nat.is_le(@FSn, U32.to_nat(len)) == True{} : Bool}, +c: U32, +k: Nat, +ec: {U32.to_nat(c) == k : Nat}, +hk: {Nat.is_le(Nat.add(k, 4n), @FSn) == True{} : Bool})
    -> {B.read32(BF(t, n), U32.add(off, c)) == (BF(t, n), UR.RWN(t, Nat.add(x, k))) : B.Buf & U32}:
  FD.logic__subst(Nat, z => {B.read32(BF(t, n), U32.add(off, c)) == (BF(t, n), UR.RWN(t, z)) : B.Buf & U32}, Nat.add(k, x), Nat.add(x, k), FD.nat__add_comm(k, x), rdF(@CWA, hF, c, k, ec, hk))

def splitX(+t: FD.array__Tree<U32>, +x: Nat, +c: Nat, +s: Nat, +r: Nat)
    -> {UW.WX(t, Nat.add(x, c), Nat.add(s, r)) == List.append(&2, U32, UW.WX(t, Nat.add(x, c), s), UW.WX(t, Nat.add(x, Nat.add(c, s)), r)) : +List<U32>}:
  +e = Equal.trans(Nat, Nat.add(s, Nat.add(x, c)), Nat.add(x, Nat.add(s, c)), Nat.add(x, Nat.add(c, s)), FD.lru_nat_algebra__add_swap(s, x, c),
    Equal.cong(Nat, Nat, z => Nat.add(x, z), Nat.add(s, c), Nat.add(c, s), FD.nat__add_comm(s, c)))
  FD.logic__subst(Nat, z => {UW.WX(t, Nat.add(x, c), Nat.add(s, r)) == List.append(&2, U32, UW.WX(t, Nat.add(x, c), s), UW.WX(t, z, r)) : +List<U32>}, Nat.add(s, Nat.add(x, c)), Nat.add(x, Nat.add(c, s)), e,
    UW.splitWX(t, Nat.add(x, c), s, r))

def splitXe(+t: FD.array__Tree<U32>, +x: Nat, +c: Nat, +s: Nat, +r: Nat, +T: Nat, +c2: Nat, +eT: {Nat.add(s, r) == T : Nat}, +e2: {Nat.add(c, s) == c2 : Nat})
    -> {UW.WX(t, Nat.add(x, c), T) == List.append(&2, U32, UW.WX(t, Nat.add(x, c), s), UW.WX(t, Nat.add(x, c2), r)) : +List<U32>}:
  %eT : {UW.WX(t, Nat.add(x, c), _) == List.append(&2, U32, UW.WX(t, Nat.add(x, c), s), UW.WX(t, Nat.add(x, c2), r)) : +List<U32>}
  %e2 : {UW.WX(t, Nat.add(x, c), Nat.add(s, r)) == List.append(&2, U32, UW.WX(t, Nat.add(x, c), s), UW.WX(t, Nat.add(x, _), r)) : +List<U32>}
  splitX(t, x, c, s, r)

def splitR(+t: FD.array__Tree<U32>, +x: Nat, +s: Nat, +r: Nat)
    -> {UW.WX(t, x, Nat.add(s, r)) == List.append(&2, U32, UW.WX(t, x, s), UW.WX(t, Nat.add(x, s), r)) : +List<U32>}:
  FD.logic__subst(Nat, z => {UW.WX(t, x, Nat.add(s, r)) == List.append(&2, U32, UW.WX(t, x, s), UW.WX(t, z, r)) : +List<U32>}, Nat.add(s, x), Nat.add(x, s), FD.nat__add_comm(s, x), UW.splitWX(t, x, s, r))

def subX(+t: FD.array__Tree<U32>, +x: Nat, +k: Nat, +m: Nat, +L: Nat, +hl: {Nat.is_le(Nat.add(k, m), L) == True{} : Bool})
    -> {VS.bt(m, VS.bdr(k, UW.WX(t, x, L))) == UW.WX(t, Nat.add(x, k), m) : +List<U32>}:
  FD.logic__subst(Nat, z => {VS.bt(m, VS.bdr(k, UW.WX(t, x, L))) == UW.WX(t, z, m) : +List<U32>}, Nat.add(k, x), Nat.add(x, k), FD.nat__add_comm(k, x), UW.subWX(t, x, k, m, L, hl))

# The window's k .. k + s (k + s <= len) at x + k.
def room4(@CW, +k: Nat, +s: Nat, +hk: {Nat.is_le(Nat.add(k, s), U32.to_nat(len)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(x, k), s), A.quad(VB.pw(d))) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, Nat.add(x, Nat.add(k, s)), Nat.add(Nat.add(x, k), s),
    Equal.sym(Nat, Nat.add(Nat.add(x, k), s), Nat.add(x, Nat.add(k, s)), FD.nat__add_assoc(x, k, s)),
    FD.nat__le_trans(Nat.add(x, Nat.add(k, s)), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.add_left(x, Nat.add(k, s), U32.to_nat(len), hk), hw))

# The offset word at k: its limbs are the digits the layout puts there.
def offwX(@CW, +k: Nat, +v: Nat, +hk: {Nat.is_le(Nat.add(k, 4n), U32.to_nat(len)) == True{} : Bool}, +hv: {Nat.is_le(v, U32.to_nat(len)) == True{} : Bool},
    +eb: {VS.bt(4n, VS.bdr(k, UW.WX(t, x, U32.to_nat(len)))) == N.digits(4n, v) : +List<U32>})
    -> {U32.to_nat(UR.RWN(t, Nat.add(x, k))) == v : Nat}:
  +P = Nat.add(x, k)
  VG.digits_word(UR.RWN(t, P), v, VMR.fitsn(d, len, v, FD.nat__lt_trans(d, 28n, 29n, hd, {==}),
      FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.left_below_sum(x, U32.to_nat(len)), hw), hv),
    Equal.trans(+List<U32>, F.limbs([UR.RWN(t, P)]), UW.WX(t, P, 4n), N.digits(4n, v), UR.rwn_bytes(d, t, P, pf, room4(@CWA, k, 4n, hk)),
      Equal.trans(+List<U32>, UW.WX(t, P, 4n), VS.bt(4n, VS.bdr(k, UW.WX(t, x, U32.to_nat(len)))), N.digits(4n, v),
        Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(k, UW.WX(t, x, U32.to_nat(len)))), UW.WX(t, P, 4n), subX(t, x, k, 4n, U32.to_nat(len), hk)), eb)))

@@ common_text @@

def le_nat(+a: U32, +b: U32, +h: {U32.is_le(a, b) == ${TRUE}}) -> {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == ${TRUE}}:
  FD.logic__subst(Bool, z => {z == ${TRUE}}, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b), h)

def and_l(+a: Bool, +b: Bool, +h: {Bool.and(a, b) == ${TRUE}}) -> {a == ${TRUE}}: FD.logic__and_left(a, b, h)
def and_r(+a: Bool, +b: Bool, +h: {Bool.and(a, b) == ${TRUE}}) -> {b == ${TRUE}}: FD.logic__and_right(a, b, h)

# A byte position o <= len of the window, as an offset: off + o at o + x.
def eoj(${CW}, +o: U32, +h: {Nat.is_le(U32.to_nat(o), U32.to_nat(len)) == ${TRUE}})
    -> {U32.to_nat(U32.add(off, o)) == Nat.add(U32.to_nat(o), x) : Nat}:
  +hl = FD.nat__le_trans(Nat.add(U32.to_nat(o), x), Nat.add(U32.to_nat(len), x), ${PW}, Order.add_right(U32.to_nat(o), U32.to_nat(len), x, h),
    FD.logic__subst(Nat, z => {Nat.is_le(z, ${PW}) == ${TRUE}}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw))
  VB.add_at(off, o, x, 3n+d, eo, FD.nat__lt_trans(3n+d, 31n, 32n, hd, {==}), VB.le_pw_lt(Nat.add(U32.to_nat(o), x), 2n+d, hl))

def alg(+o: Nat, +x: Nat, +e: Nat, +h: {Nat.is_le(o, e) == ${TRUE}}) -> {Nat.add(Nat.add(o, x), Nat.sub(e, o)) == Nat.add(x, e) : Nat}:
  %Equal.sym(Nat, Nat.add(Nat.add(o, x), Nat.sub(e, o)), Nat.add(o, Nat.add(x, Nat.sub(e, o))), FD.nat__add_assoc(o, x, Nat.sub(e, o))) : {_ == Nat.add(x, e) : Nat}
  %Equal.sym(Nat, Nat.add(o, Nat.add(x, Nat.sub(e, o))), Nat.add(x, Nat.add(o, Nat.sub(e, o))), FD.lru_nat_algebra__add_swap(o, x, Nat.sub(e, o))) : {_ == Nat.add(x, e) : Nat}
  %Equal.sym(Nat, Nat.add(o, Nat.sub(e, o)), e, FD.nat__sub_add(e, o, h)) : {Nat.add(x, _) == Nat.add(x, e) : Nat}
  {==}

# The window [a, b) of the window (a <= b <= len): its offset, and its room.
def eoW(${CW}, +a: U32, +b: U32, +h1: {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == ${TRUE}}, +h2: {Nat.is_le(U32.to_nat(b), U32.to_nat(len)) == ${TRUE}})
    -> {U32.to_nat(U32.add(off, a)) == Nat.add(U32.to_nat(a), x) : Nat}:
  eoj(${CWA}, a, FD.nat__le_trans(U32.to_nat(a), U32.to_nat(b), U32.to_nat(len), h1, h2))

def hwj(${CW}, +o: U32, +e: U32, +h1: {Nat.is_le(U32.to_nat(o), U32.to_nat(e)) == ${TRUE}}, +h2: {Nat.is_le(U32.to_nat(e), U32.to_nat(len)) == ${TRUE}})
    -> {Nat.is_le(Nat.add(Nat.add(U32.to_nat(o), x), U32.to_nat(U32.sub(e, o))), ${PW}) == ${TRUE}}:
  %Equal.sym(Nat, U32.to_nat(U32.sub(e, o)), Nat.sub(U32.to_nat(e), U32.to_nat(o)), FD.u32__sub_nat(e, o, h1)) : {Nat.is_le(Nat.add(Nat.add(U32.to_nat(o), x), _), ${PW}) == ${TRUE}}
  %Equal.sym(Nat, Nat.add(Nat.add(U32.to_nat(o), x), Nat.sub(U32.to_nat(e), U32.to_nat(o))), Nat.add(x, U32.to_nat(e)), alg(U32.to_nat(o), x, U32.to_nat(e), h1)) :
    {Nat.is_le(_, ${PW}) == ${TRUE}}
  FD.nat__le_trans(Nat.add(x, U32.to_nat(e)), Nat.add(x, U32.to_nat(len)), ${PW}, Order.add_left(x, U32.to_nat(e), U32.to_nat(len), h2), hw)

# Room for s bytes at c + x, for c + s <= ${FS} <= len.
def roomF(${CW}, +hF: {Nat.is_le(${FSN}, U32.to_nat(len)) == ${TRUE}}, +c: Nat, +s: Nat, +hc: {Nat.is_le(Nat.add(c, s), ${FSN}) == ${TRUE}})
    -> {Nat.is_le(Nat.add(Nat.add(c, x), s), ${PW}) == ${TRUE}}:
  UR.roomf(x, U32.to_nat(len), c, s, ${PW}, hw, FD.nat__le_trans(Nat.add(c, s), ${FSN}, U32.to_nat(len), hc, hF))

# off + c at c + x, for c <= ${FS} <= len.
def eoc(${CW}, +hF: {Nat.is_le(${FSN}, U32.to_nat(len)) == ${TRUE}}, +c: U32, +k: Nat, +ec: {U32.to_nat(c) == k : Nat}, +hk: {Nat.is_le(k, ${FSN}) == ${TRUE}})
    -> {U32.to_nat(U32.add(off, c)) == Nat.add(k, x) : Nat}:
  %ec : {U32.to_nat(U32.add(off, c)) == Nat.add(_, x) : Nat}
  eoj(${CWA}, c, FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(len)) == ${TRUE}}, k, U32.to_nat(c), Equal.sym(Nat, U32.to_nat(c), k, ec), FD.nat__le_trans(k, ${FSN}, U32.to_nat(len), hk, hF)))

# The header word at off + c (c + 4 <= ${FS} <= len).
def rdF(${CW}, +hF: {Nat.is_le(${FSN}, U32.to_nat(len)) == ${TRUE}}, +c: U32, +k: Nat, +ec: {U32.to_nat(c) == k : Nat}, +hk: {Nat.is_le(Nat.add(k, 4n), ${FSN}) == ${TRUE}})
    -> {B.read32(${BUF}, U32.add(off, c)) == (${BUF}, UR.RWN(t, Nat.add(k, x))) : B.Buf & U32}:
  UR.rwx(d, t, n, U32.add(off, c), Nat.add(k, x), eoc(${CWA}, hF, c, k, ec, FD.nat__le_trans(k, Nat.add(k, 4n), ${FSN}, Order.below_sum(k, 4n), hk)),
    FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf, roomF(${CWA}, hF, k, 4n, hk))

@@ OFFW @@

# The four window bytes at k are the limbs of the word at x + k.
def wbk(@CW, +k: Nat, +L2: Nat, +el: {U32.to_nat(len) == Nat.add(k, 4n+L2) : Nat},
    +hk: {Nat.is_le(Nat.add(Nat.add(k, x), 4n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {VS.bt(4n, VS.bdr(k, UW.WX(t, x, U32.to_nat(len)))) == F.limbs([UR.RWN(t, Nat.add(k, x))]) : +List<U32>}:
  %Equal.sym(Nat, U32.to_nat(len), Nat.add(k, 4n+L2), el) : {VS.bt(4n, VS.bdr(k, UW.WX(t, x, _))) == F.limbs([UR.RWN(t, Nat.add(k, x))]) : +List<U32>}
  VRC.wbytes(d, t, x, k, L2, pf, hk)

# The offset word at k: its limbs are the digits the layout puts there.
def offw(@CW, +k: Nat, +L2: Nat, +v: Nat, +el: {U32.to_nat(len) == Nat.add(k, 4n+L2) : Nat}, +hv: {Nat.is_le(v, U32.to_nat(len)) == True{} : Bool},
    +eb: {VS.bt(4n, VS.bdr(k, UW.WX(t, x, U32.to_nat(len)))) == N.digits(4n, v) : +List<U32>})
    -> {U32.to_nat(UR.RWN(t, Nat.add(k, x))) == v : Nat}:
  +hl = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, z), A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(len), Nat.add(k, 4n+L2), el, hw)
  +le0 = Order.add_left(k, Nat.add(x, 4n), Nat.add(x, 4n+L2), Order.add_left(x, 4n, 4n+L2, Order.below_sum(4n, L2)))
  +le1 = FD.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(k, Nat.add(x, 4n+L2))) == True{} : Bool}, Nat.add(k, Nat.add(x, 4n)), Nat.add(Nat.add(k, x), 4n),
    Equal.sym(Nat, Nat.add(Nat.add(k, x), 4n), Nat.add(k, Nat.add(x, 4n)), FD.nat__add_assoc(k, x, 4n)), le0)
  +le2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(Nat.add(k, x), 4n), z) == True{} : Bool}, Nat.add(k, Nat.add(x, 4n+L2)), Nat.add(x, Nat.add(k, 4n+L2)),
    Equal.sym(Nat, Nat.add(x, Nat.add(k, 4n+L2)), Nat.add(k, Nat.add(x, 4n+L2)), FD.lru_nat_algebra__add_swap(x, k, 4n+L2)), le1)
  +hk = FD.nat__le_trans(Nat.add(Nat.add(k, x), 4n), Nat.add(x, Nat.add(k, 4n+L2)), A.quad(VB.pw(d)), le2, hl)
  VG.digits_word(UR.RWN(t, Nat.add(k, x)), v, VMR.fitsn(d, len, v, FD.nat__lt_trans(d, 28n, 29n, hd, {==}),
      FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.left_below_sum(x, U32.to_nat(len)), hw), hv),
    Equal.trans(+List<U32>, F.limbs([UR.RWN(t, Nat.add(k, x))]), VS.bt(4n, VS.bdr(k, UW.WX(t, x, U32.to_nat(len)))), N.digits(4n, v),
      Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(k, UW.WX(t, x, U32.to_nat(len)))), F.limbs([UR.RWN(t, Nat.add(k, x))]), wbk(@CWA, k, L2, el, hk)),
      eb))

@@ PB_LEMMAS @@

# ---- the progressive bit lists' representation bound (proofs/obj/vpb29.bend): each pbits child's window
# [O, E) takes the premise "E <= len implies E - O <= PMAX" (Nat.sub: nothing wraps) ----

def orR(+a: Bool, +b: Bool, +ha: {a == False{} : Bool}, +h: {Bool.or(a, b) == True{} : Bool}) -> {b == True{} : Bool}:
  match a:
    case False{}: h
    case True{}: Empty.absurd({b == True{} : Bool}, FD.logic__false_true(Equal.sym(Bool, True{}, False{}, ha)))

# inside the window (O <= E <= len): the child's length is at most PMAX
def hPc(+len: U32, +o: U32, +e: U32, +h1: {Nat.is_le(U32.to_nat(o), U32.to_nat(e)) == True{} : Bool}, +h2: {Nat.is_le(U32.to_nat(e), U32.to_nat(len)) == True{} : Bool},
    +hP: {Bool.or(Nat.is_lt(U32.to_nat(len), U32.to_nat(e)), Nat.is_le(Nat.sub(U32.to_nat(e), U32.to_nat(o)), U32.to_nat(VP.PMAX()))) == True{} : Bool})
    -> {U32.is_le(U32.sub(e, o), VP.PMAX()) == True{} : Bool}:
  +hs = orR(Nat.is_lt(U32.to_nat(len), U32.to_nat(e)), Nat.is_le(Nat.sub(U32.to_nat(e), U32.to_nat(o)), U32.to_nat(VP.PMAX())), FD.nat__le_not_lt(U32.to_nat(len), U32.to_nat(e), h2), hP)
  +hn = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(VP.PMAX())) == True{} : Bool}, Nat.sub(U32.to_nat(e), U32.to_nat(o)), U32.to_nat(U32.sub(e, o)),
    Equal.sym(Nat, U32.to_nat(U32.sub(e, o)), Nat.sub(U32.to_nat(e), U32.to_nat(o)), FD.u32__sub_nat(e, o, h1)), hs)
  FD.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(U32.sub(e, o)), U32.to_nat(VP.PMAX())), U32.is_le(U32.sub(e, o), VP.PMAX()),
    Equal.sym(Bool, U32.is_le(U32.sub(e, o), VP.PMAX()), Nat.is_le(U32.to_nat(U32.sub(e, o)), U32.to_nat(VP.PMAX())), VB.le_u32n(U32.sub(e, o), VP.PMAX())), hn)

# the premise from a window of at most PMAX bytes (len <= PMAX): E <= len gives E - O <= E <= len
def hPw(+len: U32, +o: U32, +e: U32, +hl: {U32.is_le(len, VP.PMAX()) == True{} : Bool}, +c: Bool, +ec: {Nat.is_lt(U32.to_nat(len), U32.to_nat(e)) == c : Bool})
    -> {Bool.or(c, Nat.is_le(Nat.sub(U32.to_nat(e), U32.to_nat(o)), U32.to_nat(VP.PMAX()))) == True{} : Bool}:
  match c:
    case True{}: {==}
    case False{}:
      +hn = FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(len, VP.PMAX()), Nat.is_le(U32.to_nat(len), U32.to_nat(VP.PMAX())), VB.le_u32n(len, VP.PMAX()), hl)
      FD.nat__le_trans(Nat.sub(U32.to_nat(e), U32.to_nat(o)), U32.to_nat(len), U32.to_nat(VP.PMAX()),
        FD.nat__le_trans(Nat.sub(U32.to_nat(e), U32.to_nat(o)), U32.to_nat(e), U32.to_nat(len), FD.u32half__sub_le(U32.to_nat(e), U32.to_nat(o)),
          FD.nat__not_lt_le(U32.to_nat(len), U32.to_nat(e), ec)), hn)

@@ PA_LEMMAS @@

# a guarded premise Bool.or(Bool.or(c1, c2), y) with c1, c2 False is y
def orIn(+c1: Bool, +c2: Bool, +y: Bool, +h1: {c1 == False{} : Bool}, +h2: {c2 == False{} : Bool}, +h: {Bool.or(Bool.or(c1, c2), y) == True{} : Bool}) -> {y == True{} : Bool}:
  match c1 c2:
    case False{} False{}: h
    case True{} _: Empty.absurd({y == True{} : Bool}, FD.logic__false_true(Equal.sym(Bool, True{}, False{}, h1)))
    case False{} True{}: Empty.absurd({y == True{} : Bool}, FD.logic__false_true(Equal.sym(Bool, True{}, False{}, h2)))

@@ pa_old_text @@

def paOld${j}(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +a: U32, +b: U32, +hl: {U32.is_le(len, VP.PMAX()) == ${T}},
    +c1: Bool, +e1: {Nat.is_lt(U32.to_nat(b), U32.to_nat(a)) == c1 : Bool}, +c2: Bool, +e2: {Nat.is_lt(U32.to_nat(len), U32.to_nat(b)) == c2 : Bool})
    -> {Bool.or(Bool.or(c1, c2), CH${j}.PALL(t, Nat.add(U32.to_nat(a), x), U32.sub(b, a))) == ${T}}:
  match c1 c2:
    case True{} _: {==}
    case False{} True{}: {==}
    case False{} False{}:
      +hab = FD.nat__not_lt_le(U32.to_nat(b), U32.to_nat(a), e1)
      +hbl = FD.nat__not_lt_le(U32.to_nat(len), U32.to_nat(b), e2)
      +hn = FD.logic__subst(Bool, z => {z == ${T}}, U32.is_le(len, VP.PMAX()), Nat.is_le(U32.to_nat(len), U32.to_nat(VP.PMAX())), VB.le_u32n(len, VP.PMAX()), hl)
      +hs = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(VP.PMAX())) == ${T}}, Nat.sub(U32.to_nat(b), U32.to_nat(a)), U32.to_nat(U32.sub(b, a)),
        Equal.sym(Nat, U32.to_nat(U32.sub(b, a)), Nat.sub(U32.to_nat(b), U32.to_nat(a)), FD.u32__sub_nat(b, a, hab)),
        FD.nat__le_trans(Nat.sub(U32.to_nat(b), U32.to_nat(a)), U32.to_nat(len), U32.to_nat(VP.PMAX()),
          FD.nat__le_trans(Nat.sub(U32.to_nat(b), U32.to_nat(a)), U32.to_nat(b), U32.to_nat(len), FD.u32half__sub_le(U32.to_nat(b), U32.to_nat(a)), hbl), hn))
      +hle = FD.logic__subst(Bool, z => {z == ${T}}, Nat.is_le(U32.to_nat(U32.sub(b, a)), U32.to_nat(VP.PMAX())), U32.is_le(U32.sub(b, a), VP.PMAX()),
        Equal.sym(Bool, U32.is_le(U32.sub(b, a), VP.PMAX()), Nat.is_le(U32.to_nat(U32.sub(b, a)), U32.to_nat(VP.PMAX())), VB.le_u32n(U32.sub(b, a), VP.PMAX())), hs)
      CH${j}.pall_old(t, Nat.add(U32.to_nat(a), x), U32.sub(b, a), hle)

@@ EUDEFS_lines @@
def wf${q}() -> {LY.WFS(WSS${q}()) == U32.to_nat(${R}) : Nat}:
  Equal.trans(Nat, LY.WFS(WSS${q}()), Nat.add(${L.SZ(sz[q])}, U32.to_nat(${R1})), U32.to_nat(${R}), VA.wfs_c(${wv[q]}, WSS${q + 1}(), ${L.SZ(sz[q])}, U32.to_nat(${R1}), {==}, wf${q + 1}()),
    VA.stpL(${sz[q]}, ${R1}, ${R}, ${L.SZ(sz[q])}, ${L.ES(sz[q])}, {==}, {==}))
@@ EUDEFS_lines_2 @@
def wp${i}_${q}() -> {LY.WPOS(WSS${q}(), ${i - q}n) == U32.to_nat(${D}) : Nat}:
  Equal.trans(Nat, LY.WPOS(WSS${q}(), ${i - q}n), Nat.add(${L.SZ(sz[q])}, U32.to_nat(${D1})), U32.to_nat(${D}), VA.wpos_c(${wv[q]}, WSS${q + 1}(), ${i - q - 1}n, ${L.SZ(sz[q])}, U32.to_nat(${D1}), {==}, wp${i}_${q + 1}()),
    VA.stpL(${sz[q]}, ${D1}, ${D}, ${L.SZ(sz[q])}, ${L.ES(sz[q])}, {==}, {==}))
@@ defs_text_lines @@

# The fixed part is there, the first offset is ${L.FS}, the offsets are in order inside
# the window, and each variable field's window passes its child's check.
def CHKw(${TXO}) -> Bool: K0(${TXOA})

@@ facts_text_lines @@
def hFc(${TXO}, ${H}) -> {Nat.is_le(${L.FSN}, U32.to_nat(len)) == ${TRUE}}: ${LEF(L, 'it0(' + TXOA + ', h)')}
def eO0(${TXO}, ${H}) -> {U32.to_nat(${L.O(0)}) == ${L.FSN} : Nat}:
  Equal.cong(U32, Nat, z => U32.to_nat(z), ${L.O(0)}, ${L.FS}, FD.u32alg__eq_of(${L.O(0)}, ${L.FS}, it1(${TXOA}, h)))
@@ facts_text_lines_2 @@
def eoJ${j}(${CW}, ${H}) -> {U32.to_nat(${L.FJ(j)}) == ${L.XJ(j)} : Nat}: eoW(${CWA}, ${L.O(j)}, ${E}, r1${j}(${TXOA}, h), r2${j}(${TXOA}, h))
def hwJ${j}(${CW}, ${H}) -> {Nat.is_le(Nat.add(${L.XJ(j)}, U32.to_nat(${L.LJ(j)})), ${PW}) == ${TRUE}}: hwj(${CWA}, ${L.O(j)}, ${E}, r1${j}(${TXOA}, h), r2${j}(${TXOA}, h))
def itD${j}(${TXO}, ${H}) -> {CH${j}.CHKw(t, ${L.XJ(j)}, ${L.FJ(j)}, ${L.LJ(j)}) == ${TRUE}}: it${k + 1 + len(L.fchk) + j}(${TXOA}, h)
def eE${j}(${TXO}, ${H}) -> {U32.to_nat(${E}) == Nat.add(U32.to_nat(${L.O(j)}), U32.to_nat(${L.LJ(j)})) : Nat}:
  Equal.sym(Nat, Nat.add(U32.to_nat(${L.O(j)}), U32.to_nat(U32.sub(${E}, ${L.O(j)}))), U32.to_nat(${E}), VM.sub_eq(${E}, ${L.O(j)}, VMR.u32le(${L.O(j)}, ${E}, r1${j}(${TXOA}, h))))
@@ validator_text_lines_4 @@
def okc${i}(${CW}, ${decl}, +b: Bool, +eb: {IT${i + 1}(${TXOA}) == b : Bool}) -> {${cur} == (${BUF}, b) : B.Buf & Bool}:
  match b:
    case True{}: {==}
    case False{}: {==}

@@ validator_text_lines_3 @@
def okc${i}(${CW}, ${decl}, +b: Bool, +eb: {IT${i + 1}(${TXOA}) == b : Bool}) -> {${cur} == (${BUF}, ${RES}) : B.Buf & Bool}:
  match b:
    case False{}: {==}
    case True{}:
@@ validator_text_lines_5 @@
      %Equal.sym(B.Buf & Bool, T.${f['rt']}_ok_at(${BUF}, U32.add(off, ${c})), (${BUF}, ${f['fa']}.CHK(t, ${L.pos(c)})),
          ${f['fa']}.ok(d, t, n, U32.add(off, ${c}), ${L.pos(c)}, ${L.EOC(c)}, hd, pf, ${L.ROOM(c, f['rs'])})) :
        {${Tn}_v${i + 1}(off, len, ${OS(k - 1)}, _) == ${GOALT}}
@@ validator_text_lines_6 @@
      %Equal.sym(B.Buf & Bool, ${okf}(${BUF}, ${L.FJ(j)}, ${L.LJ(j)}), (${BUF}, CH${j}.CHKw(t, ${L.XJ(j)}, ${L.FJ(j)}, ${L.LJ(j)})),
          CH${j}.ok_evalw(d, t, n, ${L.XJ(j)}, ${L.FJ(j)}, ${L.LJ(j)}, eoW(${CWA}, ${L.O(j)}, ${L.E(j)}, ${h1}, ${h2}), hd,
            hwj(${CWA}, ${L.O(j)}, ${L.E(j)}, ${h1}, ${h2}), pf)) :
        {${Tn}_v${i + 1}(off, len, ${OS(k - 1)}, _) == ${GOALT}}
@@ validator_text_lines @@
def okl(${CW}, +a: Bool, +ea: {IT0(${TXOA}) == a : Bool})
    -> {${Tn}_ok_len(a, ${BUF}, off, len) == (${BUF}, Bool.and(a, K1(${TXOA}))) : B.Buf & Bool}:
  match a:
    case False{}: {==}
    case True{}:
      +hF = ${LEF(L, 'ea')}
@@ validator_text_lines_2 @@
      %Equal.sym(B.Buf & U32, B.read32(${BUF}, U32.add(off, ${c0})), (${BUF}, ${L.O(0)}), ${L.RD(c0)}) :
        {${Tn}_v0(off, len, _) == (${BUF}, K1(${TXOA})) : B.Buf & Bool}
      okc0(${CWA}, hF, IT1(${TXOA}), {==})

# The validator on the window returns the buffer and CHKw.
def ok_evalw(${CW}) -> {${Tn}_ok(${BUF}, off, len) == (${BUF}, CHKw(t, x, off, len)) : B.Buf & Bool}:
  okl(${CWA}, IT0(${TXOA}), {==})

@@ fieldset_reader_lines @@
  %Equal.sym(${ty}, ${call}, (${BUF}, ${o}),
      ${prf}) :
    {T.${prefix}_rd${len(vs) + q}(${pre}, ${hole}) == ${RHS}}
@@ reader_text_lines_2 @@
def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> ${Tn}: ${OBJ}

# The reader on the window, when the checks hold.
def readw(${CW}, ${HCHK}) -> {${Tn}_read(${BUF}, off, len) == (${BUF}, OBJw(d, t, x, off, len)) : B.Buf & ${Tn}}:
  rd_all(${CWA}, hchk)

@@ reader_text_lines @@
def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> ${Tn}: ${OBJ}

# The reader on the window, when the checks hold.
@@ sym_header_text_lines @@
  %Equal.sym(+List<Maybe<&2, Nat>>, ${full}, ${WS}, {==}) : {_ == ${WS} : +List<Maybe<&2, Nat>>}
  {==}

def efsw(${CW}, ${H}) -> {Layout.fixed_size(${PSV}) == ${FSN} : Nat}:
  Equal.trans(Nat, Layout.fixed_size(${PSV}), LY.WFS(${WS}), ${FSN}, Equal.trans(Nat, Layout.fixed_size(${PSV}), LY.WFS(LY.WID(${PSV})), LY.WFS(${WS}), LY.fs_w(${PSV}),
    Equal.cong(+List<Maybe<&2, Nat>>, Nat, z => LY.WFS(z), LY.WID(${PSV}), ${WS}, ewidw(${CWA}, h))), wf0())

@@ sym_header_text_lines_2 @@
# The fixed region: the fixed fields' slices and the offset words, the window's first ${FS} bytes.
def hdrE(${CW}, ${H}) -> {LY.HDRW(${PSV}, ${OSL}) == UW.WX(t, x, ${FSN}) : +List<U32>}:
  +hF = hFc(${TXOA}, h)
  %Equal.trans(Nat, Nat.add(x, U32.to_nat(0)), Nat.add(x, 0n), x, {==}, FD.nat__add_zero(x)) : {LY.HDRW(${PSV}, ${OSL}) == UW.WX(t, _, ${FSN}) : +List<U32>}
@@ sym_schema_text_lines @@
def isc(${SVE}) -> {SH.is_${CK}(sv) == True{} : Bool}:
  FD.logic__subst(S.Schema, z => {SH.is_${CK}(z) == True{} : Bool}, ${X}, sv, Equal.sym(S.Schema, sv, ${X}, esv), {==})
def fsn(${SVE}) -> {SS.fixed_size(SH.${CK}_fields(sv)) == None{} : Maybe<&2, Nat>}:
  FD.logic__subst(S.Schema, z => {SS.fixed_size(SH.${CK}_fields(z)) == None{} : Maybe<&2, Nat>}, ${X}, sv, Equal.sym(S.Schema, sv, ${X}, esv), {==})
@@ sym_schema_text_lines_3 @@
def es${i}(${SVE}) -> {HD${i}(sv) == ${L.spec(f)} : S.Schema}:
  FD.logic__subst(S.Schema, z => {HD${i}(z) == ${L.spec(f)} : S.Schema}, ${X}, sv, Equal.sym(S.Schema, sv, ${X}, esv), {==})
def isch${i}(${SVE}) -> {SH.is_Chain(TL${i}(sv)) == True{} : Bool}:
  FD.logic__subst(S.Schema, z => {SH.is_Chain(TL${i}(z)) == True{} : Bool}, ${X}, sv, Equal.sym(S.Schema, sv, ${X}, esv), {==})
@@ sym_schema_text_lines_2 @@
def isend(${SVE}) -> {SH.is_End(TL${nf}(sv)) == True{} : Bool}:
  FD.logic__subst(S.Schema, z => {SH.is_End(TL${nf}(z)) == True{} : Bool}, ${X}, sv, Equal.sym(S.Schema, sv, ${X}, esv), {==})
def CHS${nf}(+sv: S.Schema) -> S.Schema: S.End{}
@@ sym_schema_text_lines_4 @@
def fe${i}(${SVE}) -> {TL${i}(sv) == ${ch(i)} : S.Schema}:
  Equal.trans(S.Schema, TL${i}(sv), S.Chain{HD${i}(sv), TL${i + 1}(sv)}, ${ch(i)}, SH.Chain_shape(TL${i}(sv), isch${i}(sv, esv)),
    Equal.cong(S.Schema, S.Schema, z => S.Chain{HD${i}(sv), z}, TL${i + 1}(sv), ${ch(i + 1)}, fe${i + 1}(sv, esv)))
@@ spec_text_lines_5 @@
def eq${j}(${CW}, ${H}) -> {U32.to_nat(${Ej}) == ${Q[j]} : Nat}:
  Equal.trans(Nat, U32.to_nat(${Ej}), Nat.add(U32.to_nat(${L.O(j - 1)}), ${Ln[j - 1]}), ${Q[j]}, eE${j - 1}(${TXOA}, h),
    Equal.trans(Nat, Nat.add(U32.to_nat(${L.O(j - 1)}), ${Ln[j - 1]}), Nat.add(${Q[j - 1]}, ${Ln[j - 1]}), ${Q[j]},
      Equal.cong(Nat, Nat, z => Nat.add(z, ${Ln[j - 1]}), U32.to_nat(${L.O(j - 1)}), ${Q[j - 1]}, eq${j - 1}(${CWA}, h)),
      Equal.cong(Nat, Nat, z => Nat.add(${Q[j - 1]}, z), ${Ln[j - 1]}, ${lenY[j - 1]}, Equal.sym(Nat, ${lenY[j - 1]}, ${Ln[j - 1]}, lY${j - 1}(${CWA}, h)))))
@@ spec_text_lines_6 @@
def eln${j}(${TXO}, ${H}) -> {U32.to_nat(len) == Nat.add(U32.to_nat(${L.O(j)}), ${RS[j]}) : Nat}:
  Equal.trans(Nat, U32.to_nat(len), Nat.add(U32.to_nat(${L.O(j + 1)}), ${RS[j + 1]}), Nat.add(U32.to_nat(${L.O(j)}), ${RS[j]}), eln${j + 1}(${TXOA}, h),
    Equal.trans(Nat, Nat.add(U32.to_nat(${L.O(j + 1)}), ${RS[j + 1]}), Nat.add(Nat.add(U32.to_nat(${L.O(j)}), ${Ln[j]}), ${RS[j + 1]}), Nat.add(U32.to_nat(${L.O(j)}), ${RS[j]}),
      Equal.cong(Nat, Nat, z => Nat.add(z, ${RS[j + 1]}), U32.to_nat(${L.O(j + 1)}), Nat.add(U32.to_nat(${L.O(j)}), ${Ln[j]}), eE${j}(${TXOA}, h)),
      FD.nat__add_assoc(U32.to_nat(${L.O(j)}), ${Ln[j]}, ${RS[j + 1]})))
@@ spec_text_lines @@
def elen(${TXO}, ${H}) -> {U32.to_nat(len) == Nat.add(${FSN}, ${RS[0]}) : Nat}:
  Equal.trans(Nat, U32.to_nat(len), Nat.add(U32.to_nat(${L.O(0)}), ${RS[0]}), Nat.add(${FSN}, ${RS[0]}), eln0(${TXOA}, h),
    Equal.cong(Nat, Nat, z => Nat.add(z, ${RS[0]}), U32.to_nat(${L.O(0)}), ${FSN}, eO0(${TXOA}, h)))

@@ spec_text_lines_2 @@
def winE(${CW}, ${H})
    -> {${LHS} == ${WBL} : +List<U32>}:
  +hwR = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, z), ${PW}) == ${TRUE}}, U32.to_nat(len), Nat.add(${FSN}, ${RS[0]}), elen(${TXOA}, h), hw)
@@ spec_text_lines_7 @@
  %Equal.sym(+List<U32>, UW.WX(t, x, Nat.add(${FSN}, ${RS[0]})), List.append(&2, U32, UW.WX(t, x, ${FSN}), UW.WX(t, Nat.add(x, ${FSN}), ${RS[0]})),
      splitR(t, x, ${FSN}, ${RS[0]})) :
    {${CUR} == _ : +List<U32>}
  %hdrE(${CWA}, h) : {${CUR} == List.append(&2, U32, _, UW.WX(t, Nat.add(x, ${FSN}), ${RS[0]})) : +List<U32>}
@@ spec_text_lines_8 @@
  %Equal.sym(+List<U32>, UW.WX(t, x, Nat.add(A.quad(${L.H}n), ${RS[0]})), List.append(&2, U32, F.limbs(UR.RWS(${L.H}n, t, x)), UW.WX(t, Nat.add(A.quad(${L.H}n), x), ${RS[0]})),
      UW.headWX(d, t, x, ${L.H}n, ${RS[0]}, pf, hwR)) :
    {${CUR} == _ : +List<U32>}
@@ spec_text_lines_3 @@
def partsw(${CW}, ${HCHK}${SV}) -> {Codec.parts(${itm(0)}, ${chain(0)}) == Some{${PSV}} : ${MP}}:
  ${cat(0)}

@@ spec_text_lines_9 @@
  %Equal.sym(S.Schema, sv, ${SHP}, SH.${CK}_shape(sv, isc(sv, esv))) : {Codec.parts(VALw(t, x, len), _) == ${TGT} : ${MP}}
  %Equal.sym(Maybe<&2, Nat>, SS.fixed_size(SH.${CK}_fields(sv)), None{}, fsn(sv, esv)) : {Codec.aggregate(Codec.parts(${itm(0)}, SH.${CK}_fields(sv)), _) == ${TGT} : ${MP}}
  %Equal.sym(S.Schema, TL0(sv), ${chain(0)}, fe0(sv, esv)) : {Codec.aggregate(Codec.parts(${itm(0)}, _), None{}) == ${TGT} : ${MP}}
  %Equal.sym(${MP}, Codec.parts(${itm(0)}, ${chain(0)}), Some{${PSV}}, partsw(${CWA}, hchk, sv, esv)) : {Codec.aggregate(_, None{}) == ${TGT} : ${MP}}
  %Equal.sym(${M}, Layout.encoding(${PSV}), Some{${LHS}}, encw(${CWA}, hchk)) : {Codec.one(_, None{}) == ${TGT} : ${MP}}
  %Equal.sym(+List<U32>, ${LHS}, ${WBL}, winE(${CWA}, hchk)) : {Codec.one(Some{_}, None{}) == ${TGT} : ${MP}}
  {==}

# The spec parts of the value: one variable part, the window's bytes.
def specw(${CW}, ${HCHK}) -> {Codec.parts(VALw(t, x, len), ${L.top}) == ${TGT} : ${MP}}:
  specg(${CWA}, hchk, ${L.top}, {==})

@@ spec_text_lines_4 @@
# The spec parts of the value: one variable part, the window's bytes.
def specw(${CW}, ${HCHK}) -> {Codec.parts(VALw(t, x, len), ${L.top}) == ${TGT} : ${MP}}:
  %Equal.sym(${MP}, Codec.parts(${itm(0)}, ${chain(0)}), Some{${PSV}}, partsw(${CWA}, hchk)) : {Codec.aggregate(_, None{}) == ${TGT} : ${MP}}
  %Equal.sym(${M}, Layout.encoding(${PSV}), Some{${LHS}}, encw(${CWA}, hchk)) : {Codec.one(_, None{}) == ${TGT} : ${MP}}
  %Equal.sym(+List<U32>, ${LHS}, ${WBL}, winE(${CWA}, hchk)) : {Codec.one(Some{_}, None{}) == ${TGT} : ${MP}}
  {==}

@@ _inv_parts_bytes_lines @@
def BYX(${PLD[:-2]}) -> +List<U32>: List.append(&2, U32, Layout.fixed_parts(${PS}, Layout.fixed_size(${PS})), Layout.payloads(${PS}))
def EVF(+h: S.Value, +s: S.Schema, +y: +List<U32>) -> Data: {Codec.parts(h, s) == Some{[S.Variable{y}]} : ${MP}}
def EXF(+h: S.Value, +s: S.Schema, +y: +List<U32>) -> Data: {Codec.parts(h, s) == Some{[S.Fixed{y}]} : ${MP}}
def LXF(+s: Nat, +xs: +List<U32>) -> Data: {Some{s} == Some{List.length(&2, U32, xs)} : Maybe<&2, Nat>}
def mis(a: Maybe<&2, Nat>, +n: Nat) -> Bool:
  match a:
    case None{}: False{}
    case Some{v}: Nat.is_eq(v, n)
def eqM(+a: Maybe<&2, Nat>, +n: Nat, +e: {mis(a, n) == True{} : Bool}) -> {a == Some{n} : Maybe<&2, Nat>}:
  match a:
    case None{}: Empty.absurd({None{} == Some{n} : Maybe<&2, Nat>}, FD.logic__false_true(e))
    case Some{+v}: Equal.cong(Nat, Maybe<&2, Nat>, z => Some{z}, v, n, FD.nat__eq_from_is_eq(v, n, e))
@@ _inv_window_lengths_lines @@
def eL(${SD}) -> {U32.to_nat(len) == ${END} : Nat}:
  +FPt = ${FP}
  +lenB = Equal.trans(Nat, List.length(&2, U32, ${BYTES}), Nat.add(List.length(&2, U32, FPt), ${LPL}), ${END}, VS.len_app(FPt, ${PL}),
    Equal.trans(Nat, Nat.add(List.length(&2, U32, FPt), ${LPL}), Nat.add(${FSN}, ${LPL}), ${END},
      Equal.cong(Nat, Nat, z => Nat.add(z, ${LPL}), List.length(&2, U32, FPt), ${FSN},
        Equal.trans(Nat, List.length(&2, U32, FPt), Layout.fixed_size(${PS}), ${FSN}, LY.lay_len(${PS}, Layout.fixed_size(${PS})), efs(${SA}))),
      LY.lay_end(${PS}, ${FSN})))
  Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, ${WBL}), ${END}, Equal.sym(Nat, List.length(&2, U32, ${WBL}), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)),
    Equal.trans(Nat, List.length(&2, U32, ${WBL}), List.length(&2, U32, ${BYTES}), ${END},
      Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), ${WBL}, ${BYTES}, Equal.sym(+List<U32>, ${BYTES}, ${WBL}, eq)), lenB))

@@ _inv_variable_parts_lines_2 @@
  offwX(${CWA}, ${L.PN(c)}, ${OFF}, FD.nat__le_trans(Nat.add(${L.PN(c)}, 4n), ${FSN}, U32.to_nat(len), ${L.LEA(c, 4)}, ${HFS}),
    FD.logic__subst(Nat, z => {Nat.is_le(${OFF}, z) == ${TRUE}}, ${END}, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), ${END}, eL(${SA})), LY.off_le(${PS}, ${i}n, ${FSN})),
    eb${j}(${SA}))
@@ _inv_variable_parts_lines @@
  +eL2 = Equal.trans(Nat, U32.to_nat(len), ${END}, Nat.add(${FSN}, List.length(&2, U32, ${PL})), eL(${SA}), Equal.sym(Nat, Nat.add(${FSN}, List.length(&2, U32, ${PL})), ${END}, LY.lay_end(${PS}, ${FSN})))
  offw(${CWA}, ${c}n, Nat.add(${RF}n, List.length(&2, U32, ${PL})), ${OFF}, eL2,
    FD.logic__subst(Nat, z => {Nat.is_le(${OFF}, z) == ${TRUE}}, ${END}, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), ${END}, eL(${SA})), LY.off_le(${PS}, ${i}n, ${FSN})),
    eb${j}(${SA}))
@@ _inv_variable_parts_lines_3 @@
def el${j}(${SD}) -> {U32.to_nat(${L.LJ(j)}) == ${ly} : Nat}: VMR.subL(${E}, ${L.O(j)}, ${OFF}, ${ly}, ov${j}(${SA}), ${ovE})
def nle${j}(${SD}) -> {Nat.is_le(U32.to_nat(${L.O(j)}), U32.to_nat(${E})) == ${TRUE}}:
  FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(${E})) == ${TRUE}}, ${OFF}, U32.to_nat(${L.O(j)}), Equal.sym(Nat, U32.to_nat(${L.O(j)}), ${OFF}, ov${j}(${SA})),
    FD.logic__subst(Nat, z => {Nat.is_le(${OFF}, z) == ${TRUE}}, Nat.add(${OFF}, ${ly}), U32.to_nat(${E}), Equal.sym(Nat, U32.to_nat(${E}), Nat.add(${OFF}, ${ly}), ${ovE}),
      FD.nat__le_add_right(${OFF}, ${ly})))
@@ _inv_variable_parts_lines_5 @@
def nle2${j}(${SD}) -> {Nat.is_le(U32.to_nat(${E}), U32.to_nat(len)) == ${TRUE}}:
  FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(len)) == ${TRUE}}, ${OFFE}, U32.to_nat(${E}), Equal.sym(Nat, U32.to_nat(${E}), ${OFFE}, ${ovE}),
    FD.logic__subst(Nat, z => {Nat.is_le(${OFFE}, z) == ${TRUE}}, ${END}, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), ${END}, eL(${SA})), LY.off_le(${PS}, ${i2}n, ${FSN})))
@@ _inv_variable_parts_lines_4 @@
def ypay${j}(${SD}) -> {${L.Y(j)} == y${j} : +List<U32>}:
  %Equal.sym(Nat, U32.to_nat(${L.LJ(j)}), ${ly}, el${j}(${SA})) : {UW.WX(t, ${L.XJ(j)}, _) == y${j} : +List<U32>}
  %Equal.sym(Nat, U32.to_nat(${L.O(j)}), ${OFF}, ov${j}(${SA})) : {UW.WX(t, Nat.add(_, x), ${ly}) == y${j} : +List<U32>}
  %UW.subWX(t, x, ${OFF}, ${ly}, U32.to_nat(len), ${hl}) : {_ == y${j} : +List<U32>}
  %eq : {VS.bt(${ly}, VS.bdr(${OFF}, _)) == y${j} : +List<U32>}
  %efs(${SA}) : {VS.bt(${ly}, VS.bdr(LY.OFF(${PS}, ${i}n, _), ${BYTES})) == y${j} : +List<U32>}
  LY.lay_pay(${PS}, ${i}n, y${j}, Layout.fixed_size(${PS}), ${FP}, LY.lay_len(${PS}, Layout.fixed_size(${PS})), {==})
def dch${j}(${SD}${', +h' + str(j) + ': S.Value, +ev' + str(j) + ': EVF(h' + str(j) + ', ' + L.spec(f) + ', y' + str(j) + ')' if CP else ''}) -> {CH${j}.CHKw(t, ${L.XJ(j)}, ${L.FJ(j)}, ${L.LJ(j)}) == ${TRUE}}:
  CH${j}.invw(d, t, n, ${L.XJ(j)}, ${L.FJ(j)}, ${L.LJ(j)}, eoW(${CWA}, ${L.O(j)}, ${E}, nle${j}(${SA}), nle2${j}(${SA})), hd,
    hwj(${CWA}, ${L.O(j)}, ${E}, nle${j}(${SA}), nle2${j}(${SA})), pf, h${j},
    FD.logic__subst(+List<U32>, z => {Codec.parts(h${j}, ${L.spec(f)}) == Some{[S.Variable{z}]} : ${MP}}, y${j}, ${L.Y(j)}, Equal.sym(+List<U32>, ${L.Y(j)}, y${j}, ypay${j}(${SA})), ev${j}))
@@ _inv_checks_lines @@
def fin(${CW}, ${sdecl(nf)}+b: Bool, +e: {Codec.one(SP.optional(b, ${BYTES}), None{}) == ${TGT} : ${MP}}) -> ${GOAL}:
  match b:
    case False{}: ${absurd()}
    case True{}: contra(${CWA}, ${sargs(nf)}var_inj(${BYTES}, ${WBL}, e))

@@ _inv_item_matches_lines @@
def fp${i}(${CW}, ${sdecl(i)}+h: S.Value, +ps: +List<S.Part>, hf: DF.single(${wd}, ps), +em: {Codec.parts(h, ${sp}) == Some{ps} : ${MP}}, +r: S.Value,
    +e: ${e_fp}) -> ${GOAL}:
  match ps:
    case Nil{}: Empty.absurd(${GOAL}, hf)
@@ _inv_item_matches_lines_2 @@
    case Con{S.Fixed{+xs}, Con{+a, +b}}: Empty.absurd(${GOAL}, hf)
    case Con{S.Variable{+xs}, Con{+a, +b}}: Empty.absurd(${GOAL}, hf)

@@ _inv_item_matches_lines_3 @@
def fm${i}(${CW}, ${sdecl(i)}+h: S.Value, +mm: ${MP}, hf: DF.single_result(${wd}, mm), +em: {Codec.parts(h, ${sp}) == mm : ${MP}}, +r: S.Value,
    +e: ${e_fm}) -> ${GOAL}:
  match mm:
    case None{}: ${absurd()}
    case Some{+ps}: fp${i}(${CWA}, ${sargs(i)}h, ps, hf, em, r, e)
