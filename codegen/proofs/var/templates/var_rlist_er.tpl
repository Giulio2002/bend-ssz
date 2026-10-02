@@ _er_offsets @@
# the offsets, the lists' lengths, byte positions and runtime offsets
def O0(+t: ${TR}, +x: Nat) -> U32: UR.RWN(t, x)
def O1(+t: ${TR}, +x: Nat) -> U32: UR.RWN(t, 4n+x)
def O2(+t: ${TR}, +x: Nat) -> U32: UR.RWN(t, 8n+x)
def L0(+t: ${TR}, +x: Nat) -> U32: U32.sub(O1(t, x), O0(t, x))
def L1(+t: ${TR}, +x: Nat) -> U32: U32.sub(O2(t, x), O1(t, x))
def L2(+t: ${TR}, +x: Nat, +len: U32) -> U32: U32.sub(len, O2(t, x))
def X0(+t: ${TR}, +x: Nat) -> Nat: Nat.add(U32.to_nat(O0(t, x)), x)
def X1(+t: ${TR}, +x: Nat) -> Nat: Nat.add(U32.to_nat(O1(t, x)), x)
def X2(+t: ${TR}, +x: Nat) -> Nat: Nat.add(U32.to_nat(O2(t, x)), x)
def F0(+off: U32, +t: ${TR}, +x: Nat) -> U32: U32.add(off, O0(t, x))
def F1(+off: U32, +t: ${TR}, +x: Nat) -> U32: U32.add(off, O1(t, x))
def F2(+off: U32, +t: ${TR}, +x: Nat) -> U32: U32.add(off, O2(t, x))


@@ _er_validator @@
# ---- the validator ------------------------------------------------------------------------------

def CA(+len: U32) -> Bool: U32.is_le(12, len)
def CB(+t: ${TR}, +x: Nat) -> Bool: U32.is_eq(O0(t, x), 12)
def CC(+t: ${TR}, +x: Nat, +len: U32) -> Bool: Bool.and(U32.is_le(O0(t, x), O1(t, x)), U32.is_le(O1(t, x), len))
def CD(+t: ${TR}, +x: Nat, +len: U32) -> Bool: Bool.and(U32.is_le(O1(t, x), O2(t, x)), U32.is_le(O2(t, x), len))
def CE(${TXO}) -> Bool: C0.CHKw(t, X0(t, x), F0(off, t, x), L0(t, x))
def CF(${TXO}) -> Bool: C1.CHKw(t, X1(t, x), F1(off, t, x), L1(t, x))
def CG(${TXO}) -> Bool: C2.CHKw(t, X2(t, x), F2(off, t, x), L2(t, x, len))
def K5(${TXO}) -> Bool: Bool.and(CF(t, x, off, len), CG(t, x, off, len))
def K4(${TXO}) -> Bool: Bool.and(CE(t, x, off, len), K5(t, x, off, len))
def K3(${TXO}) -> Bool: Bool.and(CD(t, x, len), K4(t, x, off, len))
def K2(${TXO}) -> Bool: Bool.and(CC(t, x, len), K3(t, x, off, len))
def K1(${TXO}) -> Bool: Bool.and(CB(t, x), K2(t, x, off, len))
def CHKw(${TXO}) -> Bool: Bool.and(CA(len), K1(t, x, off, len))

def okG(+t: ${TR}, +n: U32, +x: Nat, +off: U32, +len: U32, +g: Bool)
    -> {T.${X}_c5(g, BF(t, n), off, len, ${O[0]}, ${O[1]}, ${O[2]}) == (BF(t, n), g) : B.Buf & Bool}:
  match g:
    case True{}: {==}
    case False{}: {==}
def okF(+t: ${TR}, +n: U32, +x: Nat, +off: U32, +len: U32, +f: Bool)
    -> {T.${X}_c4(f, BF(t, n), off, len, ${O[0]}, ${O[1]}, ${O[2]}) == (BF(t, n), Bool.and(f, CG(t, x, off, len))) : B.Buf & Bool}:
  match f:
    case True{}: okG(t, n, x, off, len, CG(t, x, off, len))
    case False{}: {==}
def okE(+t: ${TR}, +n: U32, +x: Nat, +off: U32, +len: U32, +e: Bool)
    -> {T.${X}_c3(e, BF(t, n), off, len, ${O[0]}, ${O[1]}, ${O[2]}) == (BF(t, n), Bool.and(e, K5(t, x, off, len))) : B.Buf & Bool}:
  match e:
    case True{}: okF(t, n, x, off, len, CF(t, x, off, len))
    case False{}: {==}
def okD(+t: ${TR}, +n: U32, +x: Nat, +off: U32, +len: U32, +c: Bool)
    -> {T.${X}_c2(c, BF(t, n), off, len, ${O[0]}, ${O[1]}, ${O[2]}) == (BF(t, n), Bool.and(c, K4(t, x, off, len))) : B.Buf & Bool}:
  match c:
    case True{}: okE(t, n, x, off, len, CE(t, x, off, len))
    case False{}: {==}


@@ _er_header_words @@
# the header words, read at off, off + 4, off + 8
def rdo(${CW}, +k: Nat, +c: U32, +ec: {U32.to_nat(c) == k : Nat}, +hk: {Nat.is_le(Nat.add(k, 4n), 12n) == ${TRUE}},
    +h12: {Nat.is_le(Nat.add(x, 12n), ${P}) == ${TRUE}})
    -> {B.read32(BF(t, n), U32.add(off, c)) == (BF(t, n), UR.RWN(t, Nat.add(k, x))) : B.Buf & U32}:
  +hr = UR.roomw(x, 12n, k, ${P}, h12, hk)
  UR.rwx(d, t, n, U32.add(off, c), Nat.add(k, x),
    Equal.trans(Nat, U32.to_nat(U32.add(off, c)), Nat.add(U32.to_nat(c), x), Nat.add(k, x),
      UR.offx(d, off, c, x, eo, FD.nat__lt_trans(d, 28n, 30n, hd, {==}),
        FD.logic__subst(Nat, z => {Nat.is_lt(Nat.add(z, x), ${P}) == ${TRUE}}, k, U32.to_nat(c), Equal.sym(Nat, U32.to_nat(c), k, ec),
          FD.nat__lt_le_trans(Nat.add(k, x), Nat.add(Nat.add(k, x), 4n), ${P}, VTX.ltp(Nat.add(k, x), 3n), hr))),
      Equal.cong(Nat, Nat, z => Nat.add(z, x), U32.to_nat(c), k, ec)),
    FD.nat__lt_trans(d, 28n, 31n, hd, {==}), pf, hr)

def h12of(${CW}, +ha: {U32.is_le(12, len) == ${TRUE}}) -> {Nat.is_le(Nat.add(x, 12n), ${P}) == ${TRUE}}:
  FD.nat__le_trans(Nat.add(x, 12n), Nat.add(x, U32.to_nat(len)), ${P},
    Order.add_left(x, 12n, U32.to_nat(len), FD.logic__subst(Bool, z => {z == ${TRUE}}, U32.is_le(12, len), Nat.is_le(12n, U32.to_nat(len)), VU.le_u32(12, len), ha)), hw)

def okC(${CW}, +h12: {Nat.is_le(Nat.add(x, 12n), ${P}) == ${TRUE}}, +c: Bool)
    -> {T.${X}_c1(c, BF(t, n), off, len, ${O[0]}, ${O[1]}) == (BF(t, n), Bool.and(c, K3(t, x, off, len))) : B.Buf & Bool}:
  match c:
    case True{}:
      %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, 8)), (BF(t, n), ${O[2]}), rdo(${CA}, 8n, 8, {==}, {==}, h12)) :
        {T.${X}_v2(off, len, ${O[0]}, ${O[1]}, _) == (BF(t, n), K3(t, x, off, len)) : B.Buf & Bool}
      okD(t, n, x, off, len, CD(t, x, len))
    case False{}: {==}
def okB(${CW}, +h12: {Nat.is_le(Nat.add(x, 12n), ${P}) == ${TRUE}}, +b: Bool)
    -> {T.${X}_c0(b, BF(t, n), off, len, ${O[0]}) == (BF(t, n), Bool.and(b, K2(t, x, off, len))) : B.Buf & Bool}:
  match b:
    case True{}:
      %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, 4)), (BF(t, n), ${O[1]}), rdo(${CA}, 4n, 4, {==}, {==}, h12)) :
        {T.${X}_v1(off, len, ${O[0]}, _) == (BF(t, n), K2(t, x, off, len)) : B.Buf & Bool}
      okC(${CA}, h12, CC(t, x, len))
    case False{}: {==}
def okA(${CW}, +a: Bool, +ea: {U32.is_le(12, len) == a : Bool})
    -> {T.${X}_ok_len(a, BF(t, n), off, len) == (BF(t, n), Bool.and(a, K1(t, x, off, len))) : B.Buf & Bool}:
  match a:
    case True{}:
      +h12 = h12of(${CA}, ea)
      %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, 0)), (BF(t, n), ${O[0]}), rdo(${CA}, 0n, 0, {==}, {==}, h12)) :
        {T.${X}_v0(off, len, _) == (BF(t, n), K1(t, x, off, len)) : B.Buf & Bool}
      okB(${CA}, h12, CB(t, x))
    case False{}: {==}

def ok_evalw(${CW}) -> {T.${X}_ok(BF(t, n), off, len) == (BF(t, n), CHKw(t, x, off, len)) : B.Buf & Bool}:
  okA(${CA}, CA(len), {==})


@@ _er_reader @@
# ---- the reader ---------------------------------------------------------------------------------

def OBJw(+d: Nat, ${TXO}) -> T.${X}:
  T.${X}{C0.OBJw(d, t, ${Xk[0]}, ${Fk[0]}, ${Lk[0]}), C1.OBJw(d, t, ${Xk[1]}, ${Fk[1]}, ${Lk[1]}), C2.OBJw(d, t, ${Xk[2]}, ${Fk[2]}, ${Lk[2]})}

def readw(${CW}, +hchk: {CHKw(t, x, off, len) == ${TRUE}})
    -> {T.${X}_read(BF(t, n), off, len) == (BF(t, n), OBJw(d, t, x, off, len)) : B.Buf & T.${X}}:
  +h12 = h12of(${CA}, hA(t, x, off, len, hchk))
  +RHS = (BF(t, n), OBJw(d, t, x, off, len))
  %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, 0)), (BF(t, n), ${O[0]}), rdo(${CA}, 0n, 0, {==}, {==}, h12)) :
    {T.${X}_rd0(off, len, _) == RHS : B.Buf & T.${X}}
  %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, 4)), (BF(t, n), ${O[1]}), rdo(${CA}, 4n, 4, {==}, {==}, h12)) :
    {T.${X}_rd1(off, len, ${O[0]}, _) == RHS : B.Buf & T.${X}}
  %Equal.sym(B.Buf & U32, B.read32(BF(t, n), U32.add(off, 8)), (BF(t, n), ${O[2]}), rdo(${CA}, 8n, 8, {==}, {==}, h12)) :
    {T.${X}_rd2(off, len, ${O[0]}, ${O[1]}, _) == RHS : B.Buf & T.${X}}
  %Equal.sym(B.Buf & T.${LS[0]['p']}_Seq, ${RD[0]}(BF(t, n), ${Fk[0]}, ${Lk[0]}), (BF(t, n), C0.OBJw(d, t, ${Xk[0]}, ${Fk[0]}, ${Lk[0]})),
      C0.readw(d, t, n, ${Xk[0]}, ${Fk[0]}, ${Lk[0]}, eo0(${CA}, hchk), hd, hw0(${CA}, hchk), pf, hE(t, x, off, len, hchk))) :
    {T.${X}_rd3(off, len, ${O[0]}, ${O[1]}, ${O[2]}, _) == RHS : B.Buf & T.${X}}
  %Equal.sym(B.Buf & T.${LS[1]['p']}_Seq, ${RD[1]}(BF(t, n), ${Fk[1]}, ${Lk[1]}), (BF(t, n), C1.OBJw(d, t, ${Xk[1]}, ${Fk[1]}, ${Lk[1]})),
      C1.readw(d, t, n, ${Xk[1]}, ${Fk[1]}, ${Lk[1]}, eo1(${CA}, hchk), hd, hw1(${CA}, hchk), pf, hF(t, x, off, len, hchk))) :
    {T.${X}_rd4(off, len, ${O[0]}, ${O[1]}, ${O[2]}, C0.OBJw(d, t, ${Xk[0]}, ${Fk[0]}, ${Lk[0]}), _) == RHS : B.Buf & T.${X}}
  %Equal.sym(B.Buf & T.${LS[2]['p']}_Seq, ${RD[2]}(BF(t, n), ${Fk[2]}, ${Lk[2]}), (BF(t, n), C2.OBJw(d, t, ${Xk[2]}, ${Fk[2]}, ${Lk[2]})),
      C2.readw(d, t, n, ${Xk[2]}, ${Fk[2]}, ${Lk[2]}, eo2(${CA}, hchk), hd, hw2(${CA}, hchk), pf, hG(t, x, off, len, hchk))) :
    {T.${X}_rd5(off, len, ${O[0]}, ${O[1]}, ${O[2]}, C0.OBJw(d, t, ${Xk[0]}, ${Fk[0]}, ${Lk[0]}), C1.OBJw(d, t, ${Xk[1]}, ${Fk[1]}, ${Lk[1]}), _) == RHS : B.Buf & T.${X}}
  {==}


@@ _er_spec_side @@
# ---- the spec side ------------------------------------------------------------------------------

def VALw(+t: ${TR}, +x: Nat, +len: U32) -> S.Value:
  S.Sequence{S.Items{C0.VALw(t, ${Xk[0]}, ${Lk[0]}), S.Items{C1.VALw(t, ${Xk[1]}, ${Lk[1]}), S.Items{C2.VALw(t, ${Xk[2]}, ${Lk[2]}), S.EmptyItems{}}}}}

# the offsets' values
def eO0(${TXO}, +h: {CHKw(t, x, off, len) == ${TRUE}}) -> {U32.to_nat(${O[0]}) == 12n : Nat}:
  Equal.cong(U32, Nat, z => U32.to_nat(z), ${O[0]}, 12, FD.u32alg__eq_of(${O[0]}, 12, hB(t, x, off, len, h)))
def eO1(${TXO}, +h: {CHKw(t, x, off, len) == ${TRUE}}) -> {U32.to_nat(${O[1]}) == Nat.add(U32.to_nat(${O[0]}), U32.to_nat(${Lk[0]})) : Nat}:
  Equal.sym(Nat, Nat.add(U32.to_nat(${O[0]}), U32.to_nat(${Lk[0]})), U32.to_nat(${O[1]}), VM.sub_eq(${O[1]}, ${O[0]}, l01(t, x, off, len, h)))
def eO2(${TXO}, +h: {CHKw(t, x, off, len) == ${TRUE}}) -> {U32.to_nat(${O[2]}) == Nat.add(U32.to_nat(${O[1]}), U32.to_nat(${Lk[1]})) : Nat}:
  Equal.sym(Nat, Nat.add(U32.to_nat(${O[1]}), U32.to_nat(${Lk[1]})), U32.to_nat(${O[2]}), VM.sub_eq(${O[2]}, ${O[1]}, l12(t, x, off, len, h)))
def eLn(${TXO}, +h: {CHKw(t, x, off, len) == ${TRUE}}) -> {U32.to_nat(len) == Nat.add(U32.to_nat(${O[2]}), U32.to_nat(${Lk[2]})) : Nat}:
  Equal.sym(Nat, Nat.add(U32.to_nat(${O[2]}), U32.to_nat(${Lk[2]})), U32.to_nat(len), VM.sub_eq(len, ${O[2]}, l2n(t, x, off, len, h)))

def elen(${TXO}, +h: {CHKw(t, x, off, len) == ${TRUE}})
    -> {U32.to_nat(len) == Nat.add(12n, Nat.add(U32.to_nat(${Lk[0]}), Nat.add(U32.to_nat(${Lk[1]}), U32.to_nat(${Lk[2]})))) : Nat}:
  +a = U32.to_nat(${Lk[0]})
  +b = U32.to_nat(${Lk[1]})
  +c = U32.to_nat(${Lk[2]})
  %Equal.sym(Nat, U32.to_nat(len), Nat.add(U32.to_nat(${O[2]}), c), eLn(t, x, off, len, h)) : {_ == Nat.add(12n, Nat.add(a, Nat.add(b, c))) : Nat}
  %Equal.sym(Nat, U32.to_nat(${O[2]}), Nat.add(U32.to_nat(${O[1]}), b), eO2(t, x, off, len, h)) : {Nat.add(_, c) == Nat.add(12n, Nat.add(a, Nat.add(b, c))) : Nat}
  %Equal.sym(Nat, U32.to_nat(${O[1]}), Nat.add(U32.to_nat(${O[0]}), a), eO1(t, x, off, len, h)) : {Nat.add(Nat.add(_, b), c) == Nat.add(12n, Nat.add(a, Nat.add(b, c))) : Nat}
  %Equal.sym(Nat, U32.to_nat(${O[0]}), 12n, eO0(t, x, off, len, h)) : {Nat.add(Nat.add(Nat.add(_, a), b), c) == Nat.add(12n, Nat.add(a, Nat.add(b, c))) : Nat}
  %Equal.sym(Nat, Nat.add(Nat.add(Nat.add(12n, a), b), c), Nat.add(Nat.add(12n, a), Nat.add(b, c)), FD.nat__add_assoc(Nat.add(12n, a), b, c)) :
    {_ == Nat.add(12n, Nat.add(a, Nat.add(b, c))) : Nat}
  FD.nat__add_assoc(12n, a, Nat.add(b, c))

# The window's bytes: the offset words, then the three lists' windows.
def win3(${CW}, +h: {CHKw(t, x, off, len) == ${TRUE}})
    -> {UW.WX(t, x, U32.to_nat(len)) == List.append(&2, U32, F.limbs([${O[0]}, ${O[1]}, ${O[2]}]), List.append(&2, U32, ${Yk[0]}, List.append(&2, U32, ${Yk[1]}, ${Yk[2]}))) : +List<U32>}:
  +a = U32.to_nat(${Lk[0]})
  +b = U32.to_nat(${Lk[1]})
  +c = U32.to_nat(${Lk[2]})
  +R = Nat.add(a, Nat.add(b, c))
  +RHS3 = List.append(&2, U32, F.limbs([${O[0]}, ${O[1]}, ${O[2]}]), List.append(&2, U32, ${Yk[0]}, List.append(&2, U32, ${Yk[1]}, ${Yk[2]})))
  +hwR = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, z), ${P}) == ${TRUE}}, U32.to_nat(len), Nat.add(12n, R), elen(t, x, off, len, h), hw)
  %Equal.sym(Nat, U32.to_nat(len), Nat.add(12n, R), elen(t, x, off, len, h)) : {UW.WX(t, x, _) == RHS3 : +List<U32>}
  %Equal.sym(+List<U32>, UW.WX(t, x, Nat.add(A.quad(3n), R)), List.append(&2, U32, F.limbs(UR.RWS(3n, t, x)), UW.WX(t, Nat.add(A.quad(3n), x), R)), UW.headWX(d, t, x, 3n, R, pf, hwR)) :
    {_ == RHS3 : +List<U32>}
  %Equal.cong(Nat, Nat, z => Nat.add(z, x), U32.to_nat(${O[0]}), 12n, eO0(t, x, off, len, h)) :
    {List.append(&2, U32, F.limbs(UR.RWS(3n, t, x)), UW.WX(t, _, R)) == RHS3 : +List<U32>}
  %Equal.sym(+List<U32>, UW.WX(t, ${Xk[0]}, Nat.add(a, Nat.add(b, c))), List.append(&2, U32, UW.WX(t, ${Xk[0]}, a), UW.WX(t, Nat.add(a, ${Xk[0]}), Nat.add(b, c))), VRC.splitWX(t, ${Xk[0]}, a, Nat.add(b, c))) :
    {List.append(&2, U32, F.limbs(UR.RWS(3n, t, x)), _) == RHS3 : +List<U32>}
  %VRC.pnext(U32.to_nat(${O[0]}), U32.to_nat(${O[1]}), a, x, eO1(t, x, off, len, h)) :
    {List.append(&2, U32, F.limbs(UR.RWS(3n, t, x)), List.append(&2, U32, UW.WX(t, ${Xk[0]}, a), UW.WX(t, _, Nat.add(b, c)))) == RHS3 : +List<U32>}
  %Equal.sym(+List<U32>, UW.WX(t, ${Xk[1]}, Nat.add(b, c)), List.append(&2, U32, UW.WX(t, ${Xk[1]}, b), UW.WX(t, Nat.add(b, ${Xk[1]}), c)), VRC.splitWX(t, ${Xk[1]}, b, c)) :
    {List.append(&2, U32, F.limbs(UR.RWS(3n, t, x)), List.append(&2, U32, UW.WX(t, ${Xk[0]}, a), _)) == RHS3 : +List<U32>}
  %VRC.pnext(U32.to_nat(${O[1]}), U32.to_nat(${O[2]}), b, x, eO2(t, x, off, len, h)) :
    {List.append(&2, U32, F.limbs(UR.RWS(3n, t, x)), List.append(&2, U32, UW.WX(t, ${Xk[0]}, a), List.append(&2, U32, UW.WX(t, ${Xk[1]}, b), UW.WX(t, _, c)))) == RHS3 : +List<U32>}
  {==}

def specw(${CW}, +hchk: {CHKw(t, x, off, len) == ${TRUE}})
    -> {Codec.parts(VALw(t, x, len), Spec.${X}()) == ${RHSV} : Maybe<&2, +List<S.Part>>}:
  +a = U32.to_nat(${Lk[0]})
  +b = U32.to_nat(${Lk[1]})
  +P0 = Codec.parts(C0.VALw(t, ${Xk[0]}, ${Lk[0]}), ${LS[0]['LSCH']})
  +P1 = Codec.parts(C1.VALw(t, ${Xk[1]}, ${Lk[1]}), ${LS[1]['LSCH']})
  +P2 = Codec.parts(C2.VALw(t, ${Xk[2]}, ${Lk[2]}), ${LS[2]['LSCH']})
  +h0 = hw0(${CA}, hchk)
  +h1 = hw1(${CA}, hchk)
  +h2 = hw2(${CA}, hchk)
  +la = UW.lenWX(d, t, ${Xk[0]}, a, pf, h0)
  +lb = UW.lenWX(d, t, ${Xk[1]}, b, pf, h1)
  +lc = UW.lenWX(d, t, ${Xk[2]}, U32.to_nat(${Lk[2]}), pf, h2)
  +e1 = Equal.trans(Nat, U32.to_nat(${O[1]}), Nat.add(U32.to_nat(${O[0]}), a), Nat.add(12n, List.length(&2, U32, ${Yk[0]})), eO1(t, x, off, len, hchk),
    Equal.trans(Nat, Nat.add(U32.to_nat(${O[0]}), a), Nat.add(12n, a), Nat.add(12n, List.length(&2, U32, ${Yk[0]})),
      Equal.cong(Nat, Nat, z => Nat.add(z, a), U32.to_nat(${O[0]}), 12n, eO0(t, x, off, len, hchk)),
      Equal.cong(Nat, Nat, z => Nat.add(12n, z), a, List.length(&2, U32, ${Yk[0]}), Equal.sym(Nat, List.length(&2, U32, ${Yk[0]}), a, la))))
  +e2 = Equal.trans(Nat, U32.to_nat(${O[2]}), Nat.add(U32.to_nat(${O[1]}), b), Nat.add(Nat.add(12n, List.length(&2, U32, ${Yk[0]})), List.length(&2, U32, ${Yk[1]})), eO2(t, x, off, len, hchk),
    Equal.trans(Nat, Nat.add(U32.to_nat(${O[1]}), b), Nat.add(Nat.add(12n, List.length(&2, U32, ${Yk[0]})), b), Nat.add(Nat.add(12n, List.length(&2, U32, ${Yk[0]})), List.length(&2, U32, ${Yk[1]})),
      Equal.cong(Nat, Nat, z => Nat.add(z, b), U32.to_nat(${O[1]}), Nat.add(12n, List.length(&2, U32, ${Yk[0]})), e1),
      Equal.cong(Nat, Nat, z => Nat.add(Nat.add(12n, List.length(&2, U32, ${Yk[0]})), z), b, List.length(&2, U32, ${Yk[1]}), Equal.sym(Nat, List.length(&2, U32, ${Yk[1]}), b, lb))))
  +ef = Equal.trans(Nat, Nat.add(U32.to_nat(${O[2]}), List.length(&2, U32, ${Yk[2]})), Nat.add(U32.to_nat(${O[2]}), U32.to_nat(${Lk[2]})), U32.to_nat(len),
    Equal.cong(Nat, Nat, z => Nat.add(U32.to_nat(${O[2]}), z), List.length(&2, U32, ${Yk[2]}), U32.to_nat(${Lk[2]}), lc), Equal.sym(Nat, U32.to_nat(len), Nat.add(U32.to_nat(${O[2]}), U32.to_nat(${Lk[2]})), eLn(t, x, off, len, hchk)))
  +fit = FD.logic__subst(Nat, z => {N.fits(4n, z) == ${TRUE}}, U32.to_nat(len), Nat.add(U32.to_nat(${O[2]}), List.length(&2, U32, ${Yk[2]})), Equal.sym(Nat, Nat.add(U32.to_nat(${O[2]}), List.length(&2, U32, ${Yk[2]})), U32.to_nat(len), ef),
    VFT.fits4(2n+d, U32.to_nat(len), FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), ${P}, Order.left_below_sum(x, U32.to_nat(len)), hw), FD.nat__lt_trans(d, 28n, 30n, hd, {==})))
  %Equal.sym(Maybe<&2, +List<S.Part>>, P0, Some{[S.Variable{${Yk[0]}}]}, C0.specw(d, t, n, ${Xk[0]}, ${Fk[0]}, ${Lk[0]}, eo0(${CA}, hchk), hd, h0, pf, hE(t, x, off, len, hchk))) :
    {Codec.aggregate(Codec.concatenate(_, Codec.concatenate(P1, Codec.concatenate(P2, Codec.parts(S.EmptyItems{}, S.End{})))), None{}) == ${RHSV} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Maybe<&2, +List<S.Part>>, P1, Some{[S.Variable{${Yk[1]}}]}, C1.specw(d, t, n, ${Xk[1]}, ${Fk[1]}, ${Lk[1]}, eo1(${CA}, hchk), hd, h1, pf, hF(t, x, off, len, hchk))) :
    {Codec.aggregate(Codec.concatenate(Some{[S.Variable{${Yk[0]}}]}, Codec.concatenate(_, Codec.concatenate(P2, Codec.parts(S.EmptyItems{}, S.End{})))), None{}) == ${RHSV} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Maybe<&2, +List<S.Part>>, P2, Some{[S.Variable{${Yk[2]}}]}, C2.specw(d, t, n, ${Xk[2]}, ${Fk[2]}, ${Lk[2]}, eo2(${CA}, hchk), hd, h2, pf, hG(t, x, off, len, hchk))) :
    {Codec.aggregate(Codec.concatenate(Some{[S.Variable{${Yk[0]}}]}, Codec.concatenate(Some{[S.Variable{${Yk[1]}}]}, Codec.concatenate(_, Codec.parts(S.EmptyItems{}, S.End{})))), None{}) == ${RHSV} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding(VRC.PV3(${Yk[0]}, ${Yk[1]}, ${Yk[2]})),
      Some{List.append(&2, U32, F.limbs([${O[0]}, ${O[1]}, ${O[2]}]), List.append(&2, U32, ${Yk[0]}, List.append(&2, U32, ${Yk[1]}, ${Yk[2]})))},
      VRC.enc3v(${Yk[0]}, ${Yk[1]}, ${Yk[2]}, ${O[0]}, ${O[1]}, ${O[2]}, UW.domWX(t, ${Xk[0]}, a), UW.domWX(t, ${Xk[1]}, b), UW.domWX(t, ${Xk[2]}, U32.to_nat(${Lk[2]})),
        eO0(t, x, off, len, hchk), e1, e2, fit)) :
    {Codec.one(_, None{}) == ${RHSV} : Maybe<&2, +List<S.Part>>}
  %win3(${CA}, hchk) : {Codec.one(Some{_}, None{}) == ${RHSV} : Maybe<&2, +List<S.Part>>}
  {==}

@@ er_text @@

# ---- the inversion: every value of the window's bytes passes the checks --------------------------

def leU(+a: U32, +b: U32, +x0: Nat, +y: Nat, +ha: {U32.to_nat(a) == x0 : Nat}, +hb: {U32.to_nat(b) == y : Nat}, +h: {Nat.is_le(x0, y) == ${TRUE}})
    -> {U32.is_le(a, b) == ${TRUE}}:
  VMR.u32le(a, b, FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(b)) == ${TRUE}}, x0, U32.to_nat(a), Equal.sym(Nat, U32.to_nat(a), x0, ha),
    FD.logic__subst(Nat, z => {Nat.is_le(x0, z) == ${TRUE}}, y, U32.to_nat(b), Equal.sym(Nat, U32.to_nat(b), y, hb), h)))

# The four window bytes at k are the limbs of the word at x + k.
def wbk(${CW}, +k: Nat, +L2: Nat, +el: {U32.to_nat(len) == Nat.add(k, 4n+L2) : Nat},
    +hk: {Nat.is_le(Nat.add(Nat.add(k, x), 4n), ${P}) == ${TRUE}})
    -> {VS.bt(4n, VS.bdr(k, UW.WX(t, x, U32.to_nat(len)))) == F.limbs([UR.RWN(t, Nat.add(k, x))]) : +List<U32>}:
  %Equal.sym(Nat, U32.to_nat(len), Nat.add(k, 4n+L2), el) : {VS.bt(4n, VS.bdr(k, UW.WX(t, x, _))) == F.limbs([UR.RWN(t, Nat.add(k, x))]) : +List<U32>}
  VRC.wbytes(d, t, x, k, L2, pf, hk)

# The offset word at k: its limbs are the digits the layout puts there.
def offw(${CW}, +k: Nat, +L2: Nat, +v: Nat, +el: {U32.to_nat(len) == Nat.add(k, 4n+L2) : Nat}, +hv: {Nat.is_le(v, U32.to_nat(len)) == ${TRUE}},
    +eb: {VS.bt(4n, VS.bdr(k, UW.WX(t, x, U32.to_nat(len)))) == N.digits(4n, v) : +List<U32>})
    -> {U32.to_nat(UR.RWN(t, Nat.add(k, x))) == v : Nat}:
  +hl = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, z), ${P}) == ${TRUE}}, U32.to_nat(len), Nat.add(k, 4n+L2), el, hw)
  +le0 = Order.add_left(k, Nat.add(x, 4n), Nat.add(x, 4n+L2), Order.add_left(x, 4n, 4n+L2, Order.below_sum(4n, L2)))
  +le1 = FD.logic__subst(Nat, z => {Nat.is_le(z, Nat.add(k, Nat.add(x, 4n+L2))) == ${TRUE}}, Nat.add(k, Nat.add(x, 4n)), Nat.add(Nat.add(k, x), 4n),
    Equal.sym(Nat, Nat.add(Nat.add(k, x), 4n), Nat.add(k, Nat.add(x, 4n)), FD.nat__add_assoc(k, x, 4n)), le0)
  +le2 = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(Nat.add(k, x), 4n), z) == ${TRUE}}, Nat.add(k, Nat.add(x, 4n+L2)), Nat.add(x, Nat.add(k, 4n+L2)),
    Equal.sym(Nat, Nat.add(x, Nat.add(k, 4n+L2)), Nat.add(k, Nat.add(x, 4n+L2)), FD.lru_nat_algebra__add_swap(x, k, 4n+L2)), le1)
  +hk = FD.nat__le_trans(Nat.add(Nat.add(k, x), 4n), Nat.add(x, Nat.add(k, 4n+L2)), ${P}, le2, hl)
  VG.digits_word(UR.RWN(t, Nat.add(k, x)), v, VMR.fitsn(d, len, v, FD.nat__lt_trans(d, 28n, 29n, hd, {==}),
      FD.nat__le_trans(U32.to_nat(len), Nat.add(x, U32.to_nat(len)), ${P}, Order.left_below_sum(x, U32.to_nat(len)), hw), hv),
    Equal.trans(+List<U32>, F.limbs([UR.RWN(t, Nat.add(k, x))]), VS.bt(4n, VS.bdr(k, UW.WX(t, x, U32.to_nat(len)))), N.digits(4n, v),
      Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(k, UW.WX(t, x, U32.to_nat(len)))), F.limbs([UR.RWN(t, Nat.add(k, x))]), wbk(${CA}, k, L2, el, hk)),
      eb))

@@ er_text_contra @@

def contra(${CW}${ACC3},
    +eo2: {VRC.OUTV(${YY}) == UW.WX(t, x, U32.to_nat(len)) : +List<U32>}) -> ${GOAL}:
  (+k0, +pr0) = f0
  (+hl0, +hk0) = pr0
  (+k1, +pr1) = f1
  (+hl1, +hk1) = pr1
  (+k2, +pr2) = f2
  (+hl2, +hk2) = pr2
  +WW = UW.WX(t, x, U32.to_nat(len))
  +eL = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, WW), ${SUM},
    Equal.sym(Nat, List.length(&2, U32, WW), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)),
    Equal.trans(Nat, List.length(&2, U32, WW), List.length(&2, U32, VRC.OUTV(${YY})), ${SUM},
      Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), WW, VRC.OUTV(${YY}), Equal.sym(+List<U32>, VRC.OUTV(${YY}), WW, eo2)), VRC.lenOUT(${YY})))
  +hvS = FD.logic__subst(Nat, z => {Nat.is_le(${V1}, z) == ${TRUE}}, ${SUM}, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), ${SUM}, eL),
    Order.add_left(12n, ${s[0]}, ${R}, FD.nat__le_add_right(${s[0]}, Nat.add(${s[1]}, ${s[2]}))))
  +h2S = FD.logic__subst(Nat, z => {Nat.is_le(z, ${SUM}) == ${TRUE}}, Nat.add(12n, Nat.add(${s[0]}, ${s[1]})), ${V2}, Equal.sym(Nat, ${V2}, Nat.add(12n, Nat.add(${s[0]}, ${s[1]})), FD.nat__add_assoc(12n, ${s[0]}, ${s[1]})),
    Order.add_left(12n, Nat.add(${s[0]}, ${s[1]}), ${R}, Order.add_left(${s[0]}, ${s[1]}, Nat.add(${s[1]}, ${s[2]}), FD.nat__le_add_right(${s[1]}, ${s[2]}))))
  +h2v = FD.logic__subst(Nat, z => {Nat.is_le(${V2}, z) == ${TRUE}}, ${SUM}, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), ${SUM}, eL), h2S)
  +h12 = FD.logic__subst(Nat, z => {Nat.is_le(12n, z) == ${TRUE}}, ${SUM}, U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), ${SUM}, eL), Order.below_sum(12n, ${R}))
  +eb0 = Equal.cong(+List<U32>, +List<U32>, z => VS.bt(4n, VS.bdr(0n, z)), WW, VRC.OUTV(${YY}), Equal.sym(+List<U32>, VRC.OUTV(${YY}), WW, eo2))
  +eb1 = Equal.cong(+List<U32>, +List<U32>, z => VS.bt(4n, VS.bdr(4n, z)), WW, VRC.OUTV(${YY}), Equal.sym(+List<U32>, VRC.OUTV(${YY}), WW, eo2))
  +eb2 = Equal.cong(+List<U32>, +List<U32>, z => VS.bt(4n, VS.bdr(8n, z)), WW, VRC.OUTV(${YY}), Equal.sym(+List<U32>, VRC.OUTV(${YY}), WW, eo2))
  +eO0 = offw(${CA}, 0n, Nat.add(8n, ${R}), 12n, eL, h12, eb0)
  +eO1 = offw(${CA}, 4n, Nat.add(4n, ${R}), ${V1}, eL, hvS, eb1)
  +eO2 = offw(${CA}, 8n, ${R}, ${V2}, eL, h2v, eb2)
  +eLn2 = Equal.trans(Nat, U32.to_nat(len), ${SUM}, Nat.add(${V2}, ${s[2]}), eL,
    Equal.trans(Nat, ${SUM}, Nat.add(Nat.add(12n, ${s[0]}), Nat.add(${s[1]}, ${s[2]})), Nat.add(${V2}, ${s[2]}),
      Equal.sym(Nat, Nat.add(Nat.add(12n, ${s[0]}), Nat.add(${s[1]}, ${s[2]})), ${SUM}, FD.nat__add_assoc(12n, ${s[0]}, Nat.add(${s[1]}, ${s[2]}))),
      Equal.sym(Nat, Nat.add(${V2}, ${s[2]}), Nat.add(Nat.add(12n, ${s[0]}), Nat.add(${s[1]}, ${s[2]})), FD.nat__add_assoc(Nat.add(12n, ${s[0]}), ${s[1]}, ${s[2]}))))
  +hAc = VMR.u32le(12, len, h12)
  +hBc = FD.u32alg__eq_true(${O[0]}, 12, FD.u32__injective(${O[0]}, 12, eO0))
  +hCc = FD.logic__and_intro(U32.is_le(${O[0]}, ${O[1]}), U32.is_le(${O[1]}, len),
    leU(${O[0]}, ${O[1]}, 12n, ${V1}, eO0, eO1, Order.below_sum(12n, ${s[0]})),
    leU(${O[1]}, len, ${V1}, ${SUM}, eO1, eL, Order.add_left(12n, ${s[0]}, ${R}, FD.nat__le_add_right(${s[0]}, Nat.add(${s[1]}, ${s[2]})))))
  +hDc = FD.logic__and_intro(U32.is_le(${O[1]}, ${O[2]}), U32.is_le(${O[2]}, len),
    leU(${O[1]}, ${O[2]}, ${V1}, ${V2}, eO1, eO2, Order.below_sum(${V1}, ${s[1]})), leU(${O[2]}, len, ${V2}, ${SUM}, eO2, eL, h2S))
  +hEc = VU.whole_i(${Lk[0]}, ${RS[0]}, ${LIM[0]}, C0.vR(), {==}, {==}, {==}, k0,
    Equal.trans(Nat, U32.to_nat(${Lk[0]}), ${s[0]}, Nat.mul(k0, ${RS[0]}n), VMR.subL(${O[1]}, ${O[0]}, 12n, ${s[0]}, eO0, eO1), hl0), hk0)
  +hFc = VU.whole_i(${Lk[1]}, ${RS[1]}, ${LIM[1]}, C1.vR(), {==}, {==}, {==}, k1,
    Equal.trans(Nat, U32.to_nat(${Lk[1]}), ${s[1]}, Nat.mul(k1, ${RS[1]}n), VMR.subL(${O[2]}, ${O[1]}, ${V1}, ${s[1]}, eO1, eO2), hl1), hk1)
  +hGc = VU.whole_i(${Lk[2]}, ${RS[2]}, ${LIM[2]}, C2.vR(), {==}, {==}, {==}, k2,
    Equal.trans(Nat, U32.to_nat(${Lk[2]}), ${s[2]}, Nat.mul(k2, ${RS[2]}n), VMR.subL(len, ${O[2]}, ${V2}, ${s[2]}, eO2, eLn2), hl2), hk2)
  FD.logic__and_intro(CA(len), K1(t, x, off, len), hAc, FD.logic__and_intro(CB(t, x), K2(t, x, off, len), hBc,
    FD.logic__and_intro(CC(t, x, len), K3(t, x, off, len), hCc, FD.logic__and_intro(CD(t, x, len), K4(t, x, off, len), hDc,
      FD.logic__and_intro(CE(t, x, off, len), K5(t, x, off, len), hEc, FD.logic__and_intro(CF(t, x, off, len), CG(t, x, off, len), hFc, hGc))))))

def fin(${CW}${ACC3}, +b: Bool,
    +e: {Codec.one(SP.optional(b, VRC.OUTV(${YY})), None{}) == ${RHSV} : Maybe<&2, +List<S.Part>>}) -> ${GOAL}:
  match b:
    case False{}: ${ABS('e')}
    case True{}: contra(${CA}${ACCA(3)}, VRC.var_inj(VRC.OUTV(${YY}), UW.WX(t, x, U32.to_nat(len)), e))

@@ er_text_invw @@

def invw(${CW}, +v: S.Value,
    +e: {Codec.parts(v, Spec.${X}()) == ${RHSV} : Maybe<&2, +List<S.Part>>}) -> ${GOAL}:
  match v:
${vc}

@@ top_text @@
def BF(t: ${TR}, +n: U32) -> B.Buf: UA.BF(t, n)
def CHK(+t: ${TR}, +n: U32) -> Bool: EW.CHKw(t, 0n, 0, n)
def OBJ(+d: Nat, +t: ${TR}, +n: U32) -> T.${X}: EW.OBJw(d, t, 0n, 0, n)
def VW(+t: ${TR}, +n: U32) -> +List<U32>: VS.bt(U32.to_nat(n), F.limbs(FD.array__slots(U32, t)))
def VAL(+t: ${TR}, +n: U32) -> S.Value: EW.VALw(t, 0n, n)

# The validator returns the buffer and CHK(t, n).
law ok_eval:
${LH}  {T.${X}_ok(BF(t, n), 0, n) == (BF(t, n), CHK(t, n)) : B.Buf & Bool}
def ok_eval(d, t, n, pf, hd, hn): EW.ok_evalw(${WA})

# Every buffer the validator accepts decodes to OBJ(d, t, n).
law decode_accept:
${LH}  for +hchk: {CHK(t, n) == True{} : Bool}
  {T.${X}_decode(BF(t, n), n) == (BF(t, n), Some{OBJ(d, t, n)}) : ${RT}}
def decode_accept(d, t, n, pf, hd, hn, hchk):
  %Equal.sym(B.Buf & Bool, T.${X}_ok(BF(t, n), 0, n), (BF(t, n), CHK(t, n)), ok_eval(d, t, n, pf, hd, hn)) :
    {T.${X}_built(n, _) == (BF(t, n), Some{OBJ(d, t, n)}) : ${RT}}
  %Equal.sym(Bool, CHK(t, n), True{}, hchk) :
    {T.${X}_built(n, (BF(t, n), _)) == (BF(t, n), Some{OBJ(d, t, n)}) : ${RT}}
  %Equal.sym(B.Buf & T.${X}, T.${X}_read(BF(t, n), 0, n), (BF(t, n), OBJ(d, t, n)), EW.readw(${WA}, hchk)) :
    {T.${X}_some(_) == (BF(t, n), Some{OBJ(d, t, n)}) : ${RT}}
  {==}

# The bytes of every buffer the validator accepts are the spec encoding of VAL(t, n).
law decode_spec:
${LH}  for +hchk: {CHK(t, n) == True{} : Bool}
  Decoding.decodes(Spec.${X}(), VW(t, n), VAL(t, n))
def decode_spec(d, t, n, pf, hd, hn, hchk):
  # the encoding opened over variables first (F.efl_bytes): the parts rewrite's motive over
  # Codec.bytes was compared with the spec encoding by running the encoder
  %F.efl_bytes(Spec.${X}(), VAL(t, n)) : {_ == Some{VW(t, n)} : Maybe<&2, +List<U32>>}
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(VAL(t, n), Spec.${X}()), Some{[S.Variable{UW.WX(t, 0n, U32.to_nat(n))}]}, EW.specw(${WA}, hchk)) :
    {Codec.bytes(_) == Some{VW(t, n)} : Maybe<&2, +List<U32>>}
  {==}

# Every spec value of an accepted buffer's bytes is VAL(t, n).
law decode_unique:
${LH}  for +hchk: {CHK(t, n) == True{} : Bool}
  for +v: S.Value
  for spec: Decoding.decodes(Spec.${X}(), VW(t, n), v)
  {v == VAL(t, n) : S.Value}
def decode_unique(d, t, n, pf, hd, hn, hchk, v, spec):
  DCO.valid_unique(Spec.${X}(), VW(t, n), v, VAL(t, n), {==}, spec, decode_spec(d, t, n, pf, hd, hn, hchk))

# A value encoding to the buffer's bytes has them as its one variable part.
def rj_p(+v: S.Value, +ys: +List<U32>, +ps: +List<S.Part>, hf: DF.single(None{}, ps),
    +em: {Codec.parts(v, Spec.${X}()) == Some{ps} : Maybe<&2, +List<S.Part>>}, +e: {Codec.bytes(Some{ps}) == Some{ys} : Maybe<&2, +List<U32>>})
    -> {Codec.parts(v, Spec.${X}()) == Some{[S.Variable{ys}]} : Maybe<&2, +List<S.Part>>}:
  match ps:
    case Nil{}: Empty.absurd({Codec.parts(v, Spec.${X}()) == Some{[S.Variable{ys}]} : Maybe<&2, +List<S.Part>>}, hf)
    case Con{S.Fixed{+xs}, Nil{}}: Empty.absurd({Codec.parts(v, Spec.${X}()) == Some{[S.Variable{ys}]} : Maybe<&2, +List<S.Part>>}, FD.logic__none_some(Nat, List.length(&2, U32, xs), hf))
    case Con{S.Variable{+xs}, Nil{}}:
      %FD.logic__some_inj(+List<U32>, xs, ys, e) : {Codec.parts(v, Spec.${X}()) == Some{[S.Variable{_}]} : Maybe<&2, +List<S.Part>>}
      em
    case Con{S.Fixed{+xs}, Con{+a, +b}}: Empty.absurd({Codec.parts(v, Spec.${X}()) == Some{[S.Variable{ys}]} : Maybe<&2, +List<S.Part>>}, hf)
    case Con{S.Variable{+xs}, Con{+a, +b}}: Empty.absurd({Codec.parts(v, Spec.${X}()) == Some{[S.Variable{ys}]} : Maybe<&2, +List<S.Part>>}, hf)

def rj_m(+v: S.Value, +ys: +List<U32>, +mm: Maybe<&2, +List<S.Part>>, hf: DF.single_result(None{}, mm),
    +em: {Codec.parts(v, Spec.${X}()) == mm : Maybe<&2, +List<S.Part>>}, +e: {Codec.bytes(mm) == Some{ys} : Maybe<&2, +List<U32>>})
    -> {Codec.parts(v, Spec.${X}()) == Some{[S.Variable{ys}]} : Maybe<&2, +List<S.Part>>}:
  match mm:
    case None{}: Empty.absurd({Codec.parts(v, Spec.${X}()) == Some{[S.Variable{ys}]} : Maybe<&2, +List<S.Part>>}, FD.logic__none_some(+List<U32>, ys, e))
    case Some{+ps}: rj_p(v, ys, ps, hf, em, e)

def rej_f(${H}, +hchk: {CHK(t, n) == False{} : Bool}, +v: S.Value,
    +e: {Codec.encoding_for_legal_type(Spec.${X}(), v) == Some{VW(t, n)} : Maybe<&2, +List<U32>>}) -> Empty:
  FD.logic__true_false(Equal.trans(Bool, True{}, CHK(t, n), False{},
    Equal.sym(Bool, CHK(t, n), True{}, EW.invw(${WA}, v, rj_m(v, VW(t, n), Codec.parts(v, Spec.${X}()), DS.facts(v, Spec.${X}(), {==}), {==}, e))), hchk))

# When the validator refuses, no value is related to the buffer's bytes.
law decode_reject:
${LH}  for +hchk: {CHK(t, n) == False{} : Bool}
  Decoding.outside_image(Spec.${X}(), VW(t, n))
def decode_reject(d, t, n, pf, hd, hn, hchk):
  v => e => rej_f(d, t, n, pf, hd, hn, hchk, v, e)

def none_go(${H}, +hchk: {CHK(t, n) == False{} : Bool})
    -> {T.${X}_decode(BF(t, n), n) == (BF(t, n), None{}) : ${RT}}:
  %Equal.sym(B.Buf & Bool, T.${X}_ok(BF(t, n), 0, n), (BF(t, n), CHK(t, n)), ok_eval(d, t, n, pf, hd, hn)) :
    {T.${X}_built(n, _) == (BF(t, n), None{}) : ${RT}}
  %Equal.sym(Bool, CHK(t, n), False{}, hchk) :
    {T.${X}_built(n, (BF(t, n), _)) == (BF(t, n), None{}) : ${RT}}
  {==}

# When the validator refuses, the decoder returns None and the buffer.
law decode_none:
${LH}  for +hchk: {CHK(t, n) == False{} : Bool}
  {T.${X}_decode(BF(t, n), n) == (BF(t, n), None{}) : ${RT}}
def decode_none(d, t, n, pf, hd, hn, hchk): none_go(d, t, n, pf, hd, hn, hchk)
