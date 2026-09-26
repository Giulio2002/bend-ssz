"""The encoder laws of DataColumnSidecar (encode_eval, encode_spec), for codegen/var_multi.py.

The object is index words i0 i1, the three lists' storage trees T0 T1 T2 holding
N0 N1 N2 bytes (c0 elements of 2048 bytes, c1 and c2 of 48; ec_i, hc_i), the
header's 52 words h0..h51 and the inclusion proof's storage tree TP (32 words).
The encoder allocates a zero tree of depth DO and writes, in its order:
  D1  word 2 := 356          D2  column's words at 89      D3  word 3 := S1
  D4  kzg_commitments at Q1  D5  word 4 := S2              D6  kzg_proofs at Q2
  D7  the header at word 5   D8  the proof at word 57      D9  the index at word 0
encode_eval: the encoder returns the object and B.Buf{thaw(D9), S3}.
encode_spec: those S3 bytes are the spec encoding of the object's value.
The sizes are up to 8.8 MB, so the closed bounds (cQ, cS, cD, cH0, cH1) make this a
big_* file (checked with --big).
"""

X = 'DataColumnSidecar'
IW = ['i0', 'i1']
HW = [f'h{k}' for k in range(52)]
PW = [f'VB.slot(TP, {k}n)' for k in range(32)]
TR = 'FD.array__Tree<U32>'
X_ = X


def wl(ws):
    return '[' + ', '.join(ws) + ']'


def text(hdr, pvnode, hnode, inode, DEC_HEAD, SCH):
    """hdr: var_laws.FT of the header; the walk nodes (val, sch, proof, words) of the
    proof vector (words VB.slot(TP, k)), the header (words h..) and the index (i0 i1)."""
    W = []
    w = W.append
    TRUE = 'True{} : Bool'
    # ---- parameter lists ----
    NP = ('+N0: U32, +N1: U32, +N2: U32, +c0: Nat, +c1: Nat, +c2: Nat,\n'
          '    +ec0: {U32.to_nat(N0) == A.quad(M0(c0)) : Nat}, +ec1: {U32.to_nat(N1) == A.quad(M1(c1)) : Nat}, +ec2: {U32.to_nat(N2) == A.quad(M2(c2)) : Nat},\n'
          f'    +hc0: {{Nat.is_le(c0, U32.to_nat(4096)) == {TRUE}}}, +hc1: {{Nat.is_le(c1, U32.to_nat(4096)) == {TRUE}}}, +hc2: {{Nat.is_le(c2, U32.to_nat(4096)) == {TRUE}}}')
    NA = 'N0, N1, N2, c0, c1, c2, ec0, ec1, ec2, hc0, hc1, hc2'
    DP = (f'+N0: U32, +N1: U32, +N2: U32, +c0: Nat, +c1: Nat, +T0: {TR}, +T1: {TR}, +T2: {TR}, +TP: {TR}, +i0: U32, +i1: U32, '
          + ', '.join(f'+{h}: U32' for h in HW))
    DA = 'N0, N1, N2, c0, c1, T0, T1, T2, TP, i0, i1, ' + ', '.join(HW)
    HP = (f'+c2: Nat, +dw0: Nat, +dw1: Nat, +dw2: Nat, +dp: Nat,\n'
          f'    +pf0: {{FD.array__perfect(U32, dw0, T0) == {TRUE}}}, +pf1: {{FD.array__perfect(U32, dw1, T1) == {TRUE}}}, +pf2: {{FD.array__perfect(U32, dw2, T2) == {TRUE}}}, +pfP: {{FD.array__perfect(U32, dp, TP) == {TRUE}}},\n'
          f'    +hdw0: {{Nat.is_lt(dw0, 31n) == {TRUE}}}, +hdw1: {{Nat.is_lt(dw1, 31n) == {TRUE}}}, +hdw2: {{Nat.is_lt(dw2, 31n) == {TRUE}}}, +hdp: {{Nat.is_lt(dp, 31n) == {TRUE}}},\n'
          '    +ec0: {U32.to_nat(N0) == A.quad(M0(c0)) : Nat}, +ec1: {U32.to_nat(N1) == A.quad(M1(c1)) : Nat}, +ec2: {U32.to_nat(N2) == A.quad(M2(c2)) : Nat},\n'
          f'    +hc0: {{Nat.is_le(c0, U32.to_nat(4096)) == {TRUE}}}, +hc1: {{Nat.is_le(c1, U32.to_nat(4096)) == {TRUE}}}, +hc2: {{Nat.is_le(c2, U32.to_nat(4096)) == {TRUE}}},\n'
          f'    +hr0: {{Nat.is_le(Nat.add(VC.NW(N0), 0n), VB.pw(dw0)) == {TRUE}}}, +hr1: {{Nat.is_le(Nat.add(VC.NW(N1), 0n), VB.pw(dw1)) == {TRUE}}}, +hr2: {{Nat.is_le(Nat.add(VC.NW(N2), 0n), VB.pw(dw2)) == {TRUE}}},\n'
          f'    +hrP: {{Nat.is_le(32n, VB.pw(dp)) == {TRUE}}}')
    HA = 'c2, dw0, dw1, dw2, dp, pf0, pf1, pf2, pfP, hdw0, hdw1, hdw2, hdp, ec0, ec1, ec2, hc0, hc1, hc2, hr0, hr1, hr2, hrP'
    ALLP = DP + ',\n    ' + HP
    ALLA = DA + ', ' + HA
    DOe = 'DO(N0, N1, N2)'
    HR = hdr.obj(HW)
    OE = (f'T.{X}{{O.U64{{i0, i1}}, O.Words{{FD.array__thaw(U32, T0), N0}}, O.Words{{FD.array__thaw(U32, T1), N1}}, O.Words{{FD.array__thaw(U32, T2), N2}}, '
          f'O.BSome{{{HR}, O.BNone{{}}}}, O.Words{{FD.array__thaw(U32, TP), 128}}}}')
    w(f'''
# ---- sizes ------------------------------------------------------------------------------------

def M0(+c0: Nat) -> Nat: VM.mulE(512n, c0)
def M1(+c1: Nat) -> Nat: VM.mulE(12n, c1)
def M2(+c2: Nat) -> Nat: VM.mulE(12n, c2)
def Q1(+c0: Nat) -> Nat: Nat.add(89n, M0(c0))
def Q2(+c0: Nat, +c1: Nat) -> Nat: Nat.add(Q1(c0), M1(c1))
def QN(+c0: Nat, +c1: Nat, +c2: Nat) -> Nat: Nat.add(Q2(c0, c1), M2(c2))
def MX0() -> Nat: VM.mulE(512n, U32.to_nat(4096))
def MX1() -> Nat: VM.mulE(12n, U32.to_nat(4096))
def QX() -> Nat: Nat.add(Nat.add(Nat.add(89n, MX0()), MX1()), MX1())
def S1(+N0: U32) -> U32: U32.add(356, N0)
def S2(+N0: U32, +N1: U32) -> U32: U32.add(S1(N0), N1)
def S3(+N0: U32, +N1: U32, +N2: U32) -> U32: U32.add(S2(N0, N1), N2)
def DO(+N0: U32, +N1: U32, +N2: U32) -> Nat: B.words_depth(VC.nwu(S3(N0, N1, N2)))

# the closed bounds (big)
def cQ() -> {{Nat.is_le(Nat.add(31n, A.quad(QX())), VB.pw(24n)) == {TRUE}}}: {{==}}
def cS() -> {{Nat.is_le(A.quad(QX()), U32.to_nat(16777216)) == {TRUE}}}: {{==}}
def cD() -> {{Nat.is_le(QX(), O.pow2n(23n)) == {TRUE}}}: {{==}}
def cH0() -> {{Nat.is_le(A.quad(MX0()), U32.to_nat(8388608)) == {TRUE}}}: {{==}}
def cH1() -> {{Nat.is_le(A.quad(MX1()), U32.to_nat(196608)) == {TRUE}}}: {{==}}

def lQX({NP}) -> {{Nat.is_le(QN(c0, c1, c2), QX()) == {TRUE}}}:
  +l1 = Order.add_left(89n, M0(c0), MX0(), VME.mulE_mono(512n, c0, U32.to_nat(4096), hc0))
  +l2 = FD.nat__le_trans(Q2(c0, c1), Nat.add(Nat.add(89n, MX0()), M1(c1)), Nat.add(Nat.add(89n, MX0()), MX1()),
    Order.add_right(Q1(c0), Nat.add(89n, MX0()), M1(c1), l1), Order.add_left(Nat.add(89n, MX0()), M1(c1), MX1(), VME.mulE_mono(12n, c1, U32.to_nat(4096), hc1)))
  FD.nat__le_trans(QN(c0, c1, c2), Nat.add(Nat.add(Nat.add(89n, MX0()), MX1()), M2(c2)), QX(),
    Order.add_right(Q2(c0, c1), Nat.add(Nat.add(89n, MX0()), MX1()), M2(c2), l2), Order.add_left(Nat.add(Nat.add(89n, MX0()), MX1()), M2(c2), MX1(), VME.mulE_mono(12n, c2, U32.to_nat(4096), hc2)))

def lQ1N(+c0: Nat, +c1: Nat, +c2: Nat) -> {{Nat.is_le(Q1(c0), QN(c0, c1, c2)) == {TRUE}}}:
  FD.nat__le_trans(Q1(c0), Q2(c0, c1), QN(c0, c1, c2), Order.below_sum(Q1(c0), M1(c1)), Order.below_sum(Q2(c0, c1), M2(c2)))
def lM0N(+c0: Nat, +c1: Nat, +c2: Nat) -> {{Nat.is_le(M0(c0), QN(c0, c1, c2)) == {TRUE}}}:
  FD.nat__le_trans(M0(c0), Q1(c0), QN(c0, c1, c2), Order.left_below_sum(89n, M0(c0)), lQ1N(c0, c1, c2))
def lM1N(+c0: Nat, +c1: Nat, +c2: Nat) -> {{Nat.is_le(M1(c1), QN(c0, c1, c2)) == {TRUE}}}:
  FD.nat__le_trans(M1(c1), Q2(c0, c1), QN(c0, c1, c2), Order.left_below_sum(Q1(c0), M1(c1)), Order.below_sum(Q2(c0, c1), M2(c2)))
def lM2N(+c0: Nat, +c1: Nat, +c2: Nat) -> {{Nat.is_le(M2(c2), QN(c0, c1, c2)) == {TRUE}}}: Order.left_below_sum(Q2(c0, c1), M2(c2))

# x <= QN: 4 x < 2^24, and 31 + 4 x <= 2^24
def qy({NP}, +x: Nat, +h: {{Nat.is_le(x, QN(c0, c1, c2)) == {TRUE}}})
    -> {{Nat.is_le(Nat.add(31n, A.quad(x)), VB.pw(24n)) == {TRUE}}}:
  FD.nat__le_trans(Nat.add(31n, A.quad(x)), Nat.add(31n, A.quad(QX())), VB.pw(24n),
    Order.add_left(31n, A.quad(x), A.quad(QX()), VME.quad_mono(x, QX(), FD.nat__le_trans(x, QN(c0, c1, c2), QX(), h, lQX({NA})))), cQ())
def qlt({NP}, +x: Nat, +h: {{Nat.is_le(x, QN(c0, c1, c2)) == {TRUE}}})
    -> {{Nat.is_lt(A.quad(x), VB.pw(24n)) == {TRUE}}}:
  FD.nat__lt_le_trans(A.quad(x), Nat.add(31n, A.quad(x)), VB.pw(24n), FD.nat__lt_le_trans(A.quad(x), 1n+A.quad(x), Nat.add(31n, A.quad(x)), FD.nat__lt_succ(A.quad(x)), Order.add_right(1n, 31n, A.quad(x), {{==}})), qy({NA}, x, h))
def qle({NP}, +x: Nat, +h: {{Nat.is_le(x, QN(c0, c1, c2)) == {TRUE}}})
    -> {{Nat.is_le(A.quad(x), U32.to_nat(16777216)) == {TRUE}}}:
  FD.nat__le_trans(A.quad(x), A.quad(QX()), U32.to_nat(16777216), VME.quad_mono(x, QX(), FD.nat__le_trans(x, QN(c0, c1, c2), QX(), h, lQX({NA}))), cS())

def eS1({NP}) -> {{U32.to_nat(S1(N0)) == A.quad(Q1(c0)) : Nat}}:
  +h = FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(U32.to_nat(356), z), U32.to_nat(16777216)) == {TRUE}}}, A.quad(M0(c0)), U32.to_nat(N0), Equal.sym(Nat, U32.to_nat(N0), A.quad(M0(c0)), ec0),
    qle({NA}, Q1(c0), lQ1N(c0, c1, c2)))
  Equal.trans(Nat, U32.to_nat(S1(N0)), Nat.add(U32.to_nat(356), U32.to_nat(N0)), A.quad(Q1(c0)), A.add_le(356, N0, 16777216, h),
    Equal.cong(Nat, Nat, z => Nat.add(U32.to_nat(356), z), U32.to_nat(N0), A.quad(M0(c0)), ec0))

def eS2({NP}) -> {{U32.to_nat(S2(N0, N1)) == A.quad(Q2(c0, c1)) : Nat}}:
  +e1 = eS1({NA})
  +q = Equal.trans(Nat, Nat.add(U32.to_nat(S1(N0)), U32.to_nat(N1)), Nat.add(A.quad(Q1(c0)), A.quad(M1(c1))), A.quad(Q2(c0, c1)),
    Equal.trans(Nat, Nat.add(U32.to_nat(S1(N0)), U32.to_nat(N1)), Nat.add(A.quad(Q1(c0)), U32.to_nat(N1)), Nat.add(A.quad(Q1(c0)), A.quad(M1(c1))),
      Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(N1)), U32.to_nat(S1(N0)), A.quad(Q1(c0)), e1),
      Equal.cong(Nat, Nat, z => Nat.add(A.quad(Q1(c0)), z), U32.to_nat(N1), A.quad(M1(c1)), ec1)),
    Equal.sym(Nat, A.quad(Q2(c0, c1)), Nat.add(A.quad(Q1(c0)), A.quad(M1(c1))), VM.quad_add(Q1(c0), M1(c1))))
  +h = FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat(16777216)) == {TRUE}}}, A.quad(Q2(c0, c1)), Nat.add(U32.to_nat(S1(N0)), U32.to_nat(N1)),
    Equal.sym(Nat, Nat.add(U32.to_nat(S1(N0)), U32.to_nat(N1)), A.quad(Q2(c0, c1)), q), qle({NA}, Q2(c0, c1), Order.below_sum(Q2(c0, c1), M2(c2))))
  Equal.trans(Nat, U32.to_nat(S2(N0, N1)), Nat.add(U32.to_nat(S1(N0)), U32.to_nat(N1)), A.quad(Q2(c0, c1)), A.add_le(S1(N0), N1, 16777216, h), q)

def eS3({NP}) -> {{U32.to_nat(S3(N0, N1, N2)) == A.quad(QN(c0, c1, c2)) : Nat}}:
  +e2 = eS2({NA})
  +q = Equal.trans(Nat, Nat.add(U32.to_nat(S2(N0, N1)), U32.to_nat(N2)), Nat.add(A.quad(Q2(c0, c1)), A.quad(M2(c2))), A.quad(QN(c0, c1, c2)),
    Equal.trans(Nat, Nat.add(U32.to_nat(S2(N0, N1)), U32.to_nat(N2)), Nat.add(A.quad(Q2(c0, c1)), U32.to_nat(N2)), Nat.add(A.quad(Q2(c0, c1)), A.quad(M2(c2))),
      Equal.cong(Nat, Nat, z => Nat.add(z, U32.to_nat(N2)), U32.to_nat(S2(N0, N1)), A.quad(Q2(c0, c1)), e2),
      Equal.cong(Nat, Nat, z => Nat.add(A.quad(Q2(c0, c1)), z), U32.to_nat(N2), A.quad(M2(c2)), ec2)),
    Equal.sym(Nat, A.quad(QN(c0, c1, c2)), Nat.add(A.quad(Q2(c0, c1)), A.quad(M2(c2))), VM.quad_add(Q2(c0, c1), M2(c2))))
  +h = FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat(16777216)) == {TRUE}}}, A.quad(QN(c0, c1, c2)), Nat.add(U32.to_nat(S2(N0, N1)), U32.to_nat(N2)),
    Equal.sym(Nat, Nat.add(U32.to_nat(S2(N0, N1)), U32.to_nat(N2)), A.quad(QN(c0, c1, c2)), q), qle({NA}, QN(c0, c1, c2), Order.reflexive(QN(c0, c1, c2))))
  Equal.trans(Nat, U32.to_nat(S3(N0, N1, N2)), Nat.add(U32.to_nat(S2(N0, N1)), U32.to_nat(N2)), A.quad(QN(c0, c1, c2)), A.add_le(S2(N0, N1), N2, 16777216, h), q)

# the word counts
def eNWg({NP}, +L: U32, +m: Nat, +em: {{U32.to_nat(L) == A.quad(m) : Nat}}, +hm: {{Nat.is_le(m, QN(c0, c1, c2)) == {TRUE}}})
    -> {{VC.NW(L) == m : Nat}}:
  %Equal.sym(Nat, VC.NW(L), VD.s_rng(2n, 3n+U32.to_nat(L)), VC.eNW(L, 24n, {{==}},
      FD.logic__subst(Nat, z => {{Nat.is_le(Nat.add(31n, z), VB.pw(24n)) == {TRUE}}}, A.quad(m), U32.to_nat(L), Equal.sym(Nat, U32.to_nat(L), A.quad(m), em), qy({NA}, m, hm)))) :
    {{_ == m : Nat}}
  %Equal.sym(Nat, U32.to_nat(L), A.quad(m), em) : {{VD.s_rng(2n, 3n+_) == m : Nat}}
  VL.rng2_q(m)
def eNW0({NP}) -> {{VC.NW(N0) == M0(c0) : Nat}}: eNWg({NA}, N0, M0(c0), ec0, lM0N(c0, c1, c2))
def eNW1({NP}) -> {{VC.NW(N1) == M1(c1) : Nat}}: eNWg({NA}, N1, M1(c1), ec1, lM1N(c0, c1, c2))
def eNW2({NP}) -> {{VC.NW(N2) == M2(c2) : Nat}}: eNWg({NA}, N2, M2(c2), ec2, lM2N(c0, c1, c2))
def eNWS({NP}) -> {{VC.NW(S3(N0, N1, N2)) == QN(c0, c1, c2) : Nat}}: eNWg({NA}, S3(N0, N1, N2), QN(c0, c1, c2), eS3({NA}), Order.reflexive(QN(c0, c1, c2)))

# the output tree's depth
def hDO({NP}) -> {{Nat.is_le({DOe}, 23n) == {TRUE}}}:
  VD.wd_min(VC.nwu(S3(N0, N1, N2)), 23n,
    FD.logic__subst(Nat, z => {{Nat.is_le(z, O.pow2n(23n)) == {TRUE}}}, QN(c0, c1, c2), VC.NW(S3(N0, N1, N2)), Equal.sym(Nat, VC.NW(S3(N0, N1, N2)), QN(c0, c1, c2), eNWS({NA})),
      FD.nat__le_trans(QN(c0, c1, c2), QX(), O.pow2n(23n), lQX({NA}), cD())))
def hDO29({NP}) -> {{Nat.is_lt({DOe}, 29n) == {TRUE}}}: FD.nat__le_lt_trans({DOe}, 23n, 29n, hDO({NA}), {{==}})
def hDO31({NP}) -> {{Nat.is_lt({DOe}, 31n) == {TRUE}}}: FD.nat__le_lt_trans({DOe}, 23n, 31n, hDO({NA}), {{==}})
def hDO32({NP}) -> {{Nat.is_lt({DOe}, 32n) == {TRUE}}}: VB.lt32({DOe}, hDO31({NA}))
def roomS({NP}) -> {{Nat.is_le(QN(c0, c1, c2), VB.pw({DOe})) == {TRUE}}}:
  %Equal.sym(Nat, VB.pw({DOe}), O.pow2n({DOe}), VD.s_pow2_eq({DOe})) : {{Nat.is_le(QN(c0, c1, c2), _) == {TRUE}}}
  %eNWS({NA}) : {{Nat.is_le(_, O.pow2n({DOe})) == {TRUE}}}
  VD.wd_cover(VC.nwu(S3(N0, N1, N2)), 23n, {{==}},
    FD.logic__subst(Nat, z => {{Nat.is_le(z, O.pow2n(23n)) == {TRUE}}}, QN(c0, c1, c2), VC.NW(S3(N0, N1, N2)), Equal.sym(Nat, VC.NW(S3(N0, N1, N2)), QN(c0, c1, c2), eNWS({NA})),
      FD.nat__le_trans(QN(c0, c1, c2), QX(), O.pow2n(23n), lQX({NA}), cD())))
def lQ1P({NP}) -> {{Nat.is_le(Q1(c0), VB.pw({DOe})) == {TRUE}}}: FD.nat__le_trans(Q1(c0), QN(c0, c1, c2), VB.pw({DOe}), lQ1N(c0, c1, c2), roomS({NA}))
def lQ2P({NP}) -> {{Nat.is_le(Q2(c0, c1), VB.pw({DOe})) == {TRUE}}}: FD.nat__le_trans(Q2(c0, c1), QN(c0, c1, c2), VB.pw({DOe}), Order.below_sum(Q2(c0, c1), M2(c2)), roomS({NA}))
def l89P({NP}) -> {{Nat.is_le(89n, VB.pw({DOe})) == {TRUE}}}: FD.nat__le_trans(89n, Q1(c0), VB.pw({DOe}), Order.below_sum(89n, M0(c0)), lQ1P({NA}))
def lkP({NP}, +k: Nat, +hk: {{Nat.is_le(k, 89n) == {TRUE}}}) -> {{Nat.is_le(k, VB.pw({DOe})) == {TRUE}}}: FD.nat__le_trans(k, 89n, VB.pw({DOe}), hk, l89P({NA}))
def ltP({NP}, +k: Nat, +hk: {{Nat.is_lt(k, 89n) == {TRUE}}}) -> {{Nat.is_lt(k, VB.pw({DOe})) == {TRUE}}}: FD.nat__lt_le_trans(k, 89n, VB.pw({DOe}), hk, l89P({NA}))

# the lists' windows: below the next list, inside the output
def lW0({NP}) -> {{Nat.is_le(Nat.add(VC.NW(N0), 89n), Q1(c0)) == {TRUE}}}:
  %Equal.sym(Nat, VC.NW(N0), M0(c0), eNW0({NA})) : {{Nat.is_le(Nat.add(_, 89n), Q1(c0)) == {TRUE}}}
  %FD.nat__add_comm(89n, M0(c0)) : {{Nat.is_le(_, Q1(c0)) == {TRUE}}}
  Order.reflexive(Q1(c0))
def lW1({NP}) -> {{Nat.is_le(Nat.add(VC.NW(N1), Q1(c0)), Q2(c0, c1)) == {TRUE}}}:
  %Equal.sym(Nat, VC.NW(N1), M1(c1), eNW1({NA})) : {{Nat.is_le(Nat.add(_, Q1(c0)), Q2(c0, c1)) == {TRUE}}}
  %FD.nat__add_comm(Q1(c0), M1(c1)) : {{Nat.is_le(_, Q2(c0, c1)) == {TRUE}}}
  Order.reflexive(Q2(c0, c1))
def lW2({NP}) -> {{Nat.is_le(Nat.add(VC.NW(N2), Q2(c0, c1)), QN(c0, c1, c2)) == {TRUE}}}:
  %Equal.sym(Nat, VC.NW(N2), M2(c2), eNW2({NA})) : {{Nat.is_le(Nat.add(_, Q2(c0, c1)), QN(c0, c1, c2)) == {TRUE}}}
  %FD.nat__add_comm(Q2(c0, c1), M2(c2)) : {{Nat.is_le(_, QN(c0, c1, c2)) == {TRUE}}}
  Order.reflexive(QN(c0, c1, c2))
def lW0Q2({NP}) -> {{Nat.is_le(Nat.add(VC.NW(N0), 89n), Q2(c0, c1)) == {TRUE}}}: FD.nat__le_trans(Nat.add(VC.NW(N0), 89n), Q1(c0), Q2(c0, c1), lW0({NA}), Order.below_sum(Q1(c0), M1(c1)))
def hdst0({NP}) -> {{Nat.is_le(Nat.add(VC.NW(N0), 89n), VB.pw({DOe})) == {TRUE}}}: FD.nat__le_trans(Nat.add(VC.NW(N0), 89n), Q1(c0), VB.pw({DOe}), lW0({NA}), lQ1P({NA}))
def hdst1({NP}) -> {{Nat.is_le(Nat.add(VC.NW(N1), Q1(c0)), VB.pw({DOe})) == {TRUE}}}: FD.nat__le_trans(Nat.add(VC.NW(N1), Q1(c0)), Q2(c0, c1), VB.pw({DOe}), lW1({NA}), lQ2P({NA}))
def hdst2({NP}) -> {{Nat.is_le(Nat.add(VC.NW(N2), Q2(c0, c1)), VB.pw({DOe})) == {TRUE}}}: FD.nat__le_trans(Nat.add(VC.NW(N2), Q2(c0, c1)), QN(c0, c1, c2), VB.pw({DOe}), lW2({NA}), roomS({NA}))
def lkQ1(+c0: Nat, +k: Nat, +hk: {{Nat.is_le(k, 89n) == {TRUE}}}) -> {{Nat.is_le(k, Q1(c0)) == {TRUE}}}: FD.nat__le_trans(k, 89n, Q1(c0), hk, Order.below_sum(89n, M0(c0)))
def lkQ2(+c0: Nat, +c1: Nat, +k: Nat, +hk: {{Nat.is_le(k, 89n) == {TRUE}}}) -> {{Nat.is_le(k, Q2(c0, c1)) == {TRUE}}}: FD.nat__le_trans(k, Q1(c0), Q2(c0, c1), lkQ1(c0, k, hk), Order.below_sum(Q1(c0), M1(c1)))

# no top bit: the counts are below 2^24
def ltN({NP}, +L: U32, +m: Nat, +em: {{U32.to_nat(L) == A.quad(m) : Nat}}, +hm: {{Nat.is_le(m, QN(c0, c1, c2)) == {TRUE}}})
    -> {{L == U32{{Word.shr.pad(31n, VE.winit(31n, VE.bits32(L)))}} : U32}}:
  VE.small_pad(L, 24n, {{==}}, FD.logic__subst(Nat, z => {{Nat.is_lt(z, VB.pw(24n)) == {TRUE}}}, A.quad(m), U32.to_nat(L), Equal.sym(Nat, U32.to_nat(L), A.quad(m), em), qlt({NA}, m, hm)))
def pd1({NP}) -> {{O.padd(356, N0) == S1(N0) : U32}}:
  VE.padd_ok(356, N0, VE.winit(31n, VE.bits32(356)), VE.winit(31n, VE.bits32(N0)), {{==}}, ltN({NA}, N0, M0(c0), ec0, lM0N(c0, c1, c2)))
def pd2({NP}) -> {{O.padd(S1(N0), N1) == S2(N0, N1) : U32}}:
  VE.padd_ok(S1(N0), N1, VE.winit(31n, VE.bits32(S1(N0))), VE.winit(31n, VE.bits32(N1)), ltN({NA}, S1(N0), Q1(c0), eS1({NA}), lQ1N(c0, c1, c2)), ltN({NA}, N1, M1(c1), ec1, lM1N(c0, c1, c2)))
def pd3({NP}) -> {{O.padd(S2(N0, N1), N2) == S3(N0, N1, N2) : U32}}:
  VE.padd_ok(S2(N0, N1), N2, VE.winit(31n, VE.bits32(S2(N0, N1))), VE.winit(31n, VE.bits32(N2)), ltN({NA}, S2(N0, N1), Q2(c0, c1), eS2({NA}), Order.below_sum(Q2(c0, c1), M2(c2))), ltN({NA}, N2, M2(c2), ec2, lM2N(c0, c1, c2)))
''')
    # ---- the output trees ----
    LAY = [('D1', 'v', '[356]', '2n', None), ('D2', 'm', 'VC.NW(N0)', '89n', 'T0'), ('D3', 'v', '[S1(N0)]', '3n', None),
           ('D4', 'm', 'VC.NW(N1)', 'Q1(c0)', 'T1'), ('D5', 'v', '[S2(N0, N1)]', '4n', None), ('D6', 'm', 'VC.NW(N2)', 'Q2(c0, c1)', 'T2'),
           ('D7', 'v', wl(HW), '5n', None), ('D8', 'v', wl(PW), '57n', None), ('D9', 'v', '[i0, i1]', '0n', None)]
    w('\n# ---- the output trees ------------------------------------------------------------------------\n')
    w(f'def ZD({DP}) -> {TR}: VC.ZT({DOe})')
    w(f'def pfZD({DP}) -> {{FD.array__perfect(U32, {DOe}, ZD({DA})) == {TRUE}}}: FD.array__trep_perfect(U32, {DOe}, 0)')
    prev = 'ZD'
    for n, k, V, j, src in LAY:
        if k == 'v':
            w(f'def {n}({DP}) -> {TR}: VF.updv({V}, {DOe}, {prev}({DA}), {j})')
            w(f'def pf{n}({DP}) -> {{FD.array__perfect(U32, {DOe}, {n}({DA})) == {TRUE}}}: VF.updv_perfect({V}, {DOe}, {prev}({DA}), {j}, pf{prev}({DA}))')
        else:
            w(f'def {n}({DP}) -> {TR}: VB.mone({V}, 0n, {j}, {DOe}, {prev}({DA}), {src})')
            w(f'def pf{n}({DP}) -> {{FD.array__perfect(U32, {DOe}, {n}({DA})) == {TRUE}}}: VB.mone_perfect({V}, 0n, {j}, {DOe}, {prev}({DA}), {src}, pf{prev}({DA}))')
        prev = n
    return W, LAY, dict(NP=NP, NA=NA, DP=DP, DA=DA, HP=HP, HA=HA, ALLP=ALLP, ALLA=ALLA, OE=OE, HR=HR, DOe=DOe)


def put_text(P, LAY):
    """The encoder's evaluation: size_eval, the writes, put_eval, encode_eval."""
    NP, NA, DP, DA, ALLP, ALLA, OE, HR, DOe = (P[k] for k in ('NP', 'NA', 'DP', 'DA', 'ALLP', 'ALLA', 'OE', 'HR', 'DOe'))
    TRUE = 'True{} : Bool'
    W = []
    w = W.append
    TH = lambda n: f'FD.array__thaw(U32, {n}({DA}))'
    W0 = 'O.Words{FD.array__thaw(U32, T0), N0}'
    W1 = 'O.Words{FD.array__thaw(U32, T1), N1}'
    W2 = 'O.Words{FD.array__thaw(U32, T2), N2}'
    WP = 'O.Words{FD.array__thaw(U32, TP), 128}'
    HB = f'O.BSome{{{HR}, O.BNone{{}}}}'
    U = 'O.U64{i0, i1}'
    S1, S2, S3 = 'S1(N0)', 'S2(N0, N1)', 'S3(N0, N1, N2)'
    # ---- the proof vector's word copy ----
    w('\n# ---- the inclusion proof: 32 words from TP to word 57 -------------------------------------------\n')
    for k in reversed(range(32)):
        rest = '[' + ', '.join(f'VB.slot(TP, {j}n)' for j in range(k, 32)) + ']'
        RHS = f'(FD.array__thaw(U32, VF.updv({rest}, dd, X, {57 + k}n)), FD.array__thaw(U32, TP))'
        ST = f'Equal.sym(Array<U32>, Array.set(U32, FD.array__thaw(U32, X), {57 + k}, VB.slot(TP, {k}n)), FD.array__thaw(U32, FD.array__upd(U32, dd, X, {57 + k}n, VB.slot(TP, {k}n))), VB.set_n(dd, X, {57 + k}, {57 + k}n, VB.slot(TP, {k}n), {{==}}, hd32, FD.nat__lt_le_trans({57 + k}n, 89n, VB.pw(dd), {{==}}, h89), pfX))'
        head = (f'def pa{k}(+dd: Nat, +X: {TR}, +TP: {TR}, +dp: Nat, +pfX: {{FD.array__perfect(U32, dd, X) == {TRUE}}}, +hd32: {{Nat.is_lt(dd, 32n) == {TRUE}}},\n'
                f'    +h89: {{Nat.is_le(89n, VB.pw(dd)) == {TRUE}}}, +pfP: {{FD.array__perfect(U32, dp, TP) == {TRUE}}}, +hdp32: {{Nat.is_lt(dp, 32n) == {TRUE}}}, +hrP: {{Nat.is_le(32n, VB.pw(dp)) == {TRUE}}})\n'
                f'    -> {{T.v4_b32_pa{k}(57, FD.array__thaw(U32, X), (FD.array__thaw(U32, TP), VB.slot(TP, {k}n))) == {RHS} : Array<U32> & Array<U32>}}:')
        if k == 31:
            w(head + f'\n  %{ST} :\n    {{(_, FD.array__thaw(U32, TP)) == {RHS} : Array<U32> & Array<U32>}}\n  {{==}}\n')
        else:
            X1 = f'FD.array__upd(U32, dd, X, {57 + k}n, VB.slot(TP, {k}n))'
            w(head + f'''
  %{ST} :
    {{T.v4_b32_pa{k + 1}(57, _, Array.get(U32, FD.array__thaw(U32, TP), {k + 1})) == {RHS} : Array<U32> & Array<U32>}}
  %Equal.sym(Array<U32> & U32, Array.get(U32, FD.array__thaw(U32, TP), {k + 1}), (FD.array__thaw(U32, TP), VB.slot(TP, {k + 1}n)), VB.get_n(dp, TP, {k + 1}, {k + 1}n, {{==}}, hdp32, FD.nat__lt_le_trans({k + 1}n, 32n, VB.pw(dp), {{==}}, hrP), pfP)) :
    {{T.v4_b32_pa{k + 1}(57, FD.array__thaw(U32, {X1}), _) == {RHS} : Array<U32> & Array<U32>}}
  pa{k + 1}(dd, {X1}, TP, dp, FD.array__upd_perfect(U32, dd, X, {57 + k}n, VB.slot(TP, {k}n), pfX), hd32, h89, pfP, hdp32, hrP)
''')
    NH = f'{NA}'
    w(f'''
def pvP({ALLP})
    -> {{T.v4_b32_putk({TH("D7")}, 228, {WP}) == ({TH("D8")}, ({WP}, 0)) : Array<U32> & (O.Words & U32)}}:
  +RHS = ({TH("D8")}, ({WP}, 0))
  %Equal.sym(O.Words & Bool, O.words_ok({WP}, 128, 128, False{{}}, 32), ({WP}, True{{}}), VME.words_okg(dp, TP, 128, 128, 128, 32, pfP, hdp, {{==}}, {{==}}, {{==}}, {{==}}, hrP)) :
    {{T.v4_b32_pk({TH("D7")}, 228, _) == RHS : Array<U32> & (O.Words & U32)}}
  %Equal.sym(Array<U32> & U32, Array.get(U32, FD.array__thaw(U32, TP), 0), (FD.array__thaw(U32, TP), VB.slot(TP, 0n)), VB.get_n(dp, TP, 0, 0n, {{==}}, VB.lt32(dp, hdp), FD.nat__lt_le_trans(0n, 32n, VB.pw(dp), {{==}}, hrP), pfP)) :
    {{T.v4_b32_pk_ok(T.v4_b32_pal(128, T.v4_b32_pa0(57, {TH("D7")}, _))) == RHS : Array<U32> & (O.Words & U32)}}
  %Equal.sym(Array<U32> & Array<U32>, T.v4_b32_pa0(57, {TH("D7")}, (FD.array__thaw(U32, TP), VB.slot(TP, 0n))), ({TH("D8")}, FD.array__thaw(U32, TP)),
      pa0({DOe}, D7({DA}), TP, dp, pfD7({DA}), hDO32({NH}), l89P({NH}), pfP, VB.lt32(dp, hdp), hrP)) :
    {{T.v4_b32_pk_ok(T.v4_b32_pal(128, _)) == RHS : Array<U32> & (O.Words & U32)}}
  {{==}}
''')
    # ---- the lists' writes ----
    LST = [dict(k=0, T='T0', N='N0', c='c0', W=W0, pre='ZD', mid='D1', out='D2', hoff=8, cur='356', curN=None, word=2, hi=8388608, E=512, B=2048,
                Mx='MX0()', cH='cH0()', P='89n', eP='{==}', hp3='{==}', pd='pd1', nxt=S1, pf='pf0', hdw='hdw0', hr='hr0', hdst='hdst0', putv='l4096_b2048_putv', v='DC.v2048()'),
           dict(k=1, T='T1', N='N1', c='c1', W=W1, pre='D2', mid='D3', out='D4', hoff=12, cur=S1, curN='Q1(c0)', word=3, hi=196608, E=12, B=48,
                Mx='MX1()', cH='cH1()', P='Q1(c0)', eP=f'VM.shr_q({S1}, Q1(c0), eS1({NH}))', hp3=f'VL.and3_q({S1}, Q1(c0), eS1({NH}))', pd='pd2', nxt=S2,
                pf='pf1', hdw='hdw1', hr='hr1', hdst='hdst1', putv='l4096_b48_putv', v='DC.v48()'),
           dict(k=2, T='T2', N='N2', c='c2', W=W2, pre='D4', mid='D5', out='D6', hoff=16, cur=S2, curN='Q2(c0, c1)', word=4, hi=196608, E=12, B=48,
                Mx='MX1()', cH='cH1()', P='Q2(c0, c1)', eP=f'VM.shr_q({S2}, Q2(c0, c1), eS2({NH}))', hp3=f'VL.and3_q({S2}, Q2(c0, c1), eS2({NH}))', pd='pd3', nxt=S3,
                pf='pf2', hdw='hdw2', hr='hr2', hdst='hdst2', putv='l4096_b48_putv', v='DC.v48()')]
    for L in LST:
        k, N, c = L['k'], L['N'], L['c']
        M = f'M{k}({c})'
        pfx = L['putv'].replace('_putv', '')
        RHS = f'({TH(L["out"])}, ({L["W"]}, {L["nxt"]}))'
        cur = L['cur']
        zero = '' if k == 0 else f'''
  %Equal.sym(U32, U32.add(0, {cur}), {cur}, FD.u32alg__zero_add({cur})) :
    {{T.{pfx}_pvb({cur}, T.{pfx}_putk({TH(L["mid"])}, _, {L["W"]})) == RHS : Array<U32> & (O.Words & U32)}}'''
        w(f'''
def hhi{k}({NP}) -> {{U32.is_le({N}, {L["hi"]}) == {TRUE}}}:
  VE.le_hi({N}, {L["hi"]}, FD.logic__subst(Nat, z => {{Nat.is_le(z, U32.to_nat({L["hi"]})) == {TRUE}}}, A.quad({M}), U32.to_nat({N}), Equal.sym(Nat, U32.to_nat({N}), A.quad({M}), ec{k}),
    FD.nat__le_trans(A.quad({M}), A.quad({L["Mx"]}), U32.to_nat({L["hi"]}), VME.quad_mono({M}, {L["Mx"]}, VME.mulE_mono({L["E"]}n, {c}, U32.to_nat(4096), hc{k})), {L["cH"]})))
def hu{k}({NP}) -> {{O.unit_ok({L["B"]}, {N}) == {TRUE}}}:
  VME.mod0({N}, {L["B"]}, {L["v"]}, {{==}}, {{==}}, {{==}}, {c}, Equal.trans(Nat, U32.to_nat({N}), A.quad({M}), Nat.mul({c}, U32.to_nat({L["B"]})), ec{k}, Equal.sym(Nat, Nat.mul({c}, A.quad({L["E"]}n)), A.quad({M}), VM.mulq({c}, {L["E"]}n))))

def pv{k}({ALLP})
    -> {{T.{L["putv"]}({TH(L["pre"])}, 0, {L["hoff"]}, {cur}, {L["W"]}) == {RHS} : Array<U32> & (O.Words & U32)}}:
  +RHS = {RHS}
  %Equal.sym(Array<U32>, Array.set(U32, {TH(L["pre"])}, {L["word"]}, {cur}), FD.array__thaw(U32, FD.array__upd(U32, {DOe}, {L["pre"]}({DA}), {L["word"]}n, {cur})),
      VB.set_n({DOe}, {L["pre"]}({DA}), {L["word"]}, {L["word"]}n, {cur}, {{==}}, hDO32({NH}), ltP({NH}, {L["word"]}n, {{==}}), pf{L["pre"]}({DA}))) :
    {{T.{pfx}_pvb({cur}, T.{pfx}_putk(_, U32.add(0, {cur}), {L["W"]})) == RHS : Array<U32> & (O.Words & U32)}}{zero}
  %Equal.sym(O.Words & Bool, O.words_ok({L["W"]}, 0, {L["hi"]}, False{{}}, {L["B"]}), ({L["W"]}, True{{}}),
      VME.words_okg({L["hdw"].replace("hdw", "dw")}, {L["T"]}, {N}, 0, {L["hi"]}, {L["B"]}, {L["pf"]}, {L["hdw"]}, VE.le0({N}), hhi{k}({NH}), hu{k}({NH}), VL.and3_q({N}, {M}, ec{k}), {L["hr"]})) :
    {{T.{pfx}_pvb({cur}, T.{pfx}_pk({TH(L["mid"])}, {cur}, _)) == RHS : Array<U32> & (O.Words & U32)}}
  %Equal.sym(Array<U32> & O.Words, O.put_words({TH(L["mid"])}, {cur}, {L["W"]}), ({TH(L["out"])}, {L["W"]}),
      VE.put_words_ok({DOe}, {L["hdw"].replace("hdw", "dw")}, {L["mid"]}({DA}), {L["T"]}, {cur}, {L["P"]}, {N}, pf{L["mid"]}({DA}), {L["pf"]}, hDO31({NH}), {L["hdw"]}, {L["hp3"]}, {L["eP"]}, VL.and3_q({N}, {M}, ec{k}), {L["hr"]}, {L["hdst"]}({NH}))) :
    {{T.{pfx}_pvb({cur}, O.pwn(_)) == RHS : Array<U32> & (O.Words & U32)}}
  %Equal.sym(U32, O.padd({cur}, {N}), {L["nxt"]}, {L["pd"]}({NH})) :
    {{({TH(L["out"])}, ({L["W"]}, _)) == RHS : Array<U32> & (O.Words & U32)}}
  {{==}}
''')
    # ---- the whole write ----
    RT = f'Array<U32> & (T.{X} & U32)'
    RHS = f'({TH("D9")}, ({OE}, {S3}))'
    OR1 = f'U32.or({S3}, 0)'
    w(f'''
def put_eval({ALLP})
    -> {{T.{X}_putn({TH("ZD")}, 0, {OE}) == {RHS} : {RT}}}:
  +RHS = {RHS}
  %Equal.sym({RT.replace(f"T.{X} & U32", "O.Words & U32")}, T.l4096_b2048_putv({TH("ZD")}, 0, 8, 356, {W0}), ({TH("D2")}, ({W0}, {S1})), pv0({ALLA})) :
    {{T.{X}_pw0(0, {U}, {W1}, {W2}, {HB}, {WP}, _) == RHS : {RT}}}
  %Equal.sym(Array<U32> & (O.Words & U32), T.l4096_b48_putv({TH("D2")}, 0, 12, {S1}, {W1}), ({TH("D4")}, ({W1}, {S2})), pv1({ALLA})) :
    {{T.{X}_pw1(0, {U}, {W0}, {W2}, {HB}, {WP}, _) == RHS : {RT}}}
  %Equal.sym(Array<U32> & (O.Words & U32), T.l4096_b48_putv({TH("D4")}, 0, 16, {S2}, {W2}), ({TH("D6")}, ({W2}, {S3})), pv2({ALLA})) :
    {{T.{X}_pw2(0, {U}, {W0}, {W1}, {HB}, {WP}, _) == RHS : {RT}}}
  %Equal.sym(Array<U32>, T.SignedBeaconBlockHeader_put({TH("D6")}, 20, {HR}), {TH("D7")},
      VT.put_SignedBeaconBlockHeader({DOe}, D6({DA}), 20, 5n, {{==}}, hDO29({NH}), pfD6({DA}), lkP({NH}, 57n, {{==}}), {", ".join(f"h{j}" for j in range(52))})) :
    {{T.{X}_pw3(0, {S3}, {U}, {W0}, {W1}, {W2}, {WP}, (_, ({HB}, 0))) == RHS : {RT}}}
  %Equal.sym(Array<U32> & (O.Words & U32), T.v4_b32_putk({TH("D7")}, 228, {WP}), ({TH("D8")}, ({WP}, 0)), pvP({ALLA})) :
    {{T.{X}_pw4(0, {OR1}, {U}, {W0}, {W1}, {W2}, {HB}, _) == RHS : {RT}}}
  %Equal.sym(Array<U32>, T.u64_put({TH("D8")}, 0, {U}), {TH("D9")}, VT.put_u64({DOe}, D8({DA}), 0, 0n, {{==}}, hDO29({NH}), pfD8({DA}), lkP({NH}, 2n, {{==}}), i0, i1)) :
    {{(_, ({OE}, U32.or({OR1}, 0))) == RHS : {RT}}}
  %Equal.sym(U32, U32.or({OR1}, U32{{Word.zero(32n)}}), {OR1}, VE.or_zero_u({OR1})) :
    {{({TH("D9")}, ({OE}, _)) == RHS : {RT}}}
  %Equal.sym(U32, U32.or({S3}, U32{{Word.zero(32n)}}), {S3}, VE.or_zero_u({S3})) :
    {{({TH("D9")}, ({OE}, _)) == RHS : {RT}}}
  {{==}}

def size_eval({ALLP})
    -> {{T.{X}_size({OE}) == ({OE}, {S3}) : T.{X} & U32}}:
  +RHS = ({OE}, {S3})
  %Equal.sym(Array<U32> & U32, Array.size(U32, FD.array__thaw(U32, T0)), (FD.array__thaw(U32, T0), FD.u32__pow2u(dw0)), FD.array__size_thaw(U32, dw0, T0, pf0)) :
    {{T.{X}_sz0({U}, {W1}, {W2}, {HB}, {WP}, 356, O.wsz_pick(N0, _)) == RHS : T.{X} & U32}}
  %Equal.sym(Bool, U32.is_le(VC.nwu(N0), FD.u32__pow2u(dw0)), True{{}}, VE.le_room(N0, dw0, hdw0, hr0)) :
    {{T.{X}_sz0({U}, {W1}, {W2}, {HB}, {WP}, 356, ({W0}, O.pick(_, N0, 2147483648))) == RHS : T.{X} & U32}}
  %Equal.sym(U32, O.padd(356, N0), {S1}, pd1({NH})) :
    {{T.{X}_sz1({U}, {W2}, {HB}, {WP}, {W0}, _, T.l4096_b48_size({W1})) == RHS : T.{X} & U32}}
  %Equal.sym(Array<U32> & U32, Array.size(U32, FD.array__thaw(U32, T1)), (FD.array__thaw(U32, T1), FD.u32__pow2u(dw1)), FD.array__size_thaw(U32, dw1, T1, pf1)) :
    {{T.{X}_sz1({U}, {W2}, {HB}, {WP}, {W0}, {S1}, O.wsz_pick(N1, _)) == RHS : T.{X} & U32}}
  %Equal.sym(Bool, U32.is_le(VC.nwu(N1), FD.u32__pow2u(dw1)), True{{}}, VE.le_room(N1, dw1, hdw1, hr1)) :
    {{T.{X}_sz1({U}, {W2}, {HB}, {WP}, {W0}, {S1}, ({W1}, O.pick(_, N1, 2147483648))) == RHS : T.{X} & U32}}
  %Equal.sym(U32, O.padd({S1}, N1), {S2}, pd2({NH})) :
    {{T.{X}_sz2({U}, {HB}, {WP}, {W0}, {W1}, _, T.l4096_b48_size({W2})) == RHS : T.{X} & U32}}
  %Equal.sym(Array<U32> & U32, Array.size(U32, FD.array__thaw(U32, T2)), (FD.array__thaw(U32, T2), FD.u32__pow2u(dw2)), FD.array__size_thaw(U32, dw2, T2, pf2)) :
    {{T.{X}_sz2({U}, {HB}, {WP}, {W0}, {W1}, {S2}, O.wsz_pick(N2, _)) == RHS : T.{X} & U32}}
  %Equal.sym(Bool, U32.is_le(VC.nwu(N2), FD.u32__pow2u(dw2)), True{{}}, VE.le_room(N2, dw2, hdw2, hr2)) :
    {{T.{X}_sz2({U}, {HB}, {WP}, {W0}, {W1}, {S2}, ({W2}, O.pick(_, N2, 2147483648))) == RHS : T.{X} & U32}}
  %Equal.sym(U32, O.padd({S2}, N2), {S3}, pd3({NH})) :
    {{({OE}, _) == RHS : T.{X} & U32}}
  {{==}}

# The encoder returns the object and the buffer of D9, S3 bytes.
def encode_eval({ALLP})
    -> {{T.{X}_encode({OE}) == ({OE}, B.Buf{{{TH("D9")}, {S3}}}) : T.{X} & B.Buf}}:
  +RHS = ({OE}, B.Buf{{{TH("D9")}, {S3}}})
  %Equal.sym(T.{X} & U32, T.{X}_size({OE}), ({OE}, {S3}), size_eval({ALLA})) :
    {{T.{X}_enc_sized(_) == RHS : T.{X} & B.Buf}}
  %Equal.sym(Array<U32>, B.zeros(B.words_depth_u(VC.nwu({S3}))), Array.new(U32, {DOe}, 0), VZ.zat(B.words_depth_u(VC.nwu({S3})), {DOe}, VD.wdu(VC.nwu({S3})), hDO({NH}))) :
    {{T.{X}_enc_put({S3}, T.{X}_putn(_, 0, {OE})) == RHS : T.{X} & B.Buf}}
  %Equal.sym(Array<U32>, Array.new(U32, {DOe}, 0), FD.array__thaw(U32, VC.ZT({DOe})), FD.array__new(U32, {DOe}, 0)) :
    {{T.{X}_enc_put({S3}, T.{X}_putn(_, 0, {OE})) == RHS : T.{X} & B.Buf}}
  %Equal.sym({RT}, T.{X}_putn({TH("ZD")}, 0, {OE}), ({TH("D9")}, ({OE}, {S3})), put_eval({ALLA})) :
    {{T.{X}_enc_put({S3}, _) == RHS : T.{X} & B.Buf}}
  {{==}}
''')
    return [inline_rhs(b) for b in W]


def inline_rhs(block):
    """Replace a `+RHS = X` let (lets of pairs need annotations) by X."""
    out, rhs = [], None
    for line in block.split('\n'):
        if line.startswith('  +RHS = '):
            rhs = line[len('  +RHS = '):]
            continue
        if line.startswith('def '):
            rhs = None
        if rhs is not None:
            line = line.replace(' == RHS :', f' == {rhs} :')
        out.append(line)
    return '\n'.join(out)
