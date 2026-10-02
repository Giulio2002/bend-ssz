@@ byte_module @@
def b8(w: Word(8n)) -> +List<Bool>:
  match w:
    case WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WNil{}}}}}}}}}: [c0, c1, c2, c3, c4, c5, c6, c7]

# The low byte of a word, as the eight bits of the spec's byte.
def bits8(+v: U32) -> +List<Bool>: b8(WSp.take(8n, 32n, PD.bits(v)))

def btk(k: Nat, xs: +List<Bool>) -> +List<Bool>:
  match k:
    case 0n: []
    case 1n+p:
      match xs:
        case Nil{}: []
        case Con{+b, t}: b <> btk(p, t)

def hb(+v: U32) -> Nat: U32.to_nat(O.high_bit(v))

law oct_pack:
  for +w: Word(8n)
  for +R: +List<Bool>
  {Bp.pack(List.append(&2, Bool, b8(w), R)) == PD.embed8(w) <> Bp.pack(R) : +List<U32>}
def oct_pack(w, R):
  match w:
    case 
@@ byte_module_2 @@
:
      Equal.cong(U32, +List<U32>, z => z <> Bp.pack(R), Bp.octet(c0, c1, c2, c3, c4, c5, c6, c7), PD.embed8(WCon{c0, WCon{c1, WCon{c2, WCon{c3, WCon{c4, WCon{c5, WCon{c6, WCon{c7, WNil{}}}}}}}}}),
        BLf.oct8(c0, c1, c2, c3, c4, c5, c6, c7))

@@ byte_module_fge @@
law fge:
  for +b: Bool
  for +c: Cmp
  for +h: {Cmp.is_ge(c) == True{} : Bool}
  {Cmp.is_ge(Word.cmp.fin(b, False{}, c)) == True{} : Bool}
def fge(b, c, h):
  match b c:
    case False{} LT{}: Empty.absurd({Cmp.is_ge(Word.cmp.fin(False{}, False{}, LT{})) == True{} : Bool}, F.logic__false_true(h))
    case True{} LT{}: Empty.absurd({Cmp.is_ge(Word.cmp.fin(True{}, False{}, LT{})) == True{} : Bool}, F.logic__false_true(h))
    case False{} EQ{}: {==}
    case True{} EQ{}: {==}
    case False{} GT{}: {==}
    case True{} GT{}: {==}

@@ GBODY @@

def BF(t: FD.array__Tree<U32>, +n: U32) -> B.Buf: VR.BF(t, n)
def VW(+t: FD.array__Tree<U32>, +n: U32) -> +List<U32>: VS.bt(U32.to_nat(n), FX.limbs(FD.array__slots(U32, t)))
def V(+t: FD.array__Tree<U32>, +n: U32) -> U32: VR.VX(t, VR.XN(0, n))
def BD(+t: FD.array__Tree<U32>, +n: U32) -> Nat: Nat.add(Nat.mul(8n, U32.to_nat(U32.sub(n, 1))), U32.to_nat(O.high_bit(V(t, n))))
def M1(+n: U32) -> Nat: U32.to_nat(U32.sub(n, 1))

def chk1(a: Bool, +t: FD.array__Tree<U32>, +n: U32) -> Bool:
  match a:
    case False{}: False{}
    case True{}: O.bsel(U32.is_eq(V(t, n), 0), False{}, O.bsel(False{}, True{}, Nat.is_le(BD(t, n), U32.to_nat(@N))))

# The Bool of the validator's checks: non-empty, a non-zero last byte, at most @N bits.
def CHK(+t: FD.array__Tree<U32>, +n: U32) -> Bool: chk1(U32.is_lt(0, n), t, n)

def hlt(+d: Nat, +n: U32, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +e1: {U32.to_nat(n) == 1n+M1(n) : Nat})
    -> {Nat.is_lt(Nat.add(A.quad(0n), M1(n)), A.quad(VB.pw(d))) == True{} : Bool}:
  FD.nat__lt_le_trans(M1(n), 1n+M1(n), A.quad(VB.pw(d)), FD.nat__lt_succ(M1(n)),
    FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(n), 1n+M1(n), e1, hn))

def hiN(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +e1: {U32.to_nat(n) == 1n+M1(n) : Nat}) -> {Nat.is_lt(VR.QX(VR.XN(0, n)), VB.pw(d)) == True{} : Bool}:
  VR.hiX(d, VR.XN(0, n), Nat.add(A.quad(0n), M1(n)), VR.eXN0(n, M1(n), e1), hlt(d, n, hn, e1))

def okA(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +a: Bool, +ea: {U32.is_lt(0, n) == a : Bool})
    -> {T.@p_ok(BF(t, n), 0, n) == (BF(t, n), chk1(a, t, n)) : B.Buf & Bool}:
  match a:
    case False{}:
      %Equal.sym(Bool, U32.is_lt(0, n), False{}, ea) : {O.bitlist_nz(_, BF(t, n), 0, n, @N, False{}) == (BF(t, n), False{}) : B.Buf & Bool}
      {==}
    case True{}:
      +e1 = VR.e1n(n, VR.pos1(n, ea))
      %Equal.sym(Bool, U32.is_lt(0, n), True{}, ea) : {O.bitlist_nz(_, BF(t, n), 0, n, @N, False{}) == (BF(t, n), chk1(True{}, t, n)) : B.Buf & Bool}
      %Equal.sym(B.Buf & U32, B.byte_at(BF(t, n), VR.XN(0, n)), (BF(t, n), V(t, n)),
          VR.byte_at_ok(d, t, n, VR.XN(0, n), VB.lt32(d, hd), hiN(d, n, hd, hn, e1), pf)) :
        {O.bitlist_pick(n, @N, False{}, _) == (BF(t, n), chk1(True{}, t, n)) : B.Buf & Bool}
      {==}

# The validator returns the buffer and CHK(t, n).
def ok_eval(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {T.@p_ok(BF(t, n), 0, n) == (BF(t, n), CHK(t, n)) : B.Buf & Bool}:
  okA(d, t, n, pf, hd, hn, U32.is_lt(0, n), {==})

def cA(+a: Bool, +t: FD.array__Tree<U32>, +n: U32, +h: {chk1(a, t, n) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case False{}: h
    case True{}: {==}

def bselF(+c: Bool, +y: Bool, +h: {O.bsel(c, False{}, y) == True{} : Bool}) -> {c == False{} : Bool}:
  match c:
    case True{}: Empty.absurd({True{} == False{} : Bool}, FD.logic__false_true(h))
    case False{}: {==}

def cB(+t: FD.array__Tree<U32>, +n: U32, +h: {chk1(True{}, t, n) == True{} : Bool}) -> {U32.is_eq(V(t, n), 0) == False{} : Bool}:
  bselF(U32.is_eq(V(t, n), 0), O.bsel(False{}, True{}, Nat.is_le(BD(t, n), U32.to_nat(@N))), h)

def cC(+t: FD.array__Tree<U32>, +n: U32, +h: {chk1(True{}, t, n) == True{} : Bool}, +nz: {U32.is_eq(V(t, n), 0) == False{} : Bool})
    -> {Nat.is_le(BD(t, n), U32.to_nat(@N)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {O.bsel(z, False{}, O.bsel(False{}, True{}, Nat.is_le(BD(t, n), U32.to_nat(@N)))) == True{} : Bool}, U32.is_eq(V(t, n), 0), False{}, nz, h)

def c1(+t: FD.array__Tree<U32>, +n: U32, +h: {CHK(t, n) == True{} : Bool}) -> {chk1(True{}, t, n) == True{} : Bool}:
  FD.logic__subst(Bool, z => {chk1(z, t, n) == True{} : Bool}, U32.is_lt(0, n), True{}, cA(U32.is_lt(0, n), t, n, h), h)

# n <= @BMAX: the checks bound the length.
def hB(+t: FD.array__Tree<U32>, +n: U32, +e1: {U32.to_nat(n) == 1n+M1(n) : Nat}, +bd: {Nat.is_le(BD(t, n), U32.to_nat(@N)) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(n), @BMAXn) == True{} : Bool}:
  +bd1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, U32.to_nat(O.high_bit(V(t, n)))), U32.to_nat(@N)) == True{} : Bool}, Nat.mul(8n, M1(n)), VS.x8(M1(n)), VR.mul8(M1(n)), bd)
  +h8 = FD.nat__le_trans(VS.x8(M1(n)), Nat.add(VS.x8(M1(n)), U32.to_nat(O.high_bit(V(t, n)))), Nat.add(VS.x8(@Cn), 7n), FD.nat__le_add_right(VS.x8(M1(n)), U32.to_nat(O.high_bit(V(t, n)))),
    FD.nat__le_trans(Nat.add(VS.x8(M1(n)), U32.to_nat(O.high_bit(V(t, n)))), U32.to_nat(@N), Nat.add(VS.x8(@Cn), 7n), bd1, {==}))
  %Equal.sym(Nat, U32.to_nat(n), 1n+M1(n), e1) : {Nat.is_le(_, @BMAXn) == True{} : Bool}
  VR.x8_inv(M1(n), @Cn, h8)

# 31 + n <= 2^@KB: the checks bound the length (whatever the buffer's depth).
def hyB(+n: U32, +hb: {Nat.is_le(U32.to_nat(n), @BMAXn) == True{} : Bool}) -> {Nat.is_le(VC.YL(n), VB.pw(@KBn)) == True{} : Bool}:
  FD.nat__le_trans(VC.YL(n), Nat.add(31n, @BMAXn), VB.pw(@KBn), Order.add_left(31n, U32.to_nat(n), @BMAXn, hb), {==})

def hWZ(+n: U32, +hb: {Nat.is_le(U32.to_nat(n), @BMAXn) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(VC.WZ(n)), O.pow2n(@Kn)) == True{} : Bool}:
  FD.nat__le_trans(U32.to_nat(VC.WZ(n)), Nat.add(VD.s_rng(2n, VC.YL(n)), 8n), O.pow2n(@Kn),
    VC.wz_le(n, @KBn, {==}, hyB(n, hb)),
    FD.nat__le_trans(Nat.add(VD.s_rng(2n, VC.YL(n)), 8n), Nat.add(VD.s_rng(2n, @YMAXn), 8n), O.pow2n(@Kn),
      Order.add_right(VD.s_rng(2n, VC.YL(n)), VD.s_rng(2n, @YMAXn), 8n, VC.rng_mono(2n, VC.YL(n), @YMAXn, Order.add_left(31n, U32.to_nat(n), @BMAXn, hb))),
      {==}))

# The decoder's storage depth is at most @K.
def hdzK(+d: Nat, +n: U32, +hd: {Nat.is_lt(d, 31n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +hb: {Nat.is_le(U32.to_nat(n), @BMAXn) == True{} : Bool}) -> {Nat.is_le(VL.DZ(n), @Kn) == True{} : Bool}:
  VD.wd_min(VC.WZ(n), @Kn, hWZ(n, hb))

# The list storage has room for the words.
def hrgB(+n: U32, +hb: {Nat.is_le(U32.to_nat(n), @BMAXn) == True{} : Bool}) -> {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(VL.DZ(n))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(VC.NW(n), 0n), VC.NW(n), FD.nat__add_zero(VC.NW(n))) : {Nat.is_le(_, VB.pw(VL.DZ(n))) == True{} : Bool}
  %Equal.sym(Nat, VB.pw(VL.DZ(n)), O.pow2n(VL.DZ(n)), VD.s_pow2_eq(VL.DZ(n))) : {Nat.is_le(VC.NW(n), _) == True{} : Bool}
  FD.nat__le_trans(VC.NW(n), U32.to_nat(VC.WZ(n)), O.pow2n(VL.DZ(n)), VC.nw_le_wz(n, @KBn, {==}, hyB(n, hb)), VD.wd_cover(VC.WZ(n), @Kn, {==}, hWZ(n, hb)))

@@ GBODY2 @@

def NBu(+t: FD.array__Tree<U32>, +n: U32) -> U32: U32.add(U32.mul(8, U32.sub(n, 1)), O.high_bit(V(t, n)))
def OBJ(+t: FD.array__Tree<U32>, +n: U32) -> O.Bits:
  O.Bits{O.clear_bit(O.mask_last(n, FD.array__thaw(U32, VL.MMg(t, n))), NBu(t, n)), NBu(t, n)}

def rd_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +e1: {U32.to_nat(n) == 1n+M1(n) : Nat},
    +hb: {Nat.is_le(U32.to_nat(n), @BMAXn) == True{} : Bool})
    -> {T.@p_read(BF(t, n), 0, n) == (BF(t, n), OBJ(t, n)) : B.Buf & O.Bits}:
  +hd31 = hd
  +hz = hdzK(d, n, hd, hn, hb)
  +ez = zeros_at(B.words_depth_u(VC.WZ(n)), VL.DZ(n), VD.wdu(VC.WZ(n)), hz)
  %Equal.sym(B.Buf & U32, B.byte_at(BF(t, n), VR.XN(0, n)), (BF(t, n), V(t, n)), VR.byte_at_ok(d, t, n, VR.XN(0, n), VB.lt32(d, hd31), hiN(d, n, hd, hn, e1), pf)) :
    {O.bits_from(n, 0, _) == (BF(t, n), OBJ(t, n)) : B.Buf & O.Bits}
  %Equal.sym(B.Buf & O.Words, O.copy_in(BF(t, n), 0, n), (BF(t, n), O.Words{O.mask_last(n, FD.array__thaw(U32, VL.MMg(t, n))), n}),
      VR.copy_in_ok2(d, t, n, 0, 0n, n, VL.DZ(n), pf, hd31, FD.nat__le_lt_trans(VL.DZ(n), @Kn, 31n, hz, {==}), ez, {==}, {==}, VR.nwleB(d, n, @KBn, {==}, hyB(n, hb), hn), hrgB(n, hb))) :
    {O.bits_clear(NBu(t, n), _) == (BF(t, n), OBJ(t, n)) : B.Buf & O.Bits}
  {==}

def acc_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {CHK(t, n) == True{} : Bool}, +h1: {chk1(True{}, t, n) == True{} : Bool})
    -> {T.@X_decode(BF(t, n), n) == (BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, O.Bits>}:
  +e1 = VR.e1n(n, VR.pos1(n, cA(U32.is_lt(0, n), t, n, hchk)))
  %Equal.sym(B.Buf & Bool, T.@p_ok(BF(t, n), 0, n), (BF(t, n), CHK(t, n)), ok_eval(d, t, n, pf, hd, hn)) :
    {T.@X_built(n, _) == (BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, O.Bits>}
  %Equal.sym(Bool, CHK(t, n), True{}, hchk) :
    {T.@X_built(n, (BF(t, n), _)) == (BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, O.Bits>}
  %Equal.sym(B.Buf & O.Bits, T.@p_read(BF(t, n), 0, n), (BF(t, n), OBJ(t, n)), rd_go(d, t, n, pf, hd, hn, e1, hB(t, n, e1, cC(t, n, h1, cB(t, n, h1))))) :
    {T.@X_some(_) == (BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, O.Bits>}
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
  {T.@X_decode(BF(t, n), n) == (BF(t, n), Some{OBJ(t, n)}) : B.Buf & Maybe<&1, O.Bits>}
def decode_accept(d, t, n, pf, hd, hn, hchk):
  acc_go(d, t, n, pf, hd, hn, hchk, c1(t, n, hchk))

# When the validator refuses, the decoder returns None and the buffer.
law decode_none:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == False{} : Bool}
  {T.@X_decode(BF(t, n), n) == (BF(t, n), None{}) : B.Buf & Maybe<&1, O.Bits>}
def decode_none(d, t, n, pf, hd, hn, hchk):
  %Equal.sym(B.Buf & Bool, T.@p_ok(BF(t, n), 0, n), (BF(t, n), CHK(t, n)), ok_eval(d, t, n, pf, hd, hn)) :
    {T.@X_built(n, _) == (BF(t, n), None{}) : B.Buf & Maybe<&1, O.Bits>}
  %Equal.sym(Bool, CHK(t, n), False{}, hchk) :
    {T.@X_built(n, (BF(t, n), _)) == (BF(t, n), None{}) : B.Buf & Maybe<&1, O.Bits>}
  {==}

# ---- the spec side ----------------------------------------------------------------------------

def VAL(+t: FD.array__Tree<U32>, +n: U32) -> S.Value: S.BitsValue{VBL.bl(VW(t, n))}

def hw1(+d: Nat, +n: U32, +m: Nat, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +e1: {U32.to_nat(n) == 1n+m : Nat})
    -> {Nat.is_le(Nat.add(A.quad(0n), 1n+m), A.quad(VB.pw(d))) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(n), 1n+m, e1, hn)

def spec_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +e1: {U32.to_nat(n) == 1n+M1(n) : Nat},
    +nz: {U32.is_eq(V(t, n), 0) == False{} : Bool}, +bd: {Nat.is_le(BD(t, n), U32.to_nat(@N)) == True{} : Bool})
    -> Decoding.decodes(GS.@X(), VW(t, n), VAL(t, n)):
  +m = M1(n)
  +W1 = VR.WB(t, 0n, 1n+m)
  +lw = VR.lastWB(d, t, 0n, m, VR.XN(0, n), pf, hw1(d, n, m, hn, e1), VR.eXN0(n, m, e1))
  +nzl = FD.logic__subst(U32, z => {U32.is_eq(z, 0) == False{} : Bool}, V(t, n), VBL.lastb(W1), Equal.sym(U32, VBL.lastb(W1), V(t, n), lw), nz)
  +dom = VR.domWB(t, 0n, 1n+m)
  +len = Equal.trans(Nat, List.length(&2, Bool, VBL.bl(W1)), VBL.blen(W1), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, n)))), VBL.bl_len(W1, dom, nzl),
    Equal.trans(Nat, VBL.blen(W1), Nat.add(VS.x8(m), VY.hb(VBL.lastb(W1))), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, n)))),
      VR.blen_m(W1, m, VR.lenWB(d, t, 0n, 1n+m, pf, hw1(d, n, m, hn, e1))),
      Equal.cong(U32, Nat, z => Nat.add(VS.x8(m), VY.hb(z)), VBL.lastb(W1), V(t, n), lw)))
  +bd1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, U32.to_nat(O.high_bit(V(t, n)))), U32.to_nat(@N)) == True{} : Bool}, Nat.mul(8n, m), VS.x8(m), VR.mul8(m), bd)
  +bdx = FD.logic__subst(Nat, z => {Nat.is_le(z, @Nn) == True{} : Bool}, Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, n)))), List.length(&2, Bool, VBL.bl(W1)),
    Equal.sym(Nat, List.length(&2, Bool, VBL.bl(W1)), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(V(t, n)))), len), bd1)
  %Equal.sym(Nat, U32.to_nat(n), 1n+m, e1) :
    {Codec.encoding_for_legal_type(GS.@X(), S.BitsValue{VBL.bl(VR.WB(t, 0n, _))}) == Some{VR.WB(t, 0n, _)} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, Nat.is_le(List.length(&2, Bool, VBL.bl(W1)), @Nn), True{}, bdx) :
    {Codec.bytes(Codec.one(Bits.encoding(_, List.append(&2, Bool, VBL.bl(W1), [True{}])), None{})) == Some{W1} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, Bp.pack(List.append(&2, Bool, VBL.bl(W1), [True{}])), W1, VBL.bl_pack(W1, dom, nzl)) :
    {Codec.bytes(Codec.one(Some{_}, None{})) == Some{W1} : Maybe<&2, +List<U32>>}
  {==}

# The bytes of every buffer the validator accepts are the spec encoding of
# VAL(t, n): their bits cut before the last byte's highest set bit.
law decode_spec:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == True{} : Bool}
  Decoding.decodes(GS.@X(), VW(t, n), VAL(t, n))
def decode_spec(d, t, n, pf, hd, hn, hchk):
  +h1 = c1(t, n, hchk)
  +nz = cB(t, n, h1)
  spec_go(d, t, n, pf, hd, hn, VR.e1n(n, VR.pos1(n, cA(U32.is_lt(0, n), t, n, hchk))), nz, cC(t, n, h1, nz))

@@ gbits_unique @@
import Base
import ../../types/schema.bend as S
import ../../spec/decoding_relation.bend as Decoding
import ../compact/found.bend as FD
import ../compact/arith.bend as A
import ./vbuf.bend as VB
import ./generic_specs.bend as GS
import ./var_bits_${X}.bend as DC
import ../../proofs/decode_unique.bend as DCO

# GENERATED by var_bits (codegen). Do not edit.
# Every spec value of an accepted buffer's bytes is VAL(t, n).
law decode_unique:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {DC.CHK(t, n) == True{} : Bool}
  for +v: S.Value
  for spec: Decoding.decodes(GS.${X}(), DC.VW(t, n), v)
  {v == DC.VAL(t, n) : S.Value}
def decode_unique(d, t, n, pf, hd, hn, hchk, v, spec):
  DCO.valid_unique(GS.${X}(), DC.VW(t, n), v, DC.VAL(t, n), {==}, spec, DC.decode_spec(d, t, n, pf, hd, hn, hchk))

@@ GREJ @@

def CTXT() -> Unit: Unit{}

def lenVW(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {List.length(&2, U32, DC.VW(t, n)) == U32.to_nat(n) : Nat}:
  VR.lenWB(d, t, 0n, U32.to_nat(n), pf, hn)

def m1e(+n: U32, +m: Nat, +e1: {U32.to_nat(n) == 1n+m : Nat}) -> {DC.M1(n) == m : Nat}:
  +h1 = FD.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, 1n+m, U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), 1n+m, e1), FD.nat__zero_le(m))
  %Equal.sym(Nat, DC.M1(n), Nat.sub(U32.to_nat(n), 1n), FD.u32__sub_nat(n, 1, h1)) : {_ == m : Nat}
  %Equal.sym(Nat, U32.to_nat(n), 1n+m, e1) : {Nat.sub(_, 1n) == m : Nat}
  FD.nat__add_sub_cancel(1n, m)

# The shape makes every check pass.
def chk_true(+t: FD.array__Tree<U32>, +n: U32, +m: Nat, +e1: {U32.to_nat(n) == 1n+m : Nat},
    +nz: {U32.is_eq(DC.V(t, n), 0) == False{} : Bool}, +bd: {Nat.is_le(DC.BD(t, n), U32.to_nat(@N)) == True{} : Bool})
    -> {DC.CHK(t, n) == True{} : Bool}:
  +ea = FD.logic__subst(Nat, z => {Nat.is_lt(0n, z) == True{} : Bool}, 1n+m, U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), 1n+m, e1), {==})
  %Equal.sym(Bool, U32.is_lt(0, n), True{}, FD.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_lt(0n, U32.to_nat(n)), U32.is_lt(0, n), Equal.sym(Bool, U32.is_lt(0, n), Nat.is_lt(0n, U32.to_nat(n)), VR.lt_u32(0, n)), ea)) :
    {DC.chk1(_, t, n) == True{} : Bool}
  %Equal.sym(Bool, U32.is_eq(DC.V(t, n), 0), False{}, nz) : {O.bsel(_, False{}, O.bsel(False{}, True{}, Nat.is_le(DC.BD(t, n), U32.to_nat(@N)))) == True{} : Bool}
  bd

def rej_t(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {DC.CHK(t, n) == False{} : Bool},
    +bits: +List<Bool>, +hb: {Nat.is_le(List.length(&2, Bool, bits), @Nn) == True{} : Bool}, +pk: {VBL.P(bits) == DC.VW(t, n) : +List<U32>}, +fs: VBL.IF(bits)) -> Empty:
  (+l, +r) = fs
  (+nz0, +ln) = r
  +m = VBL.mcnt(bits)
  +e1 = Equal.trans(Nat, U32.to_nat(n), List.length(&2, U32, DC.VW(t, n)), 1n+m, Equal.sym(Nat, List.length(&2, U32, DC.VW(t, n)), U32.to_nat(n), lenVW(d, t, n, pf, hn)),
    Equal.trans(Nat, List.length(&2, U32, DC.VW(t, n)), List.length(&2, U32, VBL.P(bits)), 1n+m,
      Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), DC.VW(t, n), VBL.P(bits), Equal.sym(+List<U32>, VBL.P(bits), DC.VW(t, n), pk)), l))
  +W1 = VR.WB(t, 0n, 1n+m)
  +lw = VR.lastWB(d, t, 0n, m, VR.XN(0, n), pf, DC.hw1(d, n, m, hn, e1), VR.eXN0(n, m, e1))
  # the byte at m of the encoding is the runtime's last byte
  +eW = Equal.cong(Nat, +List<U32>, z => VR.WB(t, 0n, z), U32.to_nat(n), 1n+m, e1)
  +eV = Equal.trans(U32, VBL.nthb(VBL.P(bits), m), VBL.nthb(W1, m), DC.V(t, n),
    Equal.cong(+List<U32>, U32, z => VBL.nthb(z, m), VBL.P(bits), W1, Equal.trans(+List<U32>, VBL.P(bits), DC.VW(t, n), W1, pk, eW)),
    Equal.trans(U32, VBL.nthb(W1, m), VBL.lastb(W1), DC.V(t, n), Equal.sym(U32, VBL.lastb(W1), VBL.nthb(W1, m), VR.last_len(W1, m, VR.lenWB(d, t, 0n, 1n+m, pf, DC.hw1(d, n, m, hn, e1)))), lw))
  +nz = FD.logic__subst(U32, z => {U32.is_eq(z, 0) == False{} : Bool}, VBL.nthb(VBL.P(bits), m), DC.V(t, n), eV, nz0)
  # the bit count is 8 m + the high bit, within @N
  +lnV = Equal.trans(Nat, List.length(&2, Bool, bits), Nat.add(VS.x8(m), VY.hb(VBL.nthb(VBL.P(bits), m))), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(DC.V(t, n)))), ln,
    Equal.cong(U32, Nat, z => Nat.add(VS.x8(m), VY.hb(z)), VBL.nthb(VBL.P(bits), m), DC.V(t, n), eV))
  +eBD = Equal.trans(Nat, DC.BD(t, n), Nat.add(VS.x8(DC.M1(n)), U32.to_nat(O.high_bit(DC.V(t, n)))), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(DC.V(t, n)))),
    Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(O.high_bit(DC.V(t, n)))), Nat.mul(8n, DC.M1(n)), VS.x8(DC.M1(n)), VR.mul8(DC.M1(n))),
    Equal.cong(Nat, Nat, z => Nat.add(VS.x8(z), U32.to_nat(O.high_bit(DC.V(t, n)))), DC.M1(n), m, m1e(n, m, e1)))
  +bd = FD.logic__subst(Nat, z => {Nat.is_le(z, @Nn) == True{} : Bool}, List.length(&2, Bool, bits), DC.BD(t, n),
    Equal.trans(Nat, List.length(&2, Bool, bits), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(DC.V(t, n)))), DC.BD(t, n), lnV, Equal.sym(Nat, DC.BD(t, n), Nat.add(VS.x8(m), U32.to_nat(O.high_bit(DC.V(t, n)))), eBD)), hb)
  FD.logic__true_false(Equal.trans(Bool, True{}, DC.CHK(t, n), False{}, Equal.sym(Bool, DC.CHK(t, n), True{}, chk_true(t, n, m, e1, nz, bd)), hchk))

def rej_b(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {DC.CHK(t, n) == False{} : Bool},
    +bits: +List<Bool>, +b: Bool, +eb: {Nat.is_le(List.length(&2, Bool, bits), @Nn) == b : Bool},
    +e: {Codec.bytes(Codec.one(Bits.encoding(b, List.append(&2, Bool, bits, [True{}])), None{})) == Some{DC.VW(t, n)} : Maybe<&2, +List<U32>>}) -> Empty:
  match b:
    case False{}: FD.logic__none_some(+List<U32>, DC.VW(t, n), e)
    case True{}: rej_t(d, t, n, pf, hd, hn, hchk, bits, eb, FD.logic__some_inj(+List<U32>, VBL.P(bits), DC.VW(t, n), e), VBL.inv(bits))

def inv_v(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {DC.CHK(t, n) == False{} : Bool},
    +v: S.Value, +e: {Codec.encoding_for_legal_type(GS.@X(), v) == Some{DC.VW(t, n)} : Maybe<&2, +List<U32>>}) -> Empty:
  match v:
    case S.BitsValue{+bits}: rej_b(d, t, n, pf, hd, hn, hchk, bits, Nat.is_le(List.length(&2, Bool, bits), @Nn), {==}, e)
    case S.BooleanValue{+b0}: FD.logic__none_some(+List<U32>, DC.VW(t, n), e)
    case S.UnsignedValue{+u0}: FD.logic__none_some(+List<U32>, DC.VW(t, n), e)
    case S.BytesValue{+xs0}: FD.logic__none_some(+List<U32>, DC.VW(t, n), e)
    case S.Sequence{+it0}: FD.logic__none_some(+List<U32>, DC.VW(t, n), e)
    case S.Items{+hd0, +tl0}: FD.logic__none_some(+List<U32>, DC.VW(t, n), e)
    case S.EmptyItems{}: FD.logic__none_some(+List<U32>, DC.VW(t, n), e)
    case S.Selected{+sel0, +sv0}: FD.logic__none_some(+List<U32>, DC.VW(t, n), e)
    case S.NullValue{}: FD.logic__none_some(+List<U32>, DC.VW(t, n), e)

# When the validator refuses, no value is related to the buffer's bytes.
law decode_reject:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {DC.CHK(t, n) == False{} : Bool}
  Decoding.outside_image(GS.@X(), DC.VW(t, n))
def decode_reject(d, t, n, pf, hd, hn, hchk):
  v => e => inv_v(d, t, n, pf, hd, hn, hchk, v, e)

@@ byte_module_lines @@
law ${name}:
  for +w: Word(8n)
  for +nz: {U32.is_eq(PD.embed8(w), 0) == False{} : Bool}
  ${stmt('PD.embed8(w)', 'w')}
def ${name}(w, nz):
  match w:
    case ${PAT}: ${name}_7(c0, c1, c2, c3, c4, c5, c6, c7, nz)

@@ byte_module_lines_2 @@
  %Equal.sym(U32, ${oct}, ${E}, BLf.oct8(${', '.join(hk(k))})) :
    DK.P2({U32.is_eq(_, 0) == False{} : Bool}, {${k}n == hb(_) : Nat})
  ({==}, hb${k}(${', '.join(bs)}))