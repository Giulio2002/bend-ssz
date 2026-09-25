import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../types/fulu_obj.bend as T
import ../../types/schema.bend as S
import ../../types/primitive.bend as P
import ../compact/found.bend as F
import ../compact/arith.bend as A
import ../compact/bits.bend as BT
import ../../proofs/nat_order.bend as Order
import ../../spec/primitives.bend as SP
import ../../spec/bytes.bend as Bytes
import ../../spec/layout.bend as Layout
import ../../spec/codec.bend as Codec
import ../../spec/decoding_relation.bend as Decoding
import ../../spec/nat_bytes.bend as N
import ../../spec/fulu_schemas.bend as Spec
import ./spec_fixed.bend as FX
import ./dk.bend as DK
import ./vspec.bend as VS
import ./vbuf.bend as VB
import ./vu32.bend as VU
import ./vcopy.bend as VC
import ./spec_var_dcbri.bend as DC

# Rejection of DataColumnsByRootIdentifier is exactly the complement of the
# spec image: every byte string the spec relates to some value has the shape
# the validator checks (inv_v), so when the validator's CHK(t, n) is False no
# value is related to the buffer's bytes (decode_reject), and the decoder
# returns None (decode_none).

def FACTS(bs: +List<U32>) -> Type:
  {VS.bt(4n, VS.bdr(32n, bs)) == [36, 0, 0, 0] : +List<U32>} & DK.Ex(Nat, k => DK.P2({List.length(&2, U32, bs) == Nat.add(36n, VS.x8(k)) : Nat}, {Nat.is_le(k, 128n) == True{} : Bool}))

law scope_len:
  for +k: Nat
  for +xs: +List<U32>
  for +e: {SP.byte_scope(k, xs) == True{} : Bool}
  {List.length(&2, U32, xs) == k : Nat}
def scope_len(k, xs, e):
  match k xs:
    case 0n Nil{}: {==}
    case 0n Con{+x, +t}: Empty.absurd({List.length(&2, U32, Con{x, t}) == 0n : Nat}, F.logic__false_true(e))
    case 1n+ +p Nil{}: Empty.absurd({List.length(&2, U32, Nil{}) == 1n+p : Nat}, F.logic__false_true(e))
    case 1n+ +p Con{+x, +t}:
      %Equal.sym(Nat, List.length(&2, U32, t), p, scope_len(p, t, F.logic__and_right(U32.is_lt(x, 256), SP.byte_scope(p, t), e))) : {1n+_ == 1n+p : Nat}
      {==}


def f2(+xs: +List<U32>, +ys: +List<U32>, +lxs: {List.length(&2, U32, xs) == 32n : Nat})
    -> {VS.bt(4n, VS.bdr(32n, List.append(&2, U32, Layout.fixed_parts([S.Fixed{xs}, S.Variable{ys}], Layout.fixed_size([S.Fixed{xs}, S.Variable{ys}])), Layout.payloads([S.Fixed{xs}, S.Variable{ys}])))) == [36, 0, 0, 0] : +List<U32>}:
  %Equal.sym(Nat, List.length(&2, U32, xs), 32n, lxs) :
    {VS.bt(4n, VS.bdr(32n, List.append(&2, U32, List.append(&2, U32, xs, List.append(&2, U32, N.digits(4n, Nat.add(_, 4n)), [])), List.append(&2, U32, ys, [])))) == [36, 0, 0, 0] : +List<U32>}
  %lxs :
    {VS.bt(4n, VS.bdr(_, List.append(&2, U32, List.append(&2, U32, xs, List.append(&2, U32, N.digits(4n, Nat.add(32n, 4n)), [])), List.append(&2, U32, ys, [])))) == [36, 0, 0, 0] : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, xs, List.append(&2, U32, N.digits(4n, Nat.add(32n, 4n)), [])), List.append(&2, U32, ys, [])), List.append(&2, U32, xs, List.append(&2, U32, List.append(&2, U32, N.digits(4n, Nat.add(32n, 4n)), []), List.append(&2, U32, ys, []))), VS.app_assoc(xs, List.append(&2, U32, N.digits(4n, Nat.add(32n, 4n)), []), List.append(&2, U32, ys, []))) :
    {VS.bt(4n, VS.bdr(List.length(&2, U32, xs), _)) == [36, 0, 0, 0] : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(List.length(&2, U32, xs), List.append(&2, U32, xs, List.append(&2, U32, List.append(&2, U32, N.digits(4n, Nat.add(32n, 4n)), []), List.append(&2, U32, ys, [])))), List.append(&2, U32, List.append(&2, U32, N.digits(4n, Nat.add(32n, 4n)), []), List.append(&2, U32, ys, [])), VS.bdr_app(xs, List.append(&2, U32, List.append(&2, U32, N.digits(4n, Nat.add(32n, 4n)), []), List.append(&2, U32, ys, [])))) :
    {VS.bt(4n, _) == [36, 0, 0, 0] : +List<U32>}
  {==}

def f3(+xs: +List<U32>, +ys: +List<U32>, +k: Nat, +lxs: {List.length(&2, U32, xs) == 32n : Nat}, +lys: {List.length(&2, U32, ys) == VS.x8(k) : Nat})
    -> {List.length(&2, U32, List.append(&2, U32, Layout.fixed_parts([S.Fixed{xs}, S.Variable{ys}], Layout.fixed_size([S.Fixed{xs}, S.Variable{ys}])), Layout.payloads([S.Fixed{xs}, S.Variable{ys}]))) == Nat.add(36n, VS.x8(k)) : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, Layout.fixed_parts([S.Fixed{xs}, S.Variable{ys}], Layout.fixed_size([S.Fixed{xs}, S.Variable{ys}])), Layout.payloads([S.Fixed{xs}, S.Variable{ys}]))), Nat.add(List.length(&2, U32, Layout.fixed_parts([S.Fixed{xs}, S.Variable{ys}], Layout.fixed_size([S.Fixed{xs}, S.Variable{ys}]))), List.length(&2, U32, Layout.payloads([S.Fixed{xs}, S.Variable{ys}]))),
      VS.len_app(Layout.fixed_parts([S.Fixed{xs}, S.Variable{ys}], Layout.fixed_size([S.Fixed{xs}, S.Variable{ys}])), Layout.payloads([S.Fixed{xs}, S.Variable{ys}]))) : {_ == Nat.add(36n, VS.x8(k)) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, xs, List.append(&2, U32, N.digits(4n, Layout.fixed_size([S.Fixed{xs}, S.Variable{ys}])), []))),
      Nat.add(List.length(&2, U32, xs), List.length(&2, U32, List.append(&2, U32, N.digits(4n, Layout.fixed_size([S.Fixed{xs}, S.Variable{ys}])), []))),
      VS.len_app(xs, List.append(&2, U32, N.digits(4n, Layout.fixed_size([S.Fixed{xs}, S.Variable{ys}])), []))) :
    {Nat.add(_, List.length(&2, U32, List.append(&2, U32, ys, []))) == Nat.add(36n, VS.x8(k)) : Nat}
  %Equal.sym(+List<U32>, List.append(&2, U32, ys, []), ys, VS.app_nil(ys)) :
    {Nat.add(Nat.add(List.length(&2, U32, xs), List.length(&2, U32, List.append(&2, U32, N.digits(4n, Layout.fixed_size([S.Fixed{xs}, S.Variable{ys}])), []))), List.length(&2, U32, _)) == Nat.add(36n, VS.x8(k)) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, xs), 32n, lxs) :
    {Nat.add(Nat.add(_, List.length(&2, U32, List.append(&2, U32, N.digits(4n, Nat.add(_, 4n)), []))), List.length(&2, U32, ys)) == Nat.add(36n, VS.x8(k)) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, ys), VS.x8(k), lys) :
    {Nat.add(36n, _) == Nat.add(36n, VS.x8(k)) : Nat}
  {==}

def inv_fin(+xs: +List<U32>, +ys: +List<U32>, +k: Nat, +bs: +List<U32>, +lxs: {List.length(&2, U32, xs) == 32n : Nat},
    +lys: {List.length(&2, U32, ys) == VS.x8(k) : Nat}, +hk: {Nat.is_le(k, 128n) == True{} : Bool}, +b5: Bool,
    +e: {Codec.bytes(Codec.one(SP.optional(b5, List.append(&2, U32, Layout.fixed_parts([S.Fixed{xs}, S.Variable{ys}], Layout.fixed_size([S.Fixed{xs}, S.Variable{ys}])), Layout.payloads([S.Fixed{xs}, S.Variable{ys}]))), None{})) == Some{bs} : Maybe<&2, +List<U32>>}) -> FACTS(bs):
  match b5:
    case False{}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case True{}:
      %F.logic__some_inj(+List<U32>, List.append(&2, U32, Layout.fixed_parts([S.Fixed{xs}, S.Variable{ys}], Layout.fixed_size([S.Fixed{xs}, S.Variable{ys}])), Layout.payloads([S.Fixed{xs}, S.Variable{ys}])), bs, e) : FACTS(_)
      (f2(xs, ys, lxs), (k, (f3(xs, ys, k, lxs, lys), hk)))


def inv_t2(+xs: +List<U32>, +ys: +List<U32>, +k: Nat, +t2: S.Value, +bs: +List<U32>, +lxs: {List.length(&2, U32, xs) == 32n : Nat},
    +lys: {List.length(&2, U32, ys) == VS.x8(k) : Nat}, +hk: {Nat.is_le(k, 128n) == True{} : Bool},
    +e: {Codec.bytes(Codec.aggregate(Codec.concatenate(Some{[S.Fixed{xs}]}, Codec.concatenate(Some{[S.Variable{ys}]}, Codec.parts(t2, S.End{}))), None{})) == Some{bs} : Maybe<&2, +List<U32>>}) -> FACTS(bs):
  match t2:
    case S.EmptyItems{}: inv_fin(xs, ys, k, bs, lxs, lys, hk, Bool.and(Layout.bytes_valid([S.Fixed{xs}, S.Variable{ys}]), N.fits(4n, Nat.add(Layout.fixed_size([S.Fixed{xs}, S.Variable{ys}]), List.length(&2, U32, Layout.payloads([S.Fixed{xs}, S.Variable{ys}]))))), e)
    case S.BooleanValue{+b0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.UnsignedValue{+u0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.BytesValue{+xs0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.BitsValue{+bs0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.Sequence{+it0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.Items{+hd0, +tl0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.Selected{+sel0, +sv0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.NullValue{}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))

def inv_m4(+xs: +List<U32>, +its: S.Value, +t2: S.Value, +bs: +List<U32>, +lxs: {List.length(&2, U32, xs) == 32n : Nat},
    +hk: {Nat.is_le(Codec.count(its), 128n) == True{} : Bool}, +ps: +List<S.Part>,
    +em3: {Codec.parts(its, S.Repeat{Spec.Schema3()}) == Some{ps} : Maybe<&2, +List<S.Part>>},
    +m4: Maybe<&2, +List<U32>>, +em4: {Layout.encoding(ps) == m4 : Maybe<&2, +List<U32>>},
    +e: {Codec.bytes(Codec.aggregate(Codec.concatenate(Some{[S.Fixed{xs}]}, Codec.concatenate(Codec.one(m4, None{}), Codec.parts(t2, S.End{}))), None{})) == Some{bs} : Maybe<&2, +List<U32>>}) -> FACTS(bs):
  match m4:
    case None{}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case Some{+ys}:
      +lys = Equal.trans(Nat, List.length(&2, U32, ys), Layout.fixed_size(ps), VS.x8(Codec.count(its)),
        VS.enc_len(ps, ys, Pair.fst({VS.allfix(ps) == True{} : Bool}, {Layout.fixed_size(ps) == VS.x8(Codec.count(its)) : Nat}, VS.rep_facts(its, ps, em3)), em4),
        Pair.snd({VS.allfix(ps) == True{} : Bool}, {Layout.fixed_size(ps) == VS.x8(Codec.count(its)) : Nat}, VS.rep_facts(its, ps, em3)))
      inv_t2(xs, ys, Codec.count(its), t2, bs, lxs, lys, hk, e)

def inv_m3(+xs: +List<U32>, +its: S.Value, +t2: S.Value, +bs: +List<U32>, +lxs: {List.length(&2, U32, xs) == 32n : Nat},
    +hk: {Nat.is_le(Codec.count(its), 128n) == True{} : Bool},
    +m3: Maybe<&2, +List<S.Part>>, +em3: {Codec.parts(its, S.Repeat{Spec.Schema3()}) == m3 : Maybe<&2, +List<S.Part>>},
    +e: {Codec.bytes(Codec.aggregate(Codec.concatenate(Some{[S.Fixed{xs}]}, Codec.concatenate(Codec.aggregate(m3, None{}), Codec.parts(t2, S.End{}))), None{})) == Some{bs} : Maybe<&2, +List<U32>>}) -> FACTS(bs):
  match m3:
    case None{}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case Some{+ps}: inv_m4(xs, its, t2, bs, lxs, hk, ps, em3, Layout.encoding(ps), {==}, e)

def inv_its(+xs: +List<U32>, +its: S.Value, +t2: S.Value, +bs: +List<U32>, +lxs: {List.length(&2, U32, xs) == 32n : Nat},
    +b2: Bool, +eb2: {Nat.is_le(Codec.count(its), 128n) == b2 : Bool},
    +e: {Codec.bytes(Codec.aggregate(Codec.concatenate(Some{[S.Fixed{xs}]}, Codec.concatenate(Codec.require(b2, Codec.aggregate(Codec.parts(its, S.Repeat{Spec.Schema3()}), None{})), Codec.parts(t2, S.End{}))), None{})) == Some{bs} : Maybe<&2, +List<U32>>}) -> FACTS(bs):
  match b2:
    case False{}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case True{}: inv_m3(xs, its, t2, bs, lxs, eb2, Codec.parts(its, S.Repeat{Spec.Schema3()}), {==}, e)

def inv_h2(+xs: +List<U32>, +h2: S.Value, +t2: S.Value, +bs: +List<U32>, +lxs: {List.length(&2, U32, xs) == 32n : Nat},
    +e: {Codec.bytes(Codec.aggregate(Codec.concatenate(Some{[S.Fixed{xs}]}, Codec.concatenate(Codec.parts(h2, Spec.Schema111()), Codec.parts(t2, S.End{}))), None{})) == Some{bs} : Maybe<&2, +List<U32>>}) -> FACTS(bs):
  match h2:
    case S.Sequence{+its}: inv_its(xs, its, t2, bs, lxs, Nat.is_le(Codec.count(its), 128n), {==}, e)
    case S.BooleanValue{+b0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.UnsignedValue{+u0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.BytesValue{+xs0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.BitsValue{+bs0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.Items{+hd0, +tl0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.EmptyItems{}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.Selected{+sel0, +sv0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.NullValue{}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))

def inv_t(+xs: +List<U32>, +t: S.Value, +bs: +List<U32>, +lxs: {List.length(&2, U32, xs) == 32n : Nat},
    +e: {Codec.bytes(Codec.aggregate(Codec.concatenate(Some{[S.Fixed{xs}]}, Codec.parts(t, S.Chain{Spec.Schema111(), S.End{}})), None{})) == Some{bs} : Maybe<&2, +List<U32>>}) -> FACTS(bs):
  match t:
    case S.Items{+h2, +t2}: inv_h2(xs, h2, t2, bs, lxs, e)
    case S.BooleanValue{+b0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.UnsignedValue{+u0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.BytesValue{+xs0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.BitsValue{+bs0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.Sequence{+it0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.EmptyItems{}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.Selected{+sel0, +sv0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.NullValue{}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))

def inv_xs(+xs: +List<U32>, +t: S.Value, +bs: +List<U32>, +b1: Bool, +eb1: {SP.byte_scope(32n, xs) == b1 : Bool},
    +e: {Codec.bytes(Codec.aggregate(Codec.concatenate(Codec.one(SP.optional(Bool.and(b1, Bytes.size_fits(32n)), xs), Some{32n}), Codec.parts(t, S.Chain{Spec.Schema111(), S.End{}})), None{})) == Some{bs} : Maybe<&2, +List<U32>>}) -> FACTS(bs):
  match b1:
    case False{}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case True{}: inv_t(xs, t, bs, scope_len(32n, xs, eb1), e)

def inv_h(+h: S.Value, +t: S.Value, +bs: +List<U32>, +e: {Codec.bytes(Codec.aggregate(Codec.concatenate(Codec.parts(h, Spec.Schema7()), Codec.parts(t, S.Chain{Spec.Schema111(), S.End{}})), None{})) == Some{bs} : Maybe<&2, +List<U32>>}) -> FACTS(bs):
  match h:
    case S.BytesValue{+xs}: inv_xs(xs, t, bs, SP.byte_scope(32n, xs), {==}, e)
    case S.BooleanValue{+b0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.UnsignedValue{+u0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.BitsValue{+bs0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.Sequence{+it0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.Items{+hd0, +tl0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.EmptyItems{}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.Selected{+sel0, +sv0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.NullValue{}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))

def inv_items(+items: S.Value, +bs: +List<U32>, +e: {Codec.bytes(Codec.aggregate(Codec.parts(items, S.Chain{Spec.Schema7(), S.Chain{Spec.Schema111(), S.End{}}}), None{})) == Some{bs} : Maybe<&2, +List<U32>>}) -> FACTS(bs):
  match items:
    case S.Items{+h, +t}: inv_h(h, t, bs, e)
    case S.BooleanValue{+b0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.UnsignedValue{+u0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.BytesValue{+xs0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.BitsValue{+bs0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.Sequence{+it0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.EmptyItems{}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.Selected{+sel0, +sv0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.NullValue{}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))

# Every byte string the spec relates to a value has the checked shape.
law inv_v:
  for +v: S.Value
  for +bs: +List<U32>
  for +e: {Codec.encoding_for_legal_type(Spec.DataColumnsByRootIdentifier(), v) == Some{bs} : Maybe<&2, +List<U32>>}
  FACTS(bs)
def inv_v(v, bs, e):
  match v:
    case S.Sequence{+items}: inv_items(items, bs, e)
    case S.BooleanValue{+b0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.UnsignedValue{+u0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.BytesValue{+xs0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.BitsValue{+bs0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.Items{+hd0, +tl0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.EmptyItems{}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.Selected{+sel0, +sv0}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))
    case S.NullValue{}: Empty.absurd(FACTS(bs), F.logic__none_some(+List<U32>, bs, e))

# ---- the buffer's bytes ------------------------------------------------------------------

law wdr0_eq:
  for +n: Nat
  for +W: List<&2, U32>
  {VS.wdr0(n, W) == VB.wdr(n, W) : List<&2, U32>}
def wdr0_eq(n, W):
  match n W:
    case 0n _: {==}
    case 1n+ +p Nil{}: {==}
    case 1n+ +p Con{+h, +t}: wdr0_eq(p, t)

law len_eq:
  for +W: List<&2, U32>
  {List.length(&2, U32, W) == F.spec_common__length(U32, W) : Nat}
def len_eq(W):
  match W:
    case Nil{}: {==}
    case Con{+h, +t}:
      %Equal.sym(Nat, List.length(&2, U32, t), F.spec_common__length(U32, t), len_eq(t)) : {1n+_ == 1n+F.spec_common__length(U32, t) : Nat}
      {==}

def SL(t: F.array__Tree<U32>) -> List<&2, U32>: F.array__slots(U32, t)

def lenS(+d: Nat, +t: F.array__Tree<U32>, +pf: {F.array__perfect(U32, d, t) == True{} : Bool})
    -> {List.length(&2, U32, FX.limbs(SL(t))) == A.quad(VB.pw(d)) : Nat}:
  %Equal.sym(Nat, List.length(&2, U32, FX.limbs(SL(t))), FX.wlen(SL(t)), VS.len_limbs(SL(t))) : {_ == A.quad(VB.pw(d)) : Nat}
  %Equal.sym(Nat, FX.wlen(SL(t)), A.quad(List.length(&2, U32, SL(t))), VS.wlen_quad(SL(t))) : {_ == A.quad(VB.pw(d)) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, SL(t)), VB.pw(d), Equal.trans(Nat, List.length(&2, U32, SL(t)), F.spec_common__length(U32, SL(t)), VB.pw(d), len_eq(SL(t)), F.array__slots_length(U32, d, t, pf))) : {A.quad(_) == A.quad(VB.pw(d)) : Nat}
  {==}

def lenVW(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool})
    -> {List.length(&2, U32, DC.VW(t, n)) == U32.to_nat(n) : Nat}:
  VS.bt_len(U32.to_nat(n), FX.limbs(SL(t)),
    F.logic__subst(Nat, z => {Nat.is_le(U32.to_nat(n), z) == True{} : Bool}, A.quad(VB.pw(d)), List.length(&2, U32, FX.limbs(SL(t))), Equal.sym(Nat, List.length(&2, U32, FX.limbs(SL(t))), A.quad(VB.pw(d)), lenS(d, t, pf)), hn))

def h8S(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +h36: {Nat.is_le(36n, U32.to_nat(n)) == True{} : Bool})
    -> {Nat.is_lt(8n, VB.len(SL(t))) == True{} : Bool}:
  %Equal.sym(Nat, VB.len(SL(t)), VB.pw(d), F.array__slots_length(U32, d, t, pf)) : {Nat.is_lt(8n, _) == True{} : Bool}
  F.nat__lt_le_trans(8n, 9n, VB.pw(d), {==}, VC.quad_inv(9n, VB.pw(d), F.nat__le_trans(36n, U32.to_nat(n), A.quad(VB.pw(d)), h36, hn)))

# Bytes 32..35 of the buffer are the limbs of its word 8.
def byte8(+t: F.array__Tree<U32>, +n: U32, +X: Nat, +en: {U32.to_nat(n) == 36n+X : Nat}, +h8: {Nat.is_lt(8n, VB.len(SL(t))) == True{} : Bool})
    -> {VS.bt(4n, VS.bdr(32n, DC.VW(t, n))) == FX.limbs([VB.slot(t, 8n)]) : +List<U32>}:
  %Equal.sym(Nat, U32.to_nat(n), 36n+X, en) : {VS.bt(4n, VS.bdr(32n, VS.bt(_, FX.limbs(SL(t))))) == FX.limbs([VB.slot(t, 8n)]) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(32n, VS.bt(36n+X, FX.limbs(SL(t)))), VS.bt(4n+X, VS.bdr(32n, FX.limbs(SL(t)))), VS.bdr_bt(32n, 4n+X, FX.limbs(SL(t)))) :
    {VS.bt(4n, _) == FX.limbs([VB.slot(t, 8n)]) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(4n, VS.bt(4n+X, VS.bdr(32n, FX.limbs(SL(t))))), VS.bt(4n, VS.bdr(32n, FX.limbs(SL(t)))), VS.bt_bt(4n, X, VS.bdr(32n, FX.limbs(SL(t))))) :
    {_ == FX.limbs([VB.slot(t, 8n)]) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(32n, FX.limbs(SL(t))), FX.limbs(VS.wdr0(8n, SL(t))), VS.bdr_limbs(8n, SL(t))) :
    {VS.bt(4n, _) == FX.limbs([VB.slot(t, 8n)]) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bt(4n, FX.limbs(VS.wdr0(8n, SL(t)))), FX.limbs(VS.wtake(1n, VS.wdr0(8n, SL(t)))), VS.bt_limbs(1n, VS.wdr0(8n, SL(t)))) :
    {_ == FX.limbs([VB.slot(t, 8n)]) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wdr0(8n, SL(t)), VB.wdr(8n, SL(t)), wdr0_eq(8n, SL(t))) :
    {FX.limbs(VS.wtake(1n, _)) == FX.limbs([VB.slot(t, 8n)]) : +List<U32>}
  %Equal.sym(List<&2, U32>, VS.wtake(1n, VB.wdr(8n, SL(t))), Con{F.flat__nthc(SL(t), 8n), VS.wtake(0n, VB.wdr(9n, SL(t)))}, VB.wt_eta(0n, 8n, SL(t), h8)) :
    {FX.limbs(_) == FX.limbs([VB.slot(t, 8n)]) : +List<U32>}
  {==}

def q0(xs: +List<U32>) -> U32:
  match xs:
    case Con{h, t}: h
    case Nil{}: 0
def q1(xs: +List<U32>) -> U32:
  match xs:
    case Con{h, t}: q0(t)
    case Nil{}: 0
def q2(xs: +List<U32>) -> U32:
  match xs:
    case Con{h, t}: q1(t)
    case Nil{}: 0
def q3(xs: +List<U32>) -> U32:
  match xs:
    case Con{h, t}: q2(t)
    case Nil{}: 0

# A word whose limbs are those of 36 is 36.
def word36(+x: U32, +h: {FX.limbs([x]) == [36, 0, 0, 0] : +List<U32>}) -> {x == 36 : U32}:
  Equal.trans(U32, x, BT.asm(B.byte_sel(0, x), B.byte_sel(1, x), B.byte_sel(2, x), B.byte_sel(3, x)), 36, BT.reassemble(x),
    BT.asm_cong(B.byte_sel(0, x), B.byte_sel(1, x), B.byte_sel(2, x), B.byte_sel(3, x), 36, 0, 0, 0,
      Equal.cong(+List<U32>, U32, l => q0(l), FX.limbs([x]), [36, 0, 0, 0], h),
      Equal.cong(+List<U32>, U32, l => q1(l), FX.limbs([x]), [36, 0, 0, 0], h),
      Equal.cong(+List<U32>, U32, l => q2(l), FX.limbs([x]), [36, 0, 0, 0], h),
      Equal.cong(+List<U32>, U32, l => q3(l), FX.limbs([x]), [36, 0, 0, 0], h)))

def ec_sub(+n: U32, +k: Nat, +en: {U32.to_nat(n) == 36n+VS.x8(k) : Nat})
    -> {U32.to_nat(DC.L36(n)) == Nat.mul(k, U32.to_nat(8)) : Nat}:
  +le = F.logic__subst(Nat, z => {Nat.is_le(36n, z) == True{} : Bool}, 36n+VS.x8(k), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), 36n+VS.x8(k), en), Order.below_sum(36n, VS.x8(k)))
  %Equal.sym(Nat, U32.to_nat(DC.L36(n)), Nat.sub(U32.to_nat(n), 36n), F.u32__sub_nat(n, 36, le)) : {_ == Nat.mul(k, U32.to_nat(8)) : Nat}
  %Equal.sym(Nat, U32.to_nat(n), 36n+VS.x8(k), en) : {Nat.sub(_, 36n) == Nat.mul(k, U32.to_nat(8)) : Nat}
  %VC.x8_mul(k) : {Nat.sub(36n+_, 36n) == Nat.mul(k, U32.to_nat(8)) : Nat}
  F.nat__add_sub_cancel(36n, Nat.mul(k, 8n))

# The validator accepts every buffer whose bytes have the shape.
def chk_true(+t: F.array__Tree<U32>, +n: U32, +k: Nat, +en: {U32.to_nat(n) == 36n+VS.x8(k) : Nat}, +hk: {Nat.is_le(k, 128n) == True{} : Bool},
    +e8: {VB.slot(t, 8n) == 36 : U32}) -> {DC.CHK(t, n) == True{} : Bool}:
  +le = F.logic__subst(Nat, z => {Nat.is_le(36n, z) == True{} : Bool}, 36n+VS.x8(k), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), 36n+VS.x8(k), en), Order.below_sum(36n, VS.x8(k)))
  %Equal.sym(Bool, U32.is_le(36, n), True{}, F.logic__subst(Bool, z => {z == True{} : Bool}, Nat.is_le(36n, U32.to_nat(n)), U32.is_le(36, n), Equal.sym(Bool, U32.is_le(36, n), Nat.is_le(36n, U32.to_nat(n)), VU.le_u32(36, n)), le)) :
    {DC.chk3(_, U32.is_eq(VB.slot(t, 8n), 36), DC.whole(U32.sub(n, VB.slot(t, 8n)))) == True{} : Bool}
  %Equal.sym(U32, VB.slot(t, 8n), 36, e8) :
    {DC.chk3(True{}, U32.is_eq(_, 36), DC.whole(U32.sub(n, _))) == True{} : Bool}
  VU.whole_i(DC.L36(n), 8, 128, DC.v8(), {==}, {==}, {==}, k, ec_sub(n, k, en), hk)

def rej_k(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {DC.CHK(t, n) == False{} : Bool},
    +hb: {VS.bt(4n, VS.bdr(32n, DC.VW(t, n))) == [36, 0, 0, 0] : +List<U32>},
    ex: DK.Ex(Nat, k => DK.P2({List.length(&2, U32, DC.VW(t, n)) == Nat.add(36n, VS.x8(k)) : Nat}, {Nat.is_le(k, 128n) == True{} : Bool}))) -> Empty:
  (+k, +pr) = ex
  (+hlen, +hk) = pr
  +en = Equal.trans(Nat, U32.to_nat(n), List.length(&2, U32, DC.VW(t, n)), 36n+VS.x8(k), Equal.sym(Nat, List.length(&2, U32, DC.VW(t, n)), U32.to_nat(n), lenVW(d, t, n, pf, hn)), hlen)
  +h36 = F.logic__subst(Nat, z => {Nat.is_le(36n, z) == True{} : Bool}, 36n+VS.x8(k), U32.to_nat(n), Equal.sym(Nat, U32.to_nat(n), 36n+VS.x8(k), en), Order.below_sum(36n, VS.x8(k)))
  +h8 = h8S(d, t, n, pf, hn, h36)
  +e8 = word36(VB.slot(t, 8n), Equal.trans(+List<U32>, FX.limbs([VB.slot(t, 8n)]), VS.bt(4n, VS.bdr(32n, DC.VW(t, n))), [36, 0, 0, 0],
    Equal.sym(+List<U32>, VS.bt(4n, VS.bdr(32n, DC.VW(t, n))), FX.limbs([VB.slot(t, 8n)]), byte8(t, n, VS.x8(k), en, h8)), hb))
  F.logic__true_false(Equal.trans(Bool, True{}, DC.CHK(t, n), False{}, Equal.sym(Bool, DC.CHK(t, n), True{}, chk_true(t, n, k, en, hk, e8)), hchk))

def rej_f(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {DC.CHK(t, n) == False{} : Bool},
    facts: FACTS(DC.VW(t, n))) -> Empty:
  (+hb, ex) = facts
  rej_k(d, t, n, pf, hn, hchk, hb, ex)

# When the validator refuses, no value is related to the buffer's bytes.
law decode_reject:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {DC.CHK(t, n) == False{} : Bool}
  Decoding.outside_image(Spec.DataColumnsByRootIdentifier(), DC.VW(t, n))
def decode_reject(d, t, n, pf, hn, hchk):
  v => e => rej_f(d, t, n, pf, hn, hchk, inv_v(v, DC.VW(t, n), e))

def none_go(+d: Nat, +t: F.array__Tree<U32>, +n: U32, +pf: {F.array__perfect(U32, d, t) == True{} : Bool}, +hd: {Nat.is_lt(d, 29n) == True{} : Bool},
    +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}, +hchk: {DC.CHK(t, n) == False{} : Bool},
    +a: Bool, +ea: {U32.is_le(36, n) == a : Bool})
    -> {T.DataColumnsByRootIdentifier_decode(DC.BF(t, n), n) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, T.DataColumnsByRootIdentifier>}:
  match a:
    case False{}:
      %Equal.sym(Bool, U32.is_le(36, n), False{}, ea) :
        {T.DataColumnsByRootIdentifier_built(n, T.DataColumnsByRootIdentifier_ok_len(_, DC.BF(t, n), 0, n)) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, T.DataColumnsByRootIdentifier>}
      {==}
    case True{}:
      +h36 = F.logic__subst(Bool, z => {z == True{} : Bool}, U32.is_le(36, n), Nat.is_le(36n, U32.to_nat(n)), VU.le_u32(36, n), ea)
      +h8 = F.logic__subst(Nat, z => {Nat.is_lt(8n, z) == True{} : Bool}, VB.len(SL(t)), VB.pw(d), F.array__slots_length(U32, d, t, pf), h8S(d, t, n, pf, hn, h36))
      %Equal.sym(B.Buf & Bool, T.DataColumnsByRootIdentifier_ok(DC.BF(t, n), 0, n), (DC.BF(t, n), DC.CHK(t, n)), DC.ok_eval(d, t, n, VB.lt32(d, F.nat__lt_trans(d, 29n, 31n, hd, {==})), h8, pf)) :
        {T.DataColumnsByRootIdentifier_built(n, _) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, T.DataColumnsByRootIdentifier>}
      %Equal.sym(Bool, DC.CHK(t, n), False{}, hchk) :
        {T.DataColumnsByRootIdentifier_built(n, (DC.BF(t, n), _)) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, T.DataColumnsByRootIdentifier>}
      {==}

# When the validator refuses, the decoder returns None and the buffer.
law decode_none:
  for +d: Nat
  for +t: F.array__Tree<U32>
  for +n: U32
  for +pf: {F.array__perfect(U32, d, t) == True{} : Bool}
  for +hd: {Nat.is_lt(d, 29n) == True{} : Bool}
  for +hn: {Nat.is_le(U32.to_nat(n), A.quad(VB.pw(d))) == True{} : Bool}
  for +hchk: {DC.CHK(t, n) == False{} : Bool}
  {T.DataColumnsByRootIdentifier_decode(DC.BF(t, n), n) == (DC.BF(t, n), None{}) : B.Buf & Maybe<&1, T.DataColumnsByRootIdentifier>}
def decode_none(d, t, n, pf, hd, hn, hchk):
  none_go(d, t, n, pf, hd, hn, hchk, U32.is_le(36, n), {==})
