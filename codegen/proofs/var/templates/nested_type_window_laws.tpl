@@ COMMON @@

def BF(t: FD.array__Tree<U32>, +n: U32) -> B.Buf: VR.BF(t, n)

def hlen(+d: Nat, +i: Nat, +len: U32, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(len), A.quad(VB.pw(d))) == True{} : Bool}:
  FD.nat__le_trans(U32.to_nat(len), Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d)), Order.left_below_sum(A.quad(i), U32.to_nat(len)), hw)

# The payload of a one-part variable list.
def varpay(ps: +List<S.Part>) -> +List<U32>:
  match ps:
    case Con{S.Variable{+xs}, t}: xs
    case _: []

def var_inj(+a: +List<U32>, +b: +List<U32>, +e: {Some{[S.Variable{a}]} == Some{[S.Variable{b}]} : Maybe<&2, +List<S.Part>>}) -> {a == b : +List<U32>}:
  Equal.cong(+List<S.Part>, +List<U32>, z => varpay(z), [S.Variable{a}], [S.Variable{b}], FD.logic__some_inj(+List<S.Part>, [S.Variable{a}], [S.Variable{b}], e))

@@ BITS @@

def V(+t: FD.array__Tree<U32>, +off: U32, +len: U32) -> U32: VR.VX(t, VR.XN(off, len))
def M1(+len: U32) -> Nat: U32.to_nat(U32.sub(len, 1))
def BD(+t: FD.array__Tree<U32>, +off: U32, +len: U32) -> Nat: Nat.add(Nat.mul(8n, M1(len)), U32.to_nat(O.high_bit(V(t, off, len))))

def chk1(a: Bool, +t: FD.array__Tree<U32>, +off: U32, +len: U32) -> Bool:
  match a:
    case False{}: False{}
    case True{}: O.bsel(U32.is_eq(V(t, off, len), 0), False{}, O.bsel(False{}, True{}, Nat.is_le(BD(t, off, len), U32.to_nat(@N))))

# A bit list's window: non-empty, a non-zero last byte, at most @N bits.
def CHKw(+t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32) -> Bool: chk1(U32.is_lt(0, len), t, off, len)

def eX(+d: Nat, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +e1: {U32.to_nat(len) == 1n+M1(len) : Nat})
    -> {U32.to_nat(VR.XN(off, len)) == Nat.add(A.quad(i), M1(len)) : Nat}:
  VR.eXNw(off, i, len, M1(len), eo, hw32, e1)

def hi(+d: Nat, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +e1: {U32.to_nat(len) == 1n+M1(len) : Nat})
    -> {Nat.is_lt(VR.QX(VR.XN(off, len)), VB.pw(d)) == True{} : Bool}:
  VR.hiX(d, VR.XN(off, len), Nat.add(A.quad(i), M1(len)), eX(d, i, off, len, eo, hd, hw, e1),
    FD.nat__lt_le_trans(Nat.add(A.quad(i), M1(len)), Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d)),
      FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(A.quad(i), M1(len)), Nat.add(A.quad(i), z)) == True{} : Bool}, 1n+M1(len), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), 1n+M1(len), e1),
        FD.nat__lt_add_left(M1(len), 1n+M1(len), A.quad(i), FD.nat__lt_succ(M1(len)))), hw))

def okA(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +a: Bool, +ea: {U32.is_lt(0, len) == a : Bool})
    -> {T.@p_ok(BF(t, n), off, len) == (BF(t, n), chk1(a, t, off, len)) : B.Buf & Bool}:
  match a:
    case False{}:
      %Equal.sym(Bool, U32.is_lt(0, len), False{}, ea) : {O.bitlist_nz(_, BF(t, n), off, len, @N, False{}) == (BF(t, n), False{}) : B.Buf & Bool}
      {==}
    case True{}:
      +e1 = VR.e1n(len, VR.pos1(len, ea))
      %Equal.sym(Bool, U32.is_lt(0, len), True{}, ea) : {O.bitlist_nz(_, BF(t, n), off, len, @N, False{}) == (BF(t, n), chk1(True{}, t, off, len)) : B.Buf & Bool}
      %Equal.sym(B.Buf & U32, B.byte_at(BF(t, n), VR.XN(off, len)), (BF(t, n), V(t, off, len)),
          VR.byte_at_ok(d, t, n, VR.XN(off, len), VB.lt32(d, FD.nat__lt_trans(d, 28n, 31n, hd, {==})), hi(d, i, off, len, eo, hd, hw, e1), pf)) :
        {O.bitlist_pick(len, @N, False{}, _) == (BF(t, n), chk1(True{}, t, off, len)) : B.Buf & Bool}
      {==}

# The validator on the window returns the buffer and CHKw.
def ok_evalw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {T.@p_ok(BF(t, n), off, len) == (BF(t, n), CHKw(t, i, off, len)) : B.Buf & Bool}:
  okA(d, t, n, i, off, len, eo, hd, hw, pf, U32.is_lt(0, len), {==})

def cA(+a: Bool, +t: FD.array__Tree<U32>, +off: U32, +len: U32, +h: {chk1(a, t, off, len) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case False{}: h
    case True{}: {==}

def bselF(+c: Bool, +y: Bool, +h: {O.bsel(c, False{}, y) == True{} : Bool}) -> {c == False{} : Bool}:
  match c:
    case True{}: Empty.absurd({True{} == False{} : Bool}, FD.logic__false_true(h))
    case False{}: {==}

def c1(+t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, +h: {CHKw(t, i, off, len) == True{} : Bool}) -> {chk1(True{}, t, off, len) == True{} : Bool}:
  FD.logic__subst(Bool, z => {chk1(z, t, off, len) == True{} : Bool}, U32.is_lt(0, len), True{}, cA(U32.is_lt(0, len), t, off, len, h), h)

def cB(+t: FD.array__Tree<U32>, +off: U32, +len: U32, +h: {chk1(True{}, t, off, len) == True{} : Bool}) -> {U32.is_eq(V(t, off, len), 0) == False{} : Bool}:
  bselF(U32.is_eq(V(t, off, len), 0), O.bsel(False{}, True{}, Nat.is_le(BD(t, off, len), U32.to_nat(@N))), h)

def cC(+t: FD.array__Tree<U32>, +off: U32, +len: U32, +h: {chk1(True{}, t, off, len) == True{} : Bool}, +nz: {U32.is_eq(V(t, off, len), 0) == False{} : Bool})
    -> {Nat.is_le(BD(t, off, len), U32.to_nat(@N)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {O.bsel(z, False{}, O.bsel(False{}, True{}, Nat.is_le(BD(t, off, len), U32.to_nat(@N)))) == True{} : Bool}, U32.is_eq(V(t, off, len), 0), False{}, nz, h)

def cE(+t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, +h: {CHKw(t, i, off, len) == True{} : Bool}) -> {U32.to_nat(len) == 1n+M1(len) : Nat}:
  VR.e1n(len, VR.pos1(len, cA(U32.is_lt(0, len), t, off, len, h)))

def hB(+t: FD.array__Tree<U32>, +off: U32, +len: U32, +e1: {U32.to_nat(len) == 1n+M1(len) : Nat}, +bd: {Nat.is_le(BD(t, off, len), U32.to_nat(@N)) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(len), @BMAXn) == True{} : Bool}:
  +bd1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, U32.to_nat(O.high_bit(V(t, off, len)))), U32.to_nat(@N)) == True{} : Bool}, Nat.mul(8n, M1(len)), VS.x8(M1(len)), VR.mul8(M1(len)), bd)
  +h8 = FD.nat__le_trans(VS.x8(M1(len)), Nat.add(VS.x8(M1(len)), U32.to_nat(O.high_bit(V(t, off, len)))), Nat.add(VS.x8(@Cn), 7n), FD.nat__le_add_right(VS.x8(M1(len)), U32.to_nat(O.high_bit(V(t, off, len)))),
    FD.nat__le_trans(Nat.add(VS.x8(M1(len)), U32.to_nat(O.high_bit(V(t, off, len)))), U32.to_nat(@N), Nat.add(VS.x8(@Cn), 7n), bd1, {==}))
  %Equal.sym(Nat, U32.to_nat(len), 1n+M1(len), e1) : {Nat.is_le(_, @BMAXn) == True{} : Bool}
  VR.x8_inv(M1(len), @Cn, h8)

# 31 + len <= 2^@KB: the checks bound the length (whatever the buffer's depth).
def hyB(+len: U32, +hb: {Nat.is_le(U32.to_nat(len), @BMAXn) == True{} : Bool}) -> {Nat.is_le(VC.YL(len), VB.pw(@KBn)) == True{} : Bool}:
  FD.nat__le_trans(VC.YL(len), Nat.add(31n, @BMAXn), VB.pw(@KBn), Order.add_left(31n, U32.to_nat(len), @BMAXn, hb), {==})

def hWZ(+len: U32, +hb: {Nat.is_le(U32.to_nat(len), @BMAXn) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(VC.WZ(len)), O.pow2n(@Kn)) == True{} : Bool}:
  FD.nat__le_trans(U32.to_nat(VC.WZ(len)), Nat.add(VD.s_rng(2n, VC.YL(len)), 8n), O.pow2n(@Kn),
    VC.wz_le(len, @KBn, {==}, hyB(len, hb)),
    FD.nat__le_trans(Nat.add(VD.s_rng(2n, VC.YL(len)), 8n), Nat.add(VD.s_rng(2n, @YMAXn), 8n), O.pow2n(@Kn),
      Order.add_right(VD.s_rng(2n, VC.YL(len)), VD.s_rng(2n, @YMAXn), 8n, VC.rng_mono(2n, VC.YL(len), @YMAXn, Order.add_left(31n, U32.to_nat(len), @BMAXn, hb))),
      {==}))

def hdzK(+d: Nat, +len: U32, +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hL: {Nat.is_le(U32.to_nat(len), A.quad(VB.pw(d))) == True{} : Bool},
    +hb: {Nat.is_le(U32.to_nat(len), @BMAXn) == True{} : Bool}) -> {Nat.is_le(VLS.DZ(len), @Kn) == True{} : Bool}:
  VD.wd_min(VC.WZ(len), @Kn, hWZ(len, hb))

# The list storage has room for the words.
def hrgB(+len: U32, +hb: {Nat.is_le(U32.to_nat(len), @BMAXn) == True{} : Bool}) -> {Nat.is_le(Nat.add(VC.NW(len), 0n), VB.pw(VLS.DZ(len))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(VC.NW(len), 0n), VC.NW(len), FD.nat__add_zero(VC.NW(len))) : {Nat.is_le(_, VB.pw(VLS.DZ(len))) == True{} : Bool}
  %Equal.sym(Nat, VB.pw(VLS.DZ(len)), O.pow2n(VLS.DZ(len)), VD.s_pow2_eq(VLS.DZ(len))) : {Nat.is_le(VC.NW(len), _) == True{} : Bool}
  FD.nat__le_trans(VC.NW(len), U32.to_nat(VC.WZ(len)), O.pow2n(VLS.DZ(len)), VC.nw_le_wz(len, @KBn, {==}, hyB(len, hb)), VD.wd_cover(VC.WZ(len), @Kn, {==}, hWZ(len, hb)))
@ZEROS
def NB(+t: FD.array__Tree<U32>, +off: U32, +len: U32) -> U32: U32.add(U32.mul(8, U32.sub(len, 1)), O.high_bit(V(t, off, len)))
def OBJw(+t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32) -> O.Bits:
  O.Bits{O.clear_bit(O.mask_last(len, FD.array__thaw(U32, VB.mone(VC.NW(len), i, 0n, VLS.DZ(len), VC.ZT(VLS.DZ(len)), t))), NB(t, off, len)), NB(t, off, len)}

# The reader on the window, when the checks hold.
def readw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {CHKw(t, i, off, len) == True{} : Bool})
    -> {T.@p_read(BF(t, n), off, len) == (BF(t, n), OBJw(t, i, off, len)) : B.Buf & O.Bits}:
  +e1 = cE(t, i, off, len, hchk)
  +h1 = c1(t, i, off, len, hchk)
  +hL = hlen(d, i, len, hw)
  +hd31 = FD.nat__lt_trans(d, 28n, 31n, hd, {==})
  +hb = hB(t, off, len, e1, cC(t, off, len, h1, cB(t, off, len, h1)))
  +hz = hdzK(d, len, hd, hL, hb)
  +ez = zeros_at(B.words_depth_u(VC.WZ(len)), VLS.DZ(len), VD.wdu(VC.WZ(len)), hz)
  %Equal.sym(B.Buf & U32, B.byte_at(BF(t, n), VR.XN(off, len)), (BF(t, n), V(t, off, len)), VR.byte_at_ok(d, t, n, VR.XN(off, len), VB.lt32(d, hd31), hi(d, i, off, len, eo, hd, hw, e1), pf)) :
    {O.bits_from(len, off, _) == (BF(t, n), OBJw(t, i, off, len)) : B.Buf & O.Bits}
  %Equal.sym(B.Buf & O.Words, O.copy_in(BF(t, n), off, len), (BF(t, n), O.Words{O.mask_last(len, FD.array__thaw(U32, VB.mone(VC.NW(len), i, 0n, VLS.DZ(len), VC.ZT(VLS.DZ(len)), t))), len}),
      VR.copy_in_ok2(d, t, n, off, i, len, VLS.DZ(len), pf, hd31, FD.nat__le_lt_trans(VLS.DZ(len), @Kn, 31n, hz, {==}), ez, VF.al_3(off, i, eo), VF.al_q(off, i, eo),
        VBC.nwHB(d, len, i, @KBn, {==}, hyB(len, hb), hw), hrgB(len, hb))) :
    {O.bits_clear(NB(t, off, len), _) == (BF(t, n), OBJw(t, i, off, len)) : B.Buf & O.Bits}
  {==}

def VALw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> S.Value: S.BitsValue{VBL.bl(VR.WB(t, i, U32.to_nat(len)))}

# The spec parts of the value: one variable part, the window's bytes.
def specw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {CHKw(t, i, off, len) == True{} : Bool})
    -> {Codec.parts(VALw(t, i, len), @SCH) == Some{[S.Variable{VR.WB(t, i, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}:
  +e1 = cE(t, i, off, len, hchk)
  +h1 = c1(t, i, off, len, hchk)
  +nz = cB(t, off, len, h1)
  +bd = cC(t, off, len, h1, nz)
  +m = M1(len)
  +W1 = VR.WB(t, i, 1n+m)
  +hw1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(i), z), A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(len), 1n+m, e1, hw)
  +lw = VR.lastWB(d, t, i, m, VR.XN(off, len), pf, hw1, eX(d, i, off, len, eo, hd, hw, e1))
  +nzl = FD.logic__subst(U32, z => {U32.is_eq(z, 0) == False{} : Bool}, V(t, off, len), VBL.lastb(W1), Equal.sym(U32, VBL.lastb(W1), V(t, off, len), lw), nz)
  +dom = VR.domWB(t, i, 1n+m)
  +len1 = Equal.trans(Nat, List.length(&2, Bool, VBL.bl(W1)), VBL.blen(W1), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))), VBL.bl_len(W1, dom, nzl),
    Equal.trans(Nat, VBL.blen(W1), Nat.add(VS.x8(m), VY.hb(VBL.lastb(W1))), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))),
      VR.blen_m(W1, m, VR.lenWB(d, t, i, 1n+m, pf, hw1)),
      Equal.cong(U32, Nat, z => Nat.add(VS.x8(m), VY.hb(z)), VBL.lastb(W1), V(t, off, len), lw)))
  +bd1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, U32.to_nat(O.high_bit(V(t, off, len)))), U32.to_nat(@N)) == True{} : Bool}, Nat.mul(8n, m), VS.x8(m), VR.mul8(m), bd)
  +hl = FD.logic__subst(Nat, z => {Nat.is_le(z, @LIMN) == True{} : Bool}, Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))), List.length(&2, Bool, VBL.bl(W1)),
    Equal.sym(Nat, List.length(&2, Bool, VBL.bl(W1)), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))), len1), bd1)
  %Equal.sym(Nat, U32.to_nat(len), 1n+m, e1) :
    {Codec.parts(S.BitsValue{VBL.bl(VR.WB(t, i, _))}, @SCH) == Some{[S.Variable{VR.WB(t, i, _)}]} : Maybe<&2, +List<S.Part>>}
  VBC.bl_parts(W1, @LIMN, dom, nzl, hl)

# ---- every bit-list value of the window's bytes passes the checks ----------------------------

def m1e(+len: U32, +m: Nat, +e1: {U32.to_nat(len) == 1n+m : Nat}) -> {M1(len) == m : Nat}:
  +h1 = FD.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, 1n+m, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), 1n+m, e1), FD.nat__zero_le(m))
  %Equal.sym(Nat, M1(len), Nat.sub(U32.to_nat(len), 1n), FD.u32__sub_nat(len, 1, h1)) : {_ == m : Nat}
  %Equal.sym(Nat, U32.to_nat(len), 1n+m, e1) : {Nat.sub(_, 1n) == m : Nat}
  FD.nat__add_sub_cancel(1n, m)

def chk_true(+t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, +m: Nat, +e1: {U32.to_nat(len) == 1n+m : Nat},
    +nz: {U32.is_eq(V(t, off, len), 0) == False{} : Bool}, +bd: {Nat.is_le(BD(t, off, len), U32.to_nat(@N)) == True{} : Bool})
    -> {CHKw(t, i, off, len) == True{} : Bool}:
  +ea = FD.logic__subst(Nat, z => {Nat.is_lt(0n, z) == True{} : Bool}, 1n+m, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), 1n+m, e1), {==})
  %Equal.sym(Bool, U32.is_lt(0, len), True{}, FD.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_lt(0n, U32.to_nat(len)), U32.is_lt(0, len), Equal.sym(Bool, U32.is_lt(0, len), Nat.is_lt(0n, U32.to_nat(len)), VR.lt_u32(0, len)), ea)) :
    {chk1(_, t, off, len) == True{} : Bool}
  %Equal.sym(Bool, U32.is_eq(V(t, off, len), 0), False{}, nz) : {O.bsel(_, False{}, O.bsel(False{}, True{}, Nat.is_le(BD(t, off, len), U32.to_nat(@N)))) == True{} : Bool}
  bd

def inv_t(+d: Nat, +t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +bits: +List<Bool>, +hb: {Nat.is_le(List.length(&2, Bool, bits), @LIMN) == True{} : Bool}, +pk: {VBL.P(bits) == VR.WB(t, i, U32.to_nat(len)) : +List<U32>},
    +fs: VBL.IF(bits)) -> {CHKw(t, i, off, len) == True{} : Bool}:
  (+l, +r) = fs
  (+nz0, +ln) = r
  +m = VBL.mcnt(bits)
  +WL = VR.WB(t, i, U32.to_nat(len))
  +e1 = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, WL), 1n+m, Equal.sym(Nat, List.length(&2, U32, WL), U32.to_nat(len), VR.lenWB(d, t, i, U32.to_nat(len), pf, hw)),
    Equal.trans(Nat, List.length(&2, U32, WL), List.length(&2, U32, VBL.P(bits)), 1n+m,
      Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), WL, VBL.P(bits), Equal.sym(+List<U32>, VBL.P(bits), WL, pk)), l))
  +W1 = VR.WB(t, i, 1n+m)
  +hw1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(i), z), A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(len), 1n+m, e1, hw)
  +m1 = m1e(len, m, e1)
  +e1m = Equal.trans(Nat, U32.to_nat(len), 1n+m, 1n+M1(len), e1, Equal.cong(Nat, Nat, z => 1n+z, m, M1(len), Equal.sym(Nat, M1(len), m, m1)))
  +lw = VR.lastWB(d, t, i, m, VR.XN(off, len), pf, hw1,
    FD.logic__subst(Nat, z => {U32.to_nat(VR.XN(off, len)) == Nat.add(A.quad(i), z) : Nat}, M1(len), m, m1, eX(d, i, off, len, eo, hd, hw, e1m)))
  +eW = Equal.trans(+List<U32>, VBL.P(bits), WL, W1, pk, Equal.cong(Nat, +List<U32>, z => VR.WB(t, i, z), U32.to_nat(len), 1n+m, e1))
  +eV = Equal.trans(U32, VBL.nthb(VBL.P(bits), m), VBL.nthb(W1, m), V(t, off, len), Equal.cong(+List<U32>, U32, z => VBL.nthb(z, m), VBL.P(bits), W1, eW),
    Equal.trans(U32, VBL.nthb(W1, m), VBL.lastb(W1), V(t, off, len), Equal.sym(U32, VBL.lastb(W1), VBL.nthb(W1, m), VR.last_len(W1, m, VR.lenWB(d, t, i, 1n+m, pf, hw1))), lw))
  +nz = FD.logic__subst(U32, z => {U32.is_eq(z, 0) == False{} : Bool}, VBL.nthb(VBL.P(bits), m), V(t, off, len), eV, nz0)
  +lnV = Equal.trans(Nat, List.length(&2, Bool, bits), Nat.add(VS.x8(m), VY.hb(VBL.nthb(VBL.P(bits), m))), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))), ln,
    Equal.cong(U32, Nat, z => Nat.add(VS.x8(m), VY.hb(z)), VBL.nthb(VBL.P(bits), m), V(t, off, len), eV))
  +eBD = Equal.trans(Nat, BD(t, off, len), Nat.add(VS.x8(M1(len)), U32.to_nat(O.high_bit(V(t, off, len)))), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))),
    Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(O.high_bit(V(t, off, len)))), Nat.mul(8n, M1(len)), VS.x8(M1(len)), VR.mul8(M1(len))),
    Equal.cong(Nat, Nat, z => Nat.add(VS.x8(z), U32.to_nat(O.high_bit(V(t, off, len)))), M1(len), m, m1))
  +bd = FD.logic__subst(Nat, z => {Nat.is_le(z, @LIMN) == True{} : Bool}, List.length(&2, Bool, bits), BD(t, off, len),
    Equal.trans(Nat, List.length(&2, Bool, bits), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))), BD(t, off, len), lnV, Equal.sym(Nat, BD(t, off, len), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))), eBD)), hb)
  chk_true(t, i, off, len, m, e1, nz, bd)

def inv_b(+d: Nat, +t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +bits: +List<Bool>, +b: Bool, +eb: {Nat.is_le(List.length(&2, Bool, bits), @LIMN) == b : Bool},
    +e: {Codec.one(Bits.encoding(b, List.append(&2, Bool, bits, [True{}])), None{}) == Some{[S.Variable{VR.WB(t, i, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>})
    -> {CHKw(t, i, off, len) == True{} : Bool}:
  match b:
    case False{}: Empty.absurd({CHKw(t, i, off, len) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, [S.Variable{VR.WB(t, i, U32.to_nat(len))}], e))
    case True{}: inv_t(d, t, i, off, len, eo, hd, hw, pf, bits, eb, var_inj(VBL.P(bits), VR.WB(t, i, U32.to_nat(len)), e), VBL.inv(bits))

# Every value whose spec parts are the window's bytes passes the checks.
def invw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +v: S.Value,
    +e: {Codec.parts(v, @SCH) == Some{[S.Variable{VR.WB(t, i, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>})
    -> {CHKw(t, i, off, len) == True{} : Bool}:
  match v:
    case S.BitsValue{+bits}: inv_b(d, t, i, off, len, eo, hd, hw, pf, bits, Nat.is_le(List.length(&2, Bool, bits), @LIMN), {==}, e)
@ABSURDV

@@ BITS0 @@

def V(+t: FD.array__Tree<U32>, +off: U32, +len: U32) -> U32: VR.VX(t, VR.XN(off, len))
def M1(+len: U32) -> Nat: U32.to_nat(U32.sub(len, 1))
def BD(+t: FD.array__Tree<U32>, +off: U32, +len: U32) -> Nat: Nat.add(Nat.mul(8n, M1(len)), U32.to_nat(O.high_bit(V(t, off, len))))

def chk1(a: Bool, +t: FD.array__Tree<U32>, +off: U32, +len: U32) -> Bool:
  match a:
    case False{}: False{}
    case True{}: O.bsel(U32.is_eq(V(t, off, len), 0), False{}, O.bsel(False{}, True{}, Nat.is_le(BD(t, off, len), U32.to_nat(@N))))

# A bit list's window: non-empty, a non-zero last byte, at most @N bits.
def CHKw(+t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32) -> Bool: chk1(U32.is_lt(0, len), t, off, len)

def eX(+d: Nat, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +e1: {U32.to_nat(len) == 1n+M1(len) : Nat})
    -> {U32.to_nat(VR.XN(off, len)) == Nat.add(A.quad(i), M1(len)) : Nat}:
  VR.eXN(d, off, i, len, M1(len), eo, FD.nat__lt_trans(d, 28n, 29n, hd, {==}), hw, e1)

def hi(+d: Nat, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +e1: {U32.to_nat(len) == 1n+M1(len) : Nat})
    -> {Nat.is_lt(VR.QX(VR.XN(off, len)), VB.pw(d)) == True{} : Bool}:
  VR.hiX(d, VR.XN(off, len), Nat.add(A.quad(i), M1(len)), eX(d, i, off, len, eo, hd, hw, e1),
    FD.nat__lt_le_trans(Nat.add(A.quad(i), M1(len)), Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d)),
      FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(A.quad(i), M1(len)), Nat.add(A.quad(i), z)) == True{} : Bool}, 1n+M1(len), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), 1n+M1(len), e1),
        FD.nat__lt_add_left(M1(len), 1n+M1(len), A.quad(i), FD.nat__lt_succ(M1(len)))), hw))

def okA(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +a: Bool, +ea: {U32.is_lt(0, len) == a : Bool})
    -> {T.@p_ok(BF(t, n), off, len) == (BF(t, n), chk1(a, t, off, len)) : B.Buf & Bool}:
  match a:
    case False{}:
      %Equal.sym(Bool, U32.is_lt(0, len), False{}, ea) : {O.bitlist_nz(_, BF(t, n), off, len, @N, False{}) == (BF(t, n), False{}) : B.Buf & Bool}
      {==}
    case True{}:
      +e1 = VR.e1n(len, VR.pos1(len, ea))
      %Equal.sym(Bool, U32.is_lt(0, len), True{}, ea) : {O.bitlist_nz(_, BF(t, n), off, len, @N, False{}) == (BF(t, n), chk1(True{}, t, off, len)) : B.Buf & Bool}
      %Equal.sym(B.Buf & U32, B.byte_at(BF(t, n), VR.XN(off, len)), (BF(t, n), V(t, off, len)),
          VR.byte_at_ok(d, t, n, VR.XN(off, len), VB.lt32(d, FD.nat__lt_trans(d, 28n, 31n, hd, {==})), hi(d, i, off, len, eo, hd, hw, e1), pf)) :
        {O.bitlist_pick(len, @N, False{}, _) == (BF(t, n), chk1(True{}, t, off, len)) : B.Buf & Bool}
      {==}

# The validator on the window returns the buffer and CHKw.
def ok_evalw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {T.@p_ok(BF(t, n), off, len) == (BF(t, n), CHKw(t, i, off, len)) : B.Buf & Bool}:
  okA(d, t, n, i, off, len, eo, hd, hw, pf, U32.is_lt(0, len), {==})

def cA(+a: Bool, +t: FD.array__Tree<U32>, +off: U32, +len: U32, +h: {chk1(a, t, off, len) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case False{}: h
    case True{}: {==}

def bselF(+c: Bool, +y: Bool, +h: {O.bsel(c, False{}, y) == True{} : Bool}) -> {c == False{} : Bool}:
  match c:
    case True{}: Empty.absurd({True{} == False{} : Bool}, FD.logic__false_true(h))
    case False{}: {==}

def c1(+t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, +h: {CHKw(t, i, off, len) == True{} : Bool}) -> {chk1(True{}, t, off, len) == True{} : Bool}:
  FD.logic__subst(Bool, z => {chk1(z, t, off, len) == True{} : Bool}, U32.is_lt(0, len), True{}, cA(U32.is_lt(0, len), t, off, len, h), h)

def cB(+t: FD.array__Tree<U32>, +off: U32, +len: U32, +h: {chk1(True{}, t, off, len) == True{} : Bool}) -> {U32.is_eq(V(t, off, len), 0) == False{} : Bool}:
  bselF(U32.is_eq(V(t, off, len), 0), O.bsel(False{}, True{}, Nat.is_le(BD(t, off, len), U32.to_nat(@N))), h)

def cC(+t: FD.array__Tree<U32>, +off: U32, +len: U32, +h: {chk1(True{}, t, off, len) == True{} : Bool}, +nz: {U32.is_eq(V(t, off, len), 0) == False{} : Bool})
    -> {Nat.is_le(BD(t, off, len), U32.to_nat(@N)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {O.bsel(z, False{}, O.bsel(False{}, True{}, Nat.is_le(BD(t, off, len), U32.to_nat(@N)))) == True{} : Bool}, U32.is_eq(V(t, off, len), 0), False{}, nz, h)

def cE(+t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, +h: {CHKw(t, i, off, len) == True{} : Bool}) -> {U32.to_nat(len) == 1n+M1(len) : Nat}:
  VR.e1n(len, VR.pos1(len, cA(U32.is_lt(0, len), t, off, len, h)))

def hB(+t: FD.array__Tree<U32>, +off: U32, +len: U32, +e1: {U32.to_nat(len) == 1n+M1(len) : Nat}, +bd: {Nat.is_le(BD(t, off, len), U32.to_nat(@N)) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(len), @BMAXn) == True{} : Bool}:
  +bd1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, U32.to_nat(O.high_bit(V(t, off, len)))), U32.to_nat(@N)) == True{} : Bool}, Nat.mul(8n, M1(len)), VS.x8(M1(len)), VR.mul8(M1(len)), bd)
  +h8 = FD.nat__le_trans(VS.x8(M1(len)), Nat.add(VS.x8(M1(len)), U32.to_nat(O.high_bit(V(t, off, len)))), Nat.add(VS.x8(@Cn), 7n), FD.nat__le_add_right(VS.x8(M1(len)), U32.to_nat(O.high_bit(V(t, off, len)))),
    FD.nat__le_trans(Nat.add(VS.x8(M1(len)), U32.to_nat(O.high_bit(V(t, off, len)))), U32.to_nat(@N), Nat.add(VS.x8(@Cn), 7n), bd1, {==}))
  %Equal.sym(Nat, U32.to_nat(len), 1n+M1(len), e1) : {Nat.is_le(_, @BMAXn) == True{} : Bool}
  VR.x8_inv(M1(len), @Cn, h8)

def hdzK(+d: Nat, +len: U32, +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hL: {Nat.is_le(U32.to_nat(len), A.quad(VB.pw(d))) == True{} : Bool},
    +hb: {Nat.is_le(U32.to_nat(len), @BMAXn) == True{} : Bool}) -> {Nat.is_le(VLS.DZ(len), @Kn) == True{} : Bool}:
  VD.wd_min(VC.WZ(len), @Kn,
    FD.nat__le_trans(U32.to_nat(VC.WZ(len)), Nat.add(VD.s_rng(2n, VC.YL(len)), 8n), O.pow2n(@Kn),
      VC.wz_le(len, VLS.KK(d), VLS.kk_lt(d, hd), VLS.hyn(d, len, hL)),
      FD.nat__le_trans(Nat.add(VD.s_rng(2n, VC.YL(len)), 8n), Nat.add(VD.s_rng(2n, @YMAXn), 8n), O.pow2n(@Kn),
        Order.add_right(VD.s_rng(2n, VC.YL(len)), VD.s_rng(2n, @YMAXn), 8n, VC.rng_mono(2n, VC.YL(len), @YMAXn, Order.add_left(31n, U32.to_nat(len), @BMAXn, hb))),
        {==})))
@ZEROS
def NB(+t: FD.array__Tree<U32>, +off: U32, +len: U32) -> U32: U32.add(U32.mul(8, U32.sub(len, 1)), O.high_bit(V(t, off, len)))
def OBJw(+t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32) -> O.Bits:
  O.Bits{O.clear_bit(O.mask_last(len, FD.array__thaw(U32, VB.mone(VC.NW(len), i, 0n, VLS.DZ(len), VC.ZT(VLS.DZ(len)), t))), NB(t, off, len)), NB(t, off, len)}

# The reader on the window, when the checks hold.
def readw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {CHKw(t, i, off, len) == True{} : Bool})
    -> {T.@p_read(BF(t, n), off, len) == (BF(t, n), OBJw(t, i, off, len)) : B.Buf & O.Bits}:
  +e1 = cE(t, i, off, len, hchk)
  +h1 = c1(t, i, off, len, hchk)
  +hL = hlen(d, i, len, hw)
  +hd31 = FD.nat__lt_trans(d, 28n, 31n, hd, {==})
  +hz = hdzK(d, len, hd, hL, hB(t, off, len, e1, cC(t, off, len, h1, cB(t, off, len, h1))))
  +ez = zeros_at(B.words_depth_u(VC.WZ(len)), VLS.DZ(len), VD.wdu(VC.WZ(len)), hz)
  %Equal.sym(B.Buf & U32, B.byte_at(BF(t, n), VR.XN(off, len)), (BF(t, n), V(t, off, len)), VR.byte_at_ok(d, t, n, VR.XN(off, len), VB.lt32(d, hd31), hi(d, i, off, len, eo, hd, hw, e1), pf)) :
    {O.bits_from(len, off, _) == (BF(t, n), OBJw(t, i, off, len)) : B.Buf & O.Bits}
  %Equal.sym(B.Buf & O.Words, O.copy_in(BF(t, n), off, len), (BF(t, n), O.Words{O.mask_last(len, FD.array__thaw(U32, VB.mone(VC.NW(len), i, 0n, VLS.DZ(len), VC.ZT(VLS.DZ(len)), t))), len}),
      VR.copy_in_ok2(d, t, n, off, i, len, VLS.DZ(len), pf, hd31, FD.nat__le_lt_trans(VLS.DZ(len), @Kn, 31n, hz, {==}), ez, VF.al_3(off, i, eo), VF.al_q(off, i, eo),
        VBC.nwH(d, len, i, hd, hw), VLS.hrg(d, len, hd, hL))) :
    {O.bits_clear(NB(t, off, len), _) == (BF(t, n), OBJw(t, i, off, len)) : B.Buf & O.Bits}
  {==}

def VALw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> S.Value: S.BitsValue{VBL.bl(VR.WB(t, i, U32.to_nat(len)))}

# The spec parts of the value: one variable part, the window's bytes.
def specw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {CHKw(t, i, off, len) == True{} : Bool})
    -> {Codec.parts(VALw(t, i, len), @SCH) == Some{[S.Variable{VR.WB(t, i, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}:
  +e1 = cE(t, i, off, len, hchk)
  +h1 = c1(t, i, off, len, hchk)
  +nz = cB(t, off, len, h1)
  +bd = cC(t, off, len, h1, nz)
  +m = M1(len)
  +W1 = VR.WB(t, i, 1n+m)
  +hw1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(i), z), A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(len), 1n+m, e1, hw)
  +lw = VR.lastWB(d, t, i, m, VR.XN(off, len), pf, hw1, eX(d, i, off, len, eo, hd, hw, e1))
  +nzl = FD.logic__subst(U32, z => {U32.is_eq(z, 0) == False{} : Bool}, V(t, off, len), VBL.lastb(W1), Equal.sym(U32, VBL.lastb(W1), V(t, off, len), lw), nz)
  +dom = VR.domWB(t, i, 1n+m)
  +len1 = Equal.trans(Nat, List.length(&2, Bool, VBL.bl(W1)), VBL.blen(W1), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))), VBL.bl_len(W1, dom, nzl),
    Equal.trans(Nat, VBL.blen(W1), Nat.add(VS.x8(m), VY.hb(VBL.lastb(W1))), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))),
      VR.blen_m(W1, m, VR.lenWB(d, t, i, 1n+m, pf, hw1)),
      Equal.cong(U32, Nat, z => Nat.add(VS.x8(m), VY.hb(z)), VBL.lastb(W1), V(t, off, len), lw)))
  +bd1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, U32.to_nat(O.high_bit(V(t, off, len)))), U32.to_nat(@N)) == True{} : Bool}, Nat.mul(8n, m), VS.x8(m), VR.mul8(m), bd)
  +hl = FD.logic__subst(Nat, z => {Nat.is_le(z, @LIMN) == True{} : Bool}, Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))), List.length(&2, Bool, VBL.bl(W1)),
    Equal.sym(Nat, List.length(&2, Bool, VBL.bl(W1)), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))), len1), bd1)
  %Equal.sym(Nat, U32.to_nat(len), 1n+m, e1) :
    {Codec.parts(S.BitsValue{VBL.bl(VR.WB(t, i, _))}, @SCH) == Some{[S.Variable{VR.WB(t, i, _)}]} : Maybe<&2, +List<S.Part>>}
  VBC.bl_parts(W1, @LIMN, dom, nzl, hl)

# ---- every bit-list value of the window's bytes passes the checks ----------------------------

def m1e(+len: U32, +m: Nat, +e1: {U32.to_nat(len) == 1n+m : Nat}) -> {M1(len) == m : Nat}:
  +h1 = FD.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, 1n+m, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), 1n+m, e1), FD.nat__zero_le(m))
  %Equal.sym(Nat, M1(len), Nat.sub(U32.to_nat(len), 1n), FD.u32__sub_nat(len, 1, h1)) : {_ == m : Nat}
  %Equal.sym(Nat, U32.to_nat(len), 1n+m, e1) : {Nat.sub(_, 1n) == m : Nat}
  FD.nat__add_sub_cancel(1n, m)

def chk_true(+t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, +m: Nat, +e1: {U32.to_nat(len) == 1n+m : Nat},
    +nz: {U32.is_eq(V(t, off, len), 0) == False{} : Bool}, +bd: {Nat.is_le(BD(t, off, len), U32.to_nat(@N)) == True{} : Bool})
    -> {CHKw(t, i, off, len) == True{} : Bool}:
  +ea = FD.logic__subst(Nat, z => {Nat.is_lt(0n, z) == True{} : Bool}, 1n+m, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), 1n+m, e1), {==})
  %Equal.sym(Bool, U32.is_lt(0, len), True{}, FD.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_lt(0n, U32.to_nat(len)), U32.is_lt(0, len), Equal.sym(Bool, U32.is_lt(0, len), Nat.is_lt(0n, U32.to_nat(len)), VR.lt_u32(0, len)), ea)) :
    {chk1(_, t, off, len) == True{} : Bool}
  %Equal.sym(Bool, U32.is_eq(V(t, off, len), 0), False{}, nz) : {O.bsel(_, False{}, O.bsel(False{}, True{}, Nat.is_le(BD(t, off, len), U32.to_nat(@N)))) == True{} : Bool}
  bd

def inv_t(+d: Nat, +t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +bits: +List<Bool>, +hb: {Nat.is_le(List.length(&2, Bool, bits), @LIMN) == True{} : Bool}, +pk: {VBL.P(bits) == VR.WB(t, i, U32.to_nat(len)) : +List<U32>},
    +fs: VBL.IF(bits)) -> {CHKw(t, i, off, len) == True{} : Bool}:
  (+l, +r) = fs
  (+nz0, +ln) = r
  +m = VBL.mcnt(bits)
  +WL = VR.WB(t, i, U32.to_nat(len))
  +e1 = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, WL), 1n+m, Equal.sym(Nat, List.length(&2, U32, WL), U32.to_nat(len), VR.lenWB(d, t, i, U32.to_nat(len), pf, hw)),
    Equal.trans(Nat, List.length(&2, U32, WL), List.length(&2, U32, VBL.P(bits)), 1n+m,
      Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), WL, VBL.P(bits), Equal.sym(+List<U32>, VBL.P(bits), WL, pk)), l))
  +W1 = VR.WB(t, i, 1n+m)
  +hw1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(i), z), A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(len), 1n+m, e1, hw)
  +m1 = m1e(len, m, e1)
  +e1m = Equal.trans(Nat, U32.to_nat(len), 1n+m, 1n+M1(len), e1, Equal.cong(Nat, Nat, z => 1n+z, m, M1(len), Equal.sym(Nat, M1(len), m, m1)))
  +lw = VR.lastWB(d, t, i, m, VR.XN(off, len), pf, hw1,
    FD.logic__subst(Nat, z => {U32.to_nat(VR.XN(off, len)) == Nat.add(A.quad(i), z) : Nat}, M1(len), m, m1, eX(d, i, off, len, eo, hd, hw, e1m)))
  +eW = Equal.trans(+List<U32>, VBL.P(bits), WL, W1, pk, Equal.cong(Nat, +List<U32>, z => VR.WB(t, i, z), U32.to_nat(len), 1n+m, e1))
  +eV = Equal.trans(U32, VBL.nthb(VBL.P(bits), m), VBL.nthb(W1, m), V(t, off, len), Equal.cong(+List<U32>, U32, z => VBL.nthb(z, m), VBL.P(bits), W1, eW),
    Equal.trans(U32, VBL.nthb(W1, m), VBL.lastb(W1), V(t, off, len), Equal.sym(U32, VBL.lastb(W1), VBL.nthb(W1, m), VR.last_len(W1, m, VR.lenWB(d, t, i, 1n+m, pf, hw1))), lw))
  +nz = FD.logic__subst(U32, z => {U32.is_eq(z, 0) == False{} : Bool}, VBL.nthb(VBL.P(bits), m), V(t, off, len), eV, nz0)
  +lnV = Equal.trans(Nat, List.length(&2, Bool, bits), Nat.add(VS.x8(m), VY.hb(VBL.nthb(VBL.P(bits), m))), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))), ln,
    Equal.cong(U32, Nat, z => Nat.add(VS.x8(m), VY.hb(z)), VBL.nthb(VBL.P(bits), m), V(t, off, len), eV))
  +eBD = Equal.trans(Nat, BD(t, off, len), Nat.add(VS.x8(M1(len)), U32.to_nat(O.high_bit(V(t, off, len)))), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))),
    Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(O.high_bit(V(t, off, len)))), Nat.mul(8n, M1(len)), VS.x8(M1(len)), VR.mul8(M1(len))),
    Equal.cong(Nat, Nat, z => Nat.add(VS.x8(z), U32.to_nat(O.high_bit(V(t, off, len)))), M1(len), m, m1))
  +bd = FD.logic__subst(Nat, z => {Nat.is_le(z, @LIMN) == True{} : Bool}, List.length(&2, Bool, bits), BD(t, off, len),
    Equal.trans(Nat, List.length(&2, Bool, bits), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))), BD(t, off, len), lnV, Equal.sym(Nat, BD(t, off, len), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, off, len)))), eBD)), hb)
  chk_true(t, i, off, len, m, e1, nz, bd)

def inv_b(+d: Nat, +t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +bits: +List<Bool>, +b: Bool, +eb: {Nat.is_le(List.length(&2, Bool, bits), @LIMN) == b : Bool},
    +e: {Codec.one(Bits.encoding(b, List.append(&2, Bool, bits, [True{}])), None{}) == Some{[S.Variable{VR.WB(t, i, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>})
    -> {CHKw(t, i, off, len) == True{} : Bool}:
  match b:
    case False{}: Empty.absurd({CHKw(t, i, off, len) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, [S.Variable{VR.WB(t, i, U32.to_nat(len))}], e))
    case True{}: inv_t(d, t, i, off, len, eo, hd, hw, pf, bits, eb, var_inj(VBL.P(bits), VR.WB(t, i, U32.to_nat(len)), e), VBL.inv(bits))

# Every value whose spec parts are the window's bytes passes the checks.
def invw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == A.quad(i) : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +v: S.Value,
    +e: {Codec.parts(v, @SCH) == Some{[S.Variable{VR.WB(t, i, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>})
    -> {CHKw(t, i, off, len) == True{} : Bool}:
  match v:
    case S.BitsValue{+bits}: inv_b(d, t, i, off, len, eo, hd, hw, pf, bits, Nat.is_le(List.length(&2, Bool, bits), @LIMN), {==}, e)
@ABSURDV

@@ cont_text @@
def SPOw(t: FD.array__Tree<U32>, +i: Nat) -> U32: VB.slot(t, Nat.add(${po}n, i))
def LLw(+len: U32) -> U32: U32.sub(len, ${FS})
def OWc(+off: U32) -> U32: U32.add(off, ${FS})
def JW(+i: Nat) -> Nat: Nat.add(${H}n, i)

def chk3(a: Bool, b: Bool, c: Bool) -> Bool:
  match a:
    case False{}: False{}
    case True{}:
      match b:
        case False{}: False{}
        case True{}: c

def CHKw(+t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32) -> Bool:
  chk3(U32.is_le(${FS}, len), U32.is_eq(SPOw(t, i), ${FS}), ${CHK_child})

def leF(+len: U32, ${HA}) -> {Nat.is_le(${FS}n, U32.to_nat(len)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(${FS}, len), Nat.is_le(${FS}n, U32.to_nat(len)), VU.le_u32(${FS}, len), ha)

def enF(+len: U32, ${HA}) -> {Nat.add(${FS}n, U32.to_nat(LLw(len))) == U32.to_nat(len) : Nat}:
  %Equal.sym(Nat, U32.to_nat(LLw(len)), Nat.sub(U32.to_nat(len), ${FS}n), FD.u32__sub_nat(len, ${FS}, leF(len, ha))) : {Nat.add(${FS}n, _) == U32.to_nat(len) : Nat}
  FD.nat__sub_add(U32.to_nat(len), ${FS}n, leF(len, ha))

def winb(+k: Nat, +i: Nat, +len: U32, +P: Nat, +hk: {Nat.is_le(A.quad(k), U32.to_nat(len)) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), P) == True{} : Bool}) -> {Nat.is_le(A.quad(Nat.add(k, i)), P) == True{} : Bool}:
  %VF.quad_add(k, i) : {Nat.is_le(_, P) == True{} : Bool}
  FD.nat__le_trans(Nat.add(A.quad(k), A.quad(i)), Nat.add(U32.to_nat(len), A.quad(i)), P, Order.add_right(A.quad(k), U32.to_nat(len), A.quad(i), hk),
    FD.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, Nat.add(A.quad(i), U32.to_nat(len)), Nat.add(U32.to_nat(len), A.quad(i)), FD.nat__add_comm(A.quad(i), U32.to_nat(len)), hw))

def eoc(${CW}, +k: Nat, +c: U32, +ec: {U32.to_nat(c) == A.quad(k) : Nat}, +hkF: {Nat.is_le(A.quad(k), ${FS}n) == True{} : Bool}, ${HA})
    -> {U32.to_nat(U32.add(off, c)) == A.quad(Nat.add(k, i)) : Nat}:
  VF.off_add_lt(off, c, i, k, eo, ec,
    FD.nat__le_lt_trans(A.quad(Nat.add(k, i)), Nat.add(A.quad(i), U32.to_nat(len)), FD.spec_common__pow2(32n),
      winb(k, i, len, Nat.add(A.quad(i), U32.to_nat(len)), FD.nat__le_trans(A.quad(k), ${FS}n, U32.to_nat(len), hkF, leF(len, ha)), FD.nat__le_refl(Nat.add(A.quad(i), U32.to_nat(len)))), hw32))

def hHi(${CW}, ${HA}) -> {Nat.is_le(Nat.add(${H}n, i), VB.pw(d)) == True{} : Bool}:
  VC.quad_inv(Nat.add(${H}n, i), VB.pw(d), winb(${H}n, i, len, A.quad(VB.pw(d)), leF(len, ha), hw))

def hiw(${CW}, +k: Nat, +hk: {Nat.is_lt(k, ${H}n) == True{} : Bool}, ${HA}) -> {Nat.is_lt(Nat.add(k, i), VB.pw(d)) == True{} : Bool}:
  FD.nat__lt_le_trans(Nat.add(k, i), Nat.add(${H}n, i), VB.pw(d), VB.lt_kk(k, ${H}n, i, hk), hHi(${CWA}, ha))

# The child's window: 4 (H + i) + (len - ${FS}) <= 4 2^d.
def hwc(${CW}, ${HA}) -> {Nat.is_le(Nat.add(A.quad(JW(i)), U32.to_nat(LLw(len))), A.quad(VB.pw(d))) == True{} : Bool}:
  %Equal.sym(Nat, A.quad(Nat.add(${H}n, i)), Nat.add(A.quad(${H}n), A.quad(i)), VF.quad_add(${H}n, i)) : {Nat.is_le(Nat.add(_, U32.to_nat(LLw(len))), A.quad(VB.pw(d))) == True{} : Bool}
  %FD.nat__add_comm(A.quad(i), A.quad(${H}n)) : {Nat.is_le(Nat.add(_, U32.to_nat(LLw(len))), A.quad(VB.pw(d))) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(Nat.add(A.quad(i), ${FS}n), U32.to_nat(LLw(len))), Nat.add(A.quad(i), Nat.add(${FS}n, U32.to_nat(LLw(len)))), FD.nat__add_assoc(A.quad(i), ${FS}n, U32.to_nat(LLw(len)))) :
    {Nat.is_le(_, A.quad(VB.pw(d))) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(${FS}n, U32.to_nat(LLw(len))), U32.to_nat(len), enF(len, ha)) : {Nat.is_le(Nat.add(A.quad(i), _), A.quad(VB.pw(d))) == True{} : Bool}
  hw

# ... and ends below 2^32.
def hwc32(${CW}, ${HA}) -> {Nat.is_lt(Nat.add(A.quad(JW(i)), U32.to_nat(LLw(len))), FD.spec_common__pow2(32n)) == True{} : Bool}:
  %Equal.sym(Nat, A.quad(Nat.add(${H}n, i)), Nat.add(A.quad(${H}n), A.quad(i)), VF.quad_add(${H}n, i)) : {Nat.is_lt(Nat.add(_, U32.to_nat(LLw(len))), FD.spec_common__pow2(32n)) == True{} : Bool}
  %FD.nat__add_comm(A.quad(i), A.quad(${H}n)) : {Nat.is_lt(Nat.add(_, U32.to_nat(LLw(len))), FD.spec_common__pow2(32n)) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(Nat.add(A.quad(i), ${FS}n), U32.to_nat(LLw(len))), Nat.add(A.quad(i), Nat.add(${FS}n, U32.to_nat(LLw(len)))), FD.nat__add_assoc(A.quad(i), ${FS}n, U32.to_nat(LLw(len)))) :
    {Nat.is_lt(_, FD.spec_common__pow2(32n)) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(${FS}n, U32.to_nat(LLw(len))), U32.to_nat(len), enF(len, ha)) : {Nat.is_lt(Nat.add(A.quad(i), _), FD.spec_common__pow2(32n)) == True{} : Bool}
  hw32

def eoF(${CW}, ${HA}) -> {U32.to_nat(OWc(off)) == A.quad(JW(i)) : Nat}:
  eoc(${CWA}, ${H}n, ${FS}, {==}, {==}, ha)

# ---- the validator ----------------------------------------------------------------------------

def c1_id(+ok: Bool, buf: B.Buf, +off: U32, +len: U32, +o0: U32) -> {${Tn}_c1(ok, buf, off, len, o0) == (buf, ok) : B.Buf & Bool}:
  match ok:
    case True{}: {==}
    case False{}: {==}

def okc0(${CW}, ${HA}, +b: Bool, +eb: {U32.is_eq(SPOw(t, i), ${FS}) == b : Bool})
    -> {${Tn}_c0(b, BF(t, n), off, len, SPOw(t, i)) == (BF(t, n), chk3(True{}, b, ${CHK_child})) : B.Buf & Bool}:
  match b:
    case False{}: {==}
    case True{}:
      +epo = FD.u32alg__eq_of(SPOw(t, i), ${FS}, eb)
      %Equal.sym(U32, SPOw(t, i), ${FS}, epo) :
        {${Tn}_v1(off, len, _, T.${x.okf}_ok(BF(t, n), U32.add(off, _), U32.sub(len, _))) == (BF(t, n), ${CHK_child}) : B.Buf & Bool}
      %Equal.sym(B.Buf & Bool, T.${x.okf}_ok(BF(t, n), OWc(off), LLw(len)), (BF(t, n), ${CHK_child}),
          CH.ok_evalw(d, t, n, JW(i), OWc(off), LLw(len), eoF(${CWA}, ha), hd, hwc(${CWA}, ha), hwc32(${CWA}, ha), pf)) :
        {${Tn}_v1(off, len, ${FS}, _) == (BF(t, n), ${CHK_child}) : B.Buf & Bool}
      c1_id(${CHK_child}, BF(t, n), off, len, ${FS})

def okl(${CW}, +a: Bool, +ea: {U32.is_le(${FS}, len) == a : Bool})
    -> {${Tn}_ok_len(a, BF(t, n), off, len) == (BF(t, n), chk3(a, U32.is_eq(SPOw(t, i), ${FS}), ${CHK_child})) : B.Buf & Bool}:
  match a:
    case False{}: {==}
    case True{}:
      %Equal.sym(B.Buf & U32, B.read32(VF.BF(t, n), U32.add(off, ${4 * po})), (VF.BF(t, n), SPOw(t, i)),
          VF.rd32a(d, t, n, U32.add(off, ${4 * po}), Nat.add(${po}n, i), eoc(${CWA}, ${po}n, ${4 * po}, {==}, {==}, ea),
            VB.lt32(d, FD.nat__lt_trans(d, 28n, 31n, hd, {==})), hiw(${CWA}, ${po}n, {==}, ea), pf)) :
        {${Tn}_v0(off, len, _) == (BF(t, n), chk3(True{}, U32.is_eq(SPOw(t, i), ${FS}), ${CHK_child})) : B.Buf & Bool}
      okc0(${CWA}, ea, U32.is_eq(SPOw(t, i), ${FS}), {==})

# The validator on the window returns the buffer and CHKw.
def ok_evalw(${CW}) -> {${Tn}_ok(BF(t, n), off, len) == (BF(t, n), CHKw(t, i, off, len)) : B.Buf & Bool}:
  okl(${CWA}, U32.is_le(${FS}, len), {==})

def ch_a(+a: Bool, +b: Bool, +c: Bool, +h: {chk3(a, b, c) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case False{}: h
    case True{}: {==}

def ch_b(+a: Bool, +b: Bool, +c: Bool, +h: {chk3(a, b, c) == True{} : Bool}) -> {b == True{} : Bool}:
  match a b:
    case False{} _: Empty.absurd({b == True{} : Bool}, FD.logic__false_true(h))
    case True{} False{}: h
    case True{} True{}: {==}

def ch_c(+a: Bool, +b: Bool, +c: Bool, +h: {chk3(a, b, c) == True{} : Bool}) -> {c == True{} : Bool}:
  match a b:
    case False{} _: Empty.absurd({c == True{} : Bool}, FD.logic__false_true(h))
    case True{} False{}: Empty.absurd({c == True{} : Bool}, FD.logic__false_true(h))
    case True{} True{}: h

@@ cont_text_readw @@

# The reader on the window, when the checks hold.
def readw(${CW}, +hchk: {CHKw(t, i, off, len) == True{} : Bool}) -> {${Tn}_read(BF(t, n), off, len) == ${RHS} : ${TY}}:
  +a = U32.is_le(${FS}, len)
  +b = U32.is_eq(SPOw(t, i), ${FS})
  +c = ${CHK_child}
  rd_go(${CWA}, ch_a(a, b, c, hchk), FD.u32alg__eq_of(SPOw(t, i), ${FS}, ch_b(a, b, c, hchk)), ch_c(a, b, c, hchk))

@@ cont_text_VALw @@
def VALw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> S.Value: S.Sequence{${items(0)}}

def fitw(${CW}, ${HA}) -> {N.fits(4n, Nat.add(VS.FSZ(${PRE}, ${POST}), List.length(&2, U32, ${Y}))) == True{} : Bool}:
  %Equal.sym(Nat, List.length(&2, U32, ${Y}), U32.to_nat(LLw(len)), VR.lenWB(d, t, JW(i), U32.to_nat(LLw(len)), pf, hwc(${CWA}, ha))) : {N.fits(4n, Nat.add(${FS}n, _)) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(${FS}n, U32.to_nat(LLw(len))), U32.to_nat(len), enF(len, ha)) : {N.fits(4n, _) == True{} : Bool}
  VFT.fits4lt(U32.to_nat(len), FD.nat__le_lt_trans(U32.to_nat(len), Nat.add(A.quad(i), U32.to_nat(len)), FD.spec_common__pow2(32n), Order.left_below_sum(A.quad(i), U32.to_nat(len)), hw32))

# The window's bytes: the header words' limbs, then the child's window.
def limw(${CW}, ${HA}, +epo: {SPOw(t, i) == ${FS} : U32})
    -> {List.append(&2, U32, F.limbs(${HDR}), ${Y}) == ${WBL} : +List<U32>}:
  +hh = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(${H}n, i), z) == True{} : Bool}, VB.pw(d), VB.len(${s}), Equal.sym(Nat, VB.len(${s}), VB.pw(d), FD.array__slots_length(U32, d, t, pf)), hHi(${CWA}, ha))
  %enF(len, ha) : {List.append(&2, U32, F.limbs(${HDR}), ${Y}) == VR.WB(t, i, _) : +List<U32>}
  %Equal.sym(+List<U32>, VR.WB(t, i, Nat.add(A.quad(${H}n), U32.to_nat(LLw(len)))), List.append(&2, U32, F.limbs(VF.app(VF.wpre(${H}n, i, ${s}), [])), VR.WB(t, Nat.add(${H}n, i), U32.to_nat(LLw(len)))),
      VWN.splitW(t, i, ${H}n, U32.to_nat(LLw(len)), hh)) :
    {List.append(&2, U32, F.limbs(${HDR}), ${Y}) == _ : +List<U32>}
  %epo : {List.append(&2, U32, F.limbs(${HDRh}), ${Y}) == List.append(&2, U32, F.limbs(VF.app(VF.wpre(${H}n, i, ${s}), [])), ${Y}) : +List<U32>}
  {==}

def specg(${CW}, ${HA}, +epo: {SPOw(t, i) == ${FS} : U32}, +hc: {${CHK_child} == True{} : Bool})
    -> {Codec.parts(VALw(t, i, len), Spec.${n}()) == Some{[S.Variable{${WBL}}]} : ${MP}}:
  +dom = VR.domWB(t, JW(i), U32.to_nat(LLw(len)))
  %limw(${CWA}, ha, epo) :
    {Codec.parts(VALw(t, i, len), Spec.${n}()) == Some{[S.Variable{_}]} : ${MP}}
  %Equal.sym(${MP}, Codec.parts(${items(0)}, ${chain(0)}), Some{[${', '.join(parts)}]},
      ${cat(0)}) :
    {Codec.aggregate(_, None{}) == Some{[S.Variable{List.append(&2, U32, F.limbs(${HDR}), ${Y})}]} : ${MP}}
  %Equal.sym(${M}, Layout.encoding(VS.fpv(${PRE}, ${Y}, ${POST})), Some{${ENCR}}, VBC.enc_fpvb(${PRE}, ${Y}, ${POST}, dom, fitw(${CWA}, ha))) :
    {Codec.one(_, None{}) == Some{[S.Variable{List.append(&2, U32, F.limbs(${HDR}), ${Y})}]} : ${MP}}
  {==}

# The spec parts of the value: one variable part, the window's bytes.
def specw(${CW}, +hchk: {CHKw(t, i, off, len) == True{} : Bool}) -> {Codec.parts(VALw(t, i, len), Spec.${n}()) == Some{[S.Variable{${WBL}}]} : ${MP}}:
  +a = U32.is_le(${FS}, len)
  +b = U32.is_eq(SPOw(t, i), ${FS})
  +c = ${CHK_child}
  specg(${CWA}, ch_a(a, b, c, hchk), FD.u32alg__eq_of(SPOw(t, i), ${FS}, ch_b(a, b, c, hchk)), ch_c(a, b, c, hchk))

@@ inv_text @@
def u32le(+a: U32, +b: U32, +h: {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool}) -> {U32.is_le(a, b) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(a), U32.to_nat(b)), U32.is_le(a, b), Equal.sym(Bool, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b)), h)

def subc(+n: U32, +k: U32, +y: Nat, +e: {U32.to_nat(n) == Nat.add(U32.to_nat(k), y) : Nat}) -> {U32.to_nat(U32.sub(n, k)) == y : Nat}:
  +le = FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(k), z) == True{} : Bool}, Nat.add(U32.to_nat(k), y), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), Nat.add(U32.to_nat(k), y), e), FD.nat__le_add_right(U32.to_nat(k), y))
  %Equal.sym(Nat, U32.to_nat(U32.sub(n, k)), Nat.sub(U32.to_nat(n), U32.to_nat(k)), FD.u32__sub_nat(n, k, le)) : {_ == y : Nat}
  %Equal.sym(Nat, U32.to_nat(n), Nat.add(U32.to_nat(k), y), e) : {Nat.sub(_, U32.to_nat(k)) == y : Nat}
  FD.nat__add_sub_cancel(U32.to_nat(k), y)

def chk_t(+t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32, {HA_}, +epo: {SPOw(t, i) == ${FS} : U32}, +hc: {${CHK_child} == True{} : Bool})
    -> ${GOAL}:
  %Equal.sym(Bool, U32.is_le(${FS}, len), True{}, ha) : {chk3(_, U32.is_eq(SPOw(t, i), ${FS}), ${CHK_child}) == True{} : Bool}
  %Equal.sym(U32, SPOw(t, i), ${FS}, epo) : {chk3(True{}, U32.is_eq(_, ${FS}), ${CHK_child}) == True{} : Bool}
  hc

def contra(${CW}, ${', '.join(decl_m)}, +eo2: {${OUT} == ${WBL} : +List<U32>}) -> ${GOAL}:
  +lY = List.length(&2, U32, ys)
  +elen = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, ${WBL}), Nat.add(${FS}n, lY), Equal.sym(Nat, List.length(&2, U32, ${WBL}), U32.to_nat(len), VR.lenWB(d, t, i, U32.to_nat(len), pf, hw)),
    Equal.trans(Nat, List.length(&2, U32, ${WBL}), List.length(&2, U32, ${OUT}), Nat.add(${FS}n, lY),
      Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), ${WBL}, ${OUT}, Equal.sym(+List<U32>, ${OUT}, ${WBL}, eo2)), f_len(${ALL})))
  +hF = FD.logic__subst(Nat, z => {Nat.is_le(${FS}n, z) == True{} : Bool}, Nat.add(${FS}n, lY), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), Nat.add(${FS}n, lY), elen), FD.nat__le_add_right(${FS}n, lY))
  +ha = u32le(${FS}, len, hF)
  +eLL = subc(len, ${FS}, lY, elen)
  +W2 = VR.WB(t, i, Nat.add(${FS}n, lY))
  +eW = Equal.cong(Nat, +List<U32>, z => VR.WB(t, i, z), U32.to_nat(len), Nat.add(${FS}n, lY), elen)
  +eo3 = Equal.trans(+List<U32>, ${OUT}, ${WBL}, W2, eo2, eW)
  # the offset word
  +hw2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(i), z), A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(len), Nat.add(${FS}n, lY), elen, hw)
  +b0 = VWN.byteW(d, t, i, ${po}n, Nat.add(${RF}n, lY), pf, hw2)
  +epo = VN.wordc(SPOw(t, i), ${FS}, Equal.trans(+List<U32>, F.limbs([SPOw(t, i)]), VS.bt(4n, VS.bdr(${P}n, W2)), N.digits(4n, ${FS}n),
    Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(${P}n, W2)), F.limbs([SPOw(t, i)]), b0),
    Equal.trans(+List<U32>, VS.bt(4n, VS.bdr(${P}n, W2)), VS.bt(4n, VS.bdr(${P}n, ${OUT})), N.digits(4n, ${FS}n),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bt(4n, VS.bdr(${P}n, z)), W2, ${OUT}, Equal.sym(+List<U32>, ${OUT}, W2, eo3)), f_off(${ALL}))))
  # the child's window
  +ty = Equal.trans(+List<U32>, ys, VS.bdr(${FS}n, ${OUT}), VR.WB(t, JW(i), U32.to_nat(LLw(len))),
    Equal.sym(+List<U32>, VS.bdr(${FS}n, ${OUT}), ys, f_tail(${ALL})),
    Equal.trans(+List<U32>, VS.bdr(${FS}n, ${OUT}), VS.bdr(${FS}n, W2), VR.WB(t, JW(i), U32.to_nat(LLw(len))),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bdr(${FS}n, z), ${OUT}, W2, eo3),
      Equal.trans(+List<U32>, VS.bdr(${FS}n, W2), VR.WB(t, JW(i), lY), VR.WB(t, JW(i), U32.to_nat(LLw(len))), VWN.tailW(t, i, ${H}n, lY),
        Equal.cong(Nat, +List<U32>, z => VR.WB(t, JW(i), z), lY, U32.to_nat(LLw(len)), Equal.sym(Nat, U32.to_nat(LLw(len)), lY, eLL)))))
  +eh2 = FD.logic__subst(+List<U32>, z => {Codec.parts(hv, ${CSCH}) == Some{[S.Variable{z}]} : ${MP}}, ys, VR.WB(t, JW(i), U32.to_nat(LLw(len))), ty, eh)
  +hc = CH.invw(d, t, n, JW(i), OWc(off), LLw(len), eoF(${CWA}, ha), hd, hwc(${CWA}, ha), hwc32(${CWA}, ha), pf, hv, eh2)
  chk_t(t, i, off, len, ha, epo, hc)

@@ TOP @@

def BF(t: FD.array__Tree<U32>, +n: U32) -> B.Buf: VR.BF(t, n)
def VW(+t: FD.array__Tree<U32>, +n: U32) -> +List<U32>: VS.bt(U32.to_nat(n), F.limbs(FD.array__slots(U32, t)))
def CHK(+t: FD.array__Tree<U32>, +n: U32) -> Bool: W.CHKw(t, 0n, 0, n)
def OBJ(+t: FD.array__Tree<U32>, +n: U32) -> @Tn: W.OBJw(t, 0n, 0, n)
def VAL(+t: FD.array__Tree<U32>, +n: U32) -> S.Value: W.VALw(t, 0n, n)

# The validator returns the buffer and CHK(t, n).
def ok_eval(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {@Tn_ok(BF(t, n), 0, n) == (BF(t, n), CHK(t, n)) : B.Buf & Bool}:
  W.ok_evalw(d, t, n, 0n, 0, n, {==}, hd, hn, VB.u32_lt(n), pf)

# Every buffer the validator accepts decodes to OBJ(t, n).
law decode_accept:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 28n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == True{} : Bool}
  {@Tn_decode(BF(t, n), n) == (BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, @Tn>}
def decode_accept(d, t, n, pf, hd, hn, hchk):
  %Equal.sym(B.Buf & Bool, @Tn_ok(BF(t, n), 0, n), (BF(t, n), CHK(t, n)), ok_eval(d, t, n, pf, hd, hn)) :
    {@Tn_built(n, _) == (BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, @Tn>}
  %Equal.sym(Bool, CHK(t, n), True{}, hchk) :
    {@Tn_built(n, (BF(t, n), _)) == (BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, @Tn>}
  %Equal.sym(B.Buf & @Tn, @Tn_read(BF(t, n), 0, n), (BF(t, n), OBJ(t, n)), W.readw(d, t, n, 0n, 0, n, {==}, hd, hn, VB.u32_lt(n), pf, hchk)) :
    {@Tn_some(_) == (BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, @Tn>}
  {==}

# When the validator refuses, the decoder returns None and the buffer.
law decode_none:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 28n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == False{} : Bool}
  {@Tn_decode(BF(t, n), n) == (BF(t, n), None{}) : B.Buf & Maybe<&1, @Tn>}
def decode_none(d, t, n, pf, hd, hn, hchk):
  %Equal.sym(B.Buf & Bool, @Tn_ok(BF(t, n), 0, n), (BF(t, n), CHK(t, n)), ok_eval(d, t, n, pf, hd, hn)) :
    {@Tn_built(n, _) == (BF(t, n), None{}) : B.Buf & Maybe<&1, @Tn>}
  %Equal.sym(Bool, CHK(t, n), False{}, hchk) :
    {@Tn_built(n, (BF(t, n), _)) == (BF(t, n), None{}) : B.Buf & Maybe<&1, @Tn>}
  {==}

# The bytes of every buffer the validator accepts are the spec encoding of VAL(t, n).
law decode_spec:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 28n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == True{} : Bool}
  Decoding.decodes(Spec.@N(), VW(t, n), VAL(t, n))
def decode_spec(d, t, n, pf, hd, hn, hchk):
  # the encoding opened over variables first (F.efl_bytes): the parts rewrite's motive over
  # Codec.bytes was compared with the spec encoding by running the encoder
  %F.efl_bytes(Spec.@N(), VAL(t, n)) : {_ == Some{VW(t, n)} : Maybe<&2, +List<U32>>}
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(VAL(t, n), Spec.@N()), Some{[S.Variable{VW(t, n)}]}, W.specw(d, t, n, 0n, 0, n, {==}, hd, hn, VB.u32_lt(n), pf, hchk)) :
    {Codec.bytes(_) == Some{VW(t, n)} : Maybe<&2, +List<U32>>}
  {==}

def agg3(+r: Maybe<&2, +List<U32>>, +bs: +List<U32>, +e: {Codec.bytes(Codec.one(r, None{})) == Some{bs} : Maybe<&2, +List<U32>>})
    -> {Codec.one(r, None{}) == Some{[S.Variable{bs}]} : Maybe<&2, +List<S.Part>>}:
  match r:
    case None{}: Empty.absurd({Codec.one(None{}, None{}) == Some{[S.Variable{bs}]} : Maybe<&2, +List<S.Part>>}, FD.logic__none_some(+List<U32>, bs, e))
    case Some{+ys}: Equal.cong(+List<U32>, Maybe<&2, +List<S.Part>>, z => Some{[S.Variable{z}]}, ys, bs, FD.logic__some_inj(+List<U32>, ys, bs, e))

def agg2(+ps: +List<S.Part>, +r: Maybe<&2, +List<U32>>, +er: {Layout.encoding(ps) == r : Maybe<&2, +List<U32>>}, +bs: +List<U32>,
    +e: {Codec.bytes(Codec.one(r, None{})) == Some{bs} : Maybe<&2, +List<U32>>})
    -> {Codec.aggregate(Some{ps}, None{}) == Some{[S.Variable{bs}]} : Maybe<&2, +List<S.Part>>}:
  %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding(ps), r, er) : {Codec.one(_, None{}) == Some{[S.Variable{bs}]} : Maybe<&2, +List<S.Part>>}
  agg3(r, bs, e)

# A variable-size container's bytes are its one variable part.
def agg_var(+m: Maybe<&2, +List<S.Part>>, +bs: +List<U32>, +e: {Codec.bytes(Codec.aggregate(m, None{})) == Some{bs} : Maybe<&2, +List<U32>>})
    -> {Codec.aggregate(m, None{}) == Some{[S.Variable{bs}]} : Maybe<&2, +List<S.Part>>}:
  match m:
    case None{}: Empty.absurd({Codec.aggregate(None{}, None{}) == Some{[S.Variable{bs}]} : Maybe<&2, +List<S.Part>>}, FD.logic__none_some(+List<U32>, bs, e))
    case Some{+ps}: agg2(ps, Layout.encoding(ps), {==}, bs, e)

def rej_v(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {CHK(t, n) == False{} : Bool},
    +v: S.Value, +e: {Codec.encoding_for_legal_type(Spec.@N(), v) == Some{VW(t, n)} : Maybe<&2, +List<U32>>}) -> Empty:
  match v:
    case S.Sequence{+items}:
      FD.logic__true_false(Equal.trans(Bool, True{}, CHK(t, n), False{},
        Equal.sym(Bool, CHK(t, n), True{}, W.invw(d, t, n, 0n, 0, n, {==}, hd, hn, VB.u32_lt(n), pf, S.Sequence{items}, agg_var(Codec.parts(items, @CHAIN), VW(t, n), e))), hchk))
@ABSURD
# When the validator refuses, no value is related to the buffer's bytes.
law decode_reject:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 28n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == False{} : Bool}
  Decoding.outside_image(Spec.@N(), VW(t, n))
def decode_reject(d, t, n, pf, hd, hn, hchk):
  v => e => rej_v(d, t, n, pf, hd, hn, hchk, v, e)

@@ COMMONX @@

def BF(t: FD.array__Tree<U32>, +n: U32) -> B.Buf: VR.BF(t, n)

def hlen(+d: Nat, +x: Nat, +len: U32, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(len), A.quad(VB.pw(d))) == True{} : Bool}:
  FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.left_below_sum(x, U32.to_nat(len)), hw)

# The payload of a one-part variable list.
def varpay(ps: +List<S.Part>) -> +List<U32>:
  match ps:
    case Con{S.Variable{+xs}, t}: xs
    case _: []

def var_inj(+a: +List<U32>, +b: +List<U32>, +e: {Some{[S.Variable{a}]} == Some{[S.Variable{b}]} : Maybe<&2, +List<S.Part>>}) -> {a == b : +List<U32>}:
  Equal.cong(+List<S.Part>, +List<U32>, z => varpay(z), [S.Variable{a}], [S.Variable{b}], FD.logic__some_inj(+List<S.Part>, [S.Variable{a}], [S.Variable{b}], e))

@@ _cx_reader @@

# The reader on the window, when the checks hold.
def readw(${CW}, +hchk: {CHKw(t, x, off, len) == True{} : Bool}) -> {${Tn}_read(BF(t, n), off, len) == ${RHS} : ${TY}}:
  +a = U32.is_le(${FS}, len)
  +b = U32.is_eq(SPOw(t, x), ${FS})
  +c = ${CHK_child}
  rd_go(${CWA}, ch_a(a, b, c, hchk), FD.u32alg__eq_of(SPOw(t, x), ${FS}, ch_b(a, b, c, hchk)), ch_c(a, b, c, hchk))

@@ _cx_spec_value @@
def FVc${i}(+t: FD.array__Tree<U32>, +x: Nat) -> S.Value: ${vals[i]}

def fvq${i}(+t: FD.array__Tree<U32>, +x: Nat) -> {${vals[i]} == FVc${i}(t, x) : S.Value}:
  {==}

def fxc${i}(+t: FD.array__Tree<U32>, +x: Nat) -> {Codec.parts(FVc${i}(t, x), ${schs[i]}) == ${FXR(i)}}:
  %fvq${i}(t, x) : {Codec.parts(_, ${schs[i]}) == ${FXR(i)}}
  ${nodes[i]['proof']}


@@ SMALL @@
def ITc(${TXL}) -> S.Value: ${sitems(0)}

def PSc(${TXL}) -> +List<S.Part>: VS.fpv(${PRE}, ${Y}, ${POST})

def ENCc(${TXL}) -> +List<U32>: ${ENCR}

def LHc(${TXL}) -> +List<U32>: List.append(&2, U32, F.limbs(${HDR}), ${Y})


@@ contx_text @@
def SPOw(t: FD.array__Tree<U32>, +x: Nat) -> U32: UR.RWN(t, Nat.add(${P}n, x))
def LLw(+len: U32) -> U32: U32.sub(len, ${FS})
def OWc(+off: U32) -> U32: U32.add(off, ${FS})
def JW(+x: Nat) -> Nat: Nat.add(${FS}n, x)

def chk3(a: Bool, b: Bool, c: Bool) -> Bool:
  match a:
    case False{}: False{}
    case True{}:
      match b:
        case False{}: False{}
        case True{}: c

def CHKw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool:
  chk3(U32.is_le(${FS}, len), U32.is_eq(SPOw(t, x), ${FS}), ${CHK_child})

def leF(+len: U32, ${HA}) -> {Nat.is_le(${FS}n, U32.to_nat(len)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(${FS}, len), Nat.is_le(${FS}n, U32.to_nat(len)), VU.le_u32(${FS}, len), ha)

def enF(+len: U32, ${HA}) -> {Nat.add(${FS}n, U32.to_nat(LLw(len))) == U32.to_nat(len) : Nat}:
  %Equal.sym(Nat, U32.to_nat(LLw(len)), Nat.sub(U32.to_nat(len), ${FS}n), FD.u32__sub_nat(len, ${FS}, leF(len, ha))) : {Nat.add(${FS}n, _) == U32.to_nat(len) : Nat}
  FD.nat__sub_add(U32.to_nat(len), ${FS}n, leF(len, ha))

# off + c at position c + x, for c <= ${FS}.
def eoc(${CW}, +c: U32, +k: Nat, +ec: {U32.to_nat(c) == k : Nat}, +hkF: {Nat.is_le(k, ${FS}n) == True{} : Bool}, ${HA})
    -> {U32.to_nat(U32.add(off, c)) == Nat.add(k, x) : Nat}:
  +hk = FD.nat__le_trans(k, ${FS}n, U32.to_nat(len), hkF, leF(len, ha))
  +h = FD.nat__le_lt_trans(Nat.add(k, x), Nat.add(U32.to_nat(len), x), FD.spec_common__pow2(32n), Order.add_right(k, U32.to_nat(len), x, hk),
    FD.logic__subst(Nat, z => {Nat.is_lt(z, FD.spec_common__pow2(32n)) == True{} : Bool}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw32))
  %ec : {U32.to_nat(U32.add(off, c)) == Nat.add(_, x) : Nat}
  VB.add_lt32(off, c, x, eo,
    FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(z, x), FD.spec_common__pow2(32n)) == True{} : Bool}, k, U32.to_nat(c), Equal.sym(Nat, U32.to_nat(c), k, ec), h))

# Room for s bytes at c + x, for c + s <= ${FS}.
def roomF(${CW}, ${HA}, +c: Nat, +s: Nat, +hc: {Nat.is_le(Nat.add(c, s), ${FS}n) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(c, x), s), ${PW}) == True{} : Bool}:
  UR.roomf(x, U32.to_nat(len), c, s, ${PW}, hw, FD.nat__le_trans(Nat.add(c, s), ${FS}n, U32.to_nat(len), hc, leF(len, ha)))

# The child's window: (${FS} + x) + (len - ${FS}) <= 4 2^d.
def hwc(${CW}, ${HA}) -> {Nat.is_le(Nat.add(JW(x), U32.to_nat(LLw(len))), ${PW}) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(z, ${PW}) == True{} : Bool}, Nat.add(x, Nat.add(${FS}n, U32.to_nat(LLw(len)))), Nat.add(${FS}n, Nat.add(x, U32.to_nat(LLw(len)))),
    FD.lru_nat_algebra__add_swap(x, ${FS}n, U32.to_nat(LLw(len))),
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, z), ${PW}) == True{} : Bool}, U32.to_nat(len), Nat.add(${FS}n, U32.to_nat(LLw(len))), Equal.sym(Nat, Nat.add(${FS}n, U32.to_nat(LLw(len))), U32.to_nat(len), enF(len, ha)), hw))

# ... and ends below 2^32.
def hwc32(${CW}, ${HA}) -> {Nat.is_lt(Nat.add(JW(x), U32.to_nat(LLw(len))), FD.spec_common__pow2(32n)) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_lt(z, FD.spec_common__pow2(32n)) == True{} : Bool}, Nat.add(x, Nat.add(${FS}n, U32.to_nat(LLw(len)))), Nat.add(${FS}n, Nat.add(x, U32.to_nat(LLw(len)))),
    FD.lru_nat_algebra__add_swap(x, ${FS}n, U32.to_nat(LLw(len))),
    FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(x, z), FD.spec_common__pow2(32n)) == True{} : Bool}, U32.to_nat(len), Nat.add(${FS}n, U32.to_nat(LLw(len))), Equal.sym(Nat, Nat.add(${FS}n, U32.to_nat(LLw(len))), U32.to_nat(len), enF(len, ha)), hw32))

def eoF(${CW}, ${HA}) -> {U32.to_nat(OWc(off)) == JW(x) : Nat}:
  eoc(${CWA}, ${FS}, ${FS}n, {==}, {==}, ha)

# ---- the validator ----------------------------------------------------------------------------

def c1_id(+ok: Bool, buf: B.Buf, +off: U32, +len: U32, +o0: U32) -> {${Tn}_c1(ok, buf, off, len, o0) == (buf, ok) : B.Buf & Bool}:
  match ok:
    case True{}: {==}
    case False{}: {==}

def okc0(${CW}, ${HA}, +b: Bool, +eb: {U32.is_eq(SPOw(t, x), ${FS}) == b : Bool})
    -> {${Tn}_c0(b, BF(t, n), off, len, SPOw(t, x)) == (BF(t, n), chk3(True{}, b, ${CHK_child})) : B.Buf & Bool}:
  match b:
    case False{}: {==}
    case True{}:
      +epo = FD.u32alg__eq_of(SPOw(t, x), ${FS}, eb)
      %Equal.sym(U32, SPOw(t, x), ${FS}, epo) :
        {${Tn}_v1(off, len, _, T.${x.okf}_ok(BF(t, n), U32.add(off, _), U32.sub(len, _))) == (BF(t, n), ${CHK_child}) : B.Buf & Bool}
      %Equal.sym(B.Buf & Bool, T.${x.okf}_ok(BF(t, n), OWc(off), LLw(len)), (BF(t, n), ${CHK_child}),
          CH.ok_evalwD(d, t, n, JW(x), OWc(off), LLw(len), eoF(${CWA}, ha), hd, hwc(${CWA}, ha), hwc32(${CWA}, ha), pf)) :
        {${Tn}_v1(off, len, ${FS}, _) == (BF(t, n), ${CHK_child}) : B.Buf & Bool}
      c1_id(${CHK_child}, BF(t, n), off, len, ${FS})

def rdpo(${CW}, ${HA}) -> {B.read32(BF(t, n), U32.add(off, ${P})) == (BF(t, n), SPOw(t, x)) : B.Buf & U32}:
  UR.rwx(d, t, n, U32.add(off, ${P}), Nat.add(${P}n, x), eoc(${CWA}, ${P}, ${P}n, {==}, {==}, ha), FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf,
    roomF(${CWA}, ha, ${P}n, 4n, {==}))

def okl(${CW}, +a: Bool, +ea: {U32.is_le(${FS}, len) == a : Bool})
    -> {${Tn}_ok_len(a, BF(t, n), off, len) == (BF(t, n), chk3(a, U32.is_eq(SPOw(t, x), ${FS}), ${CHK_child})) : B.Buf & Bool}:
  match a:
    case False{}: {==}
    case True{}:
      %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, ${P})), (BF(t, n), SPOw(t, x)), rdpo(${CWA}, ea)) :
        {${Tn}_v0(off, len, _) == (BF(t, n), chk3(True{}, U32.is_eq(SPOw(t, x), ${FS}), ${CHK_child})) : B.Buf & Bool}
      okc0(${CWA}, ea, U32.is_eq(SPOw(t, x), ${FS}), {==})

# The validator on the window returns the buffer and CHKw.
def ok_evalw(${CW}) -> {${Tn}_ok(BF(t, n), off, len) == (BF(t, n), CHKw(t, x, off, len)) : B.Buf & Bool}:
  okl(${CWA}, U32.is_le(${FS}, len), {==})

def ch_a(+a: Bool, +b: Bool, +c: Bool, +h: {chk3(a, b, c) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case False{}: h
    case True{}: {==}

def ch_b(+a: Bool, +b: Bool, +c: Bool, +h: {chk3(a, b, c) == True{} : Bool}) -> {b == True{} : Bool}:
  match a b:
    case False{} _: Empty.absurd({b == True{} : Bool}, FD.logic__false_true(h))
    case True{} False{}: h
    case True{} True{}: {==}

def ch_c(+a: Bool, +b: Bool, +c: Bool, +h: {chk3(a, b, c) == True{} : Bool}) -> {c == True{} : Bool}:
  match a b:
    case False{} _: Empty.absurd({c == True{} : Bool}, FD.logic__false_true(h))
    case True{} False{}: Empty.absurd({c == True{} : Bool}, FD.logic__false_true(h))
    case True{} True{}: h

@@ contx_text_VALw @@
def VALw(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value: S.Sequence{${items(0)}}

def fitw(${CW}, ${HA}) -> {N.fits(4n, Nat.add(VS.FSZ(${PRE}, ${POST}), List.length(&2, U32, ${Y}))) == True{} : Bool}:
  %Equal.sym(Nat, List.length(&2, U32, ${Y}), ${LLn}, UW.lenWX(d, t, JW(x), ${LLn}, pf, hwc(${CWA}, ha))) : {N.fits(4n, Nat.add(${FS}n, _)) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(${FS}n, ${LLn}), U32.to_nat(len), enF(len, ha)) : {N.fits(4n, _) == True{} : Bool}
  VFT.fits4lt(U32.to_nat(len), FD.nat__le_lt_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), FD.spec_common__pow2(32n), Order.left_below_sum(x, U32.to_nat(len)), hw32))

# The window's bytes: the header words' limbs, then the child's window.
def limw(${CW}, ${HA}, +epo: {SPOw(t, x) == ${FS} : U32})
    -> {List.append(&2, U32, F.limbs(${HDR}), ${Y}) == ${WBL} : +List<U32>}:
  +hw2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, z), ${PW}) == True{} : Bool}, U32.to_nat(len), Nat.add(${FS}n, ${LLn}), Equal.sym(Nat, Nat.add(${FS}n, ${LLn}), U32.to_nat(len), enF(len, ha)), hw)
  %enF(len, ha) : {List.append(&2, U32, F.limbs(${HDR}), ${Y}) == UW.WX(t, x, _) : +List<U32>}
  %Equal.sym(+List<U32>, UW.WX(t, x, Nat.add(A.quad(${H}n), ${LLn})), List.append(&2, U32, F.limbs(UR.RWS(${H}n, t, x)), UW.WX(t, Nat.add(A.quad(${H}n), x), ${LLn})),
      UW.headWX(d, t, x, ${H}n, ${LLn}, pf, hw2)) :
    {List.append(&2, U32, F.limbs(${HDR}), ${Y}) == _ : +List<U32>}
  %epo : {List.append(&2, U32, F.limbs(${HDRh}), ${Y}) == List.append(&2, U32, F.limbs(UR.RWS(${H}n, t, x)), ${Y}) : +List<U32>}
  {==}

# Definitions per step: a container's parts one step down and one field before the rest, over opaque values
# (a conversion that is not a syntactic match would evaluate the fields' parts).
def gcv_(+v: S.Value, +vs: S.Value, +s: S.Schema, +rs: S.Schema, +y: +List<U32>, +rest: +List<S.Part>,
    +ea: {Codec.parts(v, s) == Some{[S.Variable{y}]} : Maybe<&2, +List<S.Part>>}, +eb: {Codec.parts(vs, rs) == Some{rest} : Maybe<&2, +List<S.Part>>})
    -> {Codec.parts(S.Items{v, vs}, S.Chain{s, rs}) == Some{S.Variable{y} <> rest} : Maybe<&2, +List<S.Part>>}:
  VS.cat_var(Codec.parts(v, s), y, Codec.parts(vs, rs), rest, ea, eb)

def gcf_(+v: S.Value, +vs: S.Value, +s: S.Schema, +rs: S.Schema, +xs: +List<U32>, +rest: +List<S.Part>,
    +ea: {Codec.parts(v, s) == Some{[S.Fixed{xs}]} : Maybe<&2, +List<S.Part>>}, +eb: {Codec.parts(vs, rs) == Some{rest} : Maybe<&2, +List<S.Part>>})
    -> {Codec.parts(S.Items{v, vs}, S.Chain{s, rs}) == Some{S.Fixed{xs} <> rest} : Maybe<&2, +List<S.Part>>}:
  F.cat_fixed(Codec.parts(v, s), xs, Codec.parts(vs, rs), rest, ea, eb)


@@ contx_text_vwc @@
def vwc(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> {S.Sequence{ITc(t, x, len)} == VALw(t, x, len) : S.Value}:
  {==}

def lct(+it: S.Value) -> {Codec.aggregate(Codec.parts(it, ${chain(0)}), None{}) == Codec.parts(S.Sequence{it}, Spec.${n}()) : ${MP}}:
  {==}

def aggS(+xs: +List<S.Part>, +w: Maybe<&2, Nat>) -> {Codec.one(Layout.encoding(xs), w) == Codec.aggregate(Some{xs}, w) : ${MP}}:
  {==}

def limwS(${CW}, ${HA}, +epo: {SPOw(t, x) == ${FS} : U32}) -> {${LH} == ${WBL} : +List<U32>}:
  limw(${CWA}, ha, epo)

def catS(${CW}, ${HA}, +hc: {${CHK_child} == True{} : Bool}) -> {Codec.parts(ITc(t, x, len), ${chain(0)}) == Some{PSc(t, x, len)} : ${MP}}:
  ${cat(0)}

def encS(${CW}, ${HA}) -> {Layout.encoding(PSc(t, x, len)) == Some{ENCc(t, x, len)} : ${M}}:
  VBC.enc_fpvb(${PRE}, ${Y}, ${POST}, UW.domWX(t, JW(x), ${LLn}), fitw(${CWA}, ha))

def specg(${CW}, ${HA}, +epo: {SPOw(t, x) == ${FS} : U32}, +hc: {${CHK_child} == True{} : Bool})
    -> {Codec.parts(VALw(t, x, len), Spec.${n}()) == Some{[S.Variable{${WBL}}]} : ${MP}}:
  %limwS(${CWA}, ha, epo) : {Codec.parts(VALw(t, x, len), Spec.${n}()) == Some{[S.Variable{_}]} : ${MP}}
  %vwc(t, x, len) : {Codec.parts(_, Spec.${n}()) == Some{[S.Variable{${LH}}]} : ${MP}}
  %lct(ITc(t, x, len)) : {_ == Some{[S.Variable{${LH}}]} : ${MP}}
  %Equal.sym(${MP}, Codec.parts(ITc(t, x, len), ${chain(0)}), Some{PSc(t, x, len)}, catS(${CWA}, ha, hc)) :
    {Codec.aggregate(_, None{}) == Some{[S.Variable{${LH}}]} : ${MP}}
  %aggS(PSc(t, x, len), None{}) : {_ == Some{[S.Variable{${LH}}]} : ${MP}}
  %Equal.sym(${M}, Layout.encoding(PSc(t, x, len)), Some{ENCc(t, x, len)}, encS(${CWA}, ha)) :
    {Codec.one(_, None{}) == Some{[S.Variable{${LH}}]} : ${MP}}
  {==}

# The spec parts of the value: one variable part, the window's bytes.
def specw(${CW}, +hchk: {CHKw(t, x, off, len) == True{} : Bool}) -> {Codec.parts(VALw(t, x, len), Spec.${n}()) == Some{[S.Variable{${WBL}}]} : ${MP}}:
  +a = U32.is_le(${FS}, len)
  +b = U32.is_eq(SPOw(t, x), ${FS})
  +c = ${CHK_child}
  specg(${CWA}, ch_a(a, b, c, hchk), FD.u32alg__eq_of(SPOw(t, x), ${FS}, ch_b(a, b, c, hchk)), ch_c(a, b, c, hchk))

@@ LISTX @@

def v8() -> Word(31n): FD.spec_numeric__from_nat(31n, 8n)
def CQ(+len: U32) -> Nat: U32.to_nat(U32.div(len, 8))

# Whole elements, at most @N.
def CHKw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool: Bool.and(U32.is_eq(len, (U32.div(len, 8) * 8 : U32)), U32.is_le(U32.div(len, 8), @N))

# The validator on the window returns the buffer and CHKw.
def ok_evalw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {T.@p_ok(BF(t, n), off, len) == (BF(t, n), CHKw(t, x, off, len)) : B.Buf & Bool}:
  {==}

def eLc(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {CHKw(t, x, off, len) == True{} : Bool}) -> {U32.to_nat(len) == VS.x8(CQ(len)) : Nat}:
  %VC.x8_mul(CQ(len)) : {U32.to_nat(len) == _ : Nat}
  Pair.fst({U32.to_nat(len) == Nat.mul(CQ(len), U32.to_nat(8)) : Nat}, {Nat.is_le(CQ(len), U32.to_nat(@N)) == True{} : Bool},
    VU.whole_t(len, 8, @N, v8(), {==}, {==}, {==}, hc))

def hcL(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {CHKw(t, x, off, len) == True{} : Bool}) -> {Nat.is_le(CQ(len), U32.to_nat(@N)) == True{} : Bool}:
  Pair.snd({U32.to_nat(len) == Nat.mul(CQ(len), U32.to_nat(8)) : Nat}, {Nat.is_le(CQ(len), U32.to_nat(@N)) == True{} : Bool},
    VU.whole_t(len, 8, @N, v8(), {==}, {==}, {==}, hc))
@ZEROS
def hWZ(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hL: {Nat.is_le(U32.to_nat(len), A.quad(VB.pw(d))) == True{} : Bool}, +hc: {CHKw(t, x, off, len) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(VC.WZ(len)), O.pow2n(@Kn)) == True{} : Bool}:
  +hx = FD.logic__subst(Nat, z => {Nat.is_le(z, VS.x8(U32.to_nat(@N))) == True{} : Bool}, VS.x8(CQ(len)), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), VS.x8(CQ(len)), eLc(t, x, off, len, hc)),
    VS.x8_mono(CQ(len), U32.to_nat(@N), hcL(t, x, off, len, hc)))
  FD.nat__le_trans(U32.to_nat(VC.WZ(len)), Nat.add(VD.s_rng(2n, VC.YL(len)), 8n), O.pow2n(@Kn),
    VC.wz_le(len, VLS.KK(d), VLS.kk_lt(d, hd), VLS.hyn(d, len, hL)),
    FD.nat__le_trans(Nat.add(VD.s_rng(2n, VC.YL(len)), 8n), Nat.add(VD.s_rng(2n, Nat.add(31n, VS.x8(U32.to_nat(@N)))), 8n), O.pow2n(@Kn),
      Order.add_right(VD.s_rng(2n, VC.YL(len)), VD.s_rng(2n, Nat.add(31n, VS.x8(U32.to_nat(@N)))), 8n, VC.rng_mono(2n, VC.YL(len), Nat.add(31n, VS.x8(U32.to_nat(@N))), Order.add_left(31n, U32.to_nat(len), VS.x8(U32.to_nat(@N)), hx))),
      {==}))

def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> O.Words: O.Words{FD.array__thaw(U32, UCT.CT(d, t, off, len, VLS.DZ(len))), len}

# The reader on the window, when the checks hold.
def readw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {CHKw(t, x, off, len) == True{} : Bool})
    -> {T.@p_read(BF(t, n), off, len) == (BF(t, n), OBJw(d, t, x, off, len)) : B.Buf & O.Words}:
  +hL = hlen(d, x, len, hw)
  +hz = VD.wd_min(VC.WZ(len), @Kn, hWZ(d, t, x, off, len, hd, hL, hchk))
  +ez = zeros_at(B.words_depth_u(VC.WZ(len)), VLS.DZ(len), VD.wdu(VC.WZ(len)), hz)
  UCT.copy_in_at(d, t, n, off, len, VLS.DZ(len), VLS.KK(d), pf, FD.nat__lt_trans(d, 28n, 31n, hd, {==}), FD.nat__le_lt_trans(VLS.DZ(len), @Kn, 31n, hz, {==}), ez,
    UW.hsx(d, off, x, len, eo, hd, hw), VLS.hrg(d, len, hd, hL), VLS.kk_lt(d, hd), VLS.hyn(d, len, hL))

def VALw(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value: S.Sequence{VS.uitems(CQ(len), UR.RWS(Nat.double(CQ(len)), t, x))}

# The spec parts of the value: one variable part, the window's bytes.
def specw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {CHKw(t, x, off, len) == True{} : Bool})
    -> {Codec.parts(VALw(t, x, len), @SCH) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}:
  +k = CQ(len)
  +W = UR.RWS(Nat.double(k), t, x)
  +el = Equal.trans(Nat, U32.to_nat(len), VS.x8(k), VB.d3(k), eLc(t, x, off, len, hchk), VB.x8_d3(k))
  %Equal.sym(Nat, U32.to_nat(len), VB.d3(k), el) : {Codec.parts(VALw(t, x, len), @SCH) == Some{[S.Variable{UW.WX(t, x, _)}]} : Maybe<&2, +List<S.Part>>}
  %UR.rws_bytes(Nat.double(k), d, t, x, pf, FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, z), A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(len), VB.d3(k), el, hw)) :
    {Codec.parts(VALw(t, x, len), @SCH) == Some{[S.Variable{_}]} : Maybe<&2, +List<S.Part>>}
  %UR.wtake_rws(Nat.double(k), t, x) : {Codec.parts(VALw(t, x, len), @SCH) == Some{[S.Variable{F.limbs(_)}]} : Maybe<&2, +List<S.Part>>}
  VS.list_u64_parts(k, W, @LIMN, hcL(t, x, off, len, hchk), {==},
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.double(k), z) == True{} : Bool}, Nat.double(k), VB.len(W), Equal.sym(Nat, VB.len(W), Nat.double(k), UR.rws_len(Nat.double(k), t, x)), FD.nat__le_refl(Nat.double(k))))

# ---- every value whose spec parts are the window's bytes passes the checks ----------------------

def ivf(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +c: Nat, +hk: {Nat.is_le(c, U32.to_nat(@N)) == True{} : Bool},
    +ys: +List<U32>, +ly: {List.length(&2, U32, ys) == VS.x8(c) : Nat}, +ey: {ys == UW.WX(t, x, U32.to_nat(len)) : +List<U32>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  +el = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), VS.x8(c),
    Equal.sym(Nat, List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)),
    Equal.trans(Nat, List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), List.length(&2, U32, ys), VS.x8(c),
      Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), UW.WX(t, x, U32.to_nat(len)), ys, Equal.sym(+List<U32>, ys, UW.WX(t, x, U32.to_nat(len)), ey)), ly))
  VU.whole_i(len, 8, @N, v8(), {==}, {==}, {==}, c, Equal.trans(Nat, U32.to_nat(len), VS.x8(c), Nat.mul(c, 8n), el, Equal.sym(Nat, Nat.mul(c, 8n), VS.x8(c), VC.x8_mul(c))), hk)

def ivm4(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +its: S.Value, +hk: {Nat.is_le(Codec.count(its), U32.to_nat(@N)) == True{} : Bool},
    +ps: +List<S.Part>, +em3: {Codec.parts(its, S.Repeat{@EL}) == Some{ps} : Maybe<&2, +List<S.Part>>},
    +m4: Maybe<&2, +List<U32>>, +em4: {Layout.encoding(ps) == m4 : Maybe<&2, +List<U32>>},
    +e: {Codec.one(m4, None{}) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  match m4:
    case None{}: Empty.absurd({CHKw(t, x, off, len) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, [S.Variable{UW.WX(t, x, U32.to_nat(len))}], e))
    case Some{+ys}:
      +lys = Equal.trans(Nat, List.length(&2, U32, ys), Layout.fixed_size(ps), VS.x8(Codec.count(its)),
        VS.enc_len(ps, ys, Pair.fst({VS.allfix(ps) == True{} : Bool}, {Layout.fixed_size(ps) == VS.x8(Codec.count(its)) : Nat}, VS.rep_facts(its, ps, em3)), em4),
        Pair.snd({VS.allfix(ps) == True{} : Bool}, {Layout.fixed_size(ps) == VS.x8(Codec.count(its)) : Nat}, VS.rep_facts(its, ps, em3)))
      ivf(d, t, x, off, len, hw, pf, Codec.count(its), hk, ys, lys, var_inj(ys, UW.WX(t, x, U32.to_nat(len)), e))

def ivm3(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +its: S.Value, +hk: {Nat.is_le(Codec.count(its), U32.to_nat(@N)) == True{} : Bool},
    +m3: Maybe<&2, +List<S.Part>>, +em3: {Codec.parts(its, S.Repeat{@EL}) == m3 : Maybe<&2, +List<S.Part>>},
    +e: {Codec.aggregate(m3, None{}) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  match m3:
    case None{}: Empty.absurd({CHKw(t, x, off, len) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, [S.Variable{UW.WX(t, x, U32.to_nat(len))}], e))
    case Some{+ps}: ivm4(d, t, x, off, len, hw, pf, its, hk, ps, em3, Layout.encoding(ps), {==}, e)

def ivb(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +its: S.Value, +b2: Bool, +eb2: {Nat.is_le(Codec.count(its), U32.to_nat(@N)) == b2 : Bool},
    +e: {Codec.require(b2, Codec.aggregate(Codec.parts(its, S.Repeat{@EL}), None{})) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  match b2:
    case False{}: Empty.absurd({CHKw(t, x, off, len) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, [S.Variable{UW.WX(t, x, U32.to_nat(len))}], e))
    case True{}: ivm3(d, t, x, off, len, hw, pf, its, eb2, Codec.parts(its, S.Repeat{@EL}), {==}, e)

# Every value whose spec parts are the window's bytes passes the checks.
def invw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +v: S.Value,
    +e: {Codec.parts(v, @SCH) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  match v:
    case S.Sequence{+its}: ivb(d, t, x, off, len, hw, pf, its, Nat.is_le(Codec.count(its), U32.to_nat(@N)), {==}, e)
@ABSURDV

@@ LISTX_DEEP_BOUNDS @@

# 31 + len <= 2^@KB: the checks bound the length (whatever the buffer's depth).
def hyN(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {CHKw(t, x, off, len) == True{} : Bool}) -> {Nat.is_le(VC.YL(len), Nat.add(31n, VS.x8(U32.to_nat(@N)))) == True{} : Bool}:
  +hx = FD.logic__subst(Nat, z => {Nat.is_le(z, VS.x8(U32.to_nat(@N))) == True{} : Bool}, VS.x8(CQ(len)), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), VS.x8(CQ(len)), eLc(t, x, off, len, hc)),
    VS.x8_mono(CQ(len), U32.to_nat(@N), hcL(t, x, off, len, hc)))
  Order.add_left(31n, U32.to_nat(len), VS.x8(U32.to_nat(@N)), hx)

def hyL(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {CHKw(t, x, off, len) == True{} : Bool}) -> {Nat.is_le(VC.YL(len), VB.pw(@KBn)) == True{} : Bool}:
  FD.nat__le_trans(VC.YL(len), Nat.add(31n, VS.x8(U32.to_nat(@N))), VB.pw(@KBn), hyN(t, x, off, len, hc), {==})

def hWZ(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {CHKw(t, x, off, len) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(VC.WZ(len)), O.pow2n(@Kn)) == True{} : Bool}:
  FD.nat__le_trans(U32.to_nat(VC.WZ(len)), Nat.add(VD.s_rng(2n, VC.YL(len)), 8n), O.pow2n(@Kn),
    VC.wz_le(len, @KBn, {==}, hyL(t, x, off, len, hc)),
    FD.nat__le_trans(Nat.add(VD.s_rng(2n, VC.YL(len)), 8n), Nat.add(VD.s_rng(2n, Nat.add(31n, VS.x8(U32.to_nat(@N)))), 8n), O.pow2n(@Kn),
      Order.add_right(VD.s_rng(2n, VC.YL(len)), VD.s_rng(2n, Nat.add(31n, VS.x8(U32.to_nat(@N)))), 8n, VC.rng_mono(2n, VC.YL(len), Nat.add(31n, VS.x8(U32.to_nat(@N))), hyN(t, x, off, len, hc))),
      {==}))

# The list storage has room for the words.
def hrgL(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {CHKw(t, x, off, len) == True{} : Bool})
    -> {Nat.is_le(Nat.add(VC.NW(len), 0n), VB.pw(VLS.DZ(len))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(VC.NW(len), 0n), VC.NW(len), FD.nat__add_zero(VC.NW(len))) : {Nat.is_le(_, VB.pw(VLS.DZ(len))) == True{} : Bool}
  %Equal.sym(Nat, VB.pw(VLS.DZ(len)), O.pow2n(VLS.DZ(len)), VD.s_pow2_eq(VLS.DZ(len))) : {Nat.is_le(VC.NW(len), _) == True{} : Bool}
  FD.nat__le_trans(VC.NW(len), U32.to_nat(VC.WZ(len)), O.pow2n(VLS.DZ(len)), VC.nw_le_wz(len, @KBn, {==}, hyL(t, x, off, len, hc)), VD.wd_cover(VC.WZ(len), @Kn, {==}, hWZ(t, x, off, len, hc)))

@@ listx40_text @@
# Whole elements (a U32 length is below the limit).
def CHKw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool: Bool.and(U32.is_eq(len, (U32.div(len, 8) * 8 : U32)), True{})

def eLc(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {CHKw(t, x, off, len) == True{} : Bool}) -> {U32.to_nat(len) == VS.x8(CQ(len)) : Nat}:
  %VC.x8_mul(CQ(len)) : {U32.to_nat(len) == _ : Nat}
  V40.whole_e(len, 8, v8(), {==}, {==}, {==}, FD.logic__and_left(U32.is_eq(len, (U32.div(len, 8) * 8 : U32)), True{}, hc))

def hcL(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {CHKw(t, x, off, len) == True{} : Bool}) -> {Nat.is_le(CQ(len), @LIMN) == True{} : Bool}:
  V40.u32le40(U32.div(len, 8))
@@ ivf @@

def ivf(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +c: Nat, +hk: {Nat.is_le(c, @LIMN) == True{} : Bool},
    +ys: +List<U32>, +ly: {List.length(&2, U32, ys) == VS.x8(c) : Nat}, +ey: {ys == UW.WX(t, x, U32.to_nat(len)) : +List<U32>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  +el = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), VS.x8(c),
    Equal.sym(Nat, List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)),
    Equal.trans(Nat, List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), List.length(&2, U32, ys), VS.x8(c),
      Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), UW.WX(t, x, U32.to_nat(len)), ys, Equal.sym(+List<U32>, ys, UW.WX(t, x, U32.to_nat(len)), ey)), ly))
  +hc = FD.logic__subst(Nat, z => {Nat.is_le(c, z) == True{} : Bool}, VS.x8(c), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), VS.x8(c), el), V40.x8ge(c))
  +w = VU.whole_i(len, 8, len, v8(), {==}, {==}, {==}, c, Equal.trans(Nat, U32.to_nat(len), VS.x8(c), Nat.mul(c, 8n), el, Equal.sym(Nat, Nat.mul(c, 8n), VS.x8(c), VC.x8_mul(c))), hc)
  FD.logic__and_intro(U32.is_eq(len, (U32.div(len, 8) * 8 : U32)), True{}, FD.logic__and_left(U32.is_eq(len, (U32.div(len, 8) * 8 : U32)), U32.is_le(U32.div(len, 8), len), w), {==})

@@ LISTU8X40 @@

def v1() -> Word(31n): FD.spec_numeric__from_nat(31n, 1n)

# Whole elements: every length is (one-byte elements; a U32 length is below the limit).
def CHKw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool: Bool.and(U32.is_eq(len, (U32.div(len, 1) * 1 : U32)), True{})

# The validator on the window returns the buffer and CHKw.
def ok_evalw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {T.@p_ok(BF(t, n), off, len) == (BF(t, n), CHKw(t, x, off, len)) : B.Buf & Bool}:
  {==}

# The checks hold for every window.
def chk(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> {CHKw(t, x, off, len) == True{} : Bool}:
  +w = VU.whole_i(len, 1, len, v1(), {==}, {==}, {==}, U32.to_nat(len), PB.mul1(U32.to_nat(len)), FD.nat__le_refl(U32.to_nat(len)))
  FD.logic__and_intro(U32.is_eq(len, (U32.div(len, 1) * 1 : U32)), True{}, FD.logic__and_left(U32.is_eq(len, (U32.div(len, 1) * 1 : U32)), U32.is_le(U32.div(len, 1), len), w), {==})

def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> O.Words: O.Words{FD.array__thaw(U32, UCT.CT(d, t, off, len, VLS.DZ(len))), len}

# The reader on the window, when the checks hold.
def readw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {CHKw(t, x, off, len) == True{} : Bool})
    -> {T.@p_read(BF(t, n), off, len) == (BF(t, n), OBJw(d, t, x, off, len)) : B.Buf & O.Words}:
  +hL = hlen(d, x, len, hw)
  +hz = VLS.hdz29(d, len, hd, hL)
  +ez = FD.logic__subst(Nat, z => {B.zeros(B.words_depth_u(VC.WZ(len))) == Array.new(U32, z, 0) : Array<U32>}, U32.to_nat(B.words_depth_u(VC.WZ(len))), VLS.DZ(len),
    VD.wdu(VC.WZ(len)), VZG.zg(B.words_depth_u(VC.WZ(len))))
  UCT.copy_in_at(d, t, n, off, len, VLS.DZ(len), VLS.KK(d), pf, FD.nat__lt_trans(d, 28n, 31n, hd, {==}), FD.nat__le_lt_trans(VLS.DZ(len), 29n, 31n, hz, {==}), ez,
    UW.hsx(d, off, x, len, eo, hd, hw), VLS.hrg(d, len, hd, hL), VLS.kk_lt(d, hd), VLS.hyn(d, len, hL))

def VALw(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value: S.Sequence{PB.it1(U32.to_nat(len), UW.WX(t, x, U32.to_nat(len)))}

# The spec parts of the value: one variable part, the window's bytes.
def specw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {CHKw(t, x, off, len) == True{} : Bool})
    -> {Codec.parts(VALw(t, x, len), @SCH) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}:
  +Y = UW.WX(t, x, U32.to_nat(len))
  +hs = FD.logic__subst(Nat, z => {SP.byte_scope(z, Y) == True{} : Bool}, List.length(&2, U32, Y), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw),
    U8.dom_scope(Y, UW.domWX(t, x, U32.to_nat(len))))
  U8.listu8_parts(U32.to_nat(len), Y, @LIMN, V40.u32le40(len), hs, VFT.fits4(2n+d, U32.to_nat(len), hlen(d, x, len, hw), FD.nat__lt_trans(d, 28n, 30n, hd, {==})))

# Every value whose spec parts are the window's bytes passes the checks (every window does).
def invw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +v: S.Value,
    +e: {Codec.parts(v, @SCH) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  chk(t, x, off, len)

@@ ASX @@

def O0(t: FD.array__Tree<U32>, +x: Nat) -> U32: UR.RWN(t, x)
def O1(t: FD.array__Tree<U32>, +x: Nat) -> U32: UR.RWN(t, 4n+x)
def L0(+t: FD.array__Tree<U32>, +x: Nat) -> U32: U32.sub(O1(t, x), O0(t, x))
def L1(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> U32: U32.sub(len, O1(t, x))
def J0(+t: FD.array__Tree<U32>, +x: Nat) -> Nat: Nat.add(U32.to_nat(O0(t, x)), x)
def J1(+t: FD.array__Tree<U32>, +x: Nat) -> Nat: Nat.add(U32.to_nat(O1(t, x)), x)
def W0(+t: FD.array__Tree<U32>, +x: Nat, +off: U32) -> U32: U32.add(off, O0(t, x))
def W1(+t: FD.array__Tree<U32>, +x: Nat, +off: U32) -> U32: U32.add(off, O1(t, x))

def ck(a: Bool, b: Bool) -> Bool:
  match a:
    case False{}: False{}
    case True{}: b

def RR(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> Bool: Bool.and(U32.is_le(O0(t, x), O1(t, x)), U32.is_le(O1(t, x), len))
def D0(+t: FD.array__Tree<U32>, +x: Nat, +off: U32) -> Bool: CH.CHKw(t, J0(t, x), W0(t, x, off), L0(t, x))
def D1(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool: CH.CHKw(t, J1(t, x), W1(t, x, off), L1(t, x, len))

# The fixed part is there, the first offset is 8, the second lies between it
# and the end, and both windows pass the child's checks.
def CHKw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool:
  ck(U32.is_le(8, len), ck(U32.is_eq(O0(t, x), 8), ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len)))))

def ck_a(+a: Bool, +b: Bool, +h: {ck(a, b) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case False{}: h
    case True{}: {==}

def ck_b(+a: Bool, +b: Bool, +h: {ck(a, b) == True{} : Bool}) -> {b == True{} : Bool}:
  match a:
    case False{}: Empty.absurd({b == True{} : Bool}, FD.logic__false_true(h))
    case True{}: h

def le_nat(+a: U32, +b: U32, +h: {U32.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b), h)

def u32le(+a: U32, +b: U32, +h: {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool}) -> {U32.is_le(a, b) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(a), U32.to_nat(b)), U32.is_le(a, b), Equal.sym(Bool, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b)), h)

# ---- window facts -------------------------------------------------------------------------------

# A byte position c <= len of the window, as an offset: off + c at c + x.
def eoj(@CW, +o: U32, +h: {Nat.is_le(U32.to_nat(o), U32.to_nat(len)) == True{} : Bool})
    -> {U32.to_nat(U32.add(off, o)) == Nat.add(U32.to_nat(o), x) : Nat}:
  +hl = FD.nat__le_trans(Nat.add(U32.to_nat(o), x), Nat.add(U32.to_nat(len), x), A.quad(VB.pw(d)), Order.add_right(U32.to_nat(o), U32.to_nat(len), x, h),
    FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw))
  VB.add_at(off, o, x, 3n+d, eo, FD.nat__lt_trans(3n+d, 31n, 32n, hd, {==}), VB.le_pw_lt(Nat.add(U32.to_nat(o), x), 2n+d, hl))

# (o + x) + (e - o) = x + e.
def alg(+o: Nat, +x: Nat, +e: Nat, +h: {Nat.is_le(o, e) == True{} : Bool}) -> {Nat.add(Nat.add(o, x), Nat.sub(e, o)) == Nat.add(x, e) : Nat}:
  %Equal.sym(Nat, Nat.add(Nat.add(o, x), Nat.sub(e, o)), Nat.add(o, Nat.add(x, Nat.sub(e, o))), FD.nat__add_assoc(o, x, Nat.sub(e, o))) : {_ == Nat.add(x, e) : Nat}
  %Equal.sym(Nat, Nat.add(o, Nat.add(x, Nat.sub(e, o))), Nat.add(x, Nat.add(o, Nat.sub(e, o))), FD.lru_nat_algebra__add_swap(o, x, Nat.sub(e, o))) : {_ == Nat.add(x, e) : Nat}
  %Equal.sym(Nat, Nat.add(o, Nat.sub(e, o)), e, FD.nat__sub_add(e, o, h)) : {Nat.add(x, _) == Nat.add(x, e) : Nat}
  {==}

# The window [o, e) of the window: (o + x) + (e - o) <= 4 2^d.
def hwj(@CW, +o: U32, +e: U32, +h1: {Nat.is_le(U32.to_nat(o), U32.to_nat(e)) == True{} : Bool}, +h2: {Nat.is_le(U32.to_nat(e), U32.to_nat(len)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(U32.to_nat(o), x), U32.to_nat(U32.sub(e, o))), A.quad(VB.pw(d))) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(U32.sub(e, o)), Nat.sub(U32.to_nat(e), U32.to_nat(o)), FD.u32__sub_nat(e, o, h1)) : {Nat.is_le(Nat.add(Nat.add(U32.to_nat(o), x), _), A.quad(VB.pw(d))) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(Nat.add(U32.to_nat(o), x), Nat.sub(U32.to_nat(e), U32.to_nat(o))), Nat.add(x, U32.to_nat(e)), alg(U32.to_nat(o), x, U32.to_nat(e), h1)) :
    {Nat.is_le(_, A.quad(VB.pw(d))) == True{} : Bool}
  FD.nat__le_trans(Nat.add(x, U32.to_nat(e)), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.add_left(x, U32.to_nat(e), U32.to_nat(len), h2), hw)

def room4(@CW, +c: Nat, +h: {Nat.is_le(Nat.add(c, 4n), U32.to_nat(len)) == True{} : Bool}) -> {Nat.is_le(Nat.add(Nat.add(c, x), 4n), A.quad(VB.pw(d))) == True{} : Bool}:
  UR.roomw(x, U32.to_nat(len), c, A.quad(VB.pw(d)), hw, h)

def rdo(@CW, +c: U32, +k: Nat, +ec: {U32.to_nat(c) == k : Nat}, +h: {Nat.is_le(Nat.add(k, 4n), U32.to_nat(len)) == True{} : Bool})
    -> {B.read32(BF(t, n), U32.add(off, c)) == (BF(t, n), UR.RWN(t, Nat.add(k, x))) : B.Buf & U32}:
  +hk = FD.nat__le_trans(k, Nat.add(k, 4n), U32.to_nat(len), Order.below_sum(k, 4n), h)
  +eoc = eoj(@CWA, c, FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(len)) == True{} : Bool}, k, U32.to_nat(c), Equal.sym(Nat, U32.to_nat(c), k, ec), hk))
  UR.rwx(d, t, n, U32.add(off, c), Nat.add(k, x), FD.logic__subst(Nat, z => {U32.to_nat(U32.add(off, c)) == Nat.add(z, x) : Nat}, U32.to_nat(c), k, ec, eoc),
    FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf, room4(@CWA, k, h))

# ---- the validator ----------------------------------------------------------------------------

def c3_id(+ok: Bool, buf: B.Buf, +off: U32, +len: U32, +o0: U32, +o1: U32) -> {T.@AS_c3(ok, buf, off, len, o0, o1) == (buf, ok) : B.Buf & Bool}:
  match ok:
    case True{}: {==}
    case False{}: {==}

def okc2(@CW, +h01: {Nat.is_le(U32.to_nat(O0(t, x)), U32.to_nat(O1(t, x))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool},
    +dd: Bool, +ed: {D0(t, x, off) == dd : Bool})
    -> {T.@AS_c2(dd, BF(t, n), off, len, O0(t, x), O1(t, x)) == (BF(t, n), ck(dd, D1(t, x, off, len))) : B.Buf & Bool}:
  match dd:
    case False{}: {==}
    case True{}:
      %Equal.sym(B.Buf & Bool, T.@C_ok(BF(t, n), W1(t, x, off), L1(t, x, len)), (BF(t, n), D1(t, x, off, len)),
          CH.ok_evalw(d, t, n, J1(t, x), W1(t, x, off), L1(t, x, len), eoj(@CWA, O1(t, x), h1n), hd, hwj(@CWA, O1(t, x), len, h1n, FD.nat__le_refl(U32.to_nat(len))), pf)) :
        {T.@AS_v3(off, len, O0(t, x), O1(t, x), _) == (BF(t, n), D1(t, x, off, len)) : B.Buf & Bool}
      c3_id(D1(t, x, off, len), BF(t, n), off, len, O0(t, x), O1(t, x))

def okc1(@CW, +c: Bool, +ec: {RR(t, x, len) == c : Bool})
    -> {T.@AS_c1(c, BF(t, n), off, len, O0(t, x), O1(t, x)) == (BF(t, n), ck(c, ck(D0(t, x, off), D1(t, x, off, len)))) : B.Buf & Bool}:
  match c:
    case False{}: {==}
    case True{}:
      +h01 = le_nat(O0(t, x), O1(t, x), FD.logic__and_left(U32.is_le(O0(t, x), O1(t, x)), U32.is_le(O1(t, x), len), ec))
      +h1n = le_nat(O1(t, x), len, FD.logic__and_right(U32.is_le(O0(t, x), O1(t, x)), U32.is_le(O1(t, x), len), ec))
      %Equal.sym(B.Buf & Bool, T.@C_ok(BF(t, n), W0(t, x, off), L0(t, x)), (BF(t, n), D0(t, x, off)),
          CH.ok_evalw(d, t, n, J0(t, x), W0(t, x, off), L0(t, x), eoj(@CWA, O0(t, x), FD.nat__le_trans(U32.to_nat(O0(t, x)), U32.to_nat(O1(t, x)), U32.to_nat(len), h01, h1n)), hd,
            hwj(@CWA, O0(t, x), O1(t, x), h01, h1n), pf)) :
        {T.@AS_v2(off, len, O0(t, x), O1(t, x), _) == (BF(t, n), ck(True{}, ck(D0(t, x, off), D1(t, x, off, len)))) : B.Buf & Bool}
      okc2(@CWA, h01, h1n, D0(t, x, off), {==})

def okc0(@CW, +h8: {Nat.is_le(8n, U32.to_nat(len)) == True{} : Bool}, +b: Bool, +eb: {U32.is_eq(O0(t, x), 8) == b : Bool})
    -> {T.@AS_c0(b, BF(t, n), off, len, O0(t, x)) == (BF(t, n), ck(b, ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len))))) : B.Buf & Bool}:
  match b:
    case False{}: {==}
    case True{}:
      %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, 4)), (BF(t, n), O1(t, x)), rdo(@CWA, 4, 4n, {==}, h8)) :
        {T.@AS_v1(off, len, O0(t, x), _) == (BF(t, n), ck(True{}, ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len))))) : B.Buf & Bool}
      okc1(@CWA, RR(t, x, len), {==})

def okl(@CW, +a: Bool, +ea: {U32.is_le(8, len) == a : Bool})
    -> {T.@AS_ok_len(a, BF(t, n), off, len) == (BF(t, n), ck(a, ck(U32.is_eq(O0(t, x), 8), ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len)))))) : B.Buf & Bool}:
  match a:
    case False{}: {==}
    case True{}:
      +h8 = le_nat(8, len, ea)
      %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, 0)), (BF(t, n), O0(t, x)), rdo(@CWA, 0, 0n, {==}, FD.nat__le_trans(4n, 8n, U32.to_nat(len), {==}, h8))) :
        {T.@AS_v0(off, len, _) == (BF(t, n), ck(True{}, ck(U32.is_eq(O0(t, x), 8), ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len)))))) : B.Buf & Bool}
      okc0(@CWA, h8, U32.is_eq(O0(t, x), 8), {==})

# The validator on the window returns the buffer and CHKw.
def ok_evalw(@CW) -> {T.@AS_ok(BF(t, n), off, len) == (BF(t, n), CHKw(t, x, off, len)) : B.Buf & Bool}:
  okl(@CWA, U32.is_le(8, len), {==})

# ---- the reader ---------------------------------------------------------------------------------

def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> T.@AS:
  T.@AS{O.BSome{CH.OBJw(d, t, J0(t, x), W0(t, x, off), L0(t, x)), O.BNone{}}, O.BSome{CH.OBJw(d, t, J1(t, x), W1(t, x, off), L1(t, x, len)), O.BNone{}}}

def rd_go(@CW, +h8: {Nat.is_le(8n, U32.to_nat(len)) == True{} : Bool},
    +h01: {Nat.is_le(U32.to_nat(O0(t, x)), U32.to_nat(O1(t, x))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool},
    +hk0: {D0(t, x, off) == True{} : Bool}, +hk1: {D1(t, x, off, len) == True{} : Bool})
    -> {T.@AS_read(BF(t, n), off, len) == (BF(t, n), OBJw(d, t, x, off, len)) : B.Buf & T.@AS}:
  %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, 0)), (BF(t, n), O0(t, x)), rdo(@CWA, 0, 0n, {==}, FD.nat__le_trans(4n, 8n, U32.to_nat(len), {==}, h8))) :
    {T.@AS_rd0(off, len, _) == (BF(t, n), OBJw(d, t, x, off, len)) : B.Buf & T.@AS}
  %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, 4)), (BF(t, n), O1(t, x)), rdo(@CWA, 4, 4n, {==}, h8)) :
    {T.@AS_rd1(off, len, O0(t, x), _) == (BF(t, n), OBJw(d, t, x, off, len)) : B.Buf & T.@AS}
  %Equal.sym(B.Buf & T.@C, T.@C_read(BF(t, n), W0(t, x, off), L0(t, x)), (BF(t, n), CH.OBJw(d, t, J0(t, x), W0(t, x, off), L0(t, x))),
      CH.readw(d, t, n, J0(t, x), W0(t, x, off), L0(t, x), eoj(@CWA, O0(t, x), FD.nat__le_trans(U32.to_nat(O0(t, x)), U32.to_nat(O1(t, x)), U32.to_nat(len), h01, h1n)), hd,
        hwj(@CWA, O0(t, x), O1(t, x), h01, h1n), pf, hk0)) :
    {T.@AS_rd2(off, len, O0(t, x), O1(t, x), T.@C_bx_rd(_)) == (BF(t, n), OBJw(d, t, x, off, len)) : B.Buf & T.@AS}
  %Equal.sym(B.Buf & T.@C, T.@C_read(BF(t, n), W1(t, x, off), L1(t, x, len)), (BF(t, n), CH.OBJw(d, t, J1(t, x), W1(t, x, off), L1(t, x, len))),
      CH.readw(d, t, n, J1(t, x), W1(t, x, off), L1(t, x, len), eoj(@CWA, O1(t, x), h1n), hd, hwj(@CWA, O1(t, x), len, h1n, FD.nat__le_refl(U32.to_nat(len))), pf, hk1)) :
    {T.@AS_rd3(off, len, O0(t, x), O1(t, x), O.BSome{CH.OBJw(d, t, J0(t, x), W0(t, x, off), L0(t, x)), O.BNone{}}, T.@C_bx_rd(_)) == (BF(t, n), OBJw(d, t, x, off, len)) : B.Buf & T.@AS}
  {==}

# The reader on the window, when the checks hold.
def readw(@CW, +hchk: {CHKw(t, x, off, len) == True{} : Bool}) -> {T.@AS_read(BF(t, n), off, len) == (BF(t, n), OBJw(d, t, x, off, len)) : B.Buf & T.@AS}:
  +r1 = ck(U32.is_eq(O0(t, x), 8), ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len))))
  +r2 = ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len)))
  +r3 = ck(D0(t, x, off), D1(t, x, off, len))
  +h1 = ck_b(U32.is_le(8, len), r1, hchk)
  +h2 = ck_b(U32.is_eq(O0(t, x), 8), r2, h1)
  +h3 = ck_b(RR(t, x, len), r3, h2)
  +hr = ck_a(RR(t, x, len), r3, h2)
  rd_go(@CWA, le_nat(8, len, ck_a(U32.is_le(8, len), r1, hchk)),
    le_nat(O0(t, x), O1(t, x), FD.logic__and_left(U32.is_le(O0(t, x), O1(t, x)), U32.is_le(O1(t, x), len), hr)),
    le_nat(O1(t, x), len, FD.logic__and_right(U32.is_le(O0(t, x), O1(t, x)), U32.is_le(O1(t, x), len), hr)),
    ck_a(D0(t, x, off), D1(t, x, off, len), h3), ck_b(D0(t, x, off), D1(t, x, off, len), h3))

# ---- the spec side ------------------------------------------------------------------------------

def VALw(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value:
  S.Sequence{S.Items{CH.VALw(t, J0(t, x), L0(t, x)), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}}

def A0(+t: FD.array__Tree<U32>, +x: Nat) -> U32: U32.sub(O1(t, x), 8)
def Y0(+t: FD.array__Tree<U32>, +x: Nat) -> +List<U32>: UW.WX(t, 8n+x, U32.to_nat(A0(t, x)))
def Y1(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> +List<U32>: UW.WX(t, J1(t, x), U32.to_nat(L1(t, x, len)))
def PL(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> +List<S.Part>: [S.Variable{Y0(t, x)}, S.Variable{Y1(t, x, len)}]
def LS(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> +List<U32>:
  List.append(&2, U32, Layout.fixed_parts(PL(t, x, len), 8n), Layout.payloads(PL(t, x, len)))

# O1 = 8 + (O1 - 8)
def eO1(+t: FD.array__Tree<U32>, +x: Nat, +h81: {Nat.is_le(8n, U32.to_nat(O1(t, x))) == True{} : Bool})
    -> {U32.to_nat(O1(t, x)) == Nat.add(8n, U32.to_nat(A0(t, x))) : Nat}:
  %Equal.sym(Nat, U32.to_nat(A0(t, x)), Nat.sub(U32.to_nat(O1(t, x)), 8n), FD.u32__sub_nat(O1(t, x), 8, h81)) : {U32.to_nat(O1(t, x)) == Nat.add(8n, _) : Nat}
  Equal.sym(Nat, Nat.add(8n, Nat.sub(U32.to_nat(O1(t, x)), 8n)), U32.to_nat(O1(t, x)), FD.nat__sub_add(U32.to_nat(O1(t, x)), 8n, h81))

# len = 8 + ((O1 - 8) + (len - O1))
def elen(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +h81: {Nat.is_le(8n, U32.to_nat(O1(t, x))) == True{} : Bool},
    +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool})
    -> {U32.to_nat(len) == Nat.add(8n, Nat.add(U32.to_nat(A0(t, x)), U32.to_nat(L1(t, x, len)))) : Nat}:
  %FD.nat__add_assoc(8n, U32.to_nat(A0(t, x)), U32.to_nat(L1(t, x, len))) : {U32.to_nat(len) == _ : Nat}
  %Equal.sym(Nat, Nat.add(8n, U32.to_nat(A0(t, x))), U32.to_nat(O1(t, x)), Equal.sym(Nat, U32.to_nat(O1(t, x)), Nat.add(8n, U32.to_nat(A0(t, x))), eO1(t, x, h81))) :
    {U32.to_nat(len) == Nat.add(_, U32.to_nat(L1(t, x, len))) : Nat}
  %Equal.sym(Nat, U32.to_nat(L1(t, x, len)), Nat.sub(U32.to_nat(len), U32.to_nat(O1(t, x))), FD.u32__sub_nat(len, O1(t, x), h1n)) :
    {U32.to_nat(len) == Nat.add(U32.to_nat(O1(t, x)), _) : Nat}
  Equal.sym(Nat, Nat.add(U32.to_nat(O1(t, x)), Nat.sub(U32.to_nat(len), U32.to_nat(O1(t, x)))), U32.to_nat(len), FD.nat__sub_add(U32.to_nat(len), U32.to_nat(O1(t, x)), h1n))

# The second window starts right after the first.
def eJ1(+t: FD.array__Tree<U32>, +x: Nat, +h81: {Nat.is_le(8n, U32.to_nat(O1(t, x))) == True{} : Bool})
    -> {Nat.add(U32.to_nat(A0(t, x)), 8n+x) == J1(t, x) : Nat}:
  %Equal.sym(Nat, Nat.add(U32.to_nat(A0(t, x)), 8n+x), Nat.add(8n, Nat.add(U32.to_nat(A0(t, x)), x)), FD.lru_nat_algebra__add_swap(U32.to_nat(A0(t, x)), 8n, x)) : {_ == J1(t, x) : Nat}
  %Equal.sym(Nat, U32.to_nat(O1(t, x)), Nat.add(8n, U32.to_nat(A0(t, x))), eO1(t, x, h81)) : {Nat.add(8n, Nat.add(U32.to_nat(A0(t, x)), x)) == Nat.add(_, x) : Nat}
  {==}

def hw8(@CW, +h81: {Nat.is_le(8n, U32.to_nat(O1(t, x))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(8n+x, U32.to_nat(A0(t, x))), A.quad(VB.pw(d))) == True{} : Bool}:
  hwj(@CWA, 8, O1(t, x), h81, h1n)

# The spec encoding of the two windows is the window.
def enc8(@CW, +h81: {Nat.is_le(8n, U32.to_nat(O1(t, x))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool},
    +e0: {O0(t, x) == 8 : U32})
    -> {LS(t, x, len) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>}:
  +a0 = U32.to_nat(A0(t, x))
  +a1 = U32.to_nat(L1(t, x, len))
  +el = elen(t, x, len, h81, h1n)
  +hw2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, z), A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(len), Nat.add(8n, Nat.add(a0, a1)), el, hw)
  %Equal.sym(Nat, U32.to_nat(len), Nat.add(8n, Nat.add(a0, a1)), el) : {LS(t, x, len) == UW.WX(t, x, _) : +List<U32>}
  %Equal.sym(+List<U32>, UW.WX(t, x, Nat.add(A.quad(2n), Nat.add(a0, a1))), List.append(&2, U32, F.limbs(UR.RWS(2n, t, x)), UW.WX(t, Nat.add(A.quad(2n), x), Nat.add(a0, a1))),
      UW.headWX(d, t, x, 2n, Nat.add(a0, a1), pf, hw2)) :
    {LS(t, x, len) == _ : +List<U32>}
  %Equal.sym(+List<U32>, UW.WX(t, 8n+x, Nat.add(a0, a1)), List.append(&2, U32, Y0(t, x), UW.WX(t, Nat.add(a0, 8n+x), a1)), UW.splitWX(t, 8n+x, a0, a1)) :
    {LS(t, x, len) == List.append(&2, U32, F.limbs(UR.RWS(2n, t, x)), _) : +List<U32>}
  %Equal.sym(Nat, Nat.add(a0, 8n+x), J1(t, x), eJ1(t, x, h81)) :
    {LS(t, x, len) == List.append(&2, U32, F.limbs(UR.RWS(2n, t, x)), List.append(&2, U32, Y0(t, x), UW.WX(t, _, a1))) : +List<U32>}
  %Equal.sym(U32, O0(t, x), 8, e0) :
    {LS(t, x, len) == List.append(&2, U32, F.limbs([_, O1(t, x)]), List.append(&2, U32, Y0(t, x), Y1(t, x, len))) : +List<U32>}
  %VG.digits_limb(O1(t, x)) :
    {LS(t, x, len) == List.append(&2, U32, List.append(&2, U32, I.limb(8), List.append(&2, U32, _, [])), List.append(&2, U32, Y0(t, x), Y1(t, x, len))) : +List<U32>}
  %Equal.sym(Nat, U32.to_nat(O1(t, x)), Nat.add(8n, a0), eO1(t, x, h81)) :
    {LS(t, x, len) == List.append(&2, U32, List.append(&2, U32, I.limb(8), List.append(&2, U32, N.digits(4n, _), [])), List.append(&2, U32, Y0(t, x), Y1(t, x, len))) : +List<U32>}
  %Equal.sym(Nat, List.length(&2, U32, Y0(t, x)), a0, UW.lenWX(d, t, 8n+x, a0, pf, hw8(@CWA, h81, h1n))) :
    {List.append(&2, U32, List.append(&2, U32, N.digits(4n, 8n), List.append(&2, U32, N.digits(4n, Nat.add(8n, _)), [])), List.append(&2, U32, Y0(t, x), List.append(&2, U32, Y1(t, x, len), []))) ==
      List.append(&2, U32, List.append(&2, U32, I.limb(8), List.append(&2, U32, N.digits(4n, Nat.add(8n, a0)), [])), List.append(&2, U32, Y0(t, x), Y1(t, x, len))) : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, Y1(t, x, len), []), Y1(t, x, len), VS.app_nil(Y1(t, x, len))) :
    {List.append(&2, U32, List.append(&2, U32, N.digits(4n, 8n), List.append(&2, U32, N.digits(4n, Nat.add(8n, a0)), [])), List.append(&2, U32, Y0(t, x), _)) ==
      List.append(&2, U32, List.append(&2, U32, I.limb(8), List.append(&2, U32, N.digits(4n, Nat.add(8n, a0)), [])), List.append(&2, U32, Y0(t, x), Y1(t, x, len))) : +List<U32>}
  {==}

# The payloads' length.
def lpay(@CW, +h81: {Nat.is_le(8n, U32.to_nat(O1(t, x))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool})
    -> {U32.to_nat(len) == Nat.add(8n, List.length(&2, U32, Layout.payloads(PL(t, x, len)))) : Nat}:
  +a0 = U32.to_nat(A0(t, x))
  +a1 = U32.to_nat(L1(t, x, len))
  +hw1 = hwj(@CWA, O1(t, x), len, h1n, FD.nat__le_refl(U32.to_nat(len)))
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, Y0(t, x), List.append(&2, U32, Y1(t, x, len), []))), Nat.add(List.length(&2, U32, Y0(t, x)), List.length(&2, U32, List.append(&2, U32, Y1(t, x, len), []))),
      VS.len_app(Y0(t, x), List.append(&2, U32, Y1(t, x, len), []))) : {U32.to_nat(len) == Nat.add(8n, _) : Nat}
  %Equal.sym(+List<U32>, List.append(&2, U32, Y1(t, x, len), []), Y1(t, x, len), VS.app_nil(Y1(t, x, len))) : {U32.to_nat(len) == Nat.add(8n, Nat.add(List.length(&2, U32, Y0(t, x)), List.length(&2, U32, _))) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, Y0(t, x)), a0, UW.lenWX(d, t, 8n+x, a0, pf, hw8(@CWA, h81, h1n))) : {U32.to_nat(len) == Nat.add(8n, Nat.add(_, List.length(&2, U32, Y1(t, x, len)))) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, Y1(t, x, len)), a1, UW.lenWX(d, t, J1(t, x), a1, pf, hw1)) : {U32.to_nat(len) == Nat.add(8n, Nat.add(a0, _)) : Nat}
  elen(t, x, len, h81, h1n)

# Definitions per step: a container's parts one step down and one field before the rest, over opaque values
# (a conversion that is not a syntactic match would evaluate the fields' parts).
def gcv_(+v: S.Value, +vs: S.Value, +s: S.Schema, +rs: S.Schema, +y: +List<U32>, +rest: +List<S.Part>,
    +ea: {Codec.parts(v, s) == Some{[S.Variable{y}]} : Maybe<&2, +List<S.Part>>}, +eb: {Codec.parts(vs, rs) == Some{rest} : Maybe<&2, +List<S.Part>>})
    -> {Codec.parts(S.Items{v, vs}, S.Chain{s, rs}) == Some{S.Variable{y} <> rest} : Maybe<&2, +List<S.Part>>}:
  VS.cat_var(Codec.parts(v, s), y, Codec.parts(vs, rs), rest, ea, eb)

def gcf_(+v: S.Value, +vs: S.Value, +s: S.Schema, +rs: S.Schema, +xs: +List<U32>, +rest: +List<S.Part>,
    +ea: {Codec.parts(v, s) == Some{[S.Fixed{xs}]} : Maybe<&2, +List<S.Part>>}, +eb: {Codec.parts(vs, rs) == Some{rest} : Maybe<&2, +List<S.Part>>})
    -> {Codec.parts(S.Items{v, vs}, S.Chain{s, rs}) == Some{S.Fixed{xs} <> rest} : Maybe<&2, +List<S.Part>>}:
  F.cat_fixed(Codec.parts(v, s), xs, Codec.parts(vs, rs), rest, ea, eb)

def vw0(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> {S.Sequence{S.Items{CH.VALw(t, J0(t, x), L0(t, x)), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}} == VALw(t, x, len) : S.Value}:
  {==}

def j0e(+t: FD.array__Tree<U32>, +x: Nat) -> {Nat.add(U32.to_nat(O0(t, x)), x) == J0(t, x) : Nat}:
  {==}

def l0e(+t: FD.array__Tree<U32>, +x: Nat) -> {U32.sub(O1(t, x), O0(t, x)) == L0(t, x) : U32}:
  {==}

def e8x(+x: Nat) -> {8n+x == Nat.add(U32.to_nat(8), x) : Nat}:
  {==}

def a0e(+t: FD.array__Tree<U32>, +x: Nat) -> {A0(t, x) == U32.sub(O1(t, x), 8) : U32}:
  {==}

def lct2(+it: S.Value) -> {Codec.aggregate(Codec.parts(it, S.Chain{@SC, S.Chain{@SC, S.End{}}}), None{}) == Codec.parts(S.Sequence{it}, Spec.@AS()) : Maybe<&2, +List<S.Part>>}:
  {==}

def specg8(@CW, +h81: {Nat.is_le(8n, U32.to_nat(O1(t, x))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool},
    +e0: {O0(t, x) == 8 : U32}, +hk0: {CH.CHKw(t, 8n+x, U32.add(off, 8), A0(t, x)) == True{} : Bool}, +hk1: {D1(t, x, off, len) == True{} : Bool})
    -> {Codec.parts(S.Sequence{S.Items{CH.VALw(t, 8n+x, A0(t, x)), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}}, Spec.@AS()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}:
  +c0 = CH.specw(d, t, n, 8n+x, U32.add(off, 8), A0(t, x), eoj(@CWA, 8, FD.nat__le_trans(8n, U32.to_nat(O1(t, x)), U32.to_nat(len), h81, h1n)), hd, hw8(@CWA, h81, h1n), pf, hk0)
  +c1 = CH.specw(d, t, n, J1(t, x), W1(t, x, off), L1(t, x, len), eoj(@CWA, O1(t, x), h1n), hd, hwj(@CWA, O1(t, x), len, h1n, FD.nat__le_refl(U32.to_nat(len))), pf, hk1)
  +hf = FD.logic__subst(Nat, z => {N.fits(4n, z) == True{} : Bool}, U32.to_nat(len), Nat.add(8n, List.length(&2, U32, Layout.payloads(PL(t, x, len)))), lpay(@CWA, h81, h1n),
    VFT.fits4(2n+d, U32.to_nat(len), hlen(d, x, len, hw), FD.nat__lt_trans(d, 28n, 30n, hd, {==})))
  %enc8(@CWA, h81, h1n, e0) : {Codec.parts(S.Sequence{S.Items{CH.VALw(t, 8n+x, A0(t, x)), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}}, Spec.@AS()) == Some{[S.Variable{_}]} : Maybe<&2, +List<S.Part>>}
  %lct2(S.Items{CH.VALw(t, 8n+x, A0(t, x)), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}) : {_ == Some{[S.Variable{LS(t, x, len)}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(S.Items{CH.VALw(t, 8n+x, A0(t, x)), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}, S.Chain{@SC, S.Chain{@SC, S.End{}}}), Some{PL(t, x, len)},
      gcv_(CH.VALw(t, 8n+x, A0(t, x)), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}, @SC, S.Chain{@SC, S.End{}}, Y0(t, x), [S.Variable{Y1(t, x, len)}], c0,
        gcv_(CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}, @SC, S.End{}, Y1(t, x, len), [], c1, {==}))) :
    {Codec.aggregate(_, None{}) == Some{[S.Variable{LS(t, x, len)}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Bool, SP.bytes_domain(Y0(t, x)), True{}, UW.domWX(t, 8n+x, U32.to_nat(A0(t, x)))) :
    {Codec.one(SP.optional(Bool.and(Bool.and(_, Bool.and(SP.bytes_domain(Y1(t, x, len)), True{})), N.fits(4n, Nat.add(8n, List.length(&2, U32, Layout.payloads(PL(t, x, len)))))), LS(t, x, len)), None{}) == Some{[S.Variable{LS(t, x, len)}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Bool, SP.bytes_domain(Y1(t, x, len)), True{}, UW.domWX(t, J1(t, x), U32.to_nat(L1(t, x, len)))) :
    {Codec.one(SP.optional(Bool.and(Bool.and(True{}, Bool.and(_, True{})), N.fits(4n, Nat.add(8n, List.length(&2, U32, Layout.payloads(PL(t, x, len)))))), LS(t, x, len)), None{}) == Some{[S.Variable{LS(t, x, len)}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Bool, N.fits(4n, Nat.add(8n, List.length(&2, U32, Layout.payloads(PL(t, x, len))))), True{}, hf) :
    {Codec.one(SP.optional(Bool.and(True{}, _), LS(t, x, len)), None{}) == Some{[S.Variable{LS(t, x, len)}]} : Maybe<&2, +List<S.Part>>}
  {==}

def specg(@CW, +h8: {Nat.is_le(8n, U32.to_nat(len)) == True{} : Bool}, +e0: {O0(t, x) == 8 : U32},
    +h01: {Nat.is_le(U32.to_nat(O0(t, x)), U32.to_nat(O1(t, x))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool},
    +hk0: {D0(t, x, off) == True{} : Bool}, +hk1: {D1(t, x, off, len) == True{} : Bool})
    -> {Codec.parts(VALw(t, x, len), Spec.@AS()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}:
  +h81 = FD.logic__subst(U32, z => {Nat.is_le(U32.to_nat(z), U32.to_nat(O1(t, x))) == True{} : Bool}, O0(t, x), 8, e0, h01)
  +hk08 = FD.logic__subst(U32, z => {CH.CHKw(t, Nat.add(U32.to_nat(z), x), U32.add(off, z), U32.sub(O1(t, x), z)) == True{} : Bool}, O0(t, x), 8, e0, hk0)
  %vw0(t, x, len) : {Codec.parts(_, Spec.@AS()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}
  %j0e(t, x) : {Codec.parts(S.Sequence{S.Items{CH.VALw(t, _, L0(t, x)), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}}, Spec.@AS()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}
  %l0e(t, x) : {Codec.parts(S.Sequence{S.Items{CH.VALw(t, Nat.add(U32.to_nat(O0(t, x)), x), _), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}}, Spec.@AS()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(U32, O0(t, x), 8, e0) :
    {Codec.parts(S.Sequence{S.Items{CH.VALw(t, Nat.add(U32.to_nat(_), x), U32.sub(O1(t, x), _)), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}}, Spec.@AS()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}
  %e8x(x) : {Codec.parts(S.Sequence{S.Items{CH.VALw(t, _, U32.sub(O1(t, x), 8)), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}}, Spec.@AS()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}
  %a0e(t, x) : {Codec.parts(S.Sequence{S.Items{CH.VALw(t, 8n+x, _), S.Items{CH.VALw(t, J1(t, x), L1(t, x, len)), S.EmptyItems{}}}}, Spec.@AS()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}
  specg8(@CWA, h81, h1n, e0, hk08, hk1)

# The spec parts of the value: one variable part, the window's bytes.
def specw(@CW, +hchk: {CHKw(t, x, off, len) == True{} : Bool}) -> {Codec.parts(VALw(t, x, len), Spec.@AS()) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}:
  +r1 = ck(U32.is_eq(O0(t, x), 8), ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len))))
  +r2 = ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len)))
  +r3 = ck(D0(t, x, off), D1(t, x, off, len))
  +h1 = ck_b(U32.is_le(8, len), r1, hchk)
  +h2 = ck_b(U32.is_eq(O0(t, x), 8), r2, h1)
  +h3 = ck_b(RR(t, x, len), r3, h2)
  +hr = ck_a(RR(t, x, len), r3, h2)
  specg(@CWA, le_nat(8, len, ck_a(U32.is_le(8, len), r1, hchk)), FD.u32alg__eq_of(O0(t, x), 8, ck_a(U32.is_eq(O0(t, x), 8), r2, h1)),
    le_nat(O0(t, x), O1(t, x), FD.logic__and_left(U32.is_le(O0(t, x), O1(t, x)), U32.is_le(O1(t, x), len), hr)),
    le_nat(O1(t, x), len, FD.logic__and_right(U32.is_le(O0(t, x), O1(t, x)), U32.is_le(O1(t, x), len), hr)),
    ck_a(D0(t, x, off), D1(t, x, off, len), h3), ck_b(D0(t, x, off), D1(t, x, off, len), h3))

# ---- every value whose spec parts are the window's bytes passes the checks ------------------------

def OUT2(+y0: +List<U32>, +y1: +List<U32>) -> +List<U32>:
  List.append(&2, U32, Layout.fixed_parts([S.Variable{y0}, S.Variable{y1}], 8n), Layout.payloads([S.Variable{y0}, S.Variable{y1}]))

def lOUT(+y0: +List<U32>, +y1: +List<U32>)
    -> {List.length(&2, U32, OUT2(y0, y1)) == Nat.add(8n, Nat.add(List.length(&2, U32, y0), List.length(&2, U32, y1))) : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, y0, List.append(&2, U32, y1, []))), Nat.add(List.length(&2, U32, y0), List.length(&2, U32, List.append(&2, U32, y1, []))), VS.len_app(y0, List.append(&2, U32, y1, []))) :
    {Nat.add(8n, _) == Nat.add(8n, Nat.add(List.length(&2, U32, y0), List.length(&2, U32, y1))) : Nat}
  %Equal.sym(+List<U32>, List.append(&2, U32, y1, []), y1, VS.app_nil(y1)) : {Nat.add(8n, Nat.add(List.length(&2, U32, y0), List.length(&2, U32, _))) == Nat.add(8n, Nat.add(List.length(&2, U32, y0), List.length(&2, U32, y1))) : Nat}
  {==}

def chk_all(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +h8: {Nat.is_le(8n, U32.to_nat(len)) == True{} : Bool}, +e0: {O0(t, x) == 8 : U32},
    +h01: {Nat.is_le(U32.to_nat(O0(t, x)), U32.to_nat(O1(t, x))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool},
    +hk0: {D0(t, x, off) == True{} : Bool}, +hk1: {D1(t, x, off, len) == True{} : Bool}) -> {CHKw(t, x, off, len) == True{} : Bool}:
  %Equal.sym(Bool, U32.is_le(8, len), True{}, u32le(8, len, h8)) :
    {ck(_, ck(U32.is_eq(O0(t, x), 8), ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len))))) == True{} : Bool}
  %Equal.sym(Bool, U32.is_eq(O0(t, x), 8), True{}, FD.u32alg__eq_true(O0(t, x), 8, e0)) :
    {ck(True{}, ck(_, ck(RR(t, x, len), ck(D0(t, x, off), D1(t, x, off, len))))) == True{} : Bool}
  %Equal.sym(Bool, U32.is_le(O0(t, x), O1(t, x)), True{}, u32le(O0(t, x), O1(t, x), h01)) :
    {ck(True{}, ck(True{}, ck(Bool.and(_, U32.is_le(O1(t, x), len)), ck(D0(t, x, off), D1(t, x, off, len))))) == True{} : Bool}
  %Equal.sym(Bool, U32.is_le(O1(t, x), len), True{}, u32le(O1(t, x), len, h1n)) :
    {ck(True{}, ck(True{}, ck(Bool.and(True{}, _), ck(D0(t, x, off), D1(t, x, off, len))))) == True{} : Bool}
  %Equal.sym(Bool, D0(t, x, off), True{}, hk0) : {ck(True{}, ck(True{}, ck(True{}, ck(_, D1(t, x, off, len))))) == True{} : Bool}
  hk1

def cn_en(@CW, +y0: +List<U32>, +y1: +List<U32>, +eq: {OUT2(y0, y1) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>})
    -> {U32.to_nat(len) == Nat.add(8n, Nat.add(List.length(&2, U32, y0), List.length(&2, U32, y1))) : Nat}:
  Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), Nat.add(8n, Nat.add(List.length(&2, U32, y0), List.length(&2, U32, y1))),
    Equal.sym(Nat, List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)),
    Equal.trans(Nat, List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), List.length(&2, U32, OUT2(y0, y1)), Nat.add(8n, Nat.add(List.length(&2, U32, y0), List.length(&2, U32, y1))),
      Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), UW.WX(t, x, U32.to_nat(len)), OUT2(y0, y1), Equal.sym(+List<U32>, OUT2(y0, y1), UW.WX(t, x, U32.to_nat(len)), eq)), lOUT(y0, y1)))

def cn_w4(+y0: +List<U32>, +y1: +List<U32>) -> {VS.bt(4n, OUT2(y0, y1)) == [8, 0, 0, 0] : +List<U32>}:
  {==}

def cn_d1(+y0: +List<U32>, +y1: +List<U32>) -> {VS.bt(4n, VS.bdr(4n, OUT2(y0, y1))) == N.digits(4n, Nat.add(8n, List.length(&2, U32, y0))) : +List<U32>}:
  {==}

def cn_p8(+y0: +List<U32>, +y1: +List<U32>) -> {VS.bdr(8n, OUT2(y0, y1)) == List.append(&2, U32, y0, List.append(&2, U32, y1, [])) : +List<U32>}:
  {==}

def cn_b0(@CW, +y0: +List<U32>, +y1: +List<U32>, +eq: {OUT2(y0, y1) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>},
    +h8: {Nat.is_le(8n, U32.to_nat(len)) == True{} : Bool}) -> {F.limbs([O0(t, x)]) == [8, 0, 0, 0] : +List<U32>}:
  +hP = FD.nat__le_trans(Nat.add(x, 8n), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.add_left(x, 8n, U32.to_nat(len), h8), hw)
  Equal.trans(+List<U32>, F.limbs([O0(t, x)]), UW.WX(t, x, 4n), [8, 0, 0, 0],
    UR.rwn_bytes(d, t, x, pf, FD.nat__le_trans(Nat.add(x, 4n), Nat.add(x, 8n), A.quad(VB.pw(d)), Order.add_left(x, 4n, 8n, {==}), hP)),
    Equal.trans(+List<U32>, UW.WX(t, x, 4n), VS.bt(4n, UW.WX(t, x, U32.to_nat(len))), [8, 0, 0, 0],
      Equal.sym(+List<U32>, VS.bt(4n, UW.WX(t, x, U32.to_nat(len))), UW.WX(t, x, 4n), UW.btWX(t, x, 4n, U32.to_nat(len), FD.nat__le_trans(4n, 8n, U32.to_nat(len), {==}, h8))),
      Equal.trans(+List<U32>, VS.bt(4n, UW.WX(t, x, U32.to_nat(len))), VS.bt(4n, OUT2(y0, y1)), [8, 0, 0, 0],
        Equal.cong(+List<U32>, +List<U32>, z => VS.bt(4n, z), UW.WX(t, x, U32.to_nat(len)), OUT2(y0, y1), Equal.sym(+List<U32>, OUT2(y0, y1), UW.WX(t, x, U32.to_nat(len)), eq)),
        cn_w4(y0, y1))))

def cn_b1(@CW, +y0: +List<U32>, +y1: +List<U32>, +eq: {OUT2(y0, y1) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>},
    +h8: {Nat.is_le(8n, U32.to_nat(len)) == True{} : Bool}) -> {I.limb(O1(t, x)) == N.digits(4n, Nat.add(8n, List.length(&2, U32, y0))) : +List<U32>}:
  +D = N.digits(4n, Nat.add(8n, List.length(&2, U32, y0)))
  Equal.trans(+List<U32>, I.limb(O1(t, x)), F.limbs([O1(t, x)]), D, Equal.sym(+List<U32>, F.limbs([O1(t, x)]), I.limb(O1(t, x)), VS.app_nil(I.limb(O1(t, x)))),
    Equal.trans(+List<U32>, F.limbs([O1(t, x)]), UW.WX(t, 4n+x, 4n), D,
      UR.rwn_bytes(d, t, 4n+x, pf, UR.roomw(x, U32.to_nat(len), 4n, A.quad(VB.pw(d)), hw, h8)),
      Equal.trans(+List<U32>, UW.WX(t, 4n+x, 4n), VS.bt(4n, VS.bdr(4n, UW.WX(t, x, U32.to_nat(len)))), D,
        Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(4n, UW.WX(t, x, U32.to_nat(len)))), UW.WX(t, 4n+x, 4n), UW.subWX(t, x, 4n, 4n, U32.to_nat(len), h8)),
        Equal.trans(+List<U32>, VS.bt(4n, VS.bdr(4n, UW.WX(t, x, U32.to_nat(len)))), VS.bt(4n, VS.bdr(4n, OUT2(y0, y1))), D,
          Equal.cong(+List<U32>, +List<U32>, z => VS.bt(4n, VS.bdr(4n, z)), UW.WX(t, x, U32.to_nat(len)), OUT2(y0, y1), Equal.sym(+List<U32>, OUT2(y0, y1), UW.WX(t, x, U32.to_nat(len)), eq)),
          cn_d1(y0, y1)))))

def cn_ey0(@CW, +y0: +List<U32>, +y1: +List<U32>, +eq: {OUT2(y0, y1) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>},
    +le8y0: {Nat.is_le(Nat.add(8n, List.length(&2, U32, y0)), U32.to_nat(len)) == True{} : Bool})
    -> {y0 == UW.WX(t, 8n+x, List.length(&2, U32, y0)) : +List<U32>}:
  +ly0 = List.length(&2, U32, y0)
  Equal.trans(+List<U32>, y0, VS.bt(ly0, VS.bdr(8n, OUT2(y0, y1))), UW.WX(t, 8n+x, ly0),
    Equal.sym(+List<U32>, VS.bt(ly0, VS.bdr(8n, OUT2(y0, y1))), y0,
      Equal.trans(+List<U32>, VS.bt(ly0, VS.bdr(8n, OUT2(y0, y1))), VS.bt(ly0, List.append(&2, U32, y0, List.append(&2, U32, y1, []))), y0,
        Equal.cong(+List<U32>, +List<U32>, z => VS.bt(ly0, z), VS.bdr(8n, OUT2(y0, y1)), List.append(&2, U32, y0, List.append(&2, U32, y1, [])), cn_p8(y0, y1)),
        Equal.trans(+List<U32>, VS.bt(ly0, List.append(&2, U32, y0, List.append(&2, U32, y1, []))), VS.bt(ly0, y0), y0,
          VN.bt_app(ly0, y0, List.append(&2, U32, y1, []), FD.nat__le_refl(ly0)), UW.bt_self(y0)))),
    Equal.trans(+List<U32>, VS.bt(ly0, VS.bdr(8n, OUT2(y0, y1))), VS.bt(ly0, VS.bdr(8n, UW.WX(t, x, U32.to_nat(len)))), UW.WX(t, 8n+x, ly0),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bt(ly0, VS.bdr(8n, z)), OUT2(y0, y1), UW.WX(t, x, U32.to_nat(len)), eq), UW.subWX(t, x, 8n, ly0, U32.to_nat(len), le8y0)))

def cn_ey1(@CW, +y0: +List<U32>, +y1: +List<U32>, +eq: {OUT2(y0, y1) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>},
    +en2: {U32.to_nat(len) == Nat.add(Nat.add(8n, List.length(&2, U32, y0)), List.length(&2, U32, y1)) : Nat})
    -> {y1 == UW.WX(t, Nat.add(Nat.add(8n, List.length(&2, U32, y0)), x), List.length(&2, U32, y1)) : +List<U32>}:
  +ly0 = List.length(&2, U32, y0)
  +ly1 = List.length(&2, U32, y1)
  +R1 = List.append(&2, U32, y1, [])
  Equal.trans(+List<U32>, y1, VS.bdr(Nat.add(8n, ly0), OUT2(y0, y1)), UW.WX(t, Nat.add(Nat.add(8n, ly0), x), ly1),
    Equal.sym(+List<U32>, VS.bdr(Nat.add(8n, ly0), OUT2(y0, y1)), y1,
      Equal.trans(+List<U32>, VS.bdr(Nat.add(8n, ly0), OUT2(y0, y1)), VS.bdr(ly0, VS.bdr(8n, OUT2(y0, y1))), y1, VN.bdr_add(8n, ly0, OUT2(y0, y1)),
        Equal.trans(+List<U32>, VS.bdr(ly0, VS.bdr(8n, OUT2(y0, y1))), VS.bdr(ly0, List.append(&2, U32, y0, R1)), y1,
          Equal.cong(+List<U32>, +List<U32>, z => VS.bdr(ly0, z), VS.bdr(8n, OUT2(y0, y1)), List.append(&2, U32, y0, R1), cn_p8(y0, y1)),
          Equal.trans(+List<U32>, VS.bdr(ly0, List.append(&2, U32, y0, R1)), R1, y1, VS.bdr_app(y0, R1), VS.app_nil(y1))))),
    Equal.trans(+List<U32>, VS.bdr(Nat.add(8n, ly0), OUT2(y0, y1)), VS.bdr(Nat.add(8n, ly0), UW.WX(t, x, Nat.add(Nat.add(8n, ly0), ly1))), UW.WX(t, Nat.add(Nat.add(8n, ly0), x), ly1),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bdr(Nat.add(8n, ly0), z), OUT2(y0, y1), UW.WX(t, x, Nat.add(Nat.add(8n, ly0), ly1)),
        Equal.trans(+List<U32>, OUT2(y0, y1), UW.WX(t, x, U32.to_nat(len)), UW.WX(t, x, Nat.add(Nat.add(8n, ly0), ly1)), eq, Equal.cong(Nat, +List<U32>, z => UW.WX(t, x, z), U32.to_nat(len), Nat.add(Nat.add(8n, ly0), ly1), en2))),
      UW.tailWX(t, x, Nat.add(8n, ly0), ly1)))

def cn_e1(@CW, +y0: +List<U32>, +y1: +List<U32>, +eq: {OUT2(y0, y1) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>}, +le8y0: {Nat.is_le(Nat.add(8n, List.length(&2, U32, y0)), U32.to_nat(len)) == True{} : Bool})
    -> {U32.to_nat(O1(t, x)) == Nat.add(8n, List.length(&2, U32, y0)) : Nat}:
  +h8 = FD.nat__le_trans(8n, Nat.add(8n, List.length(&2, U32, y0)), U32.to_nat(len), Order.below_sum(8n, List.length(&2, U32, y0)), le8y0)
  VG.digits_word(O1(t, x), Nat.add(8n, List.length(&2, U32, y0)),
    VFT.fits4(2n+d, Nat.add(8n, List.length(&2, U32, y0)), FD.nat__le_trans(Nat.add(8n, List.length(&2, U32, y0)), U32.to_nat(len), A.quad(VB.pw(d)), le8y0, hlen(d, x, len, hw)), FD.nat__lt_trans(d, 28n, 30n, hd, {==})),
    cn_b1(@CWA, y0, y1, eq, h8))

def cn_hk0(@CW, +h0: S.Value, +y0: +List<U32>, +eh0: {Codec.parts(h0, @S) == Some{[S.Variable{y0}]} : Maybe<&2, +List<S.Part>>}, +y1: +List<U32>, +eq: {OUT2(y0, y1) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>},
    +le8y0: {Nat.is_le(Nat.add(8n, List.length(&2, U32, y0)), U32.to_nat(len)) == True{} : Bool}, +e0: {O0(t, x) == 8 : U32},
    +e1: {U32.to_nat(O1(t, x)) == Nat.add(8n, List.length(&2, U32, y0)) : Nat},
    +h81: {Nat.is_le(8n, U32.to_nat(O1(t, x))) == True{} : Bool}, +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool},
    +h01: {Nat.is_le(U32.to_nat(O0(t, x)), U32.to_nat(O1(t, x))) == True{} : Bool}) -> {D0(t, x, off) == True{} : Bool}:
  +ly0 = List.length(&2, U32, y0)
  +eL0 = Equal.trans(Nat, U32.to_nat(L0(t, x)), U32.to_nat(U32.sub(O1(t, x), 8)), ly0,
    Equal.cong(U32, Nat, z => U32.to_nat(U32.sub(O1(t, x), z)), O0(t, x), 8, e0),
    Equal.trans(Nat, U32.to_nat(U32.sub(O1(t, x), 8)), Nat.sub(U32.to_nat(O1(t, x)), 8n), ly0, FD.u32__sub_nat(O1(t, x), 8, h81),
      Equal.trans(Nat, Nat.sub(U32.to_nat(O1(t, x)), 8n), Nat.sub(Nat.add(8n, ly0), 8n), ly0, Equal.cong(Nat, Nat, z => Nat.sub(z, 8n), U32.to_nat(O1(t, x)), Nat.add(8n, ly0), e1),
        FD.nat__add_sub_cancel(8n, ly0))))
  +eJ0 = Equal.cong(U32, Nat, z => Nat.add(U32.to_nat(z), x), O0(t, x), 8, e0)
  +ew0 = Equal.trans(+List<U32>, y0, UW.WX(t, 8n+x, ly0), UW.WX(t, J0(t, x), U32.to_nat(L0(t, x))), cn_ey0(@CWA, y0, y1, eq, le8y0),
    Equal.sym(+List<U32>, UW.WX(t, J0(t, x), U32.to_nat(L0(t, x))), UW.WX(t, 8n+x, ly0),
      Equal.trans(+List<U32>, UW.WX(t, J0(t, x), U32.to_nat(L0(t, x))), UW.WX(t, 8n+x, U32.to_nat(L0(t, x))), UW.WX(t, 8n+x, ly0),
        Equal.cong(Nat, +List<U32>, z => UW.WX(t, z, U32.to_nat(L0(t, x))), J0(t, x), 8n+x, eJ0),
        Equal.cong(Nat, +List<U32>, z => UW.WX(t, 8n+x, z), U32.to_nat(L0(t, x)), ly0, eL0))))
  CH.invw(d, t, n, J0(t, x), W0(t, x, off), L0(t, x), eoj(@CWA, O0(t, x), FD.nat__le_trans(U32.to_nat(O0(t, x)), U32.to_nat(O1(t, x)), U32.to_nat(len), h01, h1n)), hd,
    hwj(@CWA, O0(t, x), O1(t, x), h01, h1n), pf, h0,
    FD.logic__subst(+List<U32>, z => {Codec.parts(h0, @S) == Some{[S.Variable{z}]} : Maybe<&2, +List<S.Part>>}, y0, UW.WX(t, J0(t, x), U32.to_nat(L0(t, x))), ew0, eh0))

def cn_hk1(@CW, +y0: +List<U32>, +h1: S.Value, +y1: +List<U32>, +eh1: {Codec.parts(h1, @S) == Some{[S.Variable{y1}]} : Maybe<&2, +List<S.Part>>}, +eq: {OUT2(y0, y1) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>},
    +en: {U32.to_nat(len) == Nat.add(8n, Nat.add(List.length(&2, U32, y0), List.length(&2, U32, y1))) : Nat},
    +e1: {U32.to_nat(O1(t, x)) == Nat.add(8n, List.length(&2, U32, y0)) : Nat},
    +h1n: {Nat.is_le(U32.to_nat(O1(t, x)), U32.to_nat(len)) == True{} : Bool}) -> {D1(t, x, off, len) == True{} : Bool}:
  +ly0 = List.length(&2, U32, y0)
  +ly1 = List.length(&2, U32, y1)
  +en2 = Equal.trans(Nat, U32.to_nat(len), Nat.add(8n, Nat.add(ly0, ly1)), Nat.add(Nat.add(8n, ly0), ly1), en, Equal.sym(Nat, Nat.add(Nat.add(8n, ly0), ly1), Nat.add(8n, Nat.add(ly0, ly1)), FD.nat__add_assoc(8n, ly0, ly1)))
  +eL1 = Equal.trans(Nat, U32.to_nat(L1(t, x, len)), Nat.sub(U32.to_nat(len), U32.to_nat(O1(t, x))), ly1, FD.u32__sub_nat(len, O1(t, x), h1n),
    Equal.trans(Nat, Nat.sub(U32.to_nat(len), U32.to_nat(O1(t, x))), Nat.sub(Nat.add(Nat.add(8n, ly0), ly1), Nat.add(8n, ly0)), ly1,
      Equal.trans(Nat, Nat.sub(U32.to_nat(len), U32.to_nat(O1(t, x))), Nat.sub(U32.to_nat(len), Nat.add(8n, ly0)), Nat.sub(Nat.add(Nat.add(8n, ly0), ly1), Nat.add(8n, ly0)),
        Equal.cong(Nat, Nat, z => Nat.sub(U32.to_nat(len), z), U32.to_nat(O1(t, x)), Nat.add(8n, ly0), e1),
        Equal.cong(Nat, Nat, z => Nat.sub(z, Nat.add(8n, ly0)), U32.to_nat(len), Nat.add(Nat.add(8n, ly0), ly1), en2)),
      FD.nat__add_sub_cancel(Nat.add(8n, ly0), ly1)))
  +ew1 = Equal.trans(+List<U32>, y1, UW.WX(t, Nat.add(Nat.add(8n, ly0), x), ly1), UW.WX(t, J1(t, x), U32.to_nat(L1(t, x, len))), cn_ey1(@CWA, y0, y1, eq, en2),
    Equal.sym(+List<U32>, UW.WX(t, J1(t, x), U32.to_nat(L1(t, x, len))), UW.WX(t, Nat.add(Nat.add(8n, ly0), x), ly1),
      Equal.trans(+List<U32>, UW.WX(t, J1(t, x), U32.to_nat(L1(t, x, len))), UW.WX(t, Nat.add(Nat.add(8n, ly0), x), U32.to_nat(L1(t, x, len))), UW.WX(t, Nat.add(Nat.add(8n, ly0), x), ly1),
        Equal.cong(Nat, +List<U32>, z => UW.WX(t, Nat.add(z, x), U32.to_nat(L1(t, x, len))), U32.to_nat(O1(t, x)), Nat.add(8n, ly0), e1),
        Equal.cong(Nat, +List<U32>, z => UW.WX(t, Nat.add(Nat.add(8n, ly0), x), z), U32.to_nat(L1(t, x, len)), ly1, eL1))))
  CH.invw(d, t, n, J1(t, x), W1(t, x, off), L1(t, x, len), eoj(@CWA, O1(t, x), h1n), hd, hwj(@CWA, O1(t, x), len, h1n, FD.nat__le_refl(U32.to_nat(len))), pf, h1,
    FD.logic__subst(+List<U32>, z => {Codec.parts(h1, @S) == Some{[S.Variable{z}]} : Maybe<&2, +List<S.Part>>}, y1, UW.WX(t, J1(t, x), U32.to_nat(L1(t, x, len))), ew1, eh1))

# The two windows' shapes make every check pass.
def contra(@CW, +h0: S.Value, +y0: +List<U32>, +eh0: {Codec.parts(h0, @S) == Some{[S.Variable{y0}]} : Maybe<&2, +List<S.Part>>},
    +h1: S.Value, +y1: +List<U32>, +eh1: {Codec.parts(h1, @S) == Some{[S.Variable{y1}]} : Maybe<&2, +List<S.Part>>}, +eq: {OUT2(y0, y1) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  +ly0 = List.length(&2, U32, y0)
  +ly1 = List.length(&2, U32, y1)
  +en = cn_en(@CWA, y0, y1, eq)
  +le8y0 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(8n, ly0), z) == True{} : Bool}, Nat.add(8n, Nat.add(ly0, ly1)), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), Nat.add(8n, Nat.add(ly0, ly1)), en),
    Order.add_left(8n, ly0, Nat.add(ly0, ly1), FD.nat__le_add_right(ly0, ly1)))
  +h8 = FD.nat__le_trans(8n, Nat.add(8n, ly0), U32.to_nat(len), Order.below_sum(8n, ly0), le8y0)
  +e0 = VN.wordc(O0(t, x), 8, cn_b0(@CWA, y0, y1, eq, h8))
  +e1 = cn_e1(@CWA, y0, y1, eq, le8y0)
  +h81 = FD.logic__subst(Nat, z => {Nat.is_le(8n, z) == True{} : Bool}, Nat.add(8n, ly0), U32.to_nat(O1(t, x)), Equal.sym(Nat, U32.to_nat(O1(t, x)), Nat.add(8n, ly0), e1), Order.below_sum(8n, ly0))
  +h1n = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(len)) == True{} : Bool}, Nat.add(8n, ly0), U32.to_nat(O1(t, x)), Equal.sym(Nat, U32.to_nat(O1(t, x)), Nat.add(8n, ly0), e1), le8y0)
  +h01 = FD.logic__subst(U32, z => {Nat.is_le(U32.to_nat(z), U32.to_nat(O1(t, x))) == True{} : Bool}, 8, O0(t, x), Equal.sym(U32, O0(t, x), 8, e0), h81)
  chk_all(t, x, off, len, h8, e0, h01, h1n, cn_hk0(@CWA, h0, y0, eh0, y1, eq, le8y0, e0, e1, h81, h1n, h01), cn_hk1(@CWA, y0, h1, y1, eh1, eq, en, e1, h1n))

@STAGES

@@ cont_text_lines @@
def OBJw(+t: FD.array__Tree<U32>, +i: Nat, +off: U32, +len: U32) -> ${Tn}: ${OBJ}

def rd_go(${CW}, ${HA}, +epo: {SPOw(t, i) == ${FS} : U32}, +hc: {${CHK_child} == True{} : Bool})
    -> {${Tn}_read(BF(t, n), off, len) == ${RHS} : ${TY}}:
  +hH = hHi(${CWA}, ha)
  %Equal.sym(B.Buf & U32, B.read32(VF.BF(t, n), U32.add(off, ${4 * po})), (VF.BF(t, n), SPOw(t, i)),
      VF.rd32a(d, t, n, U32.add(off, ${4 * po}), Nat.add(${po}n, i), eoc(${CWA}, ${po}n, ${4 * po}, {==}, {==}, ha),
        VB.lt32(d, FD.nat__lt_trans(d, 28n, 31n, hd, {==})), hiw(${CWA}, ${po}n, {==}, ha), pf)) :
    {${Tn}_rd0(off, len, _) == ${RHS} : ${TY}}
@@ cont_text_lines_2 @@
  %Equal.sym(B.Buf & ${ft.rep()}, ${read_term(f, FS)}, (BF(t, n), ${objs[j]}),
      VT.rdd_${ft.p}(d, t, n, U32.add(off, ${f['c']}), Nat.add(${k}n, i), eoc(${CWA}, ${k}n, ${f['c']}, {==}, {==}, ha), hd, pf, ${hb})) :
    {${Tn}_rd${j + 1}(${args}, _) == ${RHS} : ${TY}}
@@ inv_text_lines @@
  %Equal.sym(Nat, VRJ.lens(${PRE}), ${Pz}n, eP(${ALL})) : {Nat.add(_, 4n+VRJ.lens(${POST})) == ${FS}n : Nat}
  %Equal.sym(Nat, VRJ.lens(${POST}), ${Qz}n, eQ(${ALL})) : {Nat.add(${Pz}n, 4n+_) == ${FS}n : Nat}
  {==}

@@ inv_text_lines_2 @@
  %eP(${ALL}) : {VS.bt(4n, VS.bdr(_, ${OUT})) == N.digits(4n, Nat.add(_, 4n+${Qz}n)) : +List<U32>}
  %eQ(${ALL}) : {VS.bt(4n, VS.bdr(VRJ.lens(${PRE}), ${OUT})) == N.digits(4n, Nat.add(VRJ.lens(${PRE}), 4n+_)) : +List<U32>}
  VRJ.out_off(${PRE}, ys, ${POST})

@@ inv_text_lines_3 @@
  %fz_eq(${ALL}) : {List.length(&2, U32, ${OUT}) == Nat.add(_, List.length(&2, U32, ys)) : Nat}
  VRJ.out_len(${PRE}, ys, ${POST})

@@ inv_text_lines_4 @@
  %fz_eq(${ALL}) : {VS.bdr(_, ${OUT}) == ys : +List<U32>}
  VBC.out_tail(${PRE}, ys, ${POST})

@@ inv_text_lines_5 @@
  match b5:
    case False{}: ${absurd()}
    case True{}: contra(${CWA}, ${ALL}, var_inj(${OUT}, ${WBL}, e))

@@ inv_text_lines_6 @@
  match ps:
    case Nil{}: Empty.absurd(${GOAL}, hf)
    case Con{S.Fixed{+xs}, Nil{}}: st${i + 1}(${CWA}, ${A}xs, Equal.sym(Nat, ${z}n, List.length(&2, U32, xs), FD.logic__some_inj(Nat, ${z}n, List.length(&2, U32, xs), hf)), r, e)
    case Con{S.Variable{+xs}, Nil{}}: Empty.absurd(${GOAL}, FD.logic__none_some(Nat, ${z}n, Equal.sym(Maybe<&2, Nat>, Some{${z}n}, None{}, hf)))
    case Con{S.Fixed{+xs}, Con{+h2, +t2}}: Empty.absurd(${GOAL}, hf)
    case Con{S.Variable{+xs}, Con{+h2, +t2}}: Empty.absurd(${GOAL}, hf)

@@ inv_text_lines_7 @@
  match mm:
    case None{}: ${absurd()}
    case Some{+ps}: fp${i}(${CWA}, ${A}ps, hf, r, e)

@@ inv_text_lines_8 @@
  match ps:
    case Nil{}: Empty.absurd(${GOAL}, hf)
    case Con{S.Fixed{+xs}, Nil{}}: Empty.absurd(${GOAL}, FD.logic__none_some(Nat, List.length(&2, U32, xs), hf))
    case Con{S.Variable{+ys}, Nil{}}: st${i + 1}(${CWA}, ${A}h, ys, em, r, e)
    case Con{S.Fixed{+xs}, Con{+h2, +t2}}: Empty.absurd(${GOAL}, hf)
    case Con{S.Variable{+xs}, Con{+h2, +t2}}: Empty.absurd(${GOAL}, hf)

@@ inv_text_lines_9 @@
  match mm:
    case None{}: ${absurd()}
    case Some{+ps}: vp${i}(${CWA}, ${A}h, ps, hf, em, r, e)

@@ _cx_reader_lines @@
def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> ${Tn}: ${OBJ}

def rd_go(${CW}, ${HA}, +epo: {SPOw(t, x) == ${FS} : U32}, +hc: {${CHK_child} == True{} : Bool})
    -> {${Tn}_read(BF(t, n), off, len) == ${RHS} : ${TY}}:
  %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, ${P})), (BF(t, n), SPOw(t, x)), rdpo(${CWA}, ha)) :
    {${Tn}_rd0(off, len, _) == ${RHS} : ${TY}}
@@ _cx_reader_lines_2 @@
  %Equal.sym(B.Buf & ${ft.rep()}, ${read_term(f, FS)}, (BF(t, n), ${objs[j]}),
      VTX.rdxd_${ft.p}(d, t, n, U32.add(off, ${c}), ${posx(c)}, eoc(${CWA}, ${c}, ${c}n, {==}, {==}, ha), hd, pf,
        roomF(${CWA}, ha, ${c}n, ${ft.size}n, {==}))) :
    {${Tn}_rd${j + 1}(${args}, _) == ${RHS} : ${TY}}