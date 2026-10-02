@@ CORE @@

def BF(t: FD.array__Tree<U32>, +n: U32) -> B.Buf: VR.BF(t, n)
def SPO(t: FD.array__Tree<U32>) -> U32: VB.slot(t, @POn)
def LL(+n: U32) -> U32: U32.sub(n, @FS)
def OW() -> U32: U32.add(0, @FS)
def XW(+n: U32) -> U32: VR.XN(OW(), LL(n))
def VWB(+t: FD.array__Tree<U32>, +n: U32) -> U32: VR.VX(t, XW(n))
def M1(+n: U32) -> Nat: U32.to_nat(U32.sub(LL(n), 1))
def BD(+t: FD.array__Tree<U32>, +n: U32) -> Nat: Nat.add(Nat.mul(8n, M1(n)), U32.to_nat(O.high_bit(VWB(t, n))))

def chk3(a: Bool, b: Bool, c: Bool) -> Bool:
  match a:
    case False{}: False{}
    case True{}:
      match b:
        case False{}: False{}
        case True{}: c

def chkw(a: Bool, +t: FD.array__Tree<U32>, +n: U32) -> Bool:
  match a:
    case False{}: False{}
    case True{}: O.bsel(U32.is_eq(VWB(t, n), 0), False{}, O.bsel(False{}, True{}, Nat.is_le(BD(t, n), U32.to_nat(@N))))

# The window [@FS, n) passes the bit-list checks.
def CHKW(+t: FD.array__Tree<U32>, +n: U32) -> Bool: chkw(U32.is_lt(0, LL(n)), t, n)
def CHK(+t: FD.array__Tree<U32>, +n: U32) -> Bool: chk3(U32.is_le(@FS, n), U32.is_eq(SPO(t), @FS), CHKW(t, n))

def leFS(+n: U32, +ha: {U32.is_le(@FS, n) == True{} : Bool}) -> {Nat.is_le(@FSn, U32.to_nat(n)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(@FS, n), Nat.is_le(@FSn, U32.to_nat(n)), VU.le_u32(@FS, n), ha)

def enFS(+n: U32, +ha: {U32.is_le(@FS, n) == True{} : Bool}) -> {Nat.add(@FSn, U32.to_nat(LL(n))) == U32.to_nat(n) : Nat}:
  %Equal.sym(Nat, U32.to_nat(LL(n)), Nat.sub(U32.to_nat(n), @FSn), FD.u32__sub_nat(n, @FS, leFS(n, ha))) : {Nat.add(@FSn, _) == U32.to_nat(n) : Nat}
  FD.nat__sub_add(U32.to_nat(n), @FSn, leFS(n, ha))

# The window lies in the buffer: 4 H + L <= 4 2^d.
def hwL(+d: Nat, +n: U32, +ha: {U32.is_le(@FS, n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(Nat.add(A.quad(@Hn), U32.to_nat(LL(n))), A.quad(VB.pw(d))) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(n), Nat.add(@FSn, U32.to_nat(LL(n))), Equal.sym(Nat, Nat.add(@FSn, U32.to_nat(LL(n))), U32.to_nat(n), enFS(n, ha)), hn)

def hLd(+d: Nat, +n: U32, +ha: {U32.is_le(@FS, n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(LL(n)), A.quad(VB.pw(d))) == True{} : Bool}:
  FD.nat__le_trans(U32.to_nat(LL(n)), Nat.add(A.quad(@Hn), U32.to_nat(LL(n))), A.quad(VB.pw(d)), Order.left_below_sum(A.quad(@Hn), U32.to_nat(LL(n))), hwL(d, n, ha, hn))

# The offset word (word @PO < H) lies in the buffer: 4 H <= n <= 4 2^d.
def hk(+d: Nat, +n: U32, +ha: {U32.is_le(@FS, n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {Nat.is_lt(@POn, VB.pw(d)) == True{} : Bool}:
  A.room_aligned(@POn, VB.pw(d), FD.nat__le_trans(Nat.add(A.quad(@POn), 4n), A.quad(@Hn), A.quad(VB.pw(d)), {==},
    FD.nat__le_trans(A.quad(@Hn), Nat.add(A.quad(@Hn), U32.to_nat(LL(n))), A.quad(VB.pw(d)), FD.nat__le_add_right(A.quad(@Hn), U32.to_nat(LL(n))), hwL(d, n, ha, hn))))

def hlt(+d: Nat, +n: U32, +ha: {U32.is_le(@FS, n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +e1: {U32.to_nat(LL(n)) == 1n+M1(n) : Nat})
    -> {Nat.is_lt(Nat.add(A.quad(@Hn), M1(n)), A.quad(VB.pw(d))) == True{} : Bool}:
  FD.nat__lt_le_trans(Nat.add(A.quad(@Hn), M1(n)), Nat.add(A.quad(@Hn), U32.to_nat(LL(n))), A.quad(VB.pw(d)),
    FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(A.quad(@Hn), M1(n)), Nat.add(A.quad(@Hn), z)) == True{} : Bool}, 1n+M1(n), U32.to_nat(LL(n)), Equal.sym(Nat, U32.to_nat(LL(n)), 1n+M1(n), e1),
      FD.nat__lt_add_left(M1(n), 1n+M1(n), A.quad(@Hn), FD.nat__lt_succ(M1(n)))),
    hwL(d, n, ha, hn))

# The window ends below 2^32 (n is a U32).
def hw32L(+n: U32, +ha: {U32.is_le(@FS, n) == True{} : Bool})
    -> {Nat.is_lt(Nat.add(A.quad(@Hn), U32.to_nat(LL(n))), FD.spec_common__pow2(32n)) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_lt(z, FD.spec_common__pow2(32n)) == True{} : Bool}, U32.to_nat(n), Nat.add(@FSn, U32.to_nat(LL(n))), Equal.sym(Nat, Nat.add(@FSn, U32.to_nat(LL(n))), U32.to_nat(n), enFS(n, ha)), VB.u32_lt(n))

def eXW(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +ha: {U32.is_le(@FS, n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +e1: {U32.to_nat(LL(n)) == 1n+M1(n) : Nat})
    -> {U32.to_nat(XW(n)) == Nat.add(A.quad(@Hn), M1(n)) : Nat}:
  VR.eXNw(OW(), @Hn, LL(n), M1(n), {==}, hw32L(n, ha), e1)

def hiW(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +ha: {U32.is_le(@FS, n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +e1: {U32.to_nat(LL(n)) == 1n+M1(n) : Nat})
    -> {Nat.is_lt(VR.QX(XW(n)), VB.pw(d)) == True{} : Bool}:
  VR.hiX(d, XW(n), Nat.add(A.quad(@Hn), M1(n)), eXW(d, n, hd, ha, hn, e1), hlt(d, n, ha, hn, e1))

# ---- the validator ----------------------------------------------------------------------------

def okw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +ha: {U32.is_le(@FS, n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +a: Bool, +ea: {U32.is_lt(0, LL(n)) == a : Bool})
    -> {T.@p_ok(BF(t, n), OW(), LL(n)) == (BF(t, n), chkw(a, t, n)) : B.Buf & Bool}:
  match a:
    case False{}:
      %Equal.sym(Bool, U32.is_lt(0, LL(n)), False{}, ea) : {O.bitlist_nz(_, BF(t, n), OW(), LL(n), @N, False{}) == (BF(t, n), False{}) : B.Buf & Bool}
      {==}
    case True{}:
      +e1 = VR.e1n(LL(n), VR.pos1(LL(n), ea))
      %Equal.sym(Bool, U32.is_lt(0, LL(n)), True{}, ea) : {O.bitlist_nz(_, BF(t, n), OW(), LL(n), @N, False{}) == (BF(t, n), chkw(True{}, t, n)) : B.Buf & Bool}
      %Equal.sym(B.Buf & U32, B.byte_at(BF(t, n), XW(n)), (BF(t, n), VWB(t, n)),
          VR.byte_at_ok(d, t, n, XW(n), VB.lt32(d, hd), hiW(d, n, hd, ha, hn, e1), pf)) :
        {O.bitlist_pick(LL(n), @N, False{}, _) == (BF(t, n), chkw(True{}, t, n)) : B.Buf & Bool}
      {==}

def c1_id(+ok: Bool, buf: B.Buf, +off: U32, +len: U32, +o0: U32) -> {T.@X_c1(ok, buf, off, len, o0) == (buf, ok) : B.Buf & Bool}:
  match ok:
    case True{}: {==}
    case False{}: {==}

def ok_c0(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +ha: {U32.is_le(@FS, n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +b: Bool, +eb: {U32.is_eq(SPO(t), @FS) == b : Bool})
    -> {T.@X_c0(b, BF(t, n), 0, n, SPO(t)) == (BF(t, n), chk3(True{}, b, CHKW(t, n))) : B.Buf & Bool}:
  match b:
    case False{}: {==}
    case True{}:
      +epo = FD.u32alg__eq_of(SPO(t), @FS, eb)
      %Equal.sym(U32, SPO(t), @FS, epo) :
        {T.@X_v1(0, n, _, T.@p_ok(BF(t, n), U32.add(0, _), U32.sub(n, _))) == (BF(t, n), CHKW(t, n)) : B.Buf & Bool}
      %Equal.sym(B.Buf & Bool, T.@p_ok(BF(t, n), OW(), LL(n)), (BF(t, n), CHKW(t, n)), okw(d, t, n, pf, hd, ha, hn, U32.is_lt(0, LL(n)), {==})) :
        {T.@X_v1(0, n, @FS, _) == (BF(t, n), CHKW(t, n)) : B.Buf & Bool}
      c1_id(CHKW(t, n), BF(t, n), 0, n, @FS)

def ok_len(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +a: Bool, +ea: {U32.is_le(@FS, n) == a : Bool})
    -> {T.@X_ok_len(a, BF(t, n), 0, n) == (BF(t, n), chk3(a, U32.is_eq(SPO(t), @FS), CHKW(t, n))) : B.Buf & Bool}:
  match a:
    case False{}: {==}
    case True{}:
      %Equal.sym(B.Buf & U32, B.read32(VF.BF(t, n), U32.add(0, @CV)), (VF.BF(t, n), SPO(t)),
          VF.rd32a(d, t, n, U32.add(0, @CV), @POn, {==}, VB.lt32(d, hd), hk(d, n, ea, hn), pf)) :
        {T.@X_v0(0, n, _) == (BF(t, n), chk3(True{}, U32.is_eq(SPO(t), @FS), CHKW(t, n))) : B.Buf & Bool}
      ok_c0(d, t, n, pf, hd, ea, hn, U32.is_eq(SPO(t), @FS), {==})

# The validator returns the buffer and CHK(t, n).
def ok_eval(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {T.@X_ok(BF(t, n), 0, n) == (BF(t, n), CHK(t, n)) : B.Buf & Bool}:
  ok_len(d, t, n, pf, hd, hn, U32.is_le(@FS, n), {==})

# ---- facts of accepted buffers -----------------------------------------------------------------

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

def cwA(+a: Bool, +t: FD.array__Tree<U32>, +n: U32, +h: {chkw(a, t, n) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case False{}: h
    case True{}: {==}

def bselF(+c: Bool, +y: Bool, +h: {O.bsel(c, False{}, y) == True{} : Bool}) -> {c == False{} : Bool}:
  match c:
    case True{}: Empty.absurd({True{} == False{} : Bool}, FD.logic__false_true(h))
    case False{}: {==}

def cw1(+t: FD.array__Tree<U32>, +n: U32, +h: {CHKW(t, n) == True{} : Bool}) -> {chkw(True{}, t, n) == True{} : Bool}:
  FD.logic__subst(Bool, z => {chkw(z, t, n) == True{} : Bool}, U32.is_lt(0, LL(n)), True{}, cwA(U32.is_lt(0, LL(n)), t, n, h), h)

def cwB(+t: FD.array__Tree<U32>, +n: U32, +h: {chkw(True{}, t, n) == True{} : Bool}) -> {U32.is_eq(VWB(t, n), 0) == False{} : Bool}:
  bselF(U32.is_eq(VWB(t, n), 0), O.bsel(False{}, True{}, Nat.is_le(BD(t, n), U32.to_nat(@N))), h)

def cwC(+t: FD.array__Tree<U32>, +n: U32, +h: {chkw(True{}, t, n) == True{} : Bool}, +nz: {U32.is_eq(VWB(t, n), 0) == False{} : Bool})
    -> {Nat.is_le(BD(t, n), U32.to_nat(@N)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {O.bsel(z, False{}, O.bsel(False{}, True{}, Nat.is_le(BD(t, n), U32.to_nat(@N)))) == True{} : Bool}, U32.is_eq(VWB(t, n), 0), False{}, nz, h)

def cwE(+t: FD.array__Tree<U32>, +n: U32, +h: {CHKW(t, n) == True{} : Bool}) -> {U32.to_nat(LL(n)) == 1n+M1(n) : Nat}:
  VR.e1n(LL(n), VR.pos1(LL(n), cwA(U32.is_lt(0, LL(n)), t, n, h)))

# L <= @BMAX: the checks bound the window.
def hB(+t: FD.array__Tree<U32>, +n: U32, +e1: {U32.to_nat(LL(n)) == 1n+M1(n) : Nat}, +bd: {Nat.is_le(BD(t, n), U32.to_nat(@N)) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(LL(n)), @BMAXn) == True{} : Bool}:
  +bd1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, U32.to_nat(O.high_bit(VWB(t, n)))), U32.to_nat(@N)) == True{} : Bool}, Nat.mul(8n, M1(n)), VS.x8(M1(n)), VR.mul8(M1(n)), bd)
  +h8 = FD.nat__le_trans(VS.x8(M1(n)), Nat.add(VS.x8(M1(n)), U32.to_nat(O.high_bit(VWB(t, n)))), Nat.add(VS.x8(@Cn), 7n), FD.nat__le_add_right(VS.x8(M1(n)), U32.to_nat(O.high_bit(VWB(t, n)))),
    FD.nat__le_trans(Nat.add(VS.x8(M1(n)), U32.to_nat(O.high_bit(VWB(t, n)))), U32.to_nat(@N), Nat.add(VS.x8(@Cn), 7n), bd1, {==}))
  %Equal.sym(Nat, U32.to_nat(LL(n)), 1n+M1(n), e1) : {Nat.is_le(_, @BMAXn) == True{} : Bool}
  VR.x8_inv(M1(n), @Cn, h8)

# 31 + L <= 2^@KB: the checks bound the window (whatever the buffer's depth).
def hyB(+n: U32, +hb: {Nat.is_le(U32.to_nat(LL(n)), @BMAXn) == True{} : Bool}) -> {Nat.is_le(VC.YL(LL(n)), VB.pw(@KBn)) == True{} : Bool}:
  FD.nat__le_trans(VC.YL(LL(n)), Nat.add(31n, @BMAXn), VB.pw(@KBn), Order.add_left(31n, U32.to_nat(LL(n)), @BMAXn, hb), {==})

def hWZ(+n: U32, +hb: {Nat.is_le(U32.to_nat(LL(n)), @BMAXn) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(VC.WZ(LL(n))), O.pow2n(@Kn)) == True{} : Bool}:
  FD.nat__le_trans(U32.to_nat(VC.WZ(LL(n))), Nat.add(VD.s_rng(2n, VC.YL(LL(n))), 8n), O.pow2n(@Kn),
    VC.wz_le(LL(n), @KBn, {==}, hyB(n, hb)),
    FD.nat__le_trans(Nat.add(VD.s_rng(2n, VC.YL(LL(n))), 8n), Nat.add(VD.s_rng(2n, @YMAXn), 8n), O.pow2n(@Kn),
      Order.add_right(VD.s_rng(2n, VC.YL(LL(n))), VD.s_rng(2n, @YMAXn), 8n, VC.rng_mono(2n, VC.YL(LL(n)), @YMAXn, Order.add_left(31n, U32.to_nat(LL(n)), @BMAXn, hb))),
      {==}))

def hdzK(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hL: {Nat.is_le(U32.to_nat(LL(n)), A.quad(VB.pw(d))) == True{} : Bool},
    +hb: {Nat.is_le(U32.to_nat(LL(n)), @BMAXn) == True{} : Bool}) -> {Nat.is_le(VLS.DZ(LL(n)), @Kn) == True{} : Bool}:
  VD.wd_min(VC.WZ(LL(n)), @Kn, hWZ(n, hb))

# The list storage has room for the words.
def hrgB(+n: U32, +hb: {Nat.is_le(U32.to_nat(LL(n)), @BMAXn) == True{} : Bool}) -> {Nat.is_le(Nat.add(VC.NW(LL(n)), 0n), VB.pw(VLS.DZ(LL(n)))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(VC.NW(LL(n)), 0n), VC.NW(LL(n)), FD.nat__add_zero(VC.NW(LL(n)))) : {Nat.is_le(_, VB.pw(VLS.DZ(LL(n)))) == True{} : Bool}
  %Equal.sym(Nat, VB.pw(VLS.DZ(LL(n))), O.pow2n(VLS.DZ(LL(n))), VD.s_pow2_eq(VLS.DZ(LL(n)))) : {Nat.is_le(VC.NW(LL(n)), _) == True{} : Bool}
  FD.nat__le_trans(VC.NW(LL(n)), U32.to_nat(VC.WZ(LL(n))), O.pow2n(VLS.DZ(LL(n))), VC.nw_le_wz(LL(n), @KBn, {==}, hyB(n, hb)), VD.wd_cover(VC.WZ(LL(n)), @Kn, {==}, hWZ(n, hb)))

@@ CONTRA @@

def u32le(+a: U32, +b: U32, +h: {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool}) -> {U32.is_le(a, b) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(a), U32.to_nat(b)), U32.is_le(a, b), Equal.sym(Bool, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b)), h)

def subc(+n: U32, +k: U32, +y: Nat, +e: {U32.to_nat(n) == Nat.add(U32.to_nat(k), y) : Nat}) -> {U32.to_nat(U32.sub(n, k)) == y : Nat}:
  +le = FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(k), z) == True{} : Bool}, Nat.add(U32.to_nat(k), y), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), Nat.add(U32.to_nat(k), y), e), FD.nat__le_add_right(U32.to_nat(k), y))
  %Equal.sym(Nat, U32.to_nat(U32.sub(n, k)), Nat.sub(U32.to_nat(n), U32.to_nat(k)), FD.u32__sub_nat(n, k, le)) : {_ == y : Nat}
  %Equal.sym(Nat, U32.to_nat(n), Nat.add(U32.to_nat(k), y), e) : {Nat.sub(_, U32.to_nat(k)) == y : Nat}
  FD.nat__add_sub_cancel(U32.to_nat(k), y)

# The window's bytes, from the layout.
def winY(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +Y: +List<U32>, +ha: {U32.is_le(@FS, n) == True{} : Bool},
    +ty: {VS.bdr(@FSn, DC.VW(t, n)) == Y : +List<U32>}) -> {Y == VR.WB(t, @Hn, U32.to_nat(DC.LL(n))) : +List<U32>}:
  %ty : {_ == VR.WB(t, @Hn, U32.to_nat(DC.LL(n))) : +List<U32>}
  %Equal.sym(Nat, U32.to_nat(n), Nat.add(@FSn, U32.to_nat(DC.LL(n))), Equal.sym(Nat, Nat.add(@FSn, U32.to_nat(DC.LL(n))), U32.to_nat(n), DC.enFS(n, ha))) :
    {VS.bdr(@FSn, VS.bt(_, F.limbs(FD.array__slots(U32, t)))) == VR.WB(t, @Hn, U32.to_nat(DC.LL(n))) : +List<U32>}
  VS.bdr_bt(@FSn, U32.to_nat(DC.LL(n)), F.limbs(FD.array__slots(U32, t)))

def contra(@CTX, @DECL, +eo: {@OUT == DC.VW(t, n) : +List<U32>}) -> Empty:
  (+l, +r) = fs
  (+nz0, +ln) = r
  +m = VBL.mcnt(bits)
  +Y = VBL.P(bits)
  +lY = List.length(&2, U32, Y)
  +elen = Equal.trans(Nat, U32.to_nat(n), List.length(&2, U32, DC.VW(t, n)), Nat.add(@FSn, lY), Equal.sym(Nat, List.length(&2, U32, DC.VW(t, n)), U32.to_nat(n), VR.lenWB(d, t, 0n, U32.to_nat(n), pf, hn)),
    Equal.trans(Nat, List.length(&2, U32, DC.VW(t, n)), List.length(&2, U32, @OUT), Nat.add(@FSn, lY),
      Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), DC.VW(t, n), @OUT, Equal.sym(+List<U32>, @OUT, DC.VW(t, n), eo)), f_len(@ALL)))
  +hF = FD.logic__subst(Nat, z => {Nat.is_le(@FSn, z) == True{} : Bool}, Nat.add(@FSn, lY), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), Nat.add(@FSn, lY), elen), FD.nat__le_add_right(@FSn, lY))
  +ha = u32le(@FS, n, hF)
  +eLL = subc(n, @FS, lY, elen)
  +e1 = Equal.trans(Nat, U32.to_nat(DC.LL(n)), lY, 1n+m, eLL, l)
  # the offset word
  +b0 = VN.byteK2(d, t, n, @POn, pf, hn, FD.nat__le_trans(Nat.add(A.quad(@POn), 4n), @FSn, U32.to_nat(n), {==}, hF))
  +epo = VN.wordc(DC.SPO(t), @FS, Equal.trans(+List<U32>, F.limbs([DC.SPO(t)]), VS.bt(4n, VS.bdr(@Pn, DC.VW(t, n))), N.digits(4n, @FSn),
    Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(@Pn, DC.VW(t, n))), F.limbs([DC.SPO(t)]), b0),
    Equal.trans(+List<U32>, VS.bt(4n, VS.bdr(@Pn, DC.VW(t, n))), VS.bt(4n, VS.bdr(@Pn, @OUT)), N.digits(4n, @FSn),
      Equal.cong(+List<U32>, +List<U32>, z => VS.bt(4n, VS.bdr(@Pn, z)), DC.VW(t, n), @OUT, Equal.sym(+List<U32>, @OUT, DC.VW(t, n), eo)), f_off(@ALL))))
  # the window
  +ty = Equal.trans(+List<U32>, VS.bdr(@FSn, DC.VW(t, n)), VS.bdr(@FSn, @OUT), Y,
    Equal.cong(+List<U32>, +List<U32>, z => VS.bdr(@FSn, z), DC.VW(t, n), @OUT, Equal.sym(+List<U32>, @OUT, DC.VW(t, n), eo)), f_tail(@ALL))
  +eW = winY(d, t, n, Y, ha, ty)
  +W1 = VR.WB(t, @Hn, 1n+m)
  +eW1 = Equal.trans(+List<U32>, Y, VR.WB(t, @Hn, U32.to_nat(DC.LL(n))), W1, eW, Equal.cong(Nat, +List<U32>, z => VR.WB(t, @Hn, z), U32.to_nat(DC.LL(n)), 1n+m, e1))
  +m1 = Equal.trans(Nat, DC.M1(n), m, m, subc(DC.LL(n), 1, m, e1), {==})
  +e1m = Equal.trans(Nat, U32.to_nat(DC.LL(n)), 1n+m, 1n+DC.M1(n), e1, Equal.cong(Nat, Nat, z => 1n+z, m, DC.M1(n), Equal.sym(Nat, DC.M1(n), m, m1)))
  +hw1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(A.quad(@Hn), z), A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(DC.LL(n)), 1n+m, e1, DC.hwL(d, n, ha, hn))
  +lw = VR.lastWB(d, t, @Hn, m, DC.XW(n), pf, hw1,
    FD.logic__subst(Nat, z => {U32.to_nat(DC.XW(n)) == Nat.add(A.quad(@Hn), z) : Nat}, DC.M1(n), m, m1, DC.eXW(d, n, hd, ha, hn, e1m)))
  +eV = Equal.trans(U32, VBL.nthb(Y, m), VBL.nthb(W1, m), DC.VWB(t, n), Equal.cong(+List<U32>, U32, z => VBL.nthb(z, m), Y, W1, eW1),
    Equal.trans(U32, VBL.nthb(W1, m), VBL.lastb(W1), DC.VWB(t, n), Equal.sym(U32, VBL.lastb(W1), VBL.nthb(W1, m), VR.last_len(W1, m, VR.lenWB(d, t, @Hn, 1n+m, pf, hw1))), lw))
  +nz = FD.logic__subst(U32, z => {U32.is_eq(z, 0) == False{} : Bool}, VBL.nthb(Y, m), DC.VWB(t, n), eV, nz0)
  +lnV = Equal.trans(Nat, List.length(&2, Bool, bits), Nat.add(VS.x8(m), VY.hb(VBL.nthb(Y, m))), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(DC.VWB(t, n)))), ln,
    Equal.cong(U32, Nat, z => Nat.add(VS.x8(m), VY.hb(z)), VBL.nthb(Y, m), DC.VWB(t, n), eV))
  +eBD = Equal.trans(Nat, DC.BD(t, n), Nat.add(VS.x8(DC.M1(n)), U32.to_nat(O.high_bit(DC.VWB(t, n)))), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(DC.VWB(t, n)))),
    Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(O.high_bit(DC.VWB(t, n)))), Nat.mul(8n, DC.M1(n)), VS.x8(DC.M1(n)), VR.mul8(DC.M1(n))),
    Equal.cong(Nat, Nat, z => Nat.add(VS.x8(z), U32.to_nat(O.high_bit(DC.VWB(t, n)))), DC.M1(n), m, m1))
  +bd = FD.logic__subst(Nat, z => {Nat.is_le(z, @LIMN) == True{} : Bool}, List.length(&2, Bool, bits), DC.BD(t, n),
    Equal.trans(Nat, List.length(&2, Bool, bits), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(DC.VWB(t, n)))), DC.BD(t, n), lnV, Equal.sym(Nat, DC.BD(t, n), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(DC.VWB(t, n)))), eBD)), hb)
  +lt0 = FD.logic__subst(Nat, z => {Nat.is_lt(0n, z) == True{} : Bool}, 1n+m, U32.to_nat(DC.LL(n)), Equal.sym(Nat, U32.to_nat(DC.LL(n)), 1n+m, e1), {==})
  +ea = FD.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_lt(0n, U32.to_nat(DC.LL(n))), U32.is_lt(0, DC.LL(n)), Equal.sym(Bool, U32.is_lt(0, DC.LL(n)), Nat.is_lt(0n, U32.to_nat(DC.LL(n))), VR.lt_u32(0, DC.LL(n))), lt0)
  +hw = chkw_t(t, n, ea, nz, bd)
  FD.logic__true_false(Equal.trans(Bool, True{}, DC.CHK(t, n), False{}, Equal.sym(Bool, DC.CHK(t, n), True{}, chk_t(t, n, ha, epo, hw)), hchk))

@@ CHKT @@

def chkw_t(+t: FD.array__Tree<U32>, +n: U32, +ea: {U32.is_lt(0, DC.LL(n)) == True{} : Bool}, +nz: {U32.is_eq(DC.VWB(t, n), 0) == False{} : Bool},
    +bd: {Nat.is_le(DC.BD(t, n), U32.to_nat(@N)) == True{} : Bool}) -> {DC.CHKW(t, n) == True{} : Bool}:
  %Equal.sym(Bool, U32.is_lt(0, DC.LL(n)), True{}, ea) : {DC.chkw(_, t, n) == True{} : Bool}
  %Equal.sym(Bool, U32.is_eq(DC.VWB(t, n), 0), False{}, nz) : {O.bsel(_, False{}, O.bsel(False{}, True{}, Nat.is_le(DC.BD(t, n), U32.to_nat(@N)))) == True{} : Bool}
  bd

def chk_t(+t: FD.array__Tree<U32>, +n: U32, +ha: {U32.is_le(@FS, n) == True{} : Bool}, +epo: {DC.SPO(t) == @FS : U32}, +hw: {DC.CHKW(t, n) == True{} : Bool})
    -> {DC.CHK(t, n) == True{} : Bool}:
  %Equal.sym(Bool, U32.is_le(@FS, n), True{}, ha) : {DC.chk3(_, U32.is_eq(DC.SPO(t), @FS), DC.CHKW(t, n)) == True{} : Bool}
  %Equal.sym(U32, DC.SPO(t), @FS, epo) : {DC.chk3(True{}, U32.is_eq(_, @FS), DC.CHKW(t, n)) == True{} : Bool}
  hw

@@ dec_text @@

def acc_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {CHK(t, n) == True{} : Bool},
    +ha: {U32.is_le(@FS, n) == True{} : Bool}, +epo: {SPO(t) == @FS : U32}, +hw: {CHKW(t, n) == True{} : Bool})
    -> {${Tn}_decode(BF(t, n), n) == (BF(t, n), Some{OBJ(t, n)}) : ${D}}:
  +e1 = cwE(t, n, hw)
  +h1 = cw1(t, n, hw)
  +hL = hLd(d, n, ha, hn)
  +hb = hB(t, n, e1, cwC(t, n, h1, cwB(t, n, h1)))
  +hz = hdzK(d, n, hd, hL, hb)
  +ez = zeros_at(B.words_depth_u(VC.WZ(LL(n))), VLS.DZ(LL(n)), VD.wdu(VC.WZ(LL(n))), hz)
  %Equal.sym(B.Buf & Bool, ${Tn}_ok(BF(t, n), 0, n), (BF(t, n), CHK(t, n)), ok_eval(d, t, n, pf, hd, hn)) :
    {${Tn}_built(n, _) == (BF(t, n), Some{OBJ(t, n)}) : ${D}}
  %Equal.sym(Bool, CHK(t, n), True{}, hchk) :
    {${Tn}_built(n, (BF(t, n), _)) == (BF(t, n), Some{OBJ(t, n)}) : ${D}}
  %Equal.sym(B.Buf & ${Tn}, ${Tn}_read(BF(t, n), 0, n), (BF(t, n), OBJ(t, n)),
      rd_ok(d, t, n, VLS.DZ(LL(n)), pf, hd, FD.nat__le_lt_trans(VLS.DZ(LL(n)), @Kn, 31n, hz, {==}), ha, hn, epo, e1, hb, ez, hrgB(n, hb))) :
    {${Tn}_some(_) == (BF(t, n), Some{OBJ(t, n)}) : ${D}}
  {==}

# Every buffer the validator accepts decodes to OBJ(t, n).
law decode_accept:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == True{} : Bool}
  {${Tn}_decode(BF(t, n), n) == (BF(t, n), Some{OBJ(t, n)}) : ${D}}
def decode_accept(d, t, n, pf, hd, hn, hchk):
  +a = U32.is_le(@FS, n)
  +b = U32.is_eq(SPO(t), @FS)
  +c = CHKW(t, n)
  acc_go(d, t, n, pf, hd, hn, hchk, ch_a(a, b, c, hchk), FD.u32alg__eq_of(SPO(t), @FS, ch_b(a, b, c, hchk)), ch_c(a, b, c, hchk))

# When the validator refuses, the decoder returns None and the buffer.
law decode_none:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == False{} : Bool}
  {${Tn}_decode(BF(t, n), n) == (BF(t, n), None{}) : ${D}}
def decode_none(d, t, n, pf, hd, hn, hchk):
  %Equal.sym(B.Buf & Bool, ${Tn}_ok(BF(t, n), 0, n), (BF(t, n), CHK(t, n)), ok_eval(d, t, n, pf, hd, hn)) :
    {${Tn}_built(n, _) == (BF(t, n), None{}) : ${D}}
  %Equal.sym(Bool, CHK(t, n), False{}, hchk) :
    {${Tn}_built(n, (BF(t, n), _)) == (BF(t, n), None{}) : ${D}}
  {==}

@@ rej_text @@

# When the validator refuses, no value is related to the buffer's bytes.
law decode_reject:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {DC.CHK(t, n) == False{} : Bool}
  Decoding.outside_image(Spec.${n}(), ${VWt})
def decode_reject(d, t, n, pf, hd, hn, hchk):
  v => e => inv_v(${CA}, v, e)
