import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../types/schema.bend as S
import ../../spec/codec.bend as Codec
import ../../spec/layout.bend as Layout
import ../../spec/primitives.bend as SP
import ../../spec/schema.bend as SS
import ../../spec/nat_bytes.bend as N
import ../../proofs/decode_facts.bend as DF
import ../compact/found.bend as FD
import ../compact/arith.bend as A
import ./vbuf.bend as VB
import ./vcopy.bend as VC
import ./vspec.bend as VS
import ./vbrt.bend as VR
import ./vbitl.bend as VBL
import ./vrl.bend as VRL
import ./vua.bend as UA
import ./vua_win.bend as UW

# GENERATED from vrejb.bend.in by byte_checked_reject_laws (codegen). Do not edit.
# Names whose validator also checks bytes: booleans and vectors of booleans (every byte at
# most 1). The spec side: every encoding at such a schema has only bytes 0 and 1 (ALLB),
# and the fixed size (len_eq); the runtime side: the byte the runtime reads at a position
# is the window's byte there (vx_bx), the window's bytes one at a time (wxc).

# every byte at most 1
def ALLB(bs: +List<U32>) -> Bool:
  match bs:
    case Nil{}: True{}
    case Con{+c, t}: Bool.and(U32.is_le(c, 1), ALLB(t))

def and_true(+c: Bool) -> {Bool.and(c, True{}) == c : Bool}:
  match c:
    case True{}: {==}
    case False{}: {==}

def and_assoc(+a: Bool, +b: Bool, +c: Bool) -> {Bool.and(Bool.and(a, b), c) == Bool.and(a, Bool.and(b, c)) : Bool}:
  match a:
    case True{}: {==}
    case False{}: {==}

def allb_app(+a: +List<U32>, +b: +List<U32>) -> {ALLB(List.append(&2, U32, a, b)) == Bool.and(ALLB(a), ALLB(b)) : Bool}:
  match a:
    case Nil{}: {==}
    case Con{+c, +t}:
      %Equal.sym(Bool, ALLB(List.append(&2, U32, t, b)), Bool.and(ALLB(t), ALLB(b)), allb_app(t, b)) :
        {Bool.and(U32.is_le(c, 1), _) == Bool.and(Bool.and(U32.is_le(c, 1), ALLB(t)), ALLB(b)) : Bool}
      Equal.sym(Bool, Bool.and(Bool.and(U32.is_le(c, 1), ALLB(t)), ALLB(b)), Bool.and(U32.is_le(c, 1), Bool.and(ALLB(t), ALLB(b))), and_assoc(U32.is_le(c, 1), ALLB(t), ALLB(b)))

def and_both(+a: Bool, +b: Bool, +ha: {a == True{} : Bool}, +hb: {b == True{} : Bool}) -> {Bool.and(a, b) == True{} : Bool}:
  %Equal.sym(Bool, a, True{}, ha) : {Bool.and(_, b) == True{} : Bool}
  hb

# ---- the spec side ------------------------------------------------------------------------------

# every part fixed, with every byte at most 1
def ALLF(ps: +List<S.Part>) -> Bool:
  match ps:
    case Nil{}: True{}
    case Con{+h, t}:
      match h:
        case S.Fixed{+xs}: Bool.and(ALLB(xs), ALLF(t))
        case S.Variable{+xs}: False{}

def fx(+ps: +List<S.Part>, +o: Nat, +h: {ALLF(ps) == True{} : Bool})
    -> {ALLB(List.append(&2, U32, Layout.fixed_parts(ps, o), Layout.payloads(ps))) == True{} : Bool}:
  match ps:
    case Nil{}: {==}
    case Con{S.Fixed{+xs}, +t}:
      +h1 = FD.logic__and_left(ALLB(xs), ALLF(t), h)
      +h2 = FD.logic__and_right(ALLB(xs), ALLF(t), h)
      %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, xs, Layout.fixed_parts(t, o)), Layout.payloads(t)), List.append(&2, U32, xs, List.append(&2, U32, Layout.fixed_parts(t, o), Layout.payloads(t))),
          VS.app_assoc(xs, Layout.fixed_parts(t, o), Layout.payloads(t))) : {ALLB(_) == True{} : Bool}
      %Equal.sym(Bool, ALLB(List.append(&2, U32, xs, List.append(&2, U32, Layout.fixed_parts(t, o), Layout.payloads(t)))),
          Bool.and(ALLB(xs), ALLB(List.append(&2, U32, Layout.fixed_parts(t, o), Layout.payloads(t)))), allb_app(xs, List.append(&2, U32, Layout.fixed_parts(t, o), Layout.payloads(t)))) :
        {_ == True{} : Bool}
      and_both(ALLB(xs), ALLB(List.append(&2, U32, Layout.fixed_parts(t, o), Layout.payloads(t))), h1, fx(t, o, h2))
    case Con{S.Variable{+xs}, +t}: Empty.absurd({ALLB(List.append(&2, U32, Layout.fixed_parts(Con{S.Variable{xs}, t}, o), Layout.payloads(Con{S.Variable{xs}, t}))) == True{} : Bool}, FD.logic__false_true(h))

def opt_some(+c: Bool, +v: +List<U32>, +bs: +List<U32>, +e: {SP.optional(c, v) == Some{bs} : Maybe<&2, +List<U32>>}) -> {v == bs : +List<U32>}:
  match c:
    case False{}: Empty.absurd({v == bs : +List<U32>}, FD.logic__none_some(+List<U32>, bs, e))
    case True{}: FD.logic__some_inj(+List<U32>, v, bs, e)

def enc(+ps: +List<S.Part>, +bs: +List<U32>, +h: {ALLF(ps) == True{} : Bool}, +e: {Layout.encoding(ps) == Some{bs} : Maybe<&2, +List<U32>>})
    -> {ALLB(bs) == True{} : Bool}:
  +c = Bool.and(Layout.bytes_valid(ps), N.fits(4n, Nat.add(Layout.fixed_size(ps), List.length(&2, U32, Layout.payloads(ps)))))
  FD.logic__subst(+List<U32>, z => {ALLB(z) == True{} : Bool}, List.append(&2, U32, Layout.fixed_parts(ps, Layout.fixed_size(ps)), Layout.payloads(ps)), bs,
    opt_some(c, List.append(&2, U32, Layout.fixed_parts(ps, Layout.fixed_size(ps)), Layout.payloads(ps)), bs, e), fx(ps, Layout.fixed_size(ps), h))

def BE(b: Bool) -> +List<U32>: SP.boolean_encoding(b)
def allb_be(+b: Bool) -> {ALLB(SP.boolean_encoding(b)) == True{} : Bool}:
  match b:
    case True{}: {==}
    case False{}: {==}

# the tail's parts m, then the element's: all fixed bytes 0/1
def rep_c(+b: Bool, +m: Maybe<&2, +List<S.Part>>, +ps: +List<S.Part>,
    +e: {Codec.concatenate(Some{[S.Fixed{SP.boolean_encoding(b)}]}, m) == Some{ps} : Maybe<&2, +List<S.Part>>},
    ih: @+q: +List<S.Part> -> {m == Some{q} : Maybe<&2, +List<S.Part>>} -> {ALLF(q) == True{} : Bool})
    -> {ALLF(ps) == True{} : Bool}:
  match m:
    case None{}: Empty.absurd({ALLF(ps) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, ps, e))
    case Some{+q}:
      +eq = FD.logic__some_inj(+List<S.Part>, S.Fixed{SP.boolean_encoding(b)} <> q, ps, e)
      FD.logic__subst(+List<S.Part>, z => {ALLF(z) == True{} : Bool}, S.Fixed{SP.boolean_encoding(b)} <> q, ps, eq,
        and_both(ALLB(SP.boolean_encoding(b)), ALLF(q), allb_be(b), ih(q, {==})))

# the parts of any items at Repeat{Boolean}
def rep(+items: S.Value, +ps: +List<S.Part>, +e: {Codec.parts(items, S.Repeat{S.Boolean{}}) == Some{ps} : Maybe<&2, +List<S.Part>>})
    -> {ALLF(ps) == True{} : Bool}:
  match items:
    case S.EmptyItems{}:
      FD.logic__subst(+List<S.Part>, z => {ALLF(z) == True{} : Bool}, [], ps, FD.logic__some_inj(+List<S.Part>, [], ps, e), {==})
    case S.Items{+h, +t}:
      match h:
        case S.BooleanValue{+b}: rep_c(b, Codec.parts(t, S.Repeat{S.Boolean{}}), ps, e, q => eq => rep(t, q, eq))
        case S.UnsignedValue{+u}: Empty.absurd({ALLF(ps) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, ps, e))
        case S.BytesValue{+xs}: Empty.absurd({ALLF(ps) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, ps, e))
        case S.BitsValue{+bs}: Empty.absurd({ALLF(ps) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, ps, e))
        case S.Sequence{+it}: Empty.absurd({ALLF(ps) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, ps, e))
        case S.Selected{+sel, +sv}: Empty.absurd({ALLF(ps) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, ps, e))
        case S.NullValue{}: Empty.absurd({ALLF(ps) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, ps, e))
        case S.EmptyItems{}: Empty.absurd({ALLF(ps) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, ps, e))
        case S.Items{+hh, +tt}: Empty.absurd({ALLF(ps) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, ps, e))
    case S.BooleanValue{+b}: Empty.absurd({ALLF(ps) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, ps, e))
    case S.UnsignedValue{+u}: Empty.absurd({ALLF(ps) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, ps, e))
    case S.BytesValue{+xs}: Empty.absurd({ALLF(ps) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, ps, e))
    case S.BitsValue{+bs}: Empty.absurd({ALLF(ps) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, ps, e))
    case S.Sequence{+it}: Empty.absurd({ALLF(ps) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, ps, e))
    case S.Selected{+sel, +sv}: Empty.absurd({ALLF(ps) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, ps, e))
    case S.NullValue{}: Empty.absurd({ALLF(ps) == True{} : Bool}, FD.logic__none_some(+List<S.Part>, ps, e))

def frag(+w: Maybe<&2, Nat>, +xs: +List<U32>, +bs: +List<U32>, +e: {Codec.bytes(Some{[Codec.fragment(w, xs)]}) == Some{bs} : Maybe<&2, +List<U32>>})
    -> {xs == bs : +List<U32>}:
  match w:
    case None{}: FD.logic__some_inj(+List<U32>, xs, bs, e)
    case Some{+k}: FD.logic__some_inj(+List<U32>, xs, bs, e)

def agg_r(+ps: +List<S.Part>, +w: Maybe<&2, Nat>, +bs: +List<U32>, +h: {ALLF(ps) == True{} : Bool}, +r: Maybe<&2, +List<U32>>,
    +er: {Layout.encoding(ps) == r : Maybe<&2, +List<U32>>}, +e: {Codec.bytes(Codec.one(r, w)) == Some{bs} : Maybe<&2, +List<U32>>})
    -> {ALLB(bs) == True{} : Bool}:
  match r:
    case None{}: Empty.absurd({ALLB(bs) == True{} : Bool}, FD.logic__none_some(+List<U32>, bs, e))
    case Some{+xs}:
      FD.logic__subst(+List<U32>, z => {ALLB(z) == True{} : Bool}, xs, bs, frag(w, xs, bs, e), enc(ps, xs, h, er))

def agg_m(+items: S.Value, +m: Maybe<&2, +List<S.Part>>, +em: {Codec.parts(items, S.Repeat{S.Boolean{}}) == m : Maybe<&2, +List<S.Part>>},
    +w: Maybe<&2, Nat>, +bs: +List<U32>, +e: {Codec.bytes(Codec.aggregate(m, w)) == Some{bs} : Maybe<&2, +List<U32>>})
    -> {ALLB(bs) == True{} : Bool}:
  match m:
    case None{}: Empty.absurd({ALLB(bs) == True{} : Bool}, FD.logic__none_some(+List<U32>, bs, e))
    case Some{+ps}: agg_r(ps, w, bs, rep(items, ps, em), Layout.encoding(ps), {==}, e)

def req(+c: Bool, +items: S.Value, +w: Maybe<&2, Nat>, +bs: +List<U32>,
    +e: {Codec.bytes(Codec.require(c, Codec.aggregate(Codec.parts(items, S.Repeat{S.Boolean{}}), w))) == Some{bs} : Maybe<&2, +List<U32>>})
    -> {ALLB(bs) == True{} : Bool}:
  match c:
    case False{}: Empty.absurd({ALLB(bs) == True{} : Bool}, FD.logic__none_some(+List<U32>, bs, e))
    case True{}: agg_m(items, Codec.parts(items, S.Repeat{S.Boolean{}}), {==}, w, bs, e)

# every encoding at Vector[boolean, k]: bytes 0 and 1
def vecb(+v: S.Value, +k: Nat, +bs: +List<U32>, +e: {Codec.bytes(Codec.parts(v, S.Vector{S.Boolean{}, k})) == Some{bs} : Maybe<&2, +List<U32>>})
    -> {ALLB(bs) == True{} : Bool}:
  match v:
    case S.Sequence{+items}: req(Bool.and(Nat.is_lt(0n, k), Nat.is_eq(Codec.count(items), k)), items, SS.times(k, SS.fixed_size(S.Boolean{})), bs, e)
    case S.BooleanValue{+b}: Empty.absurd({ALLB(bs) == True{} : Bool}, FD.logic__none_some(+List<U32>, bs, e))
    case S.UnsignedValue{+u}: Empty.absurd({ALLB(bs) == True{} : Bool}, FD.logic__none_some(+List<U32>, bs, e))
    case S.BytesValue{+xs}: Empty.absurd({ALLB(bs) == True{} : Bool}, FD.logic__none_some(+List<U32>, bs, e))
    case S.BitsValue{+bb}: Empty.absurd({ALLB(bs) == True{} : Bool}, FD.logic__none_some(+List<U32>, bs, e))
    case S.Selected{+sel, +sv}: Empty.absurd({ALLB(bs) == True{} : Bool}, FD.logic__none_some(+List<U32>, bs, e))
    case S.NullValue{}: Empty.absurd({ALLB(bs) == True{} : Bool}, FD.logic__none_some(+List<U32>, bs, e))
    case S.EmptyItems{}: Empty.absurd({ALLB(bs) == True{} : Bool}, FD.logic__none_some(+List<U32>, bs, e))
    case S.Items{+hh, +tt}: Empty.absurd({ALLB(bs) == True{} : Bool}, FD.logic__none_some(+List<U32>, bs, e))

# every encoding at boolean: a byte 0 or 1
def boolb(+v: S.Value, +bs: +List<U32>, +e: {Codec.bytes(Codec.parts(v, S.Boolean{})) == Some{bs} : Maybe<&2, +List<U32>>})
    -> {ALLB(bs) == True{} : Bool}:
  match v:
    case S.BooleanValue{+b}:
      FD.logic__subst(+List<U32>, z => {ALLB(z) == True{} : Bool}, SP.boolean_encoding(b), bs, FD.logic__some_inj(+List<U32>, SP.boolean_encoding(b), bs, e), allb_be(b))
    case S.Sequence{+items}: Empty.absurd({ALLB(bs) == True{} : Bool}, FD.logic__none_some(+List<U32>, bs, e))
    case S.UnsignedValue{+u}: Empty.absurd({ALLB(bs) == True{} : Bool}, FD.logic__none_some(+List<U32>, bs, e))
    case S.BytesValue{+xs}: Empty.absurd({ALLB(bs) == True{} : Bool}, FD.logic__none_some(+List<U32>, bs, e))
    case S.BitsValue{+bb}: Empty.absurd({ALLB(bs) == True{} : Bool}, FD.logic__none_some(+List<U32>, bs, e))
    case S.Selected{+sel, +sv}: Empty.absurd({ALLB(bs) == True{} : Bool}, FD.logic__none_some(+List<U32>, bs, e))
    case S.NullValue{}: Empty.absurd({ALLB(bs) == True{} : Bool}, FD.logic__none_some(+List<U32>, bs, e))
    case S.EmptyItems{}: Empty.absurd({ALLB(bs) == True{} : Bool}, FD.logic__none_some(+List<U32>, bs, e))
    case S.Items{+hh, +tt}: Empty.absurd({ALLB(bs) == True{} : Bool}, FD.logic__none_some(+List<U32>, bs, e))

# an encoding at a schema of width w = Some{N} has N bytes (decode_shape.facts)
def len_p(+w: Maybe<&2, Nat>, +N: Nat, +bs: +List<U32>, +ps: +List<S.Part>, hf: DF.single(w, ps),
    +hw: {w == Some{N} : Maybe<&2, Nat>}, +e: {Codec.bytes(Some{ps}) == Some{bs} : Maybe<&2, +List<U32>>})
    -> {Nat.is_eq(List.length(&2, U32, bs), N) == True{} : Bool}:
  match ps:
    case Nil{}: Empty.absurd({Nat.is_eq(List.length(&2, U32, bs), N) == True{} : Bool}, hf)
    case Con{S.Fixed{+xs}, Nil{}}:
      +ex = FD.logic__some_inj(+List<U32>, xs, bs, e)
      +en = FD.logic__some_inj(Nat, N, List.length(&2, U32, xs), Equal.trans(Maybe<&2, Nat>, Some{N}, w, Some{List.length(&2, U32, xs)}, Equal.sym(Maybe<&2, Nat>, w, Some{N}, hw), hf))
      FD.logic__subst(+List<U32>, z => {Nat.is_eq(List.length(&2, U32, z), N) == True{} : Bool}, xs, bs, ex,
        FD.logic__subst(Nat, z => {Nat.is_eq(List.length(&2, U32, xs), z) == True{} : Bool}, List.length(&2, U32, xs), N, Equal.sym(Nat, N, List.length(&2, U32, xs), en), FD.nat__is_eq_refl(List.length(&2, U32, xs))))
    case Con{S.Variable{+xs}, Nil{}}: Empty.absurd({Nat.is_eq(List.length(&2, U32, bs), N) == True{} : Bool}, FD.logic__none_some(Nat, N, Equal.trans(Maybe<&2, Nat>, None{}, w, Some{N}, Equal.sym(Maybe<&2, Nat>, w, None{}, hf), hw)))
    case Con{S.Fixed{+xs}, Con{+a, +b}}: Empty.absurd({Nat.is_eq(List.length(&2, U32, bs), N) == True{} : Bool}, hf)
    case Con{S.Variable{+xs}, Con{+a, +b}}: Empty.absurd({Nat.is_eq(List.length(&2, U32, bs), N) == True{} : Bool}, hf)

def len_eq(+w: Maybe<&2, Nat>, +N: Nat, +bs: +List<U32>, +m: Maybe<&2, +List<S.Part>>, hf: DF.single_result(w, m),
    +hw: {w == Some{N} : Maybe<&2, Nat>}, +e: {Codec.bytes(m) == Some{bs} : Maybe<&2, +List<U32>>})
    -> {Nat.is_eq(List.length(&2, U32, bs), N) == True{} : Bool}:
  match m:
    case None{}: Empty.absurd({Nat.is_eq(List.length(&2, U32, bs), N) == True{} : Bool}, FD.logic__none_some(+List<U32>, bs, e))
    case Some{+ps}: len_p(w, N, bs, ps, hf, hw, e)

# the check of a byte list: its length, and a byte check c
def chk_true(+l: Bool, +c: Bool, +hl: {l == True{} : Bool}, +hc: {c == True{} : Bool}, +h: {Bool.and(l, c) == False{} : Bool}) -> Empty:
  FD.logic__true_false(Equal.trans(Bool, True{}, Bool.and(l, c), False{}, Equal.sym(Bool, Bool.and(l, c), True{}, and_both(l, c, hl, hc)), h))

# ---- the runtime side ---------------------------------------------------------------------------

def BX(+t: FD.array__Tree<U32>, +x: Nat) -> U32: VBL.nthb(UA.BYT(t), x)

# the runtime's byte at off is the byte at off's position
def vx_bx(+t: FD.array__Tree<U32>, +off: U32, +x: Nat, +e: {U32.to_nat(off) == x : Nat}) -> {VR.VX(t, off) == BX(t, x) : U32}:
  %e : {VR.VX(t, off) == VBL.nthb(UA.BYT(t), _) : U32}
  %Equal.sym(Nat, U32.to_nat(off), Nat.add(A.quad(VR.QX(off)), VR.RX(off)), VC.split4(off)) : {VR.VX(t, off) == VBL.nthb(UA.BYT(t), _) : U32}
  %Equal.sym(U32, VBL.nthb(UA.BYT(t), Nat.add(A.quad(VR.QX(off)), VR.RX(off))), VR.bsN(VR.RX(off), VB.slot(t, VR.QX(off))), VR.nth_limbs(VR.SL(t), VR.QX(off), VR.RX(off), UA.rx_lt(off))) :
    {VR.VX(t, off) == _ : U32}
  VR.bs_eq(U32.and(off, 3), VB.slot(t, VR.QX(off)), VR.RX(off), {==}, UA.rx_lt(off))

# O.ok_bool at off (byte position x < 4 2^d) checks the window's byte there
def okb(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +off: U32, +x: Nat, +e: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 28n) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hx: {Nat.is_lt(x, A.quad(VB.pw(d))) == True{} : Bool})
    -> {O.ok_bool(UA.BF(t, n), off) == (UA.BF(t, n), U32.is_le(BX(t, x), 1)) : B.Buf & Bool}:
  %Equal.sym(B.Buf & U32, B.byte_at(UA.BF(t, n), off), (UA.BF(t, n), VR.VX(t, off)), VR.byte_at_ok(d, t, n, off, FD.nat__lt_trans(d, 28n, 32n, hd, {==}), VR.hiX(d, off, x, e, hx), pf)) :
    {O.bool_ok_pick(_) == (UA.BF(t, n), U32.is_le(BX(t, x), 1)) : B.Buf & Bool}
  %Equal.sym(U32, VR.VX(t, off), BX(t, x), vx_bx(t, off, x, e)) :
    {O.bool_ok_pick((UA.BF(t, n), _)) == (UA.BF(t, n), U32.is_le(BX(t, x), 1)) : B.Buf & Bool}
  {==}

# The same at any tree depth d < 31.
def okbD(+d: Nat, +t: FD.array__Tree<U32>, +n: U32, +off: U32, +x: Nat, +e: {U32.to_nat(off) == x : Nat}, +hd: {Nat.is_lt(d, 31n) == True{} : Bool},
    +pf: {FD.array__perfect(U32, d, t) == True{} : Bool}, +hx: {Nat.is_lt(x, A.quad(VB.pw(d))) == True{} : Bool})
    -> {O.ok_bool(UA.BF(t, n), off) == (UA.BF(t, n), U32.is_le(BX(t, x), 1)) : B.Buf & Bool}:
  %Equal.sym(B.Buf & U32, B.byte_at(UA.BF(t, n), off), (UA.BF(t, n), VR.VX(t, off)), VR.byte_at_ok(d, t, n, off, FD.nat__lt_trans(d, 31n, 32n, hd, {==}), VR.hiX(d, off, x, e, hx), pf)) :
    {O.bool_ok_pick(_) == (UA.BF(t, n), U32.is_le(BX(t, x), 1)) : B.Buf & Bool}
  %Equal.sym(U32, VR.VX(t, off), BX(t, x), vx_bx(t, off, x, e)) :
    {O.bool_ok_pick((UA.BF(t, n), _)) == (UA.BF(t, n), U32.is_le(BX(t, x), 1)) : B.Buf & Bool}
  {==}

# bdr(y, L) with y < |L| is the byte at y, then bdr(1 + y, L)
def bdr_con(+y: Nat, +L: +List<U32>, +h: {Nat.is_lt(y, List.length(&2, U32, L)) == True{} : Bool})
    -> {VS.bdr(y, L) == Con{VBL.nthb(L, y), VS.bdr(1n+y, L)} : +List<U32>}:
  match y L:
    case _ Nil{}: Empty.absurd({VS.bdr(y, Nil{}) == Con{VBL.nthb(Nil{}, y), VS.bdr(1n+y, Nil{})} : +List<U32>}, FD.nat__lt_zero_absurd(y, h))
    case 0n Con{+c, +r}: {==}
    case 1n+ +q Con{+c, +r}: bdr_con(q, r, h)

# the window's bytes at y, one at a time
def wxc(+d: Nat, +t: FD.array__Tree<U32>, +y: Nat, +k: Nat, +pf: {FD.array__perfect(U32, d, t) == True{} : Bool},
    +h: {Nat.is_lt(y, A.quad(VB.pw(d))) == True{} : Bool})
    -> {UW.WX(t, y, 1n+k) == Con{BX(t, y), UW.WX(t, 1n+y, k)} : +List<U32>}:
  %Equal.sym(+List<U32>, VS.bdr(y, UA.BYT(t)), Con{VBL.nthb(UA.BYT(t), y), VS.bdr(1n+y, UA.BYT(t))}, bdr_con(y, UA.BYT(t), FD.logic__subst(Nat, z => {Nat.is_lt(y, z) == True{} : Bool}, A.quad(VB.pw(d)), List.length(&2, U32, UA.BYT(t)),
      Equal.sym(Nat, List.length(&2, U32, UA.BYT(t)), A.quad(VB.pw(d)), VR.lenS(d, t, pf)), h))) :
    {VS.bt(1n+k, _) == Con{BX(t, y), UW.WX(t, 1n+y, k)} : +List<U32>}
  {==}

# byte 1 + j is not past byte 1 + k + j
def pmk(+k: Nat, +j: Nat, +x: Nat) -> {Nat.is_le(VRL.pos(1n+j, 1n, x), VRL.pos(Nat.add(1n+k, j), 1n, x)) == True{} : Bool}:
  match k:
    case 0n: FD.nat__le_refl(VRL.pos(1n+j, 1n, x))
    case 1n+ +q: FD.nat__le_trans(VRL.pos(1n+j, 1n, x), VRL.pos(Nat.add(1n+q, j), 1n, x), VRL.pos(Nat.add(2n+q, j), 1n, x), pmk(q, j, x), VRL.pmono(Nat.add(1n+q, j), 1n, x))
