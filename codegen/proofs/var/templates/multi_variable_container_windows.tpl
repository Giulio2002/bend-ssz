@@ win_text @@
def natle(+a: U32, +b: U32, +h: {U32.is_le(a, b) == ${TRUE}}) -> {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == ${TRUE}}:
  FD.logic__subst(Bool, z => {z == ${TRUE}}, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b), h)

def leFS(+len: U32, ${HA}) -> {Nat.is_le(${FS}n, U32.to_nat(len)) == ${TRUE}}: natle(${FS}, len, ha)

def hFSof(${CW}, ${HA}) -> {Nat.is_le(Nat.add(x, ${FS}n), ${P}) == ${TRUE}}:
  FD.nat__le_trans(Nat.add(x, ${FS}n), Nat.add(x, U32.to_nat(len)), ${P}, Order.add_left(x, ${FS}n, U32.to_nat(len), leFS(len, ha)), hw)

# the offset words, read at off + k, k + 4 <= ${FS}
def rdo(${CW}, +k: Nat, +c: U32, +ec: {U32.to_nat(c) == k : Nat}, +hk: {Nat.is_le(Nat.add(k, 4n), ${FS}n) == ${TRUE}},
    +hFS: {Nat.is_le(Nat.add(x, ${FS}n), ${P}) == ${TRUE}})
    -> {B.read32(BF(t, n), U32.add(off, c)) == (BF(t, n), UR.RWN(t, Nat.add(k, x))) : B.Buf & U32}:
  +hr = UR.roomw(x, ${FS}n, k, ${P}, hFS, hk)
  UR.rwx(d, t, n, U32.add(off, c), Nat.add(k, x),
    Equal.trans(Nat, U32.to_nat(U32.add(off, c)), Nat.add(U32.to_nat(c), x), Nat.add(k, x),
      UR.offx(d, off, c, x, eo, FD.nat__lt_trans(d, 28n, 30n, hd, {==}),
        FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(z, x), ${P}) == ${TRUE}}, k, U32.to_nat(c), Equal.sym(Nat, U32.to_nat(c), k, ec),
          FD.nat__lt_le_trans(Nat.add(k, x), Nat.add(Nat.add(k, x), 4n), ${P}, VTX.ltp(Nat.add(k, x), 3n), hr))),
      Equal.cong(Nat, Nat, z => Nat.add(z, x), U32.to_nat(c), k, ec)),
    FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf, hr)

# the children's windows lie in the window
def xle(${CW}, +c: U32, +hc: {Nat.is_le(U32.to_nat(c), U32.to_nat(len)) == ${TRUE}}) -> {Nat.is_le(Nat.add(x, U32.to_nat(c)), ${P}) == ${TRUE}}:
  FD.nat__le_trans(Nat.add(x, U32.to_nat(c)), Nat.add(x, U32.to_nat(len)), ${P}, Order.add_left(x, U32.to_nat(c), U32.to_nat(len), hc), hw)
def eoc(${CW}, +c: U32, +hc: {Nat.is_le(U32.to_nat(c), U32.to_nat(len)) == ${TRUE}})
    -> {U32.to_nat(U32.add(off, c)) == Nat.add(U32.to_nat(c), x) : Nat}:
  VB.add_le_at(off, c, x, 2n+d, eo, FD.nat__lt_trans(2n+d, 30n, 31n, hd, {==}),
    FD.logic__subst(Nat, z => {Nat.is_le(z, ${P}) == ${TRUE}}, Nat.add(x, U32.to_nat(c)), Nat.add(U32.to_nat(c), x), FD.nat__add_comm(x, U32.to_nat(c)), xle(${CA}, c, hc)))

@@ win_text_2 @@
def okA(${CW}, +a: Bool, +ea: {CA(len) == a : Bool})
    -> {${Tn}_ok_len(a, BF(t, n), off, len) == (BF(t, n), Bool.and(a, ${KC[1]})) : B.Buf & Bool}:
  match a:
    case True{}:
      +hFS = hFSof(${CA}, ea)
      %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, ${cv[0]})), (BF(t, n), ${O(0)}), rdo(${CA}, ${cv[0]}n, ${cv[0]}, {==}, {==}, hFS)) :
        {${Tn}_v0(off, len, _) == (BF(t, n), ${KC[1]}) : B.Buf & Bool}
      okc0(${CA}, hFS, CB(t, x))
    case False{}: {==}

# The validator on the window returns the buffer and CHKw(t, x, off, len).
def ok_evalw(${CW}) -> {${Tn}_ok(BF(t, n), off, len) == (BF(t, n), CHKw(t, x, off, len)) : B.Buf & Bool}:
  okA(${CA}, CA(len), {==})

# ---- what the checks give -----------------------------------------------------------------------

@@ win_text_3 @@

# ---- the reader ---------------------------------------------------------------------------------

# c + x <= 4 2^d for c <= ${FS}.
def hcx(+d: Nat, +x: Nat, +len: U32, +c: Nat, +hc: {Nat.is_le(c, ${FS}n) == ${TRUE}}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), ${P}) == ${TRUE}}, ${HA})
    -> {Nat.is_le(Nat.add(c, x), ${P}) == ${TRUE}}:
  FD.nat__le_trans(Nat.add(c, x), Nat.add(U32.to_nat(len), x), ${P},
    Order.add_right(c, U32.to_nat(len), x, FD.nat__le_trans(c, ${FS}n, U32.to_nat(len), hc, leFS(len, ha))),
    FD.logic__subst(Nat, z => {Nat.is_le(z, ${P}) == ${TRUE}}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw))

# The byte offset off + c of header byte c <= ${FS} is at c + x.
def eocf(+d: Nat, +x: Nat, +off: U32, +len: U32, +c: U32, +hc: {Nat.is_le(U32.to_nat(c), ${FS}n) == ${TRUE}}, +eo: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == ${TRUE}}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), ${P}) == ${TRUE}}, ${HA})
    -> {U32.to_nat(U32.add(off, c)) == Nat.add(U32.to_nat(c), x) : Nat}:
  VB.add_le_at(off, c, x, 2n+d, eo, FD.nat__lt_trans(d, 28n, 29n, hd, {==}), hcx(d, x, len, U32.to_nat(c), hc, hw, ha))

# Room for a field of s bytes at c + x, for c + s <= ${FS}.
def roomc(+d: Nat, +x: Nat, +len: U32, +c: Nat, +s: Nat, +hc: {Nat.is_le(Nat.add(c, s), ${FS}n) == ${TRUE}}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), ${P}) == ${TRUE}}, ${HA})
    -> {Nat.is_le(Nat.add(Nat.add(c, x), s), ${P}) == ${TRUE}}:
  UR.roomf(x, U32.to_nat(len), c, s, ${P}, hw, FD.nat__le_trans(Nat.add(c, s), ${FS}n, U32.to_nat(len), hc, leFS(len, ha)))

def OBJw(+d: Nat, ${TXO}) -> ${Tn}: ${OBJ}

# When the window's checks hold, the reader returns OBJw(d, t, x, off, len).
def readw(${CW}, +hchk: ${GOAL})
    -> {${Tn}_read(BF(t, n), off, len) == ${RHS} : ${TY}}:
  +ha = q0(t, x, off, len, hchk)
  +hFS = hFSof(${CA}, ha)
  +hd30 = FD.nat__lt_trans(d, 28n, 30n, hd, {==})
  +hd31 = FD.nat__lt_trans(d, 28n, 31n, hd, {==})
@@ inv_part @@

# ---- the inversion: every value of the window's bytes passes the checks --------------------------

def leU(+a: U32, +b: U32, +x0: Nat, +y: Nat, +ha: {U32.to_nat(a) == x0 : Nat}, +hb: {U32.to_nat(b) == y : Nat}, +h: {Nat.is_le(x0, y) == ${TRUE}})
    -> {U32.is_le(a, b) == ${TRUE}}:
  VMR.u32le(a, b, FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(b)) == ${TRUE}}, x0, U32.to_nat(a), Equal.sym(Nat, U32.to_nat(a), x0, ha),
    FD.logic__subst(Nat, z => {Nat.is_le(x0, z) == ${TRUE}}, y, U32.to_nat(b), Equal.sym(Nat, U32.to_nat(b), y, hb), h)))

# The offset word at k: its limbs are the digits the layout puts there.
def offw(${CW}, +k: Nat, +L2: Nat, +v: Nat, +el: {U32.to_nat(len) == Nat.add(k, 4n+L2) : Nat}, +hv: {Nat.is_le(v, U32.to_nat(len)) == ${TRUE}},
    +eb: {VS.bt(4n, VS.bdr(k, ${WW})) == N.digits(4n, v) : +List<U32>})
    -> {U32.to_nat(UR.RWN(t, Nat.add(k, x))) == v : Nat}:
  +hl = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, z), ${P}) == ${TRUE}}, U32.to_nat(len), Nat.add(k, 4n+L2), el, hw)
  +le0 = Order.add_left(k, Nat.add(x, 4n), Nat.add(x, 4n+L2), Order.add_left(x, 4n, 4n+L2, Order.below_sum(4n, L2)))
  +le1 = FD.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(k, Nat.add(x, 4n+L2))) == ${TRUE}}, Nat.add(k, Nat.add(x, 4n)), Nat.add(Nat.add(k, x), 4n),
    Equal.sym(Nat, Nat.add(Nat.add(k, x), 4n), Nat.add(k, Nat.add(x, 4n)), FD.nat__add_assoc(k, x, 4n)), le0)
  +le2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(Nat.add(k, x), 4n), z) == ${TRUE}}, Nat.add(k, Nat.add(x, 4n+L2)), Nat.add(x, Nat.add(k, 4n+L2)),
    Equal.sym(Nat, Nat.add(x, Nat.add(k, 4n+L2)), Nat.add(k, Nat.add(x, 4n+L2)), FD.lru_nat_algebra__add_swap(x, k, 4n+L2)), le1)
  +hk = FD.nat__le_trans(Nat.add(Nat.add(k, x), 4n), Nat.add(x, Nat.add(k, 4n+L2)), ${P}, le2, hl)
  +wb = FD.logic__subst(Nat, z => {VS.bt(4n, VS.bdr(k, UW.WX(t, x, z))) == F.limbs([UR.RWN(t, Nat.add(k, x))]) : +List<U32>}, Nat.add(k, 4n+L2), U32.to_nat(len),
    Equal.sym(Nat, U32.to_nat(len), Nat.add(k, 4n+L2), el), VRC.wbytes(d, t, x, k, L2, pf, hk))
  VG.digits_word(UR.RWN(t, Nat.add(k, x)), v, VMR.fitsn(d, len, v, FD.nat__lt_trans(d, 28n, 29n, hd, {==}),
      FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), ${P}, Order.left_below_sum(x, U32.to_nat(len)), hw), hv),
    Equal.trans(+List<U32>, F.limbs([UR.RWN(t, Nat.add(k, x))]), VS.bt(4n, VS.bdr(k, ${WW})), N.digits(4n, v),
      Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(k, ${WW})), F.limbs([UR.RWN(t, Nat.add(k, x))]), wb), eb))

@@ inv_part_2 @@

def fin(${CW}${acct(m)}, +b: Bool,
    +e: {Codec.one(SP.optional(b, ${BYTES}), None{}) == ${RHSV} : ${MP}}) -> ${GOAL}:
  match b:
    case False{}: ${ABS('e')}
    case True{}: contra(${CA}${acca(m)}, VVL.vinj(${BYTES}, ${WW}, e))

@@ inv_part_3 @@

# Every value whose spec parts are the window's bytes passes the checks.
def invw(${CW}, +v: S.Value,
    +e: {Codec.parts(v, Spec.${x.n}()) == ${RHSV} : ${MP}}) -> ${GOAL}:
  match v:
${vc}

@@ win_deep @@

# x + c at most NMAX, c <= len
def xleN(+x: Nat, +len: U32, +c: U32, +hc: {Nat.is_le(U32.to_nat(c), U32.to_nat(len)) == True{} : Bool}, +hwN: ${HWN})
    -> {Nat.is_le(Nat.add(x, U32.to_nat(c)), ${NM}) == True{} : Bool}:
  FD.nat__le_trans(Nat.add(x, U32.to_nat(c)), Nat.add(x, U32.to_nat(len)), ${NM}, Order.add_left(x, U32.to_nat(c), U32.to_nat(len), hc), hwN)
