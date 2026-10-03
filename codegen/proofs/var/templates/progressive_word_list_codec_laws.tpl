@@ elem_lib @@
law bq${E}:
  for +c: Nat
  {b${E}(c) == A.quad(w${E}(c)) : Nat}
def bq${E}(c):
  match c:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, b${E}(p), A.quad(w${E}(p)), bq${E}(p)) : {${B}n+_ == A.quad(${E}n+w${E}(p)) : Nat}
      {==}

law mulb${E}:
  for +c: Nat
  {Nat.mul(c, ${B}n) == b${E}(c) : Nat}
def mulb${E}(c):
  match c:
    case 0n: {==}
    case 1n+ +p:
      %Equal.sym(Nat, Nat.mul(p, ${B}n), b${E}(p), mulb${E}(p)) : {Nat.add(${B}n, _) == b${E}(1n+p) : Nat}
      {==}

# The progressive list of k elements over W is one variable part: the limbs of
# the first E k words of W.
def plenc${E}(+k: Nat, +W: List<&2, U32>, +hl: ${HL}, +fit: {N.fits(4n, b${E}(k)) == True{} : Bool})
    -> {Codec.bytes(Codec.parts(S.Sequence{it${E}(k, W)}, S.ProgressiveList{uS${E}()})) == Some{FX.limbs(VS.wtake(w${E}(k), W))} : Maybe<&2, +List<U32>>}:
  +G = gp${E}(k, W)
  +e1 = Equal.trans(Nat, List.length(&2, U32, FX.flat(G)), b${E}(nn${E}(k, W)), b${E}(k), lenflat${E}(k, W),
    Equal.cong(Nat, Nat, z => b${E}(z), nn${E}(k, W), k, neq${E}(k, W, hl)))
  +fit2 = F.logic__subst(Nat, z => {N.fits(4n, z) == True{} : Bool}, b${E}(k), List.length(&2, U32, FX.flat(G)), Equal.sym(Nat, List.length(&2, U32, FX.flat(G)), b${E}(k), e1), fit)
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(it${E}(k, W), S.Repeat{uS${E}()}), Some{FX.fparts(G)}, parts${E}(k, W)) :
    {Codec.bytes(Codec.aggregate(_, None{})) == Some{FX.limbs(VS.wtake(w${E}(k), W))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding(FX.fparts(G)), Some{FX.flat(G)}, VS.encoding_fparts(G, fit2)) :
    {Codec.bytes(Codec.one(_, None{})) == Some{FX.limbs(VS.wtake(w${E}(k), W))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, FX.flat(G), FX.limbs(VS.wtake(w${E}(nn${E}(k, W)), W)), flat${E}(k, W)) :
    {Codec.bytes(Codec.one(Some{_}, None{})) == Some{FX.limbs(VS.wtake(w${E}(k), W))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Nat, nn${E}(k, W), k, neq${E}(k, W, hl)) :
    {Codec.bytes(Codec.one(Some{FX.limbs(VS.wtake(w${E}(_), W))}, None{})) == Some{FX.limbs(VS.wtake(w${E}(k), W))} : Maybe<&2, +List<U32>>}
  {==}

@@ elem_lib_2 @@
def ${R}(+its: S.Value, +ps: +List<S.Part>) -> Type:
  {VS.allfix(ps) == True{} : Bool} & {Layout.fixed_size(ps) == b${E}(Codec.count(its)) : Nat}

def rlen${E}(+P8: +List<U32>, +pb: +List<S.Part>, +t: S.Value, +l8: {List.length(&2, U32, P8) == ${B}n : Nat},
    +hs: {Layout.fixed_size(pb) == b${E}(Codec.count(t)) : Nat})
    -> {Nat.add(List.length(&2, U32, P8), Layout.fixed_size(pb)) == ${B}n+b${E}(Codec.count(t)) : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, P8), ${B}n, l8) : {Nat.add(_, Layout.fixed_size(pb)) == ${B}n+b${E}(Codec.count(t)) : Nat}
  %Equal.sym(Nat, Layout.fixed_size(pb), b${E}(Codec.count(t)), hs) : {${B}n+_ == ${B}n+b${E}(Codec.count(t)) : Nat}
  {==}

def rt2${E}(+P8: +List<U32>, +el: S.Value, +t: S.Value, +pb: +List<S.Part>, +l8: {List.length(&2, U32, P8) == ${B}n : Nat}, r: ${R}(t, pb))
    -> ${R}(S.Items{el, t}, S.Fixed{P8} <> pb):
  (+ha, +hs) = r
  (ha, rlen${E}(P8, pb, t, l8, hs))

def rt${E}(+P8: +List<U32>, +el: S.Value, +t: S.Value, +ps: +List<S.Part>, +mB: Maybe<&2, +List<S.Part>>,
    +eB: {Codec.parts(t, S.Repeat{uS${E}()}) == mB : Maybe<&2, +List<S.Part>>},
    +l8: {List.length(&2, U32, P8) == ${B}n : Nat},
    +e: {Codec.concatenate(Some{[S.Fixed{P8}]}, mB) == Some{ps} : Maybe<&2, +List<S.Part>>},
    ih: ${IH})
    -> ${R}(S.Items{el, t}, ps):
  match mB:
    case None{}: Empty.absurd(${R}(S.Items{el, t}, ps), F.logic__none_some(+List<S.Part>, ps, e))
    case Some{+pb}:
      +eps = F.logic__some_inj(+List<S.Part>, S.Fixed{P8} <> pb, ps, e)
      %Equal.sym(+List<S.Part>, ps, S.Fixed{P8} <> pb, Equal.sym(+List<S.Part>, S.Fixed{P8} <> pb, ps, eps)) : ${R}(S.Items{el, t}, _)
      rt2${E}(P8, el, t, pb, l8, ih(pb, eB))

def ru${E}(${', '.join(('+' + x + ': U32' for x in A8))}, +t: S.Value, +ps: +List<S.Part>, +b: Bool,
    +e: {Codec.concatenate(Codec.one(SP.optional(b, ${DIG}), Some{${B}n}), Codec.parts(t, S.Repeat{uS${E}()})) == Some{ps} : Maybe<&2, +List<S.Part>>},
    ih: ${IH})
    -> ${R}(S.Items{${UV8}, t}, ps):
  match b:
    case False{}: Empty.absurd(${R}(S.Items{${UV8}, t}, ps), F.logic__none_some(+List<S.Part>, ps, e))
    case True{}: rt${E}(${DIG}, ${UV8}, t, ps, Codec.parts(t, S.Repeat{uS${E}()}), {==}, {==}, e, ih)

@@ deep_helpers @@
# n <= NMAX: 31 + n <= UMAX (the decoder's list storage has depth at most 30, whatever the tree's depth).
def hyN(+n: U32, +hN: ${HNN}) -> ${HY}:
  VC.hyW(0n, n, FD.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(n, VB.NMAX()), Nat.is_le(U32.to_nat(n), U32.to_nat(VB.NMAX())), VB.le_u32n(n, VB.NMAX()), hN))

def nwmU(+n: U32, +m: Nat, +hy: ${HY}, +em: {U32.to_nat(n) == A.quad(m) : Nat}) -> {VC.NW(n) == m : Nat}:
  %Equal.sym(Nat, VC.NW(n), VD.s_rng(2n, 3n+U32.to_nat(n)), VC.eNWu(n, hy)) : {_ == m : Nat}
  %Equal.sym(Nat, U32.to_nat(n), A.quad(m), em) : {VD.s_rng(2n, 3n+_) == m : Nat}
  VL.rng2_q(m)

def hsgU(+d: Nat, +n: U32, +m: Nat, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hy: ${HY},
    +em: {U32.to_nat(n) == A.quad(m) : Nat}) -> {Nat.is_le(Nat.add(VC.NW(n), 0n), VB.pw(d)) == True{} : Bool}:
  %Equal.sym(Nat, Nat.add(VC.NW(n), 0n), VC.NW(n), FD.nat__add_zero(VC.NW(n))) : {Nat.is_le(_, VB.pw(d)) == True{} : Bool}
  %Equal.sym(Nat, VC.NW(n), m, nwmU(n, m, hy, em)) : {Nat.is_le(_, VB.pw(d)) == True{} : Bool}
  VC.quad_inv(m, VB.pw(d), FD.logic__subst(Nat, z => {Nat.is_le(z, A.quad(VB.pw(d))) == True{} : Bool}, U32.to_nat(n), A.quad(m), em, hn))


@@ dec_text @@
def BF(t: FD.array__Tree<U32>, +n: U32) -> B.Buf: B.Buf{FD.array__thaw(U32, t), n}
def CHK(+n: U32) -> Bool: Bool.and(U32.is_eq(n, U32.mul(U32.div(n, ${B}), ${B})), True{})
def vB() -> Word(31n): FD.spec_numeric__from_nat(31n, ${B}n)
def CQ(+n: U32) -> Nat: U32.to_nat(U32.div(n, ${B}))
def M(+n: U32) -> Nat: EL.w${E}(CQ(n))
def OBJ(+t: FD.array__Tree<U32>, +n: U32) -> O.Words: O.Words{FD.array__thaw(U32, VL.MMg(t, n)), n}
def VW(+t: FD.array__Tree<U32>, +n: U32) -> +List<U32>: VS.bt(U32.to_nat(n), FX.limbs(FD.array__slots(U32, t)))
def VAL(+t: FD.array__Tree<U32>, +n: U32) -> S.Value: S.Sequence{EL.it${E}(CQ(n), FD.array__slots(U32, VL.MMg(t, n)))}

# The validator returns the buffer and CHK(n): a whole number of elements.
law ok_eval:
  for +t: FD.array__Tree<U32>
  for +n: U32
  {T.${lp}_ok(BF(t, n), 0, n) == (BF(t, n), CHK(n)) : B.Buf & Bool}
def ok_eval(t, n): {==}

def eLc(+n: U32, +hc: {CHK(n) == True{} : Bool}) -> {U32.to_nat(n) == EL.b${E}(CQ(n)) : Nat}:
  Equal.trans(Nat, U32.to_nat(n), Nat.mul(CQ(n), U32.to_nat(${B})), EL.b${E}(CQ(n)), VL.whole_t1(n, ${B}, vB(), {==}, {==}, {==}, hc), EL.mulb${E}(CQ(n)))

def eq(+n: U32, +hc: {CHK(n) == True{} : Bool}) -> {U32.to_nat(n) == A.quad(M(n)) : Nat}:
  Equal.trans(Nat, U32.to_nat(n), EL.b${E}(CQ(n)), A.quad(M(n)), eLc(n, hc), EL.bq${E}(CQ(n)))

@@ dec_text_2 @@

def acc_go(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, ${HYP}, +hc: {CHK(n) == True{} : Bool})
    -> {${Tn}_decode(BF(t, n), n) == (BF(t, n), Some{OBJ(t, n)}) : ${DM}}:
  +hy = hyN(n, hN)
  +hz = VC.dz30(n, hy)
  +ez = FD.logic__subst(Nat, z => {B.zeros(B.words_depth_u(VC.WZ(n))) == Array.new(U32, z, 0) : Array<U32>}, U32.to_nat(B.words_depth_u(VC.WZ(n))), VL.DZ(n), VD.wdu(VC.WZ(n)), Z.zs(B.words_depth_u(VC.WZ(n))))
  %Equal.sym(Bool, CHK(n), True{}, hc) : {${Tn}_built(n, (BF(t, n), _)) == (BF(t, n), Some{OBJ(t, n)}) : ${DM}}
  %Equal.sym(B.Buf & O.Words, O.copy_in(BF(t, n), 0, n), (BF(t, n), OBJ(t, n)),
      VC.copy_in_ok(d, t, n, 0, 0n, n, VL.DZ(n), pf, hd, FD.nat__le_lt_trans(VL.DZ(n), 30n, 31n, hz, {==}), ez, {==}, {==},
        VL.and3_q(n, M(n), eq(n, hc)), hsgU(d, n, M(n), hn, hy, eq(n, hc)), VC.hrgU(n, hy))) :
    {${Tn}_some(_) == (BF(t, n), Some{OBJ(t, n)}) : ${DM}}
  {==}

# Every buffer the validator accepts decodes to OBJ(t, n), a copy of its words.
law decode_accept:
${chr(10).join(LAWHYP)}
  for +hchk: {CHK(n) == True{} : Bool}
  {${Tn}_decode(BF(t, n), n) == (BF(t, n), Some{OBJ(t, n)}) : ${DM}}
def decode_accept(d, t, n, pf, hd, hn, hN, hchk): acc_go(d, t, n, pf, hd, hn, hN, hchk)

def hl_mm(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +hy: {Nat.is_le(VC.YL(n), U32.to_nat(VB.UMAX())) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hc: {CHK(n) == True{} : Bool})
    -> {Nat.is_le(M(n), FD.spec_common__length(U32, FD.array__slots(U32, VL.MMg(t, n)))) == True{} : Bool}:
  %Equal.sym(Nat, FD.spec_common__length(U32, FD.array__slots(U32, VL.MMg(t, n))), VB.pw(VL.DZ(n)),
      FD.array__slots_length(U32, VL.DZ(n), VL.MMg(t, n), VB.mone_perfect(VC.NW(n), 0n, 0n, VL.DZ(n), VC.ZT(VL.DZ(n)), t, FD.array__trep_perfect(U32, VL.DZ(n), 0)))) :
    {Nat.is_le(M(n), _) == True{} : Bool}
  %nwmU(n, M(n), hy, eq(n, hc)) : {Nat.is_le(_, VB.pw(VL.DZ(n))) == True{} : Bool}
  FD.logic__subst(Nat, z => {Nat.is_le(z, VB.pw(VL.DZ(n))) == True{} : Bool}, Nat.add(VC.NW(n), 0n), VC.NW(n), FD.nat__add_zero(VC.NW(n)), VC.hrgU(n, hy))

# The bytes of every accepted buffer are the spec encoding of the decoded value.
law decode_spec:
${chr(10).join(LAWHYP)}
  for +hchk: {CHK(n) == True{} : Bool}
  Decoding.decodes(GS.${X}(), VW(t, n), VAL(t, n))
def decode_spec(d, t, n, pf, hd, hn, hN, hchk):
  +hy = hyN(n, hN)
  +W = FD.array__slots(U32, VL.MMg(t, n))
  +fit = FD.logic__subst(Nat, z => {N.fits(4n, z) == True{} : Bool}, U32.to_nat(n), EL.b${E}(CQ(n)), eLc(n, hchk), VL.hfitA(n))
  Equal.trans(Maybe<&2, +List<U32>>, Codec.encoding_for_legal_type(GS.${X}(), VAL(t, n)), Some{FX.limbs(VS.wtake(M(n), W))}, Some{VW(t, n)},
    EL.plenc${E}(CQ(n), W, hl_mm(d, t, n, hy, hn, hchk), fit),
    Equal.cong(+List<U32>, Maybe<&2, +List<U32>>, z => Some{z}, FX.limbs(VS.wtake(M(n), W)), VW(t, n), limU(d, t, n, M(n), pf, hn, hy, eq(n, hchk))))

@@ rej_text @@
def inv_m4(+its: S.Value, +bs: +List<U32>, +ps: +List<S.Part>, +em3: {Codec.parts(its, ${RE}) == Some{ps} : Maybe<&2, +List<S.Part>>},
    +m4: ${MB}, +em4: {Layout.encoding(ps) == m4 : ${MB}}, +e: {Codec.bytes(Codec.one(m4, None{})) == Some{bs} : ${MB}}) -> FACTS(bs):
  match m4:
    case None{}: Empty.absurd(FACTS(bs), FD.logic__none_some(+List<U32>, bs, e))
    case Some{+ys}:
      +lys = Equal.trans(Nat, List.length(&2, U32, ys), Layout.fixed_size(ps), EL.b${E}(Codec.count(its)),
        VS.enc_len(ps, ys, Pair.fst({VS.allfix(ps) == True{} : Bool}, {Layout.fixed_size(ps) == EL.b${E}(Codec.count(its)) : Nat}, EL.rep_facts${E}(its, ps, em3)), em4),
        Pair.snd({VS.allfix(ps) == True{} : Bool}, {Layout.fixed_size(ps) == EL.b${E}(Codec.count(its)) : Nat}, EL.rep_facts${E}(its, ps, em3)))
      (Codec.count(its), (FD.logic__subst(+List<U32>, z => {List.length(&2, U32, z) == EL.b${E}(Codec.count(its)) : Nat}, ys, bs, FD.logic__some_inj(+List<U32>, ys, bs, e), lys), {==}))

def inv_m(+its: S.Value, +bs: +List<U32>, +m3: Maybe<&2, +List<S.Part>>, +em3: {Codec.parts(its, ${RE}) == m3 : Maybe<&2, +List<S.Part>>},
    +e: {Codec.bytes(Codec.aggregate(m3, None{})) == Some{bs} : ${MB}}) -> FACTS(bs):
  match m3:
    case None{}: Empty.absurd(FACTS(bs), FD.logic__none_some(+List<U32>, bs, e))
    case Some{+ps}: inv_m4(its, bs, ps, em3, Layout.encoding(ps), {==}, e)

# Every byte string the spec relates to a value is a whole number of elements.
law inv_v:
  for +v: S.Value
  for +bs: +List<U32>
  for +e: {Codec.encoding_for_legal_type(GS.${X}(), v) == Some{bs} : ${MB}}
  FACTS(bs)
def inv_v(v, bs, e):
  match v:
@@ rej_text_2 @@

law len_eq:
  for +W: List<&2, U32>
  {List.length(&2, U32, W) == FD.spec_common__length(U32, W) : Nat}
def len_eq(W):
  match W:
    case Nil{}: {==}
    case Con{+h, +t}:
      %Equal.sym(Nat, List.length(&2, U32, t), FD.spec_common__length(U32, t), len_eq(t)) : {1n+_ == 1n+FD.spec_common__length(U32, t) : Nat}
      {==}

def SL(t: FD.array__Tree<U32>) -> List<&2, U32>: FD.array__slots(U32, t)

def lenS(+d: Nat, +t: FD.array__Tree<U32>, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {List.length(&2, U32, FX.limbs(SL(t))) == A.quad(VB.pw(d)) : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, FX.limbs(SL(t))), FX.wlen(SL(t)), VS.len_limbs(SL(t))) : {_ == A.quad(VB.pw(d)) : Nat}
  %Equal.sym(Nat, FX.wlen(SL(t)), A.quad(List.length(&2, U32, SL(t))), VS.wlen_quad(SL(t))) : {_ == A.quad(VB.pw(d)) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, SL(t)), VB.pw(d), Equal.trans(Nat, List.length(&2, U32, SL(t)), FD.spec_common__length(U32, SL(t)), VB.pw(d), len_eq(SL(t)), FD.array__slots_length(U32, d, t, pf))) : {A.quad(_) == A.quad(VB.pw(d)) : Nat}
  {==}

def lenVW(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {List.length(&2, U32, DC.VW(t, n)) == U32.to_nat(n) : Nat}:
  VS.bt_len(U32.to_nat(n), FX.limbs(SL(t)),
    FD.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(n), z) == True{} : Bool}, A.quad(VB.pw(d)), List.length(&2, U32, FX.limbs(SL(t))), Equal.sym(Nat, List.length(&2, U32, FX.limbs(SL(t))), A.quad(VB.pw(d)), lenS(d, t, pf)), hn))

def rej_f(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {DC.CHK(n) == False{} : Bool},
    facts: FACTS(DC.VW(t, n))) -> Empty:
  (+k, +pr) = facts
  (+hl, +hkk) = pr
  +en = Equal.trans(Nat, U32.to_nat(n), List.length(&2, U32, DC.VW(t, n)), EL.b${E}(k), Equal.sym(Nat, List.length(&2, U32, DC.VW(t, n)), U32.to_nat(n), lenVW(d, t, n, pf, hn)), hl)
  +ec = Equal.trans(Nat, U32.to_nat(n), EL.b${E}(k), Nat.mul(k, U32.to_nat(${B})), en, Equal.sym(Nat, Nat.mul(k, ${B}n), EL.b${E}(k), EL.mulb${E}(k)))
  +ht = VL.whole_i1(n, ${B}, DC.vB(), {==}, {==}, {==}, k, ec)
  FD.logic__true_false(Equal.trans(Bool, True{}, DC.CHK(n), False{}, Equal.sym(Bool, DC.CHK(n), True{}, ht), hchk))

# When the validator refuses, no value is related to the buffer's bytes.
law decode_reject:
  for +d: Nat
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {DC.CHK(n) == False{} : Bool}
  Decoding.outside_image(GS.${X}(), DC.VW(t, n))
def decode_reject(d, t, n, pf, hn, hchk):
  v => e => rej_f(d, t, n, pf, hn, hchk, inv_v(v, DC.VW(t, n), e))

# When the validator refuses, the decoder returns None and the buffer.
law decode_none:
  for +t: FD.array__Tree<U32>
  for +n: U32
  for +hchk: {DC.CHK(n) == False{} : Bool}
  {${Tn}_decode(DC.BF(t, n), n) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, O.Words>}
def decode_none(t, n, hchk):
  %Equal.sym(Bool, DC.CHK(n), False{}, hchk) : {${Tn}_built(n, (DC.BF(t, n), _)) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, O.Words>}
  {==}

@@ enc_text @@
def em(+N: U32, +c: Nat, +ec: {U32.to_nat(N) == EL.b${E}(c) : Nat}) -> {U32.to_nat(N) == A.quad(EL.w${E}(c)) : Nat}:
  Equal.trans(Nat, U32.to_nat(N), EL.b${E}(c), A.quad(EL.w${E}(c)), ec, EL.bq${E}(c))

def XE(+c: Nat, +W: List<&2, U32>) -> S.Value: S.Sequence{EL.it${E}(c, W)}

# The encoder returns the object and the buffer of OUTP(N, T), N bytes.
law encode_eval:
${chr(10).join(LHE)}
  {${Tn}_encode(${O_}) == ${RHS} : ${TY}}
def encode_eval(dw, T, N, c, pfT, hdw, ec, hroom, hS):
  +e4 = em(N, c, ec)
  +hdw31 = hdw
  +hDO = VL.hDOA(dw, N, ${m}, hdw, e4, hroom)
  %Equal.sym(Array<U32> & U32, Array.size(U32, FD.array__thaw(U32, T)), (FD.array__thaw(U32, T), FD.u32__pow2u(dw)), FD.array__size_thaw(U32, dw, T, pfT)) :
    {${Tn}_enc_sized(O.wsz_pick(N, _)) == ${RHS} : ${TY}}
  %Equal.sym(Bool, U32.is_le(VC.nwu(N), FD.u32__pow2u(dw)), True{}, VE.le_room(N, dw, hdw31, VL.roomwA(dw, N, ${m}, hdw, e4, hroom))) :
    {${Tn}_enc_sized((${O_}, O.pick(_, N, 4294967295))) == ${RHS} : ${TY}}
  %Equal.sym(Bool, O.is_poisoned(N), False{}, VBE.np_nmax(N, hS)) :
    {${Tn}_enc_go(_, N, ${O_}) == ${RHS} : ${TY}}
  %Equal.sym(Array<U32>, B.zeros(B.words_depth_u(VC.nwu(N))), Array.new(U32, VL.DO(N), 0),
      FD.logic__subst(Nat, z => {B.zeros(B.words_depth_u(VC.nwu(N))) == Array.new(U32, z, 0) : Array<U32>}, U32.to_nat(B.words_depth_u(VC.nwu(N))), VL.DO(N), VD.wdu(VC.nwu(N)), Z.zs(B.words_depth_u(VC.nwu(N))))) :
    {${Tn}_enc_put(N, T.${lp}_putn(_, 0, ${O_})) == ${RHS} : ${TY}}
  %Equal.sym(Array<U32>, Array.new(U32, VL.DO(N), 0), FD.array__thaw(U32, VC.ZT(VL.DO(N))), FD.array__new(U32, VL.DO(N), 0)) :
    {${Tn}_enc_put(N, T.${lp}_putn(_, 0, ${O_})) == ${RHS} : ${TY}}
  %Equal.sym(Array<U32> & O.Words, O.put_words(FD.array__thaw(U32, VC.ZT(VL.DO(N))), 0, ${O_}), (FD.array__thaw(U32, VL.OUTP(N, T)), ${O_}),
      VE.put_words_ok(VL.DO(N), dw, VC.ZT(VL.DO(N)), T, 0, 0n, N, FD.array__trep_perfect(U32, VL.DO(N), 0), pfT,
        FD.nat__le_lt_trans(VL.DO(N), dw, 31n, hDO, hdw31), hdw31, {==}, {==}, VL.and3_q(N, ${m}, e4),
        VL.roomwA(dw, N, ${m}, hdw, e4, hroom), VL.hdstoA(dw, N, ${m}, hdw, e4, hroom))) :
    {${Tn}_enc_put(N, O.pwn(_)) == ${RHS} : ${TY}}
  {==}

# The bytes of the encoder's buffer are the spec encoding of the object's value.
law encode_spec:
${chr(10).join(LH)}
  Decoding.decodes(GS.${X}(), VS.bt(U32.to_nat(N), FX.limbs(FD.array__slots(U32, VL.OUTP(N, T)))), XE(c, FD.array__slots(U32, T)))
def encode_spec(dw, T, N, c, pfT, hdw, ec, hroom):
  +e4 = em(N, c, ec)
  +W = FD.array__slots(U32, T)
  +hl = FD.logic__subst(Nat, z => {Nat.is_le(${m}, z) == True{} : Bool}, VB.pw(dw), FD.spec_common__length(U32, W), Equal.sym(Nat, FD.spec_common__length(U32, W), VB.pw(dw), FD.array__slots_length(U32, dw, T, pfT)), hroom)
  +fit = FD.logic__subst(Nat, z => {N.fits(4n, z) == True{} : Bool}, U32.to_nat(N), EL.b${E}(c), ec, VL.hfitA(N))
  Equal.trans(Maybe<&2, +List<U32>>, Codec.encoding_for_legal_type(GS.${X}(), XE(c, W)), Some{FX.limbs(VS.wtake(${m}, W))}, Some{VS.bt(U32.to_nat(N), FX.limbs(FD.array__slots(U32, VL.OUTP(N, T))))},
    EL.plenc${E}(c, W, hl, fit),
    Equal.cong(+List<U32>, Maybe<&2, +List<U32>>, z => Some{z}, FX.limbs(VS.wtake(${m}, W)), VS.bt(U32.to_nat(N), FX.limbs(FD.array__slots(U32, VL.OUTP(N, T)))),
      Equal.sym(+List<U32>, VS.bt(U32.to_nat(N), FX.limbs(FD.array__slots(U32, VL.OUTP(N, T)))), FX.limbs(VS.wtake(${m}, W)), VL.out_eq_gA(dw, T, N, ${m}, pfT, hdw, e4, hroom))))
