import Base
import ../types/schema.bend as T
import ../src/packed.bend as P
import ../src/cvalue.bend as C
import ../src/decode.bend as D
import ../spec/codec.bend as SC
import ../spec/layout.bend as SL
import ../spec/schema.bend as SS
import ./packed.bend as PK
import ./word_facts.bend as F
import ./complete_leaves.bend as CLeaf
import ./cursor_leaves.bend as CL
import ./lists.bend as L
import ./packing.bend as PKG
import ./layout.bend as LA
import ./primitive_invariants.bend as V
import ./decode_facts.bend as FA
import ./cursor_walk.bend as CW
import ./nat_order.bend as NO
import ./nat_algebra.bend as NA
import ./exact_division.bend as ED
import ./walk.bend as W
import ../spec/nat_bytes.bend as N
import ../spec/primitives.bend as SP
import ./nat_bytes.bend as Digits
import ./layout_offset_value.bend as LOV
import ./layout_image_headers.bend as HW
import ./schema.bend as Sch
import ../src/layout.bend as IL
import ./decode_shape.bend as Shape
import ../src/schema.bend as IS
import ../src/primitives.bend as IP

# Completeness of the layout walk.
#
# `cursor_walk` proves that whatever the walk accepts re-encodes to the region
# it read. These laws are the converse: a region that already holds the
# independent encoding of a field forest is accepted, and the children the walk
# produces read back as exactly those field values.
#
# The decoder accumulates children newest-first, so the source-order reading of
# the accumulator is `C.to_value_go(acc, True{}, T.EmptyItems{})`; appending the
# children still to come is `app_items`.

# Concatenation of two item chains of the neutral representation. It appears
# only in these statements: the runtime never builds it.
def app_items(a: T.Value, +b: T.Value) -> T.Value:
  match a:
    case T.Items{h, t}: T.Items{h, app_items(t, b)}
    case T.EmptyItems{}: b
    case _: a

law app_empty_right:
  for +a: T.Value
  {app_items(a, T.EmptyItems{}) == a : T.Value}
def app_empty_right(a):
  match a:
    case T.Items{h, t}: Equal.cong(T.Value, T.Value, x => T.Items{h, x}, app_items(t, T.EmptyItems{}), t, app_empty_right(t))
    case T.BooleanValue{b}: {==}
    case T.UnsignedValue{v}: {==}
    case T.BytesValue{xs}: {==}
    case T.BitsValue{bs}: {==}
    case T.Sequence{items}: {==}
    case T.EmptyItems{}: {==}
    case T.Selected{s, v}: {==}
    case T.NullValue{}: {==}

law app_assoc:
  for +a: T.Value
  for +b: T.Value
  for +c: T.Value
  {app_items(app_items(a, b), c) == app_items(a, app_items(b, c)) : T.Value}
def app_assoc(a, b, c):
  match a:
    case T.Items{h, t}: Equal.cong(T.Value, T.Value, x => T.Items{h, x}, app_items(app_items(t, b), c), app_items(t, app_items(b, c)), app_assoc(t, b, c))
    case T.BooleanValue{v}: {==}
    case T.UnsignedValue{v}: {==}
    case T.BytesValue{xs}: {==}
    case T.BitsValue{bs}: {==}
    case T.Sequence{items}: {==}
    case T.EmptyItems{}: {==}
    case T.Selected{s, v}: {==}
    case T.NullValue{}: {==}

# The source-order reading of an accumulated chain, as the walk laws use it.
def reading(acc: C.CValue) -> T.Value:
  C.to_value_go(acc, True{}, T.EmptyItems{})

# Folding a chain onto a tail is reading the chain and appending the tail.
law fold_app:
  for +acc: C.CValue
  for +tail: T.Value
  {C.to_value_go(acc, True{}, tail) == app_items(reading(acc), tail) : T.Value}
def fold_app(acc, tail):
  match acc:
    case C.CCons{h, t}:
      Equal.trans(T.Value, C.to_value_go(t, True{}, T.Items{C.to_value(h), tail}), app_items(reading(t), T.Items{C.to_value(h), tail}), app_items(reading(C.CCons{h, t}), tail),
        fold_app(t, T.Items{C.to_value(h), tail}),
        Equal.sym(T.Value, app_items(reading(C.CCons{h, t}), tail), app_items(reading(t), T.Items{C.to_value(h), tail}),
          Equal.trans(T.Value, app_items(reading(C.CCons{h, t}), tail), app_items(app_items(reading(t), T.Items{C.to_value(h), T.EmptyItems{}}), tail), app_items(reading(t), T.Items{C.to_value(h), tail}),
            Equal.cong(T.Value, T.Value, x => app_items(x, tail), reading(C.CCons{h, t}), app_items(reading(t), T.Items{C.to_value(h), T.EmptyItems{}}), fold_app(t, T.Items{C.to_value(h), T.EmptyItems{}})),
            app_assoc(reading(t), T.Items{C.to_value(h), T.EmptyItems{}}, tail))))
    case C.CEnd{}: {==}
    case C.CBool{b}: {==}
    case C.CUint{v}: {==}
    case C.CBytes{p}: {==}
    case C.CBits{bs}: {==}
    case C.CSeq{items}: {==}
    case C.CSel{s, v}: {==}
    case C.CNull{}: {==}

# Prepending one finished child extends the reading on the right.
law reading_step:
  for +acc: C.CValue
  for +cv: C.CValue
  {reading(C.CCons{cv, acc}) == app_items(reading(acc), T.Items{C.to_value(cv), T.EmptyItems{}}) : T.Value}
def reading_step(acc, cv):
  fold_app(acc, T.Items{C.to_value(cv), T.EmptyItems{}})

# Reading an accumulated chain is exactly the neutral view of it.
law reading_is_value:
  for +acc: C.CValue
  {C.to_value(acc) == reading(acc) : T.Value}
def reading_is_value(acc):
  match acc:
    case C.CCons{h, t}: {==}
    case C.CEnd{}: {==}
    case C.CBool{b}: {==}
    case C.CUint{v}: {==}
    case C.CBytes{p}: {==}
    case C.CBits{bs}: {==}
    case C.CSeq{items}: {==}
    case C.CSel{s, v}: {==}
    case C.CNull{}: {==}

# What a completed walk must deliver.
def walk_result(sl: P.Slice, end: Nat, expected: T.Value, out: D.Out) -> Type:
  match out:
    case D.Parsed{v, restsl}:
      {C.to_value(v) == expected : T.Value}
      & {P.slice_bytes(restsl) == List.drop(&2, U32, P.slice_bytes(sl), end) : +List<U32>}
      & {List.length(&2, U32, P.slice_bytes(restsl)) == P.slice_size(restsl) : Nat}
    case _: Empty

# The walk invariant, in the completeness direction: the region still holds the
# encoding of the fields that are left, the cursors are where the parts already
# consumed put them, and the bytes of the whole region are the layout of all of
# them. Premises are arrows so a step can discharge them one at a time.
def walk_goal(sl: P.Slice, end: Nat, fixedtotal: Nat, h: Nat, pos: Nat,
              pdone: +List<T.Part>, ps: +List<T.Part>, fs: T.Schema,
              hdr: P.Slice, pay: P.Slice, acc: C.CValue, rest: T.Value, out: D.Out) -> Type:
  @+wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat} ->
  @+roomsl: {Nat.is_le(end, P.slice_size(sl)) == True{} : Bool} ->
  @+fitend: {N.fits(4n, end) == True{} : Bool} ->
  @+hdrview: {P.slice_bytes(hdr) == List.drop(&2, U32, P.slice_bytes(sl), h) : +List<U32>} ->
  @+wfhdr: {List.length(&2, U32, P.slice_bytes(hdr)) == P.slice_size(hdr) : Nat} ->
  @+payview: {P.slice_bytes(pay) == List.drop(&2, U32, P.slice_bytes(sl), pos) : +List<U32>} ->
  @+wfpay: {List.length(&2, U32, P.slice_bytes(pay)) == P.slice_size(pay) : Nat} ->
  @+sizedone: {SL.fixed_size(pdone) == h : Nat} ->
  @+remaining: {Nat.add(h, SL.fixed_size(ps)) == fixedtotal : Nat} ->
  @+position: {Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))) == pos : Nat} ->
  @+regionsize: {Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, pdone, ps)))) == end : Nat} ->
  @+headerrest: {List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(fixedtotal, h)) == SL.fixed_parts(ps, pos) : +List<U32>} ->
  @+payloadrest: {List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), pos), Nat.sub(end, pos)) == SL.payloads(ps) : +List<U32>} ->
  @+payloadend: {Nat.add(pos, List.length(&2, U32, SL.payloads(ps))) == end : Nat} ->
  @+restparts: {SC.parts(rest, fs) == Some{ps} : Maybe<&2, +List<T.Part>>} ->
  walk_result(sl, end, app_items(reading(acc), rest), out)

# The end of a field forest: nothing is left to read, the payload cursor has
# reached the region end, and the accumulated children are the whole forest.
law parts_some:
  for +r: Maybe<&2, +List<T.Part>>
  for +ps: +List<T.Part>
  for +e: {None{} == Some{ps} : Maybe<&2, +List<T.Part>>}
  Empty
def parts_some(r, ps, e):
  F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CLeaf.parts_present, None{}, Some{ps}, e))

def parts_list(r: Maybe<&2, +List<T.Part>>) -> +List<T.Part>:
  match r:
    case Some{ps}: ps
    case None{}: []

law close_complete:
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +ps: +List<T.Part>
  for +hdr: P.Slice
  for +pay: P.Slice
  for +acc: C.CValue
  for +rest: T.Value
  walk_goal(sl, end, fixedtotal, h, pos, pdone, ps, T.End{}, hdr, pay, acc, rest, D.close(D.Settled{hdr, pay, acc}, pos, end))
def close_complete(sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc, rest):
  match rest:
    case T.EmptyItems{}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
        +empty = Equal.cong(Maybe<&2, +List<T.Part>>, +List<T.Part>, parts_list, Some{[]}, Some{ps}, restparts)
        +posend = Equal.trans(Nat, pos, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), end,
          Equal.sym(Nat, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), pos, position),
          Equal.trans(Nat, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, pdone, ps)))), end,
            Equal.cong(+List<T.Part>, Nat, qs => Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(qs))), pdone, List.append(&2, T.Part, pdone, ps),
              Equal.sym(+List<T.Part>, List.append(&2, T.Part, pdone, ps), pdone,
                Equal.trans(+List<T.Part>, List.append(&2, T.Part, pdone, ps), List.append(&2, T.Part, pdone, []), pdone,
                  Equal.cong(+List<T.Part>, +List<T.Part>, qs => List.append(&2, T.Part, pdone, qs), ps, [], Equal.sym(+List<T.Part>, [], ps, empty)),
                  L.append_empty(T.Part, pdone)))),
            regionsize))
        %Equal.sym(Bool, D.nat_eq(pos, end), True{}, CLeaf.nat_eq_true(pos, end, posend)) : walk_result(sl, end, app_items(reading(acc), T.EmptyItems{}), D.closed(_, acc, pay))
        (Equal.trans(T.Value, C.to_value(acc), reading(acc), app_items(reading(acc), T.EmptyItems{}),
           reading_is_value(acc),
           Equal.sym(T.Value, app_items(reading(acc), T.EmptyItems{}), reading(acc), app_empty_right(reading(acc)))),
         (Equal.trans(+List<U32>, P.slice_bytes(pay), List.drop(&2, U32, P.slice_bytes(sl), pos), List.drop(&2, U32, P.slice_bytes(sl), end),
            payview,
            Equal.cong(Nat, +List<U32>, k => List.drop(&2, U32, P.slice_bytes(sl), k), pos, end, posend)),
          wfpay))
    case T.Items{hv, tv}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
        Empty.absurd(walk_result(sl, end, app_items(reading(acc), T.Items{hv, tv}), D.close(D.Settled{hdr, pay, acc}, pos, end)), parts_some(SC.parts(T.Items{hv, tv}, T.End{}), ps, restparts))
    case T.BooleanValue{b}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
        Empty.absurd(walk_result(sl, end, app_items(reading(acc), T.BooleanValue{b}), D.close(D.Settled{hdr, pay, acc}, pos, end)), parts_some(SC.parts(T.BooleanValue{b}, T.End{}), ps, restparts))
    case T.UnsignedValue{v}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
        Empty.absurd(walk_result(sl, end, app_items(reading(acc), T.UnsignedValue{v}), D.close(D.Settled{hdr, pay, acc}, pos, end)), parts_some(SC.parts(T.UnsignedValue{v}, T.End{}), ps, restparts))
    case T.BytesValue{bs}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
        Empty.absurd(walk_result(sl, end, app_items(reading(acc), T.BytesValue{bs}), D.close(D.Settled{hdr, pay, acc}, pos, end)), parts_some(SC.parts(T.BytesValue{bs}, T.End{}), ps, restparts))
    case T.BitsValue{bs}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
        Empty.absurd(walk_result(sl, end, app_items(reading(acc), T.BitsValue{bs}), D.close(D.Settled{hdr, pay, acc}, pos, end)), parts_some(SC.parts(T.BitsValue{bs}, T.End{}), ps, restparts))
    case T.Sequence{items}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
        Empty.absurd(walk_result(sl, end, app_items(reading(acc), T.Sequence{items}), D.close(D.Settled{hdr, pay, acc}, pos, end)), parts_some(SC.parts(T.Sequence{items}, T.End{}), ps, restparts))
    case T.Selected{s, v}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
        Empty.absurd(walk_result(sl, end, app_items(reading(acc), T.Selected{s, v}), D.close(D.Settled{hdr, pay, acc}, pos, end)), parts_some(SC.parts(T.Selected{s, v}, T.End{}), ps, restparts))
    case T.NullValue{}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
        Empty.absurd(walk_result(sl, end, app_items(reading(acc), T.NullValue{}), D.close(D.Settled{hdr, pay, acc}, pos, end)), parts_some(SC.parts(T.NullValue{}, T.End{}), ps, restparts))

# Eliminating a completed child: `parsed_as` already rules out refusal, and an
# `Out` can be matched only as a parameter, so this hands the components to a
# continuation.
law parsed_elim:
  for -G: Type
  for +out: D.Out
  for +value: T.Value
  for +sl: P.Slice
  for +size: Nat
  for ok: CLeaf.parsed_as(value, sl, size, out)
  for k: @+v: C.CValue -> @+rest: P.Slice -> @+shape: {out == D.Parsed{v, rest} : D.Out} ->
         @+cval: {C.to_value(v) == value : T.Value} ->
         @+crest: {P.slice_bytes(rest) == List.drop(&2, U32, P.slice_bytes(sl), size) : +List<U32>} ->
         @+cwf: {List.length(&2, U32, P.slice_bytes(rest)) == P.slice_size(rest) : Nat} -> G
  G
def parsed_elim(G, out, value, sl, size, ok, k):
  match out:
    case D.Parsed{v, rest}:
      (a, bc) = ok
      (b, c) = bc
      k(v, rest, {==}, a, b, c)
    case D.Refused{}: Empty.absurd(G, ok)
    case D.Begin{r}: Empty.absurd(G, ok)

# ---------------------------------------------------------------------------
# A fixed-size field occupies exactly its fixed size. The shape development
# already proves that a non-forest schema yields one fragment whose width is
# its normative fixed size; this reads that fact off a known fragment.
def width_of(r: Maybe<&2, Nat>) -> Nat:
  match r:
    case Some{n}: n
    case None{}: 0n

law single_here:
  for +schema: T.Schema
  for +value: T.Value
  for +xs: +List<U32>
  for +ok: {FA.ok(schema) == True{} : Bool}
  for legal: {IS.valid_go(schema, False{}) == True{} : Bool}
  for +encoded: {SC.parts(value, schema) == Some{[T.Fixed{xs}]} : Maybe<&2, +List<T.Part>>}
  FA.single_result(SS.fixed_size(schema), Some{[T.Fixed{xs}]})
def single_here(schema, value, xs, ok, legal, encoded):
  %encoded : FA.single_result(SS.fixed_size(schema), _)
  Shape.head_single(schema, value, SC.parts(value, schema), legal, Shape.facts(value, schema, ok))

law fixed_part_length:
  for +schema: T.Schema
  for +value: T.Value
  for +xs: +List<U32>
  for +w: Nat
  for +ok: {FA.ok(schema) == True{} : Bool}
  for legal: {IS.valid_go(schema, False{}) == True{} : Bool}
  for +width: {SS.fixed_size(schema) == Some{w} : Maybe<&2, Nat>}
  for +encoded: {SC.parts(value, schema) == Some{[T.Fixed{xs}]} : Maybe<&2, +List<T.Part>>}
  {List.length(&2, U32, xs) == w : Nat}
def fixed_part_length(schema, value, xs, w, ok, legal, width, encoded):
  Equal.cong(Maybe<&2, Nat>, Nat, width_of, Some{List.length(&2, U32, xs)}, Some{w},
    Equal.trans(Maybe<&2, Nat>, Some{List.length(&2, U32, xs)}, SS.fixed_size(schema), Some{w},
      Equal.sym(Maybe<&2, Nat>, SS.fixed_size(schema), Some{List.length(&2, U32, xs)}, single_here(schema, value, xs, ok, legal, encoded)),
      width))

# ---------------------------------------------------------------------------
# One fixed-width field: the child was read in place at the header cursor, so
# the header advances by its width, the payload cursor does not move, and the
# remaining region still holds the encoding of the fields that are left.
law drop_append_exact:
  for +p: +List<U32>
  for +r: +List<U32>
  for +w: Nat
  for +len: {List.length(&2, U32, p) == w : Nat}
  {List.drop(&2, U32, List.append(&2, U32, p, r), w) == r : +List<U32>}
def drop_append_exact(p, r, w, len):
  %len : {List.drop(&2, U32, List.append(&2, U32, p, r), _) == r : +List<U32>}
  %PKG.add_zero(List.length(&2, U32, p)) : {List.drop(&2, U32, List.append(&2, U32, p, r), _) == r : +List<U32>}
  Equal.trans(+List<U32>, List.drop(&2, U32, List.append(&2, U32, p, r), Nat.add(List.length(&2, U32, p), 0n)), List.drop(&2, U32, r, 0n), r,
    PK.drop_append_offset(p, r, 0n),
    PK.drop_zero(r))

law add_sub_left:
  for +h: Nat
  for +w: Nat
  {Nat.sub(Nat.add(h, w), h) == w : Nat}
def add_sub_left(h, w):
  match h:
    case 0n: PK.sub_zero(w)
    case 1n+p: add_sub_left(p, w)

law header_advance:
  for +sl: P.Slice
  for +h: Nat
  for +w: Nat
  for +fixedtotal: Nat
  for +xs: +List<U32>
  for +tail: +List<U32>
  for +lenxs: {List.length(&2, U32, xs) == w : Nat}
  for +order: {Nat.is_le(h, Nat.add(h, w)) == True{} : Bool}
  for +headerrest: {List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(fixedtotal, h)) == List.append(&2, U32, xs, tail) : +List<U32>}
  {List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), Nat.add(h, w)), Nat.sub(fixedtotal, Nat.add(h, w))) == tail : +List<U32>}
def header_advance(sl, h, w, fixedtotal, xs, tail, lenxs, order, headerrest):
  +dropped = Equal.cong(+List<U32>, +List<U32>, ys => List.drop(&2, U32, ys, w),
    List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(fixedtotal, h)),
    List.append(&2, U32, xs, tail),
    headerrest)
  +tailcut = drop_append_exact(xs, tail, w, lenxs)
  +sizes = Equal.trans(Nat, Nat.sub(Nat.sub(fixedtotal, h), w), Nat.sub(Nat.sub(fixedtotal, h), Nat.sub(Nat.add(h, w), h)), Nat.sub(fixedtotal, Nat.add(h, w)),
    Equal.cong(Nat, Nat, k => Nat.sub(Nat.sub(fixedtotal, h), k), w, Nat.sub(Nat.add(h, w), h), Equal.sym(Nat, Nat.sub(Nat.add(h, w), h), w, add_sub_left(h, w))),
    CW.sub_sub(h, Nat.add(h, w), fixedtotal, order))
  +cursor = Equal.cong(+List<U32>, +List<U32>, ys => List.take(&2, U32, ys, Nat.sub(Nat.sub(fixedtotal, h), w)),
    List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), w), List.drop(&2, U32, P.slice_bytes(sl), Nat.add(h, w)),
    W.drop_drop(P.slice_bytes(sl), h, w))
  +window = Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), Nat.add(h, w)), k),
    Nat.sub(Nat.sub(fixedtotal, h), w), Nat.sub(fixedtotal, Nat.add(h, w)), sizes)
  +lhs = Equal.trans(+List<U32>, List.drop(&2, U32, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(fixedtotal, h)), w),
    List.take(&2, U32, List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), w), Nat.sub(Nat.sub(fixedtotal, h), w)),
    List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), Nat.add(h, w)), Nat.sub(fixedtotal, Nat.add(h, w))),
    PK.drop_take(List.drop(&2, U32, P.slice_bytes(sl), h), w, Nat.sub(fixedtotal, h)),
    Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), w), Nat.sub(Nat.sub(fixedtotal, h), w)),
      List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), Nat.add(h, w)), Nat.sub(Nat.sub(fixedtotal, h), w)),
      List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), Nat.add(h, w)), Nat.sub(fixedtotal, Nat.add(h, w))),
      cursor, window))
  Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), Nat.add(h, w)), Nat.sub(fixedtotal, Nat.add(h, w))),
    List.drop(&2, U32, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(fixedtotal, h)), w),
    tail,
    Equal.sym(+List<U32>, List.drop(&2, U32, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(fixedtotal, h)), w),
      List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), Nat.add(h, w)), Nat.sub(fixedtotal, Nat.add(h, w))), lhs),
    Equal.trans(+List<U32>, List.drop(&2, U32, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(fixedtotal, h)), w),
      List.drop(&2, U32, List.append(&2, U32, xs, tail), w), tail, dropped, tailcut))

law step_fixed_complete:
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +w: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +ps: +List<T.Part>
  for +xs: +List<U32>
  for +hh: T.Schema
  for +tt: T.Schema
  for +hdr: P.Slice
  for +crest: P.Slice
  for +pay: P.Slice
  for +acc: C.CValue
  for +cv: C.CValue
  for +hv: T.Value
  for +tv: T.Value
  for +lenxs: {List.length(&2, U32, xs) == w : Nat}
  for +childvalue: {C.to_value(cv) == hv : T.Value}
  for +childrest: {P.slice_bytes(crest) == List.drop(&2, U32, P.slice_bytes(hdr), w) : +List<U32>}
  for +wfcrest: {List.length(&2, U32, P.slice_bytes(crest)) == P.slice_size(crest) : Nat}
  for +tailparts: {SC.parts(tv, tt) == Some{ps} : Maybe<&2, +List<T.Part>>}
  for rec: walk_goal(sl, end, fixedtotal, Nat.add(h, w), pos, List.append(&2, T.Part, pdone, [T.Fixed{xs}]), ps, tt, crest, pay, C.CCons{cv, acc}, tv, D.go(tt, 0n, 0n, D.Walk{True{}, D.Parsed{cv, crest}, pay, pos, end, acc}))
  walk_goal(sl, end, fixedtotal, h, pos, pdone, T.Fixed{xs} <> ps, T.Chain{hh, tt}, hdr, pay, acc, T.Items{hv, tv}, D.go(tt, 0n, 0n, D.Walk{True{}, D.Parsed{cv, crest}, pay, pos, end, acc}))
def step_fixed_complete(sl, end, fixedtotal, h, w, pos, pdone, ps, xs, hh, tt, hdr, crest, pay, acc, cv, hv, tv, lenxs, childvalue, childrest, wfcrest, tailparts, rec):
  wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
    +valeq = Equal.trans(T.Value, app_items(reading(C.CCons{cv, acc}), tv), app_items(reading(acc), T.Items{C.to_value(cv), tv}), app_items(reading(acc), T.Items{hv, tv}),
      Equal.trans(T.Value, app_items(reading(C.CCons{cv, acc}), tv), app_items(app_items(reading(acc), T.Items{C.to_value(cv), T.EmptyItems{}}), tv), app_items(reading(acc), T.Items{C.to_value(cv), tv}),
        Equal.cong(T.Value, T.Value, x => app_items(x, tv), reading(C.CCons{cv, acc}), app_items(reading(acc), T.Items{C.to_value(cv), T.EmptyItems{}}), reading_step(acc, cv)),
        app_assoc(reading(acc), T.Items{C.to_value(cv), T.EmptyItems{}}, tv)),
      Equal.cong(T.Value, T.Value, x => app_items(reading(acc), T.Items{x, tv}), C.to_value(cv), hv, childvalue))
    +widthsum = Equal.trans(Nat, Nat.add(h, Nat.add(w, SL.fixed_size(ps))), Nat.add(h, Nat.add(List.length(&2, U32, xs), SL.fixed_size(ps))), fixedtotal,
      Equal.cong(Nat, Nat, k => Nat.add(h, Nat.add(k, SL.fixed_size(ps))), w, List.length(&2, U32, xs), Equal.sym(Nat, List.length(&2, U32, xs), w, lenxs)),
      remaining)
    %valeq : walk_result(sl, end, _, D.go(tt, 0n, 0n, D.Walk{True{}, D.Parsed{cv, crest}, pay, pos, end, acc}))
    rec(wfsl, roomsl, fitend,
      Equal.trans(+List<U32>, P.slice_bytes(crest), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), w), List.drop(&2, U32, P.slice_bytes(sl), Nat.add(h, w)),
        Equal.trans(+List<U32>, P.slice_bytes(crest), List.drop(&2, U32, P.slice_bytes(hdr), w), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), w),
          childrest,
          Equal.cong(+List<U32>, +List<U32>, ys => List.drop(&2, U32, ys, w), P.slice_bytes(hdr), List.drop(&2, U32, P.slice_bytes(sl), h), hdrview)),
        W.drop_drop(P.slice_bytes(sl), h, w)),
      wfcrest,
      payview,
      wfpay,
      CW.fixed_size_snoc(pdone, xs, h, w, sizedone, lenxs),
      CW.remaining_fixed(h, w, SL.fixed_size(ps), fixedtotal, widthsum),
      Equal.trans(Nat, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, pdone, [T.Fixed{xs}])))), Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), pos,
        Equal.cong(+List<U32>, Nat, ys => Nat.add(fixedtotal, List.length(&2, U32, ys)), SL.payloads(List.append(&2, T.Part, pdone, [T.Fixed{xs}])), SL.payloads(pdone), CW.payloads_snoc_fixed(pdone, xs)),
        position),
      Equal.trans(Nat, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, List.append(&2, T.Part, pdone, [T.Fixed{xs}]), ps)))), Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, pdone, T.Fixed{xs} <> ps)))), end,
        Equal.cong(+List<T.Part>, Nat, qs => Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(qs))), List.append(&2, T.Part, List.append(&2, T.Part, pdone, [T.Fixed{xs}]), ps), List.append(&2, T.Part, pdone, T.Fixed{xs} <> ps),
          L.append_associative(T.Part, pdone, [T.Fixed{xs}], ps)),
        regionsize),
      header_advance(sl, h, w, fixedtotal, xs, SL.fixed_parts(ps, pos), lenxs, NO.below_sum(h, w), headerrest),
      payloadrest,
      payloadend,
      tailparts)

# ---------------------------------------------------------------------------
# Reading a variable field's offset back out of the header: the four header
# bytes at the cursor are the canonical digits of the payload position, and
# little-endian digits are read back as exactly that position.
law value_of_digits:
  for +pos: Nat
  for +fit: {N.fits(4n, pos) == True{} : Bool}
  {N.value(N.digits(4n, pos)) == pos : Nat}
def value_of_digits(pos, fit):
  Equal.trans(Nat, N.value(N.digits(4n, pos)), U32.to_nat(SP.limb_value(N.digits(4n, pos), 0n)), pos,
    Equal.sym(Nat, U32.to_nat(SP.limb_value(N.digits(4n, pos), 0n)), N.value(N.digits(4n, pos)),
      LOV.scope_value(N.digits(4n, pos), Digits.digits_scope(4n, pos))),
    LOV.offset_digits(pos, fit))

law offset_here:
  for +hdr: P.Slice
  for +pos: Nat
  for +fit: {N.fits(4n, pos) == True{} : Bool}
  for +bytes4: {N.digits(4n, pos) == List.take(&2, U32, P.slice_bytes(hdr), 4n) : +List<U32>}
  {P.offset_at(hdr) == pos : Nat}
def offset_here(hdr, pos, fit, bytes4):
  Equal.trans(Nat, P.offset_at(hdr), N.value(N.digits(4n, pos)), pos,
    CW.offset_value(hdr, N.digits(4n, pos), Digits.digits_length(4n, pos), Digits.digits_domain(4n, pos), bytes4),
    value_of_digits(pos, fit))

# ---------------------------------------------------------------------------
# Scanning the rest of the header for the next variable field's offset.
#
# `starts_with(s, ys)` says the slice begins with exactly those bytes; the walk
# holds that for the remaining header and the layout of the remaining parts.
def starts_with(s: P.Slice, ys: +List<U32>) -> Type:
  {List.take(&2, U32, P.slice_bytes(s), List.length(&2, U32, ys)) == ys : +List<U32>}

def head_of(xs: +List<U32>) -> U32:
  match xs:
    case Con{h, t}: h
    case Nil{}: 0

def tail_of(xs: +List<U32>) -> +List<U32>:
  match xs:
    case Con{h, t}: t
    case Nil{}: []

def is_cons(xs: +List<U32>) -> Bool:
  match xs:
    case Con{h, t}: True{}
    case Nil{}: False{}

law starts_head:
  for +bytes: +List<U32>
  for +a: +List<U32>
  for +b: +List<U32>
  for +pre: {List.take(&2, U32, bytes, List.length(&2, U32, List.append(&2, U32, a, b))) == List.append(&2, U32, a, b) : +List<U32>}
  {List.take(&2, U32, bytes, List.length(&2, U32, a)) == a : +List<U32>}
def starts_head(bytes, a, b, pre):
  match bytes a:
    case Nil{} Nil{}: {==}
    case Con{y, ys} Nil{}: {==}
    case Nil{} Con{x, t}:
      Empty.absurd({List.take(&2, U32, [], List.length(&2, U32, x <> t)) == x <> t : +List<U32>},
        F.false_true(Equal.cong(+List<U32>, Bool, is_cons, [], List.append(&2, U32, x <> t, b), pre)))
    case Con{y, ys} Con{x, t}:
      Equal.trans(+List<U32>, y <> List.take(&2, U32, ys, List.length(&2, U32, t)), y <> t, x <> t,
        Equal.cong(+List<U32>, +List<U32>, zs => y <> zs, List.take(&2, U32, ys, List.length(&2, U32, t)), t,
          starts_head(ys, t, b, Equal.cong(+List<U32>, +List<U32>, tail_of, y <> List.take(&2, U32, ys, List.length(&2, U32, List.append(&2, U32, t, b))), x <> List.append(&2, U32, t, b), pre))),
        Equal.cong(U32, +List<U32>, z => z <> t, y, x,
          Equal.cong(+List<U32>, U32, head_of, y <> List.take(&2, U32, ys, List.length(&2, U32, List.append(&2, U32, t, b))), x <> List.append(&2, U32, t, b), pre)))

law starts_tail:
  for +bytes: +List<U32>
  for +a: +List<U32>
  for +b: +List<U32>
  for +pre: {List.take(&2, U32, bytes, List.length(&2, U32, List.append(&2, U32, a, b))) == List.append(&2, U32, a, b) : +List<U32>}
  {List.take(&2, U32, List.drop(&2, U32, bytes, List.length(&2, U32, a)), List.length(&2, U32, b)) == b : +List<U32>}
def starts_tail(bytes, a, b, pre):
  match bytes a:
    case Nil{} Nil{}: pre
    case Con{y, ys} Nil{}: pre
    case Nil{} Con{x, t}:
      Empty.absurd({List.take(&2, U32, List.drop(&2, U32, [], List.length(&2, U32, x <> t)), List.length(&2, U32, b)) == b : +List<U32>},
        F.false_true(Equal.cong(+List<U32>, Bool, is_cons, [], List.append(&2, U32, x <> t, b), pre)))
    case Con{y, ys} Con{x, t}:
      starts_tail(ys, t, b, Equal.cong(+List<U32>, +List<U32>, tail_of, y <> List.take(&2, U32, ys, List.length(&2, U32, List.append(&2, U32, t, b))), x <> List.append(&2, U32, t, b), pre))

# The next variable field's offset, as the specification sees the remaining
# parts: the first `Variable` part carries the payload position, and a header
# of only fixed parts has no further offset.
def first_offset(ps: +List<T.Part>, +pos: Nat) -> Maybe<&2, Nat>:
  match ps:
    case Nil{}: None{}
    case Con{T.Fixed{xs}, t}: first_offset(t, pos)
    case Con{T.Variable{xs}, t}: Some{pos}

def is_cons_w(ws: +List<Maybe<&2, Nat>>) -> Bool:
  match ws:
    case Con{w, t}: True{}
    case Nil{}: False{}

def head_w(ws: +List<Maybe<&2, Nat>>) -> Maybe<&2, Nat>:
  match ws:
    case Con{w, t}: w
    case Nil{}: None{}

def tail_w(ws: +List<Maybe<&2, Nat>>) -> +List<Maybe<&2, Nat>>:
  match ws:
    case Con{w, t}: t
    case Nil{}: []

law no_offset_here:
  for +tt: T.Schema
  for +more: P.Slice
  for +empty: {FA.widths(tt) == [] : +List<Maybe<&2, Nat>>}
  {D.next_offset(tt, more) == None{} : Maybe<&2, Nat>}
def no_offset_here(tt, more, empty):
  match tt:
    case T.Chain{s0, s1}: Empty.absurd({D.next_offset(T.Chain{s0, s1}, more) == None{} : Maybe<&2, Nat>}, F.false_true(Equal.sym(Bool, True{}, False{}, Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, FA.widths(T.Chain{s0, s1}), [], empty))))
    case T.Boolean{}: {==}
    case T.Unsigned{s0}: {==}
    case T.ByteVector{s0}: {==}
    case T.ByteList{s0}: {==}
    case T.BitVector{s0}: {==}
    case T.BitList{s0}: {==}
    case T.Vector{s0, s1}: {==}
    case T.ListOf{s0, s1}: {==}
    case T.Container{s0, s1}: {==}
    case T.Union{s0}: {==}
    case T.Null{}: {==}
    case T.End{}: {==}
    case T.Repeat{s0}: {==}
    case T.Named{s0, s1}: {==}
    case T.ProgressiveList{s0}: {==}
    case T.ProgressiveBits{}: {==}
    case T.ProgressiveContainer{s0, s1, s2}: {==}
    case T.CompatibleUnion{s0, s1}: {==}

law chain_elim:
  for -G: Type
  for +tt: T.Schema
  for +w: Maybe<&2, Nat>
  for +ws: +List<Maybe<&2, Nat>>
  for +align: {FA.widths(tt) == w <> ws : +List<Maybe<&2, Nat>>}
  for k: @h: T.Schema -> @t: T.Schema -> {tt == T.Chain{h, t} : T.Schema} -> {SS.fixed_size(h) == w : Maybe<&2, Nat>} -> {FA.widths(t) == ws : +List<Maybe<&2, Nat>>} -> G
  G
def chain_elim(G, tt, w, ws, align, k):
  match tt:
    case T.Chain{s0, s1}:
      k(s0, s1, {==},
        Equal.cong(+List<Maybe<&2, Nat>>, Maybe<&2, Nat>, head_w, FA.widths(T.Chain{s0, s1}), w <> ws, align),
        Equal.cong(+List<Maybe<&2, Nat>>, +List<Maybe<&2, Nat>>, tail_w, FA.widths(T.Chain{s0, s1}), w <> ws, align))
    case T.Boolean{}: Empty.absurd(G, F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, FA.widths(T.Boolean{}), w <> ws, align)))
    case T.Unsigned{s0}: Empty.absurd(G, F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, FA.widths(T.Unsigned{s0}), w <> ws, align)))
    case T.ByteVector{s0}: Empty.absurd(G, F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, FA.widths(T.ByteVector{s0}), w <> ws, align)))
    case T.ByteList{s0}: Empty.absurd(G, F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, FA.widths(T.ByteList{s0}), w <> ws, align)))
    case T.BitVector{s0}: Empty.absurd(G, F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, FA.widths(T.BitVector{s0}), w <> ws, align)))
    case T.BitList{s0}: Empty.absurd(G, F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, FA.widths(T.BitList{s0}), w <> ws, align)))
    case T.Vector{s0, s1}: Empty.absurd(G, F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, FA.widths(T.Vector{s0, s1}), w <> ws, align)))
    case T.ListOf{s0, s1}: Empty.absurd(G, F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, FA.widths(T.ListOf{s0, s1}), w <> ws, align)))
    case T.Container{s0, s1}: Empty.absurd(G, F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, FA.widths(T.Container{s0, s1}), w <> ws, align)))
    case T.Union{s0}: Empty.absurd(G, F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, FA.widths(T.Union{s0}), w <> ws, align)))
    case T.Null{}: Empty.absurd(G, F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, FA.widths(T.Null{}), w <> ws, align)))
    case T.End{}: Empty.absurd(G, F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, FA.widths(T.End{}), w <> ws, align)))
    case T.Repeat{s0}: Empty.absurd(G, F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, FA.widths(T.Repeat{s0}), w <> ws, align)))
    case T.Named{s0, s1}: Empty.absurd(G, F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, FA.widths(T.Named{s0, s1}), w <> ws, align)))
    case T.ProgressiveList{s0}: Empty.absurd(G, F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, FA.widths(T.ProgressiveList{s0}), w <> ws, align)))
    case T.ProgressiveBits{}: Empty.absurd(G, F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, FA.widths(T.ProgressiveBits{}), w <> ws, align)))
    case T.ProgressiveContainer{s0, s1, s2}: Empty.absurd(G, F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, FA.widths(T.ProgressiveContainer{s0, s1, s2}), w <> ws, align)))
    case T.CompatibleUnion{s0, s1}: Empty.absurd(G, F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, FA.widths(T.CompatibleUnion{s0, s1}), w <> ws, align)))

law next_offset_value:
  for +ps: +List<T.Part>
  for +tt: T.Schema
  for +more: P.Slice
  for +pos: Nat
  for +fit: {N.fits(4n, pos) == True{} : Bool}
  for +align: {HW.widths(ps) == FA.widths(tt) : +List<Maybe<&2, Nat>>}
  for pre: starts_with(more, SL.fixed_parts(ps, pos))
  {D.next_offset(tt, more) == first_offset(ps, pos) : Maybe<&2, Nat>}
def next_offset_value(ps, tt, more, pos, fit, align, pre):
  match ps:
    case Nil{}:
      no_offset_here(tt, more, Equal.sym(+List<Maybe<&2, Nat>>, [], FA.widths(tt), align))
    case Con{T.Fixed{xs}, t}:
      chain_elim({D.next_offset(tt, more) == first_offset(T.Fixed{xs} <> t, pos) : Maybe<&2, Nat>}, tt, Some{List.length(&2, U32, xs)}, HW.widths(t),
        Equal.sym(+List<Maybe<&2, Nat>>, HW.widths(T.Fixed{xs} <> t), FA.widths(tt), align),
        h => tl => tteq => weq => wseq =>
          %Equal.sym(T.Schema, tt, T.Chain{h, tl}, tteq) : {D.next_offset(_, more) == first_offset(T.Fixed{xs} <> t, pos) : Maybe<&2, Nat>}
          %Equal.sym(Maybe<&2, Nat>, IS.fixed_size(h), Some{List.length(&2, U32, xs)}, Equal.trans(Maybe<&2, Nat>, IS.fixed_size(h), SS.fixed_size(h), Some{List.length(&2, U32, xs)}, Sch.fixed_size_correct(h), weq)) : {D.next_field(_, more, rest => D.next_offset(tl, rest)) == first_offset(T.Fixed{xs} <> t, pos) : Maybe<&2, Nat>}
          next_offset_value(t, tl, P.adv(more, List.length(&2, U32, xs)), pos, fit,
            Equal.sym(+List<Maybe<&2, Nat>>, FA.widths(tl), HW.widths(t), wseq),
            Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(P.adv(more, List.length(&2, U32, xs))), List.length(&2, U32, SL.fixed_parts(t, pos))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(more), List.length(&2, U32, xs)), List.length(&2, U32, SL.fixed_parts(t, pos))), SL.fixed_parts(t, pos),
              Equal.cong(+List<U32>, +List<U32>, ys => List.take(&2, U32, ys, List.length(&2, U32, SL.fixed_parts(t, pos))), P.slice_bytes(P.adv(more, List.length(&2, U32, xs))), List.drop(&2, U32, P.slice_bytes(more), List.length(&2, U32, xs)), PK.adv_view(more, List.length(&2, U32, xs))),
              starts_tail(P.slice_bytes(more), xs, SL.fixed_parts(t, pos), pre))))
    case Con{T.Variable{xs}, t}:
      chain_elim({D.next_offset(tt, more) == first_offset(T.Variable{xs} <> t, pos) : Maybe<&2, Nat>}, tt, None{}, HW.widths(t),
        Equal.sym(+List<Maybe<&2, Nat>>, HW.widths(T.Variable{xs} <> t), FA.widths(tt), align),
        h => tl => tteq => weq => wseq =>
          %Equal.sym(T.Schema, tt, T.Chain{h, tl}, tteq) : {D.next_offset(_, more) == first_offset(T.Variable{xs} <> t, pos) : Maybe<&2, Nat>}
          %Equal.sym(Maybe<&2, Nat>, IS.fixed_size(h), None{}, Equal.trans(Maybe<&2, Nat>, IS.fixed_size(h), SS.fixed_size(h), None{}, Sch.fixed_size_correct(h), weq)) : {D.next_field(_, more, rest => D.next_offset(tl, rest)) == first_offset(T.Variable{xs} <> t, pos) : Maybe<&2, Nat>}
          Equal.cong(Nat, Maybe<&2, Nat>, k => Some{k}, P.offset_at(more), pos,
            offset_here(more, pos, fit,
              Equal.trans(+List<U32>, N.digits(4n, pos), List.take(&2, U32, P.slice_bytes(more), List.length(&2, U32, N.digits(4n, pos))), List.take(&2, U32, P.slice_bytes(more), 4n),
                Equal.sym(+List<U32>, List.take(&2, U32, P.slice_bytes(more), List.length(&2, U32, N.digits(4n, pos))), N.digits(4n, pos),
                  starts_head(P.slice_bytes(more), N.digits(4n, pos), SL.fixed_parts(t, Nat.add(pos, List.length(&2, U32, xs))), pre)),
                Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(more), k), List.length(&2, U32, N.digits(4n, pos)), 4n, Digits.digits_length(4n, pos))))))

# Where the current variable child ends: the next offset in the header if there
# is one, otherwise the region end - and both are the same position.
law first_offset_value:
  for +ps: +List<T.Part>
  for +pos: Nat
  for +k: Nat
  for +same: {first_offset(ps, pos) == Some{k} : Maybe<&2, Nat>}
  {k == pos : Nat}
def first_offset_value(ps, pos, k, same):
  match ps:
    case Nil{}: Empty.absurd({k == pos : Nat}, F.false_true(Equal.cong(Maybe<&2, Nat>, Bool, CLeaf.is_some_nat, None{}, Some{k}, same)))
    case Con{T.Fixed{xs}, t}: first_offset_value(t, pos, k, same)
    case Con{T.Variable{xs}, t}: Equal.sym(Nat, pos, k, Equal.cong(Maybe<&2, Nat>, Nat, CLeaf.nat_of, Some{pos}, Some{k}, same))

law fixed_only_payloads:
  for +ps: +List<T.Part>
  for +pos: Nat
  for +none: {first_offset(ps, pos) == None{} : Maybe<&2, Nat>}
  {SL.payloads(ps) == [] : +List<U32>}
def fixed_only_payloads(ps, pos, none):
  match ps:
    case Nil{}: {==}
    case Con{T.Fixed{xs}, t}: fixed_only_payloads(t, pos, none)
    case Con{T.Variable{xs}, t}: Empty.absurd({SL.payloads(T.Variable{xs} <> t) == [] : +List<U32>}, F.false_true(Equal.sym(Bool, True{}, False{}, Equal.cong(Maybe<&2, Nat>, Bool, CLeaf.is_some_nat, Some{pos}, None{}, none))))

law stop_at:
  for r: Maybe<&2, Nat>
  for +ps: +List<T.Part>
  for +pos: Nat
  for +end: Nat
  for +same: {first_offset(ps, pos) == r : Maybe<&2, Nat>}
  for +payloadend: {Nat.add(pos, List.length(&2, U32, SL.payloads(ps))) == end : Nat}
  {D.or_end(r, end) == pos : Nat}
def stop_at(r, ps, pos, end, same, payloadend):
  match r:
    case Some{k}: first_offset_value(ps, pos, k, same)
    case None{}:
      Equal.sym(Nat, pos, end,
        Equal.trans(Nat, pos, Nat.add(pos, 0n), end,
          Equal.sym(Nat, Nat.add(pos, 0n), pos, PKG.add_zero(pos)),
          Equal.trans(Nat, Nat.add(pos, 0n), Nat.add(pos, List.length(&2, U32, SL.payloads(ps))), end,
            Equal.cong(+List<U32>, Nat, ys => Nat.add(pos, List.length(&2, U32, ys)), [], SL.payloads(ps),
              Equal.sym(+List<U32>, SL.payloads(ps), [], fixed_only_payloads(ps, pos, same))),
            payloadend)))

# ---------------------------------------------------------------------------
# One variable-width field: the header gains four offset bytes, the payload
# cursor advances past the child's bytes, and the remaining region still holds
# the layout of the fields that are left.
law step_variable_complete:
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +ps: +List<T.Part>
  for +xs: +List<U32>
  for +hh: T.Schema
  for +tt: T.Schema
  for +hdr: P.Slice
  for +crest: P.Slice
  for +pay: P.Slice
  for +acc: C.CValue
  for +cv: C.CValue
  for +hv: T.Value
  for +tv: T.Value
  for +childvalue: {C.to_value(cv) == hv : T.Value}
  for +childrest: {P.slice_bytes(crest) == List.drop(&2, U32, P.slice_bytes(pay), List.length(&2, U32, xs)) : +List<U32>}
  for +wfcrest: {List.length(&2, U32, P.slice_bytes(crest)) == P.slice_size(crest) : Nat}
  for +tailparts: {SC.parts(tv, tt) == Some{ps} : Maybe<&2, +List<T.Part>>}
  for rec: walk_goal(sl, end, fixedtotal, Nat.add(h, 4n), Nat.add(pos, List.length(&2, U32, xs)), List.append(&2, T.Part, pdone, [T.Variable{xs}]), ps, tt, P.adv(hdr, 4n), crest, C.CCons{cv, acc}, tv, D.go(tt, 0n, 0n, D.Walk{False{}, D.Parsed{cv, crest}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, xs)), end, acc}))
  walk_goal(sl, end, fixedtotal, h, pos, pdone, T.Variable{xs} <> ps, T.Chain{hh, tt}, hdr, pay, acc, T.Items{hv, tv}, D.go(tt, 0n, 0n, D.Walk{False{}, D.Parsed{cv, crest}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, xs)), end, acc}))
def step_variable_complete(sl, end, fixedtotal, h, pos, pdone, ps, xs, hh, tt, hdr, crest, pay, acc, cv, hv, tv, childvalue, childrest, wfcrest, tailparts, rec):
  wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
    +valeq = Equal.trans(T.Value, app_items(reading(C.CCons{cv, acc}), tv), app_items(reading(acc), T.Items{C.to_value(cv), tv}), app_items(reading(acc), T.Items{hv, tv}),
      Equal.trans(T.Value, app_items(reading(C.CCons{cv, acc}), tv), app_items(app_items(reading(acc), T.Items{C.to_value(cv), T.EmptyItems{}}), tv), app_items(reading(acc), T.Items{C.to_value(cv), tv}),
        Equal.cong(T.Value, T.Value, x => app_items(x, tv), reading(C.CCons{cv, acc}), app_items(reading(acc), T.Items{C.to_value(cv), T.EmptyItems{}}), reading_step(acc, cv)),
        app_assoc(reading(acc), T.Items{C.to_value(cv), T.EmptyItems{}}, tv)),
      Equal.cong(T.Value, T.Value, x => app_items(reading(acc), T.Items{x, tv}), C.to_value(cv), hv, childvalue))
    %valeq : walk_result(sl, end, _, D.go(tt, 0n, 0n, D.Walk{False{}, D.Parsed{cv, crest}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, xs)), end, acc}))
    rec(wfsl, roomsl, fitend,
      Equal.trans(+List<U32>, P.slice_bytes(P.adv(hdr, 4n)), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), 4n), List.drop(&2, U32, P.slice_bytes(sl), Nat.add(h, 4n)),
        Equal.trans(+List<U32>, P.slice_bytes(P.adv(hdr, 4n)), List.drop(&2, U32, P.slice_bytes(hdr), 4n), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), 4n),
          PK.adv_view(hdr, 4n),
          Equal.cong(+List<U32>, +List<U32>, ys => List.drop(&2, U32, ys, 4n), P.slice_bytes(hdr), List.drop(&2, U32, P.slice_bytes(sl), h), hdrview)),
        W.drop_drop(P.slice_bytes(sl), h, 4n)),
      PK.wf_adv(hdr, 4n, wfhdr),
      Equal.trans(+List<U32>, P.slice_bytes(crest), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), pos), List.length(&2, U32, xs)), List.drop(&2, U32, P.slice_bytes(sl), Nat.add(pos, List.length(&2, U32, xs))),
        Equal.trans(+List<U32>, P.slice_bytes(crest), List.drop(&2, U32, P.slice_bytes(pay), List.length(&2, U32, xs)), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), pos), List.length(&2, U32, xs)),
          childrest,
          Equal.cong(+List<U32>, +List<U32>, ys => List.drop(&2, U32, ys, List.length(&2, U32, xs)), P.slice_bytes(pay), List.drop(&2, U32, P.slice_bytes(sl), pos), payview)),
        W.drop_drop(P.slice_bytes(sl), pos, List.length(&2, U32, xs))),
      wfcrest,
      CW.fixed_size_snoc_variable(pdone, xs, h, sizedone),
      CW.remaining_fixed(h, 4n, SL.fixed_size(ps), fixedtotal, remaining),
      Equal.trans(Nat, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, pdone, [T.Variable{xs}])))), Nat.add(Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), List.length(&2, U32, xs)), Nat.add(pos, List.length(&2, U32, xs)),
        Equal.trans(Nat, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, pdone, [T.Variable{xs}])))), Nat.add(fixedtotal, Nat.add(List.length(&2, U32, SL.payloads(pdone)), List.length(&2, U32, xs))), Nat.add(Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), List.length(&2, U32, xs)),
          Equal.cong(Nat, Nat, k => Nat.add(fixedtotal, k), List.length(&2, U32, SL.payloads(List.append(&2, T.Part, pdone, [T.Variable{xs}]))), Nat.add(List.length(&2, U32, SL.payloads(pdone)), List.length(&2, U32, xs)),
            Equal.trans(Nat, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, pdone, [T.Variable{xs}]))), List.length(&2, U32, List.append(&2, U32, SL.payloads(pdone), xs)), Nat.add(List.length(&2, U32, SL.payloads(pdone)), List.length(&2, U32, xs)),
              Equal.cong(+List<U32>, Nat, ys => List.length(&2, U32, ys), SL.payloads(List.append(&2, T.Part, pdone, [T.Variable{xs}])), List.append(&2, U32, SL.payloads(pdone), xs), CW.payloads_snoc_variable(pdone, xs)),
              L.append_length(U32, SL.payloads(pdone), xs))),
          Equal.sym(Nat, Nat.add(Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), List.length(&2, U32, xs)), Nat.add(fixedtotal, Nat.add(List.length(&2, U32, SL.payloads(pdone)), List.length(&2, U32, xs))), LA.add_associative(fixedtotal, List.length(&2, U32, SL.payloads(pdone)), List.length(&2, U32, xs)))),
        Equal.cong(Nat, Nat, k => Nat.add(k, List.length(&2, U32, xs)), Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), pos, position)),
      Equal.trans(Nat, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, List.append(&2, T.Part, pdone, [T.Variable{xs}]), ps)))), Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, pdone, T.Variable{xs} <> ps)))), end,
        Equal.cong(+List<T.Part>, Nat, qs => Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(qs))), List.append(&2, T.Part, List.append(&2, T.Part, pdone, [T.Variable{xs}]), ps), List.append(&2, T.Part, pdone, T.Variable{xs} <> ps),
          L.append_associative(T.Part, pdone, [T.Variable{xs}], ps)),
        regionsize),
      header_advance(sl, h, 4n, fixedtotal, N.digits(4n, pos), SL.fixed_parts(ps, Nat.add(pos, List.length(&2, U32, xs))), Digits.digits_length(4n, pos), NO.below_sum(h, 4n), headerrest),
      header_advance(sl, pos, List.length(&2, U32, xs), end, xs, SL.payloads(ps), {==}, NO.below_sum(pos, List.length(&2, U32, xs)), payloadrest),
      Equal.trans(Nat, Nat.add(Nat.add(pos, List.length(&2, U32, xs)), List.length(&2, U32, SL.payloads(ps))), Nat.add(pos, Nat.add(List.length(&2, U32, xs), List.length(&2, U32, SL.payloads(ps)))), end,
        LA.add_associative(pos, List.length(&2, U32, xs), List.length(&2, U32, SL.payloads(ps))),
        Equal.trans(Nat, Nat.add(pos, Nat.add(List.length(&2, U32, xs), List.length(&2, U32, SL.payloads(ps)))), Nat.add(pos, List.length(&2, U32, SL.payloads(T.Variable{xs} <> ps))), end,
          Equal.cong(Nat, Nat, k => Nat.add(pos, k), Nat.add(List.length(&2, U32, xs), List.length(&2, U32, SL.payloads(ps))), List.length(&2, U32, SL.payloads(T.Variable{xs} <> ps)),
            Equal.sym(Nat, List.length(&2, U32, SL.payloads(T.Variable{xs} <> ps)), Nat.add(List.length(&2, U32, xs), List.length(&2, U32, SL.payloads(ps))), L.append_length(U32, xs, SL.payloads(ps)))),
          payloadend)),
      tailparts)

# The decoder's plan for a variable-width field, once its offset and the next
# offset are known: the child is the payload span [pos, pos+|xs|) and the walk
# continues with the header advanced by four bytes.
law variable_plan:
  for +hdr: P.Slice
  for +pay: P.Slice
  for +acc: C.CValue
  for +tt: T.Schema
  for +pos: Nat
  for +end: Nat
  for +xs: +List<U32>
  for +offsetok: {P.offset_at(hdr) == pos : Nat}
  for +stopok: {D.or_end(D.ahead(D.Later{tt}, P.adv(hdr, 4n)), end) == Nat.add(pos, List.length(&2, U32, xs)) : Nat}
  for +fits_end: {Nat.is_le(Nat.add(pos, List.length(&2, U32, xs)), end) == True{} : Bool}
  {D.plan(D.Settled{hdr, pay, acc}, None{}, pos, end, D.Later{tt}) == D.Plan{D.Region{List.length(&2, U32, xs), pay}, False{}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, xs)), acc} : D.Plan}
def variable_plan(hdr, pay, acc, tt, pos, end, xs, offsetok, stopok, fits_end):
  %Equal.sym(Nat, P.offset_at(hdr), pos, offsetok) : {D.Plan{D.region_if(Bool.and(D.nat_eq(_, pos), Bool.and(D.nat_le(_, D.or_end(D.ahead(D.Later{tt}, P.adv(hdr, 4n)), end)), D.nat_le(D.or_end(D.ahead(D.Later{tt}, P.adv(hdr, 4n)), end), end))), Nat.sub(D.or_end(D.ahead(D.Later{tt}, P.adv(hdr, 4n)), end), _), pay), False{}, P.adv(hdr, 4n), D.or_end(D.ahead(D.Later{tt}, P.adv(hdr, 4n)), end), acc} == D.Plan{D.Region{List.length(&2, U32, xs), pay}, False{}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, xs)), acc} : D.Plan}
  %Equal.sym(Nat, D.or_end(D.ahead(D.Later{tt}, P.adv(hdr, 4n)), end), Nat.add(pos, List.length(&2, U32, xs)), stopok) : {D.Plan{D.region_if(Bool.and(D.nat_eq(pos, pos), Bool.and(D.nat_le(pos, _), D.nat_le(_, end))), Nat.sub(_, pos), pay), False{}, P.adv(hdr, 4n), _, acc} == D.Plan{D.Region{List.length(&2, U32, xs), pay}, False{}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, xs)), acc} : D.Plan}
  %Equal.sym(Bool, Bool.and(D.nat_eq(pos, pos), Bool.and(D.nat_le(pos, Nat.add(pos, List.length(&2, U32, xs))), D.nat_le(Nat.add(pos, List.length(&2, U32, xs)), end))), True{},
    V.and_true(D.nat_eq(pos, pos), Bool.and(D.nat_le(pos, Nat.add(pos, List.length(&2, U32, xs))), D.nat_le(Nat.add(pos, List.length(&2, U32, xs)), end)),
      CLeaf.nat_eq_refl(pos),
      V.and_true(D.nat_le(pos, Nat.add(pos, List.length(&2, U32, xs))), D.nat_le(Nat.add(pos, List.length(&2, U32, xs)), end),
        CLeaf.nat_le_true(pos, Nat.add(pos, List.length(&2, U32, xs)), NO.below_sum(pos, List.length(&2, U32, xs))),
        CLeaf.nat_le_true(Nat.add(pos, List.length(&2, U32, xs)), end, fits_end)))) : {D.Plan{D.region_if(_, Nat.sub(Nat.add(pos, List.length(&2, U32, xs)), pos), pay), False{}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, xs)), acc} == D.Plan{D.Region{List.length(&2, U32, xs), pay}, False{}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, xs)), acc} : D.Plan}
  %Equal.sym(Nat, Nat.sub(Nat.add(pos, List.length(&2, U32, xs)), pos), List.length(&2, U32, xs), add_sub_left(pos, List.length(&2, U32, xs))) : {D.Plan{D.Region{_, pay}, False{}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, xs)), acc} == D.Plan{D.Region{List.length(&2, U32, xs), pay}, False{}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, xs)), acc} : D.Plan}
  {==}

# The decoder's header width for a field forest is the specification's fixed
# region size of the parts those fields produce.
law no_header_here:
  for +fields: T.Schema
  for +empty: {FA.widths(fields) == [] : +List<Maybe<&2, Nat>>}
  {D.header_size(fields) == 0n : Nat}
def no_header_here(fields, empty):
  match fields:
    case T.Chain{s0, s1}: Empty.absurd({D.header_size(T.Chain{s0, s1}) == 0n : Nat}, F.false_true(Equal.sym(Bool, True{}, False{}, Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, FA.widths(T.Chain{s0, s1}), [], empty))))
    case T.Boolean{}: {==}
    case T.Unsigned{s0}: {==}
    case T.ByteVector{s0}: {==}
    case T.ByteList{s0}: {==}
    case T.BitVector{s0}: {==}
    case T.BitList{s0}: {==}
    case T.Vector{s0, s1}: {==}
    case T.ListOf{s0, s1}: {==}
    case T.Container{s0, s1}: {==}
    case T.Union{s0}: {==}
    case T.Null{}: {==}
    case T.End{}: {==}
    case T.Repeat{s0}: {==}
    case T.Named{s0, s1}: {==}
    case T.ProgressiveList{s0}: {==}
    case T.ProgressiveBits{}: {==}
    case T.ProgressiveContainer{s0, s1, s2}: {==}
    case T.CompatibleUnion{s0, s1}: {==}

law header_size_parts:
  for +ps: +List<T.Part>
  for +fields: T.Schema
  for +align: {HW.widths(ps) == FA.widths(fields) : +List<Maybe<&2, Nat>>}
  {D.header_size(fields) == SL.fixed_size(ps) : Nat}
def header_size_parts(ps, fields, align):
  match ps:
    case Nil{}: no_header_here(fields, Equal.sym(+List<Maybe<&2, Nat>>, [], FA.widths(fields), align))
    case Con{T.Fixed{xs}, t}:
      chain_elim({D.header_size(fields) == SL.fixed_size(T.Fixed{xs} <> t) : Nat}, fields, Some{List.length(&2, U32, xs)}, HW.widths(t),
        Equal.sym(+List<Maybe<&2, Nat>>, HW.widths(T.Fixed{xs} <> t), FA.widths(fields), align),
        h => tl => fieldseq => weq => wseq =>
          %Equal.sym(T.Schema, fields, T.Chain{h, tl}, fieldseq) : {D.header_size(_) == SL.fixed_size(T.Fixed{xs} <> t) : Nat}
          %Equal.sym(Maybe<&2, Nat>, IS.fixed_size(h), Some{List.length(&2, U32, xs)}, Equal.trans(Maybe<&2, Nat>, IS.fixed_size(h), SS.fixed_size(h), Some{List.length(&2, U32, xs)}, Sch.fixed_size_correct(h), weq)) : {Nat.add(IL.slot(_), D.header_size(tl)) == SL.fixed_size(T.Fixed{xs} <> t) : Nat}
          Equal.cong(Nat, Nat, k => Nat.add(List.length(&2, U32, xs), k), D.header_size(tl), SL.fixed_size(t),
            header_size_parts(t, tl, Equal.sym(+List<Maybe<&2, Nat>>, FA.widths(tl), HW.widths(t), wseq))))
    case Con{T.Variable{xs}, t}:
      chain_elim({D.header_size(fields) == SL.fixed_size(T.Variable{xs} <> t) : Nat}, fields, None{}, HW.widths(t),
        Equal.sym(+List<Maybe<&2, Nat>>, HW.widths(T.Variable{xs} <> t), FA.widths(fields), align),
        h => tl => fieldseq => weq => wseq =>
          %Equal.sym(T.Schema, fields, T.Chain{h, tl}, fieldseq) : {D.header_size(_) == SL.fixed_size(T.Variable{xs} <> t) : Nat}
          %Equal.sym(Maybe<&2, Nat>, IS.fixed_size(h), None{}, Equal.trans(Maybe<&2, Nat>, IS.fixed_size(h), SS.fixed_size(h), None{}, Sch.fixed_size_correct(h), weq)) : {Nat.add(IL.slot(_), D.header_size(tl)) == SL.fixed_size(T.Variable{xs} <> t) : Nat}
          Equal.cong(Nat, Nat, k => Nat.add(4n, k), D.header_size(tl), SL.fixed_size(t),
            header_size_parts(t, tl, Equal.sym(+List<Maybe<&2, Nat>>, FA.widths(tl), HW.widths(t), wseq))))

# A completed walk wrapped as a sequence value.
law wrap_complete:
  for out: D.Out
  for +sl: P.Slice
  for +end: Nat
  for +items: T.Value
  for r: walk_result(sl, end, items, out)
  CLeaf.parsed_as(T.Sequence{items}, sl, end, D.wrap_sequence(out))
def wrap_complete(out, sl, end, items, r):
  match out:
    case D.Parsed{v, rest}:
      (a, bc) = r
      (b, c) = bc
      (Equal.cong(T.Value, T.Value, x => T.Sequence{x}, C.to_value(v), items, a), (b, c))
    case D.Refused{}: Empty.absurd(CLeaf.parsed_as(T.Sequence{items}, sl, end, D.wrap_sequence(D.Refused{})), r)
    case D.Begin{x}: Empty.absurd(CLeaf.parsed_as(T.Sequence{items}, sl, end, D.wrap_sequence(D.Begin{x})), r)

# The layout of a parts list, as the specification's encoding of a region.
law encoding_layout:
  for +ps: +List<T.Part>
  for +bytes: +List<U32>
  for +encoded: {SL.encoding(ps) == Some{bytes} : Maybe<&2, +List<U32>>}
  {List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)) == bytes : +List<U32>}
def encoding_layout(ps, bytes, encoded):
  CLeaf.facts_bytes(Bool.and(SL.bytes_valid(ps), N.fits(4n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))))),
    List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)), bytes,
    CLeaf.optional_some(Bool.and(SL.bytes_valid(ps), N.fits(4n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))))),
      List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)), bytes, encoded))

law encoding_fits:
  for +ps: +List<T.Part>
  for +bytes: +List<U32>
  for +encoded: {SL.encoding(ps) == Some{bytes} : Maybe<&2, +List<U32>>}
  {N.fits(4n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))) == True{} : Bool}
def encoding_fits(ps, bytes, encoded):
  V.and_right(SL.bytes_valid(ps), N.fits(4n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))),
    CLeaf.facts_dom(Bool.and(SL.bytes_valid(ps), N.fits(4n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))))),
      List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)), bytes,
      CLeaf.optional_some(Bool.and(SL.bytes_valid(ps), N.fits(4n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))))),
        List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)), bytes,
        encoded)))

# ---------------------------------------------------------------------------
# A container region: the layout walk starts at the region start with an empty
# accumulator, and the region's bytes are the layout of the whole field forest.
law layout_length_parts:
  for +ps: +List<T.Part>
  {List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))) == Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))) : Nat}
def layout_length_parts(ps):
  Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))), Nat.add(List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), List.length(&2, U32, SL.payloads(ps))), Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))),
    L.append_length(U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)),
    Equal.cong(Nat, Nat, k => Nat.add(k, List.length(&2, U32, SL.payloads(ps))), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), SL.fixed_size(ps), LA.fixed_parts_length(ps, SL.fixed_size(ps))))

law region_prefix:
  for +bytes: +List<U32>
  for +ps: +List<T.Part>
  for +n: Nat
  for +room: {Nat.is_le(n, List.length(&2, U32, bytes)) == True{} : Bool}
  for +layout: {List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)) == List.take(&2, U32, bytes, n) : +List<U32>}
  {Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))) == n : Nat}
def region_prefix(bytes, ps, n, room, layout):
  Equal.trans(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))), n,
    Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))), Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))),
      Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))), Nat.add(List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), List.length(&2, U32, SL.payloads(ps))), Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))),
        L.append_length(U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)),
        Equal.cong(Nat, Nat, k => Nat.add(k, List.length(&2, U32, SL.payloads(ps))), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), SL.fixed_size(ps), LA.fixed_parts_length(ps, SL.fixed_size(ps))))),
    Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))), List.length(&2, U32, List.take(&2, U32, bytes, n)), n,
      Equal.cong(+List<U32>, Nat, ys => List.length(&2, U32, ys), List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)), List.take(&2, U32, bytes, n), layout),
      PK.take_length(bytes, n, room)))

law container_complete:
  for +names: +List<String>
  for +fields: T.Schema
  for +items: T.Value
  for +ps: +List<T.Part>
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +partsof: {SC.parts(items, fields) == Some{ps} : Maybe<&2, +List<T.Part>>}
  for +align: {HW.widths(ps) == FA.widths(fields) : +List<Maybe<&2, Nat>>}
  for +encoded: {SL.encoding(ps) == Some{List.take(&2, U32, P.slice_bytes(xs), n)} : Maybe<&2, +List<U32>>}
  for walk: walk_goal(xs, n, SL.fixed_size(ps), 0n, SL.fixed_size(ps), [], ps, fields, xs, P.adv(xs, SL.fixed_size(ps)), C.CEnd{}, items, D.go(fields, 0n, 0n, D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(ps)), SL.fixed_size(ps), n, C.CEnd{}}))
  CLeaf.parsed_as(T.Sequence{items}, xs, n, D.go(T.Container{names, fields}, 1n, 0n, D.Region{n, xs}))
def container_complete(names, fields, items, ps, n, xs, wf, room, partsof, align, encoded, walk):
  +layout = encoding_layout(ps, List.take(&2, U32, P.slice_bytes(xs), n), encoded)
  +lenn = region_prefix(P.slice_bytes(xs), ps, n, CL.sized_by_wf(xs, n, wf, room), layout)
  +fitsn = Equal.trans(Bool, N.fits(4n, n), N.fits(4n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))), True{},
    Equal.cong(Nat, Bool, k => N.fits(4n, k), n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), Equal.sym(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n, lenn)),
    encoding_fits(ps, List.take(&2, U32, P.slice_bytes(xs), n), encoded))
  +fits4 = Equal.trans(Bool, D.fits(n), N.fits(4n, n), True{}, CL.fits_bridge(n), fitsn)
  +hs = header_size_parts(ps, fields, align)
  +headle = CLeaf.nat_le_true(SL.fixed_size(ps), n,
    Equal.trans(Bool, Nat.is_le(SL.fixed_size(ps), n), Nat.is_le(SL.fixed_size(ps), Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))), True{},
      Equal.cong(Nat, Bool, k => Nat.is_le(SL.fixed_size(ps), k), n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), Equal.sym(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n, lenn)),
      NO.below_sum(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))))
  +pre = Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(xs), List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)))), List.take(&2, U32, P.slice_bytes(xs), n), List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)),
    Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))), n,
      Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))), Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n,
        layout_length_parts(ps), lenn)),
    Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(xs), n), List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)), List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)),
      Equal.sym(+List<U32>, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)), List.take(&2, U32, P.slice_bytes(xs), n), layout), {==}))
  +headerstart = Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), 0n), Nat.sub(SL.fixed_size(ps), 0n)), List.take(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), SL.fixed_parts(ps, SL.fixed_size(ps)),
    Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), 0n), Nat.sub(SL.fixed_size(ps), 0n)), List.take(&2, U32, P.slice_bytes(xs), Nat.sub(SL.fixed_size(ps), 0n)), List.take(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)),
      Equal.cong(+List<U32>, +List<U32>, ys => List.take(&2, U32, ys, Nat.sub(SL.fixed_size(ps), 0n)), List.drop(&2, U32, P.slice_bytes(xs), 0n), P.slice_bytes(xs), PK.drop_zero(P.slice_bytes(xs))),
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), Nat.sub(SL.fixed_size(ps), 0n), SL.fixed_size(ps), PK.sub_zero(SL.fixed_size(ps)))),
    Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), List.take(&2, U32, P.slice_bytes(xs), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)))), SL.fixed_parts(ps, SL.fixed_size(ps)),
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), SL.fixed_size(ps), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), Equal.sym(Nat, List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), SL.fixed_size(ps), LA.fixed_parts_length(ps, SL.fixed_size(ps)))),
      starts_head(P.slice_bytes(xs), SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps), pre)))
  +payloadstart = Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), Nat.sub(n, SL.fixed_size(ps))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)))), List.length(&2, U32, SL.payloads(ps))), SL.payloads(ps),
    Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), Nat.sub(n, SL.fixed_size(ps))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), List.length(&2, U32, SL.payloads(ps))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)))), List.length(&2, U32, SL.payloads(ps))),
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), k), Nat.sub(n, SL.fixed_size(ps)), List.length(&2, U32, SL.payloads(ps)),
        Equal.trans(Nat, Nat.sub(n, SL.fixed_size(ps)), Nat.sub(Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), SL.fixed_size(ps)), List.length(&2, U32, SL.payloads(ps)),
          Equal.cong(Nat, Nat, k => Nat.sub(k, SL.fixed_size(ps)), n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), Equal.sym(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n, lenn)),
          add_sub_left(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))))),
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), k), List.length(&2, U32, SL.payloads(ps))), SL.fixed_size(ps), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), Equal.sym(Nat, List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), SL.fixed_size(ps), LA.fixed_parts_length(ps, SL.fixed_size(ps))))),
    starts_tail(P.slice_bytes(xs), SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps), pre))
  %Equal.sym(Bool, Bool.and(D.fits(n), D.nat_le(D.header_size(fields), n)), True{},
    V.and_true(D.fits(n), D.nat_le(D.header_size(fields), n), fits4,
      Equal.trans(Bool, D.nat_le(D.header_size(fields), n), D.nat_le(SL.fixed_size(ps), n), True{},
        Equal.cong(Nat, Bool, k => D.nat_le(k, n), D.header_size(fields), SL.fixed_size(ps), hs),
        headle))) : CLeaf.parsed_as(T.Sequence{items}, xs, n, D.wrap_sequence(D.go(fields, 0n, 0n, D.layout(_, D.header_size(fields), n, xs))))
  %Equal.sym(Nat, D.header_size(fields), SL.fixed_size(ps), hs) : CLeaf.parsed_as(T.Sequence{items}, xs, n, D.wrap_sequence(D.go(fields, 0n, 0n, D.layout(True{}, _, n, xs))))
  wrap_complete(D.go(fields, 0n, 0n, D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(ps)), SL.fixed_size(ps), n, C.CEnd{}}), xs, n, items,
    walk(wf, room, fitsn,
      Equal.sym(+List<U32>, List.drop(&2, U32, P.slice_bytes(xs), 0n), P.slice_bytes(xs), PK.drop_zero(P.slice_bytes(xs))),
      wf,
      PK.adv_view(xs, SL.fixed_size(ps)),
      PK.wf_adv(xs, SL.fixed_size(ps), wf),
      {==},
      {==},
      PKG.add_zero(SL.fixed_size(ps)),
      lenn,
      headerstart,
      payloadstart,
      lenn,
      partsof))

law progressive_container_complete:
  for +names: +List<String>
  for +fields: T.Schema
  for +active: +List<Bool>
  for +items: T.Value
  for +ps: +List<T.Part>
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +partsof: {SC.parts(items, fields) == Some{ps} : Maybe<&2, +List<T.Part>>}
  for +align: {HW.widths(ps) == FA.widths(fields) : +List<Maybe<&2, Nat>>}
  for +encoded: {SL.encoding(ps) == Some{List.take(&2, U32, P.slice_bytes(xs), n)} : Maybe<&2, +List<U32>>}
  for walk: walk_goal(xs, n, SL.fixed_size(ps), 0n, SL.fixed_size(ps), [], ps, fields, xs, P.adv(xs, SL.fixed_size(ps)), C.CEnd{}, items, D.go(fields, 0n, 0n, D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(ps)), SL.fixed_size(ps), n, C.CEnd{}}))
  CLeaf.parsed_as(T.Sequence{items}, xs, n, D.go(T.ProgressiveContainer{names, fields, active}, 1n, 0n, D.Region{n, xs}))
def progressive_container_complete(names, fields, active, items, ps, n, xs, wf, room, partsof, align, encoded, walk):
  +layout = encoding_layout(ps, List.take(&2, U32, P.slice_bytes(xs), n), encoded)
  +lenn = region_prefix(P.slice_bytes(xs), ps, n, CL.sized_by_wf(xs, n, wf, room), layout)
  +fitsn = Equal.trans(Bool, N.fits(4n, n), N.fits(4n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))), True{},
    Equal.cong(Nat, Bool, k => N.fits(4n, k), n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), Equal.sym(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n, lenn)),
    encoding_fits(ps, List.take(&2, U32, P.slice_bytes(xs), n), encoded))
  +fits4 = Equal.trans(Bool, D.fits(n), N.fits(4n, n), True{}, CL.fits_bridge(n), fitsn)
  +hs = header_size_parts(ps, fields, align)
  +headle = CLeaf.nat_le_true(SL.fixed_size(ps), n,
    Equal.trans(Bool, Nat.is_le(SL.fixed_size(ps), n), Nat.is_le(SL.fixed_size(ps), Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))), True{},
      Equal.cong(Nat, Bool, k => Nat.is_le(SL.fixed_size(ps), k), n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), Equal.sym(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n, lenn)),
      NO.below_sum(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))))
  +pre = Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(xs), List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)))), List.take(&2, U32, P.slice_bytes(xs), n), List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)),
    Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))), n,
      Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))), Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n,
        layout_length_parts(ps), lenn)),
    Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(xs), n), List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)), List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)),
      Equal.sym(+List<U32>, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)), List.take(&2, U32, P.slice_bytes(xs), n), layout), {==}))
  +headerstart = Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), 0n), Nat.sub(SL.fixed_size(ps), 0n)), List.take(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), SL.fixed_parts(ps, SL.fixed_size(ps)),
    Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), 0n), Nat.sub(SL.fixed_size(ps), 0n)), List.take(&2, U32, P.slice_bytes(xs), Nat.sub(SL.fixed_size(ps), 0n)), List.take(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)),
      Equal.cong(+List<U32>, +List<U32>, ys => List.take(&2, U32, ys, Nat.sub(SL.fixed_size(ps), 0n)), List.drop(&2, U32, P.slice_bytes(xs), 0n), P.slice_bytes(xs), PK.drop_zero(P.slice_bytes(xs))),
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), Nat.sub(SL.fixed_size(ps), 0n), SL.fixed_size(ps), PK.sub_zero(SL.fixed_size(ps)))),
    Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), List.take(&2, U32, P.slice_bytes(xs), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)))), SL.fixed_parts(ps, SL.fixed_size(ps)),
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), SL.fixed_size(ps), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), Equal.sym(Nat, List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), SL.fixed_size(ps), LA.fixed_parts_length(ps, SL.fixed_size(ps)))),
      starts_head(P.slice_bytes(xs), SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps), pre)))
  +payloadstart = Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), Nat.sub(n, SL.fixed_size(ps))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)))), List.length(&2, U32, SL.payloads(ps))), SL.payloads(ps),
    Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), Nat.sub(n, SL.fixed_size(ps))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), List.length(&2, U32, SL.payloads(ps))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)))), List.length(&2, U32, SL.payloads(ps))),
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), k), Nat.sub(n, SL.fixed_size(ps)), List.length(&2, U32, SL.payloads(ps)),
        Equal.trans(Nat, Nat.sub(n, SL.fixed_size(ps)), Nat.sub(Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), SL.fixed_size(ps)), List.length(&2, U32, SL.payloads(ps)),
          Equal.cong(Nat, Nat, k => Nat.sub(k, SL.fixed_size(ps)), n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), Equal.sym(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n, lenn)),
          add_sub_left(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))))),
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), k), List.length(&2, U32, SL.payloads(ps))), SL.fixed_size(ps), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), Equal.sym(Nat, List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), SL.fixed_size(ps), LA.fixed_parts_length(ps, SL.fixed_size(ps))))),
    starts_tail(P.slice_bytes(xs), SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps), pre))
  %Equal.sym(Bool, Bool.and(D.fits(n), D.nat_le(D.header_size(fields), n)), True{},
    V.and_true(D.fits(n), D.nat_le(D.header_size(fields), n), fits4,
      Equal.trans(Bool, D.nat_le(D.header_size(fields), n), D.nat_le(SL.fixed_size(ps), n), True{},
        Equal.cong(Nat, Bool, k => D.nat_le(k, n), D.header_size(fields), SL.fixed_size(ps), hs),
        headle))) : CLeaf.parsed_as(T.Sequence{items}, xs, n, D.wrap_sequence(D.go(fields, 0n, 0n, D.layout(_, D.header_size(fields), n, xs))))
  %Equal.sym(Nat, D.header_size(fields), SL.fixed_size(ps), hs) : CLeaf.parsed_as(T.Sequence{items}, xs, n, D.wrap_sequence(D.go(fields, 0n, 0n, D.layout(True{}, _, n, xs))))
  wrap_complete(D.go(fields, 0n, 0n, D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(ps)), SL.fixed_size(ps), n, C.CEnd{}}), xs, n, items,
    walk(wf, room, fitsn,
      Equal.sym(+List<U32>, List.drop(&2, U32, P.slice_bytes(xs), 0n), P.slice_bytes(xs), PK.drop_zero(P.slice_bytes(xs))),
      wf,
      PK.adv_view(xs, SL.fixed_size(ps)),
      PK.wf_adv(xs, SL.fixed_size(ps), wf),
      {==},
      {==},
      PKG.add_zero(SL.fixed_size(ps)),
      lenn,
      headerstart,
      payloadstart,
      lenn,
      partsof))

# ---------------------------------------------------------------------------
# The same walk over a sequence: the decoder carries the remaining element
# count instead of the remaining field forest, and the parts come from the
# specification's `Repeat` schema.
def walk_goal_seq(e: T.Schema, k: Nat, sl: P.Slice, end: Nat, fixedtotal: Nat, h: Nat, pos: Nat,
                  pdone: +List<T.Part>, ps: +List<T.Part>, hdr: P.Slice, pay: P.Slice,
                  acc: C.CValue, rest: T.Value, out: D.Out) -> Type:
  @+wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat} ->
  @+roomsl: {Nat.is_le(end, P.slice_size(sl)) == True{} : Bool} ->
  @+fitend: {N.fits(4n, end) == True{} : Bool} ->
  @+hdrview: {P.slice_bytes(hdr) == List.drop(&2, U32, P.slice_bytes(sl), h) : +List<U32>} ->
  @+wfhdr: {List.length(&2, U32, P.slice_bytes(hdr)) == P.slice_size(hdr) : Nat} ->
  @+payview: {P.slice_bytes(pay) == List.drop(&2, U32, P.slice_bytes(sl), pos) : +List<U32>} ->
  @+wfpay: {List.length(&2, U32, P.slice_bytes(pay)) == P.slice_size(pay) : Nat} ->
  @+sizedone: {SL.fixed_size(pdone) == h : Nat} ->
  @+remaining: {Nat.add(h, SL.fixed_size(ps)) == fixedtotal : Nat} ->
  @+position: {Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))) == pos : Nat} ->
  @+regionsize: {Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, pdone, ps)))) == end : Nat} ->
  @+headerrest: {List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(fixedtotal, h)) == SL.fixed_parts(ps, pos) : +List<U32>} ->
  @+payloadrest: {List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), pos), Nat.sub(end, pos)) == SL.payloads(ps) : +List<U32>} ->
  @+payloadend: {Nat.add(pos, List.length(&2, U32, SL.payloads(ps))) == end : Nat} ->
  @+restparts: {SC.parts(rest, T.Repeat{e}) == Some{ps} : Maybe<&2, +List<T.Part>>} ->
  @+countok: {SC.count(rest) == k : Nat} ->
  walk_result(sl, end, app_items(reading(acc), rest), out)

law close_seq_complete:
  for +e: T.Schema
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +ps: +List<T.Part>
  for +hdr: P.Slice
  for +pay: P.Slice
  for +acc: C.CValue
  for +rest: T.Value
  walk_goal_seq(e, 0n, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc, rest, D.close(D.Settled{hdr, pay, acc}, pos, end))
def close_seq_complete(e, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc, rest):
  match rest:
    case T.EmptyItems{}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
        +empty = Equal.cong(Maybe<&2, +List<T.Part>>, +List<T.Part>, parts_list, Some{[]}, Some{ps}, restparts)
        +posend = Equal.trans(Nat, pos, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), end,
          Equal.sym(Nat, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), pos, position),
          Equal.trans(Nat, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, pdone, ps)))), end,
            Equal.cong(+List<T.Part>, Nat, qs => Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(qs))), pdone, List.append(&2, T.Part, pdone, ps),
              Equal.sym(+List<T.Part>, List.append(&2, T.Part, pdone, ps), pdone,
                Equal.trans(+List<T.Part>, List.append(&2, T.Part, pdone, ps), List.append(&2, T.Part, pdone, []), pdone,
                  Equal.cong(+List<T.Part>, +List<T.Part>, qs => List.append(&2, T.Part, pdone, qs), ps, [], Equal.sym(+List<T.Part>, [], ps, empty)),
                  L.append_empty(T.Part, pdone)))),
            regionsize))
        %Equal.sym(Bool, D.nat_eq(pos, end), True{}, CLeaf.nat_eq_true(pos, end, posend)) : walk_result(sl, end, app_items(reading(acc), T.EmptyItems{}), D.closed(_, acc, pay))
        (Equal.trans(T.Value, C.to_value(acc), reading(acc), app_items(reading(acc), T.EmptyItems{}),
           reading_is_value(acc),
           Equal.sym(T.Value, app_items(reading(acc), T.EmptyItems{}), reading(acc), app_empty_right(reading(acc)))),
         (Equal.trans(+List<U32>, P.slice_bytes(pay), List.drop(&2, U32, P.slice_bytes(sl), pos), List.drop(&2, U32, P.slice_bytes(sl), end),
            payview,
            Equal.cong(Nat, +List<U32>, k => List.drop(&2, U32, P.slice_bytes(sl), k), pos, end, posend)),
          wfpay))
    case T.Items{hv, tv}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
        Empty.absurd(walk_result(sl, end, app_items(reading(acc), T.Items{hv, tv}), D.close(D.Settled{hdr, pay, acc}, pos, end)), F.false_true(Equal.cong(Nat, Bool, k => Nat.is_eq(k, 0n), 1n+SC.count(tv), 0n, countok)))
    case T.BooleanValue{b}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
        Empty.absurd(walk_result(sl, end, app_items(reading(acc), T.BooleanValue{b}), D.close(D.Settled{hdr, pay, acc}, pos, end)), parts_some(SC.parts(T.BooleanValue{b}, T.Repeat{e}), ps, restparts))
    case T.UnsignedValue{v}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
        Empty.absurd(walk_result(sl, end, app_items(reading(acc), T.UnsignedValue{v}), D.close(D.Settled{hdr, pay, acc}, pos, end)), parts_some(SC.parts(T.UnsignedValue{v}, T.Repeat{e}), ps, restparts))
    case T.BytesValue{bs}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
        Empty.absurd(walk_result(sl, end, app_items(reading(acc), T.BytesValue{bs}), D.close(D.Settled{hdr, pay, acc}, pos, end)), parts_some(SC.parts(T.BytesValue{bs}, T.Repeat{e}), ps, restparts))
    case T.BitsValue{bs}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
        Empty.absurd(walk_result(sl, end, app_items(reading(acc), T.BitsValue{bs}), D.close(D.Settled{hdr, pay, acc}, pos, end)), parts_some(SC.parts(T.BitsValue{bs}, T.Repeat{e}), ps, restparts))
    case T.Sequence{items}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
        Empty.absurd(walk_result(sl, end, app_items(reading(acc), T.Sequence{items}), D.close(D.Settled{hdr, pay, acc}, pos, end)), parts_some(SC.parts(T.Sequence{items}, T.Repeat{e}), ps, restparts))
    case T.Selected{s, v}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
        Empty.absurd(walk_result(sl, end, app_items(reading(acc), T.Selected{s, v}), D.close(D.Settled{hdr, pay, acc}, pos, end)), parts_some(SC.parts(T.Selected{s, v}, T.Repeat{e}), ps, restparts))
    case T.NullValue{}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
        Empty.absurd(walk_result(sl, end, app_items(reading(acc), T.NullValue{}), D.close(D.Settled{hdr, pay, acc}, pos, end)), parts_some(SC.parts(T.NullValue{}, T.Repeat{e}), ps, restparts))

# Eliminating a completed child: `parsed_as` already rules out refusal, and an
# `Out` can be matched only as a parameter, so this hands the components to a
# continuation.

law step_fixed_seq_complete:
  for +schema: T.Schema
  for +e: T.Schema
  for +p: Nat
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +w: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +ps: +List<T.Part>
  for +xs: +List<U32>
  for +hdr: P.Slice
  for +crest: P.Slice
  for +pay: P.Slice
  for +acc: C.CValue
  for +cv: C.CValue
  for +hv: T.Value
  for +tv: T.Value
  for +lenxs: {List.length(&2, U32, xs) == w : Nat}
  for +childvalue: {C.to_value(cv) == hv : T.Value}
  for +childrest: {P.slice_bytes(crest) == List.drop(&2, U32, P.slice_bytes(hdr), w) : +List<U32>}
  for +wfcrest: {List.length(&2, U32, P.slice_bytes(crest)) == P.slice_size(crest) : Nat}
  for +tailparts: {SC.parts(tv, T.Repeat{e}) == Some{ps} : Maybe<&2, +List<T.Part>>}
  for +tailcount: {SC.count(tv) == p : Nat}
  for rec: walk_goal_seq(e, p, sl, end, fixedtotal, Nat.add(h, w), pos, List.append(&2, T.Part, pdone, [T.Fixed{xs}]), ps, crest, pay, C.CCons{cv, acc}, tv, D.go(schema, 0n, p, D.Walk{True{}, D.Parsed{cv, crest}, pay, pos, end, acc}))
  walk_goal_seq(e, 1n+p, sl, end, fixedtotal, h, pos, pdone, T.Fixed{xs} <> ps, hdr, pay, acc, T.Items{hv, tv}, D.go(schema, 0n, p, D.Walk{True{}, D.Parsed{cv, crest}, pay, pos, end, acc}))
def step_fixed_seq_complete(schema, e, p, sl, end, fixedtotal, h, w, pos, pdone, ps, xs, hdr, crest, pay, acc, cv, hv, tv, lenxs, childvalue, childrest, wfcrest, tailparts, tailcount, rec):
  wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
    +valeq = Equal.trans(T.Value, app_items(reading(C.CCons{cv, acc}), tv), app_items(reading(acc), T.Items{C.to_value(cv), tv}), app_items(reading(acc), T.Items{hv, tv}),
      Equal.trans(T.Value, app_items(reading(C.CCons{cv, acc}), tv), app_items(app_items(reading(acc), T.Items{C.to_value(cv), T.EmptyItems{}}), tv), app_items(reading(acc), T.Items{C.to_value(cv), tv}),
        Equal.cong(T.Value, T.Value, x => app_items(x, tv), reading(C.CCons{cv, acc}), app_items(reading(acc), T.Items{C.to_value(cv), T.EmptyItems{}}), reading_step(acc, cv)),
        app_assoc(reading(acc), T.Items{C.to_value(cv), T.EmptyItems{}}, tv)),
      Equal.cong(T.Value, T.Value, x => app_items(reading(acc), T.Items{x, tv}), C.to_value(cv), hv, childvalue))
    +widthsum = Equal.trans(Nat, Nat.add(h, Nat.add(w, SL.fixed_size(ps))), Nat.add(h, Nat.add(List.length(&2, U32, xs), SL.fixed_size(ps))), fixedtotal,
      Equal.cong(Nat, Nat, k => Nat.add(h, Nat.add(k, SL.fixed_size(ps))), w, List.length(&2, U32, xs), Equal.sym(Nat, List.length(&2, U32, xs), w, lenxs)),
      remaining)
    %valeq : walk_result(sl, end, _, D.go(schema, 0n, p, D.Walk{True{}, D.Parsed{cv, crest}, pay, pos, end, acc}))
    rec(wfsl, roomsl, fitend,
      Equal.trans(+List<U32>, P.slice_bytes(crest), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), w), List.drop(&2, U32, P.slice_bytes(sl), Nat.add(h, w)),
        Equal.trans(+List<U32>, P.slice_bytes(crest), List.drop(&2, U32, P.slice_bytes(hdr), w), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), w),
          childrest,
          Equal.cong(+List<U32>, +List<U32>, ys => List.drop(&2, U32, ys, w), P.slice_bytes(hdr), List.drop(&2, U32, P.slice_bytes(sl), h), hdrview)),
        W.drop_drop(P.slice_bytes(sl), h, w)),
      wfcrest,
      payview,
      wfpay,
      CW.fixed_size_snoc(pdone, xs, h, w, sizedone, lenxs),
      CW.remaining_fixed(h, w, SL.fixed_size(ps), fixedtotal, widthsum),
      Equal.trans(Nat, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, pdone, [T.Fixed{xs}])))), Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), pos,
        Equal.cong(+List<U32>, Nat, ys => Nat.add(fixedtotal, List.length(&2, U32, ys)), SL.payloads(List.append(&2, T.Part, pdone, [T.Fixed{xs}])), SL.payloads(pdone), CW.payloads_snoc_fixed(pdone, xs)),
        position),
      Equal.trans(Nat, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, List.append(&2, T.Part, pdone, [T.Fixed{xs}]), ps)))), Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, pdone, T.Fixed{xs} <> ps)))), end,
        Equal.cong(+List<T.Part>, Nat, qs => Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(qs))), List.append(&2, T.Part, List.append(&2, T.Part, pdone, [T.Fixed{xs}]), ps), List.append(&2, T.Part, pdone, T.Fixed{xs} <> ps),
          L.append_associative(T.Part, pdone, [T.Fixed{xs}], ps)),
        regionsize),
      header_advance(sl, h, w, fixedtotal, xs, SL.fixed_parts(ps, pos), lenxs, NO.below_sum(h, w), headerrest),
      payloadrest,
      payloadend,
      tailparts,
      tailcount)

# ---------------------------------------------------------------------------
# Reading a variable field's offset back out of the header: the four header
# bytes at the cursor are the canonical digits of the payload position, and
# little-endian digits are read back as exactly that position.

law step_variable_seq_complete:
  for +schema: T.Schema
  for +e: T.Schema
  for +p: Nat
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +ps: +List<T.Part>
  for +xs: +List<U32>
  for +hdr: P.Slice
  for +crest: P.Slice
  for +pay: P.Slice
  for +acc: C.CValue
  for +cv: C.CValue
  for +hv: T.Value
  for +tv: T.Value
  for +childvalue: {C.to_value(cv) == hv : T.Value}
  for +childrest: {P.slice_bytes(crest) == List.drop(&2, U32, P.slice_bytes(pay), List.length(&2, U32, xs)) : +List<U32>}
  for +wfcrest: {List.length(&2, U32, P.slice_bytes(crest)) == P.slice_size(crest) : Nat}
  for +tailparts: {SC.parts(tv, T.Repeat{e}) == Some{ps} : Maybe<&2, +List<T.Part>>}
  for +tailcount: {SC.count(tv) == p : Nat}
  for rec: walk_goal_seq(e, p, sl, end, fixedtotal, Nat.add(h, 4n), Nat.add(pos, List.length(&2, U32, xs)), List.append(&2, T.Part, pdone, [T.Variable{xs}]), ps, P.adv(hdr, 4n), crest, C.CCons{cv, acc}, tv, D.go(schema, 0n, p, D.Walk{False{}, D.Parsed{cv, crest}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, xs)), end, acc}))
  walk_goal_seq(e, 1n+p, sl, end, fixedtotal, h, pos, pdone, T.Variable{xs} <> ps, hdr, pay, acc, T.Items{hv, tv}, D.go(schema, 0n, p, D.Walk{False{}, D.Parsed{cv, crest}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, xs)), end, acc}))
def step_variable_seq_complete(schema, e, p, sl, end, fixedtotal, h, pos, pdone, ps, xs, hdr, crest, pay, acc, cv, hv, tv, childvalue, childrest, wfcrest, tailparts, tailcount, rec):
  wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
    +valeq = Equal.trans(T.Value, app_items(reading(C.CCons{cv, acc}), tv), app_items(reading(acc), T.Items{C.to_value(cv), tv}), app_items(reading(acc), T.Items{hv, tv}),
      Equal.trans(T.Value, app_items(reading(C.CCons{cv, acc}), tv), app_items(app_items(reading(acc), T.Items{C.to_value(cv), T.EmptyItems{}}), tv), app_items(reading(acc), T.Items{C.to_value(cv), tv}),
        Equal.cong(T.Value, T.Value, x => app_items(x, tv), reading(C.CCons{cv, acc}), app_items(reading(acc), T.Items{C.to_value(cv), T.EmptyItems{}}), reading_step(acc, cv)),
        app_assoc(reading(acc), T.Items{C.to_value(cv), T.EmptyItems{}}, tv)),
      Equal.cong(T.Value, T.Value, x => app_items(reading(acc), T.Items{x, tv}), C.to_value(cv), hv, childvalue))
    %valeq : walk_result(sl, end, _, D.go(schema, 0n, p, D.Walk{False{}, D.Parsed{cv, crest}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, xs)), end, acc}))
    rec(wfsl, roomsl, fitend,
      Equal.trans(+List<U32>, P.slice_bytes(P.adv(hdr, 4n)), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), 4n), List.drop(&2, U32, P.slice_bytes(sl), Nat.add(h, 4n)),
        Equal.trans(+List<U32>, P.slice_bytes(P.adv(hdr, 4n)), List.drop(&2, U32, P.slice_bytes(hdr), 4n), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), 4n),
          PK.adv_view(hdr, 4n),
          Equal.cong(+List<U32>, +List<U32>, ys => List.drop(&2, U32, ys, 4n), P.slice_bytes(hdr), List.drop(&2, U32, P.slice_bytes(sl), h), hdrview)),
        W.drop_drop(P.slice_bytes(sl), h, 4n)),
      PK.wf_adv(hdr, 4n, wfhdr),
      Equal.trans(+List<U32>, P.slice_bytes(crest), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), pos), List.length(&2, U32, xs)), List.drop(&2, U32, P.slice_bytes(sl), Nat.add(pos, List.length(&2, U32, xs))),
        Equal.trans(+List<U32>, P.slice_bytes(crest), List.drop(&2, U32, P.slice_bytes(pay), List.length(&2, U32, xs)), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), pos), List.length(&2, U32, xs)),
          childrest,
          Equal.cong(+List<U32>, +List<U32>, ys => List.drop(&2, U32, ys, List.length(&2, U32, xs)), P.slice_bytes(pay), List.drop(&2, U32, P.slice_bytes(sl), pos), payview)),
        W.drop_drop(P.slice_bytes(sl), pos, List.length(&2, U32, xs))),
      wfcrest,
      CW.fixed_size_snoc_variable(pdone, xs, h, sizedone),
      CW.remaining_fixed(h, 4n, SL.fixed_size(ps), fixedtotal, remaining),
      Equal.trans(Nat, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, pdone, [T.Variable{xs}])))), Nat.add(Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), List.length(&2, U32, xs)), Nat.add(pos, List.length(&2, U32, xs)),
        Equal.trans(Nat, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, pdone, [T.Variable{xs}])))), Nat.add(fixedtotal, Nat.add(List.length(&2, U32, SL.payloads(pdone)), List.length(&2, U32, xs))), Nat.add(Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), List.length(&2, U32, xs)),
          Equal.cong(Nat, Nat, k => Nat.add(fixedtotal, k), List.length(&2, U32, SL.payloads(List.append(&2, T.Part, pdone, [T.Variable{xs}]))), Nat.add(List.length(&2, U32, SL.payloads(pdone)), List.length(&2, U32, xs)),
            Equal.trans(Nat, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, pdone, [T.Variable{xs}]))), List.length(&2, U32, List.append(&2, U32, SL.payloads(pdone), xs)), Nat.add(List.length(&2, U32, SL.payloads(pdone)), List.length(&2, U32, xs)),
              Equal.cong(+List<U32>, Nat, ys => List.length(&2, U32, ys), SL.payloads(List.append(&2, T.Part, pdone, [T.Variable{xs}])), List.append(&2, U32, SL.payloads(pdone), xs), CW.payloads_snoc_variable(pdone, xs)),
              L.append_length(U32, SL.payloads(pdone), xs))),
          Equal.sym(Nat, Nat.add(Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), List.length(&2, U32, xs)), Nat.add(fixedtotal, Nat.add(List.length(&2, U32, SL.payloads(pdone)), List.length(&2, U32, xs))), LA.add_associative(fixedtotal, List.length(&2, U32, SL.payloads(pdone)), List.length(&2, U32, xs)))),
        Equal.cong(Nat, Nat, k => Nat.add(k, List.length(&2, U32, xs)), Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), pos, position)),
      Equal.trans(Nat, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, List.append(&2, T.Part, pdone, [T.Variable{xs}]), ps)))), Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, pdone, T.Variable{xs} <> ps)))), end,
        Equal.cong(+List<T.Part>, Nat, qs => Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(qs))), List.append(&2, T.Part, List.append(&2, T.Part, pdone, [T.Variable{xs}]), ps), List.append(&2, T.Part, pdone, T.Variable{xs} <> ps),
          L.append_associative(T.Part, pdone, [T.Variable{xs}], ps)),
        regionsize),
      header_advance(sl, h, 4n, fixedtotal, N.digits(4n, pos), SL.fixed_parts(ps, Nat.add(pos, List.length(&2, U32, xs))), Digits.digits_length(4n, pos), NO.below_sum(h, 4n), headerrest),
      header_advance(sl, pos, List.length(&2, U32, xs), end, xs, SL.payloads(ps), {==}, NO.below_sum(pos, List.length(&2, U32, xs)), payloadrest),
      Equal.trans(Nat, Nat.add(Nat.add(pos, List.length(&2, U32, xs)), List.length(&2, U32, SL.payloads(ps))), Nat.add(pos, Nat.add(List.length(&2, U32, xs), List.length(&2, U32, SL.payloads(ps)))), end,
        LA.add_associative(pos, List.length(&2, U32, xs), List.length(&2, U32, SL.payloads(ps))),
        Equal.trans(Nat, Nat.add(pos, Nat.add(List.length(&2, U32, xs), List.length(&2, U32, SL.payloads(ps)))), Nat.add(pos, List.length(&2, U32, SL.payloads(T.Variable{xs} <> ps))), end,
          Equal.cong(Nat, Nat, k => Nat.add(pos, k), Nat.add(List.length(&2, U32, xs), List.length(&2, U32, SL.payloads(ps))), List.length(&2, U32, SL.payloads(T.Variable{xs} <> ps)),
            Equal.sym(Nat, List.length(&2, U32, SL.payloads(T.Variable{xs} <> ps)), Nat.add(List.length(&2, U32, xs), List.length(&2, U32, SL.payloads(ps))), L.append_length(U32, xs, SL.payloads(ps)))),
          payloadend)),
      tailparts,
      tailcount)


# A sequence region's header is one slot per element: the parts of a `Repeat`
# value have uniform width, so their fixed region is exactly `count` slots.
law seq_header_size:
  for +m: Nat
  for +ps: +List<T.Part>
  for +w: Maybe<&2, Nat>
  for +align: {HW.widths(ps) == List.replicate(Maybe<&2, Nat>, m, w) : +List<Maybe<&2, Nat>>}
  {Nat.mul(IL.slot(w), m) == SL.fixed_size(ps) : Nat}
def seq_header_size(m, ps, w, align):
  match m:
    case 0n:
      match ps:
        case Nil{}: NA.mul_zero(IL.slot(w))
        case Con{T.Fixed{xs}, t}:
          Empty.absurd({Nat.mul(IL.slot(w), 0n) == SL.fixed_size(T.Fixed{xs} <> t) : Nat},
            F.false_true(Equal.sym(Bool, True{}, False{},
              Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, HW.widths(T.Fixed{xs} <> t), List.replicate(Maybe<&2, Nat>, 0n, w), align))))
        case Con{T.Variable{xs}, t}:
          Empty.absurd({Nat.mul(IL.slot(w), 0n) == SL.fixed_size(T.Variable{xs} <> t) : Nat},
            F.false_true(Equal.sym(Bool, True{}, False{},
              Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, HW.widths(T.Variable{xs} <> t), List.replicate(Maybe<&2, Nat>, 0n, w), align))))
    case 1n+p:
      match ps:
        case Nil{}:
          Empty.absurd({Nat.mul(IL.slot(w), 1n+p) == SL.fixed_size([]) : Nat},
            F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, HW.widths([]), List.replicate(Maybe<&2, Nat>, 1n+p, w), align)))
        case Con{T.Fixed{xs}, t}:
          +slotw = Equal.cong(Maybe<&2, Nat>, Nat, u => IL.slot(u), w, Some{List.length(&2, U32, xs)},
            Equal.sym(Maybe<&2, Nat>, Some{List.length(&2, U32, xs)}, w,
              Equal.cong(+List<Maybe<&2, Nat>>, Maybe<&2, Nat>, head_w, HW.widths(T.Fixed{xs} <> t), List.replicate(Maybe<&2, Nat>, 1n+p, w), align)))
          Equal.trans(Nat, Nat.mul(IL.slot(w), 1n+p), Nat.add(IL.slot(w), Nat.mul(IL.slot(w), p)), Nat.add(List.length(&2, U32, xs), SL.fixed_size(t)),
            NA.mul_succ_right(IL.slot(w), p),
            Equal.trans(Nat, Nat.add(IL.slot(w), Nat.mul(IL.slot(w), p)), Nat.add(List.length(&2, U32, xs), Nat.mul(IL.slot(w), p)), Nat.add(List.length(&2, U32, xs), SL.fixed_size(t)),
              Equal.cong(Nat, Nat, k => Nat.add(k, Nat.mul(IL.slot(w), p)), IL.slot(w), List.length(&2, U32, xs), slotw),
              Equal.cong(Nat, Nat, k => Nat.add(List.length(&2, U32, xs), k), Nat.mul(IL.slot(w), p), SL.fixed_size(t),
                seq_header_size(p, t, w,
                  Equal.cong(+List<Maybe<&2, Nat>>, +List<Maybe<&2, Nat>>, tail_w, HW.widths(T.Fixed{xs} <> t), List.replicate(Maybe<&2, Nat>, 1n+p, w), align)))))
        case Con{T.Variable{xs}, t}:
          +slotw = Equal.cong(Maybe<&2, Nat>, Nat, u => IL.slot(u), w, None{},
            Equal.sym(Maybe<&2, Nat>, None{}, w,
              Equal.cong(+List<Maybe<&2, Nat>>, Maybe<&2, Nat>, head_w, HW.widths(T.Variable{xs} <> t), List.replicate(Maybe<&2, Nat>, 1n+p, w), align)))
          Equal.trans(Nat, Nat.mul(IL.slot(w), 1n+p), Nat.add(IL.slot(w), Nat.mul(IL.slot(w), p)), Nat.add(4n, SL.fixed_size(t)),
            NA.mul_succ_right(IL.slot(w), p),
            Equal.trans(Nat, Nat.add(IL.slot(w), Nat.mul(IL.slot(w), p)), Nat.add(4n, Nat.mul(IL.slot(w), p)), Nat.add(4n, SL.fixed_size(t)),
              Equal.cong(Nat, Nat, k => Nat.add(k, Nat.mul(IL.slot(w), p)), IL.slot(w), 4n, slotw),
              Equal.cong(Nat, Nat, k => Nat.add(4n, k), Nat.mul(IL.slot(w), p), SL.fixed_size(t),
                seq_header_size(p, t, w,
                  Equal.cong(+List<Maybe<&2, Nat>>, +List<Maybe<&2, Nat>>, tail_w, HW.widths(T.Variable{xs} <> t), List.replicate(Maybe<&2, Nat>, 1n+p, w), align)))))

# A vector region: the count is the schema's, the header is one slot per
# element, and the walk reads the elements in order.
law vector_complete:
  for +e: T.Schema
  for +m: Nat
  for +items: T.Value
  for +ps: +List<T.Part>
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +partsof: {SC.parts(items, T.Repeat{e}) == Some{ps} : Maybe<&2, +List<T.Part>>}
  for +counted: {SC.count(items) == m : Nat}
  for +positive: {Nat.is_lt(0n, m) == True{} : Bool}
  for +align: {HW.widths(ps) == List.replicate(Maybe<&2, Nat>, m, SS.fixed_size(e)) : +List<Maybe<&2, Nat>>}
  for +encoded: {SL.encoding(ps) == Some{List.take(&2, U32, P.slice_bytes(xs), n)} : Maybe<&2, +List<U32>>}
  for walk: walk_goal_seq(e, m, xs, n, SL.fixed_size(ps), 0n, SL.fixed_size(ps), [], ps, xs, P.adv(xs, SL.fixed_size(ps)), C.CEnd{}, items, D.go(T.Vector{e, m}, 0n, m, D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(ps)), SL.fixed_size(ps), n, C.CEnd{}}))
  CLeaf.parsed_as(T.Sequence{items}, xs, n, D.go(T.Vector{e, m}, 1n, 0n, D.Region{n, xs}))
def vector_complete(e, m, items, ps, n, xs, wf, room, partsof, counted, positive, align, encoded, walk):
  +layout = encoding_layout(ps, List.take(&2, U32, P.slice_bytes(xs), n), encoded)
  +lenn = region_prefix(P.slice_bytes(xs), ps, n, CL.sized_by_wf(xs, n, wf, room), layout)
  +fitsn = Equal.trans(Bool, N.fits(4n, n), N.fits(4n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))), True{},
    Equal.cong(Nat, Bool, k => N.fits(4n, k), n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), Equal.sym(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n, lenn)),
    encoding_fits(ps, List.take(&2, U32, P.slice_bytes(xs), n), encoded))
  +fits4 = Equal.trans(Bool, D.fits(n), N.fits(4n, n), True{}, CL.fits_bridge(n), fitsn)
  +hs = seq_header_size(m, ps, SS.fixed_size(e), align)
  +hsd = Equal.trans(Nat, Nat.mul(IL.slot(IS.fixed_size(e)), m), Nat.mul(IL.slot(SS.fixed_size(e)), m), SL.fixed_size(ps),
    Equal.cong(Maybe<&2, Nat>, Nat, u => Nat.mul(IL.slot(u), m), IS.fixed_size(e), SS.fixed_size(e), Sch.fixed_size_correct(e)),
    hs)
  +headle = CLeaf.nat_le_true(SL.fixed_size(ps), n,
    Equal.trans(Bool, Nat.is_le(SL.fixed_size(ps), n), Nat.is_le(SL.fixed_size(ps), Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))), True{},
      Equal.cong(Nat, Bool, k => Nat.is_le(SL.fixed_size(ps), k), n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), Equal.sym(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n, lenn)),
      NO.below_sum(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))))
  +pre = Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(xs), List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)))), List.take(&2, U32, P.slice_bytes(xs), n), List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)),
    Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))), n,
      Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))), Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n,
        layout_length_parts(ps), lenn)),
    Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(xs), n), List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)), List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)),
      Equal.sym(+List<U32>, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)), List.take(&2, U32, P.slice_bytes(xs), n), layout), {==}))
  +headerstart = Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), 0n), Nat.sub(SL.fixed_size(ps), 0n)), List.take(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), SL.fixed_parts(ps, SL.fixed_size(ps)),
    Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), 0n), Nat.sub(SL.fixed_size(ps), 0n)), List.take(&2, U32, P.slice_bytes(xs), Nat.sub(SL.fixed_size(ps), 0n)), List.take(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)),
      Equal.cong(+List<U32>, +List<U32>, ys => List.take(&2, U32, ys, Nat.sub(SL.fixed_size(ps), 0n)), List.drop(&2, U32, P.slice_bytes(xs), 0n), P.slice_bytes(xs), PK.drop_zero(P.slice_bytes(xs))),
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), Nat.sub(SL.fixed_size(ps), 0n), SL.fixed_size(ps), PK.sub_zero(SL.fixed_size(ps)))),
    Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), List.take(&2, U32, P.slice_bytes(xs), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)))), SL.fixed_parts(ps, SL.fixed_size(ps)),
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), SL.fixed_size(ps), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), Equal.sym(Nat, List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), SL.fixed_size(ps), LA.fixed_parts_length(ps, SL.fixed_size(ps)))),
      starts_head(P.slice_bytes(xs), SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps), pre)))
  +payloadstart = Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), Nat.sub(n, SL.fixed_size(ps))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)))), List.length(&2, U32, SL.payloads(ps))), SL.payloads(ps),
    Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), Nat.sub(n, SL.fixed_size(ps))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), List.length(&2, U32, SL.payloads(ps))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)))), List.length(&2, U32, SL.payloads(ps))),
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), k), Nat.sub(n, SL.fixed_size(ps)), List.length(&2, U32, SL.payloads(ps)),
        Equal.trans(Nat, Nat.sub(n, SL.fixed_size(ps)), Nat.sub(Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), SL.fixed_size(ps)), List.length(&2, U32, SL.payloads(ps)),
          Equal.cong(Nat, Nat, k => Nat.sub(k, SL.fixed_size(ps)), n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), Equal.sym(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n, lenn)),
          add_sub_left(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))))),
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), k), List.length(&2, U32, SL.payloads(ps))), SL.fixed_size(ps), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), Equal.sym(Nat, List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), SL.fixed_size(ps), LA.fixed_parts_length(ps, SL.fixed_size(ps))))),
    starts_tail(P.slice_bytes(xs), SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps), pre))
  +headseq = Equal.trans(Bool, D.nat_le(Nat.mul(IL.slot(IS.fixed_size(e)), m), n), D.nat_le(SL.fixed_size(ps), n), True{},
    Equal.cong(Nat, Bool, k => D.nat_le(k, n), Nat.mul(IL.slot(IS.fixed_size(e)), m), SL.fixed_size(ps), hsd),
    headle)
  %Equal.sym(Bool, Bool.and(Nat.is_lt(0n, m), D.sequence_ok(IS.fixed_size(e), m, n)), True{},
    V.and_true(Nat.is_lt(0n, m), D.sequence_ok(IS.fixed_size(e), m, n), positive,
      V.and_true(D.fits(n), D.nat_le(Nat.mul(IL.slot(IS.fixed_size(e)), m), n), fits4, headseq))) : CLeaf.parsed_as(T.Sequence{items}, xs, n, D.wrap_sequence(D.go(T.Vector{e, m}, 0n, m, D.layout(_, Nat.mul(IL.slot(IS.fixed_size(e)), m), n, xs))))
  %Equal.sym(Nat, Nat.mul(IL.slot(IS.fixed_size(e)), m), SL.fixed_size(ps), hsd) : CLeaf.parsed_as(T.Sequence{items}, xs, n, D.wrap_sequence(D.go(T.Vector{e, m}, 0n, m, D.layout(True{}, _, n, xs))))
  wrap_complete(D.go(T.Vector{e, m}, 0n, m, D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(ps)), SL.fixed_size(ps), n, C.CEnd{}}), xs, n, items,
    walk(wf, room, fitsn,
      Equal.sym(+List<U32>, List.drop(&2, U32, P.slice_bytes(xs), 0n), P.slice_bytes(xs), PK.drop_zero(P.slice_bytes(xs))),
      wf,
      PK.adv_view(xs, SL.fixed_size(ps)),
      PK.wf_adv(xs, SL.fixed_size(ps), wf),
      {==},
      {==},
      PKG.add_zero(SL.fixed_size(ps)),
      lenn,
      headerstart,
      payloadstart,
      lenn,
      partsof,
      counted))

law mul_comm:
  for +a: Nat
  for +b: Nat
  {Nat.mul(a, b) == Nat.mul(b, a) : Nat}
def mul_comm(a, b):
  match a:
    case 0n: Equal.sym(Nat, Nat.mul(b, 0n), 0n, NA.mul_zero(b))
    case 1n+p:
      Equal.trans(Nat, Nat.add(b, Nat.mul(p, b)), Nat.add(b, Nat.mul(b, p)), Nat.mul(b, 1n+p),
        Equal.cong(Nat, Nat, k => Nat.add(b, k), Nat.mul(p, b), Nat.mul(b, p), mul_comm(p, b)),
        Equal.sym(Nat, Nat.mul(b, 1n+p), Nat.add(b, Nat.mul(b, p)), NA.mul_succ_right(b, p)))

# Uniform fixed-width elements leave no payload region: every part is fixed.
law uniform_fixed_payloads:
  for +m: Nat
  for +ps: +List<T.Part>
  for +q: Nat
  for +align: {HW.widths(ps) == List.replicate(Maybe<&2, Nat>, m, Some{q}) : +List<Maybe<&2, Nat>>}
  {SL.payloads(ps) == [] : +List<U32>}
def uniform_fixed_payloads(m, ps, q, align):
  match m:
    case 0n:
      match ps:
        case Nil{}: {==}
        case Con{T.Fixed{xs}, t}:
          Empty.absurd({SL.payloads(T.Fixed{xs} <> t) == [] : +List<U32>},
            F.false_true(Equal.sym(Bool, True{}, False{},
              Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, HW.widths(T.Fixed{xs} <> t), List.replicate(Maybe<&2, Nat>, 0n, Some{q}), align))))
        case Con{T.Variable{xs}, t}:
          Empty.absurd({SL.payloads(T.Variable{xs} <> t) == [] : +List<U32>},
            F.false_true(Equal.sym(Bool, True{}, False{},
              Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, HW.widths(T.Variable{xs} <> t), List.replicate(Maybe<&2, Nat>, 0n, Some{q}), align))))
    case 1n+p:
      match ps:
        case Nil{}:
          Empty.absurd({SL.payloads([]) == [] : +List<U32>},
            F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, HW.widths([]), List.replicate(Maybe<&2, Nat>, 1n+p, Some{q}), align)))
        case Con{T.Fixed{xs}, t}:
          uniform_fixed_payloads(p, t, q,
            Equal.cong(+List<Maybe<&2, Nat>>, +List<Maybe<&2, Nat>>, tail_w, HW.widths(T.Fixed{xs} <> t), List.replicate(Maybe<&2, Nat>, 1n+p, Some{q}), align))
        case Con{T.Variable{xs}, t}:
          Empty.absurd({SL.payloads(T.Variable{xs} <> t) == [] : +List<U32>},
            F.false_true(Equal.cong(Maybe<&2, Nat>, Bool, CLeaf.is_some_nat, None{}, Some{q},
              Equal.cong(+List<Maybe<&2, Nat>>, Maybe<&2, Nat>, head_w, HW.widths(T.Variable{xs} <> t), List.replicate(Maybe<&2, Nat>, 1n+p, Some{q}), align))))

# The decoder's element count for a fixed-width element type is the number of
# elements the specification's parts describe.
law list_count_fixed:
  for +e: T.Schema
  for +w: Nat
  for +m: Nat
  for +ps: +List<T.Part>
  for +n: Nat
  for +xs: P.Slice
  for +width: {SS.fixed_size(e) == Some{1n+w} : Maybe<&2, Nat>}
  for +align: {HW.widths(ps) == List.replicate(Maybe<&2, Nat>, m, SS.fixed_size(e)) : +List<Maybe<&2, Nat>>}
  for +lenn: {Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))) == n : Nat}
  {D.list_count(IS.fixed_size(e), n, xs) == Some{m} : Maybe<&2, Nat>}
def list_count_fixed(e, w, m, ps, n, xs, width, align, lenn):
  +alignq = Equal.trans(+List<Maybe<&2, Nat>>, HW.widths(ps), List.replicate(Maybe<&2, Nat>, m, SS.fixed_size(e)), List.replicate(Maybe<&2, Nat>, m, Some{1n+w}),
    align,
    Equal.cong(Maybe<&2, Nat>, +List<Maybe<&2, Nat>>, u => List.replicate(Maybe<&2, Nat>, m, u), SS.fixed_size(e), Some{1n+w}, width))
  +pay = uniform_fixed_payloads(m, ps, 1n+w, alignq)
  +hs = seq_header_size(m, ps, Some{1n+w}, alignq)
  +neq = Equal.trans(Nat, n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), Nat.mul(m, 1n+w),
    Equal.sym(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n, lenn),
    Equal.trans(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), Nat.add(SL.fixed_size(ps), 0n), Nat.mul(m, 1n+w),
      Equal.cong(+List<U32>, Nat, ys => Nat.add(SL.fixed_size(ps), List.length(&2, U32, ys)), SL.payloads(ps), [], pay),
      Equal.trans(Nat, Nat.add(SL.fixed_size(ps), 0n), SL.fixed_size(ps), Nat.mul(m, 1n+w),
        PKG.add_zero(SL.fixed_size(ps)),
        Equal.trans(Nat, SL.fixed_size(ps), Nat.mul(1n+w, m), Nat.mul(m, 1n+w),
          Equal.sym(Nat, Nat.mul(1n+w, m), SL.fixed_size(ps), hs),
          mul_comm(1n+w, m)))))
  %Equal.sym(Maybe<&2, Nat>, IS.fixed_size(e), Some{1n+w}, Equal.trans(Maybe<&2, Nat>, IS.fixed_size(e), SS.fixed_size(e), Some{1n+w}, Sch.fixed_size_correct(e), width)) : {D.list_count(_, n, xs) == Some{m} : Maybe<&2, Nat>}
  Equal.trans(Maybe<&2, Nat>, D.count_if(D.nat_eq(Nat.mod(n, 1n+w), 0n), Nat.div(n, 1n+w)), D.count_if(D.nat_eq(Nat.mod(Nat.mul(m, 1n+w), 1n+w), 0n), Nat.div(Nat.mul(m, 1n+w), 1n+w)), Some{m},
    Equal.cong(Nat, Maybe<&2, Nat>, k => D.count_if(D.nat_eq(Nat.mod(k, 1n+w), 0n), Nat.div(k, 1n+w)), n, Nat.mul(m, 1n+w), neq),
    Equal.trans(Maybe<&2, Nat>, D.count_if(D.nat_eq(Nat.mod(Nat.mul(m, 1n+w), 1n+w), 0n), Nat.div(Nat.mul(m, 1n+w), 1n+w)), D.count_if(D.nat_eq(0n, 0n), Nat.div(Nat.mul(m, 1n+w), 1n+w)), Some{m},
      Equal.cong(Nat, Maybe<&2, Nat>, k => D.count_if(D.nat_eq(k, 0n), Nat.div(Nat.mul(m, 1n+w), 1n+w)), Nat.mod(Nat.mul(m, 1n+w), 1n+w), 0n, ED.remainder(m, w)),
      Equal.cong(Nat, Maybe<&2, Nat>, k => D.count_if(D.nat_eq(0n, 0n), k), Nat.div(Nat.mul(m, 1n+w), 1n+w), m, ED.quotient(m, w))))

# A region of variable-width elements is counted by its first offset: four
# bytes per element, so the offset divided by four is the element count.
law count_of_offset:
  for +p: Nat
  for +sz: Nat
  for +xs: P.Slice
  for +offset: {P.offset_at(xs) == Nat.mul(4n, 1n+p) : Nat}
  for +room: {Nat.is_le(Nat.mul(4n, 1n+p), sz) == True{} : Bool}
  {D.list_count(None{}, sz, xs) == Some{1n+p} : Maybe<&2, Nat>}
def count_of_offset(p, sz, xs, offset, room):
  match sz:
    case 0n: Empty.absurd({D.list_count(None{}, 0n, xs) == Some{1n+p} : Maybe<&2, Nat>}, F.false_true(room))
    case 1n+q:
      +modeq = Equal.trans(Nat, Nat.mod(Nat.mul(4n, 1n+p), 4n), Nat.mod(Nat.mul(1n+p, 4n), 4n), 0n,
        Equal.cong(Nat, Nat, k => Nat.mod(k, 4n), Nat.mul(4n, 1n+p), Nat.mul(1n+p, 4n), mul_comm(4n, 1n+p)),
        ED.remainder(1n+p, 3n))
      +diveq = Equal.trans(Nat, Nat.div(Nat.mul(4n, 1n+p), 4n), Nat.div(Nat.mul(1n+p, 4n), 4n), 1n+p,
        Equal.cong(Nat, Nat, k => Nat.div(k, 4n), Nat.mul(4n, 1n+p), Nat.mul(1n+p, 4n), mul_comm(4n, 1n+p)),
        ED.quotient(1n+p, 3n))
      %Equal.sym(Nat, P.offset_at(xs), Nat.mul(4n, 1n+p), offset) : {D.count_if(Bool.and(Nat.is_lt(0n, _), Bool.and(D.nat_eq(Nat.mod(_, 4n), 0n), D.nat_le(_, 1n+q))), Nat.div(_, 4n)) == Some{1n+p} : Maybe<&2, Nat>}
      %Equal.sym(Bool, Bool.and(Nat.is_lt(0n, Nat.mul(4n, 1n+p)), Bool.and(D.nat_eq(Nat.mod(Nat.mul(4n, 1n+p), 4n), 0n), D.nat_le(Nat.mul(4n, 1n+p), 1n+q))), True{},
        V.and_true(Nat.is_lt(0n, Nat.mul(4n, 1n+p)), Bool.and(D.nat_eq(Nat.mod(Nat.mul(4n, 1n+p), 4n), 0n), D.nat_le(Nat.mul(4n, 1n+p), 1n+q)), {==},
          V.and_true(D.nat_eq(Nat.mod(Nat.mul(4n, 1n+p), 4n), 0n), D.nat_le(Nat.mul(4n, 1n+p), 1n+q),
            CLeaf.nat_eq_true(Nat.mod(Nat.mul(4n, 1n+p), 4n), 0n, modeq),
            CLeaf.nat_le_true(Nat.mul(4n, 1n+p), 1n+q, room)))) : {D.count_if(_, Nat.div(Nat.mul(4n, 1n+p), 4n)) == Some{1n+p} : Maybe<&2, Nat>}
      Equal.cong(Nat, Maybe<&2, Nat>, k => Some{k}, Nat.div(Nat.mul(4n, 1n+p), 4n), 1n+p, diveq)

# The decoder's element count for a variable-width element type.
law list_count_none:
  for +m: Nat
  for +ps: +List<T.Part>
  for +n: Nat
  for +xs: P.Slice
  for +alignn: {HW.widths(ps) == List.replicate(Maybe<&2, Nat>, m, None{}) : +List<Maybe<&2, Nat>>}
  for +lenn: {Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))) == n : Nat}
  for +lesn: {Nat.is_le(SL.fixed_size(ps), n) == True{} : Bool}
  for +fitfs: {N.fits(4n, SL.fixed_size(ps)) == True{} : Bool}
  for pre: starts_with(xs, SL.fixed_parts(ps, SL.fixed_size(ps)))
  {D.list_count(None{}, n, xs) == Some{m} : Maybe<&2, Nat>}
def list_count_none(m, ps, n, xs, alignn, lenn, lesn, fitfs, pre):
  match m:
    case 0n:
      match ps:
        case Nil{}:
          %lenn : {D.list_count(None{}, _, xs) == Some{0n} : Maybe<&2, Nat>}
          {==}
        case Con{T.Fixed{y}, t}:
          Empty.absurd({D.list_count(None{}, n, xs) == Some{0n} : Maybe<&2, Nat>},
            F.false_true(Equal.sym(Bool, True{}, False{},
              Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, HW.widths(T.Fixed{y} <> t), List.replicate(Maybe<&2, Nat>, 0n, None{}), alignn))))
        case Con{T.Variable{y}, t}:
          Empty.absurd({D.list_count(None{}, n, xs) == Some{0n} : Maybe<&2, Nat>},
            F.false_true(Equal.sym(Bool, True{}, False{},
              Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, HW.widths(T.Variable{y} <> t), List.replicate(Maybe<&2, Nat>, 0n, None{}), alignn))))
    case 1n+p:
      match ps:
        case Nil{}:
          Empty.absurd({D.list_count(None{}, n, xs) == Some{1n+p} : Maybe<&2, Nat>},
            F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, is_cons_w, HW.widths([]), List.replicate(Maybe<&2, Nat>, 1n+p, None{}), alignn)))
        case Con{T.Fixed{y}, t}:
          Empty.absurd({D.list_count(None{}, n, xs) == Some{1n+p} : Maybe<&2, Nat>},
            F.false_true(Equal.sym(Bool, True{}, False{},
              Equal.cong(Maybe<&2, Nat>, Bool, CLeaf.is_some_nat, Some{List.length(&2, U32, y)}, None{},
                Equal.cong(+List<Maybe<&2, Nat>>, Maybe<&2, Nat>, head_w, HW.widths(T.Fixed{y} <> t), List.replicate(Maybe<&2, Nat>, 1n+p, None{}), alignn)))))
        case Con{T.Variable{y}, t}:
          +hs = seq_header_size(1n+p, T.Variable{y} <> t, None{}, alignn)
          +bytes4 = Equal.trans(+List<U32>, N.digits(4n, SL.fixed_size(T.Variable{y} <> t)), List.take(&2, U32, P.slice_bytes(xs), List.length(&2, U32, N.digits(4n, SL.fixed_size(T.Variable{y} <> t)))), List.take(&2, U32, P.slice_bytes(xs), 4n),
            Equal.sym(+List<U32>, List.take(&2, U32, P.slice_bytes(xs), List.length(&2, U32, N.digits(4n, SL.fixed_size(T.Variable{y} <> t)))), N.digits(4n, SL.fixed_size(T.Variable{y} <> t)),
              starts_head(P.slice_bytes(xs), N.digits(4n, SL.fixed_size(T.Variable{y} <> t)), SL.fixed_parts(t, Nat.add(SL.fixed_size(T.Variable{y} <> t), List.length(&2, U32, y))), pre)),
            Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), List.length(&2, U32, N.digits(4n, SL.fixed_size(T.Variable{y} <> t))), 4n, Digits.digits_length(4n, SL.fixed_size(T.Variable{y} <> t))))
          count_of_offset(p, n, xs,
            Equal.trans(Nat, P.offset_at(xs), SL.fixed_size(T.Variable{y} <> t), Nat.mul(4n, 1n+p),
              offset_here(xs, SL.fixed_size(T.Variable{y} <> t), fitfs, bytes4),
              Equal.sym(Nat, Nat.mul(4n, 1n+p), SL.fixed_size(T.Variable{y} <> t), hs)),
            Equal.trans(Bool, Nat.is_le(Nat.mul(4n, 1n+p), n), Nat.is_le(SL.fixed_size(T.Variable{y} <> t), n), True{},
              Equal.cong(Nat, Bool, k => Nat.is_le(k, n), Nat.mul(4n, 1n+p), SL.fixed_size(T.Variable{y} <> t), hs),
              lesn))

law list_count_variable:
  for +e: T.Schema
  for +m: Nat
  for +ps: +List<T.Part>
  for +n: Nat
  for +xs: P.Slice
  for +width: {SS.fixed_size(e) == None{} : Maybe<&2, Nat>}
  for +align: {HW.widths(ps) == List.replicate(Maybe<&2, Nat>, m, SS.fixed_size(e)) : +List<Maybe<&2, Nat>>}
  for +lenn: {Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))) == n : Nat}
  for +fitn: {N.fits(4n, n) == True{} : Bool}
  for pre: starts_with(xs, SL.fixed_parts(ps, SL.fixed_size(ps)))
  {D.list_count(IS.fixed_size(e), n, xs) == Some{m} : Maybe<&2, Nat>}
def list_count_variable(e, m, ps, n, xs, width, align, lenn, fitn, pre):
  +alignn = Equal.trans(+List<Maybe<&2, Nat>>, HW.widths(ps), List.replicate(Maybe<&2, Nat>, m, SS.fixed_size(e)), List.replicate(Maybe<&2, Nat>, m, None{}),
    align,
    Equal.cong(Maybe<&2, Nat>, +List<Maybe<&2, Nat>>, u => List.replicate(Maybe<&2, Nat>, m, u), SS.fixed_size(e), None{}, width))
  +lesn = Equal.trans(Bool, Nat.is_le(SL.fixed_size(ps), n), Nat.is_le(SL.fixed_size(ps), Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))), True{},
    Equal.cong(Nat, Bool, k => Nat.is_le(SL.fixed_size(ps), k), n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))),
      Equal.sym(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n, lenn)),
    NO.below_sum(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))))
  %Equal.sym(Maybe<&2, Nat>, IS.fixed_size(e), None{}, Equal.trans(Maybe<&2, Nat>, IS.fixed_size(e), SS.fixed_size(e), None{}, Sch.fixed_size_correct(e), width)) : {D.list_count(_, n, xs) == Some{m} : Maybe<&2, Nat>}
  list_count_none(m, ps, n, xs, alignn, lenn, lesn, Digits.fits_monotone(4n, SL.fixed_size(ps), n, lesn, fitn), pre)

# A list region: the element count is read from the region itself, checked
# against the limit, and the walk then reads exactly that many elements.
law list_complete:
  for +e: T.Schema
  for +limit: Nat
  for +m: Nat
  for +items: T.Value
  for +ps: +List<T.Part>
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +partsof: {SC.parts(items, T.Repeat{e}) == Some{ps} : Maybe<&2, +List<T.Part>>}
  for +counted: {SC.count(items) == m : Nat}
  for +bound: {Nat.is_le(m, limit) == True{} : Bool}
  for +align: {HW.widths(ps) == List.replicate(Maybe<&2, Nat>, m, SS.fixed_size(e)) : +List<Maybe<&2, Nat>>}
  for +encoded: {SL.encoding(ps) == Some{List.take(&2, U32, P.slice_bytes(xs), n)} : Maybe<&2, +List<U32>>}
  for +cntok: {D.list_count(IS.fixed_size(e), n, xs) == Some{m} : Maybe<&2, Nat>}
  for walk: walk_goal_seq(e, m, xs, n, SL.fixed_size(ps), 0n, SL.fixed_size(ps), [], ps, xs, P.adv(xs, SL.fixed_size(ps)), C.CEnd{}, items, D.go(T.ListOf{e, limit}, 0n, m, D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(ps)), SL.fixed_size(ps), n, C.CEnd{}}))
  CLeaf.parsed_as(T.Sequence{items}, xs, n, D.go(T.ListOf{e, limit}, 1n, 0n, D.Region{n, xs}))
def list_complete(e, limit, m, items, ps, n, xs, wf, room, partsof, counted, bound, align, encoded, cntok, walk):
  +layout = encoding_layout(ps, List.take(&2, U32, P.slice_bytes(xs), n), encoded)
  +lenn = region_prefix(P.slice_bytes(xs), ps, n, CL.sized_by_wf(xs, n, wf, room), layout)
  +fitsn = Equal.trans(Bool, N.fits(4n, n), N.fits(4n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))), True{},
    Equal.cong(Nat, Bool, k => N.fits(4n, k), n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), Equal.sym(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n, lenn)),
    encoding_fits(ps, List.take(&2, U32, P.slice_bytes(xs), n), encoded))
  +fits4 = Equal.trans(Bool, D.fits(n), N.fits(4n, n), True{}, CL.fits_bridge(n), fitsn)
  +hs = seq_header_size(m, ps, SS.fixed_size(e), align)
  +hsd = Equal.trans(Nat, Nat.mul(IL.slot(IS.fixed_size(e)), m), Nat.mul(IL.slot(SS.fixed_size(e)), m), SL.fixed_size(ps),
    Equal.cong(Maybe<&2, Nat>, Nat, u => Nat.mul(IL.slot(u), m), IS.fixed_size(e), SS.fixed_size(e), Sch.fixed_size_correct(e)),
    hs)
  +headle = CLeaf.nat_le_true(SL.fixed_size(ps), n,
    Equal.trans(Bool, Nat.is_le(SL.fixed_size(ps), n), Nat.is_le(SL.fixed_size(ps), Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))), True{},
      Equal.cong(Nat, Bool, k => Nat.is_le(SL.fixed_size(ps), k), n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), Equal.sym(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n, lenn)),
      NO.below_sum(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))))
  +pre = Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(xs), List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)))), List.take(&2, U32, P.slice_bytes(xs), n), List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)),
    Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))), n,
      Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))), Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n,
        layout_length_parts(ps), lenn)),
    Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(xs), n), List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)), List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)),
      Equal.sym(+List<U32>, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)), List.take(&2, U32, P.slice_bytes(xs), n), layout), {==}))
  +headerstart = Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), 0n), Nat.sub(SL.fixed_size(ps), 0n)), List.take(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), SL.fixed_parts(ps, SL.fixed_size(ps)),
    Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), 0n), Nat.sub(SL.fixed_size(ps), 0n)), List.take(&2, U32, P.slice_bytes(xs), Nat.sub(SL.fixed_size(ps), 0n)), List.take(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)),
      Equal.cong(+List<U32>, +List<U32>, ys => List.take(&2, U32, ys, Nat.sub(SL.fixed_size(ps), 0n)), List.drop(&2, U32, P.slice_bytes(xs), 0n), P.slice_bytes(xs), PK.drop_zero(P.slice_bytes(xs))),
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), Nat.sub(SL.fixed_size(ps), 0n), SL.fixed_size(ps), PK.sub_zero(SL.fixed_size(ps)))),
    Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), List.take(&2, U32, P.slice_bytes(xs), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)))), SL.fixed_parts(ps, SL.fixed_size(ps)),
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), SL.fixed_size(ps), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), Equal.sym(Nat, List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), SL.fixed_size(ps), LA.fixed_parts_length(ps, SL.fixed_size(ps)))),
      starts_head(P.slice_bytes(xs), SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps), pre)))
  +payloadstart = Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), Nat.sub(n, SL.fixed_size(ps))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)))), List.length(&2, U32, SL.payloads(ps))), SL.payloads(ps),
    Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), Nat.sub(n, SL.fixed_size(ps))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), List.length(&2, U32, SL.payloads(ps))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)))), List.length(&2, U32, SL.payloads(ps))),
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), k), Nat.sub(n, SL.fixed_size(ps)), List.length(&2, U32, SL.payloads(ps)),
        Equal.trans(Nat, Nat.sub(n, SL.fixed_size(ps)), Nat.sub(Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), SL.fixed_size(ps)), List.length(&2, U32, SL.payloads(ps)),
          Equal.cong(Nat, Nat, k => Nat.sub(k, SL.fixed_size(ps)), n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), Equal.sym(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n, lenn)),
          add_sub_left(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))))),
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), k), List.length(&2, U32, SL.payloads(ps))), SL.fixed_size(ps), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), Equal.sym(Nat, List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), SL.fixed_size(ps), LA.fixed_parts_length(ps, SL.fixed_size(ps))))),
    starts_tail(P.slice_bytes(xs), SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps), pre))
  +headseq = Equal.trans(Bool, D.nat_le(Nat.mul(IL.slot(IS.fixed_size(e)), m), n), D.nat_le(SL.fixed_size(ps), n), True{},
    Equal.cong(Nat, Bool, k => D.nat_le(k, n), Nat.mul(IL.slot(IS.fixed_size(e)), m), SL.fixed_size(ps), hsd),
    headle)
  %Equal.sym(Maybe<&2, Nat>, D.list_count(IS.fixed_size(e), n, xs), Some{m}, cntok) : CLeaf.parsed_as(T.Sequence{items}, xs, n, D.wrap_sequence(D.go(T.ListOf{e, limit}, 0n, D.counted(_), D.layout(Bool.and(D.count_ok(_, Some{limit}), D.sequence_ok(IS.fixed_size(e), D.counted(_), n)), Nat.mul(IL.slot(IS.fixed_size(e)), D.counted(_)), n, xs))))
  %Equal.sym(Bool, Bool.and(D.count_ok(Some{m}, Some{limit}), D.sequence_ok(IS.fixed_size(e), m, n)), True{},
    V.and_true(D.count_ok(Some{m}, Some{limit}), D.sequence_ok(IS.fixed_size(e), m, n), CLeaf.nat_le_true(m, limit, bound),
      V.and_true(D.fits(n), D.nat_le(Nat.mul(IL.slot(IS.fixed_size(e)), m), n), fits4, headseq))) : CLeaf.parsed_as(T.Sequence{items}, xs, n, D.wrap_sequence(D.go(T.ListOf{e, limit}, 0n, m, D.layout(_, Nat.mul(IL.slot(IS.fixed_size(e)), m), n, xs))))
  %Equal.sym(Nat, Nat.mul(IL.slot(IS.fixed_size(e)), m), SL.fixed_size(ps), hsd) : CLeaf.parsed_as(T.Sequence{items}, xs, n, D.wrap_sequence(D.go(T.ListOf{e, limit}, 0n, m, D.layout(True{}, _, n, xs))))
  wrap_complete(D.go(T.ListOf{e, limit}, 0n, m, D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(ps)), SL.fixed_size(ps), n, C.CEnd{}}), xs, n, items,
    walk(wf, room, fitsn,
      Equal.sym(+List<U32>, List.drop(&2, U32, P.slice_bytes(xs), 0n), P.slice_bytes(xs), PK.drop_zero(P.slice_bytes(xs))),
      wf,
      PK.adv_view(xs, SL.fixed_size(ps)),
      PK.wf_adv(xs, SL.fixed_size(ps), wf),
      {==},
      {==},
      PKG.add_zero(SL.fixed_size(ps)),
      lenn,
      headerstart,
      payloadstart,
      lenn,
      partsof,
      counted))

# A progressive list region: same as a list region with no limit.
law progressive_list_complete:
  for +e: T.Schema
  for +m: Nat
  for +items: T.Value
  for +ps: +List<T.Part>
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +partsof: {SC.parts(items, T.Repeat{e}) == Some{ps} : Maybe<&2, +List<T.Part>>}
  for +counted: {SC.count(items) == m : Nat}
  for +align: {HW.widths(ps) == List.replicate(Maybe<&2, Nat>, m, SS.fixed_size(e)) : +List<Maybe<&2, Nat>>}
  for +encoded: {SL.encoding(ps) == Some{List.take(&2, U32, P.slice_bytes(xs), n)} : Maybe<&2, +List<U32>>}
  for +cntok: {D.list_count(IS.fixed_size(e), n, xs) == Some{m} : Maybe<&2, Nat>}
  for walk: walk_goal_seq(e, m, xs, n, SL.fixed_size(ps), 0n, SL.fixed_size(ps), [], ps, xs, P.adv(xs, SL.fixed_size(ps)), C.CEnd{}, items, D.go(T.ProgressiveList{e}, 0n, m, D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(ps)), SL.fixed_size(ps), n, C.CEnd{}}))
  CLeaf.parsed_as(T.Sequence{items}, xs, n, D.go(T.ProgressiveList{e}, 1n, 0n, D.Region{n, xs}))
def progressive_list_complete(e, m, items, ps, n, xs, wf, room, partsof, counted, align, encoded, cntok, walk):
  +layout = encoding_layout(ps, List.take(&2, U32, P.slice_bytes(xs), n), encoded)
  +lenn = region_prefix(P.slice_bytes(xs), ps, n, CL.sized_by_wf(xs, n, wf, room), layout)
  +fitsn = Equal.trans(Bool, N.fits(4n, n), N.fits(4n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))), True{},
    Equal.cong(Nat, Bool, k => N.fits(4n, k), n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), Equal.sym(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n, lenn)),
    encoding_fits(ps, List.take(&2, U32, P.slice_bytes(xs), n), encoded))
  +fits4 = Equal.trans(Bool, D.fits(n), N.fits(4n, n), True{}, CL.fits_bridge(n), fitsn)
  +hs = seq_header_size(m, ps, SS.fixed_size(e), align)
  +hsd = Equal.trans(Nat, Nat.mul(IL.slot(IS.fixed_size(e)), m), Nat.mul(IL.slot(SS.fixed_size(e)), m), SL.fixed_size(ps),
    Equal.cong(Maybe<&2, Nat>, Nat, u => Nat.mul(IL.slot(u), m), IS.fixed_size(e), SS.fixed_size(e), Sch.fixed_size_correct(e)),
    hs)
  +headle = CLeaf.nat_le_true(SL.fixed_size(ps), n,
    Equal.trans(Bool, Nat.is_le(SL.fixed_size(ps), n), Nat.is_le(SL.fixed_size(ps), Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))), True{},
      Equal.cong(Nat, Bool, k => Nat.is_le(SL.fixed_size(ps), k), n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), Equal.sym(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n, lenn)),
      NO.below_sum(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))))
  +pre = Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(xs), List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)))), List.take(&2, U32, P.slice_bytes(xs), n), List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)),
    Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))), n,
      Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))), Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n,
        layout_length_parts(ps), lenn)),
    Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(xs), n), List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)), List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)),
      Equal.sym(+List<U32>, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)), List.take(&2, U32, P.slice_bytes(xs), n), layout), {==}))
  +headerstart = Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), 0n), Nat.sub(SL.fixed_size(ps), 0n)), List.take(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), SL.fixed_parts(ps, SL.fixed_size(ps)),
    Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), 0n), Nat.sub(SL.fixed_size(ps), 0n)), List.take(&2, U32, P.slice_bytes(xs), Nat.sub(SL.fixed_size(ps), 0n)), List.take(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)),
      Equal.cong(+List<U32>, +List<U32>, ys => List.take(&2, U32, ys, Nat.sub(SL.fixed_size(ps), 0n)), List.drop(&2, U32, P.slice_bytes(xs), 0n), P.slice_bytes(xs), PK.drop_zero(P.slice_bytes(xs))),
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), Nat.sub(SL.fixed_size(ps), 0n), SL.fixed_size(ps), PK.sub_zero(SL.fixed_size(ps)))),
    Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), List.take(&2, U32, P.slice_bytes(xs), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)))), SL.fixed_parts(ps, SL.fixed_size(ps)),
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), SL.fixed_size(ps), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), Equal.sym(Nat, List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), SL.fixed_size(ps), LA.fixed_parts_length(ps, SL.fixed_size(ps)))),
      starts_head(P.slice_bytes(xs), SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps), pre)))
  +payloadstart = Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), Nat.sub(n, SL.fixed_size(ps))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)))), List.length(&2, U32, SL.payloads(ps))), SL.payloads(ps),
    Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), Nat.sub(n, SL.fixed_size(ps))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), List.length(&2, U32, SL.payloads(ps))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)))), List.length(&2, U32, SL.payloads(ps))),
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), SL.fixed_size(ps)), k), Nat.sub(n, SL.fixed_size(ps)), List.length(&2, U32, SL.payloads(ps)),
        Equal.trans(Nat, Nat.sub(n, SL.fixed_size(ps)), Nat.sub(Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), SL.fixed_size(ps)), List.length(&2, U32, SL.payloads(ps)),
          Equal.cong(Nat, Nat, k => Nat.sub(k, SL.fixed_size(ps)), n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), Equal.sym(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n, lenn)),
          add_sub_left(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))))),
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), k), List.length(&2, U32, SL.payloads(ps))), SL.fixed_size(ps), List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), Equal.sym(Nat, List.length(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps))), SL.fixed_size(ps), LA.fixed_parts_length(ps, SL.fixed_size(ps))))),
    starts_tail(P.slice_bytes(xs), SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps), pre))
  +headseq = Equal.trans(Bool, D.nat_le(Nat.mul(IL.slot(IS.fixed_size(e)), m), n), D.nat_le(SL.fixed_size(ps), n), True{},
    Equal.cong(Nat, Bool, k => D.nat_le(k, n), Nat.mul(IL.slot(IS.fixed_size(e)), m), SL.fixed_size(ps), hsd),
    headle)
  %Equal.sym(Maybe<&2, Nat>, D.list_count(IS.fixed_size(e), n, xs), Some{m}, cntok) : CLeaf.parsed_as(T.Sequence{items}, xs, n, D.wrap_sequence(D.go(T.ProgressiveList{e}, 0n, D.counted(_), D.layout(Bool.and(D.count_ok(_, None{}), D.sequence_ok(IS.fixed_size(e), D.counted(_), n)), Nat.mul(IL.slot(IS.fixed_size(e)), D.counted(_)), n, xs))))
  %Equal.sym(Bool, Bool.and(D.count_ok(Some{m}, None{}), D.sequence_ok(IS.fixed_size(e), m, n)), True{},
    V.and_true(D.count_ok(Some{m}, None{}), D.sequence_ok(IS.fixed_size(e), m, n), {==},
      V.and_true(D.fits(n), D.nat_le(Nat.mul(IL.slot(IS.fixed_size(e)), m), n), fits4, headseq))) : CLeaf.parsed_as(T.Sequence{items}, xs, n, D.wrap_sequence(D.go(T.ProgressiveList{e}, 0n, m, D.layout(_, Nat.mul(IL.slot(IS.fixed_size(e)), m), n, xs))))
  %Equal.sym(Nat, Nat.mul(IL.slot(IS.fixed_size(e)), m), SL.fixed_size(ps), hsd) : CLeaf.parsed_as(T.Sequence{items}, xs, n, D.wrap_sequence(D.go(T.ProgressiveList{e}, 0n, m, D.layout(True{}, _, n, xs))))
  wrap_complete(D.go(T.ProgressiveList{e}, 0n, m, D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(ps)), SL.fixed_size(ps), n, C.CEnd{}}), xs, n, items,
    walk(wf, room, fitsn,
      Equal.sym(+List<U32>, List.drop(&2, U32, P.slice_bytes(xs), 0n), P.slice_bytes(xs), PK.drop_zero(P.slice_bytes(xs))),
      wf,
      PK.adv_view(xs, SL.fixed_size(ps)),
      PK.wf_adv(xs, SL.fixed_size(ps), wf),
      {==},
      {==},
      PKG.add_zero(SL.fixed_size(ps)),
      lenn,
      headerstart,
      payloadstart,
      lenn,
      partsof,
      counted))

# ---------------------------------------------------------------------------
# Unions. The region is one selector byte followed by the selected option's
# encoding; the decoder picks the option by index (`Union`) or by matching the
# declared selector byte (`CompatibleUnion`).
def is_some_schema(r: Maybe<&2, T.Schema>) -> Bool:
  match r:
    case Some{s}: True{}
    case None{}: False{}

def schema_of(r: Maybe<&2, T.Schema>, alt: T.Schema) -> T.Schema:
  match r:
    case Some{s}: s
    case None{}: alt

law selected_complete:
  for out: D.Out
  for +sl: P.Slice
  for +end: Nat
  for +selector: U32
  for +v: T.Value
  for r: CLeaf.parsed_as(v, sl, end, out)
  CLeaf.parsed_as(T.Selected{selector, v}, sl, end, D.wrap_selected(selector, out))
def selected_complete(out, sl, end, selector, v, r):
  match out:
    case D.Parsed{c, rest}:
      (a, bc) = r
      (b, cc) = bc
      (Equal.cong(T.Value, T.Value, x => T.Selected{selector, x}, C.to_value(c), v, a), (b, cc))
    case D.Refused{}: Empty.absurd(CLeaf.parsed_as(T.Selected{selector, v}, sl, end, D.wrap_selected(selector, D.Refused{})), r)
    case D.Begin{x}: Empty.absurd(CLeaf.parsed_as(T.Selected{selector, v}, sl, end, D.wrap_selected(selector, D.Begin{x})), r)

# Reading one selector byte first: a result over the region after the byte is a
# result over the whole region.
law shift_region:
  for out: D.Out
  for +sl: P.Slice
  for +m: Nat
  for +value: T.Value
  for r: CLeaf.parsed_as(value, P.adv(sl, 1n), m, out)
  CLeaf.parsed_as(value, sl, 1n+m, out)
def shift_region(out, sl, m, value, r):
  match out:
    case D.Parsed{c, rest}:
      (a, bc) = r
      (b, cc) = bc
      (a, (Equal.trans(+List<U32>, P.slice_bytes(rest), List.drop(&2, U32, P.slice_bytes(P.adv(sl, 1n)), m), List.drop(&2, U32, P.slice_bytes(sl), 1n+m),
        b,
        Equal.trans(+List<U32>, List.drop(&2, U32, P.slice_bytes(P.adv(sl, 1n)), m), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), 1n), m), List.drop(&2, U32, P.slice_bytes(sl), 1n+m),
          Equal.cong(+List<U32>, +List<U32>, ys => List.drop(&2, U32, ys, m), P.slice_bytes(P.adv(sl, 1n)), List.drop(&2, U32, P.slice_bytes(sl), 1n), PK.adv_view(sl, 1n)),
          W.drop_drop(P.slice_bytes(sl), 1n, m))), cc))
    case D.Refused{}: Empty.absurd(CLeaf.parsed_as(value, sl, 1n+m, D.Refused{}), r)
    case D.Begin{x}: Empty.absurd(CLeaf.parsed_as(value, sl, 1n+m, D.Begin{x}), r)

law first_byte_of:
  for +bytes: +List<U32>
  for +m: Nat
  for +selector: U32
  for +ys: +List<U32>
  for +prefix: {List.take(&2, U32, bytes, 1n+m) == selector <> ys : +List<U32>}
  {IP.at(bytes, 0n) == selector : U32}
def first_byte_of(bytes, m, selector, ys, prefix):
  match bytes:
    case Nil{}:
      Empty.absurd({IP.at([], 0n) == selector : U32},
        F.false_true(Equal.cong(+List<U32>, Bool, is_cons, List.take(&2, U32, [], 1n+m), selector <> ys, prefix)))
    case Con{b, t}:
      Equal.cong(+List<U32>, U32, head_of, List.take(&2, U32, b <> t, 1n+m), selector <> ys, prefix)

# Walking the option chain to the selected index.
law option_pick:
  for +options: T.Schema
  for +idx: Nat
  for +s: T.Schema
  for +selector: U32
  for +m: Nat
  for +xs: P.Slice
  for +found: {SS.option(options, idx) == Some{s} : Maybe<&2, T.Schema>}
  {D.go(options, 0n, idx, D.Pick{selector, m, xs}) == D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, xs})) : D.Out}
def option_pick(options, idx, s, selector, m, xs, found):
  match options:
    case T.Chain{h, t}:
      match idx:
        case 0n:
          Equal.cong(T.Schema, D.Out, x => D.wrap_selected(selector, D.go(x, 1n, 0n, D.Region{m, xs})), h, s,
            Equal.cong(Maybe<&2, T.Schema>, T.Schema, r => schema_of(r, h), Some{h}, Some{s}, found))
        case 1n+p: option_pick(t, p, s, selector, m, xs, found)
    case T.Boolean{}: Empty.absurd({D.go(T.Boolean{}, 0n, idx, D.Pick{selector, m, xs}) == D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.option(T.Boolean{}, idx), Some{s}, found)))
    case T.Unsigned{s0}: Empty.absurd({D.go(T.Unsigned{s0}, 0n, idx, D.Pick{selector, m, xs}) == D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.option(T.Unsigned{s0}, idx), Some{s}, found)))
    case T.ByteVector{s0}: Empty.absurd({D.go(T.ByteVector{s0}, 0n, idx, D.Pick{selector, m, xs}) == D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.option(T.ByteVector{s0}, idx), Some{s}, found)))
    case T.ByteList{s0}: Empty.absurd({D.go(T.ByteList{s0}, 0n, idx, D.Pick{selector, m, xs}) == D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.option(T.ByteList{s0}, idx), Some{s}, found)))
    case T.BitVector{s0}: Empty.absurd({D.go(T.BitVector{s0}, 0n, idx, D.Pick{selector, m, xs}) == D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.option(T.BitVector{s0}, idx), Some{s}, found)))
    case T.BitList{s0}: Empty.absurd({D.go(T.BitList{s0}, 0n, idx, D.Pick{selector, m, xs}) == D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.option(T.BitList{s0}, idx), Some{s}, found)))
    case T.Vector{s0, s1}: Empty.absurd({D.go(T.Vector{s0, s1}, 0n, idx, D.Pick{selector, m, xs}) == D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.option(T.Vector{s0, s1}, idx), Some{s}, found)))
    case T.ListOf{s0, s1}: Empty.absurd({D.go(T.ListOf{s0, s1}, 0n, idx, D.Pick{selector, m, xs}) == D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.option(T.ListOf{s0, s1}, idx), Some{s}, found)))
    case T.Container{s0, s1}: Empty.absurd({D.go(T.Container{s0, s1}, 0n, idx, D.Pick{selector, m, xs}) == D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.option(T.Container{s0, s1}, idx), Some{s}, found)))
    case T.Union{s0}: Empty.absurd({D.go(T.Union{s0}, 0n, idx, D.Pick{selector, m, xs}) == D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.option(T.Union{s0}, idx), Some{s}, found)))
    case T.Null{}: Empty.absurd({D.go(T.Null{}, 0n, idx, D.Pick{selector, m, xs}) == D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.option(T.Null{}, idx), Some{s}, found)))
    case T.End{}: Empty.absurd({D.go(T.End{}, 0n, idx, D.Pick{selector, m, xs}) == D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.option(T.End{}, idx), Some{s}, found)))
    case T.Repeat{s0}: Empty.absurd({D.go(T.Repeat{s0}, 0n, idx, D.Pick{selector, m, xs}) == D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.option(T.Repeat{s0}, idx), Some{s}, found)))
    case T.Named{s0, s1}: Empty.absurd({D.go(T.Named{s0, s1}, 0n, idx, D.Pick{selector, m, xs}) == D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.option(T.Named{s0, s1}, idx), Some{s}, found)))
    case T.ProgressiveList{s0}: Empty.absurd({D.go(T.ProgressiveList{s0}, 0n, idx, D.Pick{selector, m, xs}) == D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.option(T.ProgressiveList{s0}, idx), Some{s}, found)))
    case T.ProgressiveBits{}: Empty.absurd({D.go(T.ProgressiveBits{}, 0n, idx, D.Pick{selector, m, xs}) == D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.option(T.ProgressiveBits{}, idx), Some{s}, found)))
    case T.ProgressiveContainer{s0, s1, s2}: Empty.absurd({D.go(T.ProgressiveContainer{s0, s1, s2}, 0n, idx, D.Pick{selector, m, xs}) == D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.option(T.ProgressiveContainer{s0, s1, s2}, idx), Some{s}, found)))
    case T.CompatibleUnion{s0, s1}: Empty.absurd({D.go(T.CompatibleUnion{s0, s1}, 0n, idx, D.Pick{selector, m, xs}) == D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.option(T.CompatibleUnion{s0, s1}, idx), Some{s}, found)))

law union_complete:
  for +options: T.Schema
  for +selector: U32
  for +s: T.Schema
  for +v: T.Value
  for +ys: +List<U32>
  for +m: Nat
  for +n: Nat
  for +xs: P.Slice
  for +size: {1n+m == n : Nat}
  for +found: {SS.option(options, U32.to_nat(selector)) == Some{s} : Maybe<&2, T.Schema>}
  for +prefix: {List.take(&2, U32, P.slice_bytes(xs), 1n+m) == selector <> ys : +List<U32>}
  for child: CLeaf.parsed_as(v, P.adv(xs, 1n), m, D.go(s, 1n, 0n, D.Region{m, P.adv(xs, 1n)}))
  CLeaf.parsed_as(T.Selected{selector, v}, xs, n, D.go(T.Union{options}, 1n, 0n, D.Region{n, xs}))
def union_complete(options, selector, s, v, ys, m, n, xs, size, found, prefix, child):
  +bsel = Equal.trans(U32, P.byte_at(xs, 0n), IP.at(P.slice_bytes(xs), 0n), selector,
    PK.byte_at_view(xs, 0n),
    first_byte_of(P.slice_bytes(xs), m, selector, ys, prefix))
  %size : CLeaf.parsed_as(T.Selected{selector, v}, xs, _, D.go(T.Union{options}, 1n, 0n, D.Region{_, xs}))
  %Equal.sym(U32, P.byte_at(xs, 0n), selector, bsel) : CLeaf.parsed_as(T.Selected{selector, v}, xs, 1n+m, D.go(options, 0n, U32.to_nat(_), D.Pick{_, m, P.adv(xs, 1n)}))
  %Equal.sym(D.Out, D.go(options, 0n, U32.to_nat(selector), D.Pick{selector, m, P.adv(xs, 1n)}), D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, P.adv(xs, 1n)})), option_pick(options, U32.to_nat(selector), s, selector, m, P.adv(xs, 1n), found)) : CLeaf.parsed_as(T.Selected{selector, v}, xs, 1n+m, _)
  shift_region(D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, P.adv(xs, 1n)})), xs, m, T.Selected{selector, v},
    selected_complete(D.go(s, 1n, 0n, D.Region{m, P.adv(xs, 1n)}), P.adv(xs, 1n), m, selector, v, child))

law among_step:
  for +hit: Bool
  for +s0: U32
  for +selector: U32
  for +h: T.Schema
  for +t: T.Schema
  for +rest: +List<U32>
  for +sch: T.Schema
  for +m: Nat
  for +xs: P.Slice
  for +iseq: {U32.is_eq(s0, selector) == hit : Bool}
  for +found: {SS.selected(hit, h, SS.compatible_option(rest, t, selector)) == Some{sch} : Maybe<&2, T.Schema>}
  for rec: {SS.compatible_option(rest, t, selector) == Some{sch} : Maybe<&2, T.Schema>} -> {D.go(t, 0n, 0n, D.PickAmong{rest, selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}
  {D.go(T.Chain{h, t}, 0n, 0n, D.PickAmong{s0 <> rest, selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}
def among_step(hit, s0, selector, h, t, rest, sch, m, xs, iseq, found, rec):
  match hit:
    case True{}:
      %Equal.sym(Bool, U32.is_eq(s0, selector), True{}, iseq) : {D.among(_, selector, D.go(h, 1n, 0n, D.among_here(_, m, xs)), D.go(t, 0n, 0n, D.among_later(_, rest, selector, m, xs))) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}
      Equal.cong(T.Schema, D.Out, x => D.wrap_selected(selector, D.go(x, 1n, 0n, D.Region{m, xs})), h, sch,
        Equal.cong(Maybe<&2, T.Schema>, T.Schema, r => schema_of(r, h), Some{h}, Some{sch}, found))
    case False{}:
      %Equal.sym(Bool, U32.is_eq(s0, selector), False{}, iseq) : {D.among(_, selector, D.go(h, 1n, 0n, D.among_here(_, m, xs)), D.go(t, 0n, 0n, D.among_later(_, rest, selector, m, xs))) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}
      rec(found)

law among_pick:
  for +selectors: +List<U32>
  for +options: T.Schema
  for +selector: U32
  for +sch: T.Schema
  for +m: Nat
  for +xs: P.Slice
  for +found: {SS.compatible_option(selectors, options, selector) == Some{sch} : Maybe<&2, T.Schema>}
  {D.go(options, 0n, 0n, D.PickAmong{selectors, selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}
def among_pick(selectors, options, selector, sch, m, xs, found):
  match selectors:
    case Nil{}:
      Empty.absurd({D.go(options, 0n, 0n, D.PickAmong{[], selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out},
        F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.compatible_option([], options, selector), Some{sch}, found)))
    case Con{s0, rest}:
      match options:
        case T.Chain{h, t}:
          among_step(U32.is_eq(s0, selector), s0, selector, h, t, rest, sch, m, xs, {==}, found,
            e => among_pick(rest, t, selector, sch, m, xs, e))
        case T.Boolean{}: Empty.absurd({D.go(T.Boolean{}, 0n, 0n, D.PickAmong{s0 <> rest, selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.compatible_option(s0 <> rest, T.Boolean{}, selector), Some{sch}, found)))
        case T.Unsigned{z0}: Empty.absurd({D.go(T.Unsigned{z0}, 0n, 0n, D.PickAmong{s0 <> rest, selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.compatible_option(s0 <> rest, T.Unsigned{z0}, selector), Some{sch}, found)))
        case T.ByteVector{z0}: Empty.absurd({D.go(T.ByteVector{z0}, 0n, 0n, D.PickAmong{s0 <> rest, selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.compatible_option(s0 <> rest, T.ByteVector{z0}, selector), Some{sch}, found)))
        case T.ByteList{z0}: Empty.absurd({D.go(T.ByteList{z0}, 0n, 0n, D.PickAmong{s0 <> rest, selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.compatible_option(s0 <> rest, T.ByteList{z0}, selector), Some{sch}, found)))
        case T.BitVector{z0}: Empty.absurd({D.go(T.BitVector{z0}, 0n, 0n, D.PickAmong{s0 <> rest, selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.compatible_option(s0 <> rest, T.BitVector{z0}, selector), Some{sch}, found)))
        case T.BitList{z0}: Empty.absurd({D.go(T.BitList{z0}, 0n, 0n, D.PickAmong{s0 <> rest, selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.compatible_option(s0 <> rest, T.BitList{z0}, selector), Some{sch}, found)))
        case T.Vector{z0, z1}: Empty.absurd({D.go(T.Vector{z0, z1}, 0n, 0n, D.PickAmong{s0 <> rest, selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.compatible_option(s0 <> rest, T.Vector{z0, z1}, selector), Some{sch}, found)))
        case T.ListOf{z0, z1}: Empty.absurd({D.go(T.ListOf{z0, z1}, 0n, 0n, D.PickAmong{s0 <> rest, selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.compatible_option(s0 <> rest, T.ListOf{z0, z1}, selector), Some{sch}, found)))
        case T.Container{z0, z1}: Empty.absurd({D.go(T.Container{z0, z1}, 0n, 0n, D.PickAmong{s0 <> rest, selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.compatible_option(s0 <> rest, T.Container{z0, z1}, selector), Some{sch}, found)))
        case T.Union{z0}: Empty.absurd({D.go(T.Union{z0}, 0n, 0n, D.PickAmong{s0 <> rest, selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.compatible_option(s0 <> rest, T.Union{z0}, selector), Some{sch}, found)))
        case T.Null{}: Empty.absurd({D.go(T.Null{}, 0n, 0n, D.PickAmong{s0 <> rest, selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.compatible_option(s0 <> rest, T.Null{}, selector), Some{sch}, found)))
        case T.End{}: Empty.absurd({D.go(T.End{}, 0n, 0n, D.PickAmong{s0 <> rest, selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.compatible_option(s0 <> rest, T.End{}, selector), Some{sch}, found)))
        case T.Repeat{z0}: Empty.absurd({D.go(T.Repeat{z0}, 0n, 0n, D.PickAmong{s0 <> rest, selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.compatible_option(s0 <> rest, T.Repeat{z0}, selector), Some{sch}, found)))
        case T.Named{z0, z1}: Empty.absurd({D.go(T.Named{z0, z1}, 0n, 0n, D.PickAmong{s0 <> rest, selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.compatible_option(s0 <> rest, T.Named{z0, z1}, selector), Some{sch}, found)))
        case T.ProgressiveList{z0}: Empty.absurd({D.go(T.ProgressiveList{z0}, 0n, 0n, D.PickAmong{s0 <> rest, selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.compatible_option(s0 <> rest, T.ProgressiveList{z0}, selector), Some{sch}, found)))
        case T.ProgressiveBits{}: Empty.absurd({D.go(T.ProgressiveBits{}, 0n, 0n, D.PickAmong{s0 <> rest, selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.compatible_option(s0 <> rest, T.ProgressiveBits{}, selector), Some{sch}, found)))
        case T.ProgressiveContainer{z0, z1, z2}: Empty.absurd({D.go(T.ProgressiveContainer{z0, z1, z2}, 0n, 0n, D.PickAmong{s0 <> rest, selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.compatible_option(s0 <> rest, T.ProgressiveContainer{z0, z1, z2}, selector), Some{sch}, found)))
        case T.CompatibleUnion{z0, z1}: Empty.absurd({D.go(T.CompatibleUnion{z0, z1}, 0n, 0n, D.PickAmong{s0 <> rest, selector, m, xs}) == D.wrap_selected(selector, D.go(sch, 1n, 0n, D.Region{m, xs})) : D.Out}, F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, is_some_schema, SS.compatible_option(s0 <> rest, T.CompatibleUnion{z0, z1}, selector), Some{sch}, found)))

law compatible_union_complete:
  for +selectors: +List<U32>
  for +options: T.Schema
  for +selector: U32
  for +s: T.Schema
  for +v: T.Value
  for +ys: +List<U32>
  for +m: Nat
  for +n: Nat
  for +xs: P.Slice
  for +size: {1n+m == n : Nat}
  for +found: {SS.compatible_option(selectors, options, selector) == Some{s} : Maybe<&2, T.Schema>}
  for +prefix: {List.take(&2, U32, P.slice_bytes(xs), 1n+m) == selector <> ys : +List<U32>}
  for child: CLeaf.parsed_as(v, P.adv(xs, 1n), m, D.go(s, 1n, 0n, D.Region{m, P.adv(xs, 1n)}))
  CLeaf.parsed_as(T.Selected{selector, v}, xs, n, D.go(T.CompatibleUnion{selectors, options}, 1n, 0n, D.Region{n, xs}))
def compatible_union_complete(selectors, options, selector, s, v, ys, m, n, xs, size, found, prefix, child):
  +bsel = Equal.trans(U32, P.byte_at(xs, 0n), IP.at(P.slice_bytes(xs), 0n), selector,
    PK.byte_at_view(xs, 0n),
    first_byte_of(P.slice_bytes(xs), m, selector, ys, prefix))
  %size : CLeaf.parsed_as(T.Selected{selector, v}, xs, _, D.go(T.CompatibleUnion{selectors, options}, 1n, 0n, D.Region{_, xs}))
  %Equal.sym(U32, P.byte_at(xs, 0n), selector, bsel) : CLeaf.parsed_as(T.Selected{selector, v}, xs, 1n+m, D.go(options, 0n, 0n, D.PickAmong{selectors, _, m, P.adv(xs, 1n)}))
  %Equal.sym(D.Out, D.go(options, 0n, 0n, D.PickAmong{selectors, selector, m, P.adv(xs, 1n)}), D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, P.adv(xs, 1n)})), among_pick(selectors, options, selector, s, m, P.adv(xs, 1n), found)) : CLeaf.parsed_as(T.Selected{selector, v}, xs, 1n+m, _)
  shift_region(D.wrap_selected(selector, D.go(s, 1n, 0n, D.Region{m, P.adv(xs, 1n)})), xs, m, T.Selected{selector, v},
    selected_complete(D.go(s, 1n, 0n, D.Region{m, P.adv(xs, 1n)}), P.adv(xs, 1n), m, selector, v, child))

# Rewriting the remaining parts list of a walk obligation.
law walk_goal_parts:
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +ps: +List<T.Part>
  for +qs: +List<T.Part>
  for +tt: T.Schema
  for +hdr: P.Slice
  for +pay: P.Slice
  for +acc: C.CValue
  for +rest: T.Value
  for +out: D.Out
  for +same: {qs == ps : +List<T.Part>}
  for g: walk_goal(sl, end, fixedtotal, h, pos, pdone, qs, tt, hdr, pay, acc, rest, out)
  walk_goal(sl, end, fixedtotal, h, pos, pdone, ps, tt, hdr, pay, acc, rest, out)
def walk_goal_parts(sl, end, fixedtotal, h, pos, pdone, ps, qs, tt, hdr, pay, acc, rest, out, same, g):
  %same : walk_goal(sl, end, fixedtotal, h, pos, pdone, _, tt, hdr, pay, acc, rest, out)
  g

law walk_goal_seq_parts:
  for +e: T.Schema
  for +k: Nat
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +ps: +List<T.Part>
  for +qs: +List<T.Part>
  for +hdr: P.Slice
  for +pay: P.Slice
  for +acc: C.CValue
  for +rest: T.Value
  for +out: D.Out
  for +same: {qs == ps : +List<T.Part>}
  for g: walk_goal_seq(e, k, sl, end, fixedtotal, h, pos, pdone, qs, hdr, pay, acc, rest, out)
  walk_goal_seq(e, k, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc, rest, out)
def walk_goal_seq_parts(e, k, sl, end, fixedtotal, h, pos, pdone, ps, qs, hdr, pay, acc, rest, out, same, g):
  %same : walk_goal_seq(e, k, sl, end, fixedtotal, h, pos, pdone, _, hdr, pay, acc, rest, out)
  g
