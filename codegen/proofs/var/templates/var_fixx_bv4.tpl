@@ bv4_mod @@
# the byte at Nat position x, and the validator's check (bits 4..7 clear)
def BX(+t: ${TR}, +x: Nat) -> U32: VBL.nthb(UA.BYT(t), x)
def CHKv(+v: U32) -> Bool: U32.is_eq(U32.and(v, U32.not(O.low_mask(4))), 0)
def CHK(+t: ${TR}, +x: Nat) -> Bool: CHKv(BX(t, x))

def OBJ(+d: Nat, +t: ${TR}, +x: Nat) -> T.Bitvector4: T.Bitvector4{O.keep(1, UR.RWN(t, x))}

# (reads the four bytes at x: x + 4 <= 4 2^d)
${sig('rdx', 4)}
    -> {T.bv4_read(UA.BF(t, n), off, 1) == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & T.Bitvector4}:
  %Equal.sym(B.Buf & U32, B.read32(UA.BF(t, n), off), (UA.BF(t, n), UR.RWN(t, x)), UR.rwx(d, t, n, off, x, e, FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf, UR.roomw(x, 4n, 0n, ${P}, hb, {==}))) :
    {T.bv4_r0(off, _) == (UA.BF(t, n), OBJ(d, t, x)) : B.Buf & T.Bitvector4}
  {==}

# the runtime's byte at off is the byte at off's position
def vx_bx(+t: ${TR}, +off: U32, +x: Nat, +e: {U32.to_nat(off) == x : Nat}) -> {VR.VX(t, off) == BX(t, x) : U32}:
  %e : {VR.VX(t, off) == VBL.nthb(UA.BYT(t), _) : U32}
  %Equal.sym(Nat, U32.to_nat(off), Nat.add(A.quad(VR.QX(off)), VR.RX(off)), VC.split4(off)) : {VR.VX(t, off) == VBL.nthb(UA.BYT(t), _) : U32}
  %Equal.sym(U32, VBL.nthb(UA.BYT(t), Nat.add(A.quad(VR.QX(off)), VR.RX(off))), VR.bsN(VR.RX(off), VB.slot(t, VR.QX(off))), VR.nth_limbs(VR.SL(t), VR.QX(off), VR.RX(off), UA.rx_lt(off))) :
    {VR.VX(t, off) == _ : U32}
  VR.bs_eq(U32.and(off, 3), VB.slot(t, VR.QX(off)), VR.RX(off), {==}, UA.rx_lt(off))

# the validator on the byte at off returns CHK
${sig('ok', 4)}
    -> {T.bv4_ok_at(UA.BF(t, n), off) == (UA.BF(t, n), CHK(t, x)) : B.Buf & Bool}:
  +e0 = Equal.trans(Nat, U32.to_nat(U32.add(off, 0)), Nat.add(x, 0n), x, VXG.offc(d, off, 0, 0n, x, 4n, e, hd, {==}, {==}, hb), FD.nat__add_zero(x))
  +hi = VR.hiX(d, U32.add(off, 0), x, e0, VXG.ltx(x, 4n, ${P}, {==}, hb))
  %Equal.sym(B.Buf & U32, B.byte_at(UA.BF(t, n), U32.add(off, 0)), (UA.BF(t, n), VR.VX(t, U32.add(off, 0))), VR.byte_at_ok(d, t, n, U32.add(off, 0), FD.nat__lt_trans(d, 28n, 32n, hd, {==}), hi, pf)) :
    {O.pad_pick(4, _) == (UA.BF(t, n), CHK(t, x)) : B.Buf & Bool}
  %Equal.sym(U32, VR.VX(t, U32.add(off, 0)), BX(t, x), vx_bx(t, U32.add(off, 0), x, e0)) :
    {O.pad_pick(4, (UA.BF(t, n), _)) == (UA.BF(t, n), CHK(t, x)) : B.Buf & Bool}
  {==}

# the four low bits
def VB4(v: U32) -> S.Value:
  match v:
    case U32{WCon{a0, WCon{a1, WCon{a2, WCon{a3, r}}}}}: S.BitsValue{[a0, a1, a2, a3]}
def VAL(+t: ${TR}, +x: Nat) -> S.Value: VB4(BX(t, x))

# bt(1, bdr(x, L)) is the byte at x
def bt1(+L: +List<U32>, +x: Nat, +h: {Nat.is_lt(x, List.length(&2, U32, L)) == ${TRUE}}) -> {VS.bt(1n, VS.bdr(x, L)) == [VBL.nthb(L, x)] : +List<U32>}:
  match L x:
    case Nil{} 0n: Empty.absurd({VS.bt(1n, VS.bdr(0n, Nil{})) == [VBL.nthb(Nil{}, 0n)] : +List<U32>}, FD.logic__false_true(h))
    case Nil{} 1n+ +q: Empty.absurd({VS.bt(1n, VS.bdr(1n+q, Nil{})) == [VBL.nthb(Nil{}, 1n+q)] : +List<U32>}, FD.nat__lt_zero_absurd(1n+q, h))
    case Con{+h0, +t0} 0n: {==}
    case Con{+h0, +t0} 1n+ +q: bt1(t0, q, h)

def wx1(+d: Nat, +t: ${TR}, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}, +hb: {Nat.is_le(Nat.add(x, 1n), ${P}) == ${TRUE}})
    -> {UW.WX(t, x, 1n) == [BX(t, x)] : +List<U32>}:
  bt1(UA.BYT(t), x, FD.logic__subst(Nat, z => {Nat.is_lt(x, z) == ${TRUE}}, ${P}, List.length(&2, U32, UA.BYT(t)), Equal.sym(Nat, List.length(&2, U32, UA.BYT(t)), ${P}, VR.lenS(d, t, pf)),
    VXG.ltx(x, 1n, ${P}, {==}, hb)))

@@ bv4_mod_prt @@
def prt(+d: Nat, +t: ${TR}, +x: Nat, +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}, +hb: {Nat.is_le(Nat.add(x, 4n), ${P}) == ${TRUE}},
    +s: S.Schema, +es: {s == Spec.Schema83() : S.Schema}, +hchk: {CHK(t, x) == ${TRUE}})
    -> {Codec.parts(VAL(t, x), s) == Some{[S.Fixed{UW.WX(t, x, 1n)}]} : ${MP}}:
  %Equal.sym(S.Schema, s, Spec.Schema83(), es) : {Codec.parts(VAL(t, x), _) == Some{[S.Fixed{UW.WX(t, x, 1n)}]} : ${MP}}
  %Equal.sym(+List<U32>, UW.WX(t, x, 1n), [BX(t, x)], wx1(d, t, x, pf, FD.nat__le_trans(Nat.add(x, 1n), Nat.add(x, 4n), ${P}, Order.add_left(x, 1n, 4n, {==}), hb))) :
    {Codec.parts(VAL(t, x), Spec.Schema83()) == Some{[S.Fixed{_}]} : ${MP}}
  bvp(BX(t, x), hchk)

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

@@ bv4_mod_inv @@
# every value whose parts are the window's byte passes the check
def inv(+t: ${TR}, +x: Nat, +v: S.Value, +e: {Codec.parts(v, Spec.Schema83()) == Some{[S.Fixed{UW.WX(t, x, 1n)}]} : ${MP}}) -> {CHK(t, x) == ${TRUE}}:
  chkl(UA.BYT(t), x, bvinv(v, UW.WX(t, x, 1n), e))

@@ bv4_mod_lines @@

def bvp(+v: U32, +h: {CHKv(v) == ${TRUE}}) -> ${goalv('v')}:
  match v:
    case ${word(['+' + x for x in a])}: z31(${', '.join(a)}, h)

@@ bv4_mod_lines_2 @@

# any bits value whose parts are one fixed part ys: the first byte of ys has bits 4..7 clear
def bvinv(+v: S.Value, +ys: +List<U32>, +e: {Codec.parts(v, S.BitVector{4n}) == Some{[S.Fixed{ys}]} : ${MP}}) -> {CHKL(ys) == ${TRUE}}:
  match v:
    case S.BitsValue{+bs}:
      match bs:
        case Nil{}: ${AB}
        case Con{+b0, +r0}:
          match r0:
            case Nil{}: ${AB}
            case Con{+b1, +r1}:
              match r1:
                case Nil{}: ${AB}
                case Con{+b2, +r2}:
                  match r2:
                    case Nil{}: ${AB}
                    case Con{+b3, +r3}:
                      match r3:
                        case Con{+b4, +r4}: ${AB}
                        case Nil{}:
                          +ey = Equal.cong(${MP}, +List<U32>, z => fxs(z), Some{[S.Fixed{[${OCT}]}]}, Some{[S.Fixed{ys}]}, e)
                          %Equal.sym(+List<U32>, ys, [${OCT}], Equal.sym(+List<U32>, [${OCT}], ys, ey)) : {CHKL(_) == ${TRUE}}
                          chko(b0, b1, b2, b3)