import Base
import ../../spec/primitives.bend as SP
import ../../spec/layout.bend as Layout
import ../../spec/nat_bytes.bend as N
import ../../types/schema.bend as S
import ../compact/found_generated.bend as F
import ../compact/arith.bend as A
import ./vspec.bend as VS
import ./vrej.bend as VR
import ../../proofs/nat_bytes.bend as Digits
import ../../spec/codec.bend as Codec
import ../../spec/byte_list.bend as ByteList
import ../../proofs/decode_facts.bend as DF

# The offset layout of a list of n variable parts y_0 .. y_{n-1} (spec/layout.bend),
# over arbitrary byte lists: n offsets of four bytes (the j-th is 4 n + |y_0| + .. +
# |y_{j-1}|), then the parts' bytes. For the lists of variable-size elements of
# codegen/var_vlist.py.

def VP(ys: +List<+List<U32>>) -> +List<S.Part>:
  match ys:
    case Nil{}: []
    case Con{y, r}: Con{S.Variable{y}, VP(r)}

def OFFS(ys: +List<+List<U32>>, +off: Nat) -> +List<U32>:
  match ys:
    case Nil{}: []
    case Con{y, r}: List.append(&2, U32, N.digits(4n, off), OFFS(r, Nat.add(off, List.length(&2, U32, y))))

def CNT(ys: +List<+List<U32>>) -> Nat:
  match ys:
    case Nil{}: 0n
    case Con{y, r}: 1n+CNT(r)

law vp_size:
  for +ys: +List<+List<U32>>
  {Layout.fixed_size(VP(ys)) == A.quad(CNT(ys)) : Nat}
def vp_size(ys):
  match ys:
    case Nil{}: {==}
    case Con{+y, +r}: Equal.cong(Nat, Nat, z => 4n+z, Layout.fixed_size(VP(r)), A.quad(CNT(r)), vp_size(r))

law vp_pay:
  for +ys: +List<+List<U32>>
  {Layout.payloads(VP(ys)) == VR.bcat(ys) : +List<U32>}
def vp_pay(ys):
  match ys:
    case Nil{}: {==}
    case Con{+y, +r}: Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, y, z), Layout.payloads(VP(r)), VR.bcat(r), vp_pay(r))

law vp_fp:
  for +ys: +List<+List<U32>>
  for +off: Nat
  {Layout.fixed_parts(VP(ys), off) == OFFS(ys, off) : +List<U32>}
def vp_fp(ys, off):
  match ys:
    case Nil{}: {==}
    case Con{+y, +r}:
      Equal.cong(+List<U32>, +List<U32>, z => List.append(&2, U32, N.digits(4n, off), z),
        Layout.fixed_parts(VP(r), Nat.add(off, List.length(&2, U32, y))), OFFS(r, Nat.add(off, List.length(&2, U32, y))), vp_fp(r, Nat.add(off, List.length(&2, U32, y))))

# The layout of the parts, when their bytes are valid and fit.
law vp_enc:
  for +ys: +List<+List<U32>>
  for +hv: {Layout.bytes_valid(VP(ys)) == True{} : Bool}
  for +fit: {N.fits(4n, Nat.add(A.quad(CNT(ys)), List.length(&2, U32, VR.bcat(ys)))) == True{} : Bool}
  {Layout.encoding(VP(ys)) == Some{List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys))} : Maybe<&2, +List<U32>>}
def vp_enc(ys, hv, fit):
  +ps = VP(ys)
  %Equal.sym(Nat, Layout.fixed_size(ps), A.quad(CNT(ys)), vp_size(ys)) :
    {SP.optional(Bool.and(Layout.bytes_valid(ps), N.fits(4n, Nat.add(_, List.length(&2, U32, Layout.payloads(ps))))), List.append(&2, U32, Layout.fixed_parts(ps, _), Layout.payloads(ps))) == Some{List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, Layout.payloads(ps), VR.bcat(ys), vp_pay(ys)) :
    {SP.optional(Bool.and(Layout.bytes_valid(ps), N.fits(4n, Nat.add(A.quad(CNT(ys)), List.length(&2, U32, _)))), List.append(&2, U32, Layout.fixed_parts(ps, A.quad(CNT(ys))), _)) == Some{List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys))} : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, Layout.fixed_parts(ps, A.quad(CNT(ys))), OFFS(ys, A.quad(CNT(ys))), vp_fp(ys, A.quad(CNT(ys)))) :
    {SP.optional(Bool.and(Layout.bytes_valid(ps), N.fits(4n, Nat.add(A.quad(CNT(ys)), List.length(&2, U32, VR.bcat(ys))))), List.append(&2, U32, _, VR.bcat(ys))) == Some{List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, Layout.bytes_valid(ps), True{}, hv) :
    {SP.optional(Bool.and(_, N.fits(4n, Nat.add(A.quad(CNT(ys)), List.length(&2, U32, VR.bcat(ys))))), List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys))) == Some{List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys))} : Maybe<&2, +List<U32>>}
  %Equal.sym(Bool, N.fits(4n, Nat.add(A.quad(CNT(ys)), List.length(&2, U32, VR.bcat(ys)))), True{}, fit) :
    {SP.optional(Bool.and(True{}, _), List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys))) == Some{List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys))} : Maybe<&2, +List<U32>>}
  {==}

law vp_valid:
  for +y: +List<U32>
  for +r: +List<+List<U32>>
  for +hy: {SP.bytes_domain(y) == True{} : Bool}
  for +hr: {Layout.bytes_valid(VP(r)) == True{} : Bool}
  {Layout.bytes_valid(VP(Con{y, r})) == True{} : Bool}
def vp_valid(y, r, hy, hr):
  %Equal.sym(Bool, SP.bytes_domain(y), True{}, hy) : {Bool.and(_, Layout.bytes_valid(VP(r))) == True{} : Bool}
  %Equal.sym(Bool, Layout.bytes_valid(VP(r)), True{}, hr) : {Bool.and(True{}, _) == True{} : Bool}
  {==}

law len_bcat_cons:
  for +y: +List<U32>
  for +r: +List<+List<U32>>
  {List.length(&2, U32, VR.bcat(Con{y, r})) == Nat.add(List.length(&2, U32, y), List.length(&2, U32, VR.bcat(r))) : Nat}
def len_bcat_cons(y, r):
  VS.len_app(y, VR.bcat(r))

law len_offs:
  for +ys: +List<+List<U32>>
  for +off: Nat
  {List.length(&2, U32, OFFS(ys, off)) == A.quad(CNT(ys)) : Nat}
def len_offs(ys, off):
  match ys:
    case Nil{}: {==}
    case Con{+y, +r}:
      %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, N.digits(4n, off), OFFS(r, Nat.add(off, List.length(&2, U32, y))))),
          Nat.add(List.length(&2, U32, N.digits(4n, off)), List.length(&2, U32, OFFS(r, Nat.add(off, List.length(&2, U32, y))))),
          VS.len_app(N.digits(4n, off), OFFS(r, Nat.add(off, List.length(&2, U32, y))))) :
        {_ == A.quad(1n+CNT(r)) : Nat}
      %Equal.sym(Nat, List.length(&2, U32, N.digits(4n, off)), 4n, Digits.digits_length(4n, off)) :
        {Nat.add(_, List.length(&2, U32, OFFS(r, Nat.add(off, List.length(&2, U32, y))))) == A.quad(1n+CNT(r)) : Nat}
      Equal.cong(Nat, Nat, z => 4n+z, List.length(&2, U32, OFFS(r, Nat.add(off, List.length(&2, U32, y)))), A.quad(CNT(r)), len_offs(r, Nat.add(off, List.length(&2, U32, y))))

# ---- the inversion: from a list's spec parts back to its elements' bytes -----------------------------

# The payloads of variable parts.
def YP(ps: +List<S.Part>) -> +List<+List<U32>>:
  match ps:
    case Nil{}: []
    case Con{S.Fixed{y}, r}: YP(r)
    case Con{S.Variable{y}, r}: Con{y, YP(r)}

# The items, one each, have the one variable part ys_j under the element schema s.
def ALL(+s: S.Schema, items: S.Value, ys: +List<+List<U32>>) -> Type:
  match items ys:
    case S.Items{h, r} Con{y, q}: {Codec.parts(h, s) == Some{[S.Variable{y}]} : Maybe<&2, +List<S.Part>>} & ALL(s, r, q)
    case S.EmptyItems{} Nil{}: Unit
    case _ _: Empty

# What the parts ps of items under Repeat{s} are, when each element has one variable part.
def REP(+s: S.Schema, +items: S.Value, +ps: +List<S.Part>) -> Type:
  {ps == VP(YP(ps)) : +List<S.Part>} & ({Codec.count(items) == CNT(YP(ps)) : Nat} & ALL(s, items, YP(ps)))

# A byte list's parts are at most one variable part.
def bs_one(+m: Maybe<&2, +List<U32>>) -> DF.single_result(None{}, Codec.one(m, None{})):
  match m:
    case None{}: Unit{}
    case Some{+z}: {==}

def bsingle(+n: Nat, +h: S.Value) -> DF.single_result(None{}, Codec.parts(h, S.ByteList{n})):
  match h:
    case S.BytesValue{+xs}: bs_one(ByteList.encoding(n, xs))
    case S.BooleanValue{+b0}: Unit{}
    case S.UnsignedValue{+u0}: Unit{}
    case S.BitsValue{+bs0}: Unit{}
    case S.Sequence{+it0}: Unit{}
    case S.Items{+hd0, +tl0}: Unit{}
    case S.EmptyItems{}: Unit{}
    case S.Selected{+sel0, +sv0}: Unit{}
    case S.NullValue{}: Unit{}

def rep_t2(+s: S.Schema, +h: S.Value, +t: S.Value, +y: +List<U32>, +pt: +List<S.Part>,
    +eh: {Codec.parts(h, s) == Some{[S.Variable{y}]} : Maybe<&2, +List<S.Part>>}, r: REP(s, t, pt))
    -> REP(s, S.Items{h, t}, Con{S.Variable{y}, pt}):
  (+ep, +ec, al) = r
  (Equal.cong(+List<S.Part>, +List<S.Part>, z => Con{S.Variable{y}, z}, pt, VP(YP(pt)), ep), Equal.cong(Nat, Nat, z => 1n+z, Codec.count(t), CNT(YP(pt)), ec), eh, al)

def rep_t(+s: S.Schema, +h: S.Value, +t: S.Value, +ps: +List<S.Part>, +y: +List<U32>,
    +eh: {Codec.parts(h, s) == Some{[S.Variable{y}]} : Maybe<&2, +List<S.Part>>}, +mt: Maybe<&2, +List<S.Part>>, +et: {Codec.parts(t, S.Repeat{s}) == mt : Maybe<&2, +List<S.Part>>},
    +e: {Codec.concatenate(Some{[S.Variable{y}]}, mt) == Some{ps} : Maybe<&2, +List<S.Part>>},
    ih: @+pt: +List<S.Part> -> {Codec.parts(t, S.Repeat{s}) == Some{pt} : Maybe<&2, +List<S.Part>>} -> REP(s, t, pt))
    -> REP(s, S.Items{h, t}, ps):
  match mt:
    case None{}: Empty.absurd(REP(s, S.Items{h, t}, ps), F.logic__none_some(+List<S.Part>, ps, e))
    case Some{+pt}:
      +eps = F.logic__some_inj(+List<S.Part>, Con{S.Variable{y}, pt}, ps, e)
      %Equal.sym(+List<S.Part>, ps, Con{S.Variable{y}, pt}, Equal.sym(+List<S.Part>, Con{S.Variable{y}, pt}, ps, eps)) : REP(s, S.Items{h, t}, _)
      rep_t2(s, h, t, y, pt, eh, ih(pt, et))

def rep_p(+s: S.Schema, +h: S.Value, +t: S.Value, +ps: +List<S.Part>, +ph: +List<S.Part>, hf: DF.single(None{}, ph),
    +eh: {Codec.parts(h, s) == Some{ph} : Maybe<&2, +List<S.Part>>}, +e: {Codec.concatenate(Some{ph}, Codec.parts(t, S.Repeat{s})) == Some{ps} : Maybe<&2, +List<S.Part>>},
    ih: @+pt: +List<S.Part> -> {Codec.parts(t, S.Repeat{s}) == Some{pt} : Maybe<&2, +List<S.Part>>} -> REP(s, t, pt))
    -> REP(s, S.Items{h, t}, ps):
  match ph:
    case Nil{}: Empty.absurd(REP(s, S.Items{h, t}, ps), hf)
    case Con{S.Fixed{+xs}, Nil{}}: Empty.absurd(REP(s, S.Items{h, t}, ps), F.logic__none_some(Nat, List.length(&2, U32, xs), hf))
    case Con{S.Variable{+y}, Nil{}}: rep_t(s, h, t, ps, y, eh, Codec.parts(t, S.Repeat{s}), {==}, e, ih)
    case Con{S.Fixed{+xs}, Con{+a2, +b2}}: Empty.absurd(REP(s, S.Items{h, t}, ps), hf)
    case Con{S.Variable{+xs}, Con{+a2, +b2}}: Empty.absurd(REP(s, S.Items{h, t}, ps), hf)

# The parts of an item h then items t, h with at most one variable part.
def rep_h(+s: S.Schema, +h: S.Value, +t: S.Value, +ps: +List<S.Part>, +mh: Maybe<&2, +List<S.Part>>, hf: DF.single_result(None{}, mh),
    +eh: {Codec.parts(h, s) == mh : Maybe<&2, +List<S.Part>>}, +e: {Codec.concatenate(mh, Codec.parts(t, S.Repeat{s})) == Some{ps} : Maybe<&2, +List<S.Part>>},
    ih: @+pt: +List<S.Part> -> {Codec.parts(t, S.Repeat{s}) == Some{pt} : Maybe<&2, +List<S.Part>>} -> REP(s, t, pt))
    -> REP(s, S.Items{h, t}, ps):
  match mh:
    case None{}: Empty.absurd(REP(s, S.Items{h, t}, ps), F.logic__none_some(+List<S.Part>, ps, e))
    case Some{+ph}: rep_p(s, h, t, ps, ph, hf, eh, e, ih)

# The layout of variable parts, its guard left open.
law vp_encb:
  for +ys: +List<+List<U32>>
  {Layout.encoding(VP(ys)) == SP.optional(Bool.and(Layout.bytes_valid(VP(ys)), N.fits(4n, Nat.add(A.quad(CNT(ys)), List.length(&2, U32, VR.bcat(ys))))), List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys))) : Maybe<&2, +List<U32>>}
def vp_encb(ys):
  +ps = VP(ys)
  +G = SP.optional(Bool.and(Layout.bytes_valid(ps), N.fits(4n, Nat.add(A.quad(CNT(ys)), List.length(&2, U32, VR.bcat(ys))))), List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys)))
  %Equal.sym(Nat, Layout.fixed_size(ps), A.quad(CNT(ys)), vp_size(ys)) :
    {SP.optional(Bool.and(Layout.bytes_valid(ps), N.fits(4n, Nat.add(_, List.length(&2, U32, Layout.payloads(ps))))), List.append(&2, U32, Layout.fixed_parts(ps, _), Layout.payloads(ps))) == G : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, Layout.payloads(ps), VR.bcat(ys), vp_pay(ys)) :
    {SP.optional(Bool.and(Layout.bytes_valid(ps), N.fits(4n, Nat.add(A.quad(CNT(ys)), List.length(&2, U32, _)))), List.append(&2, U32, Layout.fixed_parts(ps, A.quad(CNT(ys))), _)) == G : Maybe<&2, +List<U32>>}
  %Equal.sym(+List<U32>, Layout.fixed_parts(ps, A.quad(CNT(ys))), OFFS(ys, A.quad(CNT(ys))), vp_fp(ys, A.quad(CNT(ys)))) :
    {SP.optional(Bool.and(Layout.bytes_valid(ps), N.fits(4n, Nat.add(A.quad(CNT(ys)), List.length(&2, U32, VR.bcat(ys))))), List.append(&2, U32, _, VR.bcat(ys))) == G : Maybe<&2, +List<U32>>}
  {==}

# What a list's encoding W says: the offsets table of its elements' bytes ys, then ys; at most lim of them.
def LST(+s: S.Schema, +lim: Nat, +items: S.Value, +W: +List<U32>, +ys: +List<+List<U32>>) -> Type:
  {W == List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys)) : +List<U32>} & ({Nat.is_le(CNT(ys), lim) == True{} : Bool} & ALL(s, items, ys))

def vpay(ps: +List<S.Part>) -> +List<U32>:
  match ps:
    case Con{S.Variable{ys}, Nil{}}: ys
    case _: []

def vinj(+a: +List<U32>, +b: +List<U32>, +e: {Some{[S.Variable{a}]} == Some{[S.Variable{b}]} : Maybe<&2, +List<S.Part>>}) -> {a == b : +List<U32>}:
  Equal.cong(+List<S.Part>, +List<U32>, z => vpay(z), [S.Variable{a}], [S.Variable{b}], F.logic__some_inj(+List<S.Part>, [S.Variable{a}], [S.Variable{b}], e))

def inv_b2(+s: S.Schema, +lim: Nat, +items: S.Value, +W: +List<U32>, +ys: +List<+List<U32>>, al: ALL(s, items, ys),
    +hl: {Nat.is_le(CNT(ys), lim) == True{} : Bool}, +b2: Bool,
    +e: {Codec.one(SP.optional(b2, List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys))), None{}) == Some{[S.Variable{W}]} : Maybe<&2, +List<S.Part>>})
    -> LST(s, lim, items, W, ys):
  match b2:
    case False{}: Empty.absurd(LST(s, lim, items, W, ys), F.logic__none_some(+List<S.Part>, [S.Variable{W}], e))
    case True{}:
      (Equal.sym(+List<U32>, List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys)), W, vinj(List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys)), W, e)), hl, al)

def inv_b1(+s: S.Schema, +lim: Nat, +items: S.Value, +W: +List<U32>, +ys: +List<+List<U32>>, al: ALL(s, items, ys),
    +b1: Bool, +eb1: {Nat.is_le(CNT(ys), lim) == b1 : Bool},
    +e: {Codec.require(b1, Codec.one(Layout.encoding(VP(ys)), None{})) == Some{[S.Variable{W}]} : Maybe<&2, +List<S.Part>>})
    -> LST(s, lim, items, W, ys):
  match b1:
    case False{}: Empty.absurd(LST(s, lim, items, W, ys), F.logic__none_some(+List<S.Part>, [S.Variable{W}], e))
    case True{}:
      +G = SP.optional(Bool.and(Layout.bytes_valid(VP(ys)), N.fits(4n, Nat.add(A.quad(CNT(ys)), List.length(&2, U32, VR.bcat(ys))))), List.append(&2, U32, OFFS(ys, A.quad(CNT(ys))), VR.bcat(ys)))
      inv_b2(s, lim, items, W, ys, al, eb1, Bool.and(Layout.bytes_valid(VP(ys)), N.fits(4n, Nat.add(A.quad(CNT(ys)), List.length(&2, U32, VR.bcat(ys))))),
        F.logic__subst(Maybe<&2, +List<U32>>, z => {Codec.one(z, None{}) == Some{[S.Variable{W}]} : Maybe<&2, +List<S.Part>>}, Layout.encoding(VP(ys)), G, vp_encb(ys), e))

# A list value whose parts under Repeat{s} are ps, and whose layout is the one variable part W.
def inv_enc(+s: S.Schema, +lim: Nat, +items: S.Value, +W: +List<U32>, +ps: +List<S.Part>, r: REP(s, items, ps),
    +e: {Codec.require(Nat.is_le(Codec.count(items), lim), Codec.aggregate(Some{ps}, None{})) == Some{[S.Variable{W}]} : Maybe<&2, +List<S.Part>>})
    -> LST(s, lim, items, W, YP(ps)):
  (+ep, +ec, al) = r
  +e1 = F.logic__subst(+List<S.Part>, z => {Codec.require(Nat.is_le(Codec.count(items), lim), Codec.one(Layout.encoding(z), None{})) == Some{[S.Variable{W}]} : Maybe<&2, +List<S.Part>>}, ps, VP(YP(ps)), ep, e)
  +e2 = F.logic__subst(Nat, z => {Codec.require(Nat.is_le(z, lim), Codec.one(Layout.encoding(VP(YP(ps))), None{})) == Some{[S.Variable{W}]} : Maybe<&2, +List<S.Part>>}, Codec.count(items), CNT(YP(ps)), ec, e1)
  inv_b1(s, lim, items, W, YP(ps), al, Nat.is_le(CNT(YP(ps)), lim), {==}, e2)

# 4 more bytes after p: p + 4 <= |xs|.
law bdr_room:
  for +p: Nat
  for +xs: +List<U32>
  for +h: {Nat.is_le(4n, List.length(&2, U32, VS.bdr(p, xs))) == True{} : Bool}
  {Nat.is_le(Nat.add(p, 4n), List.length(&2, U32, xs)) == True{} : Bool}
def bdr_room(p, xs, h):
  match p xs:
    case 0n _: h
    case 1n+ +q Nil{}: Empty.absurd({Nat.is_le(Nat.add(1n+q, 4n), 0n) == True{} : Bool}, F.logic__false_true(h))
    case 1n+ +q Con{+x, +r}: bdr_room(q, r, h)

# a + 1 + b is not a.
law nself:
  for +a: Nat
  for +b: Nat
  for +e: {Nat.add(a, 1n+b) == a : Nat}
  Empty
def nself(a, b, e):
  match a:
    case 0n: F.logic__false_true(Equal.cong(Nat, Bool, z => Nat.is_eq(z, 0n), 1n+b, 0n, e))
    case 1n+ +p: nself(p, b, F.nat__succ_inj(Nat.add(p, 1n+b), p, e))
