@@ TEMPLATE @@

def v2() -> Word(31n): FD.spec_numeric__from_nat(31n, 2n)
def CQ(+len: U32) -> Nat: U32.to_nat(U32.div(len, 2))
def SCH() -> S.Schema: S.ListOf{S.Unsigned{P.U16{}}, @Nn}

# Whole elements (two bytes each), at most @N.
def CHKw(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> Bool: Bool.and(U32.is_eq(len, (U32.div(len, 2) * 2 : U32)), U32.is_le(U32.div(len, 2), @N))

# The validator on the window returns the buffer and CHKw.
def ok_evalw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool})
    -> {T.@p_ok(BF(t, n), off, len) == (BF(t, n), CHKw(t, x, off, len)) : B.Buf & Bool}:
  {==}

# CHKw: the length is twice the element count, and the count at most @N.
def eLc(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {CHKw(t, x, off, len) == True{} : Bool}) -> {U32.to_nat(len) == Nat.double(CQ(len)) : Nat}:
  Equal.trans(Nat, U32.to_nat(len), Nat.mul(CQ(len), 2n), Nat.double(CQ(len)),
    Pair.fst({U32.to_nat(len) == Nat.mul(CQ(len), U32.to_nat(2)) : Nat}, {Nat.is_le(CQ(len), U32.to_nat(@N)) == True{} : Bool},
      VU.whole_t(len, 2, @N, v2(), {==}, {==}, {==}, hc)),
    Equal.sym(Nat, Nat.double(CQ(len)), Nat.mul(CQ(len), 2n), PB.dbl_mul(CQ(len))))

def hcL(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hc: {CHKw(t, x, off, len) == True{} : Bool}) -> {Nat.is_le(CQ(len), @Nn) == True{} : Bool}:
  Pair.snd({U32.to_nat(len) == Nat.mul(CQ(len), U32.to_nat(2)) : Nat}, {Nat.is_le(CQ(len), U32.to_nat(@N)) == True{} : Bool},
    VU.whole_t(len, 2, @N, v2(), {==}, {==}, {==}, hc))

# A length of 2 c bytes, c <= @N, passes the checks.
def chk2(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +c: Nat, +ec: {U32.to_nat(len) == Nat.double(c) : Nat}, +hk: {Nat.is_le(c, @Nn) == True{} : Bool})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  VU.whole_i(len, 2, @N, v2(), {==}, {==}, {==}, c, Equal.trans(Nat, U32.to_nat(len), Nat.double(c), Nat.mul(c, 2n), ec, PB.dbl_mul(c)), hk)

# The reader on the window, when the checks hold: a copy of the window's words.
def OBJw(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32) -> O.Words: O.Words{FD.array__thaw(U32, UCT.CT(d, t, off, len, VLS.DZ(len))), len}

def readw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {CHKw(t, x, off, len) == True{} : Bool})
    -> {T.@p_read(BF(t, n), off, len) == (BF(t, n), OBJw(d, t, x, off, len)) : B.Buf & O.Words}:
  +hL = hlen(d, x, len, hw)
  +hz = VLS.hdz29(d, len, hd, hL)
  +ez = FD.logic__subst(Nat, z => {B.zeros(B.words_depth_u(VC.WZ(len))) == Array.new(U32, z, 0) : Array<U32>}, U32.to_nat(B.words_depth_u(VC.WZ(len))), VLS.DZ(len),
    VD.wdu(VC.WZ(len)), VZG.zg(B.words_depth_u(VC.WZ(len))))
  UCT.copy_in_at(d, t, n, off, len, VLS.DZ(len), VLS.KK(d), pf, FD.nat__lt_trans(d, 28n, 31n, hd, {==}), FD.nat__le_lt_trans(VLS.DZ(len), 29n, 31n, hz, {==}), ez,
    UW.hsx(d, off, x, len, eo, hd, hw), VLS.hrg(d, len, hd, hL), VLS.kk_lt(d, hd), VLS.hyn(d, len, hL))

def VALw(+t: FD.array__Tree<U32>, +x: Nat, +len: U32) -> S.Value: S.Sequence{PB.it2(CQ(len), UW.WX(t, x, U32.to_nat(len)))}

# ---- the spec parts of a list of 2-byte elements ------------------------------------------------

def sp2(xs: +List<U32>) -> +List<S.Part>:
  match xs:
    case Nil{}: []
    case Con{x0, t}:
      match t:
        case Nil{}: []
        case Con{x1, r}: S.Fixed{[x0, x1]} <> sp2(r)

def u16p(+x0: U32, +x1: U32, +e0: {U32.is_lt(x0, 256) == True{} : Bool}, +e1: {U32.is_lt(x1, 256) == True{} : Bool})
    -> {Codec.parts(S.UnsignedValue{P.UInt{PB.v16of(x0, x1), 0, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U16{}}) == Some{[S.Fixed{[x0, x1]}]} : Maybe<&2, +List<S.Part>>}:
  %Equal.sym(Maybe<&2, +List<U32>>, RR.basic_one(S.UnsignedValue{P.UInt{PB.v16of(x0, x1), 0, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U16{}}), Some{[x0, x1]}, PB.two(x0, x1, e0, e1)) :
    {Codec.one(_, Some{2n}) == Some{[S.Fixed{[x0, x1]}]} : Maybe<&2, +List<S.Part>>}
  {==}

# The facts of a byte string in scope for k elements, by induction on k.
law sc2p:
  for +k: Nat
  for +xs: +List<U32>
  for +hs: {SP.byte_scope(Nat.double(k), xs) == True{} : Bool}
  {Codec.parts(PB.it2(k, xs), S.Repeat{S.Unsigned{P.U16{}}}) == Some{sp2(xs)} : Maybe<&2, +List<S.Part>>}
def sc2p(k, xs, hs):
  match k xs:
    case 0n Nil{}: {==}
    case 0n Con{+x, +t}: Empty.absurd({Codec.parts(PB.it2(0n, x <> t), S.Repeat{S.Unsigned{P.U16{}}}) == Some{sp2(x <> t)} : Maybe<&2, +List<S.Part>>}, FD.logic__false_true(hs))
    case 1n+ +c Nil{}: Empty.absurd({Codec.parts(PB.it2(1n+c, Nil{}), S.Repeat{S.Unsigned{P.U16{}}}) == Some{sp2(Nil{})} : Maybe<&2, +List<S.Part>>}, FD.logic__false_true(hs))
    case 1n+ +c Con{+x0, +t}:
      match t:
        case Nil{}: Empty.absurd({Codec.parts(PB.it2(1n+c, [x0]), S.Repeat{S.Unsigned{P.U16{}}}) == Some{sp2([x0])} : Maybe<&2, +List<S.Part>>}, FD.logic__false_true(FD.logic__and_right(U32.is_lt(x0, 256), False{}, hs)))
        case Con{+x1, +rest}:
          +k1 = FD.logic__and_right(U32.is_lt(x0, 256), Bool.and(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest)), hs)
          +e0 = FD.logic__and_left(U32.is_lt(x0, 256), Bool.and(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest)), hs)
          +e1 = FD.logic__and_left(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest), k1)
          +ih = sc2p(c, rest, FD.logic__and_right(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest), k1))
          F.cat_fixed(Codec.parts(S.UnsignedValue{P.UInt{PB.v16of(x0, x1), 0, 0, 0, 0, 0, 0, 0}}, S.Unsigned{P.U16{}}), [x0, x1], Codec.parts(PB.it2(c, rest), S.Repeat{S.Unsigned{P.U16{}}}), sp2(rest), u16p(x0, x1, e0, e1), ih)

law sc2s:
  for +k: Nat
  for +xs: +List<U32>
  for +hs: {SP.byte_scope(Nat.double(k), xs) == True{} : Bool}
  {Layout.fixed_size(sp2(xs)) == Nat.double(k) : Nat}
def sc2s(k, xs, hs):
  match k xs:
    case 0n Nil{}: {==}
    case 0n Con{+x, +t}: Empty.absurd({Layout.fixed_size(sp2(x <> t)) == Nat.double(0n) : Nat}, FD.logic__false_true(hs))
    case 1n+ +c Nil{}: Empty.absurd({Layout.fixed_size(sp2(Nil{})) == Nat.double(1n+c) : Nat}, FD.logic__false_true(hs))
    case 1n+ +c Con{+x0, +t}:
      match t:
        case Nil{}: Empty.absurd({Layout.fixed_size(sp2([x0])) == Nat.double(1n+c) : Nat}, FD.logic__false_true(FD.logic__and_right(U32.is_lt(x0, 256), False{}, hs)))
        case Con{+x1, +rest}:
          +k1 = FD.logic__and_right(U32.is_lt(x0, 256), Bool.and(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest)), hs)
          +ih = sc2s(c, rest, FD.logic__and_right(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest), k1))
          Equal.cong(Nat, Nat, z => 2n+z, Layout.fixed_size(sp2(rest)), Nat.double(c), ih)

law sc2v:
  for +k: Nat
  for +xs: +List<U32>
  for +hs: {SP.byte_scope(Nat.double(k), xs) == True{} : Bool}
  {Layout.bytes_valid(sp2(xs)) == True{} : Bool}
def sc2v(k, xs, hs):
  match k xs:
    case 0n Nil{}: {==}
    case 0n Con{+x, +t}: Empty.absurd({Layout.bytes_valid(sp2(x <> t)) == True{} : Bool}, FD.logic__false_true(hs))
    case 1n+ +c Nil{}: Empty.absurd({Layout.bytes_valid(sp2(Nil{})) == True{} : Bool}, FD.logic__false_true(hs))
    case 1n+ +c Con{+x0, +t}:
      match t:
        case Nil{}: Empty.absurd({Layout.bytes_valid(sp2([x0])) == True{} : Bool}, FD.logic__false_true(FD.logic__and_right(U32.is_lt(x0, 256), False{}, hs)))
        case Con{+x1, +rest}:
          +k1 = FD.logic__and_right(U32.is_lt(x0, 256), Bool.and(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest)), hs)
          +e0 = FD.logic__and_left(U32.is_lt(x0, 256), Bool.and(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest)), hs)
          +e1 = FD.logic__and_left(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest), k1)
          +ih = sc2v(c, rest, FD.logic__and_right(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest), k1))
          FD.logic__and_intro(SP.bytes_domain([x0, x1]), Layout.bytes_valid(sp2(rest)), FD.logic__and_intro(U32.is_lt(x0, 256), Bool.and(U32.is_lt(x1, 256), True{}), e0, FD.logic__and_intro(U32.is_lt(x1, 256), True{}, e1, {==})), ih)

law sc2c:
  for +k: Nat
  for +xs: +List<U32>
  for +hs: {SP.byte_scope(Nat.double(k), xs) == True{} : Bool}
  {Codec.count(PB.it2(k, xs)) == k : Nat}
def sc2c(k, xs, hs):
  match k xs:
    case 0n Nil{}: {==}
    case 0n Con{+x, +t}: {==}
    case 1n+ +c Nil{}: Empty.absurd({0n == 1n+c : Nat}, FD.logic__false_true(hs))
    case 1n+ +c Con{+x0, +t}:
      match t:
        case Nil{}: Empty.absurd({0n == 1n+c : Nat}, FD.logic__false_true(FD.logic__and_right(U32.is_lt(x0, 256), False{}, hs)))
        case Con{+x1, +rest}:
          +k1 = FD.logic__and_right(U32.is_lt(x0, 256), Bool.and(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest)), hs)
          +ih = sc2c(c, rest, FD.logic__and_right(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest), k1))
          Equal.cong(Nat, Nat, z => 1n+z, Codec.count(PB.it2(c, rest)), c, ih)

def ev(xs: +List<U32>) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{x0, t}:
      match t:
        case Nil{}: False{}
        case Con{x1, r}: ev(r)

law sc2e:
  for +k: Nat
  for +xs: +List<U32>
  for +hs: {SP.byte_scope(Nat.double(k), xs) == True{} : Bool}
  {ev(xs) == True{} : Bool}
def sc2e(k, xs, hs):
  match k xs:
    case 0n Nil{}: {==}
    case 0n Con{+x, +t}: Empty.absurd({ev(x <> t) == True{} : Bool}, FD.logic__false_true(hs))
    case 1n+ +c Nil{}: Empty.absurd({ev(Nil{}) == True{} : Bool}, FD.logic__false_true(hs))
    case 1n+ +c Con{+x0, +t}:
      match t:
        case Nil{}: Empty.absurd({ev([x0]) == True{} : Bool}, FD.logic__false_true(FD.logic__and_right(U32.is_lt(x0, 256), False{}, hs)))
        case Con{+x1, +rest}:
          +k1 = FD.logic__and_right(U32.is_lt(x0, 256), Bool.and(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest)), hs)
          sc2e(c, rest, FD.logic__and_right(U32.is_lt(x1, 256), SP.byte_scope(Nat.double(c), rest), k1))

law s2_fp:
  for +xs: +List<U32>
  for +o: Nat
  for +h: {ev(xs) == True{} : Bool}
  {Layout.fixed_parts(sp2(xs), o) == xs : +List<U32>}
def s2_fp(xs, o, h):
  match xs:
    case Nil{}: {==}
    case Con{+x0, +t}:
      match t:
        case Nil{}: Empty.absurd({Layout.fixed_parts(sp2([x0]), o) == [x0] : +List<U32>}, FD.logic__false_true(h))
        case Con{+x1, +r}: Equal.cong(+List<U32>, +List<U32>, z => x0 <> x1 <> z, Layout.fixed_parts(sp2(r), o), r, s2_fp(r, o, h))

law s2_pay:
  for +xs: +List<U32>
  {Layout.payloads(sp2(xs)) == [] : +List<U32>}
def s2_pay(xs):
  match xs:
    case Nil{}: {==}
    case Con{+x0, +t}:
      match t:
        case Nil{}: {==}
        case Con{+x1, +r}: s2_pay(r)

# The list of the 2-byte elements of a byte string, k <= lim: one variable part, the string.
def list_parts(+k: Nat, +xs: +List<U32>, +lim: Nat, +hk: {Nat.is_le(k, lim) == True{} : Bool}, +hs: {SP.byte_scope(Nat.double(k), xs) == True{} : Bool},
    +hfit: {N.fits(4n, Nat.double(k)) == True{} : Bool})
    -> {Codec.parts(S.Sequence{PB.it2(k, xs)}, S.ListOf{S.Unsigned{P.U16{}}, lim}) == Some{[S.Variable{xs}]} : Maybe<&2, +List<S.Part>>}:
  +hm = sc2e(k, xs, hs)
  %Equal.sym(Nat, Codec.count(PB.it2(k, xs)), k, sc2c(k, xs, hs)) :
    {Codec.require(Nat.is_le(_, lim), Codec.aggregate(Codec.parts(PB.it2(k, xs), S.Repeat{S.Unsigned{P.U16{}}}), None{})) == Some{[S.Variable{xs}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Bool, Nat.is_le(k, lim), True{}, hk) :
    {Codec.require(_, Codec.aggregate(Codec.parts(PB.it2(k, xs), S.Repeat{S.Unsigned{P.U16{}}}), None{})) == Some{[S.Variable{xs}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Maybe<&2, +List<S.Part>>, Codec.parts(PB.it2(k, xs), S.Repeat{S.Unsigned{P.U16{}}}), Some{sp2(xs)}, sc2p(k, xs, hs)) :
    {Codec.require(True{}, Codec.aggregate(_, None{})) == Some{[S.Variable{xs}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(Maybe<&2, +List<U32>>, Layout.encoding(sp2(xs)), Some{List.append(&2, U32, xs, [])},
      VMV.enc_gen(sp2(xs), Nat.double(k), xs, [], sc2s(k, xs, hs), s2_fp(xs, Nat.double(k), hm), s2_pay(xs), sc2v(k, xs, hs),
        FD.logic__subst(Nat, z => {N.fits(4n, z) == True{} : Bool}, Nat.double(k), Nat.add(Nat.double(k), 0n), Equal.sym(Nat, Nat.add(Nat.double(k), 0n), Nat.double(k), FD.nat__add_zero(Nat.double(k))), hfit))) :
    {Codec.one(_, None{}) == Some{[S.Variable{xs}]} : Maybe<&2, +List<S.Part>>}
  %Equal.sym(+List<U32>, List.append(&2, U32, xs, []), xs, VS.app_nil(xs)) : {Codec.one(Some{_}, None{}) == Some{[S.Variable{xs}]} : Maybe<&2, +List<S.Part>>}
  {==}

# The spec parts of the value: one variable part, the window's bytes.
def specw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hchk: {CHKw(t, x, off, len) == True{} : Bool})
    -> {Codec.parts(VALw(t, x, len), S.ListOf{S.Unsigned{P.U16{}}, @Nn}) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>}:
  +Y = UW.WX(t, x, U32.to_nat(len))
  +el = eLc(t, x, off, len, hchk)
  +hs0 = FD.logic__subst(Nat, z => {SP.byte_scope(z, Y) == True{} : Bool}, List.length(&2, U32, Y), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw),
    U8.dom_scope(Y, UW.domWX(t, x, U32.to_nat(len))))
  +hs = FD.logic__subst(Nat, z => {SP.byte_scope(z, Y) == True{} : Bool}, U32.to_nat(len), Nat.double(CQ(len)), el, hs0)
  +hf = FD.logic__subst(Nat, z => {N.fits(4n, z) == True{} : Bool}, U32.to_nat(len), Nat.double(CQ(len)), el,
    VFT.fits4(2n+d, U32.to_nat(len), hlen(d, x, len, hw), FD.nat__lt_trans(d, 28n, 30n, hd, {==})))
  list_parts(CQ(len), Y, @Nn, hcL(t, x, off, len, hchk), hs, hf)

# ---- every value whose spec parts are the window's bytes passes the checks ----------------------

@REP

def ivf(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +c: Nat, +hk: {Nat.is_le(c, @Nn) == True{} : Bool},
    +ys: +List<U32>, +ly: {List.length(&2, U32, ys) == Nat.double(c) : Nat}, +ey: {ys == UW.WX(t, x, U32.to_nat(len)) : +List<U32>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  +el = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), Nat.double(c),
    Equal.sym(Nat, List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)),
    Equal.trans(Nat, List.length(&2, U32, UW.WX(t, x, U32.to_nat(len))), List.length(&2, U32, ys), Nat.double(c),
      Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), UW.WX(t, x, U32.to_nat(len)), ys, Equal.sym(+List<U32>, ys, UW.WX(t, x, U32.to_nat(len)), ey)), ly))
  chk2(t, x, off, len, c, el, hk)

def ivm4(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +its: S.Value, +hk: {Nat.is_le(Codec.count(its), @Nn) == True{} : Bool},
    +ps: +List<S.Part>, +em3: {Codec.parts(its, S.Repeat{U16S()}) == Some{ps} : Maybe<&2, +List<S.Part>>},
    +m4: Maybe<&2, +List<U32>>, +em4: {Layout.encoding(ps) == m4 : Maybe<&2, +List<U32>>},
    +e: {Codec.one(m4, None{}) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  match m4:
    case None{}: Empty.absurd({CHKw(t, x, off, len) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, [S.Variable{UW.WX(t, x, U32.to_nat(len))}], e))
    case Some{+ys}:
      +lys = Equal.trans(Nat, List.length(&2, U32, ys), Layout.fixed_size(ps), Nat.double(Codec.count(its)),
        VS.enc_len(ps, ys, Pair.fst({VS.allfix(ps) == True{} : Bool}, {Layout.fixed_size(ps) == Nat.double(Codec.count(its)) : Nat}, rep_facts(its, ps, em3)), em4),
        Pair.snd({VS.allfix(ps) == True{} : Bool}, {Layout.fixed_size(ps) == Nat.double(Codec.count(its)) : Nat}, rep_facts(its, ps, em3)))
      ivf(d, t, x, off, len, hw, pf, Codec.count(its), hk, ys, lys, var_inj(ys, UW.WX(t, x, U32.to_nat(len)), e))

def ivm3(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +its: S.Value, +hk: {Nat.is_le(Codec.count(its), @Nn) == True{} : Bool},
    +m3: Maybe<&2, +List<S.Part>>, +em3: {Codec.parts(its, S.Repeat{U16S()}) == m3 : Maybe<&2, +List<S.Part>>},
    +e: {Codec.aggregate(m3, None{}) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  match m3:
    case None{}: Empty.absurd({CHKw(t, x, off, len) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, [S.Variable{UW.WX(t, x, U32.to_nat(len))}], e))
    case Some{+ps}: ivm4(d, t, x, off, len, hw, pf, its, hk, ps, em3, Layout.encoding(ps), {==}, e)

def ivb(+d: Nat, +t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +its: S.Value, +b2: Bool, +eb2: {Nat.is_le(Codec.count(its), @Nn) == b2 : Bool},
    +e: {Codec.require(b2, Codec.aggregate(Codec.parts(its, S.Repeat{U16S()}), None{})) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  match b2:
    case False{}: Empty.absurd({CHKw(t, x, off, len) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, [S.Variable{UW.WX(t, x, U32.to_nat(len))}], e))
    case True{}: ivm3(d, t, x, off, len, hw, pf, its, eb2, Codec.parts(its, S.Repeat{U16S()}), {==}, e)

# Every value whose spec parts are the window's bytes passes the checks.
def invw(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +x: Nat, +off: U32, +len: U32, +eo: {U32.to_nat(off) == x : Nat},
    +hd: {Nat.is_lt(d, 28n) == True{} : Bool}, +hw: {Nat.is_le(Nat.add(x, U32.to_nat(len)), A.quad(VB.pw(d))) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +v: S.Value,
    +e: {Codec.parts(v, S.ListOf{S.Unsigned{P.U16{}}, @Nn}) == Some{[S.Variable{UW.WX(t, x, U32.to_nat(len))}]} : Maybe<&2, +List<S.Part>>})
    -> {CHKw(t, x, off, len) == True{} : Bool}:
  match v:
    case S.Sequence{+its}: ivb(d, t, x, off, len, hw, pf, its, Nat.is_le(Codec.count(its), @Nn), {==}, e)
@ABSURDV

@@ deep_text @@

# ---- the copy's bounds from the limit: at most ${B} bytes ----
def dle(+c: Nat, +h: {Nat.is_le(c, ${N}n) == True{} : Bool}) -> {Nat.is_le(Nat.double(c), ${B}n) == True{} : Bool}:
  %Equal.sym(Nat, Nat.double(c), Nat.add(c, c), FD.lru_nat_algebra__double_self(c)) : {Nat.is_le(_, ${B}n) == True{} : Bool}
  FD.nat__le_trans(Nat.add(c, c), Nat.add(${N}n, c), ${B}n, Order.add_right(c, ${N}n, c, h), FD.nat__le_add_left(c, ${N}n, ${N}n, h))

def hB(+t: FD.array__Tree<U32>, +x: Nat, +off: U32, +len: U32, +hchk: {CHKw(t, x, off, len) == True{} : Bool}) -> {Nat.is_le(U32.to_nat(len), ${B}n) == True{} : Bool}:
  FD.logic__subst(Nat, z => {Nat.is_le(z, ${B}n) == True{} : Bool}, Nat.double(CQ(len)), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), Nat.double(CQ(len)), eLc(t, x, off, len, hchk)), dle(CQ(len), hcL(t, x, off, len, hchk)))
