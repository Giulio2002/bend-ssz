@@ win_text @@
# The byte list's check: its length is at most the limit.
def BLW(+L: U32) -> Bool: U32.is_le(L, ${LIM})
def LL(+len: U32) -> U32: U32.sub(len, ${FS})
def SPOw(t: FD.array__Tree<U32>, +x: Nat) -> U32: ${rwn(cvar).replace('UR.RWN(t, ', 'UR.RWN(t, ')}

def CHKw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool:
  chk3(U32.is_le(${FS}, len), U32.is_eq(SPOw(t, x), ${FS}), BLW(U32.sub(len, SPOw(t, x))))

@@ win_text_hcx @@
# c + x <= 4 2^d for c <= ${FS}.
def hcx(+d: Nat, +x: Nat, +len: U32, +c: Nat, +hc: {Nat.is_le(c, ${FS}n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), ${P4}) == True{} : Bool}, ${HA})
    -> {Nat.is_le(Nat.add(c, x), ${P4}) == True{} : Bool}:
  FD.nat__le_trans(Nat.add(c, x), Nat.add(U32.to_nat(len), x), ${P4},
    Order.add_right(c, U32.to_nat(len), x, FD.nat__le_trans(c, ${FS}n, U32.to_nat(len), hc, leFS(len, ha))),
    FD.logic__subst(Nat, z => {Nat.is_le(z, ${P4}) == True{} : Bool}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw))

# The byte offset off + c of header byte c <= ${FS} is at c + x.
def eoc(+d: Nat, +x: Nat, +off: U32, +len: U32, +c: U32, +hc: {Nat.is_le(U32.to_nat(c), ${FS}n) == True{} : Bool}, ${WHX}, ${HA})
    -> {U32.to_nat(U32.add(off, c)) == Nat.add(U32.to_nat(c), x) : Nat}:
  VB.add_le_at(off, c, x, 2n+d, eo, FD.nat__lt_trans(d, 28n, 29n, hd, {==}), hcx(d, x, len, U32.to_nat(c), hc, hw, ha))

# Room for a field of s bytes at c + x, for c + s <= ${FS}.
def roomc(+d: Nat, +x: Nat, +len: U32, +c: Nat, +s: Nat, +hc: {Nat.is_le(Nat.add(c, s), ${FS}n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), ${P4}) == True{} : Bool}, ${HA})
    -> {Nat.is_le(Nat.add(Nat.add(c, x), s), ${P4}) == True{} : Bool}:
  UR.roomf(x, U32.to_nat(len), c, s, ${P4}, hw, FD.nat__le_trans(Nat.add(c, s), ${FS}n, U32.to_nat(len), hc, leFS(len, ha)))

# The byte list's window: (${FS} + x) + (len - ${FS}) = x + len.
def hwv(+d: Nat, +x: Nat, +len: U32, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), ${P4}) == True{} : Bool}, ${HA})
    -> {Nat.is_le(Nat.add(Nat.add(U32.to_nat(${FS}), x), U32.to_nat(LL(len))), ${P4}) == True{} : Bool}:
  +e = Equal.trans(Nat, Nat.add(Nat.add(${FS}n, x), U32.to_nat(LL(len))), Nat.add(${FS}n, Nat.add(x, U32.to_nat(LL(len)))), Nat.add(x, Nat.add(${FS}n, U32.to_nat(LL(len)))),
    FD.nat__add_assoc(${FS}n, x, U32.to_nat(LL(len))), FD.lru_nat_algebra__add_swap(${FS}n, x, U32.to_nat(LL(len))))
  %Equal.sym(Nat, Nat.add(Nat.add(${FS}n, x), U32.to_nat(LL(len))), Nat.add(x, Nat.add(${FS}n, U32.to_nat(LL(len)))), e) : {Nat.is_le(_, ${P4}) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(${FS}n, U32.to_nat(LL(len))), U32.to_nat(len), enFS(len, ha)) : {Nat.is_le(Nat.add(x, _), ${P4}) == True{} : Bool}
  hw

# ---- the validator ----------------------------------------------------------------------------

def rdoff(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, ${WHX}, ${PF}, ${HA})
    -> {B.read32(${BF}, U32.add(off, ${cvar})) == (${BF}, SPOw(t, x)) : B.Buf & U32}:
  UR.rwx(d, t, n, U32.add(off, ${cvar}), ${posx(cvar)}, eoc(d, x, off, len, ${cvar}, {==}, eo, hd, hw, ha), FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf,
    roomc(d, x, len, ${cvar}n, 4n, {==}, hw, ha))

def okw_c0(+t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +b: Bool)
    -> {${Tn}_c0(b, ${BF}, off, len, SPOw(t, x)) == (${BF}, chk3(True{}, b, BLW(U32.sub(len, SPOw(t, x))))) : B.Buf & Bool}:
  match b:
    case False{}: {==}
    case True{}: c1_id(BLW(U32.sub(len, SPOw(t, x))), ${BF}, off, len, SPOw(t, x))

def okw_len(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, ${WHX}, ${PF},
    +a: Bool, +ea: {U32.is_le(${FS}, len) == a : Bool})
    -> {${Tn}_ok_len(a, ${BF}, off, len) == (${BF}, chk3(a, U32.is_eq(SPOw(t, x), ${FS}), BLW(U32.sub(len, SPOw(t, x))))) : B.Buf & Bool}:
  match a:
    case False{}: {==}
    case True{}:
      %Equal.sym(B.Buf & U32, B.read32(${BF}, U32.add(off, ${cvar})), (${BF}, SPOw(t, x)), rdoff(d, t, n, x, off, len, eo, hd, hw, pf, ea)) :
        {${Tn}_v0(off, len, _) == (${BF}, chk3(True{}, U32.is_eq(SPOw(t, x), ${FS}), BLW(U32.sub(len, SPOw(t, x))))) : B.Buf & Bool}
      okw_c0(t, n, x, off, len, U32.is_eq(SPOw(t, x), ${FS}))

# The validator on the window returns the buffer and CHKw(t, x, off, len).
def ok_evalw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, ${WHX}, ${PF})
    -> {${Tn}_ok(${BF}, off, len) == (${BF}, CHKw(t, x, off, len)) : B.Buf & Bool}:
  okw_len(d, t, n, x, off, len, eo, hd, hw, pf, U32.is_le(${FS}, len), {==})

# ---- the byte list's bounds --------------------------------------------------------------------

@@ win_text_hsv @@
# The byte list's words lie in the buffer.
def hsv(+d: Nat, +x: Nat, +off: U32, +len: U32, ${WHX}, ${HA})
    -> {Nat.is_le(Nat.add(VC.NW(LL(len)), VRT.QX(U32.add(off, ${FS}))), VB.pw(d)) == True{} : Bool}:
  UW.hsx(d, U32.add(off, ${FS}), Nat.add(U32.to_nat(${FS}), x), LL(len), eoc(d, x, off, len, ${FS}, {==}, eo, hd, hw, ha), hd, hwv(d, x, len, hw, ha))

# The offset word, once checked, reads as ${FS}.
def rdo(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, ${WHX}, ${PF}, ${HA}, +epo: {SPOw(t, x) == ${FS} : U32})
    -> {B.read32(${BF}, U32.add(off, ${cvar})) == (${BF}, ${FS}) : B.Buf & U32}:
  %Equal.sym(B.Buf & U32, B.read32(${BF}, U32.add(off, ${cvar})), (${BF}, SPOw(t, x)), rdoff(d, t, n, x, off, len, eo, hd, hw, pf, ha)) :
    {_ == (${BF}, ${FS}) : B.Buf & U32}
  %Equal.sym(U32, SPOw(t, x), ${FS}, epo) : {(${BF}, _) == (${BF}, ${FS}) : B.Buf & U32}
  {==}

@@ win_text_readw @@

# When the window's checks hold, the reader returns OBJw(d, t, x, off, len).
def readw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, ${WHX}, ${PF},
    +hchk: {CHKw(t, x, off, len) == True{} : Bool})
    -> {${Tn}_read(${BF}, off, len) == ${RHS} : ${TY}}:
  +a = U32.is_le(${FS}, len)
  +b = U32.is_eq(SPOw(t, x), ${FS})
  +c = BLW(U32.sub(len, SPOw(t, x)))
  +epo = FD.u32alg__eq_of(SPOw(t, x), ${FS}, chk_b(a, b, c, hchk))
  rdw_go(d, t, n, x, off, len, eo, hd, hw, pf, chk_a(a, b, c, hchk), epo,
    FD.logic__subst(U32, z => {BLW(U32.sub(len, z)) == True{} : Bool}, SPOw(t, x), ${FS}, epo, chk_c(a, b, c, hchk)))

@@ inv_part @@

# ---- every value whose spec parts are the window's bytes passes the checks ----------------------

def ek_sub(+n: U32, +k: Nat, +en: {U32.to_nat(n) == Nat.add(${FS}n, k) : Nat}) -> {U32.to_nat(LL(n)) == k : Nat}:
  +le = FD.logic__subst(Nat, z => {Nat.is_le(${FS}n, z) == True{} : Bool}, Nat.add(${FS}n, k), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), Nat.add(${FS}n, k), en), Order.below_sum(${FS}n, k))
  %Equal.sym(Nat, U32.to_nat(LL(n)), Nat.sub(U32.to_nat(n), ${FS}n), FD.u32__sub_nat(n, ${FS}, le)) : {_ == k : Nat}
  %Equal.sym(Nat, U32.to_nat(n), Nat.add(${FS}n, k), en) : {Nat.sub(_, ${FS}n) == k : Nat}
  FD.nat__add_sub_cancel(${FS}n, k)

def chk_truew(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +k: Nat, +en: {U32.to_nat(len) == Nat.add(${FS}n, k) : Nat},
    +hk: {Nat.is_le(k, ${LIM}n) == True{} : Bool}, +epo: {SPOw(t, x) == ${FS} : U32}) -> {CHKw(t, x, off, len) == True{} : Bool}:
  +le = FD.logic__subst(Nat, z => {Nat.is_le(${FS}n, z) == True{} : Bool}, Nat.add(${FS}n, k), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), Nat.add(${FS}n, k), en), Order.below_sum(${FS}n, k))
  +hL = FD.logic__subst(Nat, z => {Nat.is_le(z, ${LIM}n) == True{} : Bool}, k, U32.to_nat(LL(len)), Equal.sym(Nat, U32.to_nat(LL(len)), k, ek_sub(len, k, en)), hk)
  %Equal.sym(Bool, U32.is_le(${FS}, len), True{}, FD.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(${FS}n, U32.to_nat(len)), U32.is_le(${FS}, len), Equal.sym(Bool, U32.is_le(${FS}, len), Nat.is_le(${FS}n, U32.to_nat(len)), VU.le_u32(${FS}, len)), le)) :
    {chk3(_, U32.is_eq(SPOw(t, x), ${FS}), BLW(U32.sub(len, SPOw(t, x)))) == True{} : Bool}
  %Equal.sym(U32, SPOw(t, x), ${FS}, epo) : {chk3(True{}, U32.is_eq(_, ${FS}), BLW(U32.sub(len, _))) == True{} : Bool}
  FD.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(LL(len)), U32.to_nat(${LIM})), U32.is_le(LL(len), ${LIM}), Equal.sym(Bool, U32.is_le(LL(len), ${LIM}), Nat.is_le(U32.to_nat(LL(len)), U32.to_nat(${LIM})), VU.le_u32(LL(len), ${LIM})), hL)

# The four bytes at the window's offset field are the limbs of its offset word.
def byteP(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, +k: Nat, +en: {U32.to_nat(len) == Nat.add(${FS}n, k) : Nat}, ${PF},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool})
    -> {VS.bt(4n, VS.bdr(${cvar}n, ${WX})) == F.limbs([SPOw(t, x)]) : +List<U32>}:
  +hw2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, z), A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(len), Nat.add(${cvar}n, 4n+Nat.add(${R}n, k)), en, hw)
  %Equal.sym(Nat, U32.to_nat(len), Nat.add(${cvar}n, 4n+Nat.add(${R}n, k)), en) : {VS.bt(4n, VS.bdr(${cvar}n, UW.WX(t, x, _))) == F.limbs([SPOw(t, x)]) : +List<U32>}
  UW.byteWX(d, t, x, ${cvar}n, Nat.add(${R}n, k), pf, hw2)

def inv_facts(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, ${PF},
    +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool}, facts: XI.FACTS(${WX}))
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  (+hb, ex) = facts
  (+k, +pr) = ex
  (+hlen, +hk) = pr
  +en = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, ${WX}), Nat.add(${FS}n, k), Equal.sym(Nat, List.length(&2, U32, ${WX}), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)), hlen)
  +epo = XI.wordFS(SPOw(t, x), Equal.trans(+List<U32>, F.limbs([SPOw(t, x)]), VS.bt(4n, VS.bdr(${cvar}n, ${WX})), ${FSL},
    Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(${cvar}n, ${WX})), F.limbs([SPOw(t, x)]), byteP(d, t, x, len, k, en, pf, hw)), hb))
  chk_truew(t, x, off, len, k, en, hk, epo)

# Every value whose spec parts are the window's bytes passes the checks.
def invw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, ${WHX}, ${PF},
    +v: S.Value, +e: {Codec.parts(v, Spec.${n}()) == Some{[S.Variable{${WX}}]} : ${MP}})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  inv_facts(d, t, x, off, len, pf, hw, XI.inv_p(v, ${WX}, e))

@@ hcx32 @@
# c + x below 2^32 for c <= ${FS}.
def hcx32(+x: Nat, +len: U32, +c: Nat, +hc: {Nat.is_le(c, ${FS}n) == ${T}}, +hw32: {Nat.is_lt(Nat.add(x, U32.to_nat(len)), ${P32}) == ${T}}, +ha: {U32.is_le(${FS}, len) == ${T}})
    -> {Nat.is_lt(Nat.add(c, x), ${P32}) == ${T}}:
  FD.nat__le_lt_trans(Nat.add(c, x), Nat.add(U32.to_nat(len), x), ${P32},
    Order.add_right(c, U32.to_nat(len), x, FD.nat__le_trans(c, ${FS}n, U32.to_nat(len), hc, leFS(len, ha))),
    FD.logic__subst(Nat, z => {Nat.is_lt(z, ${P32}) == ${T}}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw32))

@@ hcx32_hcx32 @@
# c + x below 2^32 for c <= ${FS}.
def hcx32(+x: Nat, +len: U32, +c: Nat, +hc: {Nat.is_le(c, ${FS}n) == ${T}}, +hw32: {Nat.is_lt(Nat.add(x, U32.to_nat(len)), ${P32}) == ${T}}, +ha: {U32.is_le(${FS}, len) == ${T}})
    -> {Nat.is_lt(Nat.add(c, x), ${P32}) == ${T}}:
  FD.nat__le_lt_trans(Nat.add(c, x), Nat.add(U32.to_nat(len), x), ${P32},
    Order.add_right(c, U32.to_nat(len), x, FD.nat__le_trans(c, ${FS}n, U32.to_nat(len), hc, leFS(len, ha))),
    FD.logic__subst(Nat, z => {Nat.is_lt(z, ${P32}) == ${T}}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw32))

@@ hwy32 @@
def hwY32(+x: Nat, +len: U32, +hw32: {Nat.is_lt(Nat.add(x, U32.to_nat(len)), ${P32}) == ${T}}, +ha: {U32.is_le(${FS}, len) == ${T}})
    -> {Nat.is_lt(Nat.add(Nat.add(U32.to_nat(${FS}), x), U32.to_nat(LL(len))), ${P32}) == ${T}}:
  +e = Equal.trans(Nat, Nat.add(Nat.add(${FS}n, x), U32.to_nat(LL(len))), Nat.add(${FS}n, Nat.add(x, U32.to_nat(LL(len)))), Nat.add(x, Nat.add(${FS}n, U32.to_nat(LL(len)))),
    FD.nat__add_assoc(${FS}n, x, U32.to_nat(LL(len))), FD.lru_nat_algebra__add_swap(${FS}n, x, U32.to_nat(LL(len))))
  %Equal.sym(Nat, Nat.add(Nat.add(${FS}n, x), U32.to_nat(LL(len))), Nat.add(x, Nat.add(${FS}n, U32.to_nat(LL(len)))), e) : {Nat.is_lt(_, ${P32}) == ${T}}
  %Equal.sym(Nat, Nat.add(${FS}n, U32.to_nat(LL(len))), U32.to_nat(len), enFS(len, ha)) : {Nat.is_lt(Nat.add(x, _), ${P32}) == ${T}}
  hw32

@@ _xw_setup @@
def LL(+len: U32) -> U32: U32.sub(len, ${FS})
def SPOw(t: FD.array__Tree<U32>, +x: Nat) -> U32: ${rwn(cvar)}

# The checks: the size, the offset, and ${Y}'s checks on the window after the header.
def CHKw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool:
  chk3(U32.is_le(${FS}, len), U32.is_eq(SPOw(t, x), ${FS}), ${YCHK})


@@ _xw_reader @@
def hcx(+d: Nat, +x: Nat, +len: U32, +c: Nat, +hc: {Nat.is_le(c, ${FS}n) == True{} : Bool}, ${HW}, ${HA})
    -> {Nat.is_le(Nat.add(c, x), ${P4}) == True{} : Bool}:
  FD.nat__le_trans(Nat.add(c, x), Nat.add(U32.to_nat(len), x), ${P4},
    Order.add_right(c, U32.to_nat(len), x, FD.nat__le_trans(c, ${FS}n, U32.to_nat(len), hc, leFS(len, ha))),
    FD.logic__subst(Nat, z => {Nat.is_le(z, ${P4}) == True{} : Bool}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw))

# The byte offset off + c of header byte c <= ${FS} is at c + x.
def eoc(+d: Nat, +x: Nat, +off: U32, +len: U32, +c: U32, +hc: {Nat.is_le(U32.to_nat(c), ${FS}n) == True{} : Bool}, ${WHX}, ${HA})
    -> {U32.to_nat(U32.add(off, c)) == Nat.add(U32.to_nat(c), x) : Nat}:
  VB.add_le_at(off, c, x, 2n+d, eo, FD.nat__lt_trans(d, 28n, 29n, hd, {==}), hcx(d, x, len, U32.to_nat(c), hc, hw, ha))

def roomc(+d: Nat, +x: Nat, +len: U32, +c: Nat, +s: Nat, +hc: {Nat.is_le(Nat.add(c, s), ${FS}n) == True{} : Bool}, ${HW}, ${HA})
    -> {Nat.is_le(Nat.add(Nat.add(c, x), s), ${P4}) == True{} : Bool}:
  UR.roomf(x, U32.to_nat(len), c, s, ${P4}, hw, FD.nat__le_trans(Nat.add(c, s), ${FS}n, U32.to_nat(len), hc, leFS(len, ha)))

# The child's window (${FS} + x, len - ${FS}) lies in the buffer.
def hwY(+d: Nat, +x: Nat, +len: U32, ${HW}, ${HA})
    -> {Nat.is_le(Nat.add(Nat.add(U32.to_nat(${FS}), x), U32.to_nat(LL(len))), ${P4}) == True{} : Bool}:
  +e = Equal.trans(Nat, Nat.add(Nat.add(${FS}n, x), U32.to_nat(LL(len))), Nat.add(${FS}n, Nat.add(x, U32.to_nat(LL(len)))), Nat.add(x, Nat.add(${FS}n, U32.to_nat(LL(len)))),
    FD.nat__add_assoc(${FS}n, x, U32.to_nat(LL(len))), FD.lru_nat_algebra__add_swap(${FS}n, x, U32.to_nat(LL(len))))
  %Equal.sym(Nat, Nat.add(Nat.add(${FS}n, x), U32.to_nat(LL(len))), Nat.add(x, Nat.add(${FS}n, U32.to_nat(LL(len)))), e) : {Nat.is_le(_, ${P4}) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(${FS}n, U32.to_nat(LL(len))), U32.to_nat(len), enFS(len, ha)) : {Nat.is_le(Nat.add(x, _), ${P4}) == True{} : Bool}
  hw

def ecY(+d: Nat, +x: Nat, +off: U32, +len: U32, ${WHX}, ${HA}) -> {U32.to_nat(U32.add(off, ${FS})) == ${JX} : Nat}:
  eoc(d, x, off, len, ${FS}, {==}, eo, hd, hw, ha)

# ---- the validator ----------------------------------------------------------------------------

def rdoff(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, ${WHX}, ${PF}, ${HA})
    -> {B.read32(${BF}, U32.add(off, ${cvar})) == (${BF}, SPOw(t, x)) : B.Buf & U32}:
  UR.rwx(d, t, n, U32.add(off, ${cvar}), ${posx(cvar)}, eoc(d, x, off, len, ${cvar}, {==}, eo, hd, hw, ha), FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf,
    roomc(d, x, len, ${cvar}n, 4n, {==}, hw, ha))

def okw_c1(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, ${WHX}, ${PF}, ${HA}, +epo: {SPOw(t, x) == ${FS} : U32})
    -> {${Tn}_c0(True{}, ${BF}, off, len, SPOw(t, x)) == (${BF}, ${YCHK}) : B.Buf & Bool}:
  %Equal.sym(U32, SPOw(t, x), ${FS}, epo) :
    {${Tn}_v1(off, len, _, ${yok}(${BF}, U32.add(off, _), U32.sub(len, _))) == (${BF}, ${YCHK}) : B.Buf & Bool}
  %Equal.sym(B.Buf & Bool, T.${Y}_ok(${BF}, U32.add(off, ${FS}), LL(len)), (${BF}, ${YCHK}),
      YW.ok_evalw(d, t, n, ${JX}, U32.add(off, ${FS}), LL(len), ecY(d, x, off, len, eo, hd, hw, ha), hd, hwY(d, x, len, hw, ha), pf)) :
    {${Tn}_v1(off, len, ${FS}, _) == (${BF}, ${YCHK}) : B.Buf & Bool}
  c1_id(${YCHK}, ${BF}, off, len, ${FS})

def okw_c0(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, ${WHX}, ${PF}, ${HA},
    +b: Bool, +eb: {U32.is_eq(SPOw(t, x), ${FS}) == b : Bool})
    -> {${Tn}_c0(b, ${BF}, off, len, SPOw(t, x)) == (${BF}, chk3(True{}, b, ${YCHK})) : B.Buf & Bool}:
  match b:
    case False{}: {==}
    case True{}: okw_c1(d, t, n, x, off, len, eo, hd, hw, pf, ha, FD.u32alg__eq_of(SPOw(t, x), ${FS}, eb))

def okw_len(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, ${WHX}, ${PF},
    +a: Bool, +ea: {U32.is_le(${FS}, len) == a : Bool})
    -> {${Tn}_ok_len(a, ${BF}, off, len) == (${BF}, chk3(a, U32.is_eq(SPOw(t, x), ${FS}), ${YCHK})) : B.Buf & Bool}:
  match a:
    case False{}: {==}
    case True{}:
      %Equal.sym(B.Buf & U32, B.read32(${BF}, U32.add(off, ${cvar})), (${BF}, SPOw(t, x)), rdoff(d, t, n, x, off, len, eo, hd, hw, pf, ea)) :
        {${Tn}_v0(off, len, _) == (${BF}, chk3(True{}, U32.is_eq(SPOw(t, x), ${FS}), ${YCHK})) : B.Buf & Bool}
      okw_c0(d, t, n, x, off, len, eo, hd, hw, pf, ea, U32.is_eq(SPOw(t, x), ${FS}), {==})

# The validator on the window returns the buffer and CHKw(t, x, off, len).
def ok_evalw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, ${WHX}, ${PF})
    -> {${Tn}_ok(${BF}, off, len) == (${BF}, CHKw(t, x, off, len)) : B.Buf & Bool}:
  okw_len(d, t, n, x, off, len, eo, hd, hw, pf, U32.is_le(${FS}, len), {==})

# The offset word, once checked, reads as ${FS}.
def rdo(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, ${WHX}, ${PF}, ${HA}, +epo: {SPOw(t, x) == ${FS} : U32})
    -> {B.read32(${BF}, U32.add(off, ${cvar})) == (${BF}, ${FS}) : B.Buf & U32}:
  %Equal.sym(B.Buf & U32, B.read32(${BF}, U32.add(off, ${cvar})), (${BF}, SPOw(t, x)), rdoff(d, t, n, x, off, len, eo, hd, hw, pf, ha)) :
    {_ == (${BF}, ${FS}) : B.Buf & U32}
  %Equal.sym(U32, SPOw(t, x), ${FS}, epo) : {(${BF}, _) == (${BF}, ${FS}) : B.Buf & U32}
  {==}

@@ _xw_reader_readw @@

# When the window's checks hold, the reader returns OBJw(d, t, x, off, len).
def readw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, ${WHX}, ${PF},
    +hchk: {CHKw(t, x, off, len) == True{} : Bool})
    -> {${Tn}_read(${BF}, off, len) == ${RHS} : ${TY}}:
  +a = U32.is_le(${FS}, len)
  +b = U32.is_eq(SPOw(t, x), ${FS})
  +c = ${YCHK}
  +epo = FD.u32alg__eq_of(SPOw(t, x), ${FS}, chk_b(a, b, c, hchk))
  rdw_go(d, t, n, x, off, len, eo, hd, hw, pf, chk_a(a, b, c, hchk), epo, chk_c(a, b, c, hchk))

@@ _xw_invariant @@

# ---- every value whose spec parts are the window's bytes passes the checks ----------------------

def ek_sub(+n: U32, +k: Nat, +en: {U32.to_nat(n) == Nat.add(${FS}n, k) : Nat}) -> {U32.to_nat(LL(n)) == k : Nat}:
  +le = FD.logic__subst(Nat, z => {Nat.is_le(${FS}n, z) == True{} : Bool}, Nat.add(${FS}n, k), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), Nat.add(${FS}n, k), en), Order.below_sum(${FS}n, k))
  %Equal.sym(Nat, U32.to_nat(LL(n)), Nat.sub(U32.to_nat(n), ${FS}n), FD.u32__sub_nat(n, ${FS}, le)) : {_ == k : Nat}
  %Equal.sym(Nat, U32.to_nat(n), Nat.add(${FS}n, k), en) : {Nat.sub(_, ${FS}n) == k : Nat}
  FD.nat__add_sub_cancel(${FS}n, k)

def chk_truew(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +k: Nat, +en: {U32.to_nat(len) == Nat.add(${FS}n, k) : Nat},
    +epo: {SPOw(t, x) == ${FS} : U32}, +hY: {${YCHK} == True{} : Bool}) -> {CHKw(t, x, off, len) == True{} : Bool}:
  +le = FD.logic__subst(Nat, z => {Nat.is_le(${FS}n, z) == True{} : Bool}, Nat.add(${FS}n, k), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), Nat.add(${FS}n, k), en), Order.below_sum(${FS}n, k))
  %Equal.sym(Bool, U32.is_le(${FS}, len), True{}, FD.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(${FS}n, U32.to_nat(len)), U32.is_le(${FS}, len), Equal.sym(Bool, U32.is_le(${FS}, len), Nat.is_le(${FS}n, U32.to_nat(len)), VU.le_u32(${FS}, len)), le)) :
    {chk3(_, U32.is_eq(SPOw(t, x), ${FS}), ${YCHK}) == True{} : Bool}
  %Equal.sym(U32, SPOw(t, x), ${FS}, epo) : {chk3(True{}, U32.is_eq(_, ${FS}), ${YCHK}) == True{} : Bool}
  hY

def byteP(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, +k: Nat, +en: {U32.to_nat(len) == Nat.add(${FS}n, k) : Nat}, ${PF}, ${HW})
    -> {VS.bt(4n, VS.bdr(${cvar}n, ${WX})) == F.limbs([SPOw(t, x)]) : +List<U32>}:
  +hw2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, z), ${P4}) == True{} : Bool}, U32.to_nat(len), Nat.add(${cvar}n, 4n+Nat.add(${R}n, k)), en, hw)
  %Equal.sym(Nat, U32.to_nat(len), Nat.add(${cvar}n, 4n+Nat.add(${R}n, k)), en) : {VS.bt(4n, VS.bdr(${cvar}n, UW.WX(t, x, _))) == F.limbs([SPOw(t, x)]) : +List<U32>}
  UW.byteWX(d, t, x, ${cvar}n, Nat.add(${R}n, k), pf, hw2)

# The child's bytes: the window after the header.
def eys(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +k: Nat, +en: {U32.to_nat(len) == Nat.add(${FS}n, k) : Nat})
    -> {VS.bdr(${FS}n, ${WX}) == ${YX} : +List<U32>}:
  %Equal.sym(Nat, U32.to_nat(len), Nat.add(${FS}n, k), en) : {VS.bdr(${FS}n, UW.WX(t, x, _)) == ${YX} : +List<U32>}
  %Equal.sym(Nat, ${L4}, k, ek_sub(len, k, en)) : {VS.bdr(${FS}n, UW.WX(t, x, Nat.add(${FS}n, k))) == UW.WX(t, ${JX}, _) : +List<U32>}
  UW.tailWX(t, x, ${FS}n, k)

def inv_tail(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, ${WHX}, ${PF},
    +hb: {VS.bt(4n, VS.bdr(${cvar}n, ${WX})) == ${FSL} : +List<U32>}, +hv0: S.Value, +ys: +List<U32>,
    +hlen: {List.length(&2, U32, ${WX}) == Nat.add(${FS}n, List.length(&2, U32, ys)) : Nat},
    +hdr: {VS.bdr(${FS}n, ${WX}) == ys : +List<U32>},
    +hvp: {Codec.parts(hv0, Spec.${Y}()) == Some{[S.Variable{ys}]} : ${MP}})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  +k = List.length(&2, U32, ys)
  +en = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, ${WX}), Nat.add(${FS}n, k), Equal.sym(Nat, List.length(&2, U32, ${WX}), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)), hlen)
  +ha = FD.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(${FS}n, U32.to_nat(len)), U32.is_le(${FS}, len), Equal.sym(Bool, U32.is_le(${FS}, len), Nat.is_le(${FS}n, U32.to_nat(len)), VU.le_u32(${FS}, len)),
    FD.logic__subst(Nat, z => {Nat.is_le(${FS}n, z) == True{} : Bool}, Nat.add(${FS}n, k), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), Nat.add(${FS}n, k), en), Order.below_sum(${FS}n, k)))
  +epo = XI.wordFS(SPOw(t, x), Equal.trans(+List<U32>, F.limbs([SPOw(t, x)]), VS.bt(4n, VS.bdr(${cvar}n, ${WX})), ${FSL},
    Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(${cvar}n, ${WX})), F.limbs([SPOw(t, x)]), byteP(d, t, x, len, k, en, pf, hw)), hb))
  +ey = Equal.trans(+List<U32>, ys, VS.bdr(${FS}n, ${WX}), ${YX}, Equal.sym(+List<U32>, VS.bdr(${FS}n, ${WX}), ys, hdr), eys(t, x, len, k, en))
  +hv = FD.logic__subst(+List<U32>, z => {Codec.parts(hv0, Spec.${Y}()) == Some{[S.Variable{z}]} : ${MP}}, ys, ${YX}, ey, hvp)
  chk_truew(t, x, off, len, k, en, epo,
    YW.invw(d, t, n, ${JX}, U32.add(off, ${FS}), LL(len), ecY(d, x, off, len, eo, hd, hw, ha), hd, hwY(d, x, len, hw, ha), pf, hv0, hv))

def inv_p2(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, ${WHX}, ${PF},
    +hb: {VS.bt(4n, VS.bdr(${cvar}n, ${WX})) == ${FSL} : +List<U32>}, +hv0: S.Value, +ys: +List<U32>,
    +hlen: {List.length(&2, U32, ${WX}) == Nat.add(${FS}n, List.length(&2, U32, ys)) : Nat},
    r3: DK.P2({VS.bdr(${FS}n, ${WX}) == ys : +List<U32>}, {Codec.parts(hv0, Spec.${Y}()) == Some{[S.Variable{ys}]} : ${MP}}))
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  (+hdr, hvp) = r3
  inv_tail(d, t, n, x, off, len, eo, hd, hw, pf, hb, hv0, ys, hlen, hdr, hvp)

def inv_facts(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, ${WHX}, ${PF}, facts: XI.FACTS(${WX}))
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  (+hb, ex) = facts
  (+hv0, r1) = ex
  (+ys, r2) = r1
  (+hlen, r3) = r2
  inv_p2(d, t, n, x, off, len, eo, hd, hw, pf, hb, hv0, ys, hlen, r3)

# Every value whose spec parts are the window's bytes passes the checks.
def invw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, ${WHX}, ${PF},
    +v: S.Value, +e: {Codec.parts(v, Spec.${n}()) == Some{[S.Variable{${WX}}]} : ${MP}})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  inv_facts(d, t, n, x, off, len, eo, hd, hw, pf, XI.inv_p(v, ${WX}, e))

@@ inv_text_lines @@
# Every value whose spec parts are one variable part has its bytes in the checked shape.
def inv_p(+v: S.Value, +bs: +List<U32>, +e: {Codec.parts(v, Spec.${x.n}()) == Some{[S.Variable{bs}]} : Maybe<&2, +List<S.Part>>}) -> FACTS(bs):
  inv_v(v, bs, Equal.cong(Maybe<&2, +List<S.Part>>, Maybe<&2, +List<U32>>, z => Codec.bytes(z), Codec.parts(v, Spec.${x.n}()), Some{[S.Variable{bs}]}, e))
@@ win_text_lines @@
def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> ${Tn}: ${OBJ}

# The reader on the window, when the checks hold.
def rdw_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, ${WHX}, ${PF},
    ${HA}, +epo: {SPOw(t, x) == ${FS} : U32}, ${HX})
    -> {${Tn}_read(${BF}, off, len) == ${RHS} : ${TY}}:
  +hd30 = FD.nat__lt_trans(d, 28n, 30n, hd, {==})
  +hd31 = FD.nat__lt_trans(d, 28n, 31n, hd, {==})
@@ win_text_lines_2 @@
  %Equal.sym(B.Buf & O.Words, ${call}, (${BF}, ${val}),
      UCT.copy_in_at(d, t, n, U32.add(off, ${FS}), LL(len), DZ(len), ${KY}n, pf, hd31, hdz31(len, hx), ez(len, hx),
        hsv(d, x, off, len, eo, hd, hw, ha), hr(len, hx), {==}, hyL(len, hx))) :
@@ xn_inv_text_lines @@
# Every value whose spec parts are one variable part has its bytes in the checked shape.
def inv_p(+v: S.Value, +bs: +List<U32>, +e: {Codec.parts(v, Spec.${x.n}()) == Some{[S.Variable{bs}]} : Maybe<&2, +List<S.Part>>}) -> FACTS(bs):
  inv_v(v, bs, Equal.cong(Maybe<&2, +List<S.Part>>, Maybe<&2, +List<U32>>, z => Codec.bytes(z), Codec.parts(v, Spec.${x.n}()), Some{[S.Variable{bs}]}, e))
@@ _xw_reader_lines @@
def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> ${Tn}: ${OBJ}

# The reader on the window, when the checks hold.
def rdw_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, ${WHX}, ${PF},
    ${HA}, +epo: {SPOw(t, x) == ${FS} : U32}, +hY: {${YCHK} == True{} : Bool})
    -> {${Tn}_read(${BF}, off, len) == ${RHS} : ${TY}}:
  +hd30 = FD.nat__lt_trans(d, 28n, 30n, hd, {==})
  +hd31 = FD.nat__lt_trans(d, 28n, 31n, hd, {==})