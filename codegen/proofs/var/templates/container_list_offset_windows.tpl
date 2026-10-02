@@ READER_TAIL @@

def R4(s: Bool, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> T.@LP_Seq:
  match s:
    case True{}: T.@LP_Seq{T.@LP_fill(0n), 0}
    case False{}: RQ(NQ(t, x), d, t, x, off, len)

def RZ(z: Bool, +d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> T.@LP_Seq:
  match z:
    case True{}: T.@LP_Seq{T.@LP_fill(0n), 0}
    case False{}: R4(U32.is_lt(len, 4), d, t, x, off, len)

def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> T.@LP_Seq: RZ(U32.is_eq(len, 0), d, t, x, off, len)

@@ READER_TOP @@

def hk_l(+h: Bool, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +e: {HK(h, t, x, off, len) == True{} : Bool}) -> {h == True{} : Bool}:
  match h:
    case True{}: {==}
    case False{}: e

def rd4(@CW, +s: Bool, +es: {U32.is_lt(len, 4) == s : Bool}, +hc: {L4(s, t, x, off, len) == True{} : Bool})
    -> {T.@LP_read_nz(False{}, BF(t, n), off, len) == (BF(t, n), R4(s, d, t, x, off, len)) : B.Buf & T.@LP_Seq}:
  match s:
    case True{}: Empty.absurd({T.@LP_read_nz(False{}, BF(t, n), off, len) == (BF(t, n), R4(True{}, d, t, x, off, len)) : B.Buf & T.@LP_Seq}, FD.logic__false_true(hc))
    case False{}:
      +h4 = FD.logic__subst(Bool, z => {z == False{} : Bool}, U32.is_lt(len, 4), Nat.is_lt(U32.to_nat(len), 4n), VR.lt_u32(len, 4), es)
      +hl = FD.nat__not_lt_le(U32.to_nat(len), 4n, h4)
      +hh = hk_l(HC(t, x, len), t, x, off, len, hc)
      +c1 = and_l(Bool.and(U32.is_eq(U32.and(O0(t, x), 3), 0), U32.is_le(O0(t, x), len)), Bool.and(U32.is_le(4, O0(t, x)), U32.is_le(U32.shrn(O0(t, x), 2n), @N)), hh)
      +hlp = FD.logic__subst(Bool, z => {HK(z, t, x, off, len) == True{} : Bool}, HC(t, x, len), True{}, hh, hc)
      %Equal.sym(B.Buf & U32, B.read32(BF(t, n), off), (BF(t, n), O0(t, x)), UR.rwx(d, t, n, off, x, eo, FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf,
          FD.nat__le_trans(Nat.add(x, 4n), Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d)), Order.add_left(x, 4n, U32.to_nat(len), hl), hw))) :
        {T.@LP_rv_count(off, len, _) == (BF(t, n), RQ(NQ(t, x), d, t, x, off, len)) : B.Buf & T.@LP_Seq}
      rdq(@CWA, NQ(t, x), {==}, FD.u32alg__eq_of(U32.and(O0(t, x), 3), 0, and_l(U32.is_eq(U32.and(O0(t, x), 3), 0), U32.is_le(O0(t, x), len), c1)), hlp,
        le_nat(O0(t, x), len, and_r(U32.is_eq(U32.and(O0(t, x), 3), 0), U32.is_le(O0(t, x), len), c1)))

def rdz(@CW, +z: Bool, +ez: {U32.is_eq(len, 0) == z : Bool}, +hc: {LZ(z, t, x, off, len) == True{} : Bool})
    -> {T.@LP_read_nz(z, BF(t, n), off, len) == (BF(t, n), RZ(z, d, t, x, off, len)) : B.Buf & T.@LP_Seq}:
  match z:
    case True{}: {==}
    case False{}: rd4(@CWA, U32.is_lt(len, 4), {==}, hc)

# The reader on the window, when the checks hold.
def readw(@CW, +hchk: {CHKw(t, x, off, len) == True{} : Bool}) -> {T.@LP_read(BF(t, n), off, len) == (BF(t, n), OBJw(d, t, x, off, len)) : B.Buf & T.@LP_Seq}:
  rdz(@CWA, U32.is_eq(len, 0), {==}, hchk)

@@ header_defs @@
def HC(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> Bool:
  Bool.and(Bool.and(U32.is_eq(U32.and(${O(0)}, 3), 0), U32.is_le(${O(0)}, len)), Bool.and(U32.is_le(4, ${O(0)}), U32.is_le(U32.shrn(${O(0)}, 2n), ${N})))

def NQ(+t: FD.array__Tree<U32>, +x: Nat) -> Nat: U32.to_nat(U32.shrn(${O(0)}, 2n))

# O0 = 4 (O0 >> 2) when its low bits are 0.
def e4q(+t: FD.array__Tree<U32>, +x: Nat, +e3: {U32.and(${O(0)}, 3) == 0 : U32}) -> {U32.to_nat(${O(0)}) == Nat.add(A.quad(NQ(t, x)), 0n) : Nat}:
  Equal.trans(Nat, U32.to_nat(${O(0)}), Nat.add(A.quad(NQ(t, x)), VR.RX(${O(0)})), Nat.add(A.quad(NQ(t, x)), 0n), VC.split4(${O(0)}),
    Equal.cong(U32, Nat, z => Nat.add(A.quad(NQ(t, x)), U32.to_nat(z)), U32.and(${O(0)}, 3), 0, e3))

def EW(ok: Bool, dd: Bool) -> Bool:
  match ok:
    case True{}: dd
    case False{}: False{}

@@ common_lemmas @@

def le_nat(+a: U32, +b: U32, +h: {U32.is_le(a, b) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b), h)

def u32le(+a: U32, +b: U32, +h: {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool}) -> {U32.is_le(a, b) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(a), U32.to_nat(b)), U32.is_le(a, b), Equal.sym(Bool, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b)), h)

def and_l(+a: Bool, +b: Bool, +h: {Bool.and(a, b) == True{} : Bool}) -> {a == True{} : Bool}: FD.logic__and_left(a, b, h)
def and_r(+a: Bool, +b: Bool, +h: {Bool.and(a, b) == True{} : Bool}) -> {b == True{} : Bool}: FD.logic__and_right(a, b, h)

def ew_l(+ok: Bool, +dd: Bool, +h: {EW(ok, dd) == True{} : Bool}) -> {ok == True{} : Bool}:
  match ok:
    case True{}: {==}
    case False{}: h

def ew_r(+ok: Bool, +dd: Bool, +h: {EW(ok, dd) == True{} : Bool}) -> {dd == True{} : Bool}:
  match ok:
    case True{}: h
    case False{}: Empty.absurd({dd == True{} : Bool}, FD.logic__false_true(h))

# A byte position o <= len of the window, as an offset: off + o at o + x.
def eoj(${CW}, +o: U32, +h: {Nat.is_le(U32.to_nat(o), U32.to_nat(len)) == True{} : Bool})
    -> {U32.to_nat(U32.add(off, o)) == Nat.add(U32.to_nat(o), x) : Nat}:
  +hl = FD.nat__le_trans(Nat.add(U32.to_nat(o), x), Nat.add(U32.to_nat(len), x), ${PW}, Order.add_right(U32.to_nat(o), U32.to_nat(len), x, h),
    FD.logic__subst(Nat, z => {Nat.is_le(z, ${PW}) == True{} : Bool}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw))
  VB.add_at(off, o, x, 3n+d, eo, FD.nat__lt_trans(3n+d, 31n, 32n, hd, {==}), VB.le_pw_lt(Nat.add(U32.to_nat(o), x), 2n+d, hl))

def alg(+o: Nat, +x: Nat, +e: Nat, +h: {Nat.is_le(o, e) == True{} : Bool}) -> {Nat.add(Nat.add(o, x), Nat.sub(e, o)) == Nat.add(x, e) : Nat}:
  %Equal.sym(Nat, Nat.add(Nat.add(o, x), Nat.sub(e, o)), Nat.add(o, Nat.add(x, Nat.sub(e, o))), FD.nat__add_assoc(o, x, Nat.sub(e, o))) : {_ == Nat.add(x, e) : Nat}
  %Equal.sym(Nat, Nat.add(o, Nat.add(x, Nat.sub(e, o))), Nat.add(x, Nat.add(o, Nat.sub(e, o))), FD.lru_nat_algebra__add_swap(o, x, Nat.sub(e, o))) : {_ == Nat.add(x, e) : Nat}
  %Equal.sym(Nat, Nat.add(o, Nat.sub(e, o)), e, FD.nat__sub_add(e, o, h)) : {Nat.add(x, _) == Nat.add(x, e) : Nat}
  {==}

# The window [o, e) of the window: (o + x) + (e - o) <= 4 2^d.
def hwj(${CW}, +o: U32, +e: U32, +h1: {Nat.is_le(U32.to_nat(o), U32.to_nat(e)) == True{} : Bool}, +h2: {Nat.is_le(U32.to_nat(e), U32.to_nat(len)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(Nat.add(U32.to_nat(o), x), U32.to_nat(U32.sub(e, o))), ${PW}) == True{} : Bool}:
  %Equal.sym(Nat, U32.to_nat(U32.sub(e, o)), Nat.sub(U32.to_nat(e), U32.to_nat(o)), FD.u32__sub_nat(e, o, h1)) : {Nat.is_le(Nat.add(Nat.add(U32.to_nat(o), x), _), ${PW}) == True{} : Bool}
  %Equal.sym(Nat, Nat.add(Nat.add(U32.to_nat(o), x), Nat.sub(U32.to_nat(e), U32.to_nat(o))), Nat.add(x, U32.to_nat(e)), alg(U32.to_nat(o), x, U32.to_nat(e), h1)) :
    {Nat.is_le(_, ${PW}) == True{} : Bool}
  FD.nat__le_trans(Nat.add(x, U32.to_nat(e)), Nat.add(x, U32.to_nat(len)), ${PW}, Order.add_left(x, U32.to_nat(e), U32.to_nat(len), h2), hw)

# The four-byte read at off + c (c + 4 <= len).
def rdo(${CW}, +c: U32, +k: Nat, +ec: {U32.to_nat(c) == k : Nat}, +h: {Nat.is_le(Nat.add(k, 4n), U32.to_nat(len)) == True{} : Bool})
    -> {B.read32(${BUF}, U32.add(off, c)) == (${BUF}, UR.RWN(t, Nat.add(k, x))) : B.Buf & U32}:
  +hk = FD.nat__le_trans(k, Nat.add(k, 4n), U32.to_nat(len), Order.below_sum(k, 4n), h)
  +eoc = eoj(${CWA}, c, FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(len)) == True{} : Bool}, k, U32.to_nat(c), Equal.sym(Nat, U32.to_nat(c), k, ec), hk))
  UR.rwx(d, t, n, U32.add(off, c), Nat.add(k, x), FD.logic__subst(Nat, z => {U32.to_nat(U32.add(off, c)) == Nat.add(z, x) : Nat}, U32.to_nat(c), k, ec, eoc),
    FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf, UR.roomw(x, U32.to_nat(len), k, ${PW}, hw, h))

# The element check at [a, b): the child's validator, when the ranges hold.
def ewl(${CW}, +acc: Bool, +a: U32, +b: U32, +ok: Bool, +e: {Bool.and(acc, Bool.and(U32.is_le(a, b), U32.is_le(b, len))) == ok : Bool})
    -> {T.${LP}_ew(ok, ${BUF}, off, a, b) == (${BUF}, EW(ok, CH.CHKw(t, Nat.add(U32.to_nat(a), x), U32.add(off, a), U32.sub(b, a)))) : B.Buf & Bool}:
  match ok:
    case False{}: {==}
    case True{}:
      +r = and_r(acc, Bool.and(U32.is_le(a, b), U32.is_le(b, len)), e)
      +hab = le_nat(a, b, and_l(U32.is_le(a, b), U32.is_le(b, len), r))
      +hbl = le_nat(b, len, and_r(U32.is_le(a, b), U32.is_le(b, len), r))
      %Equal.sym(B.Buf & Bool, T.${C}_ok(${BUF}, U32.add(off, a), U32.sub(b, a)), (${BUF}, CH.CHKw(t, Nat.add(U32.to_nat(a), x), U32.add(off, a), U32.sub(b, a))),
          CH.ok_evalw(d, t, n, Nat.add(U32.to_nat(a), x), U32.add(off, a), U32.sub(b, a), eoj(${CWA}, a, FD.nat__le_trans(U32.to_nat(a), U32.to_nat(b), U32.to_nat(len), hab, hbl)), hd,
            hwj(${CWA}, a, b, hab, hbl), pf)) :
        {_ == (${BUF}, CH.CHKw(t, Nat.add(U32.to_nat(a), x), U32.add(off, a), U32.sub(b, a))) : B.Buf & Bool}
      {==}

# A header check fails for a window of fewer than 4 bytes, whatever the first word.
def hc_small(+v: U32, +len: U32, +h: {Nat.is_lt(U32.to_nat(len), 4n) == True{} : Bool}, +a: Bool, +ea: {U32.is_eq(U32.and(v, 3), 0) == a : Bool},
    +b: Bool, +eb: {U32.is_le(v, len) == b : Bool}, +c: Bool, +ec: {U32.is_le(4, v) == c : Bool})
    -> {Bool.and(Bool.and(a, b), Bool.and(c, U32.is_le(U32.shrn(v, 2n), ${N}))) == False{} : Bool}:
  match a b c:
    case False{} _ _: {==}
    case True{} False{} _: {==}
    case True{} True{} False{}: {==}
    case True{} True{} True{}:
      +h4 = FD.nat__le_trans(4n, U32.to_nat(v), U32.to_nat(len), le_nat(4, v, ec), le_nat(v, len, eb))
      Empty.absurd({Bool.and(Bool.and(True{}, True{}), Bool.and(True{}, U32.is_le(U32.shrn(v, 2n), ${N}))) == False{} : Bool},
        FD.logic__false_true(FD.nat__le_lt_trans(4n, U32.to_nat(len), 4n, h4, h)))

@@ spec_top @@

def spec4(${CW}, +s: Bool, +es: {U32.is_lt(len, 4) == s : Bool}, +hc: {L4(s, t, x, off, len) == True{} : Bool})
    -> {Codec.parts(V4(s, t, x, len), ${LSCH}) == Some{[S.Variable{${WBL}}]} : ${MP}}:
  match s:
    case True{}: Empty.absurd({Codec.parts(V4(True{}, t, x, len), ${LSCH}) == Some{[S.Variable{${WBL}}]} : ${MP}}, FD.logic__false_true(hc))
    case False{}:
      +hh = hk_l(HC(t, x, len), t, x, off, len, hc)
      +c1 = and_l(Bool.and(U32.is_eq(U32.and(${O(0)}, 3), 0), U32.is_le(${O(0)}, len)), Bool.and(U32.is_le(4, ${O(0)}), U32.is_le(U32.shrn(${O(0)}, 2n), ${N})), hh)
      +hlp = FD.logic__subst(Bool, z => {HK(z, t, x, off, len) == True{} : Bool}, HC(t, x, len), True{}, hh, hc)
      specq(${CWA}, NQ(t, x), {==}, FD.u32alg__eq_of(U32.and(${O(0)}, 3), 0, and_l(U32.is_eq(U32.and(${O(0)}, 3), 0), U32.is_le(${O(0)}, len), c1)), hlp,
        le_nat(${O(0)}, len, and_r(U32.is_eq(U32.and(${O(0)}, 3), 0), U32.is_le(${O(0)}, len), c1)))

def specz(${CW}, +z: Bool, +ez: {U32.is_eq(len, 0) == z : Bool}, +hc: {LZ(z, t, x, off, len) == True{} : Bool})
    -> {Codec.parts(VZ(z, t, x, len), ${LSCH}) == Some{[S.Variable{${WBL}}]} : ${MP}}:
  match z:
    case True{}:
      %Equal.sym(U32, len, 0, FD.u32alg__eq_of(len, 0, ez)) : {Codec.parts(S.Sequence{S.EmptyItems{}}, ${LSCH}) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(_))}]} : ${MP}}
      {==}
    case False{}: spec4(${CWA}, U32.is_lt(len, 4), {==}, hc)

# The spec parts of the value: one variable part, the window's bytes.
def specw(${CW}, +hchk: {CHKw(t, x, off, len) == True{} : Bool}) -> {Codec.parts(VALw(t, x, len), ${LSCH}) == Some{[S.Variable{${WBL}}]} : ${MP}}:
  specz(${CWA}, U32.is_eq(len, 0), {==}, hchk)

@@ inv_helpers @@

# ---- every value whose spec parts are the window's bytes passes the checks ------------------------

def req_none(+t: FD.array__Tree<U32>, +x: Nat, +len: U32, +b: Bool, +e: {Codec.require(b, None{}) == Some{[S.Variable{${WBL}}]} : ${MP}}) -> Empty:
  match b:
    case True{}: FD.logic__none_some(+List<S.Part>, [S.Variable{${WBL}}], e)
    case False{}: FD.logic__none_some(+List<S.Part>, [S.Variable{${WBL}}], e)

def neq0(+len: U32, +h: {Nat.is_le(1n, U32.to_nat(len)) == True{} : Bool}, +b: Bool, +eb: {U32.is_eq(len, 0) == b : Bool}) -> {b == False{} : Bool}:
  match b:
    case False{}: {==}
    case True{}: Empty.absurd({True{} == False{} : Bool}, FD.logic__false_true(FD.logic__subst(Nat, z => {Nat.is_le(1n, z) == True{} : Bool}, U32.to_nat(len), 0n,
      Equal.cong(U32, Nat, z => U32.to_nat(z), len, 0, FD.u32alg__eq_of(len, 0, eb)), h)))

def nlt4(+len: U32, +h: {Nat.is_le(4n, U32.to_nat(len)) == True{} : Bool}, +b: Bool, +eb: {U32.is_lt(len, 4) == b : Bool}) -> {b == False{} : Bool}:
  match b:
    case False{}: {==}
    case True{}: Empty.absurd({True{} == False{} : Bool}, FD.logic__false_true(FD.nat__le_lt_trans(4n, U32.to_nat(len), 4n, h,
      FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_lt(len, 4), Nat.is_lt(U32.to_nat(len), 4n), VR.lt_u32(len, 4), eb))))

def zero_len(${CW}, +e: {[] == ${WBL} : +List<U32>}) -> ${GOAL}:
  +el = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, ${WBL}), 0n, Equal.sym(Nat, List.length(&2, U32, ${WBL}), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)),
    Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), ${WBL}, [], Equal.sym(+List<U32>, [], ${WBL}, e)))
  %Equal.sym(Bool, U32.is_eq(len, 0), True{}, FD.u32alg__eq_true(len, 0, FD.u32__injective(len, 0, el))) : {LZ(_, t, x, off, len) == True{} : Bool}
  {==}

@@ ok_top @@

def nz1g(+len: U32, +ez: {U32.is_eq(len, 0) == False{} : Bool}, +k: Nat, +ek: {U32.to_nat(len) == k : Nat}) -> {Nat.is_le(1n, k) == True{} : Bool}:
  match k:
    case 0n: Empty.absurd({Nat.is_le(1n, 0n) == True{} : Bool}, FD.logic__false_true(Equal.trans(Bool, False{}, U32.is_eq(len, 0), True{}, Equal.sym(Bool, U32.is_eq(len, 0), False{}, ez), FD.u32alg__eq_true(len, 0, FD.u32__injective(len, 0, ek)))))
    case 1n+ +p: FD.nat__zero_le(p)

def nz1(+len: U32, +ez: {U32.is_eq(len, 0) == False{} : Bool}) -> {Nat.is_le(1n, U32.to_nat(len)) == True{} : Bool}: nz1g(len, ez, U32.to_nat(len), {==})

def okh(${CW}, +hb: Bool, +eh: {HC(t, x, len) == hb : Bool})
    -> {T.${LP}_first(hb, ${BUF}, off, len, ${O(0)}) == (${BUF}, HK(hb, t, x, off, len)) : B.Buf & Bool}:
  match hb:
    case False{}: {==}
    case True{}:
      +c1 = and_l(Bool.and(U32.is_eq(U32.and(${O(0)}, 3), 0), U32.is_le(${O(0)}, len)), Bool.and(U32.is_le(4, ${O(0)}), U32.is_le(U32.shrn(${O(0)}, 2n), ${N})), eh)
      +c2 = and_r(Bool.and(U32.is_eq(U32.and(${O(0)}, 3), 0), U32.is_le(${O(0)}, len)), Bool.and(U32.is_le(4, ${O(0)}), U32.is_le(U32.shrn(${O(0)}, 2n), ${N})), eh)
      walkq(${CWA}, NQ(t, x), {==}, le_nat(4, ${O(0)}, and_l(U32.is_le(4, ${O(0)}), U32.is_le(U32.shrn(${O(0)}, 2n), ${N}), c2)),
        le_nat(U32.shrn(${O(0)}, 2n), ${N}, and_r(U32.is_le(4, ${O(0)}), U32.is_le(U32.shrn(${O(0)}, 2n), ${N}), c2)),
        FD.u32alg__eq_of(U32.and(${O(0)}, 3), 0, and_l(U32.is_eq(U32.and(${O(0)}, 3), 0), U32.is_le(${O(0)}, len), c1)),
        le_nat(${O(0)}, len, and_r(U32.is_eq(U32.and(${O(0)}, 3), 0), U32.is_le(${O(0)}, len), c1)))

def ok4(${CW}, +h1: {Nat.is_le(1n, U32.to_nat(len)) == True{} : Bool}, +s: Bool, +es: {U32.is_lt(len, 4) == s : Bool})
    -> {T.${LP}_ok_nz(False{}, ${BUF}, off, len) == (${BUF}, L4(s, t, x, off, len)) : B.Buf & Bool}:
  match s:
    case True{}:
      +hl4 = FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_lt(len, 4), Nat.is_lt(U32.to_nat(len), 4n), VR.lt_u32(len, 4), es)
      +hx = FD.logic__subst(Nat, z => {Nat.is_lt(z, ${PW}) == True{} : Bool}, x, U32.to_nat(off), Equal.sym(Nat, U32.to_nat(off), x, eo),
        FD.nat__lt_le_trans(x, Nat.add(x, U32.to_nat(len)), ${PW}, FD.logic__subst(Nat, z => {Nat.is_lt(x, z) == True{} : Bool}, Nat.add(U32.to_nat(len), x), Nat.add(x, U32.to_nat(len)), FD.nat__add_comm(U32.to_nat(len), x),
          FD.nat__lt_le_trans(x, 1n+x, Nat.add(U32.to_nat(len), x), FD.nat__lt_succ(x), Order.add_right(1n, U32.to_nat(len), x, h1))), hw))
      +V = UR.RWW(d, t, off)
      %Equal.sym(B.Buf & U32, B.read32(${BUF}, off), (${BUF}, V), UR.rd_lt(d, t, n, off, FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf, hx)) :
        {T.${LP}_head(len, off, _) == (${BUF}, False{}) : B.Buf & Bool}
      %Equal.sym(Bool, Bool.and(Bool.and(U32.is_eq(U32.and(V, 3), 0), U32.is_le(V, len)), Bool.and(U32.is_le(4, V), U32.is_le(U32.shrn(V, 2n), ${N}))), False{},
          hc_small(V, len, hl4, U32.is_eq(U32.and(V, 3), 0), {==}, U32.is_le(V, len), {==}, U32.is_le(4, V), {==})) :
        {T.${LP}_first(_, ${BUF}, off, len, V) == (${BUF}, False{}) : B.Buf & Bool}
      {==}
    case False{}:
      +h4 = FD.logic__subst(Bool, z => {z == False{} : Bool}, U32.is_lt(len, 4), Nat.is_lt(U32.to_nat(len), 4n), VR.lt_u32(len, 4), es)
      +hl = FD.nat__not_lt_le(U32.to_nat(len), 4n, h4)
      %Equal.sym(B.Buf & U32, B.read32(${BUF}, off), (${BUF}, ${O(0)}), UR.rwx(d, t, n, off, x, eo, FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf,
          FD.nat__le_trans(Nat.add(x, 4n), Nat.add(x, U32.to_nat(len)), ${PW}, Order.add_left(x, 4n, U32.to_nat(len), hl), hw))) :
        {T.${LP}_head(len, off, _) == (${BUF}, HK(HC(t, x, len), t, x, off, len)) : B.Buf & Bool}
      okh(${CWA}, HC(t, x, len), {==})

def okz(${CW}, +z: Bool, +ez: {U32.is_eq(len, 0) == z : Bool})
    -> {T.${LP}_ok_nz(z, ${BUF}, off, len) == (${BUF}, LZ(z, t, x, off, len)) : B.Buf & Bool}:
  match z:
    case True{}: {==}
    case False{}:
      ok4(${CWA}, nz1(len, ez), U32.is_lt(len, 4), {==})

# The validator on the window returns the buffer and CHKw.
def ok_evalw(${CW}) -> {T.${LP}_ok(${BUF}, off, len) == (${BUF}, CHKw(t, x, off, len)) : B.Buf & Bool}:
  okz(${CWA}, U32.is_eq(len, 0), {==})
