@@ WIN_HEAD @@

def chk5(a: Bool, b: Bool, c: Bool, d: Bool, e: Bool) -> Bool:
  match a:
    case False{}: False{}
    case True{}:
      match b:
        case False{}: False{}
        case True{}:
          match c:
            case False{}: False{}
            case True{}:
              match d:
                case False{}: False{}
                case True{}: e

def c5a(+a: Bool, +b: Bool, +c: Bool, +d: Bool, +e: Bool, +h: {chk5(a, b, c, d, e) == True{} : Bool}) -> {a == True{} : Bool}:
  match a:
    case False{}: h
    case True{}: {==}

def c5b(+b: Bool, +c: Bool, +d: Bool, +e: Bool, +h: {chk5(True{}, b, c, d, e) == True{} : Bool}) -> {b == True{} : Bool}:
  match b:
    case False{}: h
    case True{}: {==}

def c5c(+c: Bool, +d: Bool, +e: Bool, +h: {chk5(True{}, True{}, c, d, e) == True{} : Bool}) -> {c == True{} : Bool}:
  match c:
    case False{}: h
    case True{}: {==}

def c5d(+d: Bool, +e: Bool, +h: {chk5(True{}, True{}, True{}, d, e) == True{} : Bool}) -> {d == True{} : Bool}:
  match d:
    case False{}: h
    case True{}: {==}

def c5e(+e: Bool, +h: {chk5(True{}, True{}, True{}, True{}, e) == True{} : Bool}) -> {e == True{} : Bool}:
  h

def c3_id(+ok: Bool, buf: B.Buf, +off: U32, +len: U32, +o0: U32, +o1: U32) -> {@Tn_c3(ok, buf, off, len, o0, o1) == (buf, ok) : B.Buf & Bool}:
  match ok:
    case True{}: {==}
    case False{}: {==}

def SPO0(t: FD.array__Tree<U32>, +x: Nat) -> U32: UR.RWN(t, x)
def SPO1(t: FD.array__Tree<U32>, +x: Nat) -> U32: UR.RWN(t, 4n+x)
def L1(+t: FD.array__Tree<U32>, +x: Nat) -> U32: U32.sub(SPO1(t, x), @FS)
def L2(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> U32: U32.sub(len, SPO1(t, x))
def X2(+t: FD.array__Tree<U32>, +x: Nat) -> Nat: Nat.add(U32.to_nat(SPO1(t, x)), x)
def CK(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> Bool: Bool.and(U32.is_le(@FS, SPO1(t, x)), U32.is_le(SPO1(t, x), len))
def D1(+t: FD.array__Tree<U32>, +x: Nat, +off: U32) -> Bool: YW.CHKw(t, @X1, U32.add(off, @FS), L1(t, x))
def D2(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool: YW.CHKw(t, X2(t, x), U32.add(off, SPO1(t, x)), L2(t, x, len))

# The checks: the size, the first offset, the second offset between it and the end, and
# @Y's checks on the two windows.
def CHKw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool:
  chk5(U32.is_le(@FS, len), U32.is_eq(SPO0(t, x), @FS), CK(t, x, len), D1(t, x, off), D2(t, x, off, len))

def leFS(+len: U32, @HA) -> {Nat.is_le(@FSn, U32.to_nat(len)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(@FS, len), Nat.is_le(@FSn, U32.to_nat(len)), VU.le_u32(@FS, len), ha)

def u32le(+a: U32, +b: U32, +h: {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool}) -> {U32.is_le(a, b) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(a), U32.to_nat(b)), U32.is_le(a, b), Equal.sym(Bool, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b)), h)

def subc(+n: U32, +k: U32, +y: Nat, +e: {U32.to_nat(n) == Nat.add(U32.to_nat(k), y) : Nat}) -> {U32.to_nat(U32.sub(n, k)) == y : Nat}:
  +le = FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(k), z) == True{} : Bool}, Nat.add(U32.to_nat(k), y), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), Nat.add(U32.to_nat(k), y), e), FD.nat__le_add_right(U32.to_nat(k), y))
  %Equal.sym(Nat, U32.to_nat(U32.sub(n, k)), Nat.sub(U32.to_nat(n), U32.to_nat(k)), FD.u32__sub_nat(n, k, le)) : {_ == y : Nat}
  %Equal.sym(Nat, U32.to_nat(n), Nat.add(U32.to_nat(k), y), e) : {Nat.sub(_, U32.to_nat(k)) == y : Nat}
  FD.nat__add_sub_cancel(U32.to_nat(k), y)

# c + x <= 4 2^d for c <= len.
def hcx(+d: Nat, +x: Nat, +len: U32, +c: Nat, +hc: {Nat.is_le(c, U32.to_nat(len)) == True{} : Bool}, @HW)
    -> {Nat.is_le(Nat.add(c, x), @P4) == True{} : Bool}:
  FD.nat__le_trans(Nat.add(c, x), Nat.add(U32.to_nat(len), x), @P4, Order.add_right(c, U32.to_nat(len), x, hc),
    FD.logic__subst(Nat, z => {Nat.is_le(z, @P4) == True{} : Bool}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw))

# The byte offset off + c, for c <= len, is at c + x.
def eoc(+d: Nat, +x: Nat, +off: U32, +len: U32, +c: U32, +hc: {Nat.is_le(U32.to_nat(c), U32.to_nat(len)) == True{} : Bool}, @WHX)
    -> {U32.to_nat(U32.add(off, c)) == Nat.add(U32.to_nat(c), x) : Nat}:
  VB.add_le_at(off, c, x, 2n+d, eo, FD.nat__lt_trans(d, 28n, 29n, hd, {==}), hcx(d, x, len, U32.to_nat(c), hc, hw))

def hcF(+len: U32, +c: Nat, +hc: {Nat.is_le(c, @FSn) == True{} : Bool}, @HA) -> {Nat.is_le(c, U32.to_nat(len)) == True{} : Bool}:
  FD.nat__le_trans(c, @FSn, U32.to_nat(len), hc, leFS(len, ha))

# Room for a field of s bytes at c + x, for c + s <= @FS.
def roomc(+d: Nat, +x: Nat, +len: U32, +c: Nat, +s: Nat, +hc: {Nat.is_le(Nat.add(c, s), @FSn) == True{} : Bool}, @HW, @HA)
    -> {Nat.is_le(Nat.add(Nat.add(c, x), s), @P4) == True{} : Bool}:
  UR.roomf(x, U32.to_nat(len), c, s, @P4, hw, hcF(len, Nat.add(c, s), hc, ha))

# ---- the two windows ---------------------------------------------------------------------------

def ck1(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {CK(t, x, len) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(@FS), U32.to_nat(SPO1(t, x))) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(@FS, SPO1(t, x)), Nat.is_le(U32.to_nat(@FS), U32.to_nat(SPO1(t, x))), VU.le_u32(@FS, SPO1(t, x)),
    FD.logic__and_left(U32.is_le(@FS, SPO1(t, x)), U32.is_le(SPO1(t, x), len), hc))

def ck2(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {CK(t, x, len) == True{} : Bool})
    -> {Nat.is_le(U32.to_nat(SPO1(t, x)), U32.to_nat(len)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(SPO1(t, x), len), Nat.is_le(U32.to_nat(SPO1(t, x)), U32.to_nat(len)), VU.le_u32(SPO1(t, x), len),
    FD.logic__and_right(U32.is_le(@FS, SPO1(t, x)), U32.is_le(SPO1(t, x), len), hc))

def eL1(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {CK(t, x, len) == True{} : Bool})
    -> {Nat.add(U32.to_nat(@FS), U32.to_nat(L1(t, x))) == U32.to_nat(SPO1(t, x)) : Nat}:
  %Equal.sym(Nat, U32.to_nat(L1(t, x)), Nat.sub(U32.to_nat(SPO1(t, x)), U32.to_nat(@FS)), FD.u32__sub_nat(SPO1(t, x), @FS, ck1(t, x, len, hc))) :
    {Nat.add(U32.to_nat(@FS), _) == U32.to_nat(SPO1(t, x)) : Nat}
  FD.nat__sub_add(U32.to_nat(SPO1(t, x)), U32.to_nat(@FS), ck1(t, x, len, hc))

def eL2(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +hc: {CK(t, x, len) == True{} : Bool})
    -> {Nat.add(U32.to_nat(SPO1(t, x)), U32.to_nat(L2(t, x, len))) == U32.to_nat(len) : Nat}:
  %Equal.sym(Nat, U32.to_nat(L2(t, x, len)), Nat.sub(U32.to_nat(len), U32.to_nat(SPO1(t, x))), FD.u32__sub_nat(len, SPO1(t, x), ck2(t, x, len, hc))) :
    {Nat.add(U32.to_nat(SPO1(t, x)), _) == U32.to_nat(len) : Nat}
  FD.nat__sub_add(U32.to_nat(len), U32.to_nat(SPO1(t, x)), ck2(t, x, len, hc))

def eo1(+d: Nat, +x: Nat, +off: U32, +len: U32, @WHX, @HA) -> {U32.to_nat(U32.add(off, @FS)) == @X1 : Nat}:
  eoc(d, x, off, len, @FS, leFS(len, ha), eo, hd, hw)

def eo2(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, @WHX, +hc: {CK(t, x, len) == True{} : Bool})
    -> {U32.to_nat(U32.add(off, SPO1(t, x))) == X2(t, x) : Nat}:
  eoc(d, x, off, len, SPO1(t, x), ck2(t, x, len, hc), eo, hd, hw)

# (a + x) + b = x + (a + b)
def swp(+a: Nat, +x: Nat, +b: Nat) -> {Nat.add(Nat.add(a, x), b) == Nat.add(x, Nat.add(a, b)) : Nat}:
  Equal.trans(Nat, Nat.add(Nat.add(a, x), b), Nat.add(a, Nat.add(x, b)), Nat.add(x, Nat.add(a, b)), FD.nat__add_assoc(a, x, b), FD.lru_nat_algebra__add_swap(a, x, b))

def hw1(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, @HW, +hc: {CK(t, x, len) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(U32.to_nat(@FS), x), U32.to_nat(L1(t, x))), @P4) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(Nat.add(U32.to_nat(@FS), x), U32.to_nat(L1(t, x))), Nat.add(x, Nat.add(U32.to_nat(@FS), U32.to_nat(L1(t, x)))), swp(U32.to_nat(@FS), x, U32.to_nat(L1(t, x)))) :
    {Nat.is_le(_, @P4) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(U32.to_nat(@FS), U32.to_nat(L1(t, x))), U32.to_nat(SPO1(t, x)), eL1(t, x, len, hc)) : {Nat.is_le(Nat.add(x, _), @P4) == True{} : Bool}
  FD.nat__le_trans(Nat.add(x, U32.to_nat(SPO1(t, x))), Nat.add(x, U32.to_nat(len)), @P4, Order.add_left(x, U32.to_nat(SPO1(t, x)), U32.to_nat(len), ck2(t, x, len, hc)), hw)

def hw2(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, @HW, +hc: {CK(t, x, len) == True{} : Bool})
    -> {Nat.is_le(Nat.add(X2(t, x), U32.to_nat(L2(t, x, len))), @P4) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(Nat.add(U32.to_nat(SPO1(t, x)), x), U32.to_nat(L2(t, x, len))), Nat.add(x, Nat.add(U32.to_nat(SPO1(t, x)), U32.to_nat(L2(t, x, len)))), swp(U32.to_nat(SPO1(t, x)), x, U32.to_nat(L2(t, x, len)))) :
    {Nat.is_le(_, @P4) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(U32.to_nat(SPO1(t, x)), U32.to_nat(L2(t, x, len))), U32.to_nat(len), eL2(t, x, len, hc)) : {Nat.is_le(Nat.add(x, _), @P4) == True{} : Bool}
  hw

# ---- the validator ------------------------------------------------------------------------------

def rdoff0(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, @HA)
    -> {B.read32(@BF, U32.add(off, 0)) == (@BF, SPO0(t, x)) : B.Buf & U32}:
  UR.rwx(d, t, n, U32.add(off, 0), x, eoc(d, x, off, len, 0, FD.nat__zero_le(U32.to_nat(len)), eo, hd, hw), FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf,
    roomc(d, x, len, 0n, 4n, {==}, hw, ha))

def rdoff1(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, @HA)
    -> {B.read32(@BF, U32.add(off, 4)) == (@BF, SPO1(t, x)) : B.Buf & U32}:
  UR.rwx(d, t, n, U32.add(off, 4), 4n+x, eoc(d, x, off, len, 4, hcF(len, 4n, {==}, ha), eo, hd, hw), FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf,
    roomc(d, x, len, 4n, 4n, {==}, hw, ha))

def okc2(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, +hc: {CK(t, x, len) == True{} : Bool},
    +b: Bool, +eb: {D1(t, x, off) == b : Bool})
    -> {@Tn_c2(b, @BF, off, len, @FS, SPO1(t, x)) == (@BF, chk5(True{}, True{}, True{}, b, D2(t, x, off, len))) : B.Buf & Bool}:
  match b:
    case False{}: {==}
    case True{}:
      %Equal.sym(B.Buf & Bool, T.@Y_ok(@BF, U32.add(off, SPO1(t, x)), U32.sub(len, SPO1(t, x))), (@BF, D2(t, x, off, len)),
          YW.ok_evalw(d, t, n, X2(t, x), U32.add(off, SPO1(t, x)), L2(t, x, len), eo2(d, t, x, off, len, eo, hd, hw, hc), hd, hw2(d, t, x, len, hw, hc), pf)) :
        {@Tn_v3(off, len, @FS, SPO1(t, x), _) == (@BF, D2(t, x, off, len)) : B.Buf & Bool}
      c3_id(D2(t, x, off, len), @BF, off, len, @FS, SPO1(t, x))

def okc1(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, @HA,
    +b: Bool, +eb: {CK(t, x, len) == b : Bool})
    -> {@Tn_c1(b, @BF, off, len, @FS, SPO1(t, x)) == (@BF, chk5(True{}, True{}, b, D1(t, x, off), D2(t, x, off, len))) : B.Buf & Bool}:
  match b:
    case False{}: {==}
    case True{}:
      %Equal.sym(B.Buf & Bool, T.@Y_ok(@BF, U32.add(off, @FS), U32.sub(SPO1(t, x), @FS)), (@BF, D1(t, x, off)),
          YW.ok_evalw(d, t, n, @X1, U32.add(off, @FS), L1(t, x), eo1(d, x, off, len, eo, hd, hw, ha), hd, hw1(d, t, x, len, hw, eb), pf)) :
        {@Tn_v2(off, len, @FS, SPO1(t, x), _) == (@BF, chk5(True{}, True{}, True{}, D1(t, x, off), D2(t, x, off, len))) : B.Buf & Bool}
      okc2(d, t, n, x, off, len, eo, hd, hw, pf, eb, D1(t, x, off), {==})

def okc0(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, @HA,
    +b: Bool, +eb: {U32.is_eq(SPO0(t, x), @FS) == b : Bool})
    -> {@Tn_c0(b, @BF, off, len, SPO0(t, x)) == (@BF, chk5(True{}, b, CK(t, x, len), D1(t, x, off), D2(t, x, off, len))) : B.Buf & Bool}:
  match b:
    case False{}: {==}
    case True{}:
      +epo = FD.u32alg__eq_of(SPO0(t, x), @FS, eb)
      %Equal.sym(U32, SPO0(t, x), @FS, epo) :
        {@Tn_v1(off, len, _, B.read32(@BF, U32.add(off, 4))) == (@BF, chk5(True{}, True{}, CK(t, x, len), D1(t, x, off), D2(t, x, off, len))) : B.Buf & Bool}
      %Equal.sym(B.Buf & U32, B.read32(@BF, U32.add(off, 4)), (@BF, SPO1(t, x)), rdoff1(d, t, n, x, off, len, eo, hd, hw, pf, ha)) :
        {@Tn_v1(off, len, @FS, _) == (@BF, chk5(True{}, True{}, CK(t, x, len), D1(t, x, off), D2(t, x, off, len))) : B.Buf & Bool}
      okc1(d, t, n, x, off, len, eo, hd, hw, pf, ha, CK(t, x, len), {==})

def okl(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF,
    +a: Bool, +ea: {U32.is_le(@FS, len) == a : Bool})
    -> {@Tn_ok_len(a, @BF, off, len) == (@BF, chk5(a, U32.is_eq(SPO0(t, x), @FS), CK(t, x, len), D1(t, x, off), D2(t, x, off, len))) : B.Buf & Bool}:
  match a:
    case False{}: {==}
    case True{}:
      %Equal.sym(B.Buf & U32, B.read32(@BF, U32.add(off, 0)), (@BF, SPO0(t, x)), rdoff0(d, t, n, x, off, len, eo, hd, hw, pf, ea)) :
        {@Tn_v0(off, len, _) == (@BF, chk5(True{}, U32.is_eq(SPO0(t, x), @FS), CK(t, x, len), D1(t, x, off), D2(t, x, off, len))) : B.Buf & Bool}
      okc0(d, t, n, x, off, len, eo, hd, hw, pf, ea, U32.is_eq(SPO0(t, x), @FS), {==})

# The validator on the window returns the buffer and CHKw(t, x, off, len).
def ok_evalw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF)
    -> {@Tn_ok(@BF, off, len) == (@BF, CHKw(t, x, off, len)) : B.Buf & Bool}:
  okl(d, t, n, x, off, len, eo, hd, hw, pf, U32.is_le(@FS, len), {==})

# The first offset word, once checked, reads as @FS.
def rdo0(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, @WHX, @PF, @HA, +epo: {SPO0(t, x) == @FS : U32})
    -> {B.read32(@BF, U32.add(off, 0)) == (@BF, @FS) : B.Buf & U32}:
  %Equal.sym(B.Buf & U32, B.read32(@BF, U32.add(off, 0)), (@BF, SPO0(t, x)), rdoff0(d, t, n, x, off, len, eo, hd, hw, pf, ha)) :
    {_ == (@BF, @FS) : B.Buf & U32}
  %Equal.sym(U32, SPO0(t, x), @FS, epo) : {(@BF, _) == (@BF, @FS) : B.Buf & U32}
  {==}

@@ win_text @@

# When the window's checks hold, the reader returns OBJw(d, t, x, off, len).
def readw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, ${VX.WHX}, ${VX.PF},
    +hchk: {CHKw(t, x, off, len) == True{} : Bool})
    -> {${Tn}_read(${BF}, off, len) == ${RHS} : ${TY}}:
  +a = U32.is_le(${FS}, len)
  +b = U32.is_eq(SPO0(t, x), ${FS})
  +c = CK(t, x, len)
  +dd = D1(t, x, off)
  +e = D2(t, x, off, len)
  +ha = c5a(a, b, c, dd, e, hchk)
  +h1 = FD.logic__subst(Bool, z => {chk5(z, b, c, dd, e) == True{} : Bool}, a, True{}, ha, hchk)
  +hb = c5b(b, c, dd, e, h1)
  +h2 = FD.logic__subst(Bool, z => {chk5(True{}, z, c, dd, e) == True{} : Bool}, b, True{}, hb, h1)
  +hc = c5c(c, dd, e, h2)
  +h3 = FD.logic__subst(Bool, z => {chk5(True{}, True{}, z, dd, e) == True{} : Bool}, c, True{}, hc, h2)
  +hd1 = c5d(dd, e, h3)
  +h4 = FD.logic__subst(Bool, z => {chk5(True{}, True{}, True{}, z, e) == True{} : Bool}, dd, True{}, hd1, h3)
  rdw_go(d, t, n, x, off, len, eo, hd, hw, pf, ha, FD.u32alg__eq_of(SPO0(t, x), ${FS}, hb), hc, hd1, c5e(e, h4))

@@ inv_part @@

# ---- every value whose spec parts are the window's bytes passes the checks ----------------------

# The four bytes at offset P of the window are the word at P + x.
def byteAt(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +len: U32, +P: Nat, +R: Nat, +en: {U32.to_nat(len) == Nat.add(P, 4n+R) : Nat}, @PF, @HW)
    -> {VS.bt(4n, VS.bdr(P, ${WXn})) == F.limbs([UR.RWN(t, Nat.add(P, x))]) : +List<U32>}:
  +hw2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, z), @P4) == True{} : Bool}, U32.to_nat(len), Nat.add(P, 4n+R), en, hw)
  %Equal.sym(Nat, U32.to_nat(len), Nat.add(P, 4n+R), en) : {VS.bt(4n, VS.bdr(P, UW.WX(t, x, _))) == F.limbs([UR.RWN(t, Nat.add(P, x))]) : +List<U32>}
  UW.byteWX(d, t, x, P, R, pf, hw2)

def inv_tail(${ARGS}, +hb0: {VS.bt(4n, VS.bdr(0n, ${WXn})) == ${FSL} : +List<U32>},
    +hv0: S.Value, +ys0: +List<U32>, +hv1: S.Value, +ys1: +List<U32>, +f1: ${F1}, +f2: ${F2_}, +f3: ${F3}, +em0: ${E0}, +em1: ${E1})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  +K = Nat.add(${K0}, ${K1})
  +en = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, ${WXn}), Nat.add(${FS}n, K), Equal.sym(Nat, List.length(&2, U32, ${WXn}), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)), f2)
  +hl = FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), @P4, Order.left_below_sum(x, U32.to_nat(len)), hw)
  +ha = u32le(${FS}, len, FD.logic__subst(Nat, z => {Nat.is_le(${FS}n, z) == True{} : Bool}, Nat.add(${FS}n, K), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), Nat.add(${FS}n, K), en), Order.below_sum(${FS}n, K)))
  +epo = XI.wordFS(SPO0(t, x), Equal.trans(+List<U32>, F.limbs([SPO0(t, x)]), VS.bt(4n, VS.bdr(0n, ${WXn})), ${FSL},
    Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(0n, ${WXn})), F.limbs([SPO0(t, x)]), byteAt(d, t, x, len, 0n, Nat.add(${FS - 4}n, K), en, pf, hw)), hb0))
  +le1 = FD.nat__le_trans(Nat.add(${FS}n, ${K0}), Nat.add(${FS}n, K), @P4, Order.add_left(${FS}n, ${K0}, K, Order.below_sum(${K0}, ${K1})),
    FD.logic__subst(Nat, z => {Nat.is_le(z, @P4) == True{} : Bool}, U32.to_nat(len), Nat.add(${FS}n, K), en, hl))
  +e1 = VG.digits_word(SPO1(t, x), Nat.add(${FS}n, ${K0}), VBZ.fitq(d, Nat.add(${FS}n, ${K0}), le1, FD.nat__lt_trans(d, 28n, 30n, hd, {==})),
    Equal.trans(+List<U32>, I.limb(SPO1(t, x)), VS.bt(4n, VS.bdr(4n, ${WXn})), N.digits(4n, Nat.add(${FS}n, ${K0})),
      Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(4n, ${WXn})), I.limb(SPO1(t, x)), byteAt(d, t, x, len, 4n, Nat.add(${FS - 8}n, K), en, pf, hw)), f1))
  +hc1 = u32le(${FS}, SPO1(t, x), FD.logic__subst(Nat, z => {Nat.is_le(${FS}n, z) == True{} : Bool}, Nat.add(${FS}n, ${K0}), U32.to_nat(SPO1(t, x)), Equal.sym(Nat, U32.to_nat(SPO1(t, x)), Nat.add(${FS}n, ${K0}), e1), Order.below_sum(${FS}n, ${K0})))
  +e2 = Equal.trans(Nat, U32.to_nat(len), Nat.add(${FS}n, K), Nat.add(U32.to_nat(SPO1(t, x)), ${K1}), en,
    Equal.trans(Nat, Nat.add(${FS}n, K), Nat.add(Nat.add(${FS}n, ${K0}), ${K1}), Nat.add(U32.to_nat(SPO1(t, x)), ${K1}),
      Equal.sym(Nat, Nat.add(Nat.add(${FS}n, ${K0}), ${K1}), Nat.add(${FS}n, K), FD.nat__add_assoc(${FS}n, ${K0}, ${K1})),
      Equal.cong(Nat, Nat, z => Nat.add(z, ${K1}), Nat.add(${FS}n, ${K0}), U32.to_nat(SPO1(t, x)), Equal.sym(Nat, U32.to_nat(SPO1(t, x)), Nat.add(${FS}n, ${K0}), e1))))
  +hc2 = u32le(SPO1(t, x), len, FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(SPO1(t, x)), z) == True{} : Bool}, Nat.add(U32.to_nat(SPO1(t, x)), ${K1}), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), Nat.add(U32.to_nat(SPO1(t, x)), ${K1}), e2), Order.below_sum(U32.to_nat(SPO1(t, x)), ${K1})))
  +hc = V.and_true(U32.is_le(${FS}, SPO1(t, x)), U32.is_le(SPO1(t, x), len), hc1, hc2)
  +el1 = subc(SPO1(t, x), ${FS}, ${K0}, e1)
  +el2 = subc(len, SPO1(t, x), ${K1}, e2)
  +ew = Equal.trans(+List<U32>, UW.WX(t, Nat.add(${FS}n, x), K), VS.bdr(${FS}n, UW.WX(t, x, Nat.add(${FS}n, K))), List.append(&2, U32, ys0, ys1),
    Equal.sym(+List<U32>, VS.bdr(${FS}n, UW.WX(t, x, Nat.add(${FS}n, K))), UW.WX(t, Nat.add(${FS}n, x), K), UW.tailWX(t, x, ${FS}n, K)),
    FD.logic__subst(Nat, z => {VS.bdr(${FS}n, UW.WX(t, x, z)) == List.append(&2, U32, ys0, ys1) : +List<U32>}, U32.to_nat(len), Nat.add(${FS}n, K), en, f3))
  +ey0 = Equal.trans(+List<U32>, ys0, UW.WX(t, Nat.add(${FS}n, x), ${K0}), UW.WX(t, ${X1}, ${L1n}), VX2.wx_fst(t, Nat.add(${FS}n, x), ys0, ys1, ew),
    Equal.cong(Nat, +List<U32>, z => UW.WX(t, Nat.add(${FS}n, x), z), ${K0}, ${L1n}, Equal.sym(Nat, ${L1n}, ${K0}, el1)))
  +pos = Equal.trans(Nat, Nat.add(${K0}, Nat.add(${FS}n, x)), Nat.add(Nat.add(${FS}n, ${K0}), x), X2(t, x),
    Equal.trans(Nat, Nat.add(${K0}, Nat.add(${FS}n, x)), Nat.add(Nat.add(${K0}, ${FS}n), x), Nat.add(Nat.add(${FS}n, ${K0}), x),
      Equal.sym(Nat, Nat.add(Nat.add(${K0}, ${FS}n), x), Nat.add(${K0}, Nat.add(${FS}n, x)), FD.nat__add_assoc(${K0}, ${FS}n, x)),
      Equal.cong(Nat, Nat, z => Nat.add(z, x), Nat.add(${K0}, ${FS}n), Nat.add(${FS}n, ${K0}), FD.nat__add_comm(${K0}, ${FS}n))),
    Equal.cong(Nat, Nat, z => Nat.add(z, x), Nat.add(${FS}n, ${K0}), U32.to_nat(SPO1(t, x)), Equal.sym(Nat, U32.to_nat(SPO1(t, x)), Nat.add(${FS}n, ${K0}), e1)))
  +ey1 = Equal.trans(+List<U32>, ys1, UW.WX(t, Nat.add(${K0}, Nat.add(${FS}n, x)), ${K1}), UW.WX(t, X2(t, x), ${L2n}), VX2.wx_snd(t, Nat.add(${FS}n, x), ys0, ys1, ew),
    Equal.trans(+List<U32>, UW.WX(t, Nat.add(${K0}, Nat.add(${FS}n, x)), ${K1}), UW.WX(t, X2(t, x), ${K1}), UW.WX(t, X2(t, x), ${L2n}),
      Equal.cong(Nat, +List<U32>, z => UW.WX(t, z, ${K1}), Nat.add(${K0}, Nat.add(${FS}n, x)), X2(t, x), pos),
      Equal.cong(Nat, +List<U32>, z => UW.WX(t, X2(t, x), z), ${K1}, ${L2n}, Equal.sym(Nat, ${L2n}, ${K1}, el2))))
  +d1 = YW.invw(d, t, n, ${X1}, U32.add(off, ${FS}), L1(t, x), eo1(d, x, off, len, eo, hd, hw, ha), hd, hw1(d, t, x, len, hw, hc), pf, hv0,
    FD.logic__subst(+List<U32>, z => {Codec.parts(hv0, Spec.${Y}()) == Some{[S.Variable{z}]} : ${MP}}, ys0, UW.WX(t, ${X1}, ${L1n}), ey0, em0))
  +d2 = YW.invw(d, t, n, X2(t, x), U32.add(off, SPO1(t, x)), L2(t, x, len), eo2(d, t, x, off, len, eo, hd, hw, hc), hd, hw2(d, t, x, len, hw, hc), pf, hv1,
    FD.logic__subst(+List<U32>, z => {Codec.parts(hv1, Spec.${Y}()) == Some{[S.Variable{z}]} : ${MP}}, ys1, UW.WX(t, X2(t, x), ${L2n}), ey1, em1))
  %Equal.sym(Bool, U32.is_le(${FS}, len), True{}, ha) : {chk5(_, U32.is_eq(SPO0(t, x), ${FS}), CK(t, x, len), D1(t, x, off), D2(t, x, off, len)) == True{} : Bool}
  %Equal.sym(U32, SPO0(t, x), ${FS}, epo) : {chk5(True{}, U32.is_eq(_, ${FS}), CK(t, x, len), D1(t, x, off), D2(t, x, off, len)) == True{} : Bool}
  %Equal.sym(Bool, CK(t, x, len), True{}, hc) : {chk5(True{}, U32.is_eq(${FS}, ${FS}), _, D1(t, x, off), D2(t, x, off, len)) == True{} : Bool}
  %Equal.sym(Bool, D1(t, x, off), True{}, d1) : {chk5(True{}, U32.is_eq(${FS}, ${FS}), True{}, _, D2(t, x, off, len)) == True{} : Bool}
  d2

def inv_e(${ARGS}, +hb0: {VS.bt(4n, VS.bdr(0n, ${WXn})) == ${FSL} : +List<U32>},
    +hv0: S.Value, +ys0: +List<U32>, +hv1: S.Value, +ys1: +List<U32>, +f1: ${F1}, +f2: ${F2_}, +f3: ${F3}, r: DK.P2(${E0}, ${E1}))
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  (+em0, em1) = r
  inv_tail(${A_}, hb0, hv0, ys0, hv1, ys1, f1, f2, f3, em0, em1)

def inv_d(${ARGS}, +hb0: {VS.bt(4n, VS.bdr(0n, ${WXn})) == ${FSL} : +List<U32>},
    +hv0: S.Value, +ys0: +List<U32>, +hv1: S.Value, +ys1: +List<U32>, +f1: ${F1}, +f2: ${F2_}, r: DK.P2(${F3}, DK.P2(${E0}, ${E1})))
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  (+f3, r2) = r
  inv_e(${A_}, hb0, hv0, ys0, hv1, ys1, f1, f2, f3, r2)

def inv_c(${ARGS}, +hb0: {VS.bt(4n, VS.bdr(0n, ${WXn})) == ${FSL} : +List<U32>},
    +hv0: S.Value, +ys0: +List<U32>, +hv1: S.Value, +ys1: +List<U32>, +f1: ${F1}, r: DK.P2(${F2_}, DK.P2(${F3}, DK.P2(${E0}, ${E1}))))
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  (+f2, r2) = r
  inv_d(${A_}, hb0, hv0, ys0, hv1, ys1, f1, f2, r2)

def inv_b(${ARGS}, +hb0: {VS.bt(4n, VS.bdr(0n, ${WXn})) == ${FSL} : +List<U32>},
    +hv0: S.Value, +ys0: +List<U32>, +hv1: S.Value, +ys1: +List<U32>, r: DK.P2(${F1}, DK.P2(${F2_}, DK.P2(${F3}, DK.P2(${E0}, ${E1})))))
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  (+f1, r2) = r
  inv_c(${A_}, hb0, hv0, ys0, hv1, ys1, f1, r2)

def inv_facts(${ARGS}, facts: XI.FACTS2(${WXn})) -> {CHKw(t, x, off, len) == True{} : Bool}:
  (+hb0, ex) = facts
  (+hv0, r1) = ex
  (+ys0, r2) = r1
  (+hv1, r3) = r2
  (+ys1, r4) = r3
  inv_b(${A_}, hb0, hv0, ys0, hv1, ys1, r4)

# Every value whose spec parts are the window's bytes passes the checks.
def invw(${ARGS}, +v: S.Value, +e: {Codec.parts(v, Spec.${n}()) == Some{[S.Variable{${WXn}}]} : ${MP}})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  inv_facts(${A_}, XI.inv_p(v, ${WXn}, e))

@@ dec_text @@

def BF(t: FD.array__Tree<U32>, +n: U32) -> B.Buf: UA.BF(t, n)
def CHK(+t: FD.array__Tree<U32>, +n: U32) -> Bool: W.CHKw(t, 0n, 0, n)
def OBJ(+d: Nat, +t: FD.array__Tree<U32>, +n: U32) -> ${Tn}: W.OBJw(d, t, 0n, 0, n)
def VAL(+t: FD.array__Tree<U32>, +n: U32) -> S.Value: W.VALw(t, 0n, n)
def VW(+t: FD.array__Tree<U32>, +n: U32) -> +List<U32>: VS.bt(U32.to_nat(n), F.limbs(FD.array__slots(U32, t)))

# The validator returns the buffer and CHK(t, n).
law ok_eval:
${q}
  {${Tn}_ok(BF(t, n), 0, n) == (BF(t, n), CHK(t, n)) : B.Buf & Bool}
def ok_eval(d, t, n, pf, hd, hn):
  W.ok_evalw(d, t, n, 0n, 0, n, {==}, hd, hn, pf)

# Every buffer the validator accepts decodes to OBJ(d, t, n).
law decode_accept:
${q}
  for +hchk: {CHK(t, n) == True{} : Bool}
  {${Tn}_decode(BF(t, n), n) == (BF(t, n), Some{OBJ(d, t, n)}) : ${D}}
def decode_accept(d, t, n, pf, hd, hn, hchk):
  %Equal.sym(B.Buf & Bool, ${Tn}_ok(BF(t, n), 0, n), (BF(t, n), CHK(t, n)), ok_eval(d, t, n, pf, hd, hn)) :
    {${Tn}_built(n, _) == (BF(t, n), Some{OBJ(d, t, n)}) : ${D}}
  %Equal.sym(Bool, CHK(t, n), True{}, hchk) :
    {${Tn}_built(n, (BF(t, n), _)) == (BF(t, n), Some{OBJ(d, t, n)}) : ${D}}
  %Equal.sym(B.Buf & ${Tn}, ${Tn}_read(BF(t, n), 0, n), (BF(t, n), OBJ(d, t, n)), W.readw(d, t, n, 0n, 0, n, {==}, hd, hn, pf, hchk)) :
    {${Tn}_some(_) == (BF(t, n), Some{OBJ(d, t, n)}) : ${D}}
  {==}

# The bytes of every buffer the validator accepts are the spec encoding of the
# decoded object's value.
def VALe(+t: FD.array__Tree<U32>, +n: U32) -> {W.VALw(t, 0n, n) == VAL(t, n) : S.Value}: {==}
def VWe(+t: FD.array__Tree<U32>, +n: U32) -> {UW.WX(t, 0n, U32.to_nat(n)) == VW(t, n) : +List<U32>}: {==}

law decode_spec:
${q}
  for +hchk: {CHK(t, n) == True{} : Bool}
  Decoding.decodes(Spec.${n}(), VW(t, n), VAL(t, n))
def decode_spec(d, t, n, pf, hd, hn, hchk):
  # the value and bytes in specw's own terms first (VALe, VWe), then F.encoding_of_var over
  # them: comparing the spec encoding of VAL with that of W.VALw ran the spec encoder (3 s)
  %VALe(t, n) : Decoding.decodes(Spec.${n}(), VW(t, n), _)
  %VWe(t, n) : Decoding.decodes(Spec.${n}(), _, W.VALw(t, 0n, n))
  F.encoding_of_var(Spec.${n}(), W.VALw(t, 0n, n), UW.WX(t, 0n, U32.to_nat(n)), W.specw(d, t, n, 0n, 0, n, {==}, hd, hn, pf, hchk))

# Every spec value of an accepted buffer's bytes is the decoded object's value.
law decode_unique:
${q}
  for +hchk: {CHK(t, n) == True{} : Bool}
  for +v: S.Value
  for spec: Decoding.decodes(Spec.${n}(), VW(t, n), v)
  {v == VAL(t, n) : S.Value}
def decode_unique(d, t, n, pf, hd, hn, hchk, v, spec):
  # the validator's acceptance of the schema by evaluation (decode_unique.valid_unique): image_unique's
  # legality form imports the compatibility_* chain and every name's legality witness
  DCO.valid_unique(Spec.${n}(), VW(t, n), v, VAL(t, n), {==}, spec, decode_spec(d, t, n, pf, hd, hn, hchk))

# When the validator refuses, no value is related to the buffer's bytes.
law decode_reject:
${q}
  for +hchk: {CHK(t, n) == False{} : Bool}
  Decoding.outside_image(Spec.${n}(), VW(t, n))
def decode_reject(d, t, n, pf, hd, hn, hchk):
  v => e => FD.logic__true_false(Equal.trans(Bool, True{}, CHK(t, n), False{},
    Equal.sym(Bool, CHK(t, n), True{}, W.inv_facts(d, t, n, 0n, 0, n, {==}, hd, hn, pf, XI.inv_v(v, VW(t, n), e))), hchk))

# When the validator refuses, the decoder returns None and the buffer.
law decode_none:
${q}
  for +hchk: {CHK(t, n) == False{} : Bool}
  {${Tn}_decode(BF(t, n), n) == (BF(t, n), None{}) : ${D}}
def decode_none(d, t, n, pf, hd, hn, hchk):
  %Equal.sym(B.Buf & Bool, ${Tn}_ok(BF(t, n), 0, n), (BF(t, n), CHK(t, n)), ok_eval(d, t, n, pf, hd, hn)) :
    {${Tn}_built(n, _) == (BF(t, n), None{}) : ${D}}
  %Equal.sym(Bool, CHK(t, n), False{}, hchk) :
    {${Tn}_built(n, (BF(t, n), _)) == (BF(t, n), None{}) : ${D}}
  {==}
