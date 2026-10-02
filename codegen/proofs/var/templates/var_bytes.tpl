@@ win_text @@
def chk3(a: Bool, b: Bool, c: Bool) -> Bool:
  match a:
    case False{}: False{}
    case True{}:
      match b:
        case False{}: False{}
        case True{}: c

def chk_a(+a: Bool, +b: Bool, +c: Bool, +h: {chk3(a, b, c) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case False{}: h
    case True{}: {==}

def chk_b(+a: Bool, +b: Bool, +c: Bool, +h: {chk3(a, b, c) == True{} : Bool}) -> {b == True{} : Bool}:
  match a b:
    case False{} _: Empty.absurd({b == True{} : Bool}, FD.logic__false_true(h))
    case True{} False{}: h
    case True{} True{}: {==}

def chk_c(+a: Bool, +b: Bool, +c: Bool, +h: {chk3(a, b, c) == True{} : Bool}) -> {c == True{} : Bool}:
  match a b:
    case False{} _: Empty.absurd({c == True{} : Bool}, FD.logic__false_true(h))
    case True{} False{}: Empty.absurd({c == True{} : Bool}, FD.logic__false_true(h))
    case True{} True{}: h

# The byte list's check: its length is at most the limit.
def BLW(+L: U32) -> Bool: U32.is_le(L, ${LIM})
def LL(+len: U32) -> U32: U32.sub(len, ${FS})
def SPOw(t: FD.array__Tree<U32>, +i: Nat) -> U32: VB.slot(t, Nat.add(${po}n, i))

def CHKw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> Bool:
  chk3(U32.is_le(${FS}, len), U32.is_eq(SPOw(t, i), ${FS}), BLW(U32.sub(len, SPOw(t, i))))

def c1_id(+ok: Bool, buf: B.Buf, +off: U32, +len: U32, +o0: U32) -> {${Tn}_c1(ok, buf, off, len, o0) == (buf, ok) : B.Buf & Bool}:
  match ok:
    case True{}: {==}
    case False{}: {==}

def leFS(+len: U32, ${HA}) -> {Nat.is_le(${FS}n, U32.to_nat(len)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(${FS}, len), Nat.is_le(${FS}n, U32.to_nat(len)), VU.le_u32(${FS}, len), ha)

def enFS(+len: U32, ${HA}) -> {Nat.add(${FS}n, U32.to_nat(LL(len))) == U32.to_nat(len) : Nat}:
  %Equal.sym(Nat, U32.to_nat(LL(len)), Nat.sub(U32.to_nat(len), ${FS}n), FD.u32__sub_nat(len, ${FS}, leFS(len, ha))) : {Nat.add(${FS}n, _) == U32.to_nat(len) : Nat}
  FD.nat__sub_add(U32.to_nat(len), ${FS}n, leFS(len, ha))

def winb(+k: Nat, +i: Nat, +len: U32, +P: Nat, +hk: {Nat.is_le(A.quad(k), U32.to_nat(len)) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), P) == True{} : Bool}) -> {Nat.is_le(A.quad(Nat.add(k, i)), P) == True{} : Bool}:
  %VF.quad_add(k, i) : {Nat.is_le(_, P) == True{} : Bool}
  FD.nat__le_trans(Nat.add(A.quad(k), A.quad(i)), Nat.add(U32.to_nat(len), A.quad(i)), P, Order.add_right(A.quad(k), U32.to_nat(len), A.quad(i), hk),
    FD.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, Nat.add(A.quad(i), U32.to_nat(len)), Nat.add(U32.to_nat(len), A.quad(i)), FD.nat__add_comm(A.quad(i), U32.to_nat(len)), hw))

# The byte offset off + c of header byte c = 4 k (k <= H) is word k + i.
def eoc(+d: Nat, +i: Nat, +off: U32, +len: U32, +k: Nat, +c: U32, +ec: {U32.to_nat(c) == A.quad(k) : Nat},
    +hkF: {Nat.is_le(A.quad(k), ${FS}n) == True{} : Bool}, ${WH}, ${HA})
    -> {U32.to_nat(U32.add(off, c)) == A.quad(Nat.add(k, i)) : Nat}:
  VF.off_add(off, c, i, k, 2n+d, eo, ec, hd,
    winb(k, i, len, A.quad(VB.pw(d)), FD.nat__le_trans(A.quad(k), ${FS}n, U32.to_nat(len), hkF, leFS(len, ha)), hw))

# Header words k < H of the window are below 2^d.
def hiw(+d: Nat, +i: Nat, +len: U32, +k: Nat, +hk: {Nat.is_lt(k, ${H}n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, ${HA})
    -> {Nat.is_lt(Nat.add(k, i), VB.pw(d)) == True{} : Bool}:
  FD.nat__lt_le_trans(Nat.add(k, i), Nat.add(${H}n, i), VB.pw(d), VB.lt_kk(k, ${H}n, i, hk),
    VC.quad_inv(Nat.add(${H}n, i), VB.pw(d), winb(${H}n, i, len, A.quad(VB.pw(d)), leFS(len, ha), hw)))

def okw_c0(+t: FD.array__Tree<U32>, +n: U32, +off: U32, +len: U32, +i: Nat, +b: Bool)
    -> {${Tn}_c0(b, VF.BF(t, n), off, len, SPOw(t, i)) == (VF.BF(t, n), chk3(True{}, b, BLW(U32.sub(len, SPOw(t, i))))) : B.Buf & Bool}:
  match b:
    case False{}: {==}
    case True{}: c1_id(BLW(U32.sub(len, SPOw(t, i))), VF.BF(t, n), off, len, SPOw(t, i))

def okw_len(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, ${WH}, ${PF},
    +a: Bool, +ea: {U32.is_le(${FS}, len) == a : Bool})
    -> {${Tn}_ok_len(a, VF.BF(t, n), off, len) == (VF.BF(t, n), chk3(a, U32.is_eq(SPOw(t, i), ${FS}), BLW(U32.sub(len, SPOw(t, i))))) : B.Buf & Bool}:
  match a:
    case False{}: {==}
    case True{}:
      %Equal.sym(B.Buf & U32, B.read32(VF.BF(t, n), U32.add(off, ${cvar})), (VF.BF(t, n), SPOw(t, i)),
          VF.rd32a(d, t, n, U32.add(off, ${cvar}), Nat.add(${po}n, i), eoc(d, i, off, len, ${po}n, ${cvar}, {==}, {==}, eo, hd, hw, ea),
            VB.lt32(d, FD.nat__lt_trans(d, 29n, 31n, hd, {==})), hiw(d, i, len, ${po}n, {==}, hw, ea), pf)) :
        {${Tn}_v0(off, len, _) == (VF.BF(t, n), chk3(True{}, U32.is_eq(SPOw(t, i), ${FS}), BLW(U32.sub(len, SPOw(t, i))))) : B.Buf & Bool}
      okw_c0(t, n, off, len, i, U32.is_eq(SPOw(t, i), ${FS}))

# The validator on the window returns the buffer and CHKw(t, i, len).
def ok_evalw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, ${WH}, ${PF})
    -> {${Tn}_ok(VF.BF(t, n), off, len) == (VF.BF(t, n), CHKw(t, i, len)) : B.Buf & Bool}:
  okw_len(d, t, n, i, off, len, eo, hd, hw, pf, U32.is_le(${FS}, len), {==})

# ---- the byte list's bounds --------------------------------------------------------------------

def hLx(+len: U32, ${HX}) -> {Nat.is_le(U32.to_nat(LL(len)), ${LIM}n) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(LL(len), ${LIM}), Nat.is_le(U32.to_nat(LL(len)), U32.to_nat(${LIM})), VU.le_u32(LL(len), ${LIM}), hx)

def hyL(+len: U32, ${HX}) -> {Nat.is_le(VC.YL(LL(len)), VB.pw(${KY}n)) == True{} : Bool}:
  FD.nat__le_trans(VC.YL(LL(len)), ${31 + LIM}n, VB.pw(${KY}n), hLx(len, hx), {==})

# The byte list's words lie in the buffer: NW + H + i <= 2^d.
def hsw(+d: Nat, +i: Nat, +len: U32, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, ${HA}, ${HX})
    -> {Nat.is_le(Nat.add(VC.NW(LL(len)), Nat.add(${H}n, i)), VB.pw(d)) == True{} : Bool}:
  +e1 = Equal.cong(Nat, Nat, z => Nat.add(A.quad(i), z), U32.to_nat(len), Nat.add(${FS}n, U32.to_nat(LL(len))), Equal.sym(Nat, Nat.add(${FS}n, U32.to_nat(LL(len))), U32.to_nat(len), enFS(len, ha)))
  +e2 = Equal.sym(Nat, Nat.add(Nat.add(A.quad(i), ${FS}n), U32.to_nat(LL(len))), Nat.add(A.quad(i), Nat.add(${FS}n, U32.to_nat(LL(len)))), FD.nat__add_assoc(A.quad(i), ${FS}n, U32.to_nat(LL(len))))
  +e3 = Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(LL(len))), Nat.add(A.quad(i), ${FS}n), Nat.add(${FS}n, A.quad(i)), FD.nat__add_comm(A.quad(i), ${FS}n))
  +e = Equal.trans(Nat, Nat.add(A.quad(i), U32.to_nat(len)), Nat.add(A.quad(i), Nat.add(${FS}n, U32.to_nat(LL(len)))), Nat.add(A.quad(Nat.add(${H}n, i)), U32.to_nat(LL(len))), e1,
    Equal.trans(Nat, Nat.add(A.quad(i), Nat.add(${FS}n, U32.to_nat(LL(len)))), Nat.add(Nat.add(A.quad(i), ${FS}n), U32.to_nat(LL(len))), Nat.add(A.quad(Nat.add(${H}n, i)), U32.to_nat(LL(len))), e2, e3))
  VY.nw_room(Nat.add(${H}n, i), LL(len), VB.pw(d), ${KY}n, {==}, hyL(len, hx),
    FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, Nat.add(A.quad(i), U32.to_nat(len)), Nat.add(A.quad(Nat.add(${H}n, i)), U32.to_nat(LL(len))), e, hw))

def hHi(+d: Nat, +i: Nat, +len: U32, +hs: {Nat.is_le(Nat.add(VC.NW(LL(len)), Nat.add(${H}n, i)), VB.pw(d)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(${H}n, i), VB.pw(d)) == True{} : Bool}:
  FD.nat__le_trans(Nat.add(${H}n, i), Nat.add(VC.NW(LL(len)), Nat.add(${H}n, i)), VB.pw(d), Order.left_below_sum(VC.NW(LL(len)), Nat.add(${H}n, i)), hs)

# The storage of the byte list: depth DZ <= ${KZ}.
def DZ(+len: U32) -> Nat: B.words_depth(VC.WZ(LL(len)))

def d3m(+a: Nat, +b: Nat, +h: {Nat.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(VB.d3(a), VB.d3(b)) == True{} : Bool}:
  Order.double_monotone(Nat.double(Nat.double(a)), Nat.double(Nat.double(b)), Order.double_monotone(Nat.double(a), Nat.double(b), Order.double_monotone(a, b, h)))

def hWZ(+len: U32, ${HX}) -> {Nat.is_le(U32.to_nat(VC.WZ(LL(len))), O.pow2n(${KZ}n)) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(VC.WZ(LL(len))), Nat.add(VB.d3(VD.s_rng(5n, VC.YL(LL(len)))), 8n), VC.eWZ(LL(len), ${KY}n, {==}, hyL(len, hx))) :
    {Nat.is_le(_, O.pow2n(${KZ}n)) == True{} : Bool}
  FD.nat__le_trans(Nat.add(VB.d3(VD.s_rng(5n, VC.YL(LL(len)))), 8n), Nat.add(VB.d3(${x.R5}n), 8n), O.pow2n(${KZ}n),
    Order.add_right(VB.d3(VD.s_rng(5n, VC.YL(LL(len)))), VB.d3(${x.R5}n), 8n, d3m(VD.s_rng(5n, VC.YL(LL(len))), ${x.R5}n, VC.rng_mono(5n, VC.YL(LL(len)), ${31 + LIM}n, hLx(len, hx)))),
    {==})

def hdz(+len: U32, ${HX}) -> {Nat.is_le(DZ(len), ${KZ}n) == True{} : Bool}:
  VD.wd_min(VC.WZ(LL(len)), ${KZ}n, hWZ(len, hx))

def hdz31(+len: U32, ${HX}) -> {Nat.is_lt(DZ(len), 31n) == True{} : Bool}:
  FD.nat__le_lt_trans(DZ(len), ${KZ}n, 31n, hdz(len, hx), {==})

@@ win_text_ez @@

def ez(+len: U32, ${HX}) -> {B.zeros(B.words_depth_u(VC.WZ(LL(len)))) == Array.new(U32, DZ(len), 0) : Array<U32>}:
  zeros_at(B.words_depth_u(VC.WZ(LL(len))), DZ(len), VD.wdu(VC.WZ(LL(len))), hdz(len, hx))

def hr(+len: U32, ${HX}) -> {Nat.is_le(Nat.add(VC.NW(LL(len)), 0n), VB.pw(DZ(len))) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(VC.NW(LL(len)), 0n), VC.NW(LL(len)), FD.nat__add_zero(VC.NW(LL(len)))) : {Nat.is_le(_, VB.pw(DZ(len))) == True{} : Bool}
  %Equal.sym(Nat, VB.pw(DZ(len)), O.pow2n(DZ(len)), VD.s_pow2_eq(DZ(len))) : {Nat.is_le(VC.NW(LL(len)), _) == True{} : Bool}
  FD.nat__le_trans(VC.NW(LL(len)), U32.to_nat(VC.WZ(LL(len))), O.pow2n(DZ(len)),
    VC.nw_le_wz(LL(len), ${KY}n, {==}, hyL(len, hx)),
    VD.wd_cover(VC.WZ(LL(len)), ${KZ}n, {==}, hWZ(len, hx)))

# The byte list's storage: the masked copy of its words.
def MKw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> FD.array__Tree<U32>:
  VY.MK(LL(len), DZ(len), VB.mone(VC.NW(LL(len)), Nat.add(${H}n, i), 0n, DZ(len), VC.ZT(DZ(len)), t))

# The offset word, once checked, reads as ${FS}.
def rdo(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, ${WH}, ${PF}, ${HA}, +epo: {SPOw(t, i) == ${FS} : U32})
    -> {B.read32(VF.BF(t, n), U32.add(off, ${cvar})) == (VF.BF(t, n), ${FS}) : B.Buf & U32}:
  %Equal.sym(B.Buf & U32, B.read32(VF.BF(t, n), U32.add(off, ${cvar})), (VF.BF(t, n), SPOw(t, i)),
      VF.rd32a(d, t, n, U32.add(off, ${cvar}), Nat.add(${po}n, i), eoc(d, i, off, len, ${po}n, ${cvar}, {==}, {==}, eo, hd, hw, ha),
        VB.lt32(d, FD.nat__lt_trans(d, 29n, 31n, hd, {==})), hiw(d, i, len, ${po}n, {==}, hw, ha), pf)) :
    {_ == (VF.BF(t, n), ${FS}) : B.Buf & U32}
  %Equal.sym(U32, SPOw(t, i), ${FS}, epo) : {(VF.BF(t, n), _) == (VF.BF(t, n), ${FS}) : B.Buf & U32}
  {==}

@@ win_text_readw @@

# When the window's checks hold, the reader returns OBJw(t, i, len).
def readw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, ${WH}, ${PF},
    +hchk: {CHKw(t, i, len) == True{} : Bool})
    -> {${Tn}_read(VF.BF(t, n), off, len) == (VF.BF(t, n), OBJw(t, i, len)) : ${TY}}:
  +a = U32.is_le(${FS}, len)
  +b = U32.is_eq(SPOw(t, i), ${FS})
  +c = BLW(U32.sub(len, SPOw(t, i)))
  +epo = FD.u32alg__eq_of(SPOw(t, i), ${FS}, chk_b(a, b, c, hchk))
  rdw_go(d, t, n, i, off, len, eo, hd, hw, pf, chk_a(a, b, c, hchk), epo,
    FD.logic__subst(U32, z => {BLW(U32.sub(len, z)) == True{} : Bool}, SPOw(t, i), ${FS}, epo, chk_c(a, b, c, hchk)))

@@ spec_part @@

# ---- the spec side -------------------------------------------------------------------------

# The value of the window's fixed words and byte list Y.
def XVw(+t: FD.array__Tree<U32>, +i: Nat, +Y: +List<U32>) -> S.Value: S.Sequence{${ITEMS}}

# Its spec parts: one variable part, the header's bytes (the offset is ${FS}) and Y.
def encpw(+t: FD.array__Tree<U32>, +i: Nat, +Y: +List<U32>, +hdom: {SP.bytes_domain(Y) == True{} : Bool},
    +hlen: {Nat.is_le(List.length(&2, U32, Y), ${LIM}n) == True{} : Bool})
    -> {Codec.parts(XVw(t, i, Y), Spec.${n}()) == Some{[S.Variable{${ENC}}]} : ${MP}}:
  +fit = VS.fits_mono(4n, Nat.add(VS.FSZ(${PRE}, ${POST}), List.length(&2, U32, Y)), Nat.add(${FS}n, ${LIM}n),
    Order.add_left(${FS}n, List.length(&2, U32, Y), ${LIM}n, hlen), {==})
  %Equal.sym(${MP}, Codec.parts(${ITEMS}, ${CHAIN}), Some{${PL}},
      ${CAT}) :
    {Codec.aggregate(_, None{}) == Some{[S.Variable{${ENC}}]} : ${MP}}
  %Equal.sym(${M}, Layout.encoding(VS.fpv(${PRE}, Y, ${POST})), Some{${ENCR}}, VZ.enc_fpvb(${PRE}, Y, ${POST}, hdom, fit)) :
    {Codec.one(_, None{}) == Some{[S.Variable{${ENC}}]} : ${MP}}
  {==}

# The byte list's value: the first LL(len) bytes of its storage.
def YB(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> +List<U32>: VS.bt(U32.to_nat(LL(len)), F.limbs(FD.array__slots(U32, MKw(t, i, len))))
def VALw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> S.Value: XVw(t, i, YB(t, i, len))

def len_yb(+t: FD.array__Tree<U32>, +i: Nat, +len: U32, ${HX}) -> {Nat.is_le(List.length(&2, U32, ${YB}), ${LIM}n) == True{} : Bool}:
  FD.nat__le_trans(List.length(&2, U32, ${YB}), U32.to_nat(LL(len)), ${LIM}n, VZ.bt_len_le(U32.to_nat(LL(len)), F.limbs(FD.array__slots(U32, MKw(t, i, len)))), hLx(len, hx))

# Those bytes are the window's bytes.
def bytesw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +len: U32, ${PF}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, ${HA}, +epo: {SPOw(t, i) == ${FS} : U32}, ${HX})
    -> {List.append(&2, U32, F.limbs(${HDR}), ${YB}) == ${WIN} : +List<U32>}:
  +hs = hsw(d, i, len, hw, ha, hx)
  +hsl = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(VC.NW(LL(len)), Nat.add(${H}n, i)), z) == True{} : Bool}, VB.pw(d), VB.len(${s}), Equal.sym(Nat, VB.len(${s}), VB.pw(d), FD.array__slots_length(U32, d, t, pf)), hs)
  +hpre = FD.nat__le_trans(Nat.add(${H}n, i), Nat.add(VC.NW(LL(len)), Nat.add(${H}n, i)), VB.len(${s}), Order.left_below_sum(VC.NW(LL(len)), Nat.add(${H}n, i)), hsl)
  %enFS(len, ha) : {List.append(&2, U32, F.limbs(${HDR}), ${YB}) == VS.bt(_, F.limbs(VB.wdr(i, ${s}))) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(Nat.add(A.quad(${H}n), U32.to_nat(LL(len))), F.limbs(VB.wdr(i, ${s}))),
      List.append(&2, U32, F.limbs(VS.wtake(${H}n, VB.wdr(i, ${s}))), VS.bt(U32.to_nat(LL(len)), F.limbs(VB.wdr(${H}n, VB.wdr(i, ${s}))))),
      VY.bt_split(${H}n, U32.to_nat(LL(len)), VB.wdr(i, ${s}), VZ.wdr_len_le(${H}n, i, ${s}, hpre))) :
    {List.append(&2, U32, F.limbs(${HDR}), ${YB}) == _ : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(Nat.add(${H}n, 0n), VB.wdr(i, ${s})), VF.app(VF.wpre(${H}n, i, ${s}), VS.wtake(0n, VB.wdr(Nat.add(${H}n, i), ${s}))),
      VF.wt_pre(${H}n, 0n, i, ${s}, hpre)) :
    {List.append(&2, U32, F.limbs(${HDR}), ${YB}) == List.append(&2, U32, F.limbs(_), VS.bt(U32.to_nat(LL(len)), F.limbs(VB.wdr(${H}n, VB.wdr(i, ${s}))))) : +List<U32>}
  %Equal.sym(List<&2, U32>, VB.wdr(${H}n, VB.wdr(i, ${s})), VB.wdr(Nat.add(i, ${H}n), ${s}), VF.wdr_add(${H}n, i, ${s})) :
    {List.append(&2, U32, F.limbs(${HDR}), ${YB}) == List.append(&2, U32, F.limbs(${hdrs}), VS.bt(U32.to_nat(LL(len)), F.limbs(_))) : +List<U32>}
  %Equal.sym(Nat, Nat.add(i, ${H}n), Nat.add(${H}n, i), FD.nat__add_comm(i, ${H}n)) :
    {List.append(&2, U32, F.limbs(${HDR}), ${YB}) == List.append(&2, U32, F.limbs(${hdrs}), VS.bt(U32.to_nat(LL(len)), F.limbs(VB.wdr(_, ${s})))) : +List<U32>}
  %Equal.sym(+List<U32>, ${YB}, ${YT},
      VZ.ybytes(LL(len), DZ(len), Nat.add(${H}n, i), t, ${KY}n, {==}, hyL(len, hx), hr(len, hx), hsl)) :
    {List.append(&2, U32, F.limbs(${HDR}), _) == List.append(&2, U32, F.limbs(${hdrs}), ${YT}) : +List<U32>}
  %epo : {List.append(&2, U32, F.limbs(${hdrh}), ${YT}) == List.append(&2, U32, F.limbs(${hdrs}), ${YT}) : +List<U32>}
  {==}

def specw_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +len: U32, ${PF}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, ${HA}, +epo: {SPOw(t, i) == ${FS} : U32}, ${HX})
    -> {Codec.parts(VALw(t, i, len), Spec.${n}()) == Some{[S.Variable{${WIN}}]} : ${MP}}:
  %bytesw(d, t, n, i, len, pf, hd, hw, ha, epo, hx) :
    {Codec.parts(VALw(t, i, len), Spec.${n}()) == Some{[S.Variable{_}]} : ${MP}}
  encpw(t, i, ${YB}, VZ.bd_btl(U32.to_nat(LL(len)), FD.array__slots(U32, MKw(t, i, len))), len_yb(t, i, len, hx))

# When the window's checks hold, the spec parts of VALw are its bytes, as one variable part.
def specw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +len: U32, ${PF}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {CHKw(t, i, len) == True{} : Bool})
    -> {Codec.parts(VALw(t, i, len), Spec.${n}()) == Some{[S.Variable{${WIN}}]} : ${MP}}:
  +a = U32.is_le(${FS}, len)
  +b = U32.is_eq(SPOw(t, i), ${FS})
  +c = BLW(U32.sub(len, SPOw(t, i)))
  +epo = FD.u32alg__eq_of(SPOw(t, i), ${FS}, chk_b(a, b, c, hchk))
  specw_go(d, t, n, i, len, pf, hd, hw, chk_a(a, b, c, hchk), epo,
    FD.logic__subst(U32, z => {BLW(U32.sub(len, z)) == True{} : Bool}, SPOw(t, i), ${FS}, epo, chk_c(a, b, c, hchk)))

@@ top_text @@

def BF(t: FD.array__Tree<U32>, +n: U32) -> B.Buf: VF.BF(t, n)
def CHK(+t: FD.array__Tree<U32>, +n: U32) -> Bool: W.CHKw(t, 0n, n)
def OBJ(+t: FD.array__Tree<U32>, +n: U32) -> ${Tn}: W.OBJw(t, 0n, n)
def VAL(+t: FD.array__Tree<U32>, +n: U32) -> S.Value: W.VALw(t, 0n, n)
def VW(+t: FD.array__Tree<U32>, +n: U32) -> +List<U32>: VS.bt(U32.to_nat(n), F.limbs(FD.array__slots(U32, t)))

# The validator returns the buffer and CHK(t, n).
law ok_eval:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 29n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  {${Tn}_ok(BF(t, n), 0, n) == (BF(t, n), CHK(t, n)) : B.Buf & Bool}
def ok_eval(d, t, n, pf, hd, hn):
  W.ok_evalw(d, t, n, 0n, 0, n, {==}, hd, hn, pf)

# Every buffer the validator accepts decodes to OBJ(t, n).
law decode_accept:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 29n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == True{} : Bool}
  {${Tn}_decode(BF(t, n), n) == (BF(t, n), Some{OBJ(t, n)}) : ${D}}
def decode_accept(d, t, n, pf, hd, hn, hchk):
  %Equal.sym(B.Buf & Bool, ${Tn}_ok(BF(t, n), 0, n), (BF(t, n), CHK(t, n)), ok_eval(d, t, n, pf, hd, hn)) :
    {${Tn}_built(n, _) == (BF(t, n), Some{OBJ(t, n)}) : ${D}}
  %Equal.sym(Bool, CHK(t, n), True{}, hchk) :
    {${Tn}_built(n, (BF(t, n), _)) == (BF(t, n), Some{OBJ(t, n)}) : ${D}}
  %Equal.sym(B.Buf & ${Tn}, ${Tn}_read(BF(t, n), 0, n), (BF(t, n), OBJ(t, n)), W.readw(d, t, n, 0n, 0, n, {==}, hd, hn, pf, hchk)) :
    {${Tn}_some(_) == (BF(t, n), Some{OBJ(t, n)}) : ${D}}
  {==}

# The bytes of every buffer the validator accepts are the spec encoding of the
# decoded object's value.
law decode_spec:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 29n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {CHK(t, n) == True{} : Bool}
  Decoding.decodes(Spec.${n}(), VW(t, n), VAL(t, n))
def decode_spec(d, t, n, pf, hd, hn, hchk):
  # the encoding opened over variables first (F.efl_bytes): the parts rewrite's motive over
  # Codec.bytes was compared with the spec encoding by running the encoder
  %F.efl_bytes(Spec.${n}(), VAL(t, n)) : {_ == Some{VW(t, n)} : Maybe<&2, +List<U32>>}
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(VAL(t, n), Spec.${n}()), Some{[S.Variable{VW(t, n)}]}, W.specw(d, t, n, 0n, n, pf, hd, hn, hchk)) :
    {Codec.bytes(_) == Some{VW(t, n)} : Maybe<&2, +List<U32>>}
  {==}

@@ lem @@
# The header's end H + P lies in the object's room; a header offset 4 (k + P), k <= H, is below 2^32 by hr32.
def hHR(+N: U32, +P: Nat) -> {Nat.is_le(${A_}, ${B_}) == True{} : Bool}: ${prf}

def hq32(+k: Nat, +N: U32, +P: Nat, +hk: {Nat.is_le(k, ${H}n) == True{} : Bool},
    +hr32: {Nat.is_lt(A.quad(ROOM(N, P)), ${P32}) == True{} : Bool}) -> {Nat.is_lt(A.quad(Nat.add(k, P)), ${P32}) == True{} : Bool}:
  +h1 = FD.nat__le_trans(Nat.add(k, P), ${A_}, ROOM(N, P), Order.add_right(k, ${H}n, P, hk), hHR(N, P))
  FD.nat__le_lt_trans(A.quad(Nat.add(k, P)), A.quad(ROOM(N, P)), ${P32},
    Order.double_monotone(Nat.double(Nat.add(k, P)), Nat.double(ROOM(N, P)), Order.double_monotone(Nat.add(k, P), ROOM(N, P), h1)), hr32)

# At dd < 29 (the old names): 4 ROOM <= 4 2^dd = 2^(2+dd) < 2^(3+dd) <= 2^32.
def hr32w(+N: U32, +P: Nat, +dd: Nat, +hdd: {Nat.is_lt(dd, 29n) == True{} : Bool}, +hdst: {Nat.is_le(ROOM(N, P), VB.pw(dd)) == True{} : Bool})
    -> {Nat.is_lt(A.quad(ROOM(N, P)), ${P32}) == True{} : Bool}:
  +hq = Order.double_monotone(Nat.double(ROOM(N, P)), Nat.double(VB.pw(dd)), Order.double_monotone(ROOM(N, P), VB.pw(dd), hdst))
  +hk = FD.nat__lt_succ_le(dd, 28n, hdd)
  FD.nat__le_lt_trans(A.quad(ROOM(N, P)), VB.pw(2n+dd), ${P32}, hq,
    FD.nat__lt_le_trans(VB.pw(2n+dd), VB.pw(Nat.add(3n, dd)), ${P32}, FD.nat__pow2_lt_succ(2n+dd),
      FD.nat__pow2_mono(Nat.add(3n, dd), 32n, FD.nat__le_trans(Nat.add(3n, dd), 31n, 32n, hk, {==}))))

def eocW(+k: Nat, +c: U32, +P: Nat, +pos: U32, +dd: Nat, +eP: {U32.to_nat(pos) == A.quad(P) : Nat},
    +hdd: {Nat.is_lt(dd, 31n) == True{} : Bool}, +ec: {U32.to_nat(c) == A.quad(k) : Nat},
    +hq: {Nat.is_lt(A.quad(Nat.add(k, P)), ${P32}) == True{} : Bool})
    -> {U32.to_nat(U32.add(pos, c)) == A.quad(Nat.add(k, P)) : Nat}:
  VF.off_add_lt(pos, c, P, k, eP, ec, hq)

