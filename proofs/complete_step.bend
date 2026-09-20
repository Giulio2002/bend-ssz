import Base
import ../types/schema.bend as T
import ../src/packed.bend as P
import ../src/cvalue.bend as C
import ../src/decode.bend as D
import ../src/schema.bend as IS
import ../src/layout.bend as IL
import ../spec/codec.bend as SC
import ../spec/layout.bend as SL
import ../spec/schema.bend as SS
import ./packed.bend as PK
import ./word_facts.bend as F
import ./complete_leaves.bend as CLeaf
import ./complete_walk.bend as CWalk
import ./complete_regions.bend as CReg
import ./cursor_walk.bend as CW
import ./decode_facts.bend as FA
import ./decode_shape.bend as Shape
import ./layout.bend as LA
import ./lists.bend as L
import ./primitive_invariants.bend as V
import ./nat_order.bend as NO
import ./schema.bend as Sch
import ../spec/nat_bytes.bend as N
import ./nat_bytes.bend as Digits
import ./layout_image_headers.bend as HW

# The bytes a walk hands to its next child are exactly that child's fragment.
#
# The walk invariant says the header region from `h` holds the fixed parts of
# the remaining parts list and the payload region from `pos` holds their
# payloads. These two laws read the first child's bytes back out of those
# statements, which is what turns the walk's premises into the child's region
# premise.
law header_child_bytes:
  for +sl: P.Slice
  for +hdr: P.Slice
  for +h: Nat
  for +fixedtotal: Nat
  for +pos: Nat
  for +xs: +List<U32>
  for +ps: +List<T.Part>
  for +hdrview: {P.slice_bytes(hdr) == List.drop(&2, U32, P.slice_bytes(sl), h) : +List<U32>}
  for +remaining: {Nat.add(h, SL.fixed_size(T.Fixed{xs} <> ps)) == fixedtotal : Nat}
  for +headerrest: {List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(fixedtotal, h)) == SL.fixed_parts(T.Fixed{xs} <> ps, pos) : +List<U32>}
  {List.take(&2, U32, P.slice_bytes(hdr), List.length(&2, U32, xs)) == xs : +List<U32>}
def header_child_bytes(sl, hdr, h, fixedtotal, pos, xs, ps, hdrview, remaining, headerrest):
  +sizeeq = Equal.trans(Nat, Nat.sub(fixedtotal, h), Nat.sub(Nat.add(h, SL.fixed_size(T.Fixed{xs} <> ps)), h), SL.fixed_size(T.Fixed{xs} <> ps),
    Equal.cong(Nat, Nat, kk => Nat.sub(kk, h), fixedtotal, Nat.add(h, SL.fixed_size(T.Fixed{xs} <> ps)),
      Equal.sym(Nat, Nat.add(h, SL.fixed_size(T.Fixed{xs} <> ps)), fixedtotal, remaining)),
    CWalk.add_sub_left(h, SL.fixed_size(T.Fixed{xs} <> ps)))
  +lenparts = Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, xs, SL.fixed_parts(ps, pos))), Nat.add(List.length(&2, U32, xs), List.length(&2, U32, SL.fixed_parts(ps, pos))), Nat.sub(fixedtotal, h),
    L.append_length(U32, xs, SL.fixed_parts(ps, pos)),
    Equal.trans(Nat, Nat.add(List.length(&2, U32, xs), List.length(&2, U32, SL.fixed_parts(ps, pos))), SL.fixed_size(T.Fixed{xs} <> ps), Nat.sub(fixedtotal, h),
      Equal.cong(Nat, Nat, kk => Nat.add(List.length(&2, U32, xs), kk), List.length(&2, U32, SL.fixed_parts(ps, pos)), SL.fixed_size(ps), LA.fixed_parts_length(ps, pos)),
      Equal.sym(Nat, Nat.sub(fixedtotal, h), SL.fixed_size(T.Fixed{xs} <> ps), sizeeq)))
  CWalk.starts_head(P.slice_bytes(hdr), xs, SL.fixed_parts(ps, pos),
    Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(hdr), List.length(&2, U32, List.append(&2, U32, xs, SL.fixed_parts(ps, pos)))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(fixedtotal, h)), List.append(&2, U32, xs, SL.fixed_parts(ps, pos)),
      Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(hdr), List.length(&2, U32, List.append(&2, U32, xs, SL.fixed_parts(ps, pos)))), List.take(&2, U32, P.slice_bytes(hdr), Nat.sub(fixedtotal, h)), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(fixedtotal, h)),
        Equal.cong(Nat, +List<U32>, kk => List.take(&2, U32, P.slice_bytes(hdr), kk), List.length(&2, U32, List.append(&2, U32, xs, SL.fixed_parts(ps, pos))), Nat.sub(fixedtotal, h), lenparts),
        Equal.cong(+List<U32>, +List<U32>, ys => List.take(&2, U32, ys, Nat.sub(fixedtotal, h)), P.slice_bytes(hdr), List.drop(&2, U32, P.slice_bytes(sl), h), hdrview)),
      headerrest))

law payload_child_bytes:
  for +sl: P.Slice
  for +pay: P.Slice
  for +pos: Nat
  for +end: Nat
  for +xs: +List<U32>
  for +ps: +List<T.Part>
  for +payview: {P.slice_bytes(pay) == List.drop(&2, U32, P.slice_bytes(sl), pos) : +List<U32>}
  for +payloadend: {Nat.add(pos, List.length(&2, U32, SL.payloads(T.Variable{xs} <> ps))) == end : Nat}
  for +payloadrest: {List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), pos), Nat.sub(end, pos)) == SL.payloads(T.Variable{xs} <> ps) : +List<U32>}
  {List.take(&2, U32, P.slice_bytes(pay), List.length(&2, U32, xs)) == xs : +List<U32>}
def payload_child_bytes(sl, pay, pos, end, xs, ps, payview, payloadend, payloadrest):
  +sizeeq = Equal.trans(Nat, Nat.sub(end, pos), Nat.sub(Nat.add(pos, List.length(&2, U32, SL.payloads(T.Variable{xs} <> ps))), pos), List.length(&2, U32, SL.payloads(T.Variable{xs} <> ps)),
    Equal.cong(Nat, Nat, kk => Nat.sub(kk, pos), end, Nat.add(pos, List.length(&2, U32, SL.payloads(T.Variable{xs} <> ps))),
      Equal.sym(Nat, Nat.add(pos, List.length(&2, U32, SL.payloads(T.Variable{xs} <> ps))), end, payloadend)),
    CWalk.add_sub_left(pos, List.length(&2, U32, SL.payloads(T.Variable{xs} <> ps))))
  CWalk.starts_head(P.slice_bytes(pay), xs, SL.payloads(ps),
    Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(pay), List.length(&2, U32, List.append(&2, U32, xs, SL.payloads(ps)))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), pos), Nat.sub(end, pos)), List.append(&2, U32, xs, SL.payloads(ps)),
      Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(pay), List.length(&2, U32, List.append(&2, U32, xs, SL.payloads(ps)))), List.take(&2, U32, P.slice_bytes(pay), Nat.sub(end, pos)), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), pos), Nat.sub(end, pos)),
        Equal.cong(Nat, +List<U32>, kk => List.take(&2, U32, P.slice_bytes(pay), kk), List.length(&2, U32, List.append(&2, U32, xs, SL.payloads(ps))), Nat.sub(end, pos),
          Equal.sym(Nat, Nat.sub(end, pos), List.length(&2, U32, List.append(&2, U32, xs, SL.payloads(ps))), sizeeq)),
        Equal.cong(+List<U32>, +List<U32>, ys => List.take(&2, U32, ys, Nat.sub(end, pos)), P.slice_bytes(pay), List.drop(&2, U32, P.slice_bytes(sl), pos), payview)),
      payloadrest))

law concat_elim:
  for -G: Type
  for +a: Maybe<&2, +List<T.Part>>
  for +b: Maybe<&2, +List<T.Part>>
  for +target: +List<T.Part>
  for +known: {SC.concatenate(a, b) == Some{target} : Maybe<&2, +List<T.Part>>}
  for k: @+us: +List<T.Part> -> @+vs: +List<T.Part> -> @+ea: {a == Some{us} : Maybe<&2, +List<T.Part>>} -> @+eb: {b == Some{vs} : Maybe<&2, +List<T.Part>>} -> @+et: {List.append(&2, T.Part, us, vs) == target : +List<T.Part>} -> G
  G
def concat_elim(G, a, b, target, known, k):
  match a:
    case None{}:
      Empty.absurd(G, F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.concatenate(None{}, b), Some{target}, known)))
    case Some{us}:
      match b:
        case None{}:
          Empty.absurd(G, F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.concatenate(Some{us}, None{}), Some{target}, known)))
        case Some{vs}:
          k(us, vs, {==}, {==},
            Equal.cong(Maybe<&2, +List<T.Part>>, +List<T.Part>, CReg.parts_of, Some{List.append(&2, T.Part, us, vs)}, Some{target}, known))

# The child's region premise: its fragment is the bytes at the cursor.
law child_holds:
  for +hh: T.Schema
  for +hv: T.Value
  for +xs: +List<U32>
  for +sl: P.Slice
  for +childbytes: {CLeaf.fragment_bytes(SC.parts(hv, hh)) == xs : +List<U32>}
  for +issingle: {CReg.single_parts(SC.parts(hv, hh)) == True{} : Bool}
  for single: FA.single_result(SS.fixed_size(hh), SC.parts(hv, hh))
  for +bytes: {List.take(&2, U32, P.slice_bytes(sl), List.length(&2, U32, xs)) == xs : +List<U32>}
  CLeaf.holds(hh, hv, sl, List.length(&2, U32, xs))
def child_holds(hh, hv, xs, sl, childbytes, issingle, single, bytes):
  %Equal.sym(+List<U32>, List.take(&2, U32, P.slice_bytes(sl), List.length(&2, U32, xs)), xs, bytes) : {SC.parts(hv, hh) == Some{[SC.fragment(SS.fixed_size(hh), _)]} : Maybe<&2, +List<T.Part>>}
  Equal.trans(Maybe<&2, +List<T.Part>>, SC.parts(hv, hh), Some{[SC.fragment(SS.fixed_size(hh), CLeaf.fragment_bytes(SC.parts(hv, hh)))]}, Some{[SC.fragment(SS.fixed_size(hh), xs)]},
    CReg.single_holds(hh, SC.parts(hv, hh), single, issingle),
    Equal.cong(+List<U32>, Maybe<&2, +List<T.Part>>, us => Some{[SC.fragment(SS.fixed_size(hh), us)]}, CLeaf.fragment_bytes(SC.parts(hv, hh)), xs, childbytes))

def pred(n: Nat) -> Nat:
  match n:
    case 0n: 0n
    case 1n+p: p

law take_room:
  for +k: Nat
  for +zs: +List<U32>
  for +len: {List.length(&2, U32, List.take(&2, U32, zs, k)) == k : Nat}
  {Nat.is_le(k, List.length(&2, U32, zs)) == True{} : Bool}
def take_room(k, zs, len):
  match k:
    case 0n: NO.zero_le(List.length(&2, U32, zs))
    case 1n+q:
      match zs:
        case Nil{}:
          Empty.absurd({Nat.is_le(1n+q, List.length(&2, U32, [])) == True{} : Bool},
            F.false_true(Equal.sym(Bool, True{}, False{}, Equal.cong(Nat, Bool, kk => Nat.is_eq(kk, 0n), 0n, 1n+q, len))))
        case Con{b, t}:
          take_room(q, t, Equal.cong(Nat, Nat, pred, 1n+List.length(&2, U32, List.take(&2, U32, t, q)), 1n+q, len))

law chain_fixed_step:
  for +hh: T.Schema
  for +tt: T.Schema
  for +fixed: Bool
  for +prior: D.Out
  for +other: P.Slice
  for +acc: C.CValue
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +vs: +List<T.Part>
  for +ys: +List<U32>
  for +hdr: P.Slice
  for +pay: P.Slice
  for +acc2: C.CValue
  for +hv: T.Value
  for +tv: T.Value
  for +settled: {D.settle(prior, fixed, other, acc) == D.Settled{hdr, pay, acc2} : D.Settled}
  for +headparts: {SC.parts(hv, hh) == Some{[T.Fixed{ys}]} : Maybe<&2, +List<T.Part>>}
  for +tailparts: {SC.parts(tv, tt) == Some{vs} : Maybe<&2, +List<T.Part>>}
  for +widtheq: {SS.fixed_size(hh) == Some{List.length(&2, U32, ys)} : Maybe<&2, Nat>}
  for single: FA.single_result(SS.fixed_size(hh), SC.parts(hv, hh))
  for child: @+n: Nat -> @+xs: P.Slice ->
    @+wfx: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat} ->
    @+roomx: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool} ->
    CLeaf.holds(hh, hv, xs, n) ->
    CLeaf.parsed_as(hv, xs, n, D.go(hh, 1n, 0n, D.Region{n, xs}))
  for cont: @+v2: C.CValue -> @+crest2: P.Slice ->
    CWalk.walk_goal(sl, end, fixedtotal, Nat.add(h, List.length(&2, U32, ys)), pos, List.append(&2, T.Part, pdone, [T.Fixed{ys}]), vs, tt, crest2, pay, C.CCons{v2, acc2}, tv, D.go(tt, 0n, 0n, D.Walk{True{}, D.Parsed{v2, crest2}, pay, pos, end, acc2}))
  CWalk.walk_goal(sl, end, fixedtotal, h, pos, pdone, T.Fixed{ys} <> vs, T.Chain{hh, tt}, hdr, pay, acc2, T.Items{hv, tv}, D.go(T.Chain{hh, tt}, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc}))
def chain_fixed_step(hh, tt, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, vs, ys, hdr, pay, acc2, hv, tv, settled, headparts, tailparts, widtheq, single, child, cont):
  wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
    +hbytes = header_child_bytes(sl, hdr, h, fixedtotal, pos, ys, vs, hdrview, remaining, headerrest)
    holdsc = child_holds(hh, hv, ys, hdr,
      Equal.cong(Maybe<&2, +List<T.Part>>, +List<U32>, CLeaf.fragment_bytes, SC.parts(hv, hh), Some{[T.Fixed{ys}]}, headparts),
      Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.single_parts, SC.parts(hv, hh), Some{[T.Fixed{ys}]}, headparts),
      single, hbytes)
    +roomhdr = Equal.trans(Bool, Nat.is_le(List.length(&2, U32, ys), P.slice_size(hdr)), Nat.is_le(List.length(&2, U32, ys), List.length(&2, U32, P.slice_bytes(hdr))), True{},
      Equal.cong(Nat, Bool, kk => Nat.is_le(List.length(&2, U32, ys), kk), P.slice_size(hdr), List.length(&2, U32, P.slice_bytes(hdr)),
        Equal.sym(Nat, List.length(&2, U32, P.slice_bytes(hdr)), P.slice_size(hdr), wfhdr)),
      take_room(List.length(&2, U32, ys), P.slice_bytes(hdr),
        Equal.cong(+List<U32>, Nat, us => List.length(&2, U32, us), List.take(&2, U32, P.slice_bytes(hdr), List.length(&2, U32, ys)), ys, hbytes)))
    +widthd = Equal.trans(Maybe<&2, Nat>, IS.fixed_size(hh), SS.fixed_size(hh), Some{List.length(&2, U32, ys)}, Sch.fixed_size_correct(hh), widtheq)
    CWalk.parsed_elim(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), D.go(T.Chain{hh, tt}, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc})),
      D.go(hh, 1n, 0n, D.Region{List.length(&2, U32, ys), hdr}), hv, hdr, List.length(&2, U32, ys),
      child(List.length(&2, U32, ys), hdr, wfhdr, roomhdr, holdsc),
      cv => crest => shape => cval => crestview => cwf =>
        %Equal.sym(D.Settled, D.settle(prior, fixed, other, acc), D.Settled{hdr, pay, acc2}, settled) : CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), D.go(tt, 0n, 0n, D.plan_next(D.plan(_, IS.fixed_size(hh), pos, end, D.Later{tt}), D.go(hh, 1n, 0n, D.plan_child(D.plan(_, IS.fixed_size(hh), pos, end, D.Later{tt}))), end)))
        %Equal.sym(Maybe<&2, Nat>, IS.fixed_size(hh), Some{List.length(&2, U32, ys)}, widthd) : CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), D.go(tt, 0n, 0n, D.plan_next(D.plan(D.Settled{hdr, pay, acc2}, _, pos, end, D.Later{tt}), D.go(hh, 1n, 0n, D.plan_child(D.plan(D.Settled{hdr, pay, acc2}, _, pos, end, D.Later{tt}))), end)))
        %Equal.sym(D.Out, D.go(hh, 1n, 0n, D.Region{List.length(&2, U32, ys), hdr}), D.Parsed{cv, crest}, shape) : CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), D.go(tt, 0n, 0n, D.Walk{True{}, _, pay, pos, end, acc2}))
        CWalk.step_fixed_complete(sl, end, fixedtotal, h, List.length(&2, U32, ys), pos, pdone, vs, ys, hh, tt, hdr, crest, pay, acc2, cv, hv, tv, {==}, cval, crestview, cwf, tailparts, cont(cv, crest))(wfsl, roomsl, fitend, hdrview, wfhdr, payview, wfpay, sizedone, remaining, position, regionsize, headerrest, payloadrest, payloadend, restparts))

# The header prefix of a variable-width child: four offset bytes, then the
# offsets and inline bytes of the fields after it.
law header_variable_prefix:
  for +sl: P.Slice
  for +hdr: P.Slice
  for +h: Nat
  for +fixedtotal: Nat
  for +pos: Nat
  for +ys: +List<U32>
  for +vs: +List<T.Part>
  for +hdrview: {P.slice_bytes(hdr) == List.drop(&2, U32, P.slice_bytes(sl), h) : +List<U32>}
  for +remaining: {Nat.add(h, SL.fixed_size(T.Variable{ys} <> vs)) == fixedtotal : Nat}
  for +headerrest: {List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(fixedtotal, h)) == SL.fixed_parts(T.Variable{ys} <> vs, pos) : +List<U32>}
  {List.take(&2, U32, P.slice_bytes(hdr), List.length(&2, U32, List.append(&2, U32, N.digits(4n, pos), SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys)))))) == List.append(&2, U32, N.digits(4n, pos), SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys)))) : +List<U32>}
def header_variable_prefix(sl, hdr, h, fixedtotal, pos, ys, vs, hdrview, remaining, headerrest):
  +sizeeq = Equal.trans(Nat, Nat.sub(fixedtotal, h), Nat.sub(Nat.add(h, SL.fixed_size(T.Variable{ys} <> vs)), h), SL.fixed_size(T.Variable{ys} <> vs),
    Equal.cong(Nat, Nat, kk => Nat.sub(kk, h), fixedtotal, Nat.add(h, SL.fixed_size(T.Variable{ys} <> vs)),
      Equal.sym(Nat, Nat.add(h, SL.fixed_size(T.Variable{ys} <> vs)), fixedtotal, remaining)),
    CWalk.add_sub_left(h, SL.fixed_size(T.Variable{ys} <> vs)))
  +lenparts = Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, N.digits(4n, pos), SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys))))), Nat.add(List.length(&2, U32, N.digits(4n, pos)), List.length(&2, U32, SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys))))), Nat.sub(fixedtotal, h),
    L.append_length(U32, N.digits(4n, pos), SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys)))),
    Equal.trans(Nat, Nat.add(List.length(&2, U32, N.digits(4n, pos)), List.length(&2, U32, SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys))))), Nat.add(4n, SL.fixed_size(vs)), Nat.sub(fixedtotal, h),
      Equal.trans(Nat, Nat.add(List.length(&2, U32, N.digits(4n, pos)), List.length(&2, U32, SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys))))), Nat.add(4n, List.length(&2, U32, SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys))))), Nat.add(4n, SL.fixed_size(vs)),
        Equal.cong(Nat, Nat, kk => Nat.add(kk, List.length(&2, U32, SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys))))), List.length(&2, U32, N.digits(4n, pos)), 4n, Digits.digits_length(4n, pos)),
        Equal.cong(Nat, Nat, kk => Nat.add(4n, kk), List.length(&2, U32, SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys)))), SL.fixed_size(vs), LA.fixed_parts_length(vs, Nat.add(pos, List.length(&2, U32, ys))))),
      Equal.sym(Nat, Nat.sub(fixedtotal, h), Nat.add(4n, SL.fixed_size(vs)), sizeeq)))
  Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(hdr), List.length(&2, U32, List.append(&2, U32, N.digits(4n, pos), SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys)))))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(fixedtotal, h)), List.append(&2, U32, N.digits(4n, pos), SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys)))),
    Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(hdr), List.length(&2, U32, List.append(&2, U32, N.digits(4n, pos), SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys)))))), List.take(&2, U32, P.slice_bytes(hdr), Nat.sub(fixedtotal, h)), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(fixedtotal, h)),
      Equal.cong(Nat, +List<U32>, kk => List.take(&2, U32, P.slice_bytes(hdr), kk), List.length(&2, U32, List.append(&2, U32, N.digits(4n, pos), SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys))))), Nat.sub(fixedtotal, h), lenparts),
      Equal.cong(+List<U32>, +List<U32>, us => List.take(&2, U32, us, Nat.sub(fixedtotal, h)), P.slice_bytes(hdr), List.drop(&2, U32, P.slice_bytes(sl), h), hdrview)),
    headerrest)

law header_offset_bytes:
  for +hdr: P.Slice
  for +pos: Nat
  for +ys: +List<U32>
  for +vs: +List<T.Part>
  for +pre: {List.take(&2, U32, P.slice_bytes(hdr), List.length(&2, U32, List.append(&2, U32, N.digits(4n, pos), SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys)))))) == List.append(&2, U32, N.digits(4n, pos), SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys)))) : +List<U32>}
  {N.digits(4n, pos) == List.take(&2, U32, P.slice_bytes(hdr), 4n) : +List<U32>}
def header_offset_bytes(hdr, pos, ys, vs, pre):
  Equal.sym(+List<U32>, List.take(&2, U32, P.slice_bytes(hdr), 4n), N.digits(4n, pos),
    Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(hdr), 4n), List.take(&2, U32, P.slice_bytes(hdr), List.length(&2, U32, N.digits(4n, pos))), N.digits(4n, pos),
      Equal.cong(Nat, +List<U32>, kk => List.take(&2, U32, P.slice_bytes(hdr), kk), 4n, List.length(&2, U32, N.digits(4n, pos)),
        Equal.sym(Nat, List.length(&2, U32, N.digits(4n, pos)), 4n, Digits.digits_length(4n, pos))),
      CWalk.starts_head(P.slice_bytes(hdr), N.digits(4n, pos), SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys))), pre)))

law header_tail_starts:
  for +hdr: P.Slice
  for +pos: Nat
  for +ys: +List<U32>
  for +vs: +List<T.Part>
  for +pre: {List.take(&2, U32, P.slice_bytes(hdr), List.length(&2, U32, List.append(&2, U32, N.digits(4n, pos), SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys)))))) == List.append(&2, U32, N.digits(4n, pos), SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys)))) : +List<U32>}
  CWalk.starts_with(P.adv(hdr, 4n), SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys))))
def header_tail_starts(hdr, pos, ys, vs, pre):
  Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(P.adv(hdr, 4n)), List.length(&2, U32, SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys))))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(hdr), List.length(&2, U32, N.digits(4n, pos))), List.length(&2, U32, SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys))))), SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys))),
    Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(P.adv(hdr, 4n)), List.length(&2, U32, SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys))))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(hdr), 4n), List.length(&2, U32, SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys))))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(hdr), List.length(&2, U32, N.digits(4n, pos))), List.length(&2, U32, SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys))))),
      Equal.cong(+List<U32>, +List<U32>, us => List.take(&2, U32, us, List.length(&2, U32, SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys))))), P.slice_bytes(P.adv(hdr, 4n)), List.drop(&2, U32, P.slice_bytes(hdr), 4n), PK.adv_view(hdr, 4n)),
      Equal.cong(Nat, +List<U32>, kk => List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(hdr), kk), List.length(&2, U32, SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys))))), 4n, List.length(&2, U32, N.digits(4n, pos)),
        Equal.sym(Nat, List.length(&2, U32, N.digits(4n, pos)), 4n, Digits.digits_length(4n, pos)))),
    CWalk.starts_tail(P.slice_bytes(hdr), N.digits(4n, pos), SL.fixed_parts(vs, Nat.add(pos, List.length(&2, U32, ys))), pre))

law chain_variable_step:
  for +hh: T.Schema
  for +tt: T.Schema
  for +fixed: Bool
  for +prior: D.Out
  for +other: P.Slice
  for +acc: C.CValue
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +vs: +List<T.Part>
  for +ys: +List<U32>
  for +hdr: P.Slice
  for +pay: P.Slice
  for +acc2: C.CValue
  for +hv: T.Value
  for +tv: T.Value
  for +settled: {D.settle(prior, fixed, other, acc) == D.Settled{hdr, pay, acc2} : D.Settled}
  for +headparts: {SC.parts(hv, hh) == Some{[T.Variable{ys}]} : Maybe<&2, +List<T.Part>>}
  for +tailparts: {SC.parts(tv, tt) == Some{vs} : Maybe<&2, +List<T.Part>>}
  for +widtheq: {SS.fixed_size(hh) == None{} : Maybe<&2, Nat>}
  for +align: {HW.widths(vs) == FA.widths(tt) : +List<Maybe<&2, Nat>>}
  for single: FA.single_result(SS.fixed_size(hh), SC.parts(hv, hh))
  for child: @+n: Nat -> @+xs: P.Slice ->
    @+wfx: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat} ->
    @+roomx: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool} ->
    CLeaf.holds(hh, hv, xs, n) ->
    CLeaf.parsed_as(hv, xs, n, D.go(hh, 1n, 0n, D.Region{n, xs}))
  for cont: @+v2: C.CValue -> @+crest2: P.Slice ->
    CWalk.walk_goal(sl, end, fixedtotal, Nat.add(h, 4n), Nat.add(pos, List.length(&2, U32, ys)), List.append(&2, T.Part, pdone, [T.Variable{ys}]), vs, tt, P.adv(hdr, 4n), crest2, C.CCons{v2, acc2}, tv, D.go(tt, 0n, 0n, D.Walk{False{}, D.Parsed{v2, crest2}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, ys)), end, acc2}))
  CWalk.walk_goal(sl, end, fixedtotal, h, pos, pdone, T.Variable{ys} <> vs, T.Chain{hh, tt}, hdr, pay, acc2, T.Items{hv, tv}, D.go(T.Chain{hh, tt}, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc}))
def chain_variable_step(hh, tt, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, vs, ys, hdr, pay, acc2, hv, tv, settled, headparts, tailparts, widtheq, align, single, child, cont):
  wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
    +payend2 = Equal.trans(Nat, Nat.add(Nat.add(pos, List.length(&2, U32, ys)), List.length(&2, U32, SL.payloads(vs))), Nat.add(pos, Nat.add(List.length(&2, U32, ys), List.length(&2, U32, SL.payloads(vs)))), end,
      LA.add_associative(pos, List.length(&2, U32, ys), List.length(&2, U32, SL.payloads(vs))),
      Equal.trans(Nat, Nat.add(pos, Nat.add(List.length(&2, U32, ys), List.length(&2, U32, SL.payloads(vs)))), Nat.add(pos, List.length(&2, U32, SL.payloads(T.Variable{ys} <> vs))), end,
        Equal.cong(Nat, Nat, kk => Nat.add(pos, kk), Nat.add(List.length(&2, U32, ys), List.length(&2, U32, SL.payloads(vs))), List.length(&2, U32, SL.payloads(T.Variable{ys} <> vs)),
          Equal.sym(Nat, List.length(&2, U32, SL.payloads(T.Variable{ys} <> vs)), Nat.add(List.length(&2, U32, ys), List.length(&2, U32, SL.payloads(vs))), L.append_length(U32, ys, SL.payloads(vs)))),
        payloadend))
    +posle = Equal.trans(Bool, Nat.is_le(pos, end), Nat.is_le(pos, Nat.add(pos, List.length(&2, U32, SL.payloads(T.Variable{ys} <> vs)))), True{},
      Equal.cong(Nat, Bool, kk => Nat.is_le(pos, kk), end, Nat.add(pos, List.length(&2, U32, SL.payloads(T.Variable{ys} <> vs))),
        Equal.sym(Nat, Nat.add(pos, List.length(&2, U32, SL.payloads(T.Variable{ys} <> vs))), end, payloadend)),
      NO.below_sum(pos, List.length(&2, U32, SL.payloads(T.Variable{ys} <> vs))))
    +posle2 = Equal.trans(Bool, Nat.is_le(Nat.add(pos, List.length(&2, U32, ys)), end), Nat.is_le(Nat.add(pos, List.length(&2, U32, ys)), Nat.add(Nat.add(pos, List.length(&2, U32, ys)), List.length(&2, U32, SL.payloads(vs)))), True{},
      Equal.cong(Nat, Bool, kk => Nat.is_le(Nat.add(pos, List.length(&2, U32, ys)), kk), end, Nat.add(Nat.add(pos, List.length(&2, U32, ys)), List.length(&2, U32, SL.payloads(vs))),
        Equal.sym(Nat, Nat.add(Nat.add(pos, List.length(&2, U32, ys)), List.length(&2, U32, SL.payloads(vs))), end, payend2)),
      NO.below_sum(Nat.add(pos, List.length(&2, U32, ys)), List.length(&2, U32, SL.payloads(vs))))
    +hpre = header_variable_prefix(sl, hdr, h, fixedtotal, pos, ys, vs, hdrview, remaining, headerrest)
    +offsetok = CWalk.offset_here(hdr, pos, Digits.fits_monotone(4n, pos, end, posle, fitend), header_offset_bytes(hdr, pos, ys, vs, hpre))
    +stopok = Equal.trans(Nat, D.or_end(D.ahead(D.Later{tt}, P.adv(hdr, 4n)), end), D.or_end(CWalk.first_offset(vs, Nat.add(pos, List.length(&2, U32, ys))), end), Nat.add(pos, List.length(&2, U32, ys)),
      Equal.cong(Maybe<&2, Nat>, Nat, r => D.or_end(r, end), D.next_offset(tt, P.adv(hdr, 4n)), CWalk.first_offset(vs, Nat.add(pos, List.length(&2, U32, ys))),
        CWalk.next_offset_value(vs, tt, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, ys)),
          Digits.fits_monotone(4n, Nat.add(pos, List.length(&2, U32, ys)), end, posle2, fitend),
          align,
          header_tail_starts(hdr, pos, ys, vs, hpre))),
      CWalk.stop_at(CWalk.first_offset(vs, Nat.add(pos, List.length(&2, U32, ys))), vs, Nat.add(pos, List.length(&2, U32, ys)), end, {==}, payend2))
    +planeq = CWalk.variable_plan(hdr, pay, acc2, tt, pos, end, ys, offsetok, stopok, posle2)
    +pbytes = payload_child_bytes(sl, pay, pos, end, ys, vs, payview, payloadend, payloadrest)
    holdsc = child_holds(hh, hv, ys, pay,
      Equal.cong(Maybe<&2, +List<T.Part>>, +List<U32>, CLeaf.fragment_bytes, SC.parts(hv, hh), Some{[T.Variable{ys}]}, headparts),
      Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.single_parts, SC.parts(hv, hh), Some{[T.Variable{ys}]}, headparts),
      single, pbytes)
    +roompay = Equal.trans(Bool, Nat.is_le(List.length(&2, U32, ys), P.slice_size(pay)), Nat.is_le(List.length(&2, U32, ys), List.length(&2, U32, P.slice_bytes(pay))), True{},
      Equal.cong(Nat, Bool, kk => Nat.is_le(List.length(&2, U32, ys), kk), P.slice_size(pay), List.length(&2, U32, P.slice_bytes(pay)),
        Equal.sym(Nat, List.length(&2, U32, P.slice_bytes(pay)), P.slice_size(pay), wfpay)),
      take_room(List.length(&2, U32, ys), P.slice_bytes(pay),
        Equal.cong(+List<U32>, Nat, us => List.length(&2, U32, us), List.take(&2, U32, P.slice_bytes(pay), List.length(&2, U32, ys)), ys, pbytes)))
    +widthd = Equal.trans(Maybe<&2, Nat>, IS.fixed_size(hh), SS.fixed_size(hh), None{}, Sch.fixed_size_correct(hh), widtheq)
    CWalk.parsed_elim(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), D.go(T.Chain{hh, tt}, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc})),
      D.go(hh, 1n, 0n, D.Region{List.length(&2, U32, ys), pay}), hv, pay, List.length(&2, U32, ys),
      child(List.length(&2, U32, ys), pay, wfpay, roompay, holdsc),
      cv => crest => shape => cval => crestview => cwf =>
        %Equal.sym(D.Settled, D.settle(prior, fixed, other, acc), D.Settled{hdr, pay, acc2}, settled) : CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), D.go(tt, 0n, 0n, D.plan_next(D.plan(_, IS.fixed_size(hh), pos, end, D.Later{tt}), D.go(hh, 1n, 0n, D.plan_child(D.plan(_, IS.fixed_size(hh), pos, end, D.Later{tt}))), end)))
        %Equal.sym(Maybe<&2, Nat>, IS.fixed_size(hh), None{}, widthd) : CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), D.go(tt, 0n, 0n, D.plan_next(D.plan(D.Settled{hdr, pay, acc2}, _, pos, end, D.Later{tt}), D.go(hh, 1n, 0n, D.plan_child(D.plan(D.Settled{hdr, pay, acc2}, _, pos, end, D.Later{tt}))), end)))
        %Equal.sym(D.Plan, D.plan(D.Settled{hdr, pay, acc2}, None{}, pos, end, D.Later{tt}), D.Plan{D.Region{List.length(&2, U32, ys), pay}, False{}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, ys)), acc2}, planeq) : CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), D.go(tt, 0n, 0n, D.plan_next(_, D.go(hh, 1n, 0n, D.plan_child(_)), end)))
        %Equal.sym(D.Out, D.go(hh, 1n, 0n, D.Region{List.length(&2, U32, ys), pay}), D.Parsed{cv, crest}, shape) : CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), D.go(tt, 0n, 0n, D.Walk{False{}, _, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, ys)), end, acc2}))
        CWalk.step_variable_complete(sl, end, fixedtotal, h, pos, pdone, vs, ys, hh, tt, hdr, crest, pay, acc2, cv, hv, tv, cval, crestview, cwf, tailparts, cont(cv, crest))(wfsl, roomsl, fitend, hdrview, wfhdr, payview, wfpay, sizedone, remaining, position, regionsize, headerrest, payloadrest, payloadend, restparts))

# The same two steps for a sequence walk, where the remaining element count
# replaces the remaining field forest. `unfold` is the decoder's own step for
# the three sequence schemas, supplied as `{==}` at each of them.
law seq_fixed_step:
  for +schema: T.Schema
  for +e: T.Schema
  for +p: Nat
  for +fixed: Bool
  for +prior: D.Out
  for +other: P.Slice
  for +acc: C.CValue
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +vs: +List<T.Part>
  for +ys: +List<U32>
  for +hdr: P.Slice
  for +pay: P.Slice
  for +acc2: C.CValue
  for +hv: T.Value
  for +tv: T.Value
  for +unfold: {D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc}) == D.go(schema, 0n, p, D.plan_next(D.plan(D.settle(prior, fixed, other, acc), IS.fixed_size(e), pos, end, D.Remaining{p}), D.go(e, 1n, 0n, D.plan_child(D.plan(D.settle(prior, fixed, other, acc), IS.fixed_size(e), pos, end, D.Remaining{p}))), end)) : D.Out}
  for +settled: {D.settle(prior, fixed, other, acc) == D.Settled{hdr, pay, acc2} : D.Settled}
  for +headparts: {SC.parts(hv, e) == Some{[T.Fixed{ys}]} : Maybe<&2, +List<T.Part>>}
  for +tailparts: {SC.parts(tv, T.Repeat{e}) == Some{vs} : Maybe<&2, +List<T.Part>>}
  for +tailcount: {SC.count(tv) == p : Nat}
  for +widtheq: {SS.fixed_size(e) == Some{List.length(&2, U32, ys)} : Maybe<&2, Nat>}
  for single: FA.single_result(SS.fixed_size(e), SC.parts(hv, e))
  for child: @+n: Nat -> @+xs: P.Slice ->
    @+wfx: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat} ->
    @+roomx: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool} ->
    CLeaf.holds(e, hv, xs, n) ->
    CLeaf.parsed_as(hv, xs, n, D.go(e, 1n, 0n, D.Region{n, xs}))
  for cont: @+v2: C.CValue -> @+crest2: P.Slice ->
    CWalk.walk_goal_seq(e, p, sl, end, fixedtotal, Nat.add(h, List.length(&2, U32, ys)), pos, List.append(&2, T.Part, pdone, [T.Fixed{ys}]), vs, crest2, pay, C.CCons{v2, acc2}, tv, D.go(schema, 0n, p, D.Walk{True{}, D.Parsed{v2, crest2}, pay, pos, end, acc2}))
  CWalk.walk_goal_seq(e, 1n+p, sl, end, fixedtotal, h, pos, pdone, T.Fixed{ys} <> vs, hdr, pay, acc2, T.Items{hv, tv}, D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc}))
def seq_fixed_step(schema, e, p, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, vs, ys, hdr, pay, acc2, hv, tv, unfold, settled, headparts, tailparts, tailcount, widtheq, single, child, cont):
  wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
    +hbytes = header_child_bytes(sl, hdr, h, fixedtotal, pos, ys, vs, hdrview, remaining, headerrest)
    holdsc = child_holds(e, hv, ys, hdr,
      Equal.cong(Maybe<&2, +List<T.Part>>, +List<U32>, CLeaf.fragment_bytes, SC.parts(hv, e), Some{[T.Fixed{ys}]}, headparts),
      Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.single_parts, SC.parts(hv, e), Some{[T.Fixed{ys}]}, headparts),
      single, hbytes)
    +roomhdr = Equal.trans(Bool, Nat.is_le(List.length(&2, U32, ys), P.slice_size(hdr)), Nat.is_le(List.length(&2, U32, ys), List.length(&2, U32, P.slice_bytes(hdr))), True{},
      Equal.cong(Nat, Bool, kk => Nat.is_le(List.length(&2, U32, ys), kk), P.slice_size(hdr), List.length(&2, U32, P.slice_bytes(hdr)),
        Equal.sym(Nat, List.length(&2, U32, P.slice_bytes(hdr)), P.slice_size(hdr), wfhdr)),
      take_room(List.length(&2, U32, ys), P.slice_bytes(hdr),
        Equal.cong(+List<U32>, Nat, us => List.length(&2, U32, us), List.take(&2, U32, P.slice_bytes(hdr), List.length(&2, U32, ys)), ys, hbytes)))
    +widthd = Equal.trans(Maybe<&2, Nat>, IS.fixed_size(e), SS.fixed_size(e), Some{List.length(&2, U32, ys)}, Sch.fixed_size_correct(e), widtheq)
    CWalk.parsed_elim(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc})),
      D.go(e, 1n, 0n, D.Region{List.length(&2, U32, ys), hdr}), hv, hdr, List.length(&2, U32, ys),
      child(List.length(&2, U32, ys), hdr, wfhdr, roomhdr, holdsc),
      cv => crest => shape => cval => crestview => cwf =>
        %Equal.sym(D.Out, D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc}), D.go(schema, 0n, p, D.plan_next(D.plan(D.settle(prior, fixed, other, acc), IS.fixed_size(e), pos, end, D.Remaining{p}), D.go(e, 1n, 0n, D.plan_child(D.plan(D.settle(prior, fixed, other, acc), IS.fixed_size(e), pos, end, D.Remaining{p}))), end)), unfold) : CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), _)
        %Equal.sym(D.Settled, D.settle(prior, fixed, other, acc), D.Settled{hdr, pay, acc2}, settled) : CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), D.go(schema, 0n, p, D.plan_next(D.plan(_, IS.fixed_size(e), pos, end, D.Remaining{p}), D.go(e, 1n, 0n, D.plan_child(D.plan(_, IS.fixed_size(e), pos, end, D.Remaining{p}))), end)))
        %Equal.sym(Maybe<&2, Nat>, IS.fixed_size(e), Some{List.length(&2, U32, ys)}, widthd) : CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), D.go(schema, 0n, p, D.plan_next(D.plan(D.Settled{hdr, pay, acc2}, _, pos, end, D.Remaining{p}), D.go(e, 1n, 0n, D.plan_child(D.plan(D.Settled{hdr, pay, acc2}, _, pos, end, D.Remaining{p}))), end)))
        %Equal.sym(D.Out, D.go(e, 1n, 0n, D.Region{List.length(&2, U32, ys), hdr}), D.Parsed{cv, crest}, shape) : CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), D.go(schema, 0n, p, D.Walk{True{}, _, pay, pos, end, acc2}))
        CWalk.step_fixed_seq_complete(schema, e, p, sl, end, fixedtotal, h, List.length(&2, U32, ys), pos, pdone, vs, ys, hdr, crest, pay, acc2, cv, hv, tv, {==}, cval, crestview, cwf, tailparts, tailcount, cont(cv, crest))(wfsl, roomsl, fitend, hdrview, wfhdr, payview, wfpay, sizedone, remaining, position, regionsize, headerrest, payloadrest, payloadend, restparts, countok))

law variable_plan_at:
  for +hdr: P.Slice
  for +pay: P.Slice
  for +acc: C.CValue
  for +a: D.Ahead
  for +pos: Nat
  for +end: Nat
  for +xs: +List<U32>
  for +offsetok: {P.offset_at(hdr) == pos : Nat}
  for +stopok: {D.or_end(D.ahead(a, P.adv(hdr, 4n)), end) == Nat.add(pos, List.length(&2, U32, xs)) : Nat}
  for +fits_end: {Nat.is_le(Nat.add(pos, List.length(&2, U32, xs)), end) == True{} : Bool}
  {D.plan(D.Settled{hdr, pay, acc}, None{}, pos, end, a) == D.Plan{D.Region{List.length(&2, U32, xs), pay}, False{}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, xs)), acc} : D.Plan}
def variable_plan_at(hdr, pay, acc, a, pos, end, xs, offsetok, stopok, fits_end):
  %Equal.sym(Nat, P.offset_at(hdr), pos, offsetok) : {D.Plan{D.region_if(Bool.and(D.nat_eq(_, pos), Bool.and(D.nat_le(_, D.or_end(D.ahead(a, P.adv(hdr, 4n)), end)), D.nat_le(D.or_end(D.ahead(a, P.adv(hdr, 4n)), end), end))), Nat.sub(D.or_end(D.ahead(a, P.adv(hdr, 4n)), end), _), pay), False{}, P.adv(hdr, 4n), D.or_end(D.ahead(a, P.adv(hdr, 4n)), end), acc} == D.Plan{D.Region{List.length(&2, U32, xs), pay}, False{}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, xs)), acc} : D.Plan}
  %Equal.sym(Nat, D.or_end(D.ahead(a, P.adv(hdr, 4n)), end), Nat.add(pos, List.length(&2, U32, xs)), stopok) : {D.Plan{D.region_if(Bool.and(D.nat_eq(pos, pos), Bool.and(D.nat_le(pos, _), D.nat_le(_, end))), Nat.sub(_, pos), pay), False{}, P.adv(hdr, 4n), _, acc} == D.Plan{D.Region{List.length(&2, U32, xs), pay}, False{}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, xs)), acc} : D.Plan}
  %Equal.sym(Bool, Bool.and(D.nat_eq(pos, pos), Bool.and(D.nat_le(pos, Nat.add(pos, List.length(&2, U32, xs))), D.nat_le(Nat.add(pos, List.length(&2, U32, xs)), end))), True{},
    V.and_true(D.nat_eq(pos, pos), Bool.and(D.nat_le(pos, Nat.add(pos, List.length(&2, U32, xs))), D.nat_le(Nat.add(pos, List.length(&2, U32, xs)), end)),
      CLeaf.nat_eq_refl(pos),
      V.and_true(D.nat_le(pos, Nat.add(pos, List.length(&2, U32, xs))), D.nat_le(Nat.add(pos, List.length(&2, U32, xs)), end),
        CLeaf.nat_le_true(pos, Nat.add(pos, List.length(&2, U32, xs)), NO.below_sum(pos, List.length(&2, U32, xs))),
        CLeaf.nat_le_true(Nat.add(pos, List.length(&2, U32, xs)), end, fits_end)))) : {D.Plan{D.region_if(_, Nat.sub(Nat.add(pos, List.length(&2, U32, xs)), pos), pay), False{}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, xs)), acc} == D.Plan{D.Region{List.length(&2, U32, xs), pay}, False{}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, xs)), acc} : D.Plan}
  %Equal.sym(Nat, Nat.sub(Nat.add(pos, List.length(&2, U32, xs)), pos), List.length(&2, U32, xs), CWalk.add_sub_left(pos, List.length(&2, U32, xs))) : {D.Plan{D.Region{_, pay}, False{}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, xs)), acc} == D.Plan{D.Region{List.length(&2, U32, xs), pay}, False{}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, xs)), acc} : D.Plan}
  {==}

law seq_next_offset:
  for +p: Nat
  for +vs: +List<T.Part>
  for +more: P.Slice
  for +pos: Nat
  for +fit: {N.fits(4n, pos) == True{} : Bool}
  for +align: {HW.widths(vs) == List.replicate(Maybe<&2, Nat>, p, None{}) : +List<Maybe<&2, Nat>>}
  for pre: CWalk.starts_with(more, SL.fixed_parts(vs, pos))
  {D.ahead(D.Remaining{p}, more) == CWalk.first_offset(vs, pos) : Maybe<&2, Nat>}
def seq_next_offset(p, vs, more, pos, fit, align, pre):
  match p:
    case 0n:
      match vs:
        case Nil{}: {==}
        case Con{T.Fixed{y}, t}:
          Empty.absurd({D.ahead(D.Remaining{0n}, more) == CWalk.first_offset(T.Fixed{y} <> t, pos) : Maybe<&2, Nat>},
            F.false_true(Equal.sym(Bool, True{}, False{},
              Equal.cong(+List<Maybe<&2, Nat>>, Bool, CWalk.is_cons_w, HW.widths(T.Fixed{y} <> t), List.replicate(Maybe<&2, Nat>, 0n, None{}), align))))
        case Con{T.Variable{y}, t}:
          Empty.absurd({D.ahead(D.Remaining{0n}, more) == CWalk.first_offset(T.Variable{y} <> t, pos) : Maybe<&2, Nat>},
            F.false_true(Equal.sym(Bool, True{}, False{},
              Equal.cong(+List<Maybe<&2, Nat>>, Bool, CWalk.is_cons_w, HW.widths(T.Variable{y} <> t), List.replicate(Maybe<&2, Nat>, 0n, None{}), align))))
    case 1n+q:
      match vs:
        case Nil{}:
          Empty.absurd({D.ahead(D.Remaining{1n+q}, more) == CWalk.first_offset([], pos) : Maybe<&2, Nat>},
            F.false_true(Equal.cong(+List<Maybe<&2, Nat>>, Bool, CWalk.is_cons_w, HW.widths([]), List.replicate(Maybe<&2, Nat>, 1n+q, None{}), align)))
        case Con{T.Fixed{y}, t}:
          Empty.absurd({D.ahead(D.Remaining{1n+q}, more) == CWalk.first_offset(T.Fixed{y} <> t, pos) : Maybe<&2, Nat>},
            F.false_true(Equal.sym(Bool, True{}, False{},
              Equal.cong(Maybe<&2, Nat>, Bool, CLeaf.is_some_nat, Some{List.length(&2, U32, y)}, None{},
                Equal.cong(+List<Maybe<&2, Nat>>, Maybe<&2, Nat>, CWalk.head_w, HW.widths(T.Fixed{y} <> t), List.replicate(Maybe<&2, Nat>, 1n+q, None{}), align)))))
        case Con{T.Variable{y}, t}:
          Equal.cong(Nat, Maybe<&2, Nat>, kk => Some{kk}, P.offset_at(more), pos,
            CWalk.offset_here(more, pos, fit,
              Equal.trans(+List<U32>, N.digits(4n, pos), List.take(&2, U32, P.slice_bytes(more), List.length(&2, U32, N.digits(4n, pos))), List.take(&2, U32, P.slice_bytes(more), 4n),
                Equal.sym(+List<U32>, List.take(&2, U32, P.slice_bytes(more), List.length(&2, U32, N.digits(4n, pos))), N.digits(4n, pos),
                  CWalk.starts_head(P.slice_bytes(more), N.digits(4n, pos), SL.fixed_parts(t, Nat.add(pos, List.length(&2, U32, y))), pre)),
                Equal.cong(Nat, +List<U32>, kk => List.take(&2, U32, P.slice_bytes(more), kk), List.length(&2, U32, N.digits(4n, pos)), 4n, Digits.digits_length(4n, pos)))))

law seq_variable_step:
  for +schema: T.Schema
  for +e: T.Schema
  for +p: Nat
  for +fixed: Bool
  for +prior: D.Out
  for +other: P.Slice
  for +acc: C.CValue
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +vs: +List<T.Part>
  for +ys: +List<U32>
  for +hdr: P.Slice
  for +pay: P.Slice
  for +acc2: C.CValue
  for +hv: T.Value
  for +tv: T.Value
  for +unfold: {D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc}) == D.go(schema, 0n, p, D.plan_next(D.plan(D.settle(prior, fixed, other, acc), IS.fixed_size(e), pos, end, D.Remaining{p}), D.go(e, 1n, 0n, D.plan_child(D.plan(D.settle(prior, fixed, other, acc), IS.fixed_size(e), pos, end, D.Remaining{p}))), end)) : D.Out}
  for +settled: {D.settle(prior, fixed, other, acc) == D.Settled{hdr, pay, acc2} : D.Settled}
  for +headparts: {SC.parts(hv, e) == Some{[T.Variable{ys}]} : Maybe<&2, +List<T.Part>>}
  for +tailparts: {SC.parts(tv, T.Repeat{e}) == Some{vs} : Maybe<&2, +List<T.Part>>}
  for +tailcount: {SC.count(tv) == p : Nat}
  for +widtheq: {SS.fixed_size(e) == None{} : Maybe<&2, Nat>}
  for +align: {HW.widths(vs) == List.replicate(Maybe<&2, Nat>, p, None{}) : +List<Maybe<&2, Nat>>}
  for single: FA.single_result(SS.fixed_size(e), SC.parts(hv, e))
  for child: @+n: Nat -> @+xs: P.Slice ->
    @+wfx: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat} ->
    @+roomx: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool} ->
    CLeaf.holds(e, hv, xs, n) ->
    CLeaf.parsed_as(hv, xs, n, D.go(e, 1n, 0n, D.Region{n, xs}))
  for cont: @+v2: C.CValue -> @+crest2: P.Slice ->
    CWalk.walk_goal_seq(e, p, sl, end, fixedtotal, Nat.add(h, 4n), Nat.add(pos, List.length(&2, U32, ys)), List.append(&2, T.Part, pdone, [T.Variable{ys}]), vs, P.adv(hdr, 4n), crest2, C.CCons{v2, acc2}, tv, D.go(schema, 0n, p, D.Walk{False{}, D.Parsed{v2, crest2}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, ys)), end, acc2}))
  CWalk.walk_goal_seq(e, 1n+p, sl, end, fixedtotal, h, pos, pdone, T.Variable{ys} <> vs, hdr, pay, acc2, T.Items{hv, tv}, D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc}))
def seq_variable_step(schema, e, p, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, vs, ys, hdr, pay, acc2, hv, tv, unfold, settled, headparts, tailparts, tailcount, widtheq, align, single, child, cont):
  wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
    +payend2 = Equal.trans(Nat, Nat.add(Nat.add(pos, List.length(&2, U32, ys)), List.length(&2, U32, SL.payloads(vs))), Nat.add(pos, Nat.add(List.length(&2, U32, ys), List.length(&2, U32, SL.payloads(vs)))), end,
      LA.add_associative(pos, List.length(&2, U32, ys), List.length(&2, U32, SL.payloads(vs))),
      Equal.trans(Nat, Nat.add(pos, Nat.add(List.length(&2, U32, ys), List.length(&2, U32, SL.payloads(vs)))), Nat.add(pos, List.length(&2, U32, SL.payloads(T.Variable{ys} <> vs))), end,
        Equal.cong(Nat, Nat, kk => Nat.add(pos, kk), Nat.add(List.length(&2, U32, ys), List.length(&2, U32, SL.payloads(vs))), List.length(&2, U32, SL.payloads(T.Variable{ys} <> vs)),
          Equal.sym(Nat, List.length(&2, U32, SL.payloads(T.Variable{ys} <> vs)), Nat.add(List.length(&2, U32, ys), List.length(&2, U32, SL.payloads(vs))), L.append_length(U32, ys, SL.payloads(vs)))),
        payloadend))
    +posle = Equal.trans(Bool, Nat.is_le(pos, end), Nat.is_le(pos, Nat.add(pos, List.length(&2, U32, SL.payloads(T.Variable{ys} <> vs)))), True{},
      Equal.cong(Nat, Bool, kk => Nat.is_le(pos, kk), end, Nat.add(pos, List.length(&2, U32, SL.payloads(T.Variable{ys} <> vs))),
        Equal.sym(Nat, Nat.add(pos, List.length(&2, U32, SL.payloads(T.Variable{ys} <> vs))), end, payloadend)),
      NO.below_sum(pos, List.length(&2, U32, SL.payloads(T.Variable{ys} <> vs))))
    +posle2 = Equal.trans(Bool, Nat.is_le(Nat.add(pos, List.length(&2, U32, ys)), end), Nat.is_le(Nat.add(pos, List.length(&2, U32, ys)), Nat.add(Nat.add(pos, List.length(&2, U32, ys)), List.length(&2, U32, SL.payloads(vs)))), True{},
      Equal.cong(Nat, Bool, kk => Nat.is_le(Nat.add(pos, List.length(&2, U32, ys)), kk), end, Nat.add(Nat.add(pos, List.length(&2, U32, ys)), List.length(&2, U32, SL.payloads(vs))),
        Equal.sym(Nat, Nat.add(Nat.add(pos, List.length(&2, U32, ys)), List.length(&2, U32, SL.payloads(vs))), end, payend2)),
      NO.below_sum(Nat.add(pos, List.length(&2, U32, ys)), List.length(&2, U32, SL.payloads(vs))))
    +hpre = header_variable_prefix(sl, hdr, h, fixedtotal, pos, ys, vs, hdrview, remaining, headerrest)
    +offsetok = CWalk.offset_here(hdr, pos, Digits.fits_monotone(4n, pos, end, posle, fitend), header_offset_bytes(hdr, pos, ys, vs, hpre))
    +stopok = Equal.trans(Nat, D.or_end(D.ahead(D.Remaining{p}, P.adv(hdr, 4n)), end), D.or_end(CWalk.first_offset(vs, Nat.add(pos, List.length(&2, U32, ys))), end), Nat.add(pos, List.length(&2, U32, ys)),
      Equal.cong(Maybe<&2, Nat>, Nat, r => D.or_end(r, end), D.ahead(D.Remaining{p}, P.adv(hdr, 4n)), CWalk.first_offset(vs, Nat.add(pos, List.length(&2, U32, ys))),
        seq_next_offset(p, vs, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, ys)),
          Digits.fits_monotone(4n, Nat.add(pos, List.length(&2, U32, ys)), end, posle2, fitend),
          align,
          header_tail_starts(hdr, pos, ys, vs, hpre))),
      CWalk.stop_at(CWalk.first_offset(vs, Nat.add(pos, List.length(&2, U32, ys))), vs, Nat.add(pos, List.length(&2, U32, ys)), end, {==}, payend2))
    +planeq = variable_plan_at(hdr, pay, acc2, D.Remaining{p}, pos, end, ys, offsetok, stopok, posle2)
    +pbytes = payload_child_bytes(sl, pay, pos, end, ys, vs, payview, payloadend, payloadrest)
    holdsc = child_holds(e, hv, ys, pay,
      Equal.cong(Maybe<&2, +List<T.Part>>, +List<U32>, CLeaf.fragment_bytes, SC.parts(hv, e), Some{[T.Variable{ys}]}, headparts),
      Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.single_parts, SC.parts(hv, e), Some{[T.Variable{ys}]}, headparts),
      single, pbytes)
    +roompay = Equal.trans(Bool, Nat.is_le(List.length(&2, U32, ys), P.slice_size(pay)), Nat.is_le(List.length(&2, U32, ys), List.length(&2, U32, P.slice_bytes(pay))), True{},
      Equal.cong(Nat, Bool, kk => Nat.is_le(List.length(&2, U32, ys), kk), P.slice_size(pay), List.length(&2, U32, P.slice_bytes(pay)),
        Equal.sym(Nat, List.length(&2, U32, P.slice_bytes(pay)), P.slice_size(pay), wfpay)),
      take_room(List.length(&2, U32, ys), P.slice_bytes(pay),
        Equal.cong(+List<U32>, Nat, us => List.length(&2, U32, us), List.take(&2, U32, P.slice_bytes(pay), List.length(&2, U32, ys)), ys, pbytes)))
    +widthd = Equal.trans(Maybe<&2, Nat>, IS.fixed_size(e), SS.fixed_size(e), None{}, Sch.fixed_size_correct(e), widtheq)
    CWalk.parsed_elim(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc})),
      D.go(e, 1n, 0n, D.Region{List.length(&2, U32, ys), pay}), hv, pay, List.length(&2, U32, ys),
      child(List.length(&2, U32, ys), pay, wfpay, roompay, holdsc),
      cv => crest => shape => cval => crestview => cwf =>
        %Equal.sym(D.Out, D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc}), D.go(schema, 0n, p, D.plan_next(D.plan(D.settle(prior, fixed, other, acc), IS.fixed_size(e), pos, end, D.Remaining{p}), D.go(e, 1n, 0n, D.plan_child(D.plan(D.settle(prior, fixed, other, acc), IS.fixed_size(e), pos, end, D.Remaining{p}))), end)), unfold) : CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), _)
        %Equal.sym(D.Settled, D.settle(prior, fixed, other, acc), D.Settled{hdr, pay, acc2}, settled) : CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), D.go(schema, 0n, p, D.plan_next(D.plan(_, IS.fixed_size(e), pos, end, D.Remaining{p}), D.go(e, 1n, 0n, D.plan_child(D.plan(_, IS.fixed_size(e), pos, end, D.Remaining{p}))), end)))
        %Equal.sym(Maybe<&2, Nat>, IS.fixed_size(e), None{}, widthd) : CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), D.go(schema, 0n, p, D.plan_next(D.plan(D.Settled{hdr, pay, acc2}, _, pos, end, D.Remaining{p}), D.go(e, 1n, 0n, D.plan_child(D.plan(D.Settled{hdr, pay, acc2}, _, pos, end, D.Remaining{p}))), end)))
        %Equal.sym(D.Plan, D.plan(D.Settled{hdr, pay, acc2}, None{}, pos, end, D.Remaining{p}), D.Plan{D.Region{List.length(&2, U32, ys), pay}, False{}, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, ys)), acc2}, planeq) : CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), D.go(schema, 0n, p, D.plan_next(_, D.go(e, 1n, 0n, D.plan_child(_)), end)))
        %Equal.sym(D.Out, D.go(e, 1n, 0n, D.Region{List.length(&2, U32, ys), pay}), D.Parsed{cv, crest}, shape) : CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), D.go(schema, 0n, p, D.Walk{False{}, _, P.adv(hdr, 4n), Nat.add(pos, List.length(&2, U32, ys)), end, acc2}))
        CWalk.step_variable_seq_complete(schema, e, p, sl, end, fixedtotal, h, pos, pdone, vs, ys, hdr, crest, pay, acc2, cv, hv, tv, cval, crestview, cwf, tailparts, tailcount, cont(cv, crest))(wfsl, roomsl, fitend, hdrview, wfhdr, payview, wfpay, sizedone, remaining, position, regionsize, headerrest, payloadrest, payloadend, restparts, countok))

# One field step, dispatched on the kind of the first remaining fragment.
law chain_step_dispatch:
  for +hh: T.Schema
  for +tt: T.Schema
  for +fixed: Bool
  for +prior: D.Out
  for +other: P.Slice
  for +acc: C.CValue
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +ps: +List<T.Part>
  for +us: +List<T.Part>
  for +vs: +List<T.Part>
  for +hdr: P.Slice
  for +pay: P.Slice
  for +acc2: C.CValue
  for +hv: T.Value
  for +tv: T.Value
  for +f: CReg.FragShape
  for ok: CReg.shape_ok(SS.fixed_size(hh), us, f)
  for +settled: {D.settle(prior, fixed, other, acc) == D.Settled{hdr, pay, acc2} : D.Settled}
  for +ea: {SC.parts(hv, hh) == Some{us} : Maybe<&2, +List<T.Part>>}
  for +eb: {SC.parts(tv, tt) == Some{vs} : Maybe<&2, +List<T.Part>>}
  for +et: {List.append(&2, T.Part, us, vs) == ps : +List<T.Part>}
  for +talign: {HW.widths(vs) == FA.widths(tt) : +List<Maybe<&2, Nat>>}
  for single: FA.single_result(SS.fixed_size(hh), SC.parts(hv, hh))
  for child: @+n: Nat -> @+xs: P.Slice ->
    @+wfx: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat} ->
    @+roomx: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool} ->
    CLeaf.holds(hh, hv, xs, n) ->
    CLeaf.parsed_as(hv, xs, n, D.go(hh, 1n, 0n, D.Region{n, xs}))
  for cont: @+h2: Nat -> @+pos2: Nat -> @+pdone2: +List<T.Part> -> @+hdr2: P.Slice -> @+pay2: P.Slice -> @+acc3: C.CValue -> @+fixed2: Bool -> @+prior2: D.Out -> @+other2: P.Slice ->
    @+settled2: {D.settle(prior2, fixed2, other2, acc2) == D.Settled{hdr2, pay2, acc3} : D.Settled} ->
    CWalk.walk_goal(sl, end, fixedtotal, h2, pos2, pdone2, vs, tt, hdr2, pay2, acc3, tv, D.go(tt, 0n, 0n, D.Walk{fixed2, prior2, other2, pos2, end, acc2}))
  CWalk.walk_goal(sl, end, fixedtotal, h, pos, pdone, ps, T.Chain{hh, tt}, hdr, pay, acc2, T.Items{hv, tv}, D.go(T.Chain{hh, tt}, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc}))
def chain_step_dispatch(hh, tt, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, us, vs, hdr, pay, acc2, hv, tv, f, ok, settled, ea, eb, et, talign, single, child, cont):
  match f:
    case CReg.FixedShape{ys}:
      (shape, width) = ok
      +sh = shape
      CWalk.walk_goal_parts(sl, end, fixedtotal, h, pos, pdone, ps, T.Fixed{ys} <> vs, T.Chain{hh, tt}, hdr, pay, acc2, T.Items{hv, tv}, D.go(T.Chain{hh, tt}, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc}),
        Equal.trans(+List<T.Part>, T.Fixed{ys} <> vs, List.append(&2, T.Part, us, vs), ps,
          Equal.cong(+List<T.Part>, +List<T.Part>, qs => List.append(&2, T.Part, qs, vs), [T.Fixed{ys}], us, Equal.sym(+List<T.Part>, us, [T.Fixed{ys}], sh)),
          et),
        chain_fixed_step(hh, tt, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, vs, ys, hdr, pay, acc2, hv, tv, settled,
          Equal.trans(Maybe<&2, +List<T.Part>>, SC.parts(hv, hh), Some{us}, Some{[T.Fixed{ys}]}, ea, Equal.cong(+List<T.Part>, Maybe<&2, +List<T.Part>>, qs => Some{qs}, us, [T.Fixed{ys}], sh)),
          eb, width, single,
          child,
          v2 => crest2 => cont(Nat.add(h, List.length(&2, U32, ys)), pos, List.append(&2, T.Part, pdone, [T.Fixed{ys}]), crest2, pay, C.CCons{v2, acc2}, True{}, D.Parsed{v2, crest2}, pay, {==})))
    case CReg.VarShape{ys}:
      (shape, width) = ok
      +sh = shape
      CWalk.walk_goal_parts(sl, end, fixedtotal, h, pos, pdone, ps, T.Variable{ys} <> vs, T.Chain{hh, tt}, hdr, pay, acc2, T.Items{hv, tv}, D.go(T.Chain{hh, tt}, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc}),
        Equal.trans(+List<T.Part>, T.Variable{ys} <> vs, List.append(&2, T.Part, us, vs), ps,
          Equal.cong(+List<T.Part>, +List<T.Part>, qs => List.append(&2, T.Part, qs, vs), [T.Variable{ys}], us, Equal.sym(+List<T.Part>, us, [T.Variable{ys}], sh)),
          et),
        chain_variable_step(hh, tt, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, vs, ys, hdr, pay, acc2, hv, tv, settled,
          Equal.trans(Maybe<&2, +List<T.Part>>, SC.parts(hv, hh), Some{us}, Some{[T.Variable{ys}]}, ea, Equal.cong(+List<T.Part>, Maybe<&2, +List<T.Part>>, qs => Some{qs}, us, [T.Variable{ys}], sh)),
          eb, width, talign, single,
          child,
          v2 => crest2 => cont(Nat.add(h, 4n), Nat.add(pos, List.length(&2, U32, ys)), List.append(&2, T.Part, pdone, [T.Variable{ys}]), P.adv(hdr, 4n), crest2, C.CCons{v2, acc2}, False{}, D.Parsed{v2, crest2}, P.adv(hdr, 4n), {==})))

# The chain walk case of the decoder's recursion.
law chain_walk_complete:
  for +hh: T.Schema
  for +tt: T.Schema
  for +k: Nat
  for +fixed: Bool
  for +prior: D.Out
  for +other: P.Slice
  for +acc: C.CValue
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +ps: +List<T.Part>
  for +hdr: P.Slice
  for +pay: P.Slice
  for +acc2: C.CValue
  for +value: T.Value
  for +settled: {D.settle(prior, fixed, other, acc) == D.Settled{hdr, pay, acc2} : D.Settled}
  for +legal: {IS.valid_go(T.Chain{hh, tt}, True{}) == True{} : Bool}
  for +kok: {Nat.is_eq(k, 0n) == True{} : Bool}
  for child: @+cv0: T.Value -> @+n: Nat -> @+xs: P.Slice ->
    @+wfx: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat} ->
    @+roomx: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool} ->
    CLeaf.holds(hh, cv0, xs, n) ->
    CLeaf.parsed_as(cv0, xs, n, D.go(hh, 1n, 0n, D.Region{n, xs}))
  for cont: @+h2: Nat -> @+pos2: Nat -> @+pdone2: +List<T.Part> -> @+ps2: +List<T.Part> -> @+hdr2: P.Slice -> @+pay2: P.Slice -> @+acc3: C.CValue -> @+value2: T.Value -> @+fixed2: Bool -> @+prior2: D.Out -> @+other2: P.Slice ->
    @+settled2: {D.settle(prior2, fixed2, other2, acc2) == D.Settled{hdr2, pay2, acc3} : D.Settled} ->
    CWalk.walk_goal(sl, end, fixedtotal, h2, pos2, pdone2, ps2, tt, hdr2, pay2, acc3, value2, D.go(tt, 0n, 0n, D.Walk{fixed2, prior2, other2, pos2, end, acc2}))
  CWalk.walk_goal(sl, end, fixedtotal, h, pos, pdone, ps, T.Chain{hh, tt}, hdr, pay, acc2, value, D.go(T.Chain{hh, tt}, 0n, k, D.Walk{fixed, prior, other, pos, end, acc}))
def chain_walk_complete(hh, tt, k, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, settled, legal, kok, child, cont):
  match k:
    case 1n+q:
      Empty.absurd(CWalk.walk_goal(sl, end, fixedtotal, h, pos, pdone, ps, T.Chain{hh, tt}, hdr, pay, acc2, value, D.go(T.Chain{hh, tt}, 0n, 1n+q, D.Walk{fixed, prior, other, pos, end, acc})), F.false_true(kok))
    case 0n:
      match value:
        case T.BooleanValue{b0}:
          wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
            Empty.absurd(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.BooleanValue{b0}), D.go(T.Chain{hh, tt}, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc})),
              F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BooleanValue{b0}, T.Chain{hh, tt}), Some{ps}, restparts)))
        case T.UnsignedValue{u0}:
          wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
            Empty.absurd(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.UnsignedValue{u0}), D.go(T.Chain{hh, tt}, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc})),
              F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.UnsignedValue{u0}, T.Chain{hh, tt}), Some{ps}, restparts)))
        case T.BytesValue{y0}:
          wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
            Empty.absurd(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.BytesValue{y0}), D.go(T.Chain{hh, tt}, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc})),
              F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BytesValue{y0}, T.Chain{hh, tt}), Some{ps}, restparts)))
        case T.BitsValue{q0}:
          wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
            Empty.absurd(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.BitsValue{q0}), D.go(T.Chain{hh, tt}, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc})),
              F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BitsValue{q0}, T.Chain{hh, tt}), Some{ps}, restparts)))
        case T.Sequence{i0}:
          wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
            Empty.absurd(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Sequence{i0}), D.go(T.Chain{hh, tt}, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc})),
              F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Sequence{i0}, T.Chain{hh, tt}), Some{ps}, restparts)))
        case T.EmptyItems{}:
          wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
            Empty.absurd(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.EmptyItems{}), D.go(T.Chain{hh, tt}, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc})),
              F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.EmptyItems{}, T.Chain{hh, tt}), Some{ps}, restparts)))
        case T.Selected{s0, w0}:
          wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
            Empty.absurd(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Selected{s0, w0}), D.go(T.Chain{hh, tt}, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc})),
              F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Selected{s0, w0}, T.Chain{hh, tt}), Some{ps}, restparts)))
        case T.NullValue{}:
          wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
            Empty.absurd(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.NullValue{}), D.go(T.Chain{hh, tt}, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc})),
              F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.NullValue{}, T.Chain{hh, tt}), Some{ps}, restparts)))
        case T.Items{hv, tv}:
          wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts =>
            concat_elim(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), D.go(T.Chain{hh, tt}, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc})), SC.parts(hv, hh), SC.parts(tv, tt), ps, restparts,
              us => vs => ea => eb => et =>
                chain_step_dispatch(hh, tt, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, us, vs, hdr, pay, acc2, hv, tv,
                  CReg.shape_of(us),
                  CReg.single_shape(SS.fixed_size(hh), SC.parts(hv, hh), us, ea, Shape.head_single(hh, hv, SC.parts(hv, hh), V.and_left(IS.valid_go(hh, False{}), IS.valid_go(tt, True{}), legal), Shape.facts(hv, hh, Shape.ok_single(hh, V.and_left(IS.valid_go(hh, False{}), IS.valid_go(tt, True{}), legal))))),
                  settled, ea, eb, et,
                  CReg.chain_fact_widths(FA.widths(tt), SS.fixed_size(tt), SC.parts(tv, tt), vs, eb, Shape.forest_view(tt, tv, SC.parts(tv, tt), V.and_right(IS.valid_go(hh, False{}), IS.valid_go(tt, True{}), legal), Shape.facts(tv, tt, Shape.ok_forest(tt, V.and_right(IS.valid_go(hh, False{}), IS.valid_go(tt, True{}), legal))))),
                  Shape.head_single(hh, hv, SC.parts(hv, hh), V.and_left(IS.valid_go(hh, False{}), IS.valid_go(tt, True{}), legal), Shape.facts(hv, hh, Shape.ok_single(hh, V.and_left(IS.valid_go(hh, False{}), IS.valid_go(tt, True{}), legal)))),
                  n2 => xs2 => wfx2 => roomx2 => hx2 => child(hv, n2, xs2, wfx2, roomx2, hx2),
                  h2 => pos2 => pdone2 => hdr2 => pay2 => acc3 => fixed2 => prior2 => other2 => settled2 => cont(h2, pos2, pdone2, vs, hdr2, pay2, acc3, tv, fixed2, prior2, other2, settled2))(wfsl, roomsl, fitend, hdrview, wfhdr, payview, wfpay, sizedone, remaining, position, regionsize, headerrest, payloadrest, payloadend, restparts))

# One element step of a sequence walk, dispatched on the fragment kind.
law seq_step_dispatch:
  for +schema: T.Schema
  for +e: T.Schema
  for +p: Nat
  for +fixed: Bool
  for +prior: D.Out
  for +other: P.Slice
  for +acc: C.CValue
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +ps: +List<T.Part>
  for +us: +List<T.Part>
  for +vs: +List<T.Part>
  for +hdr: P.Slice
  for +pay: P.Slice
  for +acc2: C.CValue
  for +hv: T.Value
  for +tv: T.Value
  for +f: CReg.FragShape
  for ok: CReg.shape_ok(SS.fixed_size(e), us, f)
  for +unfold: {D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc}) == D.go(schema, 0n, p, D.plan_next(D.plan(D.settle(prior, fixed, other, acc), IS.fixed_size(e), pos, end, D.Remaining{p}), D.go(e, 1n, 0n, D.plan_child(D.plan(D.settle(prior, fixed, other, acc), IS.fixed_size(e), pos, end, D.Remaining{p}))), end)) : D.Out}
  for +settled: {D.settle(prior, fixed, other, acc) == D.Settled{hdr, pay, acc2} : D.Settled}
  for +ea: {SC.parts(hv, e) == Some{us} : Maybe<&2, +List<T.Part>>}
  for +eb: {SC.parts(tv, T.Repeat{e}) == Some{vs} : Maybe<&2, +List<T.Part>>}
  for +et: {List.append(&2, T.Part, us, vs) == ps : +List<T.Part>}
  for +tailcount: {SC.count(tv) == p : Nat}
  for +salign: {HW.widths(vs) == List.replicate(Maybe<&2, Nat>, p, SS.fixed_size(e)) : +List<Maybe<&2, Nat>>}
  for single: FA.single_result(SS.fixed_size(e), SC.parts(hv, e))
  for child: @+n: Nat -> @+xs: P.Slice ->
    @+wfx: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat} ->
    @+roomx: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool} ->
    CLeaf.holds(e, hv, xs, n) ->
    CLeaf.parsed_as(hv, xs, n, D.go(e, 1n, 0n, D.Region{n, xs}))
  for cont: @+h2: Nat -> @+pos2: Nat -> @+pdone2: +List<T.Part> -> @+hdr2: P.Slice -> @+pay2: P.Slice -> @+acc3: C.CValue -> @+fixed2: Bool -> @+prior2: D.Out -> @+other2: P.Slice ->
    @+settled2: {D.settle(prior2, fixed2, other2, acc2) == D.Settled{hdr2, pay2, acc3} : D.Settled} ->
    CWalk.walk_goal_seq(e, p, sl, end, fixedtotal, h2, pos2, pdone2, vs, hdr2, pay2, acc3, tv, D.go(schema, 0n, p, D.Walk{fixed2, prior2, other2, pos2, end, acc2}))
  CWalk.walk_goal_seq(e, 1n+p, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, T.Items{hv, tv}, D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc}))
def seq_step_dispatch(schema, e, p, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, us, vs, hdr, pay, acc2, hv, tv, f, ok, unfold, settled, ea, eb, et, tailcount, salign, single, child, cont):
  match f:
    case CReg.FixedShape{ys}:
      (shape, width) = ok
      +sh = shape
      CWalk.walk_goal_seq_parts(e, 1n+p, sl, end, fixedtotal, h, pos, pdone, ps, T.Fixed{ys} <> vs, hdr, pay, acc2, T.Items{hv, tv}, D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc}),
        Equal.trans(+List<T.Part>, T.Fixed{ys} <> vs, List.append(&2, T.Part, us, vs), ps,
          Equal.cong(+List<T.Part>, +List<T.Part>, qs => List.append(&2, T.Part, qs, vs), [T.Fixed{ys}], us, Equal.sym(+List<T.Part>, us, [T.Fixed{ys}], sh)),
          et),
        seq_fixed_step(schema, e, p, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, vs, ys, hdr, pay, acc2, hv, tv, unfold, settled,
          Equal.trans(Maybe<&2, +List<T.Part>>, SC.parts(hv, e), Some{us}, Some{[T.Fixed{ys}]}, ea, Equal.cong(+List<T.Part>, Maybe<&2, +List<T.Part>>, qs => Some{qs}, us, [T.Fixed{ys}], sh)),
          eb, tailcount, width, single,
          child,
          v2 => crest2 => cont(Nat.add(h, List.length(&2, U32, ys)), pos, List.append(&2, T.Part, pdone, [T.Fixed{ys}]), crest2, pay, C.CCons{v2, acc2}, True{}, D.Parsed{v2, crest2}, pay, {==})))
    case CReg.VarShape{ys}:
      (shape, width) = ok
      +sh = shape
      +wd = width
      CWalk.walk_goal_seq_parts(e, 1n+p, sl, end, fixedtotal, h, pos, pdone, ps, T.Variable{ys} <> vs, hdr, pay, acc2, T.Items{hv, tv}, D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc}),
        Equal.trans(+List<T.Part>, T.Variable{ys} <> vs, List.append(&2, T.Part, us, vs), ps,
          Equal.cong(+List<T.Part>, +List<T.Part>, qs => List.append(&2, T.Part, qs, vs), [T.Variable{ys}], us, Equal.sym(+List<T.Part>, us, [T.Variable{ys}], sh)),
          et),
        seq_variable_step(schema, e, p, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, vs, ys, hdr, pay, acc2, hv, tv, unfold, settled,
          Equal.trans(Maybe<&2, +List<T.Part>>, SC.parts(hv, e), Some{us}, Some{[T.Variable{ys}]}, ea, Equal.cong(+List<T.Part>, Maybe<&2, +List<T.Part>>, qs => Some{qs}, us, [T.Variable{ys}], sh)),
          eb, tailcount, wd,
          Equal.trans(+List<Maybe<&2, Nat>>, HW.widths(vs), List.replicate(Maybe<&2, Nat>, p, SS.fixed_size(e)), List.replicate(Maybe<&2, Nat>, p, None{}),
            salign,
            Equal.cong(Maybe<&2, Nat>, +List<Maybe<&2, Nat>>, u => List.replicate(Maybe<&2, Nat>, p, u), SS.fixed_size(e), None{}, wd)),
          single,
          child,
          v2 => crest2 => cont(Nat.add(h, 4n), Nat.add(pos, List.length(&2, U32, ys)), List.append(&2, T.Part, pdone, [T.Variable{ys}]), P.adv(hdr, 4n), crest2, C.CCons{v2, acc2}, False{}, D.Parsed{v2, crest2}, P.adv(hdr, 4n), {==})))

# The sequence walk at zero remaining elements: the region ends here.
law seq_close_complete:
  for +schema: T.Schema
  for +e: T.Schema
  for +fixed: Bool
  for +prior: D.Out
  for +other: P.Slice
  for +acc: C.CValue
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +ps: +List<T.Part>
  for +hdr: P.Slice
  for +pay: P.Slice
  for +acc2: C.CValue
  for +value: T.Value
  for +settled: {D.settle(prior, fixed, other, acc) == D.Settled{hdr, pay, acc2} : D.Settled}
  for +unfold0: {D.go(schema, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc}) == D.close(D.settle(prior, fixed, other, acc), pos, end) : D.Out}
  CWalk.walk_goal_seq(e, 0n, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, D.go(schema, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc}))
def seq_close_complete(schema, e, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, settled, unfold0):
  %Equal.sym(D.Out, D.go(schema, 0n, 0n, D.Walk{fixed, prior, other, pos, end, acc}), D.close(D.settle(prior, fixed, other, acc), pos, end), unfold0) : CWalk.walk_goal_seq(e, 0n, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, _)
  %Equal.sym(D.Settled, D.settle(prior, fixed, other, acc), D.Settled{hdr, pay, acc2}, settled) : CWalk.walk_goal_seq(e, 0n, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, D.close(_, pos, end))
  CWalk.close_seq_complete(e, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value)

# One element of a sequence walk: the value and parts are decomposed here.
law seq_step_complete:
  for +schema: T.Schema
  for +e: T.Schema
  for +p: Nat
  for +fixed: Bool
  for +prior: D.Out
  for +other: P.Slice
  for +acc: C.CValue
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +ps: +List<T.Part>
  for +hdr: P.Slice
  for +pay: P.Slice
  for +acc2: C.CValue
  for +value: T.Value
  for +settled: {D.settle(prior, fixed, other, acc) == D.Settled{hdr, pay, acc2} : D.Settled}
  for +legal: {IS.valid_go(e, False{}) == True{} : Bool}
  for +unfoldp: {D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc}) == D.go(schema, 0n, p, D.plan_next(D.plan(D.settle(prior, fixed, other, acc), IS.fixed_size(e), pos, end, D.Remaining{p}), D.go(e, 1n, 0n, D.plan_child(D.plan(D.settle(prior, fixed, other, acc), IS.fixed_size(e), pos, end, D.Remaining{p}))), end)) : D.Out}
  for child: @+cv0: T.Value -> @+n: Nat -> @+xs: P.Slice ->
    @+wfx: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat} ->
    @+roomx: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool} ->
    CLeaf.holds(e, cv0, xs, n) ->
    CLeaf.parsed_as(cv0, xs, n, D.go(e, 1n, 0n, D.Region{n, xs}))
  for cont: @+h2: Nat -> @+pos2: Nat -> @+pdone2: +List<T.Part> -> @+ps2: +List<T.Part> -> @+hdr2: P.Slice -> @+pay2: P.Slice -> @+acc3: C.CValue -> @+value2: T.Value -> @+fixed2: Bool -> @+prior2: D.Out -> @+other2: P.Slice ->
    @+settled2: {D.settle(prior2, fixed2, other2, acc2) == D.Settled{hdr2, pay2, acc3} : D.Settled} ->
    CWalk.walk_goal_seq(e, p, sl, end, fixedtotal, h2, pos2, pdone2, ps2, hdr2, pay2, acc3, value2, D.go(schema, 0n, p, D.Walk{fixed2, prior2, other2, pos2, end, acc2}))
  CWalk.walk_goal_seq(e, 1n+p, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc}))
def seq_step_complete(schema, e, p, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, settled, legal, unfoldp, child, cont):
  match value:
    case T.BooleanValue{b0}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
        Empty.absurd(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.BooleanValue{b0}), D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc})),
          F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BooleanValue{b0}, T.Repeat{e}), Some{ps}, restparts)))
    case T.UnsignedValue{u0}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
        Empty.absurd(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.UnsignedValue{u0}), D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc})),
          F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.UnsignedValue{u0}, T.Repeat{e}), Some{ps}, restparts)))
    case T.BytesValue{y0}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
        Empty.absurd(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.BytesValue{y0}), D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc})),
          F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BytesValue{y0}, T.Repeat{e}), Some{ps}, restparts)))
    case T.BitsValue{q0}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
        Empty.absurd(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.BitsValue{q0}), D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc})),
          F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BitsValue{q0}, T.Repeat{e}), Some{ps}, restparts)))
    case T.Sequence{i0}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
        Empty.absurd(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Sequence{i0}), D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc})),
          F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Sequence{i0}, T.Repeat{e}), Some{ps}, restparts)))
    case T.Selected{s0, w0}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
        Empty.absurd(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Selected{s0, w0}), D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc})),
          F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Selected{s0, w0}, T.Repeat{e}), Some{ps}, restparts)))
    case T.NullValue{}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
        Empty.absurd(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.NullValue{}), D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc})),
          F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.NullValue{}, T.Repeat{e}), Some{ps}, restparts)))
    case T.EmptyItems{}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
        Empty.absurd(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.EmptyItems{}), D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc})),
          F.false_true(Equal.sym(Bool, True{}, False{}, Equal.cong(Nat, Bool, kk => Nat.is_eq(kk, 0n), 0n, 1n+p, countok))))
    case T.Items{hv, tv}:
      wfsl => roomsl => fitend => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => regionsize => headerrest => payloadrest => payloadend => restparts => countok =>
        concat_elim(CWalk.walk_result(sl, end, CWalk.app_items(CWalk.reading(acc2), T.Items{hv, tv}), D.go(schema, 0n, 1n+p, D.Walk{fixed, prior, other, pos, end, acc})), SC.parts(hv, e), SC.parts(tv, T.Repeat{e}), ps, restparts,
          us => vs => ea => eb => et =>
            seq_step_dispatch(schema, e, p, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, us, vs, hdr, pay, acc2, hv, tv,
              CReg.shape_of(us),
              CReg.single_shape(SS.fixed_size(e), SC.parts(hv, e), us, ea, Shape.head_single(e, hv, SC.parts(hv, e), legal, Shape.facts(hv, e, Shape.ok_single(e, legal)))),
              unfoldp, settled, ea, eb, et,
              Equal.cong(Nat, Nat, pred, 1n+SC.count(tv), 1n+p, countok),
              Equal.trans(+List<Maybe<&2, Nat>>, HW.widths(vs), List.replicate(Maybe<&2, Nat>, SC.count(tv), SS.fixed_size(e)), List.replicate(Maybe<&2, Nat>, p, SS.fixed_size(e)),
                CReg.repeat_fact_widths(List.replicate(Maybe<&2, Nat>, SC.count(tv), SS.fixed_size(e)), SC.parts(tv, T.Repeat{e}), vs, eb, Shape.facts(tv, T.Repeat{e}, legal)),
                Equal.cong(Nat, +List<Maybe<&2, Nat>>, kk => List.replicate(Maybe<&2, Nat>, kk, SS.fixed_size(e)), SC.count(tv), p, Equal.cong(Nat, Nat, pred, 1n+SC.count(tv), 1n+p, countok))),
              Shape.head_single(e, hv, SC.parts(hv, e), legal, Shape.facts(hv, e, Shape.ok_single(e, legal))),
              n2 => xs2 => wfx2 => roomx2 => hx2 => child(hv, n2, xs2, wfx2, roomx2, hx2),
              h2 => pos2 => pdone2 => hdr2 => pay2 => acc3 => fixed2 => prior2 => other2 => settled2 => cont(h2, pos2, pdone2, vs, hdr2, pay2, acc3, tv, fixed2, prior2, other2, settled2))(wfsl, roomsl, fitend, hdrview, wfhdr, payview, wfpay, sizedone, remaining, position, regionsize, headerrest, payloadrest, payloadend, restparts, countok))
