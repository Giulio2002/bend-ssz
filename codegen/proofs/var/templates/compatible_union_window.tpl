@@ union_deep @@


${hdr.replace('def hwj(', 'def hwj32(')}
    -> {Nat.is_lt(Nat.add(Nat.add(U32.to_nat(o), x), U32.to_nat(U32.sub(len, o))), ${P32}) == ${TRUE}}:
  VB.le_n_lt32(Nat.add(Nat.add(U32.to_nat(o), x), U32.to_nat(U32.sub(len, o))), VB.NMAX(), hwjN(${pn}))
@@ module_text @@
def le_nat(+a: U32, +b: U32, +h: {U32.is_le(a, b) == ${TRUE}}) -> {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == ${TRUE}}:
  FD.logic__subst(Bool, z => {z == ${TRUE}}, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b), h)

# A byte position o <= len of the window, as an offset: off + o at o + x.
def eoj(${CW}, +o: U32, +h: {Nat.is_le(U32.to_nat(o), U32.to_nat(len)) == ${TRUE}})
    -> {U32.to_nat(U32.add(off, o)) == Nat.add(U32.to_nat(o), x) : Nat}:
  +hl = FD.nat__le_trans(Nat.add(U32.to_nat(o), x), Nat.add(U32.to_nat(len), x), ${PW}, Order.add_right(U32.to_nat(o), U32.to_nat(len), x, h),
    FD.logic__subst(Nat, z => {Nat.is_le(z, ${PW}) == ${TRUE}}, Nat.add(x, U32.to_nat(len)), Nat.add(U32.to_nat(len), x), FD.nat__add_comm(x, U32.to_nat(len)), hw))
  VB.add_at(off, o, x, 3n+d, eo, FD.nat__lt_trans(3n+d, 31n, 32n, hd, {==}), VB.le_pw_lt(Nat.add(U32.to_nat(o), x), 2n+d, hl))

def alg(+o: Nat, +x: Nat, +e: Nat, +h: {Nat.is_le(o, e) == ${TRUE}}) -> {Nat.add(Nat.add(o, x), Nat.sub(e, o)) == Nat.add(x, e) : Nat}:
  %Equal.sym(Nat, Nat.add(Nat.add(o, x), Nat.sub(e, o)), Nat.add(o, Nat.add(x, Nat.sub(e, o))), FD.nat__add_assoc(o, x, Nat.sub(e, o))) : {_ == Nat.add(x, e) : Nat}
  %Equal.sym(Nat, Nat.add(o, Nat.add(x, Nat.sub(e, o))), Nat.add(x, Nat.add(o, Nat.sub(e, o))), FD.lru_nat_algebra__add_swap(o, x, Nat.sub(e, o))) : {_ == Nat.add(x, e) : Nat}
  %Equal.sym(Nat, Nat.add(o, Nat.sub(e, o)), e, FD.nat__sub_add(e, o, h)) : {Nat.add(x, _) == Nat.add(x, e) : Nat}
  {==}

def hwj(${CW}, +o: U32, +h2: {Nat.is_le(U32.to_nat(o), U32.to_nat(len)) == ${TRUE}})
    -> {Nat.is_le(Nat.add(Nat.add(U32.to_nat(o), x), U32.to_nat(U32.sub(len, o))), ${PW}) == ${TRUE}}:
  %Equal.sym(Nat, U32.to_nat(U32.sub(len, o)), Nat.sub(U32.to_nat(len), U32.to_nat(o)), FD.u32__sub_nat(len, o, h2)) : {Nat.is_le(Nat.add(Nat.add(U32.to_nat(o), x), _), ${PW}) == ${TRUE}}
  %Equal.sym(Nat, Nat.add(Nat.add(U32.to_nat(o), x), Nat.sub(U32.to_nat(len), U32.to_nat(o))), Nat.add(x, U32.to_nat(len)), alg(U32.to_nat(o), x, U32.to_nat(len), h2)) :
    {Nat.is_le(_, ${PW}) == ${TRUE}}
  hw

# the arm's window: bytes 1 .. len of this one
def XJ(+t: ${TR}, +x: Nat) -> Nat: Nat.add(U32.to_nat(1), x)
def FJ(+off: U32) -> U32: U32.add(off, 1)
def LJ(+len: U32) -> U32: U32.sub(len, 1)
def H1(${TXO}) -> Data: {Nat.is_le(U32.to_nat(1), U32.to_nat(len)) == ${TRUE}}
def eoJ(${CW}, +h1: H1(${TXOA})) -> {U32.to_nat(${FJ}) == ${XJ} : Nat}: eoj(${CWA}, 1, h1)
def hwJ(${CW}, +h1: H1(${TXOA})) -> {Nat.is_le(Nat.add(${XJ}, U32.to_nat(${LJ})), ${PW}) == ${TRUE}}: hwj(${CWA}, 1, h1)

# the selector byte is the window's first byte
def hx0(${CW}, +h1: H1(${TXOA})) -> {Nat.is_le(Nat.add(x, 1n), ${PW}) == ${TRUE}}:
  FD.nat__le_trans(Nat.add(x, 1n), Nat.add(x, U32.to_nat(len)), ${PW}, Order.add_left(x, 1n, U32.to_nat(len), h1), hw)

def ewx(${CW}, +h1: H1(${TXOA})) -> {${WBL} == ${SB} <> ${YJ} : +List<U32>}:
  +eL = Equal.sym(Nat, Nat.add(U32.to_nat(1), U32.to_nat(${LJ})), U32.to_nat(len), VM.sub_eq(len, 1, VMR.u32le(1, len, h1)))
  %Equal.sym(Nat, U32.to_nat(len), Nat.add(U32.to_nat(1), U32.to_nat(${LJ})), eL) : {UW.WX(t, x, _) == ${SB} <> ${YJ} : +List<U32>}
  %Equal.sym(+List<U32>, UW.WX(t, x, Nat.add(U32.to_nat(1), U32.to_nat(${LJ}))), List.append(&2, U32, UW.WX(t, x, U32.to_nat(1)), ${YJ}),
      UW.splitWX(t, x, U32.to_nat(1), U32.to_nat(${LJ}))) : {_ == ${SB} <> ${YJ} : +List<U32>}
  %Equal.sym(+List<U32>, UW.WX(t, x, 1n), [${SB}], wx1(d, t, x, pf, hx0(${CWA}, h1))) : {List.append(&2, U32, _, ${YJ}) == ${SB} <> ${YJ} : +List<U32>}
  {==}

@@ module_text_2 @@

def hxl(${CW}, +h1: H1(${TXOA})) -> {VR.VX(t, off) == ${SB} : U32}: vx_bx(t, off, x, eo)
def hix(${CW}, +h1: H1(${TXOA})) -> {Nat.is_lt(VR.QX(off), VB.pw(d)) == ${TRUE}}:
  VR.hiX(d, off, x, eo, VXG.ltx(x, 1n, ${PW}, {==}, hx0(${CWA}, h1)))
def rsel(${CW}, +h1: H1(${TXOA})) -> {O.rd_u8(${BUF}, off) == (${BUF}, ${SB}) : B.Buf & U32}:
  %hxl(${CWA}, h1) : {O.rd_u8(${BUF}, off) == (${BUF}, _) : B.Buf & U32}
  VR.byte_at_ok(d, t, n, off, FD.nat__lt_trans(d, 28n, 32n, hd, {==}), hix(${CWA}, h1), pf)

def okn(${CW}, +a: Bool, +ea: {U32.is_le(1, len) == a : Bool})
    -> {${Tn}_ok_nz(a, ${BUF}, off, len) == (${BUF}, Bool.and(a, ${K0})) : B.Buf & Bool}:
  match a:
    case False{}: {==}
    case True{}:
      +h1 = le_nat(1, len, ea)
      %Equal.sym(B.Buf & U32, O.rd_u8(${BUF}, off), (${BUF}, ${SB}), rsel(${CWA}, h1)) : {${Tn}_ok_sel(off, len, _) == (${BUF}, ${K0}) : B.Buf & Bool}
      ok0(${CWA}, h1, U32.is_eq(${SB}, ${sels[0]}))

# The validator on the window returns the buffer and CHKw.
def ok_evalw(${CW}) -> {${Tn}_ok(${BUF}, off, len) == (${BUF}, CHKw(${TXOA})) : B.Buf & Bool}:
  okn(${CWA}, U32.is_le(1, len), {==})

@@ module_text_3 @@

def hch1(${TXO}, +hchk: ${GOAL}) -> {U32.is_le(1, len) == ${TRUE}}: FD.logic__and_left(U32.is_le(1, len), ${K0}, hchk)
def hchk0(${TXO}, +hchk: ${GOAL}) -> {${K0} == ${TRUE}}: FD.logic__and_right(U32.is_le(1, len), ${K0}, hchk)

# The reader on the window, when the checks hold.
def readw(${CW}, +hchk: ${GOAL}) -> {${Tn}_read(${BUF}, off, len) == (${BUF}, OBJw(d, ${TXOA})) : B.Buf & ${Tn}}:
  +h1 = le_nat(1, len, hch1(${TXOA}, hchk))
  %Equal.sym(B.Buf & U32, O.rd_u8(${BUF}, off), (${BUF}, ${SB}), rsel(${CWA}, h1)) : {${Tn}_rd_sel(off, len, _) == (${BUF}, OBJw(d, ${TXOA})) : B.Buf & ${Tn}}
  rd0(${CWA}, h1, U32.is_eq(${SB}, ${sels[0]}), hchk0(${TXOA}, hchk))

@@ module_text_4 @@

# The spec parts of the value: one variable part, the window's bytes.
def specw(${CW}, +hchk: ${GOAL}) -> {Codec.parts(VALw(t, x, len), GS.${U}()) == ${TGT} : ${MP}}:
  +h1 = le_nat(1, len, hch1(${TXOA}, hchk))
  %Equal.sym(+List<U32>, ${WBL}, ${SB} <> ${YJ}, ewx(${CWA}, h1)) :
    {Codec.parts(VALw(t, x, len), GS.${U}()) == Some{[S.Variable{_}]} : ${MP}}
  sp0(${CWA}, h1, U32.is_eq(${SB}, ${sels[0]}), {==}, hchk0(${TXOA}, hchk))

@@ module_text_5 @@
# ---- every value whose parts are the window's bytes passes the checks ------------------------

def HDL(l: +List<U32>) -> U32:
  match l:
    case Nil{}: 0
    case Con{+h, r}: h
def TLL(l: +List<U32>) -> +List<U32>:
  match l:
    case Nil{}: []
    case Con{h, r}: r

# a value of a progressive container of variable size has one variable part
def vsingleP(h: S.Value, +names: +List<String>, +fields: S.Schema, +active: +List<Bool>, +e: {SS.fixed_size(fields) == None{} : Maybe<&2, Nat>})
    -> DF.single_result(None{}, Codec.parts(h, S.ProgressiveContainer{names, fields, active})):
  match h:
    case S.Sequence{+items}:
      FD.logic__subst(Maybe<&2, Nat>, z => DF.single_result(None{}, Codec.aggregate(Codec.parts(items, fields), z)), None{}, SS.fixed_size(fields), Equal.sym(Maybe<&2, Nat>, SS.fixed_size(fields), None{}, e),
        UW.vs_agg(Codec.parts(items, fields)))
    case S.BooleanValue{+b0}: Unit{}
    case S.UnsignedValue{+u0}: Unit{}
    case S.BytesValue{+xs0}: Unit{}
    case S.BitsValue{+bs0}: Unit{}
    case S.Items{+hd0, +tl0}: Unit{}
    case S.EmptyItems{}: Unit{}
    case S.Selected{+sel0, +sv0}: Unit{}
    case S.NullValue{}: Unit{}

# the window's bytes as a selector and the rest: at least one byte
def h1of(${CW}, +sel: U32, +xs: +List<U32>, +ey: {sel <> xs == ${WBL} : +List<U32>}) -> H1(${TXOA}):
  +el = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, ${WBL}), List.length(&2, U32, sel <> xs),
    Equal.sym(Nat, List.length(&2, U32, ${WBL}), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)),
    Equal.cong(+List<U32>, Nat, z => List.length(&2, U32, z), ${WBL}, sel <> xs, Equal.sym(+List<U32>, sel <> xs, ${WBL}, ey)))
  FD.logic__subst(Nat, z => {Nat.is_le(1n, z) == ${TRUE}}, 1n+List.length(&2, U32, xs), U32.to_nat(len), Equal.sym(Nat, U32.to_nat(len), 1n+List.length(&2, U32, xs), el),
    Order.below_sum(1n, List.length(&2, U32, xs)))

@@ fixw_text @@

# One byte: the window's length is 1.
def CHKw(${TXO}) -> Bool: U32.is_eq(len, 1)

def okl(${CW}, +a: Bool) -> {${Tn}_ok_len(a, ${BUF}, off) == (${BUF}, a) : B.Buf & Bool}:
  match a:
    case True{}: {==}
    case False{}: {==}

# The validator on the window returns the buffer and CHKw.
def ok_evalw(${CW}) -> {${Tn}_ok(${BUF}, off, len) == (${BUF}, CHKw(${TXOA})) : B.Buf & Bool}: okl(${CWA}, U32.is_eq(len, 1))

def el1(${TXO}, +h: ${FG}) -> {U32.to_nat(len) == 1n : Nat}: Equal.cong(U32, Nat, z => U32.to_nat(z), len, 1, FD.u32alg__eq_of(len, 1, h))
def hb1(${CW}, +h: ${FG}) -> {Nat.is_le(Nat.add(x, 1n), ${PW}) == ${TRUE}}:
  FD.logic__subst(Nat, z => {Nat.is_le(Nat.add(x, z), ${PW}) == ${TRUE}}, U32.to_nat(len), 1n, el1(${TXOA}, h), hw)

def OBJw(+d: Nat, ${TXO}) -> ${Tn}: ${Tn}{FX.OBJ(d, t, x)}

# The reader on the window, when the checks hold.
def readw(${CW}, +hchk: ${FG}) -> {${Tn}_read(${BUF}, off, len) == (${BUF}, OBJw(d, ${TXOA})) : B.Buf & ${Tn}}:
  +e0 = Equal.trans(Nat, U32.to_nat(U32.add(off, 0)), U32.to_nat(off), x, Equal.cong(U32, Nat, z => U32.to_nat(z), U32.add(off, 0), off, FD.u32alg__add_zero(off)), eo)
  %Equal.sym(B.Buf & U32, T.u8_read(${BUF}, U32.add(off, 0), 1), (${BUF}, FX.OBJ(d, t, x)), FX.rdx(d, t, n, U32.add(off, 0), x, e0, hd, pf, hb1(${CWA}, hchk))) :
    {${Tn}_rd0(off, len, _) == (${BUF}, OBJw(d, ${TXOA})) : B.Buf & ${Tn}}
  {==}

def VALw(+t: ${TR}, +x: Nat, +len: U32) -> S.Value: S.Sequence{S.Items{FX.VAL(t, x), S.EmptyItems{}}}

# The spec parts of the value: one FIXED part, the window's byte.
def specw(${CW}, +hchk: ${FG}) -> {Codec.parts(VALw(t, x, len), GS.${X}()) == Some{[S.Fixed{${YW}}]} : ${MP}}:
  +hb = hb1(${CWA}, hchk)
  %Equal.sym(Nat, U32.to_nat(len), 1n, el1(${TXOA}, hchk)) : {Codec.parts(VALw(t, x, len), GS.${X}()) == Some{[S.Fixed{UW.WX(t, x, _)}]} : ${MP}}
  %Equal.sym(${MP}, Codec.parts(S.Items{FX.VAL(t, x), S.EmptyItems{}}, S.Chain{S.Unsigned{P.U8{}}, S.End{}}), Some{[S.Fixed{UW.WX(t, x, 1n)}]},
      F.cat_fixed(Codec.parts(FX.VAL(t, x), S.Unsigned{P.U8{}}), UW.WX(t, x, 1n), Codec.parts(S.EmptyItems{}, S.End{}), [],
        FX.prt(d, t, x, pf, hb, S.Unsigned{P.U8{}}, {==}), {==})) :
    {Codec.aggregate(_, SS.fixed_size(S.Chain{S.Unsigned{P.U8{}}, S.End{}})) == Some{[S.Fixed{UW.WX(t, x, 1n)}]} : ${MP}}
  %VS.app_nil(UW.WX(t, x, 1n)) :
    {Codec.aggregate(Some{[S.Fixed{UW.WX(t, x, 1n)}]}, Some{1n}) == Some{[S.Fixed{_}]} : ${MP}}
  SP2.agg([S.Fixed{UW.WX(t, x, 1n)}], 1n, 1n, {==},
    FD.logic__subst(+List<U32>, z => {SP.bytes_domain(z) == ${TRUE}}, UW.WX(t, x, 1n), SP2.fcat([S.Fixed{UW.WX(t, x, 1n)}]),
      Equal.sym(+List<U32>, SP2.fcat([S.Fixed{UW.WX(t, x, 1n)}]), UW.WX(t, x, 1n), VS.app_nil(UW.WX(t, x, 1n))), UW.domWX(t, x, 1n)),
    FD.logic__subst(+List<U32>, z => {List.length(&2, U32, z) == 1n : Nat}, UW.WX(t, x, 1n), SP2.fcat([S.Fixed{UW.WX(t, x, 1n)}]),
      Equal.sym(+List<U32>, SP2.fcat([S.Fixed{UW.WX(t, x, 1n)}]), UW.WX(t, x, 1n), VS.app_nil(UW.WX(t, x, 1n))), UW.lenWX(d, t, x, 1n, pf, hb)),
    {==})

# Every value whose spec part is the window's bytes (one fixed part) passes the checks.
def MN(m: Maybe<&2, Nat>) -> Nat:
  match m:
    case None{}: 0n
    case Some{k}: k
def FXS(ps: +List<S.Part>) -> +List<U32>:
  match ps:
    case Con{S.Fixed{xs}, r}: xs
    case _: []

def ivp(${CW}, +ps: +List<S.Part>, hf: DF.single(Some{1n}, ps), +ep: {ps == [S.Fixed{${YW}}] : +List<S.Part>}) -> ${FG}:
  match ps:
    case Nil{}: Empty.absurd(${FG}, hf)
    case Con{S.Fixed{+xs}, Nil{}}:
      +ex = Equal.cong(+List<S.Part>, +List<U32>, z => FXS(z), [S.Fixed{xs}], [S.Fixed{${YW}}], ep)
      +l1 = Equal.cong(Maybe<&2, Nat>, Nat, z => MN(z), Some{List.length(&2, U32, xs)}, Some{1n}, Equal.sym(Maybe<&2, Nat>, Some{1n}, Some{List.length(&2, U32, xs)}, hf))
      +el = Equal.trans(Nat, U32.to_nat(len), List.length(&2, U32, ${YW}), 1n, Equal.sym(Nat, List.length(&2, U32, ${YW}), U32.to_nat(len), UW.lenWX(d, t, x, U32.to_nat(len), pf, hw)),
        FD.logic__subst(+List<U32>, z => {List.length(&2, U32, z) == 1n : Nat}, xs, ${YW}, ex, l1))
      FD.u32alg__eq_true(len, 1, FD.u32__injective(len, 1, el))
    case Con{S.Variable{+xs}, Nil{}}: Empty.absurd(${FG}, FD.logic__none_some(Nat, 1n, Equal.sym(Maybe<&2, Nat>, Some{1n}, None{}, hf)))
    case Con{S.Fixed{+xs}, Con{+h2, +r2}}: Empty.absurd(${FG}, hf)
    case Con{S.Variable{+xs}, Con{+h2, +r2}}: Empty.absurd(${FG}, hf)

def ivf(${CW}, +v: S.Value, +m: ${MP}, hf: DF.single_result(Some{1n}, m),
    +e: {m == Some{[S.Fixed{${YW}}]} : ${MP}}) -> ${FG}:
  match m:
    case None{}: Empty.absurd(${FG}, FD.logic__none_some(+List<S.Part>, [S.Fixed{${YW}}], e))
    case Some{+ps}: ivp(${CWA}, ps, hf, FD.logic__some_inj(+List<S.Part>, ps, [S.Fixed{${YW}}], e))

def invw(${CW}, +v: S.Value, +e: {Codec.parts(v, GS.${X}()) == Some{[S.Fixed{${YW}}]} : ${MP}}) -> ${FG}:
  ivf(${CWA}, v, Codec.parts(v, GS.${X}()), DS.facts(v, GS.${X}(), {==}), e)

@@ top_text @@
def tg(+sel: U32, +pm: ${MP}, +bs: +List<U32>, +e: {Codec.bytes(Codec.tagged(sel, pm)) == Some{bs} : Maybe<&2, +List<U32>>})
    -> {Codec.tagged(sel, pm) == Some{[S.Variable{bs}]} : ${MP}}:
  match pm:
    case Some{Con{S.Fixed{+xs}, Nil{}}}: Equal.cong(+List<U32>, ${MP}, z => Some{[S.Variable{z}]}, sel <> xs, bs, FD.logic__some_inj(+List<U32>, sel <> xs, bs, e))
    case Some{Con{S.Variable{+xs}, Nil{}}}: Equal.cong(+List<U32>, ${MP}, z => Some{[S.Variable{z}]}, sel <> xs, bs, FD.logic__some_inj(+List<U32>, sel <> xs, bs, e))
    case None{}: Empty.absurd({Codec.tagged(sel, None{}) == Some{[S.Variable{bs}]} : ${MP}}, FD.logic__none_some(+List<U32>, bs, e))
    case Some{Nil{}}: Empty.absurd({Codec.tagged(sel, Some{Nil{}}) == Some{[S.Variable{bs}]} : ${MP}}, FD.logic__none_some(+List<U32>, bs, e))
    case Some{Con{S.Fixed{+xs}, Con{+h2, +r2}}}: Empty.absurd({Codec.tagged(sel, Some{Con{S.Fixed{xs}, Con{h2, r2}}}) == Some{[S.Variable{bs}]} : ${MP}}, FD.logic__none_some(+List<U32>, bs, e))
    case Some{Con{S.Variable{+xs}, Con{+h2, +r2}}}: Empty.absurd({Codec.tagged(sel, Some{Con{S.Variable{xs}, Con{h2, r2}}}) == Some{[S.Variable{bs}]} : ${MP}}, FD.logic__none_some(+List<U32>, bs, e))

def wo(+o: Maybe<&2, S.Schema>, +sel: U32, +w: S.Value, +bs: +List<U32>,
    +e: {Codec.bytes(Codec.with_option(o, s => Codec.tagged(sel, Codec.parts(w, s)))) == Some{bs} : Maybe<&2, +List<U32>>})
    -> {Codec.with_option(o, s => Codec.tagged(sel, Codec.parts(w, s))) == Some{[S.Variable{bs}]} : ${MP}}:
  match o:
    case None{}: Empty.absurd({Codec.with_option(None{}, s => Codec.tagged(sel, Codec.parts(w, s))) == Some{[S.Variable{bs}]} : ${MP}}, FD.logic__none_some(+List<U32>, bs, e))
    case Some{+s}: tg(sel, Codec.parts(w, s), bs, e)

def rej_v(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {CHK(t, n) == False{} : Bool},
    +v: S.Value, +e: {Codec.encoding_for_legal_type(Spec.${U}(), v) == Some{VW(t, n)} : Maybe<&2, +List<U32>>}) -> Empty:
  match v:
    case S.Selected{+sel, +w}:
      FD.logic__true_false(Equal.trans(Bool, True{}, CHK(t, n), False{},
        Equal.sym(Bool, CHK(t, n), True{}, W.invw(d, t, n, 0n, 0, n, {==}, hd, hn, pf, S.Selected{sel, w},
          wo(SS.compatible_option(${WB.split_top(union_schema(U)[2])[0]}, ${WB.split_top(union_schema(U)[2])[1]}, sel), sel, w, VW(t, n), e))), hchk))
