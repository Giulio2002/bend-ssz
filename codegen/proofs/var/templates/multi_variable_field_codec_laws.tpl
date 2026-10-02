@@ DEC_BODY @@
def BF(t: FD.array__Tree<U32>, +n: U32) -> B.Buf: B.Buf{FD.array__thaw(U32, t), n}

def rd32(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +q: U32, +i: Nat, +eq: {U32.to_nat(q) == i : Nat},
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hi: {Nat.is_lt(i, VB.pw(d)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {B.word(BF(t, n), q) == (BF(t, n), VB.slot(t, i)) : B.Buf & U32}:
  %Equal.sym(Array<U32> & U32, Array.get(U32, FD.array__thaw(U32, t), q), (FD.array__thaw(U32, t), VB.slot(t, i)), VB.get_n(d, t, q, i, eq, hd, hi, pf)) :
    {B.rewrap(n, _) == (BF(t, n), VB.slot(t, i)) : B.Buf & U32}
  {==}

# ---- the validator ----------------------------------------------------------------------------

# the three list offsets
def O0(t: FD.array__Tree<U32>) -> U32: VB.slot(t, 2n)
def O1(t: FD.array__Tree<U32>) -> U32: VB.slot(t, 3n)
def O2(t: FD.array__Tree<U32>) -> U32: VB.slot(t, 4n)

# a list of whole elements of b bytes, at most lim of them
def WH(+L: U32, +b: U32, +lim: U32) -> Bool: Bool.and(U32.is_eq(L, (U32.div(L, b) * b : U32)), U32.is_le(U32.div(L, b), lim))

def L0(+t: FD.array__Tree<U32>) -> U32: U32.sub(O1(t), O0(t))
def L1(+t: FD.array__Tree<U32>) -> U32: U32.sub(O2(t), O1(t))
def L2(+t: FD.array__Tree<U32>, +n: U32) -> U32: U32.sub(n, O2(t))

def CA(+n: U32) -> Bool: U32.is_le(356, n)
def CB(+t: FD.array__Tree<U32>) -> Bool: U32.is_eq(O0(t), 356)
def CC(+t: FD.array__Tree<U32>, +n: U32) -> Bool: Bool.and(U32.is_le(O0(t), O1(t)), U32.is_le(O1(t), n))
def CD(+t: FD.array__Tree<U32>, +n: U32) -> Bool: Bool.and(U32.is_le(O1(t), O2(t)), U32.is_le(O2(t), n))
def CE(+t: FD.array__Tree<U32>) -> Bool: WH(L0(t), 2048, 4096)
def CF(+t: FD.array__Tree<U32>) -> Bool: WH(L1(t), 48, 4096)
def CG(+t: FD.array__Tree<U32>, +n: U32) -> Bool: WH(L2(t, n), 48, 4096)

# the checks, in the validator's order
def CHK(+t: FD.array__Tree<U32>, +n: U32) -> Bool:
  Bool.and(CA(n), Bool.and(CB(t), Bool.and(CC(t, n), Bool.and(CD(t, n), Bool.and(CE(t), Bool.and(CF(t), CG(t, n)))))))

def okG(+t: FD.array__Tree<U32>, +n: U32, +g: Bool)
    -> {T.DataColumnSidecar_c5(g, BF(t, n), 0, n, O0(t), O1(t), O2(t)) == (BF(t, n), g) : B.Buf & Bool}:
  match g:
    case True{}: {==}
    case False{}: {==}

def okF(+t: FD.array__Tree<U32>, +n: U32, +f: Bool)
    -> {T.DataColumnSidecar_c4(f, BF(t, n), 0, n, O0(t), O1(t), O2(t)) == (BF(t, n), Bool.and(f, CG(t, n))) : B.Buf & Bool}:
  match f:
    case True{}: okG(t, n, CG(t, n))
    case False{}: {==}

def okE(+t: FD.array__Tree<U32>, +n: U32, +e: Bool)
    -> {T.DataColumnSidecar_c3(e, BF(t, n), 0, n, O0(t), O1(t), O2(t)) == (BF(t, n), Bool.and(e, Bool.and(CF(t), CG(t, n)))) : B.Buf & Bool}:
  match e:
    case True{}: okF(t, n, CF(t))
    case False{}: {==}

def okD(+t: FD.array__Tree<U32>, +n: U32, +c: Bool)
    -> {T.DataColumnSidecar_c2(c, BF(t, n), 0, n, O0(t), O1(t), O2(t)) == (BF(t, n), Bool.and(c, Bool.and(CE(t), Bool.and(CF(t), CG(t, n))))) : B.Buf & Bool}:
  match c:
    case True{}: okE(t, n, CE(t))
    case False{}: {==}

def okC(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +c: Bool,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hpo: {Nat.is_lt(4n, VB.pw(d)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {T.DataColumnSidecar_c1(c, BF(t, n), 0, n, O0(t), O1(t)) == (BF(t, n), Bool.and(c, Bool.and(CD(t, n), Bool.and(CE(t), Bool.and(CF(t), CG(t, n)))))) : B.Buf & Bool}:
  match c:
    case True{}:
      %Equal.sym(B.Buf & U32, B.word(BF(t, n), 4), (BF(t, n), O2(t)), rd32(d, t, n, 4, 4n, {==}, hd, hpo, pf)) :
        {T.DataColumnSidecar_v2(0, n, O0(t), O1(t), _) == (BF(t, n), Bool.and(CD(t, n), Bool.and(CE(t), Bool.and(CF(t), CG(t, n))))) : B.Buf & Bool}
      okD(t, n, CD(t, n))
    case False{}: {==}

def okB(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +b: Bool,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hpo: {Nat.is_lt(4n, VB.pw(d)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {T.DataColumnSidecar_c0(b, BF(t, n), 0, n, O0(t)) == (BF(t, n), Bool.and(b, Bool.and(CC(t, n), Bool.and(CD(t, n), Bool.and(CE(t), Bool.and(CF(t), CG(t, n))))))) : B.Buf & Bool}:
  match b:
    case True{}:
      %Equal.sym(B.Buf & U32, B.word(BF(t, n), 3), (BF(t, n), O1(t)), rd32(d, t, n, 3, 3n, {==}, hd, FD.nat__lt_trans(3n, 4n, VB.pw(d), {==}, hpo), pf)) :
        {T.DataColumnSidecar_v1(0, n, O0(t), _) == (BF(t, n), Bool.and(CC(t, n), Bool.and(CD(t, n), Bool.and(CE(t), Bool.and(CF(t), CG(t, n)))))) : B.Buf & Bool}
      okC(d, t, n, CC(t, n), hd, hpo, pf)
    case False{}: {==}

def okA(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +a: Bool,
    +hd: {Nat.is_lt(d, 32n) == True{} : Bool}, +hpo: {Nat.is_lt(4n, VB.pw(d)) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {T.DataColumnSidecar_ok_len(a, BF(t, n), 0, n) == (BF(t, n), Bool.and(a, Bool.and(CB(t), Bool.and(CC(t, n), Bool.and(CD(t, n), Bool.and(CE(t), Bool.and(CF(t), CG(t, n)))))))) : B.Buf & Bool}:
  match a:
    case True{}:
      %Equal.sym(B.Buf & U32, B.word(BF(t, n), 2), (BF(t, n), O0(t)), rd32(d, t, n, 2, 2n, {==}, hd, FD.nat__lt_trans(2n, 4n, VB.pw(d), {==}, hpo), pf)) :
        {T.DataColumnSidecar_v0(0, n, _) == (BF(t, n), Bool.and(CB(t), Bool.and(CC(t, n), Bool.and(CD(t, n), Bool.and(CE(t), Bool.and(CF(t), CG(t, n))))))) : B.Buf & Bool}
      okB(d, t, n, CB(t), hd, hpo, pf)
    case False{}: {==}

# The validator returns the buffer and CHK(t, n).
law ok_eval:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +hd: {Nat.is_lt(d, 32n) == True{} : Bool}
  for +hpo: {Nat.is_lt(4n, VB.pw(d)) == True{} : Bool}
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  {T.DataColumnSidecar_ok(BF(t, n), 0, n) == (BF(t, n), CHK(t, n)) : B.Buf & Bool}
def ok_eval(d, t, n, hd, hpo, pf): okA(d, t, n, CA(n), hd, hpo, pf)

@@ acc_text @@

# ---- acceptance ---------------------------------------------------------------------------------

def v2048() -> Word(31n): FD.spec_numeric__from_nat(31n, 2048n)
def v48() -> Word(31n): FD.spec_numeric__from_nat(31n, 48n)

# the element counts, the lists' word counts, the lists' first words
def C0(+t: FD.array__Tree<U32>) -> Nat: U32.to_nat(U32.div(L0(t), 2048))
def C1(+t: FD.array__Tree<U32>) -> Nat: U32.to_nat(U32.div(L1(t), 48))
def C2(+t: FD.array__Tree<U32>, +n: U32) -> Nat: U32.to_nat(U32.div(L2(t, n), 48))
def M0(+t: FD.array__Tree<U32>) -> Nat: VM.mulE(512n, C0(t))
def M1(+t: FD.array__Tree<U32>) -> Nat: VM.mulE(12n, C1(t))
def M2(+t: FD.array__Tree<U32>, +n: U32) -> Nat: VM.mulE(12n, C2(t, n))
def Q1(+t: FD.array__Tree<U32>) -> Nat: Nat.add(89n, M0(t))
def Q2(+t: FD.array__Tree<U32>) -> Nat: Nat.add(Q1(t), M1(t))
def QN(+t: FD.array__Tree<U32>, +n: U32) -> Nat: Nat.add(Q2(t), M2(t, n))

def eL0(+t: FD.array__Tree<U32>, +h: {CE(t) == True{} : Bool}) -> {U32.to_nat(L0(t)) == A.quad(M0(t)) : Nat}:
  Equal.trans(Nat, U32.to_nat(L0(t)), Nat.mul(C0(t), U32.to_nat(2048)), A.quad(M0(t)),
    Pair.fst({U32.to_nat(L0(t)) == Nat.mul(C0(t), U32.to_nat(2048)) : Nat}, {Nat.is_le(C0(t), U32.to_nat(4096)) == True{} : Bool}, VU.whole_t(L0(t), 2048, 4096, v2048(), {==}, {==}, {==}, h)),
    VM.mulq(C0(t), 512n))

def eL1(+t: FD.array__Tree<U32>, +h: {CF(t) == True{} : Bool}) -> {U32.to_nat(L1(t)) == A.quad(M1(t)) : Nat}:
  Equal.trans(Nat, U32.to_nat(L1(t)), Nat.mul(C1(t), U32.to_nat(48)), A.quad(M1(t)),
    Pair.fst({U32.to_nat(L1(t)) == Nat.mul(C1(t), U32.to_nat(48)) : Nat}, {Nat.is_le(C1(t), U32.to_nat(4096)) == True{} : Bool}, VU.whole_t(L1(t), 48, 4096, v48(), {==}, {==}, {==}, h)),
    VM.mulq(C1(t), 12n))

def eL2(+t: FD.array__Tree<U32>, +n: U32, +h: {CG(t, n) == True{} : Bool}) -> {U32.to_nat(L2(t, n)) == A.quad(M2(t, n)) : Nat}:
  Equal.trans(Nat, U32.to_nat(L2(t, n)), Nat.mul(C2(t, n), U32.to_nat(48)), A.quad(M2(t, n)),
    Pair.fst({U32.to_nat(L2(t, n)) == Nat.mul(C2(t, n), U32.to_nat(48)) : Nat}, {Nat.is_le(C2(t, n), U32.to_nat(4096)) == True{} : Bool}, VU.whole_t(L2(t, n), 48, 4096, v48(), {==}, {==}, {==}, h)),
    VM.mulq(C2(t, n), 12n))

def eO1(+t: FD.array__Tree<U32>, +n: U32, +hb: {CB(t) == True{} : Bool}, +hc: {CC(t, n) == True{} : Bool}, +he: {CE(t) == True{} : Bool})
    -> {U32.to_nat(O1(t)) == A.quad(Q1(t)) : Nat}:
  +s = VM.sub_eq(O1(t), O0(t), FD.logic__and_left(U32.is_le(O0(t), O1(t)), U32.is_le(O1(t), n), hc))
  %s : {_ == A.quad(Q1(t)) : Nat}
  %Equal.sym(U32, O0(t), 356, FD.u32alg__eq_of(O0(t), 356, hb)) : {Nat.add(U32.to_nat(_), U32.to_nat(L0(t))) == A.quad(Q1(t)) : Nat}
  %Equal.sym(Nat, U32.to_nat(L0(t)), A.quad(M0(t)), eL0(t, he)) : {Nat.add(U32.to_nat(356), _) == A.quad(Q1(t)) : Nat}
  Equal.sym(Nat, A.quad(Q1(t)), Nat.add(A.quad(89n), A.quad(M0(t))), VM.quad_add(89n, M0(t)))

def eO2(+t: FD.array__Tree<U32>, +n: U32, +hb: {CB(t) == True{} : Bool}, +hc: {CC(t, n) == True{} : Bool}, +hdd: {CD(t, n) == True{} : Bool},
    +he: {CE(t) == True{} : Bool}, +hf: {CF(t) == True{} : Bool})
    -> {U32.to_nat(O2(t)) == A.quad(Q2(t)) : Nat}:
  +s = VM.sub_eq(O2(t), O1(t), FD.logic__and_left(U32.is_le(O1(t), O2(t)), U32.is_le(O2(t), n), hdd))
  %s : {_ == A.quad(Q2(t)) : Nat}
  %Equal.sym(Nat, U32.to_nat(O1(t)), A.quad(Q1(t)), eO1(t, n, hb, hc, he)) : {Nat.add(_, U32.to_nat(L1(t))) == A.quad(Q2(t)) : Nat}
  %Equal.sym(Nat, U32.to_nat(L1(t)), A.quad(M1(t)), eL1(t, hf)) : {Nat.add(A.quad(Q1(t)), _) == A.quad(Q2(t)) : Nat}
  Equal.sym(Nat, A.quad(Q2(t)), Nat.add(A.quad(Q1(t)), A.quad(M1(t))), VM.quad_add(Q1(t), M1(t)))

def eN(+t: FD.array__Tree<U32>, +n: U32, ${FACTS})
    -> {U32.to_nat(n) == A.quad(QN(t, n)) : Nat}:
  +s = VM.sub_eq(n, O2(t), FD.logic__and_right(U32.is_le(O1(t), O2(t)), U32.is_le(O2(t), n), hdd))
  %s : {_ == A.quad(QN(t, n)) : Nat}
  %Equal.sym(Nat, U32.to_nat(O2(t)), A.quad(Q2(t)), eO2(t, n, hb, hc, hdd, he, hf)) : {Nat.add(_, U32.to_nat(L2(t, n))) == A.quad(QN(t, n)) : Nat}
  %Equal.sym(Nat, U32.to_nat(L2(t, n)), A.quad(M2(t, n)), eL2(t, n, hg)) : {Nat.add(A.quad(Q2(t)), _) == A.quad(QN(t, n)) : Nat}
  Equal.sym(Nat, A.quad(QN(t, n)), Nat.add(A.quad(Q2(t)), A.quad(M2(t, n))), VM.quad_add(Q2(t), M2(t, n)))

# QN <= 2^d: the header and the three lists lie in the buffer
def hQN(${HY}, ${FACTS})
    -> {Nat.is_le(QN(t, n), VB.pw(d)) == True{} : Bool}:
  VC.quad_inv(QN(t, n), VB.pw(d), FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(n), A.quad(QN(t, n)), eN(t, n, ${FA}), hn))

# ---- the lists' storage from the buffer's size: n <= NMAX gives 31 + L <= UMAX for every list ----

def hnN(+n: U32, +hN: {U32.is_le(n, VB.NMAX()) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(n), U32.to_nat(VB.NMAX())) == True{} : Bool}:
  FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(n, VB.NMAX()), Nat.is_le(U32.to_nat(n), U32.to_nat(VB.NMAX())), VB.le_u32n(n, VB.NMAX()), hN)

# a list of quad(m) bytes, m <= Q, lies within the n = quad(Q) bytes of the buffer
def hLn(+n: U32, +L: U32, +m: Nat, +Q: Nat, +em: {U32.to_nat(L) == A.quad(m) : Nat}, +eN: {U32.to_nat(n) == A.quad(Q) : Nat}, +hm: {Nat.is_le(m, Q) == True{} : Bool})
    -> {Nat.is_le(Nat.add(0n, U32.to_nat(L)), U32.to_nat(n)) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(0n, z), U32.to_nat(n)) == True{} : Bool}, A.quad(m), U32.to_nat(L), Equal.sym(Nat, U32.to_nat(L), A.quad(m), em),
    FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(0n, A.quad(m)), z) == True{} : Bool}, A.quad(Q), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), A.quad(Q), eN),
      FD.nat__double_le(Nat.double(m), Nat.double(Q), FD.nat__double_le(m, Q, hm))))

def hy0(+t: FD.array__Tree<U32>, +n: U32, ${FACTS}, +hN: {U32.is_le(n, VB.NMAX()) == True{} : Bool})
    -> {Nat.is_le(VC.YL(L0(t)), U32.to_nat(VB.UMAX())) == True{} : Bool}:
  VC.hyW(0n, L0(t), FD.nat__le_trans(Nat.add(0n, U32.to_nat(L0(t))), U32.to_nat(n), U32.to_nat(VB.NMAX()),
    hLn(n, L0(t), M0(t), QN(t, n), eL0(t, he), eN(t, n, ${FA}),
      FD.nat__le_trans(M0(t), Q1(t), QN(t, n), Order.left_below_sum(89n, M0(t)), FD.nat__le_trans(Q1(t), Q2(t), QN(t, n), Order.below_sum(Q1(t), M1(t)), Order.below_sum(Q2(t), M2(t, n))))),
    hnN(n, hN)))

def hy1(+t: FD.array__Tree<U32>, +n: U32, ${FACTS}, +hN: {U32.is_le(n, VB.NMAX()) == True{} : Bool})
    -> {Nat.is_le(VC.YL(L1(t)), U32.to_nat(VB.UMAX())) == True{} : Bool}:
  VC.hyW(0n, L1(t), FD.nat__le_trans(Nat.add(0n, U32.to_nat(L1(t))), U32.to_nat(n), U32.to_nat(VB.NMAX()),
    hLn(n, L1(t), M1(t), QN(t, n), eL1(t, hf), eN(t, n, ${FA}),
      FD.nat__le_trans(M1(t), Q2(t), QN(t, n), Order.left_below_sum(Q1(t), M1(t)), Order.below_sum(Q2(t), M2(t, n)))),
    hnN(n, hN)))

def hy2(+t: FD.array__Tree<U32>, +n: U32, ${FACTS}, +hN: {U32.is_le(n, VB.NMAX()) == True{} : Bool})
    -> {Nat.is_le(VC.YL(L2(t, n)), U32.to_nat(VB.UMAX())) == True{} : Bool}:
  VC.hyW(0n, L2(t, n), FD.nat__le_trans(Nat.add(0n, U32.to_nat(L2(t, n))), U32.to_nat(n), U32.to_nat(VB.NMAX()),
    hLn(n, L2(t, n), M2(t, n), QN(t, n), eL2(t, n, hg), eN(t, n, ${FA}),
      Order.left_below_sum(Q2(t), M2(t, n))),
    hnN(n, hN)))

# the zero array of the list storage, at any depth
def ezd(+L: U32) -> {B.zeros(B.words_depth_u(VC.WZ(L))) == Array.new(U32, VL.DZ(L), 0) : Array<U32>}:
  FD.logic__subst(Nat, z => {B.zeros(B.words_depth_u(VC.WZ(L))) == Array.new(U32, z, 0) : Array<U32>}, U32.to_nat(B.words_depth_u(VC.WZ(L))), VL.DZ(L),
    VD.wdu(VC.WZ(L)), VZG.zg(B.words_depth_u(VC.WZ(L))))

# the list's words, from word q on, lie in the buffer
def hsgD(+d: Nat, +L: U32, +m: Nat, +q: Nat, +em: {U32.to_nat(L) == A.quad(m) : Nat}, +h: {Nat.is_le(Nat.add(q, m), VB.pw(d)) == True{} : Bool})
    -> {Nat.is_le(Nat.add(VC.NW(L), q), VB.pw(d)) == True{} : Bool}:
  %Equal.sym(Nat, VC.NW(L), m, VL.nwmA(L, m, em)) : {Nat.is_le(Nat.add(_, q), VB.pw(d)) == True{} : Bool}
  %FD.nat__add_comm(q, m) : {Nat.is_le(_, VB.pw(d)) == True{} : Bool}
  h

@@ unique_text @@
import Base
import ../../types/schema.bend as S
import ../../spec/decoding_relation.bend as Decoding
import ../../spec/fulu_schemas.bend as Spec
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ./vbuf.bend as VB
import ./var_codec_${X}.bend as DC
import ../../proofs/decode_unique.bend as DCO

# GENERATED by multi_variable_field_codec_laws (codegen). Do not edit.
# Every spec value of an accepted buffer's bytes is the buffer's value DC.VAL.
law decode_unique:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hN: {U32.is_le(n, VB.NMAX()) == True{} : Bool}
  for +hchk: {DC.CHK(t, n) == True{} : Bool}
  for +v: S.Value
  for spec: Decoding.decodes(Spec.${X}(), DC.VW(t, n), v)
  {v == DC.VAL(t, n) : S.Value}
def decode_unique(d, t, n, pf, hd, hn, hN, hchk, v, spec):
  DCO.valid_unique(Spec.${X}(), DC.VW(t, n), v, DC.VAL(t, n), {==}, spec,
    DC.decode_spec(d, t, n, pf, hd, hn, hN, hchk))

@@ rej_file @@

def fin(${CTXT}${acc_t(6)}, +b5: Bool,
    +e: {Codec.bytes(Codec.one(SP.optional(b5, VMR.OUTR(x0, y0, y1, y2, [xh, xp])), None{})) == Some{${VWt}} : Maybe<&2, +List<U32>>}) -> Empty:
  match b5:
    case False{}: ${NONE}
    case True{}: contra(${CTX}${acc_a(6)}, FD.logic__some_inj(+List<U32>, VMR.OUTR(x0, y0, y1, y2, [xh, xp]), ${VWt}, e))

@@ rej_file_2 @@

def inv_v(${CTXT}, +v: S.Value,
    +e: {Codec.encoding_for_legal_type(Spec.${X}(), v) == Some{${VWt}} : Maybe<&2, +List<U32>>}) -> Empty:
  match v:
${vcases}

# When the validator refuses, no value is related to the buffer's bytes.
law decode_reject:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hN: {U32.is_le(n, VB.NMAX()) == True{} : Bool}
  for +hchk: {DC.CHK(t, n) == False{} : Bool}
  Decoding.outside_image(Spec.${X}(), ${VWt})
def decode_reject(d, t, n, pf, hd, hn, hN, hchk):
  v => e => inv_v(${CTX}, v, e)

def none_go(${CTXT}, +a: Bool, +ea: {U32.is_le(356, n) == a : Bool})
    -> {T.${X}_decode(DC.BF(t, n), n) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, T.${X}>}:
  match a:
    case False{}:
      %Equal.sym(Bool, U32.is_le(356, n), False{}, ea) :
        {T.${X}_built(n, T.${X}_ok_len(_, DC.BF(t, n), 0, n)) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, T.${X}>}
      {==}
    case True{}:
      +hF2 = FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(356, n), Nat.is_le(356n, U32.to_nat(n)), VU.le_u32(356, n), ea)
      +h89 = VC.quad_inv(89n, VB.pw(d), FD.nat__le_trans(356n, U32.to_nat(n), A.quad(VB.pw(d)), hF2, hn))
      %Equal.sym(B.Buf & Bool, T.${X}_ok(DC.BF(t, n), 0, n), (DC.BF(t, n), DC.CHK(t, n)),
          DC.ok_eval(d, t, n, VB.lt32(d, hd), FD.nat__lt_le_trans(4n, 89n, VB.pw(d), {==}, h89), pf)) :
        {T.${X}_built(n, _) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, T.${X}>}
      %Equal.sym(Bool, DC.CHK(t, n), False{}, hchk) :
        {T.${X}_built(n, (DC.BF(t, n), _)) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, T.${X}>}
      {==}

# When the validator refuses, the decoder returns None and the buffer.
law decode_none:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 31n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hN: {U32.is_le(n, VB.NMAX()) == True{} : Bool}
  for +hchk: {DC.CHK(t, n) == False{} : Bool}
  {T.${X}_decode(DC.BF(t, n), n) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, T.${X}>}
def decode_none(d, t, n, pf, hd, hn, hN, hchk):
  none_go(${CTX}, U32.is_le(356, n), {==})
