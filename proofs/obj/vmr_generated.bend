import Base
import ../../spec/primitives.bend as SP
import ../../spec/layout.bend as Layout
import ../../spec/codec.bend as Codec
import ../../spec/bytes.bend as Bytes
import ../../spec/nat_bytes.bend as N
import ../../types/schema.bend as S
import ../compact/found_generated.bend as F
import ../compact/arith.bend as A
import ../../proofs/nat_order.bend as Order
import ./spec_fixed.bend as FX
import ./dk.bend as DK
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vu32.bend as VU
import ./vfits.bend as VFT
import ./vrej.bend as VR
import ./vnest.bend as VN

# GENERATED from vmr.bend.in by multi_variable_field_codec_laws (codegen). Do not edit.
# Variable-size rejection with THREE variable parts, specification side: the
# encoding of a list of byte vectors has a whole number of elements, and the
# offset layout of [one fixed part | three variable parts | fixed parts] puts
# the three offsets right after the first part. Everything is over arbitrary
# byte lists and symbolic sizes.

# ---- a list of byte vectors ------------------------------------------------------------------

law scope_len:
  for +n: Nat
  for +xs: +List<U32>
  for +h: {SP.byte_scope(n, xs) == True{} : Bool}
  {List.length(&2, U32, xs) == n : Nat}
def scope_len(n, xs, h):
  match n xs:
    case 0n Nil{}: {==}
    case 0n Con{+x, +r}: Empty.absurd({List.length(&2, U32, Con{x, r}) == 0n : Nat}, F.logic__false_true(h))
    case 1n+ +p Nil{}: Empty.absurd({List.length(&2, U32, Nil{}) == 1n+p : Nat}, F.logic__false_true(h))
    case 1n+ +p Con{+x, +r}: F.nat__succ_cong(List.length(&2, U32, r), p, scope_len(p, r, F.logic__and_right(U32.is_lt(x, 256), SP.byte_scope(p, r), h)))

def BVS(+p: Nat) -> S.Schema: S.ByteVector{1n+p}

def REPB(+its: S.Value, +ps: +List<S.Part>, +B: Nat) -> Type:
  {VS.allfix(ps) == True{} : Bool} & {Layout.fixed_size(ps) == Nat.mul(Codec.count(its), B) : Nat}

def rpb_len(+xs: +List<U32>, +pb: +List<S.Part>, +t: S.Value, +B: Nat, +lx: {List.length(&2, U32, xs) == B : Nat},
    +hs: {Layout.fixed_size(pb) == Nat.mul(Codec.count(t), B) : Nat})
    -> {Nat.add(List.length(&2, U32, xs), Layout.fixed_size(pb)) == Nat.add(B, Nat.mul(Codec.count(t), B)) : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, xs), B, lx) : {Nat.add(_, Layout.fixed_size(pb)) == Nat.add(B, Nat.mul(Codec.count(t), B)) : Nat}
  %Equal.sym(Nat, Layout.fixed_size(pb), Nat.mul(Codec.count(t), B), hs) : {Nat.add(B, _) == Nat.add(B, Nat.mul(Codec.count(t), B)) : Nat}
  {==}

def rpb_t2(+xs: +List<U32>, +el: S.Value, +t: S.Value, +pb: +List<S.Part>, +B: Nat, +lx: {List.length(&2, U32, xs) == B : Nat}, r: REPB(t, pb, B))
    -> REPB(S.Items{el, t}, S.Fixed{xs} <> pb, B):
  (+ha, +hs) = r
  (ha, rpb_len(xs, pb, t, B, lx, hs))

def rpb_t(+xs: +List<U32>, +el: S.Value, +t: S.Value, +ps: +List<S.Part>, +p: Nat, +mB: Maybe<&2, +List<S.Part>>,
    +eB: {Codec.parts(t, S.Repeat{BVS(p)}) == mB : Maybe<&2, +List<S.Part>>},
    +lx: {List.length(&2, U32, xs) == 1n+p : Nat},
    +e: {Codec.concatenate(Some{[S.Fixed{xs}]}, mB) == Some{ps} : Maybe<&2, +List<S.Part>>},
    ih: @+pb: +List<S.Part> -> {Codec.parts(t, S.Repeat{BVS(p)}) == Some{pb} : Maybe<&2, +List<S.Part>>} -> REPB(t, pb, 1n+p))
    -> REPB(S.Items{el, t}, ps, 1n+p):
  match mB:
    case None{}: Empty.absurd(REPB(S.Items{el, t}, ps, 1n+p), F.logic__none_some(+List<S.Part>, ps, e))
    case Some{+pb}:
      +eps = F.logic__some_inj(+List<S.Part>, S.Fixed{xs} <> pb, ps, e)
      %Equal.sym(+List<S.Part>, ps, S.Fixed{xs} <> pb, Equal.sym(+List<S.Part>, S.Fixed{xs} <> pb, ps, eps)) : REPB(S.Items{el, t}, _, 1n+p)
      rpb_t2(xs, el, t, pb, 1n+p, lx, ih(pb, eB))

def rpb_b2(+xs: +List<U32>, +t: S.Value, +ps: +List<S.Part>, +p: Nat, +hs: {SP.byte_scope(1n+p, xs) == True{} : Bool}, +b2: Bool,
    +e: {Codec.concatenate(Codec.one(SP.optional(Bool.and(True{}, b2), xs), Some{1n+p}), Codec.parts(t, S.Repeat{BVS(p)})) == Some{ps} : Maybe<&2, +List<S.Part>>},
    ih: @+pb: +List<S.Part> -> {Codec.parts(t, S.Repeat{BVS(p)}) == Some{pb} : Maybe<&2, +List<S.Part>>} -> REPB(t, pb, 1n+p))
    -> REPB(S.Items{S.BytesValue{xs}, t}, ps, 1n+p):
  match b2:
    case False{}: Empty.absurd(REPB(S.Items{S.BytesValue{xs}, t}, ps, 1n+p), F.logic__none_some(+List<S.Part>, ps, e))
    case True{}: rpb_t(xs, S.BytesValue{xs}, t, ps, p, Codec.parts(t, S.Repeat{BVS(p)}), {==}, scope_len(1n+p, xs, hs), e, ih)

def rpb_b1(+xs: +List<U32>, +t: S.Value, +ps: +List<S.Part>, +p: Nat, +b1: Bool, +eb1: {SP.byte_scope(1n+p, xs) == b1 : Bool},
    +e: {Codec.concatenate(Codec.one(SP.optional(Bool.and(b1, Bytes.size_fits(1n+p)), xs), Some{1n+p}), Codec.parts(t, S.Repeat{BVS(p)})) == Some{ps} : Maybe<&2, +List<S.Part>>},
    ih: @+pb: +List<S.Part> -> {Codec.parts(t, S.Repeat{BVS(p)}) == Some{pb} : Maybe<&2, +List<S.Part>>} -> REPB(t, pb, 1n+p))
    -> REPB(S.Items{S.BytesValue{xs}, t}, ps, 1n+p):
  match b1:
    case False{}: Empty.absurd(REPB(S.Items{S.BytesValue{xs}, t}, ps, 1n+p), F.logic__none_some(+List<S.Part>, ps, e))
    case True{}: rpb_b2(xs, t, ps, p, eb1, Bytes.size_fits(1n+p), e, ih)

# The parts of k byte vectors of 1 + p bytes are k fixed parts of (1 + p) k bytes.
law rep_b:
  for +its: S.Value
  for +ps: +List<S.Part>
  for +p: Nat
  for +e: {Codec.parts(its, S.Repeat{BVS(p)}) == Some{ps} : Maybe<&2, +List<S.Part>>}
  REPB(its, ps, 1n+p)
def rep_b(its, ps, p, e):
  match its:
    case S.EmptyItems{}:
      +eps = F.logic__some_inj(+List<S.Part>, [], ps, e)
      %Equal.sym(+List<S.Part>, ps, [], Equal.sym(+List<S.Part>, [], ps, eps)) : REPB(S.EmptyItems{}, _, 1n+p)
      ({==}, {==})
    case S.Items{S.BytesValue{+xs}, +t}:
      rpb_b1(xs, t, ps, p, SP.byte_scope(1n+p, xs), {==}, e, pb => eb => rep_b(t, pb, p, eb))
    case S.BooleanValue{+b}: Empty.absurd(REPB(S.BooleanValue{b}, ps, 1n+p), F.logic__none_some(+List<S.Part>, ps, e))
    case S.UnsignedValue{+u}: Empty.absurd(REPB(S.UnsignedValue{u}, ps, 1n+p), F.logic__none_some(+List<S.Part>, ps, e))
    case S.BytesValue{+xs}: Empty.absurd(REPB(S.BytesValue{xs}, ps, 1n+p), F.logic__none_some(+List<S.Part>, ps, e))
    case S.BitsValue{+bs}: Empty.absurd(REPB(S.BitsValue{bs}, ps, 1n+p), F.logic__none_some(+List<S.Part>, ps, e))
    case S.Sequence{+it}: Empty.absurd(REPB(S.Sequence{it}, ps, 1n+p), F.logic__none_some(+List<S.Part>, ps, e))
    case S.Selected{+sel, +sv}: Empty.absurd(REPB(S.Selected{sel, sv}, ps, 1n+p), F.logic__none_some(+List<S.Part>, ps, e))
    case S.NullValue{}: Empty.absurd(REPB(S.NullValue{}, ps, 1n+p), F.logic__none_some(+List<S.Part>, ps, e))
    case S.Items{S.BooleanValue{+b}, +t}: Empty.absurd(REPB(S.Items{S.BooleanValue{b}, t}, ps, 1n+p), F.logic__none_some(+List<S.Part>, ps, e))
    case S.Items{S.UnsignedValue{+u}, +t}: Empty.absurd(REPB(S.Items{S.UnsignedValue{u}, t}, ps, 1n+p), F.logic__none_some(+List<S.Part>, ps, e))
    case S.Items{S.BitsValue{+bs}, +t}: Empty.absurd(REPB(S.Items{S.BitsValue{bs}, t}, ps, 1n+p), F.logic__none_some(+List<S.Part>, ps, e))
    case S.Items{S.Sequence{+it}, +t}: Empty.absurd(REPB(S.Items{S.Sequence{it}, t}, ps, 1n+p), F.logic__none_some(+List<S.Part>, ps, e))
    case S.Items{S.Items{+hd, +tl}, +t}: Empty.absurd(REPB(S.Items{S.Items{hd, tl}, t}, ps, 1n+p), F.logic__none_some(+List<S.Part>, ps, e))
    case S.Items{S.EmptyItems{}, +t}: Empty.absurd(REPB(S.Items{S.EmptyItems{}, t}, ps, 1n+p), F.logic__none_some(+List<S.Part>, ps, e))
    case S.Items{S.Selected{+sel, +sv}, +t}: Empty.absurd(REPB(S.Items{S.Selected{sel, sv}, t}, ps, 1n+p), F.logic__none_some(+List<S.Part>, ps, e))
    case S.Items{S.NullValue{}, +t}: Empty.absurd(REPB(S.Items{S.NullValue{}, t}, ps, 1n+p), F.logic__none_some(+List<S.Part>, ps, e))

# What the encoding of a list of at most lim byte vectors of B bytes says: its length is B k, k <= lim.
def LF(+ys: +List<U32>, +B: Nat, +lim: Nat) -> Data:
  DK.Ex(Nat, k => DK.P2({List.length(&2, U32, ys) == Nat.mul(k, B) : Nat}, {Nat.is_le(k, lim) == True{} : Bool}))

def lm4(+its: S.Value, +ys: +List<U32>, +p: Nat, +lim: Nat, +hk: {Nat.is_le(Codec.count(its), lim) == True{} : Bool}, +ps: +List<S.Part>,
    +em3: {Codec.parts(its, S.Repeat{BVS(p)}) == Some{ps} : Maybe<&2, +List<S.Part>>}, +m4: Maybe<&2, +List<U32>>,
    +em4: {Layout.encoding(ps) == m4 : Maybe<&2, +List<U32>>}, +e: {Codec.bytes(Codec.one(m4, None{})) == Some{ys} : Maybe<&2, +List<U32>>})
    -> LF(ys, 1n+p, lim):
  match m4:
    case None{}: Empty.absurd(LF(ys, 1n+p, lim), F.logic__none_some(+List<U32>, ys, e))
    case Some{+zs}:
      +ez = F.logic__some_inj(+List<U32>, zs, ys, e)
      +lz = Equal.trans(Nat, List.length(&2, U32, zs), Layout.fixed_size(ps), Nat.mul(Codec.count(its), 1n+p),
        VS.enc_len(ps, zs, Pair.fst({VS.allfix(ps) == True{} : Bool}, {Layout.fixed_size(ps) == Nat.mul(Codec.count(its), 1n+p) : Nat}, rep_b(its, ps, p, em3)), em4),
        Pair.snd({VS.allfix(ps) == True{} : Bool}, {Layout.fixed_size(ps) == Nat.mul(Codec.count(its), 1n+p) : Nat}, rep_b(its, ps, p, em3)))
      (Codec.count(its), (F.logic__subst(+List<U32>, z => {List.length(&2, U32, z) == Nat.mul(Codec.count(its), 1n+p) : Nat}, zs, ys, ez, lz), hk))

def lm3(+its: S.Value, +ys: +List<U32>, +p: Nat, +lim: Nat, +hk: {Nat.is_le(Codec.count(its), lim) == True{} : Bool}, +m3: Maybe<&2, +List<S.Part>>,
    +em3: {Codec.parts(its, S.Repeat{BVS(p)}) == m3 : Maybe<&2, +List<S.Part>>}, +e: {Codec.bytes(Codec.aggregate(m3, None{})) == Some{ys} : Maybe<&2, +List<U32>>})
    -> LF(ys, 1n+p, lim):
  match m3:
    case None{}: Empty.absurd(LF(ys, 1n+p, lim), F.logic__none_some(+List<U32>, ys, e))
    case Some{+ps}: lm4(its, ys, p, lim, hk, ps, em3, Layout.encoding(ps), {==}, e)

def lb(+its: S.Value, +ys: +List<U32>, +p: Nat, +lim: Nat, +b: Bool, +eb: {Nat.is_le(Codec.count(its), lim) == b : Bool},
    +e: {Codec.bytes(Codec.require(b, Codec.aggregate(Codec.parts(its, S.Repeat{BVS(p)}), None{}))) == Some{ys} : Maybe<&2, +List<U32>>})
    -> LF(ys, 1n+p, lim):
  match b:
    case False{}: Empty.absurd(LF(ys, 1n+p, lim), F.logic__none_some(+List<U32>, ys, e))
    case True{}: lm3(its, ys, p, lim, eb, Codec.parts(its, S.Repeat{BVS(p)}), {==}, e)

law linv:
  for +h: S.Value
  for +ys: +List<U32>
  for +p: Nat
  for +lim: Nat
  for +e: {Codec.bytes(Codec.parts(h, S.ListOf{BVS(p), lim})) == Some{ys} : Maybe<&2, +List<U32>>}
  LF(ys, 1n+p, lim)
def linv(h, ys, p, lim, e):
  match h:
    case S.Sequence{+its}: lb(its, ys, p, lim, Nat.is_le(Codec.count(its), lim), {==}, e)
    case S.BooleanValue{+b0}: Empty.absurd(LF(ys, 1n+p, lim), F.logic__none_some(+List<U32>, ys, e))
    case S.UnsignedValue{+u0}: Empty.absurd(LF(ys, 1n+p, lim), F.logic__none_some(+List<U32>, ys, e))
    case S.BytesValue{+xs0}: Empty.absurd(LF(ys, 1n+p, lim), F.logic__none_some(+List<U32>, ys, e))
    case S.BitsValue{+bs0}: Empty.absurd(LF(ys, 1n+p, lim), F.logic__none_some(+List<U32>, ys, e))
    case S.Items{+hd0, +tl0}: Empty.absurd(LF(ys, 1n+p, lim), F.logic__none_some(+List<U32>, ys, e))
    case S.EmptyItems{}: Empty.absurd(LF(ys, 1n+p, lim), F.logic__none_some(+List<U32>, ys, e))
    case S.Selected{+sel0, +sv0}: Empty.absurd(LF(ys, 1n+p, lim), F.logic__none_some(+List<U32>, ys, e))
    case S.NullValue{}: Empty.absurd(LF(ys, 1n+p, lim), F.logic__none_some(+List<U32>, ys, e))

# ---- the layout of [x0 | y0 | y1 | y2 | post] ---------------------------------------------------

def PR3(+x0: +List<U32>, +y0: +List<U32>, +y1: +List<U32>, +y2: +List<U32>, +post: +List<+List<U32>>) -> +List<S.Part>:
  Con{S.Fixed{x0}, Con{S.Variable{y0}, Con{S.Variable{y1}, Con{S.Variable{y2}, VR.bfix(post)}}}}

def FR(+x0: +List<U32>, +post: +List<+List<U32>>) -> Nat: Nat.add(List.length(&2, U32, x0), 12n+VR.lens(post))

def OUTR(+x0: +List<U32>, +y0: +List<U32>, +y1: +List<U32>, +y2: +List<U32>, +post: +List<+List<U32>>) -> +List<U32>:
  List.append(&2, U32, Layout.fixed_parts(PR3(x0, y0, y1, y2, post), Layout.fixed_size(PR3(x0, y0, y1, y2, post))), Layout.payloads(PR3(x0, y0, y1, y2, post)))

def R1(+x0: +List<U32>, +y0: +List<U32>, +y1: +List<U32>, +post: +List<+List<U32>>) -> +List<U32>:
  List.append(&2, U32, N.digits(4n, FR(x0, post)), List.append(&2, U32, N.digits(4n, Nat.add(FR(x0, post), List.length(&2, U32, y0))),
    List.append(&2, U32, N.digits(4n, Nat.add(Nat.add(FR(x0, post), List.length(&2, U32, y0)), List.length(&2, U32, y1))), VR.bcat(post))))

def PAY(+y0: +List<U32>, +y1: +List<U32>, +y2: +List<U32>) -> +List<U32>: List.append(&2, U32, y0, List.append(&2, U32, y1, y2))

def OUTN(+x0: +List<U32>, +y0: +List<U32>, +y1: +List<U32>, +y2: +List<U32>, +post: +List<+List<U32>>) -> +List<U32>:
  List.append(&2, U32, List.append(&2, U32, x0, R1(x0, y0, y1, post)), PAY(y0, y1, y2))

law out_n:
  for +x0: +List<U32>
  for +y0: +List<U32>
  for +y1: +List<U32>
  for +y2: +List<U32>
  for +post: +List<+List<U32>>
  {OUTR(x0, y0, y1, y2, post) == OUTN(x0, y0, y1, y2, post) : +List<U32>}
def out_n(x0, y0, y1, y2, post):
  +ps = PR3(x0, y0, y1, y2, post)
  +F0 = FR(x0, post)
  +X1 = Nat.add(F0, List.length(&2, U32, y0))
  +X2 = Nat.add(Nat.add(F0, List.length(&2, U32, y0)), List.length(&2, U32, y1))
  +X3 = Nat.add(Nat.add(Nat.add(F0, List.length(&2, U32, y0)), List.length(&2, U32, y1)), List.length(&2, U32, y2))
  %Equal.sym(Nat, Layout.fixed_size(VR.bfix(post)), VR.lens(post), VR.size_bfix(post)) :
    {List.append(&2, U32, Layout.fixed_parts(ps, Nat.add(List.length(&2, U32, x0), Nat.add(4n, Nat.add(4n, Nat.add(4n, _))))), Layout.payloads(ps)) == OUTN(x0, y0, y1, y2, post) : +List<U32>}
  %Equal.sym(+List<U32>, Layout.fixed_parts(VR.bfix(post), X3), VR.bcat(post), VR.fp_bfix(post, X3)) :
    {List.append(&2, U32, List.append(&2, U32, x0, List.append(&2, U32, N.digits(4n, F0), List.append(&2, U32, N.digits(4n, X1), List.append(&2, U32, N.digits(4n, X2), _)))), Layout.payloads(ps)) == OUTN(x0, y0, y1, y2, post) : +List<U32>}
  %Equal.sym(+List<U32>, Layout.payloads(VR.bfix(post)), [], VR.pay_bfix(post)) :
    {List.append(&2, U32, List.append(&2, U32, x0, R1(x0, y0, y1, post)), List.append(&2, U32, y0, List.append(&2, U32, y1, List.append(&2, U32, y2, _)))) == OUTN(x0, y0, y1, y2, post) : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, y2, []), y2, VS.app_nil(y2)) :
    {List.append(&2, U32, List.append(&2, U32, x0, R1(x0, y0, y1, post)), List.append(&2, U32, y0, List.append(&2, U32, y1, _))) == OUTN(x0, y0, y1, y2, post) : +List<U32>}
  {==}

def h8(+x0: +List<U32>, +y0: +List<U32>, +y1: +List<U32>, +y2: +List<U32>, +post: +List<+List<U32>>, +l0: {List.length(&2, U32, x0) == 8n : Nat})
    -> {VS.bdr(8n, OUTN(x0, y0, y1, y2, post)) == List.append(&2, U32, R1(x0, y0, y1, post), PAY(y0, y1, y2)) : +List<U32>}:
  %l0 : {VS.bdr(_, OUTN(x0, y0, y1, y2, post)) == List.append(&2, U32, R1(x0, y0, y1, post), PAY(y0, y1, y2)) : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, x0, R1(x0, y0, y1, post)), PAY(y0, y1, y2)), List.append(&2, U32, x0, List.append(&2, U32, R1(x0, y0, y1, post), PAY(y0, y1, y2))),
      VS.app_assoc(x0, R1(x0, y0, y1, post), PAY(y0, y1, y2))) :
    {VS.bdr(List.length(&2, U32, x0), _) == List.append(&2, U32, R1(x0, y0, y1, post), PAY(y0, y1, y2)) : +List<U32>}
  VS.bdr_app(x0, List.append(&2, U32, R1(x0, y0, y1, post), PAY(y0, y1, y2)))

# The three offsets, at bytes 8, 12, 16 (the first part has 8 bytes).
def r_b0(+x0: +List<U32>, +y0: +List<U32>, +y1: +List<U32>, +y2: +List<U32>, +post: +List<+List<U32>>, +l0: {List.length(&2, U32, x0) == 8n : Nat})
    -> {VS.bt(4n, VS.bdr(8n, OUTN(x0, y0, y1, y2, post))) == N.digits(4n, FR(x0, post)) : +List<U32>}:
  %Equal.sym(+List<U32>, VS.bdr(8n, OUTN(x0, y0, y1, y2, post)), List.append(&2, U32, R1(x0, y0, y1, post), PAY(y0, y1, y2)), h8(x0, y0, y1, y2, post, l0)) :
    {VS.bt(4n, _) == N.digits(4n, FR(x0, post)) : +List<U32>}
  {==}

def r_b1(+x0: +List<U32>, +y0: +List<U32>, +y1: +List<U32>, +y2: +List<U32>, +post: +List<+List<U32>>, +l0: {List.length(&2, U32, x0) == 8n : Nat})
    -> {VS.bt(4n, VS.bdr(12n, OUTN(x0, y0, y1, y2, post))) == N.digits(4n, Nat.add(FR(x0, post), List.length(&2, U32, y0))) : +List<U32>}:
  %Equal.sym(+List<U32>, VS.bdr(Nat.add(8n, 4n), OUTN(x0, y0, y1, y2, post)), VS.bdr(4n, VS.bdr(8n, OUTN(x0, y0, y1, y2, post))), VN.bdr_add(8n, 4n, OUTN(x0, y0, y1, y2, post))) :
    {VS.bt(4n, _) == N.digits(4n, Nat.add(FR(x0, post), List.length(&2, U32, y0))) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(8n, OUTN(x0, y0, y1, y2, post)), List.append(&2, U32, R1(x0, y0, y1, post), PAY(y0, y1, y2)), h8(x0, y0, y1, y2, post, l0)) :
    {VS.bt(4n, VS.bdr(4n, _)) == N.digits(4n, Nat.add(FR(x0, post), List.length(&2, U32, y0))) : +List<U32>}
  {==}

def r_b2(+x0: +List<U32>, +y0: +List<U32>, +y1: +List<U32>, +y2: +List<U32>, +post: +List<+List<U32>>, +l0: {List.length(&2, U32, x0) == 8n : Nat})
    -> {VS.bt(4n, VS.bdr(16n, OUTN(x0, y0, y1, y2, post))) == N.digits(4n, Nat.add(Nat.add(FR(x0, post), List.length(&2, U32, y0)), List.length(&2, U32, y1))) : +List<U32>}:
  %Equal.sym(+List<U32>, VS.bdr(Nat.add(8n, 8n), OUTN(x0, y0, y1, y2, post)), VS.bdr(8n, VS.bdr(8n, OUTN(x0, y0, y1, y2, post))), VN.bdr_add(8n, 8n, OUTN(x0, y0, y1, y2, post))) :
    {VS.bt(4n, _) == N.digits(4n, Nat.add(Nat.add(FR(x0, post), List.length(&2, U32, y0)), List.length(&2, U32, y1))) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(8n, OUTN(x0, y0, y1, y2, post)), List.append(&2, U32, R1(x0, y0, y1, post), PAY(y0, y1, y2)), h8(x0, y0, y1, y2, post, l0)) :
    {VS.bt(4n, VS.bdr(8n, _)) == N.digits(4n, Nat.add(Nat.add(FR(x0, post), List.length(&2, U32, y0)), List.length(&2, U32, y1))) : +List<U32>}
  {==}

law r_len:
  for +x0: +List<U32>
  for +y0: +List<U32>
  for +y1: +List<U32>
  for +y2: +List<U32>
  for +post: +List<+List<U32>>
  {List.length(&2, U32, OUTN(x0, y0, y1, y2, post)) == Nat.add(FR(x0, post), Nat.add(List.length(&2, U32, y0), Nat.add(List.length(&2, U32, y1), List.length(&2, U32, y2)))) : Nat}
def r_len(x0, y0, y1, y2, post):
  +RHS = Nat.add(FR(x0, post), Nat.add(List.length(&2, U32, y0), Nat.add(List.length(&2, U32, y1), List.length(&2, U32, y2))))
  %Equal.sym(Nat, List.length(&2, U32, OUTN(x0, y0, y1, y2, post)), Nat.add(List.length(&2, U32, List.append(&2, U32, x0, R1(x0, y0, y1, post))), List.length(&2, U32, PAY(y0, y1, y2))),
      VS.len_app(List.append(&2, U32, x0, R1(x0, y0, y1, post)), PAY(y0, y1, y2))) :
    {_ == RHS : Nat}
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, x0, R1(x0, y0, y1, post))), Nat.add(List.length(&2, U32, x0), List.length(&2, U32, R1(x0, y0, y1, post))), VS.len_app(x0, R1(x0, y0, y1, post))) :
    {Nat.add(_, List.length(&2, U32, PAY(y0, y1, y2))) == RHS : Nat}
  %Equal.sym(Nat, List.length(&2, U32, VR.bcat(post)), VR.lens(post), VR.len_bcat(post)) :
    {Nat.add(Nat.add(List.length(&2, U32, x0), 12n+_), List.length(&2, U32, PAY(y0, y1, y2))) == RHS : Nat}
  %Equal.sym(Nat, List.length(&2, U32, PAY(y0, y1, y2)), Nat.add(List.length(&2, U32, y0), List.length(&2, U32, List.append(&2, U32, y1, y2))), VS.len_app(y0, List.append(&2, U32, y1, y2))) :
    {Nat.add(FR(x0, post), _) == RHS : Nat}
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, y1, y2)), Nat.add(List.length(&2, U32, y1), List.length(&2, U32, y2)), VS.len_app(y1, y2)) :
    {Nat.add(FR(x0, post), Nat.add(List.length(&2, U32, y0), _)) == RHS : Nat}
  {==}

# ---- words ---------------------------------------------------------------------------------------

def u32le(+a: U32, +b: U32, +h: {Nat.is_le(U32.to_nat(a), U32.to_nat(b)) == True{} : Bool}) -> {U32.is_le(a, b) == True{} : Bool}:
  F.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(U32.to_nat(a), U32.to_nat(b)), U32.is_le(a, b), Equal.sym(Bool, U32.is_le(a, b), Nat.is_le(U32.to_nat(a), U32.to_nat(b)), VU.le_u32(a, b)), h)

def fitsn(+d: Nat, +n: U32, +x: Nat, +hd: {Nat.is_lt(d, 29n) == True{} : Bool}, +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool},
    +hx: {Nat.is_le(x, U32.to_nat(n)) == True{} : Bool}) -> {N.fits(4n, x) == True{} : Bool}:
  VFT.fits4(2n+d, x, F.nat__le_trans(x, U32.to_nat(n), A.quad(VB.pw(d)), hx, hn), F.nat__lt_trans(d, 29n, 30n, hd, {==}))

# ... with x <= n and n a U32 (no depth bound).
def fitsnA(+n: U32, +x: Nat, +hx: {Nat.is_le(x, U32.to_nat(n)) == True{} : Bool}) -> {N.fits(4n, x) == True{} : Bool}:
  VFT.fits4lt(x, F.nat__le_lt_trans(x, U32.to_nat(n), F.spec_common__pow2(32n), hx, VB.u32_lt(n)))

# b = x and a = x + y: a - b = y.
def subL(+a: U32, +b: U32, +x: Nat, +y: Nat, +hb: {U32.to_nat(b) == x : Nat}, +ha: {U32.to_nat(a) == Nat.add(x, y) : Nat})
    -> {U32.to_nat(U32.sub(a, b)) == y : Nat}:
  +le = F.logic__subst(Nat, z => {Nat.is_le(z, U32.to_nat(a)) == True{} : Bool}, x, U32.to_nat(b), Equal.sym(Nat, U32.to_nat(b), x, hb),
    F.logic__subst(Nat, z => {Nat.is_le(x, z) == True{} : Bool}, Nat.add(x, y), U32.to_nat(a), Equal.sym(Nat, U32.to_nat(a), Nat.add(x, y), ha), Order.below_sum(x, y)))
  %Equal.sym(Nat, U32.to_nat(U32.sub(a, b)), Nat.sub(U32.to_nat(a), U32.to_nat(b)), F.u32__sub_nat(a, b, le)) : {_ == y : Nat}
  %Equal.sym(Nat, U32.to_nat(b), x, hb) : {Nat.sub(U32.to_nat(a), _) == y : Nat}
  %Equal.sym(Nat, U32.to_nat(a), Nat.add(x, y), ha) : {Nat.sub(_, x) == y : Nat}
  F.nat__add_sub_cancel(x, y)

law len_eq:
  for +W: List<&2, U32>
  {List.length(&2, U32, W) == F.spec_common__length(U32, W) : Nat}
def len_eq(W):
  match W:
    case Nil{}: {==}
    case Con{+h, +t}:
      %Equal.sym(Nat, List.length(&2, U32, t), F.spec_common__length(U32, t), len_eq(t)) : {1n+_ == 1n+F.spec_common__length(U32, t) : Nat}
      {==}

def SLt(t: F.array__Tree<U32>) -> List<&2, U32>: F.array__slots(U32, t)

def lenS(+d: Nat, +t: F.array__Tree<U32>, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {List.length(&2, U32, FX.limbs(SLt(t))) == A.quad(VB.pw(d)) : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, FX.limbs(SLt(t))), FX.wlen(SLt(t)), VS.len_limbs(SLt(t))) : {_ == A.quad(VB.pw(d)) : Nat}
  %Equal.sym(Nat, FX.wlen(SLt(t)), A.quad(List.length(&2, U32, SLt(t))), VS.wlen_quad(SLt(t))) : {_ == A.quad(VB.pw(d)) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, SLt(t)), VB.pw(d), Equal.trans(Nat, List.length(&2, U32, SLt(t)), F.spec_common__length(U32, SLt(t)), VB.pw(d), len_eq(SLt(t)), F.array__slots_length(U32, d, t, pf))) : {A.quad(_) == A.quad(VB.pw(d)) : Nat}
  {==}

# The buffer's bytes are n long.
def lenVW(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {List.length(&2, U32, VN.VWg(t, n)) == U32.to_nat(n) : Nat}:
  VS.bt_len(U32.to_nat(n), FX.limbs(SLt(t)),
    F.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(n), z) == True{} : Bool}, A.quad(VB.pw(d)), List.length(&2, U32, FX.limbs(SLt(t))), Equal.sym(Nat, List.length(&2, U32, FX.limbs(SLt(t))), A.quad(VB.pw(d)), lenS(d, t, pf)), hn))
