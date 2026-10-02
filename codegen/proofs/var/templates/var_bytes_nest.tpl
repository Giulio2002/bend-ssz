@@ LEHD @@
def leH(+len: U32, +ha: {U32.is_le(${FS}, len) == True{} : Bool}) -> {Nat.is_le(A.quad(${H}n), U32.to_nat(len)) == True{} : Bool}:
  VBZ.le_fs(${FS}, A.quad(${H}n), FD.nat__eq_from_is_eq(U32.to_nat(${FS}), A.quad(${H}n), {==}), len, ha)

def enH(+len: U32, +ha: {U32.is_le(${FS}, len) == True{} : Bool}) -> {Nat.add(A.quad(${H}n), U32.to_nat(LL(len))) == U32.to_nat(len) : Nat}:
  VBZ.en_fs(${FS}, A.quad(${H}n), FD.nat__eq_from_is_eq(U32.to_nat(${FS}), A.quad(${H}n), {==}), len, LL(len), {==}, ha)


@@ HWB @@
  +e1 = Equal.cong(Nat, Nat, z => Nat.add(A.quad(i), z), U32.to_nat(len), Nat.add(${FSN}, U32.to_nat(LL(len))), Equal.sym(Nat, Nat.add(${FSN}, U32.to_nat(LL(len))), U32.to_nat(len), enFS(len, ha)))
  +e2 = Equal.sym(Nat, Nat.add(Nat.add(A.quad(i), ${FSN}), U32.to_nat(LL(len))), Nat.add(A.quad(i), Nat.add(${FSN}, U32.to_nat(LL(len)))), FD.nat__add_assoc(A.quad(i), ${FSN}, U32.to_nat(LL(len))))
  +e3 = Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(LL(len))), Nat.add(A.quad(i), ${FSN}), Nat.add(${FSN}, A.quad(i)), FD.nat__add_comm(A.quad(i), ${FSN}))
  +e = Equal.trans(Nat, Nat.add(A.quad(i), U32.to_nat(len)), Nat.add(A.quad(i), Nat.add(${FSN}, U32.to_nat(LL(len)))), Nat.add(A.quad(Nat.add(${H}n, i)), U32.to_nat(LL(len))), e1,
    Equal.trans(Nat, Nat.add(A.quad(i), Nat.add(${FSN}, U32.to_nat(LL(len)))), Nat.add(Nat.add(A.quad(i), ${FSN}), U32.to_nat(LL(len))), Nat.add(A.quad(Nat.add(${H}n, i)), U32.to_nat(LL(len))), e2, e3))
  FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, Nat.add(A.quad(i), U32.to_nat(len)), Nat.add(A.quad(Nat.add(${H}n, i)), U32.to_nat(LL(len))), e, hw)
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

def LL(+len: U32) -> U32: U32.sub(len, ${FS})
def SPOw(t: FD.array__Tree<U32>, +i: Nat) -> U32: VB.slot(t, Nat.add(${po}n, i))

# The checks: the size, the offset, and ${Y}'s checks on the window after the header.
def CHKw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> Bool:
  chk3(U32.is_le(${FS}, len), U32.is_eq(SPOw(t, i), ${FS}), YW.CHKw(t, Nat.add(${H}n, i), LL(len)))

def c1_id(+ok: Bool, buf: B.Buf, +off: U32, +len: U32, +o0: U32) -> {${Tn}_c1(ok, buf, off, len, o0) == (buf, ok) : B.Buf & Bool}:
  match ok:
    case True{}: {==}
    case False{}: {==}

def leFS(+len: U32, ${HA}) -> {Nat.is_le(${FSN}, U32.to_nat(len)) == True{} : Bool}:
${LEB}

def enFS(+len: U32, ${HA}) -> {Nat.add(${FSN}, U32.to_nat(LL(len))) == U32.to_nat(len) : Nat}:
${ENB}

${LEHD}def winb(+k: Nat, +i: Nat, +len: U32, +P: Nat, +hk: {Nat.is_le(A.quad(k), U32.to_nat(len)) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), P) == True{} : Bool}) -> {Nat.is_le(A.quad(Nat.add(k, i)), P) == True{} : Bool}:
  %VF.quad_add(k, i) : {Nat.is_le(_, P) == True{} : Bool}
  FD.nat__le_trans(Nat.add(A.quad(k), A.quad(i)), Nat.add(U32.to_nat(len), A.quad(i)), P, Order.add_right(A.quad(k), U32.to_nat(len), A.quad(i), hk),
    FD.logic__subst(Nat, z => {Nat.is_le(z, P) == True{} : Bool}, Nat.add(A.quad(i), U32.to_nat(len)), Nat.add(U32.to_nat(len), A.quad(i)), FD.nat__add_comm(A.quad(i), U32.to_nat(len)), hw))

# The byte offset off + c of header byte c = 4 k (k <= H) is word k + i.
def eoc(+d: Nat, +i: Nat, +off: U32, +len: U32, +k: Nat, +c: U32, +ec: {U32.to_nat(c) == A.quad(k) : Nat},
    +hkF: {Nat.is_le(A.quad(k), ${FSN}) == True{} : Bool}, ${WH}, ${HA})
    -> {U32.to_nat(U32.add(off, c)) == A.quad(Nat.add(k, i)) : Nat}:
  VF.off_add(off, c, i, k, 2n+d, eo, ec, hd,
    winb(k, i, len, A.quad(VB.pw(d)), FD.nat__le_trans(A.quad(k), ${FSN}, U32.to_nat(len), hkF, leFS(len, ha)), hw))

# Header words k < H of the window are below 2^d.
def hiw(+d: Nat, +i: Nat, +len: U32, +k: Nat, +hk: {Nat.is_lt(k, ${H}n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, ${HA})
    -> {Nat.is_lt(Nat.add(k, i), VB.pw(d)) == True{} : Bool}:
  FD.nat__lt_le_trans(Nat.add(k, i), Nat.add(${H}n, i), VB.pw(d), VB.lt_kk(k, ${H}n, i, hk),
    VC.quad_inv(Nat.add(${H}n, i), VB.pw(d), winb(${H}n, i, len, A.quad(VB.pw(d)), ${LEHC}, hw)))

# The child's window (4 (H + i), len - ${FS}) lies in the buffer.
def hwY(+d: Nat, +i: Nat, +len: U32, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, ${HA})
    -> {Nat.is_le(Nat.add(A.quad(Nat.add(${H}n, i)), U32.to_nat(LL(len))), A.quad(VB.pw(d))) == True{} : Bool}:
${HWB}

def ecY(+d: Nat, +i: Nat, +off: U32, +len: U32, ${WH}, ${HA}) -> {U32.to_nat(U32.add(off, ${FS})) == A.quad(Nat.add(${H}n, i)) : Nat}:
  eoc(d, i, off, len, ${H}n, ${FS}, ${ecq(H, FS)}, {==}, eo, hd, hw, ha)

def okw_c1(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, ${WH}, ${PF}, ${HA}, +epo: {SPOw(t, i) == ${FS} : U32})
    -> {${Tn}_c0(True{}, VF.BF(t, n), off, len, SPOw(t, i)) == (VF.BF(t, n), YW.CHKw(t, Nat.add(${H}n, i), LL(len))) : B.Buf & Bool}:
  %Equal.sym(U32, SPOw(t, i), ${FS}, epo) :
    {${Tn}_v1(off, len, _, ${yok}(VF.BF(t, n), U32.add(off, _), U32.sub(len, _))) == (VF.BF(t, n), YW.CHKw(t, Nat.add(${H}n, i), LL(len))) : B.Buf & Bool}
  %Equal.sym(B.Buf & Bool, T.${Y}_ok(VF.BF(t, n), U32.add(off, ${FS}), LL(len)), (VF.BF(t, n), YW.CHKw(t, Nat.add(${H}n, i), LL(len))),
      YW.ok_evalw(d, t, n, Nat.add(${H}n, i), U32.add(off, ${FS}), LL(len), ecY(d, i, off, len, eo, hd, hw, ha), hd, hwY(d, i, len, hw, ha), pf)) :
    {${Tn}_v1(off, len, ${FS}, _) == (VF.BF(t, n), YW.CHKw(t, Nat.add(${H}n, i), LL(len))) : B.Buf & Bool}
  c1_id(YW.CHKw(t, Nat.add(${H}n, i), LL(len)), VF.BF(t, n), off, len, ${FS})

def okw_c0(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, ${WH}, ${PF}, ${HA},
    +b: Bool, +eb: {U32.is_eq(SPOw(t, i), ${FS}) == b : Bool})
    -> {${Tn}_c0(b, VF.BF(t, n), off, len, SPOw(t, i)) == (VF.BF(t, n), chk3(True{}, b, YW.CHKw(t, Nat.add(${H}n, i), LL(len)))) : B.Buf & Bool}:
  match b:
    case False{}: {==}
    case True{}: okw_c1(d, t, n, i, off, len, eo, hd, hw, pf, ha, FD.u32alg__eq_of(SPOw(t, i), ${FS}, eb))

def okw_len(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, ${WH}, ${PF},
    +a: Bool, +ea: {U32.is_le(${FS}, len) == a : Bool})
    -> {${Tn}_ok_len(a, VF.BF(t, n), off, len) == (VF.BF(t, n), chk3(a, U32.is_eq(SPOw(t, i), ${FS}), YW.CHKw(t, Nat.add(${H}n, i), LL(len)))) : B.Buf & Bool}:
  match a:
    case False{}: {==}
    case True{}:
      %Equal.sym(B.Buf & U32, B.read32(VF.BF(t, n), U32.add(off, ${cvar})), (VF.BF(t, n), SPOw(t, i)),
          VF.rd32a(d, t, n, U32.add(off, ${cvar}), Nat.add(${po}n, i), eoc(d, i, off, len, ${po}n, ${cvar}, {==}, {==}, eo, hd, hw, ea),
            VB.lt32(d, FD.nat__lt_trans(d, 29n, 31n, hd, {==})), hiw(d, i, len, ${po}n, {==}, hw, ea), pf)) :
        {${Tn}_v0(off, len, _) == (VF.BF(t, n), chk3(True{}, U32.is_eq(SPOw(t, i), ${FS}), YW.CHKw(t, Nat.add(${H}n, i), LL(len)))) : B.Buf & Bool}
      okw_c0(d, t, n, i, off, len, eo, hd, hw, pf, ea, U32.is_eq(SPOw(t, i), ${FS}), {==})

# The validator on the window returns the buffer and CHKw(t, i, len).
def ok_evalw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, ${WH}, ${PF})
    -> {${Tn}_ok(VF.BF(t, n), off, len) == (VF.BF(t, n), CHKw(t, i, len)) : B.Buf & Bool}:
  okw_len(d, t, n, i, off, len, eo, hd, hw, pf, U32.is_le(${FS}, len), {==})

def hHi(+d: Nat, +i: Nat, +len: U32, +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, ${HA})
    -> {Nat.is_le(Nat.add(${H}n, i), VB.pw(d)) == True{} : Bool}:
  VC.quad_inv(Nat.add(${H}n, i), VB.pw(d), winb(${H}n, i, len, A.quad(VB.pw(d)), ${LEHC}, hw))

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
  +c = YW.CHKw(t, Nat.add(${H}n, i), LL(len))
  +epo = FD.u32alg__eq_of(SPOw(t, i), ${FS}, chk_b(a, b, c, hchk))
  rdw_go(d, t, n, i, off, len, eo, hd, hw, pf, chk_a(a, b, c, hchk), epo, chk_c(a, b, c, hchk))

@@ spec_part @@

# ---- the spec side -------------------------------------------------------------------------

# The value of the window's fixed words and the child's value V.
def XVw(+t: FD.array__Tree<U32>, +i: Nat, +V: S.Value) -> S.Value: S.Sequence{${ITEMS}}

# Its spec parts: one variable part, the header's bytes (the offset is ${FS}) and the child's bytes Yb.
def encpw(+t: FD.array__Tree<U32>, +i: Nat, +V: S.Value, +Yb: +List<U32>,
    +hv: {Codec.parts(V, Spec.${Y}()) == Some{[S.Variable{Yb}]} : ${MP}}, +hdom: {SP.bytes_domain(Yb) == True{} : Bool},
    +fit: {N.fits(4n, Nat.add(VS.FSZ(${PRE}, ${POST}), List.length(&2, U32, Yb))) == True{} : Bool})
    -> {Codec.parts(XVw(t, i, V), Spec.${n}()) == Some{[S.Variable{${ENC}}]} : ${MP}}:
  %Equal.sym(${MP}, Codec.parts(${ITEMS}, ${CHAIN}), Some{${PL}},
      ${CAT}) :
    {Codec.aggregate(_, None{}) == Some{[S.Variable{${ENC}}]} : ${MP}}
  %Equal.sym(${M}, Layout.encoding(VS.fpv(${PRE}, Yb, ${POST})), Some{${ENCR}}, VZ.enc_fpvb(${PRE}, Yb, ${POST}, hdom, fit)) :
    {Codec.one(_, None{}) == Some{[S.Variable{${ENC}}]} : ${MP}}
  {==}

def VALw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> S.Value: XVw(t, i, ${VY_})

# The header's bytes and the child's window's bytes are the window's bytes.
def bytesw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +len: U32, ${PF}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, ${HA}, +epo: {SPOw(t, i) == ${FS} : U32})
    -> {List.append(&2, U32, F.limbs(${HDR}), ${YT}) == ${WIN} : +List<U32>}:
  +hsl = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(${H}n, i), z) == True{} : Bool}, VB.pw(d), VB.len(${s}), Equal.sym(Nat, VB.len(${s}), VB.pw(d), FD.array__slots_length(U32, d, t, pf)), hHi(d, i, len, hw, ha))
  %enFS(len, ha) : {List.append(&2, U32, F.limbs(${HDR}), ${YT}) == VS.bt(_, F.limbs(VB.wdr(i, ${s}))) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(Nat.add(A.quad(${H}n), U32.to_nat(LL(len))), F.limbs(VB.wdr(i, ${s}))),
      List.append(&2, U32, F.limbs(VS.wtake(${H}n, VB.wdr(i, ${s}))), VS.bt(U32.to_nat(LL(len)), F.limbs(VB.wdr(${H}n, VB.wdr(i, ${s}))))),
      VY.bt_split(${H}n, U32.to_nat(LL(len)), VB.wdr(i, ${s}), VZ.wdr_len_le(${H}n, i, ${s}, hsl))) :
    {List.append(&2, U32, F.limbs(${HDR}), ${YT}) == _ : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(Nat.add(${H}n, 0n), VB.wdr(i, ${s})), VF.app(VF.wpre(${H}n, i, ${s}), VS.wtake(0n, VB.wdr(Nat.add(${H}n, i), ${s}))),
      VF.wt_pre(${H}n, 0n, i, ${s}, hsl)) :
    {List.append(&2, U32, F.limbs(${HDR}), ${YT}) == List.append(&2, U32, F.limbs(_), VS.bt(U32.to_nat(LL(len)), F.limbs(VB.wdr(${H}n, VB.wdr(i, ${s}))))) : +List<U32>}
  %Equal.sym(List<&2, U32>, VB.wdr(${H}n, VB.wdr(i, ${s})), VB.wdr(Nat.add(i, ${H}n), ${s}), VF.wdr_add(${H}n, i, ${s})) :
    {List.append(&2, U32, F.limbs(${HDR}), ${YT}) == List.append(&2, U32, F.limbs(${hdrs}), VS.bt(U32.to_nat(LL(len)), F.limbs(_))) : +List<U32>}
  %Equal.sym(Nat, Nat.add(i, ${H}n), Nat.add(${H}n, i), FD.nat__add_comm(i, ${H}n)) :
    {List.append(&2, U32, F.limbs(${HDR}), ${YT}) == List.append(&2, U32, F.limbs(${hdrs}), VS.bt(U32.to_nat(LL(len)), F.limbs(VB.wdr(_, ${s})))) : +List<U32>}
  %epo : {List.append(&2, U32, F.limbs(${hdrh}), ${YT}) == List.append(&2, U32, F.limbs(${hdrs}), ${YT}) : +List<U32>}
  {==}

def fitw(+d: Nat, +t: FD.array__Tree<U32>, +i: Nat, +len: U32, +hd: {Nat.is_lt(d, 29n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, ${HA})
    -> {N.fits(4n, Nat.add(VS.FSZ(${PRE}, ${POST}), List.length(&2, U32, ${YT}))) == True{} : Bool}:
  +hl = FD.nat__le_trans(U32.to_nat(len), Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d)), Order.left_below_sum(A.quad(i), U32.to_nat(len)), hw)
  +h1 = FD.nat__le_trans(Nat.add(${FSN}, List.length(&2, U32, ${YT})), Nat.add(${FSN}, U32.to_nat(LL(len))), A.quad(VB.pw(d)),
    Order.add_left(${FSN}, List.length(&2, U32, ${YT}), U32.to_nat(LL(len)), VZ.bt_len_le(U32.to_nat(LL(len)), F.limbs(VB.wdr(Nat.add(${H}n, i), ${s})))),
    FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(len), Nat.add(${FSN}, U32.to_nat(LL(len))), Equal.sym(Nat, Nat.add(${FSN}, U32.to_nat(LL(len))), U32.to_nat(len), enFS(len, ha)), hl))
  VFT.fits4(2n+d, Nat.add(${FSN}, List.length(&2, U32, ${YT})), h1, FD.nat__lt_trans(d, 29n, 30n, hd, {==}))

def specw_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +len: U32, ${PF}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, ${HA}, +epo: {SPOw(t, i) == ${FS} : U32},
    +hY: {YW.CHKw(t, Nat.add(${H}n, i), LL(len)) == True{} : Bool})
    -> {Codec.parts(VALw(t, i, len), Spec.${n}()) == Some{[S.Variable{${WIN}}]} : ${MP}}:
  %bytesw(d, t, n, i, len, pf, hd, hw, ha, epo) :
    {Codec.parts(VALw(t, i, len), Spec.${n}()) == Some{[S.Variable{_}]} : ${MP}}
  encpw(t, i, ${VY_}, ${YT}, YW.specw(d, t, n, Nat.add(${H}n, i), LL(len), pf, hd, hwY(d, i, len, hw, ha), hY),
    VZ.bd_btl(U32.to_nat(LL(len)), VB.wdr(Nat.add(${H}n, i), ${s})), fitw(d, t, i, len, hd, hw, ha))

# When the window's checks hold, the spec parts of VALw are its bytes, as one variable part.
def specw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +len: U32, ${PF}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {CHKw(t, i, len) == True{} : Bool})
    -> {Codec.parts(VALw(t, i, len), Spec.${n}()) == Some{[S.Variable{${WIN}}]} : ${MP}}:
  +a = U32.is_le(${FS}, len)
  +b = U32.is_eq(SPOw(t, i), ${FS})
  +c = YW.CHKw(t, Nat.add(${H}n, i), LL(len))
  +epo = FD.u32alg__eq_of(SPOw(t, i), ${FS}, chk_b(a, b, c, hchk))
  specw_go(d, t, n, i, len, pf, hd, hw, chk_a(a, b, c, hchk), epo, chk_c(a, b, c, hchk))

@@ WVG @@
def wv_g(+t: F.array__Tree<U32>, +i: Nat, +len: U32, +h: Nat, +H: Nat, +eH: {A.quad(H) == h : Nat}, +l: U32, +en: {Nat.add(h, U32.to_nat(l)) == U32.to_nat(len) : Nat})
    -> {VS.bdr(h, WV(t, i, len)) == YR.WV(t, Nat.add(H, i), l) : +List<U32>}:
  %Equal.sym(Nat, U32.to_nat(len), Nat.add(h, U32.to_nat(l)), Equal.sym(Nat, Nat.add(h, U32.to_nat(l)), U32.to_nat(len), en)) :
    {VS.bdr(h, VS.bt(_, FX.limbs(VB.wdr(i, SL(t))))) == YR.WV(t, Nat.add(H, i), l) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(h, VS.bt(Nat.add(h, U32.to_nat(l)), FX.limbs(VB.wdr(i, SL(t))))), VS.bt(U32.to_nat(l), VS.bdr(h, FX.limbs(VB.wdr(i, SL(t))))),
      VS.bdr_bt(h, U32.to_nat(l), FX.limbs(VB.wdr(i, SL(t))))) :
    {_ == YR.WV(t, Nat.add(H, i), l) : +List<U32>}
  %eH : {VS.bt(U32.to_nat(l), VS.bdr(_, FX.limbs(VB.wdr(i, SL(t))))) == YR.WV(t, Nat.add(H, i), l) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(A.quad(H), FX.limbs(VB.wdr(i, SL(t)))), FX.limbs(VS.wdr0(H, VB.wdr(i, SL(t)))), VS.bdr_limbs(H, VB.wdr(i, SL(t)))) :
    {VS.bt(U32.to_nat(l), _) == YR.WV(t, Nat.add(H, i), l) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wdr0(H, VB.wdr(i, SL(t))), VB.wdr(H, VB.wdr(i, SL(t))), wdr0_eq(H, VB.wdr(i, SL(t)))) :
    {VS.bt(U32.to_nat(l), FX.limbs(_)) == YR.WV(t, Nat.add(H, i), l) : +List<U32>}
  %Equal.sym(List<&2, U32>, VB.wdr(H, VB.wdr(i, SL(t))), VB.wdr(Nat.add(i, H), SL(t)), VF.wdr_add(H, i, SL(t))) :
    {VS.bt(U32.to_nat(l), FX.limbs(_)) == YR.WV(t, Nat.add(H, i), l) : +List<U32>}
  %Equal.sym(Nat, Nat.add(i, H), Nat.add(H, i), F.nat__add_comm(i, H)) :
    {VS.bt(U32.to_nat(l), FX.limbs(VB.wdr(_, SL(t)))) == YR.WV(t, Nat.add(H, i), l) : +List<U32>}
  {==}

def wv_dr(+t: F.array__Tree<U32>, +i: Nat, +len: U32, +X: Nat, +en: {U32.to_nat(len) == Nat.add(@FSn, X) : Nat})
    -> {VS.bdr(@FSn, WV(t, i, len)) == YR.WV(t, Nat.add(@Hn, i), W.LL(len)) : +List<U32>}:
  wv_g(t, i, len, @FSn, @Hn, F.nat__eq_from_is_eq(A.quad(@Hn), @FSn, {==}), W.LL(len), W.enFS(len, haw(len, X, en)))


@@ NREJ @@

# The child's window: the bytes after the header.
def wv_dr(+t: F.array__Tree<U32>, +i: Nat, +len: U32, +X: Nat, +en: {U32.to_nat(len) == Nat.add(@FSn, X) : Nat})
    -> {VS.bdr(@FSn, WV(t, i, len)) == YR.WV(t, Nat.add(@Hn, i), W.LL(len)) : +List<U32>}:
  %Equal.sym(Nat, U32.to_nat(len), Nat.add(@FSn, U32.to_nat(W.LL(len))), Equal.sym(Nat, Nat.add(@FSn, U32.to_nat(W.LL(len))), U32.to_nat(len), W.enFS(len, haw(len, X, en)))) :
    {VS.bdr(@FSn, VS.bt(_, FX.limbs(VB.wdr(i, SL(t))))) == YR.WV(t, Nat.add(@Hn, i), W.LL(len)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(@FSn, VS.bt(Nat.add(@FSn, U32.to_nat(W.LL(len))), FX.limbs(VB.wdr(i, SL(t))))), VS.bt(U32.to_nat(W.LL(len)), VS.bdr(@FSn, FX.limbs(VB.wdr(i, SL(t))))),
      VS.bdr_bt(@FSn, U32.to_nat(W.LL(len)), FX.limbs(VB.wdr(i, SL(t))))) :
    {_ == YR.WV(t, Nat.add(@Hn, i), W.LL(len)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(@FSn, FX.limbs(VB.wdr(i, SL(t)))), FX.limbs(VS.wdr0(@Hn, VB.wdr(i, SL(t)))), VS.bdr_limbs(@Hn, VB.wdr(i, SL(t)))) :
    {VS.bt(U32.to_nat(W.LL(len)), _) == YR.WV(t, Nat.add(@Hn, i), W.LL(len)) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wdr0(@Hn, VB.wdr(i, SL(t))), VB.wdr(@Hn, VB.wdr(i, SL(t))), wdr0_eq(@Hn, VB.wdr(i, SL(t)))) :
    {VS.bt(U32.to_nat(W.LL(len)), FX.limbs(_)) == YR.WV(t, Nat.add(@Hn, i), W.LL(len)) : +List<U32>}
  %Equal.sym(List<&2, U32>, VB.wdr(@Hn, VB.wdr(i, SL(t))), VB.wdr(Nat.add(i, @Hn), SL(t)), VF.wdr_add(@Hn, i, SL(t))) :
    {VS.bt(U32.to_nat(W.LL(len)), FX.limbs(_)) == YR.WV(t, Nat.add(@Hn, i), W.LL(len)) : +List<U32>}
  %Equal.sym(Nat, Nat.add(i, @Hn), Nat.add(@Hn, i), F.nat__add_comm(i, @Hn)) :
    {VS.bt(U32.to_nat(W.LL(len)), FX.limbs(VB.wdr(_, SL(t)))) == YR.WV(t, Nat.add(@Hn, i), W.LL(len)) : +List<U32>}
  {==}

# The window's checks hold when its offset is @FS and the child's window passes its checks.
def chk_truew(+t: F.array__Tree<U32>, +i: Nat, +len: U32, +X: Nat, +en: {U32.to_nat(len) == Nat.add(@FSn, X) : Nat},
    +epo: {W.SPOw(t, i) == @FS : U32}, +hY: {YW.CHKw(t, Nat.add(@Hn, i), W.LL(len)) == True{} : Bool}) -> {W.CHKw(t, i, len) == True{} : Bool}:
  %Equal.sym(Bool, U32.is_le(@FS, len), True{}, haw(len, X, en)) :
    {W.chk3(_, U32.is_eq(W.SPOw(t, i), @FS), YW.CHKw(t, Nat.add(@Hn, i), W.LL(len))) == True{} : Bool}
  %Equal.sym(U32, W.SPOw(t, i), @FS, epo) :
    {W.chk3(True{}, U32.is_eq(_, @FS), YW.CHKw(t, Nat.add(@Hn, i), W.LL(len))) == True{} : Bool}
  hY

def rej_tail(+d: Nat, +t: F.array__Tree<U32>, +i: Nat, +len: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +hb: {VS.bt(4n, VS.bdr(@Pn, WV(t, i, len))) == @FSL : +List<U32>}, +hv0: S.Value, +ys: +List<U32>,
    +hlen: {List.length(&2, U32, WV(t, i, len)) == Nat.add(@FSn, List.length(&2, U32, ys)) : Nat},
    +hdr: {VS.bdr(@FSn, WV(t, i, len)) == ys : +List<U32>},
    +hvp: {Codec.parts(hv0, Spec.@Y()) == Some{[S.Variable{ys}]} : Maybe<&2, +List<S.Part>>})
    -> {W.CHKw(t, i, len) == True{} : Bool}:
  +en = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, WV(t, i, len)), Nat.add(@FSn, List.length(&2, U32, ys)), Equal.sym(Nat, List.length(&2, U32, WV(t, i, len)), U32.to_nat(len), lenWV(d, t, i, len, pf, hw)), hlen)
  +epo = wordFS(W.SPOw(t, i), Equal.trans(+List<U32>, FX.limbs([W.SPOw(t, i)]), VS.bt(4n, VS.bdr(@Pn, WV(t, i, len))), @FSL,
    Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(@Pn, WV(t, i, len))), FX.limbs([W.SPOw(t, i)]), bytePw(d, t, i, len, List.length(&2, U32, ys), en, pf, hw)), hb))
  +eys = Equal.trans(+List<U32>, ys, VS.bdr(@FSn, WV(t, i, len)), YR.WV(t, Nat.add(@Hn, i), W.LL(len)), Equal.sym(+List<U32>, VS.bdr(@FSn, WV(t, i, len)), ys, hdr),
    wv_dr(t, i, len, List.length(&2, U32, ys), en))
  fy = F.logic__subst(+List<U32>, z => YR.FACTS(z), ys, YR.WV(t, Nat.add(@Hn, i), W.LL(len)), eys, YR.inv_p(hv0, ys, hvp))
  chk_truew(t, i, len, List.length(&2, U32, ys), en, epo,
    YR.rej_facts(d, t, Nat.add(@Hn, i), W.LL(len), pf, W.hwY(d, i, len, hw, haw(len, List.length(&2, U32, ys), en)), fy))

def rej_p2(+d: Nat, +t: F.array__Tree<U32>, +i: Nat, +len: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +hb: {VS.bt(4n, VS.bdr(@Pn, WV(t, i, len))) == @FSL : +List<U32>}, +hv0: S.Value, +ys: +List<U32>,
    +hlen: {List.length(&2, U32, WV(t, i, len)) == Nat.add(@FSn, List.length(&2, U32, ys)) : Nat},
    r3: DK.P2({VS.bdr(@FSn, WV(t, i, len)) == ys : +List<U32>}, {Codec.parts(hv0, Spec.@Y()) == Some{[S.Variable{ys}]} : Maybe<&2, +List<S.Part>>}))
    -> {W.CHKw(t, i, len) == True{} : Bool}:
  (+hdr, hvp) = r3
  rej_tail(d, t, i, len, pf, hw, hb, hv0, ys, hlen, hdr, hvp)

# A window whose bytes have the checked shape passes the window's checks.
def rej_facts(+d: Nat, +t: F.array__Tree<U32>, +i: Nat, +len: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hw: {Nat.is_le(Nat.add(A.quad(i), U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, facts: FACTS(WV(t, i, len)))
    -> {W.CHKw(t, i, len) == True{} : Bool}:
  (+hb, ex) = facts
  (+hv0, r1) = ex
  (+ys, r2) = r1
  (+hlen, r3) = r2
  rej_p2(d, t, i, len, pf, hw, hb, hv0, ys, hlen, r3)

# When the validator refuses, no value is related to the buffer's bytes.
law decode_reject:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {DC.CHK(t, n) == False{} : Bool}
  Decoding.outside_image(Spec.@n(), DC.VW(t, n))
def decode_reject(d, t, n, pf, hn, hchk):
  v => e => F.logic__true_false(Equal.trans(Bool, True{}, DC.CHK(t, n), False{}, Equal.sym(Bool, DC.CHK(t, n), True{}, rej_facts(d, t, 0n, n, pf, hn, inv_v(v, DC.VW(t, n), e))), hchk))

# When the validator refuses, the decoder returns None and the buffer.
law decode_none:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 29n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {DC.CHK(t, n) == False{} : Bool}
  {@Tn_decode(DC.BF(t, n), n) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, @Tn>}
def decode_none(d, t, n, pf, hd, hn, hchk):
  %Equal.sym(B.Buf & Bool, @Tn_ok(DC.BF(t, n), 0, n), (DC.BF(t, n), DC.CHK(t, n)), DC.ok_eval(d, t, n, pf, hd, hn)) :
    {@Tn_built(n, _) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, @Tn>}
  %Equal.sym(Bool, DC.CHK(t, n), False{}, hchk) :
    {@Tn_built(n, (DC.BF(t, n), _)) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, @Tn>}
  {==}

@@ win_text_lines @@
def OBJw(+t: FD.array__Tree<U32>, +i: Nat, +len: U32) -> ${Tn}: ${OBJ}

# The reader on the window, when the checks hold.
def rdw_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +i: Nat, +off: U32, +len: U32, ${WH}, ${PF},
    ${HA}, +epo: {SPOw(t, i) == ${FS} : U32}, +hY: {YW.CHKw(t, Nat.add(${H}n, i), LL(len)) == True{} : Bool})
    -> {${Tn}_read(VF.BF(t, n), off, len) == ${RHS} : ${TY}}:
  +hd31 = FD.nat__lt_trans(d, 29n, 31n, hd, {==})
  +hH = hHi(d, i, len, hw, ha)
@@ win_text_lines_2 @@
  %Equal.sym(B.Buf & O.Words, ${call}, (VF.BF(t, n), ${val}),
      VY.copy_into_any(d, t, n, U32.add(off, ${f['c']}), Nat.add(${f['k']}n, i), ${f['size']}, ${f['dz']}n, ${kw}n, pf, hd31, {==},
        VF.al_3(U32.add(off, ${f['c']}), Nat.add(${f['k']}n, i), ${e}), VF.al_q(U32.add(off, ${f['c']}), Nat.add(${f['k']}n, i), ${e}),
        ${hb(f['W'], f['k'])}, {==}, {==}, {==})) :
@@ rej_text_lines_5 @@
def mis(m: Maybe<&2, Nat>, +n: Nat) -> Bool:
  match m:
    case Some{v}: Nat.is_eq(v, n)
    case None{}: False{}

def fs_of(+m: Maybe<&2, Nat>, +n: Nat, +h: {mis(m, n) == True{} : Bool}) -> {m == Some{n} : Maybe<&2, Nat>}:
  match m:
    case Some{+v}: Equal.cong(Nat, Maybe<&2, Nat>, z => Some{z}, v, n, F.nat__eq_from_is_eq(v, n, h))
    case None{}: Empty.absurd({None{} == Some{n} : Maybe<&2, Nat>}, F.logic__false_true(h))

def sfix(+sch: S.Schema, +n: Nat, +h: S.Value, +hn: {mis(SS.fixed_size(sch), n) == True{} : Bool},
    hf: DF.single_result(SS.fixed_size(sch), Codec.parts(h, sch))) -> DF.single_result(Some{n}, Codec.parts(h, sch)):
  F.logic__subst(Maybe<&2, Nat>, z => DF.single_result(z, Codec.parts(h, sch)), SS.fixed_size(sch), Some{n}, fs_of(SS.fixed_size(sch), n, hn), hf)

@@ rej_text_lines @@
def FACTS(bs: +List<U32>) -> Type:
  {VS.bt(4n, VS.bdr(${P}n, bs)) == ${FSL} : +List<U32>} & DK.Ex(S.Value, hv0 => DK.Ex(+List<U32>, ys => DK.P2({List.length(&2, U32, bs) == Nat.add(${FSN}, List.length(&2, U32, ys)) : Nat}, DK.P2({VS.bdr(${FSN}, bs) == ys : +List<U32>}, {Codec.parts(hv0, Spec.${Y}()) == Some{[S.Variable{ys}]} : ${MP}}))))

@@ rej_text_lines_2 @@
  %eP(${ALL}) : {VS.bt(4n, VS.bdr(_, ${OUT})) == N.digits(4n, Nat.add(_, 4n+${Qz}n)) : +List<U32>}
  %eQ(${ALL}) : {VS.bt(4n, VS.bdr(VR.lens(${PRE}), ${OUT})) == N.digits(4n, Nat.add(VR.lens(${PRE}), 4n+_)) : +List<U32>}
  VR.out_off(${PRE}, ys, ${POST})

@@ rej_text_lines_6 @@
  Equal.trans(Nat, ${OFS}, Nat.add(${Pz}n, 4n+${Qz}n), ${FSN},
    Equal.trans(Nat, ${OFS}, Nat.add(${Pz}n, 4n+${LQ}), Nat.add(${Pz}n, 4n+${Qz}n),
      Equal.cong(Nat, Nat, z => Nat.add(z, 4n+${LQ}), ${LP}, ${Pz}n, eP(${ALL})), Equal.cong(Nat, Nat, z => Nat.add(${Pz}n, 4n+z), ${LQ}, ${Qz}n, eQ(${ALL}))),
    F.nat__eq_from_is_eq(Nat.add(${Pz}n, 4n+${Qz}n), ${FSN}, {==}))

@@ rej_text_lines_7 @@
def f_len_g(${FSD}) -> {List.length(&2, U32, ${OUT}) == Nat.add(fs, VBZ.LN(ys)) : Nat}:
  Equal.trans(Nat, List.length(&2, U32, ${OUT}), Nat.add(${OFS}, List.length(&2, U32, ys)), Nat.add(fs, VBZ.LN(ys)), VR.out_len(${PRE}, ys, ${POST}),
    Equal.cong(Nat, Nat, z => Nat.add(z, List.length(&2, U32, ys)), ${OFS}, fs, ef))

@@ rej_text_lines_8 @@
  f_len_g(${ALL}, ${FSN}, eF(${ALL}))

def f_dr_g(${FSD}) -> {VS.bdr(fs, ${OUT}) == ys : +List<U32>}:
  Equal.trans(+List<U32>, VS.bdr(fs, ${OUT}), VS.bdr(${OFS}, ${OUT}), ys,
    Equal.cong(Nat, +List<U32>, z => VS.bdr(z, ${OUT}), fs, ${OFS}, Equal.sym(Nat, ${OFS}, fs, ef)), VZ.out_dr(${PRE}, ys, ${POST}))

@@ rej_text_lines_9 @@
  %eP(${ALL}) : {List.length(&2, U32, ${OUT}) == Nat.add(Nat.add(_, 4n+${Qz}n), List.length(&2, U32, ys)) : Nat}
  %eQ(${ALL}) : {List.length(&2, U32, ${OUT}) == Nat.add(Nat.add(VR.lens(${PRE}), 4n+_), List.length(&2, U32, ys)) : Nat}
  VR.out_len(${PRE}, ys, ${POST})

@@ rej_text_lines_10 @@
  %eP(${ALL}) : {VS.bdr(Nat.add(_, 4n+${Qz}n), ${OUT}) == ys : +List<U32>}
  %eQ(${ALL}) : {VS.bdr(Nat.add(VR.lens(${PRE}), 4n+_), ${OUT}) == ys : +List<U32>}
  VZ.out_dr(${PRE}, ys, ${POST})

@@ rej_text_lines_3 @@
  match b5:
    case False{}: ${absurd()}
    case True{}:
      %F.logic__some_inj(+List<U32>, ${OUT}, bs, e) : FACTS(_)
      (f_off(${ALL}), (hv0, (ys, (f_len(${ALL}), (f_dr(${ALL}), em)))))

@@ rej_text_lines_11 @@
  match ps:
    case Nil{}: Empty.absurd(FACTS(bs), hf)
    case Con{S.Fixed{+xs}, Nil{}}: st${i + 1}(${A_}xs, Equal.sym(Nat, ${z}n, List.length(&2, U32, xs), F.logic__some_inj(Nat, ${z}n, List.length(&2, U32, xs), hf)), t, bs, e)
    case Con{S.Variable{+xs}, Nil{}}: Empty.absurd(FACTS(bs), F.logic__none_some(Nat, ${z}n, Equal.sym(Maybe<&2, Nat>, Some{${z}n}, None{}, hf)))
    case Con{S.Fixed{+xs}, Con{+h2, +t2}}: Empty.absurd(FACTS(bs), hf)
    case Con{S.Variable{+xs}, Con{+h2, +t2}}: Empty.absurd(FACTS(bs), hf)

@@ rej_text_lines_12 @@
  match mm:
    case None{}: ${absurd()}
    case Some{+ps}: fp${i}(${A_}ps, hf, t, bs, e)

@@ rej_text_lines_13 @@
  match ps:
    case Nil{}: Empty.absurd(FACTS(bs), hf)
    case Con{S.Fixed{+xs}, Nil{}}: Empty.absurd(FACTS(bs), F.logic__none_some(Nat, List.length(&2, U32, xs), hf))
    case Con{S.Variable{+ys}, Nil{}}: st${i + 1}(${A_}h, ys, em0, t, bs, e)
    case Con{S.Fixed{+xs}, Con{+h2, +t2}}: Empty.absurd(FACTS(bs), hf)
    case Con{S.Variable{+xs}, Con{+h2, +t2}}: Empty.absurd(FACTS(bs), hf)

@@ rej_text_lines_14 @@
  match mm:
    case None{}: ${absurd()}
    case Some{+ps}: fp${i}(${A_}h, ps, hf, em0, t, bs, e)

@@ rej_text_lines_4 @@
# Every byte string the spec relates to a value has the checked shape.
law inv_v:
  for +v: S.Value
  for +bs: +List<U32>
  for +e: {Codec.encoding_for_legal_type(Spec.${n}(), v) == Some{bs} : ${MB}}
  FACTS(bs)
def inv_v(v, bs, e):