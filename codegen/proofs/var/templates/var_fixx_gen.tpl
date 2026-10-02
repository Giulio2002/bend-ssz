@@ bvc_mod @@
def OBJ(+d: Nat, +t: ${TR}, +x: Nat) -> O.Words: O.Words{FD.array__thaw(U32, VXB.CTN(d, t, x, ${S}, ${dz}n)), ${S}}

${sig('rdx', S)}
    -> {T.${p}_read(UA.BF(t, n), off, ${S}) == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & O.Words}:
  VXG.rdg(d, t, n, off, x, e, hd, pf, ${S}, ${S}n, ${dz}n, ${ky}n, {==}, {==}, {==}, {==}, {==}, hb)

def VAL(+t: ${TR}, +x: Nat) -> S.Value: S.BitsValue{FB.bitsof(UR.RWS(${M}n, t, x))}

def prt(+d: Nat, +t: ${TR}, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}, +hb: {Nat.is_le(Nat.add(x, ${S}n), A.quad(VB.pw(d))) == ${TRUE}},
    +s: S.Schema, +es: {s == ${SCH} : S.Schema})
    -> {Codec.parts(VAL(t, x), s) == Some{[S.Fixed{UW.WX(t, x, ${S}n)}]} : ${MP}}:
  %Equal.sym(S.Schema, s, ${SCH}, es) : {Codec.parts(VAL(t, x), _) == Some{[S.Fixed{UW.WX(t, x, ${S}n)}]} : ${MP}}
  %UR.rws_bytes(${M}n, d, t, x, pf, hb) : {Codec.parts(VAL(t, x), ${SCH}) == Some{[S.Fixed{_}]} : ${MP}}
  FB.bits_part(UR.RWS(${M}n, t, x), ${N}n, {==}, {==})

@@ common @@

# the byte at Nat position x
def BX(+t: ${TR}, +x: Nat) -> U32: VBL.nthb(UA.BYT(t), x)

# the runtime's byte at off is the byte at off's position
def vx_bx(+t: ${TR}, +off: U32, +x: Nat, +e: {U32.to_nat(off) == x : Nat}) -> {VR.VX(t, off) == BX(t, x) : U32}:
  %e : {VR.VX(t, off) == VBL.nthb(UA.BYT(t), _) : U32}
  %Equal.sym(Nat, U32.to_nat(off), Nat.add(A.quad(VR.QX(off)), VR.RX(off)), VC.split4(off)) : {VR.VX(t, off) == VBL.nthb(UA.BYT(t), _) : U32}
  %Equal.sym(U32, VBL.nthb(UA.BYT(t), Nat.add(A.quad(VR.QX(off)), VR.RX(off))), VR.bsN(VR.RX(off), VB.slot(t, VR.QX(off))), VR.nth_limbs(VR.SL(t), VR.QX(off), VR.RX(off), UA.rx_lt(off))) :
    {VR.VX(t, off) == _ : U32}
  VR.bs_eq(U32.and(off, 3), VB.slot(t, VR.QX(off)), VR.RX(off), {==}, UA.rx_lt(off))

# the first one / two bytes from x
def bt1(+L: +List<U32>, +x: Nat, +h: {Nat.is_lt(x, List.length(&2, U32, L)) == ${TRUE}}) -> {VS.bt(1n, VS.bdr(x, L)) == [VBL.nthb(L, x)] : +List<U32>}:
  match L x:
    case Nil{} 0n: Empty.absurd({VS.bt(1n, VS.bdr(0n, Nil{})) == [VBL.nthb(Nil{}, 0n)] : +List<U32>}, FD.logic__false_true(h))
    case Nil{} 1n+ +q: Empty.absurd({VS.bt(1n, VS.bdr(1n+q, Nil{})) == [VBL.nthb(Nil{}, 1n+q)] : +List<U32>}, FD.nat__lt_zero_absurd(1n+q, h))
    case Con{+h0, +t0} 0n: {==}
    case Con{+h0, +t0} 1n+ +q: bt1(t0, q, h)

def bt2(+L: +List<U32>, +x: Nat, +h: {Nat.is_lt(1n+x, List.length(&2, U32, L)) == ${TRUE}}) -> {VS.bt(2n, VS.bdr(x, L)) == [VBL.nthb(L, x), VBL.nthb(L, 1n+x)] : +List<U32>}:
  match L x:
    case Nil{} 0n: Empty.absurd({VS.bt(2n, VS.bdr(0n, Nil{})) == [VBL.nthb(Nil{}, 0n), VBL.nthb(Nil{}, 1n)] : +List<U32>}, FD.logic__false_true(h))
    case Nil{} 1n+ +q: Empty.absurd({VS.bt(2n, VS.bdr(1n+q, Nil{})) == [VBL.nthb(Nil{}, 1n+q), VBL.nthb(Nil{}, 2n+q)] : +List<U32>}, FD.logic__false_true(h))
    case Con{+h0, Nil{}} 0n: Empty.absurd({VS.bt(2n, VS.bdr(0n, [h0])) == [VBL.nthb([h0], 0n), VBL.nthb([h0], 1n)] : +List<U32>}, FD.logic__false_true(h))
    case Con{+h0, Con{+h1, +t1}} 0n: {==}
    case Con{+h0, +t0} 1n+ +q: bt2(t0, q, h)

def lenB(+d: Nat, +t: ${TR}, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}) -> {List.length(&2, U32, UA.BYT(t)) == ${P} : Nat}: VR.lenS(d, t, pf)

def wx1(+d: Nat, +t: ${TR}, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}, +hb: {Nat.is_le(Nat.add(x, 1n), ${P}) == ${TRUE}})
    -> {UW.WX(t, x, 1n) == [BX(t, x)] : +List<U32>}:
  bt1(UA.BYT(t), x, FD.logic__subst(Nat, z => {Nat.is_lt(x, z) == ${TRUE}}, ${P}, List.length(&2, U32, UA.BYT(t)), Equal.sym(Nat, List.length(&2, U32, UA.BYT(t)), ${P}, VR.lenS(d, t, pf)),
    VXG.ltx(x, 1n, ${P}, {==}, hb)))

def wx2(+d: Nat, +t: ${TR}, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}, +hb: {Nat.is_le(Nat.add(x, 2n), ${P}) == ${TRUE}})
    -> {UW.WX(t, x, 2n) == [BX(t, x), BX(t, 1n+x)] : +List<U32>}:
  +h1 = FD.logic__subst(Nat, z => {Nat.is_le(z, ${P}) == ${TRUE}}, Nat.add(x, 2n), 2n+x, FD.nat__add_comm(x, 2n), hb)
  bt2(UA.BYT(t), x, FD.logic__subst(Nat, z => {Nat.is_lt(1n+x, z) == ${TRUE}}, ${P}, List.length(&2, U32, UA.BYT(t)), Equal.sym(Nat, List.length(&2, U32, UA.BYT(t)), ${P}, VR.lenS(d, t, pf)),
    FD.nat__lt_le_trans(1n+x, 2n+x, ${P}, FD.nat__lt_succ(1n+x), h1)))

@@ u8_mod @@

def OBJ(+d: Nat, +t: ${TR}, +x: Nat) -> U32: BX(t, x)

# (reads the byte at x: x + 1 <= 4 2^d)
${sig('rdx', 1)}
    -> {T.u8_read(UA.BF(t, n), off, 1) == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & U32}:
  %Equal.sym(B.Buf & U32, B.byte_at(UA.BF(t, n), off), (UA.BF(t, n), VR.VX(t, off)),
      VR.byte_at_ok(d, t, n, off, FD.nat__lt_trans(d, 28n, 32n, hd, {==}), VR.hiX(d, off, x, e, VXG.ltx(x, 1n, ${P}, {==}, hb)), pf)) :
    {_ == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & U32}
  %Equal.sym(U32, VR.VX(t, off), BX(t, x), vx_bx(t, off, x, e)) : {(UA.BF(t, n), _) == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & U32}
  {==}

def VAL(+t: ${TR}, +x: Nat) -> S.Value: S.UnsignedValue{P.UInt{BX(t, x), 0, 0, 0, 0, 0, 0, 0}}

def prt(+d: Nat, +t: ${TR}, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}, +hb: {Nat.is_le(Nat.add(x, 1n), ${P}) == ${TRUE}},
    +s: S.Schema, +es: {s == ${SCH} : S.Schema})
    -> {Codec.parts(VAL(t, x), s) == Some{[S.Fixed{UW.WX(t, x, 1n)}]} : ${MP}}:
  +e1 = wx1(d, t, x, pf, hb)
  +dm = FD.logic__subst(+List<U32>, z => {SP.bytes_domain(z) == ${TRUE}}, UW.WX(t, x, 1n), [BX(t, x)], e1, UW.domWX(t, x, 1n))
  %Equal.sym(S.Schema, s, ${SCH}, es) : {Codec.parts(VAL(t, x), _) == Some{[S.Fixed{UW.WX(t, x, 1n)}]} : ${MP}}
  %Equal.sym(+List<U32>, UW.WX(t, x, 1n), [BX(t, x)], e1) : {Codec.parts(VAL(t, x), ${SCH}) == Some{[S.Fixed{_}]} : ${MP}}
  U8.u8p(BX(t, x), FD.logic__and_left(U32.is_lt(BX(t, x), 256), True{}, dm))

@@ u16_mod @@

def OBJ(+d: Nat, +t: ${TR}, +x: Nat) -> U32: O.keep(2, UR.RWN(t, x))

# (the four-byte read keeps the two bytes at x: x + 2 <= 4 2^d; vedge.bend)
${sig('rdx', 2)}
    -> {T.u16_read(UA.BF(t, n), off, 2) == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & U32}:
  +hb2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 2n), ${P}) == ${TRUE}}, x, U32.to_nat(off), Equal.sym(Nat, U32.to_nat(off), x, e), hb)
  %Equal.sym(B.Buf & U32, B.read32(UA.BF(t, n), off), (UA.BF(t, n), VE.RV(t, n, off)), VE.rd_same(t, n, off)) :
    {O.keep2(_) == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & U32}
  %Equal.sym(U32, O.keep(2, VE.RV(t, n, off)), O.keep(2, UA.RW(t, off)), VE.kv2(d, t, n, off, FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf, hb2)) :
    {(UA.BF(t, n), _) == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & U32}
  %Equal.sym(U32, UA.RW(t, off), UR.RWN(t, U32.to_nat(off)), UR.rw_n(t, off)) : {(UA.BF(t, n), O.keep(2, _)) == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & U32}
  %Equal.sym(Nat, U32.to_nat(off), x, e) : {(UA.BF(t, n), O.keep(2, UR.RWN(t, _))) == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & U32}
  {==}

def VAL(+t: ${TR}, +x: Nat) -> S.Value: S.UnsignedValue{P.UInt{PB.v16of(BX(t, x), BX(t, 1n+x)), 0, 0, 0, 0, 0, 0, 0}}

def u16p(+x0: U32, +x1: U32, +e0: {U32.is_lt(x0, 256) == ${TRUE}}, +e1: {U32.is_lt(x1, 256) == ${TRUE}})
    -> {Codec.parts(S.UnsignedValue{P.UInt{PB.v16of(x0, x1), 0, 0, 0, 0, 0, 0, 0}}, ${SCH}) == Some{[S.Fixed{[x0, x1]}]} : ${MP}}:
  %Equal.sym(Maybe<&2, +List<U32>>, RR.basic_one(S.UnsignedValue{P.UInt{PB.v16of(x0, x1), 0, 0, 0, 0, 0, 0, 0}}, ${SCH}), Some{[x0, x1]}, PB.two(x0, x1, e0, e1)) :
    {Codec.one(_, Some{2n}) == Some{[S.Fixed{[x0, x1]}]} : ${MP}}
  {==}

def prt(+d: Nat, +t: ${TR}, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}, +hb: {Nat.is_le(Nat.add(x, 2n), ${P}) == ${TRUE}},
    +s: S.Schema, +es: {s == ${SCH} : S.Schema})
    -> {Codec.parts(VAL(t, x), s) == Some{[S.Fixed{UW.WX(t, x, 2n)}]} : ${MP}}:
  +e2 = wx2(d, t, x, pf, hb)
  +dm = FD.logic__subst(+List<U32>, z => {SP.bytes_domain(z) == ${TRUE}}, UW.WX(t, x, 2n), [BX(t, x), BX(t, 1n+x)], e2, UW.domWX(t, x, 2n))
  +d1 = FD.logic__and_right(U32.is_lt(BX(t, x), 256), Bool.and(U32.is_lt(BX(t, 1n+x), 256), True{}), dm)
  %Equal.sym(S.Schema, s, ${SCH}, es) : {Codec.parts(VAL(t, x), _) == Some{[S.Fixed{UW.WX(t, x, 2n)}]} : ${MP}}
  %Equal.sym(+List<U32>, UW.WX(t, x, 2n), [BX(t, x), BX(t, 1n+x)], e2) : {Codec.parts(VAL(t, x), ${SCH}) == Some{[S.Fixed{_}]} : ${MP}}
  u16p(BX(t, x), BX(t, 1n+x), FD.logic__and_left(U32.is_lt(BX(t, x), 256), Bool.and(U32.is_lt(BX(t, 1n+x), 256), True{}), dm),
    FD.logic__and_left(U32.is_lt(BX(t, 1n+x), 256), True{}, d1))

@@ bvn_mod @@
# the validator's check (bits ${N}..7 of the byte clear)
def CHKv(+v: U32) -> Bool: U32.is_eq(U32.and(v, U32.not(O.low_mask(${N}))), 0)
def CHK(+t: ${TR}, +x: Nat) -> Bool: CHKv(BX(t, x))

@@ bvn_mod_OBJ @@
def OBJ(+d: Nat, +t: ${TR}, +x: Nat) -> ${Tn}: ${Tn}{O.keep(1, UR.RWN(t, x))}

# (the four-byte read keeps the byte at x: x + 1 <= 4 2^d; vedge.bend)
${sig('rdx', 1)}
    -> {T.${p}_read(UA.BF(t, n), off, 1) == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & ${Tn}}:
  +hb1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 1n), ${P}) == ${TRUE}}, x, U32.to_nat(off), Equal.sym(Nat, U32.to_nat(off), x, e), hb)
  %Equal.sym(B.Buf & U32, B.read32(UA.BF(t, n), off), (UA.BF(t, n), VE.RV(t, n, off)), VE.rd_same(t, n, off)) :
    {T.${p}_r0(off, _) == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & ${Tn}}
  %Equal.sym(U32, O.keep(1, VE.RV(t, n, off)), O.keep(1, UA.RW(t, off)), VE.kv1(d, t, n, off, FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf, hb1)) :
    {(UA.BF(t, n), ${Tn}{_}) == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & ${Tn}}
  %Equal.sym(U32, UA.RW(t, off), UR.RWN(t, U32.to_nat(off)), UR.rw_n(t, off)) : {(UA.BF(t, n), ${Tn}{O.keep(1, _)}) == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & ${Tn}}
  %Equal.sym(Nat, U32.to_nat(off), x, e) : {(UA.BF(t, n), ${Tn}{O.keep(1, UR.RWN(t, _))}) == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & ${Tn}}
  {==}

@@ bvn_mod_2 @@
# the validator on the byte at off returns CHK
${sig('ok', 1)}
    -> {T.${p}_ok_at(UA.BF(t, n), off) == (UA.BF(t, n), CHK(t, x)) : B.Buf & Bool}:
  +e0 = Equal.trans(Nat, U32.to_nat(U32.add(off, 0)), Nat.add(x, 0n), x, VXG.offc(d, off, 0, 0n, x, 1n, e, hd, {==}, {==}, hb), FD.nat__add_zero(x))
  +hi = VR.hiX(d, U32.add(off, 0), x, e0, VXG.ltx(x, 1n, ${P}, {==}, hb))
  %Equal.sym(B.Buf & U32, B.byte_at(UA.BF(t, n), U32.add(off, 0)), (UA.BF(t, n), VR.VX(t, U32.add(off, 0))), VR.byte_at_ok(d, t, n, U32.add(off, 0), FD.nat__lt_trans(d, 28n, 32n, hd, {==}), hi, pf)) :
    {O.pad_pick(${N}, _) == (UA.BF(t, n), CHK(t, x)) : B.Buf & Bool}
  %Equal.sym(U32, VR.VX(t, U32.add(off, 0)), BX(t, x), vx_bx(t, U32.add(off, 0), x, e0)) :
    {O.pad_pick(${N}, (UA.BF(t, n), _)) == (UA.BF(t, n), CHK(t, x)) : B.Buf & Bool}
  {==}

@@ bvn_mod_VBN @@
# the ${N} low bits
def VBN(v: U32) -> S.Value:
  match v:
    case U32{${pat}}: S.BitsValue{[${', '.join(a[:N])}]}
def VAL(+t: ${TR}, +x: Nat) -> S.Value: VBN(BX(t, x))

@@ bvn_mod_prt @@
def prt(+d: Nat, +t: ${TR}, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}, ${HB},
    +s: S.Schema, +es: {s == ${SCH} : S.Schema}, +hchk: {CHK(t, x) == ${TRUE}})
    -> {Codec.parts(VAL(t, x), s) == Some{[S.Fixed{UW.WX(t, x, 1n)}]} : ${MP}}:
  %Equal.sym(S.Schema, s, ${SCH}, es) : {Codec.parts(VAL(t, x), _) == Some{[S.Fixed{UW.WX(t, x, 1n)}]} : ${MP}}
  %Equal.sym(+List<U32>, UW.WX(t, x, 1n), [BX(t, x)], wx1(d, t, x, pf, hb)) : {Codec.parts(VAL(t, x), ${SCH}) == Some{[S.Fixed{_}]} : ${MP}}
  bvp(BX(t, x), hchk)

@@ bvn_mod_3 @@
def prt(+d: Nat, +t: ${TR}, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}, ${HB},
    +s: S.Schema, +es: {s == ${SCH} : S.Schema})
    -> {Codec.parts(VAL(t, x), s) == Some{[S.Fixed{UW.WX(t, x, 1n)}]} : ${MP}}:
  +e1 = wx1(d, t, x, pf, hb)
  +dm = FD.logic__subst(+List<U32>, z => {SP.bytes_domain(z) == ${TRUE}}, UW.WX(t, x, 1n), [BX(t, x)], e1, UW.domWX(t, x, 1n))
  %Equal.sym(S.Schema, s, ${SCH}, es) : {Codec.parts(VAL(t, x), _) == Some{[S.Fixed{UW.WX(t, x, 1n)}]} : ${MP}}
  %Equal.sym(+List<U32>, UW.WX(t, x, 1n), [BX(t, x)], e1) : {Codec.parts(VAL(t, x), ${SCH}) == Some{[S.Fixed{_}]} : ${MP}}
  %VBL.ebyte(BX(t, x), FD.logic__and_left(U32.is_lt(BX(t, x), 256), True{}, dm)) :
    {Codec.parts(VBN(_), ${SCH}) == Some{[S.Fixed{[_]}]} : ${MP}}
  bvp8(VBL.W8(BX(t, x)))

@@ bvn_mod_CHKL @@
# CHK of the first byte of a list (False when empty)
def CHKL(ys: +List<U32>) -> Bool:
  match ys:
    case Nil{}: False{}
    case Con{+u, r}: CHKv(u)

def chkl(+L: +List<U32>, +x: Nat, +h: {CHKL(VS.bt(1n, VS.bdr(x, L))) == ${TRUE}}) -> {CHKv(VBL.nthb(L, x)) == ${TRUE}}:
  match L x:
    case Nil{} 0n: Empty.absurd({CHKv(VBL.nthb(Nil{}, 0n)) == ${TRUE}}, FD.logic__false_true(h))
    case Nil{} 1n+ +q: Empty.absurd({CHKv(VBL.nthb(Nil{}, 1n+q)) == ${TRUE}}, FD.logic__false_true(h))
    case Con{+h0, +t0} 0n: h
    case Con{+h0, +t0} 1n+ +q: chkl(t0, q, h)

def fxs(m: ${MP}) -> +List<U32>:
  match m:
    case Some{Con{S.Fixed{xs}, r}}: xs
    case _: []

@@ bvn_mod_inv @@
# every value whose parts are the window's byte passes the check
def inv(+t: ${TR}, +x: Nat, +v: S.Value, +e: {Codec.parts(v, ${SCH}) == Some{[S.Fixed{UW.WX(t, x, 1n)}]} : ${MP}}) -> {CHK(t, x) == ${TRUE}}:
  chkl(UA.BYT(t), x, bvinv(v, UW.WX(t, x, 1n), e))

@@ bvw1_mod @@
# the last byte's check (bits 1..7 clear) and its low bit
def CHKv(+v: U32) -> Bool: U32.is_eq(U32.and(v, U32.not(O.low_mask(1))), 0)
def CHK(+t: ${TR}, +x: Nat) -> Bool: CHKv(BX(t, ${X32}))
def LB(v: U32) -> Bool:
  match v:
    case U32{WCon{a0, r}}: a0

def OBJ(+d: Nat, +t: ${TR}, +x: Nat) -> ${Tn}: ${OBJ}

def ec(+d: Nat, +off: U32, +x: Nat, +c: U32, +C: Nat, +e: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 28n) == ${TRUE}},
    +eC: {Nat.is_eq(U32.to_nat(c), C) == ${TRUE}}, +hC: {Nat.is_lt(C, ${S}n) == ${TRUE}}, +hb: {Nat.is_le(Nat.add(x, ${S}n), ${P}) == ${TRUE}})
    -> {U32.to_nat(U32.add(off, c)) == Nat.add(C, x) : Nat}:
  VXG.offc0(d, off, c, C, x, ${S}n, e, hd, eC, hC, hb)

def rm(+x: Nat, +C: Nat, +s: Nat, +hc: {Nat.is_le(Nat.add(C, s), ${S}n) == ${TRUE}}, +P: Nat, +hb: {Nat.is_le(Nat.add(x, ${S}n), P) == ${TRUE}})
    -> {Nat.is_le(Nat.add(Nat.add(C, x), s), P) == ${TRUE}}:
  FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, s), P) == ${TRUE}}, Nat.add(x, C), Nat.add(C, x), FD.nat__add_comm(x, C), VXG.roomc(x, ${S}n, C, s, P, hb, hc))

@@ bvw1_mod_2 @@
${sig('rdx', S)}
    -> {T.${p}_read(UA.BF(t, n), off, ${S}) == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & O.Words}:
  VXG.rdg(d, t, n, off, x, e, hd, pf, ${S}, ${S}n, ${dz}n, ${ky}n, {==}, {==}, {==}, {==}, {==}, hb)

@@ bvw1_mod_3 @@
${sig('rdx', S)}
    -> {T.${p}_read(UA.BF(t, n), off, ${S}) == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & ${Tn}}:
  +hd31 = FD.nat__lt_trans(d, 28n, 31n, hd, {==})
  +e32 = ec(d, off, x, ${C}, ${C}n, e, hd, {==}, {==}, hb)
  +hb1 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(z, 1n), ${P}) == ${TRUE}}, ${X32}, U32.to_nat(U32.add(off, ${C})), Equal.sym(Nat, U32.to_nat(U32.add(off, ${C})), ${X32}, e32),
    rm(x, ${C}n, 1n, {==}, ${P}, hb))
@@ bvw1_mod_4 @@
  %Equal.sym(B.Buf & U32, B.read32(UA.BF(t, n), ${X}), (UA.BF(t, n), VE.RV(t, n, ${X})), VE.rd_same(t, n, ${X})) :
    {T.${p}_r${M}(${args}) == ${RHS}}
  %Equal.sym(U32, O.keep(1, VE.RV(t, n, ${X})), O.keep(1, UA.RW(t, ${X})), VE.kv1(d, t, n, ${X}, hd31, pf, hb1)) :
    {(UA.BF(t, n), ${Tn}{${', '.join(got)}, _}) == ${RHS}}
  %Equal.sym(U32, UA.RW(t, ${X}), UR.RWN(t, U32.to_nat(${X})), UR.rw_n(t, ${X})) : {(UA.BF(t, n), ${Tn}{${', '.join(got)}, O.keep(1, _)}) == ${RHS}}
  %Equal.sym(Nat, U32.to_nat(${X}), ${X32}, e32) : {(UA.BF(t, n), ${Tn}{${', '.join(got)}, O.keep(1, UR.RWN(t, _))}) == ${RHS}}
  {==}

@@ bvw1_mod_5 @@
# the validator on the last byte returns CHK
${sig('ok', S)}
    -> {T.${p}_ok_at(UA.BF(t, n), off) == (UA.BF(t, n), CHK(t, x)) : B.Buf & Bool}:
  +e32 = ec(d, off, x, ${C}, ${C}n, e, hd, {==}, {==}, hb)
  +hi = VR.hiX(d, U32.add(off, ${C}), ${X32}, e32, VXG.ltx(${X32}, 1n, ${P}, {==}, rm(x, ${C}n, 1n, {==}, ${P}, hb)))
  %Equal.sym(B.Buf & U32, B.byte_at(UA.BF(t, n), U32.add(off, ${C})), (UA.BF(t, n), VR.VX(t, U32.add(off, ${C}))), VR.byte_at_ok(d, t, n, U32.add(off, ${C}), FD.nat__lt_trans(d, 28n, 32n, hd, {==}), hi, pf)) :
    {O.pad_pick(1, _) == (UA.BF(t, n), CHK(t, x)) : B.Buf & Bool}
  %Equal.sym(U32, VR.VX(t, U32.add(off, ${C})), BX(t, ${X32}), vx_bx(t, U32.add(off, ${C}), ${X32}, e32)) :
    {O.pad_pick(1, (UA.BF(t, n), _)) == (UA.BF(t, n), CHK(t, x)) : B.Buf & Bool}
  {==}

@@ bvw1_mod_VAL @@
def VAL(+t: ${TR}, +x: Nat) -> S.Value: S.BitsValue{${BITS}}

# the packing of whole words' bits then more bits
law pack_app:
  for +ws: +List<U32>
  for +tl: +List<Bool>
  {Bp.pack(List.append(&2, Bool, FB.bitsof(ws), tl)) == List.append(&2, U32, F.limbs(ws), Bp.pack(tl)) : +List<U32>}
def pack_app(ws, tl):
  match ws:
    case Nil{}: {==}
    case Con{+h, +r}:
      match h:
        case ${word(['+' + x for x in a])}:
          +e1 = FB.pack_limbs([H])
          +e2 = Equal.trans(+List<U32>, List.append(&2, U32, O4, Bp.pack(List.append(&2, Bool, FB.bitsof(r), tl))),
            List.append(&2, U32, List.append(&2, U32, I.limb(H), []), Bp.pack(List.append(&2, Bool, FB.bitsof(r), tl))),
            List.append(&2, U32, I.limb(H), Bp.pack(List.append(&2, Bool, FB.bitsof(r), tl))),
            Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, z, Bp.pack(List.append(&2, Bool, FB.bitsof(r), tl))), O4, List.append(&2, U32, I.limb(H), []), e1),
            Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, z, Bp.pack(List.append(&2, Bool, FB.bitsof(r), tl))), List.append(&2, U32, I.limb(H), []), I.limb(H), VS.app_nil(I.limb(H))))
          Equal.trans(+List<U32>, List.append(&2, U32, O4, Bp.pack(List.append(&2, Bool, FB.bitsof(r), tl))),
            List.append(&2, U32, I.limb(H), Bp.pack(List.append(&2, Bool, FB.bitsof(r), tl))),
            List.append(&2, U32, List.append(&2, U32, I.limb(H), F.limbs(r)), Bp.pack(tl)), e2,
            Equal.trans(+List<U32>, List.append(&2, U32, I.limb(H), Bp.pack(List.append(&2, Bool, FB.bitsof(r), tl))),
              List.append(&2, U32, I.limb(H), List.append(&2, U32, F.limbs(r), Bp.pack(tl))),
              List.append(&2, U32, List.append(&2, U32, I.limb(H), F.limbs(r)), Bp.pack(tl)),
              Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, I.limb(H), z), Bp.pack(List.append(&2, Bool, FB.bitsof(r), tl)), List.append(&2, U32, F.limbs(r), Bp.pack(tl)), pack_app(r, tl)),
              Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, I.limb(H), F.limbs(r)), Bp.pack(tl)), List.append(&2, U32, I.limb(H), List.append(&2, U32, F.limbs(r), Bp.pack(tl))),
                VS.app_assoc(I.limb(H), F.limbs(r), Bp.pack(tl)))))

@@ bvw1_mod_wx @@
# the window's ${S} bytes: the words' limbs, then the last byte
def wx(+d: Nat, +t: ${TR}, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}, +hb: {Nat.is_le(Nat.add(x, ${S}n), ${P}) == ${TRUE}})
    -> {UW.WX(t, x, ${S}n) == ${APP} : +List<U32>}:
  %wx1(d, t, ${X32}, pf, rm(x, ${C}n, 1n, {==}, ${P}, hb)) :
    {UW.WX(t, x, ${S}n) == List.append(&2, U32, F.limbs(${WS}), _) : +List<U32>}
  %VXG.cnt_eq(x, ${M}n) : {UW.WX(t, x, ${S}n) == List.append(&2, U32, F.limbs(UR.RWS(_, t, x)), UW.WX(t, ${X32}, 1n)) : +List<U32>}
  VXG.splitC0(d, t, x, pf, ${M}n, ${C}n, 1n, ${S}n, {==}, {==}, hb)

def elen(+t: ${TR}, +x: Nat) -> {List.length(&2, Bool, ${BITS}) == ${NB}n : Nat}:
  %Equal.sym(Nat, List.length(&2, Bool, ${BITS}), Nat.add(List.length(&2, Bool, FB.bitsof(${WS})), 1n), VBL.lenB_app(FB.bitsof(${WS}), [LB(BX(t, ${X32}))])) : {_ == ${NB}n : Nat}
  %Equal.sym(Nat, List.length(&2, Bool, FB.bitsof(${WS})), FB.bitlen(${WS}), FB.len_bits(${WS})) : {Nat.add(_, 1n) == ${NB}n : Nat}
  {==}

def prt(+d: Nat, +t: ${TR}, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}, +hb: {Nat.is_le(Nat.add(x, ${S}n), ${P}) == ${TRUE}},
    +s: S.Schema, +es: {s == ${SCH} : S.Schema}, +hchk: {CHK(t, x) == ${TRUE}})
    -> {Codec.parts(VAL(t, x), s) == Some{[S.Fixed{UW.WX(t, x, ${S}n)}]} : ${MP}}:
  %Equal.sym(S.Schema, s, ${SCH}, es) : {Codec.parts(VAL(t, x), _) == Some{[S.Fixed{UW.WX(t, x, ${S}n)}]} : ${MP}}
  %Equal.sym(+List<U32>, UW.WX(t, x, ${S}n), ${APP}, wx(d, t, x, pf, hb)) : {Codec.parts(VAL(t, x), ${SCH}) == Some{[S.Fixed{_}]} : ${MP}}
  %ob1(BX(t, ${X32}), hchk) : {Codec.parts(VAL(t, x), ${SCH}) == Some{[S.Fixed{List.append(&2, U32, F.limbs(${WS}), [_])}]} : ${MP}}
  %pack_app(${WS}, [LB(BX(t, ${X32}))]) : {Codec.parts(VAL(t, x), ${SCH}) == Some{[S.Fixed{_}]} : ${MP}}
  %Equal.sym(Nat, List.length(&2, Bool, ${BITS}), ${NB}n, elen(t, x)) :
    {Codec.one(SBF.encoding(Bool.and(Nat.is_lt(0n, ${NB}n), Nat.is_eq(_, ${NB}n)), ${BITS}), Some{Nat.div(Nat.add(${NB}n, 7n), 8n)}) == Some{[S.Fixed{Bp.pack(${BITS})}]} : ${MP}}
  {==}

@@ bvw1_mod_GE @@
# ---- every value whose parts are the window's bytes passes the check -------------------------

def GE(k: Nat, z: Nat) -> Bool:
  match k z:
    case 0n _: True{}
    case 1n+q 0n: False{}
    case 1n+q 1n+r: GE(q, r)

def LEN(m: Nat) -> Nat:
  match m:
    case 0n: 1n
    case 1n+p: 8n+LEN(p)

def fxs(m: ${MP}) -> +List<U32>:
  match m:
    case Some{Con{S.Fixed{xs}, r}}: xs
    case _: []

def pk0(+bs: +List<Bool>, +h: {List.length(&2, Bool, bs) == 1n : Nat}) -> {CHKv(VBL.nthb(Bp.pack(bs), 0n)) == ${TRUE}}:
  match bs:
    case Nil{}: Empty.absurd({CHKv(VBL.nthb(Bp.pack(Nil{}), 0n)) == ${TRUE}}, FD.logic__false_true(Equal.sym(Bool, True{}, False{}, Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), 0n, 1n, h))))
    case Con{True{}, Nil{}}: {==}
    case Con{False{}, Nil{}}: {==}
    case Con{+b0, Con{+b1, +r}}: Empty.absurd({CHKv(VBL.nthb(Bp.pack(b0 <> b1 <> r), 0n)) == ${TRUE}}, FD.logic__false_true(Equal.cong(Nat, Bool, z => Nat.is_eq(z, 1n), 2n+List.length(&2, Bool, r), 1n, h)))

law pkl:
  for +m: Nat
  for +bs: +List<Bool>
  for +h: {List.length(&2, Bool, bs) == LEN(m) : Nat}
  {CHKv(VBL.nthb(Bp.pack(bs), m)) == ${TRUE}}
@@ bvw1_mod_ivb @@
def ivb(+t: ${TR}, +x: Nat, +bs: +List<Bool>, +b: Bool, +eb: {Nat.is_eq(List.length(&2, Bool, bs), ${NB}n) == b : Bool},
    +e: {Codec.one(SBF.encoding(Bool.and(Nat.is_lt(0n, ${NB}n), b), bs), Some{Nat.div(Nat.add(${NB}n, 7n), 8n)}) == Some{[S.Fixed{UW.WX(t, x, ${S}n)}]} : ${MP}})
    -> {CHK(t, x) == ${TRUE}}:
  match b:
    case False{}: ${AB}
    case True{}:
      +ey = Equal.cong(${MP}, +List<U32>, z => fxs(z), Some{[S.Fixed{Bp.pack(bs)}]}, Some{[S.Fixed{UW.WX(t, x, ${S}n)}]}, e)
      +c = pkl(${C}n, bs, FD.nat__eq_from_is_eq(List.length(&2, Bool, bs), ${NB}n, eb))
      +c2 = FD.logic__subst(+List<U32>, z => {CHKv(VBL.nthb(z, ${C}n)) == ${TRUE}}, Bp.pack(bs), UW.WX(t, x, ${S}n), ey, c)
      +c3 = FD.logic__subst(U32, z => {CHKv(z) == ${TRUE}}, VBL.nthb(UW.WX(t, x, ${S}n), ${C}n), VBL.nthb(VS.bdr(x, UA.BYT(t)), ${C}n), VR.nth_bt(${S}n, VS.bdr(x, UA.BYT(t)), ${C}n, {==}), c2)
      +c4 = FD.logic__subst(U32, z => {CHKv(z) == ${TRUE}}, VBL.nthb(VS.bdr(x, UA.BYT(t)), ${C}n), BX(t, Nat.add(x, ${C}n)), VR.nth_bdr(x, UA.BYT(t), ${C}n), c3)
      FD.logic__subst(Nat, z => {CHKv(BX(t, z)) == ${TRUE}}, Nat.add(x, ${C}n), ${X32}, FD.nat__add_comm(x, ${C}n), c4)

# every value whose parts are the window's bytes passes the check
def inv(+t: ${TR}, +x: Nat, +v: S.Value, +e: {Codec.parts(v, ${SCH}) == Some{[S.Fixed{UW.WX(t, x, ${S}n)}]} : ${MP}}) -> {CHK(t, x) == ${TRUE}}:
  match v:
    case S.BitsValue{+bs}: ivb(t, x, bs, Nat.is_eq(List.length(&2, Bool, bs), ${NB}n), {==}, e)
@@ body @@

def OBJ(+d: Nat, +t: ${TR}, +x: Nat) -> U32: UR.RWN(t, x)

${sig('rdx', 4)}
    -> {T.u32_read(UA.BF(t, n), off, 4) == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & U32}:
  UR.rwx(d, t, n, off, x, e, FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf, hb)

def VAL(+t: ${TR}, +x: Nat) -> S.Value: S.UnsignedValue{P.UInt{UR.RWN(t, x), 0, 0, 0, 0, 0, 0, 0}}

def prt(+d: Nat, +t: ${TR}, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}, +hb: {Nat.is_le(Nat.add(x, 4n), ${P}) == ${TRUE}},
    +s: S.Schema, +es: {s == ${SCH} : S.Schema})
    -> {Codec.parts(VAL(t, x), s) == Some{[S.Fixed{UW.WX(t, x, 4n)}]} : ${MP}}:
  %Equal.sym(S.Schema, s, ${SCH}, es) : {Codec.parts(VAL(t, x), _) == Some{[S.Fixed{UW.WX(t, x, 4n)}]} : ${MP}}
  %UR.rws_bytes(1n, d, t, x, pf, hb) : {Codec.parts(VAL(t, x), ${SCH}) == Some{[S.Fixed{_}]} : ${MP}}
  F.uint32_part(UR.RWN(t, x))
