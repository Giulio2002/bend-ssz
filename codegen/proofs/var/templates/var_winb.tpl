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
