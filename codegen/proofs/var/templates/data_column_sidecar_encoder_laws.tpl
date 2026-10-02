@@ HP @@
+c2: Nat, +dw0: Nat, +dw1: Nat, +dw2: Nat, +dp: Nat,
    +pf0: {FD.array__perfect(U32, dw0, T0) == ${TRUE}}, +pf1: {FD.array__perfect(U32, dw1, T1) == ${TRUE}}, +pf2: {FD.array__perfect(U32, dw2, T2) == ${TRUE}}, +pfP: {FD.array__perfect(U32, dp, TP) == ${TRUE}},
    +hdw0: {Nat.is_lt(dw0, 31n) == ${TRUE}}, +hdw1: {Nat.is_lt(dw1, 31n) == ${TRUE}}, +hdw2: {Nat.is_lt(dw2, 31n) == ${TRUE}}, +hdp: {Nat.is_lt(dp, 31n) == ${TRUE}},
    +ec0: {U32.to_nat(N0) == A.quad(M0(c0)) : Nat}, +ec1: {U32.to_nat(N1) == A.quad(M1(c1)) : Nat}, +ec2: {U32.to_nat(N2) == A.quad(M2(c2)) : Nat},
    +hc0: {Nat.is_le(c0, U32.to_nat(4096)) == ${TRUE}}, +hc1: {Nat.is_le(c1, U32.to_nat(4096)) == ${TRUE}}, +hc2: {Nat.is_le(c2, U32.to_nat(4096)) == ${TRUE}},
    +hr0: {Nat.is_le(Nat.add(VC.NW(N0), 0n), VB.pw(dw0)) == ${TRUE}}, +hr1: {Nat.is_le(Nat.add(VC.NW(N1), 0n), VB.pw(dw1)) == ${TRUE}}, +hr2: {Nat.is_le(Nat.add(VC.NW(N2), 0n), VB.pw(dw2)) == ${TRUE}},
    +hrP: {Nat.is_le(32n, VB.pw(dp)) == ${TRUE}}
@@ text @@

# ---- sizes ------------------------------------------------------------------------------------

def M0(+c0: Nat) -> Nat: VM.mulE(512n, c0)
def M1(+c1: Nat) -> Nat: VM.mulE(12n, c1)
def M2(+c2: Nat) -> Nat: VM.mulE(12n, c2)
def Q1(+c0: Nat) -> Nat: Nat.add(89n, M0(c0))
def Q2(+c0: Nat, +c1: Nat) -> Nat: Nat.add(Q1(c0), M1(c1))
def QN(+c0: Nat, +c1: Nat, +c2: Nat) -> Nat: Nat.add(Q2(c0, c1), M2(c2))
def S1(+N0: U32) -> U32: U32.add(356, N0)
def S2(+N0: U32, +N1: U32) -> U32: U32.add(S1(N0), N1)
def S3(+N0: U32, +N1: U32, +N2: U32) -> U32: U32.add(S2(N0, N1), N2)
def DO(+N0: U32, +N1: U32, +N2: U32) -> Nat: B.words_depth(VC.nwu(S3(N0, N1, N2)))

@U32BOUNDS
def lQX(${NP}) -> {Nat.is_le(QN(c0, c1, c2), QX()) == ${TRUE}}:
  +l1 = Order.add_left(89n, M0(c0), MX0(), lM512(c0, hc0))
  +l2 = FD.nat__le_trans(Q2(c0, c1), Nat.add(Nat.add(89n, MX0()), M1(c1)), Nat.add(Nat.add(89n, MX0()), MX1()),
    Order.add_right(Q1(c0), Nat.add(89n, MX0()), M1(c1), l1), Order.add_left(Nat.add(89n, MX0()), M1(c1), MX1(), lM12(c1, hc1)))
  FD.logic__subst(Nat, z => {Nat.is_le(QN(c0, c1, c2), z) == ${TRUE}}, Nat.add(Nat.add(Nat.add(89n, MX0()), MX1()), MX1()), QX(), eQX(),
    FD.nat__le_trans(QN(c0, c1, c2), Nat.add(Nat.add(Nat.add(89n, MX0()), MX1()), M2(c2)), Nat.add(Nat.add(Nat.add(89n, MX0()), MX1()), MX1()),
      Order.add_right(Q2(c0, c1), Nat.add(Nat.add(89n, MX0()), MX1()), M2(c2), l2), Order.add_left(Nat.add(Nat.add(89n, MX0()), MX1()), M2(c2), MX1(), lM12(c2, hc2))))

def lQ1N(+c0: Nat, +c1: Nat, +c2: Nat) -> {Nat.is_le(Q1(c0), QN(c0, c1, c2)) == ${TRUE}}:
  FD.nat__le_trans(Q1(c0), Q2(c0, c1), QN(c0, c1, c2), Order.below_sum(Q1(c0), M1(c1)), Order.below_sum(Q2(c0, c1), M2(c2)))
def lM0N(+c0: Nat, +c1: Nat, +c2: Nat) -> {Nat.is_le(M0(c0), QN(c0, c1, c2)) == ${TRUE}}:
  FD.nat__le_trans(M0(c0), Q1(c0), QN(c0, c1, c2), Order.left_below_sum(89n, M0(c0)), lQ1N(c0, c1, c2))
def lM1N(+c0: Nat, +c1: Nat, +c2: Nat) -> {Nat.is_le(M1(c1), QN(c0, c1, c2)) == ${TRUE}}:
  FD.nat__le_trans(M1(c1), Q2(c0, c1), QN(c0, c1, c2), Order.left_below_sum(Q1(c0), M1(c1)), Order.below_sum(Q2(c0, c1), M2(c2)))
def lM2N(+c0: Nat, +c1: Nat, +c2: Nat) -> {Nat.is_le(M2(c2), QN(c0, c1, c2)) == ${TRUE}}: Order.left_below_sum(Q2(c0, c1), M2(c2))

# x <= QN: 4 x < 2^24, and 31 + 4 x <= 2^24
def qy(${NP}, +x: Nat, +h: {Nat.is_le(x, QN(c0, c1, c2)) == ${TRUE}})
    -> {Nat.is_le(Nat.add(31n, A.quad(x)), VB.pw(24n)) == ${TRUE}}:
  FD.nat__le_trans(Nat.add(31n, A.quad(x)), Nat.add(31n, A.quad(QX())), VB.pw(24n),
    Order.add_left(31n, A.quad(x), A.quad(QX()), VME.quad_mono(x, QX(), FD.nat__le_trans(x, QN(c0, c1, c2), QX(), h, lQX(${NA})))), cQ())
def qlt(${NP}, +x: Nat, +h: {Nat.is_le(x, QN(c0, c1, c2)) == ${TRUE}})
    -> {Nat.is_lt(A.quad(x), VB.pw(24n)) == ${TRUE}}:
  FD.nat__lt_le_trans(A.quad(x), Nat.add(31n, A.quad(x)), VB.pw(24n), FD.nat__lt_le_trans(A.quad(x), 1n+A.quad(x), Nat.add(31n, A.quad(x)), FD.nat__lt_succ(A.quad(x)), Order.add_right(1n, 31n, A.quad(x), {==})), qy(${NA}, x, h))
def qle(${NP}, +x: Nat, +h: {Nat.is_le(x, QN(c0, c1, c2)) == ${TRUE}})
    -> {Nat.is_le(A.quad(x), U32.to_nat(16777216)) == ${TRUE}}:
  FD.nat__le_trans(A.quad(x), A.quad(QX()), U32.to_nat(16777216), VME.quad_mono(x, QX(), FD.nat__le_trans(x, QN(c0, c1, c2), QX(), h, lQX(${NA}))), cS())

def eS1(${NP}) -> {U32.to_nat(S1(N0)) == A.quad(Q1(c0)) : Nat}:
  +h = FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(U32.to_nat(356), z), U32.to_nat(16777216)) == ${TRUE}}, A.quad(M0(c0)), U32.to_nat(N0), Equal.sym(Nat, U32.to_nat(N0), A.quad(M0(c0)), ec0),
    qle(${NA}, Q1(c0), lQ1N(c0, c1, c2)))
  Equal.trans(Nat, U32.to_nat(S1(N0)), Nat.add(U32.to_nat(356), U32.to_nat(N0)), A.quad(Q1(c0)), A.add_le(356, N0, 16777216, h),
    Equal.cong(Nat, Nat, z => Nat.add(U32.to_nat(356), z), U32.to_nat(N0), A.quad(M0(c0)), ec0))

def eS2(${NP}) -> {U32.to_nat(S2(N0, N1)) == A.quad(Q2(c0, c1)) : Nat}:
  +e1 = eS1(${NA})
  +q = Equal.trans(Nat, Nat.add(U32.to_nat(S1(N0)), U32.to_nat(N1)), Nat.add(A.quad(Q1(c0)), A.quad(M1(c1))), A.quad(Q2(c0, c1)),
    Equal.trans(Nat, Nat.add(U32.to_nat(S1(N0)), U32.to_nat(N1)), Nat.add(A.quad(Q1(c0)), U32.to_nat(N1)), Nat.add(A.quad(Q1(c0)), A.quad(M1(c1))),
      Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(N1)), U32.to_nat(S1(N0)), A.quad(Q1(c0)), e1),
      Equal.cong(Nat, Nat, z => Nat.add(A.quad(Q1(c0)), z), U32.to_nat(N1), A.quad(M1(c1)), ec1)),
    Equal.sym(Nat, A.quad(Q2(c0, c1)), Nat.add(A.quad(Q1(c0)), A.quad(M1(c1))), VM.quad_add(Q1(c0), M1(c1))))
  +h = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(16777216)) == ${TRUE}}, A.quad(Q2(c0, c1)), Nat.add(U32.to_nat(S1(N0)), U32.to_nat(N1)),
    Equal.sym(Nat, Nat.add(U32.to_nat(S1(N0)), U32.to_nat(N1)), A.quad(Q2(c0, c1)), q), qle(${NA}, Q2(c0, c1), Order.below_sum(Q2(c0, c1), M2(c2))))
  Equal.trans(Nat, U32.to_nat(S2(N0, N1)), Nat.add(U32.to_nat(S1(N0)), U32.to_nat(N1)), A.quad(Q2(c0, c1)), A.add_le(S1(N0), N1, 16777216, h), q)

def eS3(${NP}) -> {U32.to_nat(S3(N0, N1, N2)) == A.quad(QN(c0, c1, c2)) : Nat}:
  +e2 = eS2(${NA})
  +q = Equal.trans(Nat, Nat.add(U32.to_nat(S2(N0, N1)), U32.to_nat(N2)), Nat.add(A.quad(Q2(c0, c1)), A.quad(M2(c2))), A.quad(QN(c0, c1, c2)),
    Equal.trans(Nat, Nat.add(U32.to_nat(S2(N0, N1)), U32.to_nat(N2)), Nat.add(A.quad(Q2(c0, c1)), U32.to_nat(N2)), Nat.add(A.quad(Q2(c0, c1)), A.quad(M2(c2))),
      Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(N2)), U32.to_nat(S2(N0, N1)), A.quad(Q2(c0, c1)), e2),
      Equal.cong(Nat, Nat, z => Nat.add(A.quad(Q2(c0, c1)), z), U32.to_nat(N2), A.quad(M2(c2)), ec2)),
    Equal.sym(Nat, A.quad(QN(c0, c1, c2)), Nat.add(A.quad(Q2(c0, c1)), A.quad(M2(c2))), VM.quad_add(Q2(c0, c1), M2(c2))))
  +h = FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(16777216)) == ${TRUE}}, A.quad(QN(c0, c1, c2)), Nat.add(U32.to_nat(S2(N0, N1)), U32.to_nat(N2)),
    Equal.sym(Nat, Nat.add(U32.to_nat(S2(N0, N1)), U32.to_nat(N2)), A.quad(QN(c0, c1, c2)), q), qle(${NA}, QN(c0, c1, c2), Order.reflexive(QN(c0, c1, c2))))
  Equal.trans(Nat, U32.to_nat(S3(N0, N1, N2)), Nat.add(U32.to_nat(S2(N0, N1)), U32.to_nat(N2)), A.quad(QN(c0, c1, c2)), A.add_le(S2(N0, N1), N2, 16777216, h), q)

# the word counts
def eNWg(${NP}, +L: U32, +m: Nat, +em: {U32.to_nat(L) == A.quad(m) : Nat}, +hm: {Nat.is_le(m, QN(c0, c1, c2)) == ${TRUE}})
    -> {VC.NW(L) == m : Nat}:
  %Equal.sym(Nat, VC.NW(L), VD.s_rng(2n, 3n+U32.to_nat(L)), VC.eNW(L, 24n, {==},
      FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(31n, z), VB.pw(24n)) == ${TRUE}}, A.quad(m), U32.to_nat(L), Equal.sym(Nat, U32.to_nat(L), A.quad(m), em), qy(${NA}, m, hm)))) :
    {_ == m : Nat}
  %Equal.sym(Nat, U32.to_nat(L), A.quad(m), em) : {VD.s_rng(2n, 3n+_) == m : Nat}
  VL.rng2_q(m)
def eNW0(${NP}) -> {VC.NW(N0) == M0(c0) : Nat}: eNWg(${NA}, N0, M0(c0), ec0, lM0N(c0, c1, c2))
def eNW1(${NP}) -> {VC.NW(N1) == M1(c1) : Nat}: eNWg(${NA}, N1, M1(c1), ec1, lM1N(c0, c1, c2))
def eNW2(${NP}) -> {VC.NW(N2) == M2(c2) : Nat}: eNWg(${NA}, N2, M2(c2), ec2, lM2N(c0, c1, c2))
def eNWS(${NP}) -> {VC.NW(S3(N0, N1, N2)) == QN(c0, c1, c2) : Nat}: eNWg(${NA}, S3(N0, N1, N2), QN(c0, c1, c2), eS3(${NA}), Order.reflexive(QN(c0, c1, c2)))

# the output tree's depth
def hDO(${NP}) -> {Nat.is_le(${DOe}, 23n) == ${TRUE}}:
  VD.wd_min(VC.nwu(S3(N0, N1, N2)), 23n,
    FD.logic__subst(Nat, z => {Nat.is_le(z, O.pow2n(23n)) == ${TRUE}}, QN(c0, c1, c2), VC.NW(S3(N0, N1, N2)), Equal.sym(Nat, VC.NW(S3(N0, N1, N2)), QN(c0, c1, c2), eNWS(${NA})),
      FD.nat__le_trans(QN(c0, c1, c2), QX(), O.pow2n(23n), lQX(${NA}), cD())))
def hDO29(${NP}) -> {Nat.is_lt(${DOe}, 29n) == ${TRUE}}: FD.nat__le_lt_trans(${DOe}, 23n, 29n, hDO(${NA}), {==})
def hDO31(${NP}) -> {Nat.is_lt(${DOe}, 31n) == ${TRUE}}: FD.nat__le_lt_trans(${DOe}, 23n, 31n, hDO(${NA}), {==})
def hDO32(${NP}) -> {Nat.is_lt(${DOe}, 32n) == ${TRUE}}: VB.lt32(${DOe}, hDO31(${NA}))
def roomS(${NP}) -> {Nat.is_le(QN(c0, c1, c2), VB.pw(${DOe})) == ${TRUE}}:
  %Equal.sym(Nat, VB.pw(${DOe}), O.pow2n(${DOe}), VD.s_pow2_eq(${DOe})) : {Nat.is_le(QN(c0, c1, c2), _) == ${TRUE}}
  %eNWS(${NA}) : {Nat.is_le(_, O.pow2n(${DOe})) == ${TRUE}}
  VD.wd_cover(VC.nwu(S3(N0, N1, N2)), 23n, {==},
    FD.logic__subst(Nat, z => {Nat.is_le(z, O.pow2n(23n)) == ${TRUE}}, QN(c0, c1, c2), VC.NW(S3(N0, N1, N2)), Equal.sym(Nat, VC.NW(S3(N0, N1, N2)), QN(c0, c1, c2), eNWS(${NA})),
      FD.nat__le_trans(QN(c0, c1, c2), QX(), O.pow2n(23n), lQX(${NA}), cD())))
def lQ1P(${NP}) -> {Nat.is_le(Q1(c0), VB.pw(${DOe})) == ${TRUE}}: FD.nat__le_trans(Q1(c0), QN(c0, c1, c2), VB.pw(${DOe}), lQ1N(c0, c1, c2), roomS(${NA}))
def lQ2P(${NP}) -> {Nat.is_le(Q2(c0, c1), VB.pw(${DOe})) == ${TRUE}}: FD.nat__le_trans(Q2(c0, c1), QN(c0, c1, c2), VB.pw(${DOe}), Order.below_sum(Q2(c0, c1), M2(c2)), roomS(${NA}))
def l89P(${NP}) -> {Nat.is_le(89n, VB.pw(${DOe})) == ${TRUE}}: FD.nat__le_trans(89n, Q1(c0), VB.pw(${DOe}), Order.below_sum(89n, M0(c0)), lQ1P(${NA}))
def lkP(${NP}, +k: Nat, +hk: {Nat.is_le(k, 89n) == ${TRUE}}) -> {Nat.is_le(k, VB.pw(${DOe})) == ${TRUE}}: FD.nat__le_trans(k, 89n, VB.pw(${DOe}), hk, l89P(${NA}))
def ltP(${NP}, +k: Nat, +hk: {Nat.is_lt(k, 89n) == ${TRUE}}) -> {Nat.is_lt(k, VB.pw(${DOe})) == ${TRUE}}: FD.nat__lt_le_trans(k, 89n, VB.pw(${DOe}), hk, l89P(${NA}))

# the lists' windows: below the next list, inside the output
def lW0(${NP}) -> {Nat.is_le(Nat.add(VC.NW(N0), 89n), Q1(c0)) == ${TRUE}}:
  %Equal.sym(Nat, VC.NW(N0), M0(c0), eNW0(${NA})) : {Nat.is_le(Nat.add(_, 89n), Q1(c0)) == ${TRUE}}
  %FD.nat__add_comm(89n, M0(c0)) : {Nat.is_le(_, Q1(c0)) == ${TRUE}}
  Order.reflexive(Q1(c0))
def lW1(${NP}) -> {Nat.is_le(Nat.add(VC.NW(N1), Q1(c0)), Q2(c0, c1)) == ${TRUE}}:
  %Equal.sym(Nat, VC.NW(N1), M1(c1), eNW1(${NA})) : {Nat.is_le(Nat.add(_, Q1(c0)), Q2(c0, c1)) == ${TRUE}}
  %FD.nat__add_comm(Q1(c0), M1(c1)) : {Nat.is_le(_, Q2(c0, c1)) == ${TRUE}}
  Order.reflexive(Q2(c0, c1))
def lW2(${NP}) -> {Nat.is_le(Nat.add(VC.NW(N2), Q2(c0, c1)), QN(c0, c1, c2)) == ${TRUE}}:
  %Equal.sym(Nat, VC.NW(N2), M2(c2), eNW2(${NA})) : {Nat.is_le(Nat.add(_, Q2(c0, c1)), QN(c0, c1, c2)) == ${TRUE}}
  %FD.nat__add_comm(Q2(c0, c1), M2(c2)) : {Nat.is_le(_, QN(c0, c1, c2)) == ${TRUE}}
  Order.reflexive(QN(c0, c1, c2))
def lW0Q2(${NP}) -> {Nat.is_le(Nat.add(VC.NW(N0), 89n), Q2(c0, c1)) == ${TRUE}}: FD.nat__le_trans(Nat.add(VC.NW(N0), 89n), Q1(c0), Q2(c0, c1), lW0(${NA}), Order.below_sum(Q1(c0), M1(c1)))
def hdst0(${NP}) -> {Nat.is_le(Nat.add(VC.NW(N0), 89n), VB.pw(${DOe})) == ${TRUE}}: FD.nat__le_trans(Nat.add(VC.NW(N0), 89n), Q1(c0), VB.pw(${DOe}), lW0(${NA}), lQ1P(${NA}))
def hdst1(${NP}) -> {Nat.is_le(Nat.add(VC.NW(N1), Q1(c0)), VB.pw(${DOe})) == ${TRUE}}: FD.nat__le_trans(Nat.add(VC.NW(N1), Q1(c0)), Q2(c0, c1), VB.pw(${DOe}), lW1(${NA}), lQ2P(${NA}))
def hdst2(${NP}) -> {Nat.is_le(Nat.add(VC.NW(N2), Q2(c0, c1)), VB.pw(${DOe})) == ${TRUE}}: FD.nat__le_trans(Nat.add(VC.NW(N2), Q2(c0, c1)), QN(c0, c1, c2), VB.pw(${DOe}), lW2(${NA}), roomS(${NA}))
def lkQ1(+c0: Nat, +k: Nat, +hk: {Nat.is_le(k, 89n) == ${TRUE}}) -> {Nat.is_le(k, Q1(c0)) == ${TRUE}}: FD.nat__le_trans(k, 89n, Q1(c0), hk, Order.below_sum(89n, M0(c0)))
def lkQ2(+c0: Nat, +c1: Nat, +k: Nat, +hk: {Nat.is_le(k, 89n) == ${TRUE}}) -> {Nat.is_le(k, Q2(c0, c1)) == ${TRUE}}: FD.nat__le_trans(k, Q1(c0), Q2(c0, c1), lkQ1(c0, k, hk), Order.below_sum(Q1(c0), M1(c1)))

# no top bit: the counts are below 2^24
def ltN(${NP}, +L: U32, +m: Nat, +em: {U32.to_nat(L) == A.quad(m) : Nat}, +hm: {Nat.is_le(m, QN(c0, c1, c2)) == ${TRUE}})
    -> {L == U32{Word.shr.pad(31n, VE.winit(31n, VE.bits32(L)))} : U32}:
  VE.small_pad(L, 24n, {==}, FD.logic__subst(Nat, z => {Nat.is_lt(z, VB.pw(24n)) == ${TRUE}}, A.quad(m), U32.to_nat(L), Equal.sym(Nat, U32.to_nat(L), A.quad(m), em), qlt(${NA}, m, hm)))
def pd1(${NP}) -> {O.padd(356, N0) == S1(N0) : U32}:
  VE.padd_ok(356, N0, VE.winit(31n, VE.bits32(356)), VE.winit(31n, VE.bits32(N0)), {==}, ltN(${NA}, N0, M0(c0), ec0, lM0N(c0, c1, c2)))
def pd2(${NP}) -> {O.padd(S1(N0), N1) == S2(N0, N1) : U32}:
  VE.padd_ok(S1(N0), N1, VE.winit(31n, VE.bits32(S1(N0))), VE.winit(31n, VE.bits32(N1)), ltN(${NA}, S1(N0), Q1(c0), eS1(${NA}), lQ1N(c0, c1, c2)), ltN(${NA}, N1, M1(c1), ec1, lM1N(c0, c1, c2)))
def pd3(${NP}) -> {O.padd(S2(N0, N1), N2) == S3(N0, N1, N2) : U32}:
  VE.padd_ok(S2(N0, N1), N2, VE.winit(31n, VE.bits32(S2(N0, N1))), VE.winit(31n, VE.bits32(N2)), ltN(${NA}, S2(N0, N1), Q2(c0, c1), eS2(${NA}), Order.below_sum(Q2(c0, c1), M2(c2))), ltN(${NA}, N2, M2(c2), ec2, lM2N(c0, c1, c2)))

@@ put_text @@

  %${ST} :
    {T.v4_b32_pa${k + 1}(57, _, Array.get(U32, FD.array__thaw(U32, TP), ${k + 1})) == ${RHS} : Array<U32> & Array<U32>}
  %Equal.sym(Array<U32> & U32, Array.get(U32, FD.array__thaw(U32, TP), ${k + 1}), (FD.array__thaw(U32, TP), VB.slot(TP, ${k + 1}n)), VB.get_n(dp, TP, ${k + 1}, ${k + 1}n, {==}, hdp32, FD.nat__lt_le_trans(${k + 1}n, 32n, VB.pw(dp), {==}, hrP), pfP)) :
    {T.v4_b32_pa${k + 1}(57, FD.array__thaw(U32, ${X1}), _) == ${RHS} : Array<U32> & Array<U32>}
  pa${k + 1}(dd, ${X1}, TP, dp, FD.array__upd_perfect(U32, dd, X, ${57 + k}n, VB.slot(TP, ${k}n), pfX), hd32, h89, pfP, hdp32, hrP)

@@ put_text_pvP @@

def pvP(${ALLP})
    -> {T.v4_b32_putk(${TH('D7')}, 228, ${WP}) == (${TH('D8')}, (${WP}, 0)) : Array<U32> & (O.Words & U32)}:
  +RHS = (${TH('D8')}, (${WP}, 0))
  %Equal.sym(O.Words & Bool, O.words_ok(${WP}, 128, 128, False{}, 32), (${WP}, True{}), VME.words_okg(dp, TP, 128, 128, 128, 32, pfP, hdp, {==}, {==}, {==}, {==}, hrP)) :
    {T.v4_b32_pk(${TH('D7')}, 228, _) == RHS : Array<U32> & (O.Words & U32)}
  %Equal.sym(Array<U32> & U32, Array.get(U32, FD.array__thaw(U32, TP), 0), (FD.array__thaw(U32, TP), VB.slot(TP, 0n)), VB.get_n(dp, TP, 0, 0n, {==}, VB.lt32(dp, hdp), FD.nat__lt_le_trans(0n, 32n, VB.pw(dp), {==}, hrP), pfP)) :
    {T.v4_b32_pk_ok(T.v4_b32_pal(128, T.v4_b32_pa0(57, ${TH('D7')}, _))) == RHS : Array<U32> & (O.Words & U32)}
  %Equal.sym(Array<U32> & Array<U32>, T.v4_b32_pa0(57, ${TH('D7')}, (FD.array__thaw(U32, TP), VB.slot(TP, 0n))), (${TH('D8')}, FD.array__thaw(U32, TP)),
      pa0(${DOe}, D7(${DA}), TP, dp, pfD7(${DA}), hDO32(${NH}), l89P(${NH}), pfP, VB.lt32(dp, hdp), hrP)) :
    {T.v4_b32_pk_ok(T.v4_b32_pal(128, _)) == RHS : Array<U32> & (O.Words & U32)}
  {==}

@@ put_text_hhi @@

def hhi${k}(${NP}) -> {U32.is_le(${N}, ${L['hi']}) == ${TRUE}}:
  VE.le_hi(${N}, ${L['hi']}, FD.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(${L['hi']})) == ${TRUE}}, A.quad(${M}), U32.to_nat(${N}), Equal.sym(Nat, U32.to_nat(${N}), A.quad(${M}), ec${k}),
    FD.nat__le_trans(A.quad(${M}), A.quad(${L['Mx']}), U32.to_nat(${L['hi']}), VME.quad_mono(${M}, ${L['Mx']}, lM${L['E']}(${c}, hc${k})), ${L['cH']})))
def hu${k}(${NP}) -> {O.unit_ok(${L['B']}, ${N}) == ${TRUE}}:
  VME.mod0(${N}, ${L['B']}, ${L['v']}, {==}, {==}, {==}, ${c}, Equal.trans(Nat, U32.to_nat(${N}), A.quad(${M}), Nat.mul(${c}, U32.to_nat(${L['B']})), ec${k}, Equal.sym(Nat, Nat.mul(${c}, A.quad(${L['E']}n)), A.quad(${M}), VM.mulq(${c}, ${L['E']}n))))

def pv${k}(${ALLP})
    -> {T.${L['putv']}(${TH(L['pre'])}, 0, ${L['hoff']}, ${cur}, ${L['W']}) == ${RHS} : Array<U32> & (O.Words & U32)}:
  +RHS = ${RHS}
  %Equal.sym(Array<U32>, Array.set(U32, ${TH(L['pre'])}, ${L['word']}, ${cur}), FD.array__thaw(U32, FD.array__upd(U32, ${DOe}, ${L['pre']}(${DA}), ${L['word']}n, ${cur})),
      VB.set_n(${DOe}, ${L['pre']}(${DA}), ${L['word']}, ${L['word']}n, ${cur}, {==}, hDO32(${NH}), ltP(${NH}, ${L['word']}n, {==}), pf${L['pre']}(${DA}))) :
    {T.${pfx}_pvb(${cur}, T.${pfx}_putk(_, U32.add(0, ${cur}), ${L['W']})) == RHS : Array<U32> & (O.Words & U32)}${zero}
  %Equal.sym(O.Words & Bool, O.words_ok(${L['W']}, 0, ${L['hi']}, False{}, ${L['B']}), (${L['W']}, True{}),
      VME.words_okg(${L['hdw'].replace('hdw', 'dw')}, ${L['T']}, ${N}, 0, ${L['hi']}, ${L['B']}, ${L['pf']}, ${L['hdw']}, VE.le0(${N}), hhi${k}(${NH}), hu${k}(${NH}), VL.and3_q(${N}, ${M}, ec${k}), ${L['hr']})) :
    {T.${pfx}_pvb(${cur}, T.${pfx}_pk(${TH(L['mid'])}, ${cur}, _)) == RHS : Array<U32> & (O.Words & U32)}
  %Equal.sym(Array<U32> & O.Words, O.put_words(${TH(L['mid'])}, ${cur}, ${L['W']}), (${TH(L['out'])}, ${L['W']}),
      VE.put_words_ok(${DOe}, ${L['hdw'].replace('hdw', 'dw')}, ${L['mid']}(${DA}), ${L['T']}, ${cur}, ${L['P']}, ${N}, pf${L['mid']}(${DA}), ${L['pf']}, hDO31(${NH}), ${L['hdw']}, ${L['hp3']}, ${L['eP']}, VL.and3_q(${N}, ${M}, ec${k}), ${L['hr']}, ${L['hdst']}(${NH}))) :
    {T.${pfx}_pvb(${cur}, O.pwn(_)) == RHS : Array<U32> & (O.Words & U32)}
  %Equal.sym(U32, O.padd(${cur}, ${N}), ${L['nxt']}, ${L['pd']}(${NH})) :
    {(${TH(L['out'])}, (${L['W']}, _)) == RHS : Array<U32> & (O.Words & U32)}
  {==}

@@ spec_text @@

# ---- the spec side ------------------------------------------------------------------------------

def XE(${ALLP}) -> S.Value: ${XE}
def ENC(${ALLP}) -> +List<U32>: ${ENC}

@@ spec_text_hl @@
def hl${j}(${ALLP}) -> {Nat.is_le(${MN[j]}, FD.spec_common__length(U32, FD.array__slots(U32, ${TN[j]}))) == ${TRUE}}:
  %Equal.sym(Nat, FD.spec_common__length(U32, FD.array__slots(U32, ${TN[j]})), VB.pw(dw${j}), FD.array__slots_length(U32, dw${j}, ${TN[j]}, pf${j})) : {Nat.is_le(${MN[j]}, _) == ${TRUE}}
  %eNW${j}(${NH}) : {Nat.is_le(_, VB.pw(dw${j})) == ${TRUE}}
  FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(dw${j})) == ${TRUE}}, Nat.add(VC.NW(N${j}), 0n), VC.NW(N${j}), FD.nat__add_zero(VC.NW(N${j})), hr${j})
def ft${j}(${ALLP}) -> {N.fits(4n, A.quad(${MN[j]})) == ${TRUE}}:
  VFT.fits4(24n, A.quad(${MN[j]}), FD.nat__le_trans(A.quad(${MN[j]}), Nat.add(31n, A.quad(${MN[j]})), VB.pw(24n), Order.left_below_sum(31n, A.quad(${MN[j]})), qy(${NH}, ${MN[j]}, lM${j}N(c0, c1, c2))), {==})

@@ spec_text_encE @@

def encE(${ALLP}) -> {Codec.encoding_for_legal_type(Spec.${X}(), XE(${ALLA})) == Some{ENC(${ALLA})} : Maybe<&2, +List<U32>>}:
  +e1 = %Equal.sym(Nat, List.length(&2, U32, F.limbs(${ZN[0]})), A.quad(M0(c0)), VM.len_lwt(M0(c0), FD.array__slots(U32, T0), hl0(${ALLA}))) : {U32.to_nat(${S1}) == Nat.add(U32.to_nat(356), _) : Nat}
    eS1(${NH})
  {==}

@@ spec_text_ce1 @@

def ce1(${ALLP}) -> {U32.to_nat(${S1}) == Nat.add(U32.to_nat(356), List.length(&2, U32, F.limbs(${ZN[0]}))) : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, F.limbs(${ZN[0]})), A.quad(M0(c0)), VM.len_lwt(M0(c0), FD.array__slots(U32, T0), hl0(${ALLA}))) : {U32.to_nat(${S1}) == Nat.add(U32.to_nat(356), _) : Nat}
  eS1(${NH})
def ce2(${ALLP}) -> {U32.to_nat(${S2}) == Nat.add(U32.to_nat(${S1}), List.length(&2, U32, F.limbs(${ZN[1]}))) : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, F.limbs(${ZN[1]})), A.quad(M1(c1)), VM.len_lwt(M1(c1), FD.array__slots(U32, T1), hl1(${ALLA}))) : {U32.to_nat(${S2}) == Nat.add(U32.to_nat(${S1}), _) : Nat}
  %Equal.sym(Nat, U32.to_nat(${S1}), A.quad(Q1(c0)), eS1(${NH})) : {U32.to_nat(${S2}) == Nat.add(_, A.quad(M1(c1))) : Nat}
  Equal.trans(Nat, U32.to_nat(${S2}), A.quad(Q2(c0, c1)), Nat.add(A.quad(Q1(c0)), A.quad(M1(c1))), eS2(${NH}), VM.quad_add(Q1(c0), M1(c1)))
def cfit(${ALLP}) -> {N.fits(4n, Nat.add(U32.to_nat(${S2}), List.length(&2, U32, F.limbs(${ZN[2]})))) == ${TRUE}}:
  %Equal.sym(Nat, List.length(&2, U32, F.limbs(${ZN[2]})), A.quad(M2(c2)), VM.len_lwt(M2(c2), FD.array__slots(U32, T2), hl2(${ALLA}))) : {N.fits(4n, Nat.add(U32.to_nat(${S2}), _)) == ${TRUE}}
  %Equal.sym(Nat, U32.to_nat(${S2}), A.quad(Q2(c0, c1)), eS2(${NH})) : {N.fits(4n, Nat.add(_, A.quad(M2(c2)))) == ${TRUE}}
  %VM.quad_add(Q2(c0, c1), M2(c2)) : {N.fits(4n, _) == ${TRUE}}
  VFT.fits4(24n, A.quad(QN(c0, c1, c2)), FD.nat__le_trans(A.quad(QN(c0, c1, c2)), Nat.add(31n, A.quad(QN(c0, c1, c2))), VB.pw(24n), Order.left_below_sum(31n, A.quad(QN(c0, c1, c2))), qy(${NH}, QN(c0, c1, c2), Order.reflexive(QN(c0, c1, c2)))), {==})

def encE(${ALLP}) -> {Codec.encoding_for_legal_type(Spec.${X}(), XE(${ALLA})) == Some{ENC(${ALLA})} : Maybe<&2, +List<U32>>}:
  # the encoding opened by F.efl_bytes and the container by VSQ.seq_parts (over variables): the
  # conversions from the encoding to the aggregate of the parts ran the spec encoder (5.7 s)
  %F.efl_bytes(Spec.${X}(), XE(${ALLA})) : {_ == Some{ENC(${ALLA})} : Maybe<&2, +List<U32>>}
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(XE(${ALLA}), Spec.${X}()), Codec.aggregate(Codec.parts(${items(0)}, ${chain(0)}), SC.fixed_size(${chain(0)})),
      VSQ.seq_parts(XE(${ALLA}), Spec.${X}(), ${items(0)}, ${VBX_names(X)}, ${chain(0)}, {==}, {==})) :
    {Codec.bytes(_) == Some{ENC(${ALLA})} : Maybe<&2, +List<U32>>}
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(${items(0)}, ${chain(0)}), Some{[${', '.join(parts)}]}, ${cat(0)}) :
    {Codec.bytes(Codec.aggregate(_, SC.fixed_size(${chain(0)}))) == Some{ENC(${ALLA})} : Maybe<&2, +List<U32>>}
  %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding([${', '.join(parts)}]), Some{ENC(${ALLA})},
      VV.enc3(${AW}, ${ZN[0]}, ${ZN[1]}, ${ZN[2]}, ${POST}, 356, ${S1}, ${S2}, {==}, ce1(${ALLA}), ce2(${ALLA}), cfit(${ALLA}))) :
    {Codec.bytes(Codec.one(_, None{})) == Some{ENC(${ALLA})} : Maybe<&2, +List<U32>>}
  {==}

@@ spec_text_hdrW @@
def hdrW(${ALLP}) -> {VF.WIN(89n, 0n, ${SD}) == ${HW89} : List<&2, U32>}:
  %Equal.sym(List<&2, U32>, VF.WIN(Nat.add(2n, 87n), 0n, ${SD}), VF.app(VF.WIN(2n, 0n, ${SD}), VF.WIN(87n, Nat.add(0n, 2n), ${SD})), VF.win_split(2n, 87n, 0n, ${SD})) : {_ == ${HW89} : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(Nat.add(1n, 86n), 2n, ${SD}), VF.app(VF.WIN(1n, 2n, ${SD}), VF.WIN(86n, Nat.add(2n, 1n), ${SD})), VF.win_split(1n, 86n, 2n, ${SD})) : {VF.app(VF.WIN(2n, 0n, ${SD}), _) == ${HW89} : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(Nat.add(1n, 85n), 3n, ${SD}), VF.app(VF.WIN(1n, 3n, ${SD}), VF.WIN(85n, Nat.add(3n, 1n), ${SD})), VF.win_split(1n, 85n, 3n, ${SD})) : {VF.app(VF.WIN(2n, 0n, ${SD}), VF.app(VF.WIN(1n, 2n, ${SD}), _)) == ${HW89} : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(Nat.add(1n, 84n), 4n, ${SD}), VF.app(VF.WIN(1n, 4n, ${SD}), VF.WIN(84n, Nat.add(4n, 1n), ${SD})), VF.win_split(1n, 84n, 4n, ${SD})) : {VF.app(VF.WIN(2n, 0n, ${SD}), VF.app(VF.WIN(1n, 2n, ${SD}), VF.app(VF.WIN(1n, 3n, ${SD}), _))) == ${HW89} : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(Nat.add(52n, 32n), 5n, ${SD}), VF.app(VF.WIN(52n, 5n, ${SD}), VF.WIN(32n, Nat.add(5n, 52n), ${SD})), VF.win_split(52n, 32n, 5n, ${SD})) : {VF.app(VF.WIN(2n, 0n, ${SD}), VF.app(VF.WIN(1n, 2n, ${SD}), VF.app(VF.WIN(1n, 3n, ${SD}), VF.app(VF.WIN(1n, 4n, ${SD}), _)))) == ${HW89} : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(2n, 0n, ${SD}), [i0, i1], s0(${ALLA})) : {VF.app(_, VF.app(VF.WIN(1n, 2n, ${SD}), VF.app(VF.WIN(1n, 3n, ${SD}), VF.app(VF.WIN(1n, 4n, ${SD}), VF.app(VF.WIN(52n, 5n, ${SD}), VF.WIN(32n, 57n, ${SD})))))) == ${HW89} : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(1n, 2n, ${SD}), [356], s2(${ALLA})) : {VF.app([i0, i1], VF.app(_, VF.app(VF.WIN(1n, 3n, ${SD}), VF.app(VF.WIN(1n, 4n, ${SD}), VF.app(VF.WIN(52n, 5n, ${SD}), VF.WIN(32n, 57n, ${SD})))))) == ${HW89} : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(1n, 3n, ${SD}), [${S1}], s3(${ALLA})) : {VF.app([i0, i1], VF.app([356], VF.app(_, VF.app(VF.WIN(1n, 4n, ${SD}), VF.app(VF.WIN(52n, 5n, ${SD}), VF.WIN(32n, 57n, ${SD})))))) == ${HW89} : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(1n, 4n, ${SD}), [${S2}], s4(${ALLA})) : {VF.app([i0, i1], VF.app([356], VF.app([${S1}], VF.app(_, VF.app(VF.WIN(52n, 5n, ${SD}), VF.WIN(32n, 57n, ${SD})))))) == ${HW89} : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(52n, 5n, ${SD}), ${wl(HW)}, s5(${ALLA})) : {VF.app([i0, i1], VF.app([356], VF.app([${S1}], VF.app([${S2}], VF.app(_, VF.WIN(32n, 57n, ${SD})))))) == ${HW89} : List<&2, U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(32n, 57n, ${SD}), ${wl(PW)}, s57(${ALLA})) : {VF.app([i0, i1], VF.app([356], VF.app([${S1}], VF.app([${S2}], VF.app(${wl(HW)}, _))))) == ${HW89} : List<&2, U32>}
  {==}

@@ spec_text_out_eq @@

# The output's bytes are the encoding.
def out_eq(${ALLP}) -> {${Ew} == VS.bt(U32.to_nat(${S3}), F.limbs(${SD})) : +List<U32>}:
  %Equal.sym(Nat, U32.to_nat(${S3}), A.quad(QN(c0, c1, c2)), eS3(${NH})) : {${Ew} == VS.bt(_, F.limbs(${SD})) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(A.quad(QN(c0, c1, c2)), F.limbs(${SD})), F.limbs(VS.wtake(QN(c0, c1, c2), ${SD})), VS.bt_limbs(QN(c0, c1, c2), ${SD})) : {${Ew} == _ : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(QN(c0, c1, c2), ${SD}), VF.app(VS.wtake(Q2(c0, c1), ${SD}), ${X2}), VF.take_split(Q2(c0, c1), M2(c2), ${SD})) : {${Ew} == F.limbs(_) : +List<U32>}
  %Equal.sym(+List<U32>, F.limbs(VF.app(VS.wtake(Q2(c0, c1), ${SD}), ${X2})), List.append(&2, U32, F.limbs(VS.wtake(Q2(c0, c1), ${SD})), F.limbs(${X2})), VF.limbs_app(VS.wtake(Q2(c0, c1), ${SD}), ${X2})) :
    {${Ew} == _ : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(Q2(c0, c1), ${SD}), VF.app(VS.wtake(Q1(c0), ${SD}), ${X1}), VF.take_split(Q1(c0), M1(c1), ${SD})) :
    {${Ew} == List.append(&2, U32, F.limbs(_), F.limbs(${X2})) : +List<U32>}
  %Equal.sym(+List<U32>, F.limbs(VF.app(VS.wtake(Q1(c0), ${SD}), ${X1})), List.append(&2, U32, F.limbs(VS.wtake(Q1(c0), ${SD})), F.limbs(${X1})), VF.limbs_app(VS.wtake(Q1(c0), ${SD}), ${X1})) :
    {${Ew} == List.append(&2, U32, _, F.limbs(${X2})) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(Q1(c0), ${SD}), VF.app(VS.wtake(89n, ${SD}), ${X0}), VF.take_split(89n, M0(c0), ${SD})) :
    {${Ew} == List.append(&2, U32, List.append(&2, U32, F.limbs(_), F.limbs(${X1})), F.limbs(${X2})) : +List<U32>}
  %Equal.sym(+List<U32>, F.limbs(VF.app(VS.wtake(89n, ${SD}), ${X0})), List.append(&2, U32, F.limbs(VS.wtake(89n, ${SD})), F.limbs(${X0})), VF.limbs_app(VS.wtake(89n, ${SD}), ${X0})) :
    {${Ew} == List.append(&2, U32, List.append(&2, U32, _, F.limbs(${X1})), F.limbs(${X2})) : +List<U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(89n, 0n, ${SD}), ${HW89}, hdrW(${ALLA})) :
    {${Ew} == List.append(&2, U32, List.append(&2, U32, List.append(&2, U32, F.limbs(_), F.limbs(${X0})), F.limbs(${X1})), F.limbs(${X2})) : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, List.append(&2, U32, ${LH}, F.limbs(${X0})), F.limbs(${X1})), F.limbs(${X2})),
      List.append(&2, U32, List.append(&2, U32, ${LH}, F.limbs(${X0})), List.append(&2, U32, F.limbs(${X1}), F.limbs(${X2}))),
      VS.app_assoc(List.append(&2, U32, ${LH}, F.limbs(${X0})), F.limbs(${X1}), F.limbs(${X2}))) :
    {${Ew} == _ : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, ${LH}, F.limbs(${X0})), List.append(&2, U32, F.limbs(${X1}), F.limbs(${X2}))),
      List.append(&2, U32, ${LH}, List.append(&2, U32, F.limbs(${X0}), List.append(&2, U32, F.limbs(${X1}), F.limbs(${X2})))),
      VS.app_assoc(${LH}, F.limbs(${X0}), List.append(&2, U32, F.limbs(${X1}), F.limbs(${X2})))) :
    {${Ew} == _ : +List<U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(M0(c0), 89n, ${SD}), ${ZN[0]}, lW0w(${ALLA})) :
    {${Ew} == List.append(&2, U32, ${LH}, List.append(&2, U32, F.limbs(_), List.append(&2, U32, F.limbs(${X1}), F.limbs(${X2})))) : +List<U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(M1(c1), Q1(c0), ${SD}), ${ZN[1]}, lW1w(${ALLA})) :
    {${Ew} == List.append(&2, U32, ${LH}, List.append(&2, U32, F.limbs(${ZN[0]}), List.append(&2, U32, F.limbs(_), F.limbs(${X2})))) : +List<U32>}
  %Equal.sym(List<&2, U32>, VF.WIN(M2(c2), Q2(c0, c1), ${SD}), ${ZN[2]}, lW2w(${ALLA})) :
    {${Ew} == List.append(&2, U32, ${LH}, List.append(&2, U32, F.limbs(${ZN[0]}), List.append(&2, U32, F.limbs(${ZN[1]}), F.limbs(_)))) : +List<U32>}
  {==}

# The bytes the encoder writes are the spec/codec.bend encoding of the object's value.
def encode_spec(${ALLP})
    -> Decoding.decodes(Spec.${X}(), VS.bt(U32.to_nat(${S3}), F.limbs(${SD})), XE(${ALLA})):
  Equal.trans(Maybe<&2, +List<U32>>, Codec.encoding_for_legal_type(Spec.${X}(), XE(${ALLA})), Some{${Ew}}, Some{VS.bt(U32.to_nat(${S3}), F.limbs(${SD}))},
    encE(${ALLA}), Equal.cong(+List<U32>, Maybe<&2, +List<U32>>, z => Some{z}, ${Ew}, VS.bt(U32.to_nat(${S3}), F.limbs(${SD})), out_eq(${ALLA})))
