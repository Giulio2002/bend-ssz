@@ CTN @@

# ---- a copy at a Nat byte position ---------------------------------------------------------------

# vua_ct's copy storage CT(d, t, off, L, dz), by the byte position y = off.
def ctsn(r: Nat, +d: Nat, +t: FD.array__Tree<U32>, +q: Nat, +L: U32, +dz: Nat) -> FD.array__Tree<U32>:
  match r:
    case 0n: VBY.MK(L, dz, VB.mone(VC.NW(L), q, 0n, dz, VC.ZT(dz), t))
    case 1n+s: VBY.MK(L, dz, UC.smone(1n+s, VC.NW(L), q, 0n, dz, d, VC.ZT(dz), t))

def CTN(+d: Nat, +t: FD.array__Tree<U32>, +y: Nat, +L: U32, +dz: Nat) -> FD.array__Tree<U32>: ctsn(UR.m4(y), d, t, UR.d4(y), L, dz)

def cts_n(+r: Nat, +d: Nat, +t: FD.array__Tree<U32>, +off: U32, +L: U32, +dz: Nat) -> {UCT.cts(r, d, t, off, L, dz) == ctsn(r, d, t, VR.QX(off), L, dz) : FD.array__Tree<U32>}:
  match r:
    case 0n: {==}
    case 1n+ +s: {==}

def ct_n(+d: Nat, +t: FD.array__Tree<U32>, +off: U32, +y: Nat, +L: U32, +dz: Nat, +e: {U32.to_nat(off) == y : Nat})
    -> {UCT.CT(d, t, off, L, dz) == CTN(d, t, y, L, dz) : FD.array__Tree<U32>}:
  %e : {UCT.CT(d, t, off, L, dz) == ctsn(UR.m4(_), d, t, UR.d4(_), L, dz) : FD.array__Tree<U32>}
  %Equal.sym(Nat, U32.to_nat(off), Nat.add(A.quad(VR.QX(off)), VR.RX(off)), VC.split4(off)) :
    {UCT.CT(d, t, off, L, dz) == ctsn(UR.m4(_), d, t, UR.d4(_), L, dz) : FD.array__Tree<U32>}
  %Equal.sym(Nat, UR.m4(Nat.add(A.quad(VR.QX(off)), VR.RX(off))), VR.RX(off), UR.m4_eq(VR.QX(off), VR.RX(off), UA.rx_lt(off))) :
    {UCT.CT(d, t, off, L, dz) == ctsn(_, d, t, UR.d4(Nat.add(A.quad(VR.QX(off)), VR.RX(off))), L, dz) : FD.array__Tree<U32>}
  %Equal.sym(Nat, UR.d4(Nat.add(A.quad(VR.QX(off)), VR.RX(off))), VR.QX(off), UR.d4_eq(VR.QX(off), VR.RX(off), UA.rx_lt(off))) :
    {UCT.CT(d, t, off, L, dz) == ctsn(VR.RX(off), d, t, _, L, dz) : FD.array__Tree<U32>}
  cts_n(VR.RX(off), d, t, off, L, dz)

@@ reader_box @@
# the records j, j + 1, ..., j + k set into the runtime storage A from index i on
def RT(k: Nat, +i: U32, +j: Nat, A: ${AE}, +t: ${TR}, +x: Nat) -> ${AE}:
  match k:
    case 0n: Array.set(${ET}, A, i, RX(t, ${POS('j')}))
    case 1n+q: RT(q, U32.add(i, 1), 1n+j, Array.set(${ET}, A, i, RX(t, ${POS('j')})), t, x)


@@ reader_box_2 @@
def LOBJ(e: Bool, +t: ${TR}, +x: Nat, +len: U32) -> T.${p}_Seq:
  match e:
    case True{}: T.${p}_Seq{T.${p}_fill(0n), 0}
    case False{}: T.${p}_Seq{RT(U32.to_nat(U32.sub(NN(len), 1)), 0, 0n, T.${p}_fill(T.${p}_cap(NN(len))), t, x), NN(len)}
def OBJw(+d: Nat, +t: ${TR}, +x: Nat, +off: U32, +len: U32) -> T.${p}_Seq: LOBJ(U32.is_eq(len, 0), t, x, len)

# The read loop from record j (index i) on.
def lp(k: Nat, +d: Nat, +t: ${TR}, +n: U32, +x: Nat, +off: U32, +i: U32, +j: Nat, A: ${AE},
    +eo: {U32.to_nat(off) == x : Nat}, +ej: {U32.to_nat(i) == j : Nat}, +hd: {Nat.is_lt(d, 28n) == ${TRUE}},
    +pf: {FD.array__perfect(U32, d, t) == ${TRUE}}, +hb: {Nat.is_le(${POS('Nat.add(1n+k, j)')}, A.quad(VB.pw(d))) == ${TRUE}})
    -> {T.${p}_rd(k, i, off, A, (BF(t, n), RX(t, ${POS('j')}))) == (BF(t, n), RT(k, i, j, A, t, x)) : ${RD}}:
  match k:
    case 0n: {==}
    case 1n+ +q:
      +hb2 = FD.logic__subst(Nat, z => {Nat.is_le(VRL.pos(1n+z, ${RS}n, x), A.quad(VB.pw(d))) == ${TRUE}}, 1n+Nat.add(q, j), Nat.add(q, 1n+j), Equal.sym(Nat, Nat.add(q, 1n+j), 1n+Nat.add(q, j), FD.nat__add_succ(q, j)), hb)
      +hx = VRL.nextfit(j, q, ${RS}n, x, A.quad(VB.pw(d)), hb)
      +ex = VRL.posU(d, off, x, i, j, ${RS}, ${RS - 1}n, {==}, eo, ej, hd, hx)
      %Equal.sym(B.Buf & ${ET}, T.${R}_bx_read(BF(t, n), U32.add(off, U32.mul(U32.add(i, 1), ${RS})), ${RS}), (BF(t, n), RX(t, ${POS('1n+j')})),
          VXB.rdbx_${R}(d, t, n, U32.add(off, U32.mul(U32.add(i, 1), ${RS})), ${POS('1n+j')}, ex, ${hdr}, pf, hx)) :
        {T.${p}_rd(q, U32.add(i, 1), off, Array.set(${ET}, A, i, RX(t, ${POS('j')})), _) == (BF(t, n), RT(1n+q, i, j, A, t, x)) : ${RD}}
      lp(q, d, t, n, x, off, U32.add(i, 1), 1n+j, Array.set(${ET}, A, i, RX(t, ${POS('j')})), eo, VRL.succU(d, i, j, ${RS - 1}n, x, ej, hd, hx), hd, pf, hb2)


@@ rd_go_box @@
      %Equal.sym(B.Buf & O.Boxed<T.${R}>, T.${R}_bx_read(BF(t, n), off, ${RS}), (BF(t, n), RX(t, x)), VXB.rdbx_${R}(d, t, n, off, x, eo, ${hdr}, pf, hb0)) :
        {T.${p}_rd_fin(NN(len), T.${p}_rd(k, 0, off, ${FILL}, _)) == (BF(t, n), LOBJ(False{}, t, x, len)) : B.Buf & T.${p}_Seq}
      %Equal.sym(B.Buf & Array<O.Boxed<T.${R}>>, T.${p}_rd(k, 0, off, ${FILL}, (BF(t, n), RX(t, x))), (BF(t, n), RT(k, 0, 0n, ${FILL}, t, x)),
          lp(k, d, t, n, x, off, 0, 0n, ${FILL}, eo, {==}, hd, pf, hb)) :
        {T.${p}_rd_fin(NN(len), _) == (BF(t, n), LOBJ(False{}, t, x, len)) : B.Buf & T.${p}_Seq}
      {==}

