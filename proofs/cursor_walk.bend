import Base
import ../types/schema.bend as T
import ../src/packed.bend as P
import ../src/cvalue.bend as C
import ../src/decode.bend as D
import ../spec/codec.bend as SC
import ../spec/layout.bend as SL
import ../spec/schema.bend as SS
import ./packed.bend as PK
import ./parts_algebra.bend as PA
import ./cursor_leaves.bend as CL
import ./lists.bend as L
import ./layout.bend as LA
import ./packing.bend as PKG
import ./nat_order.bend as NO
import ./word_facts.bend as F
import ../spec/primitives.bend as SP
import ../src/schema.bend as IS
import ../src/layout.bend as IL
import ./schema.bend as SchemaProof
import ./walk.bend as W
import ./nat_algebra.bend as NA
import ../src/bitfields.bend as IBits
import ./primitive_invariants.bend as V
import ../src/primitives.bend as IP
import ../spec/nat_bytes.bend as N
import ./integer_decoding.bend as Integer
import ./layout_offset_value.bend as LOV
import ./offset_digits.bend as OD
import ./cvalue_chain.bend as CH

# Soundness of the layout walk: what the cursor decoder produces for a
# container/sequence region re-encodes, under the frozen layout
# specification, to exactly that region's bytes.
#
# The walk is stated against `P.slice_bytes`, the byte list a slice denotes,
# and against `spec/layout.bend`; no implementation serializer appears.

# A byte string split at a prefix position: the specification's fixed region
# followed by its payload region is the region itself.
law take_split:
  for +a: Nat
  for +b: Nat
  for +xs: +List<U32>
  for +order: {Nat.is_le(a, b) == True{} : Bool}
  {List.append(&2, U32, List.take(&2, U32, xs, a), List.take(&2, U32, List.drop(&2, U32, xs, a), Nat.sub(b, a))) == List.take(&2, U32, xs, b) : +List<U32>}
def take_split(a, b, xs, order):
  match a b:
    case 0n b2:
      %Equal.sym(+List<U32>, List.take(&2, U32, xs, 0n), [], PK.take_zero(xs)) : {List.append(&2, U32, _, List.take(&2, U32, List.drop(&2, U32, xs, 0n), Nat.sub(b2, 0n))) == List.take(&2, U32, xs, b2) : +List<U32>}
      %Equal.sym(+List<U32>, List.drop(&2, U32, xs, 0n), xs, PK.drop_zero(xs)) : {List.take(&2, U32, _, Nat.sub(b2, 0n)) == List.take(&2, U32, xs, b2) : +List<U32>}
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, xs, k), Nat.sub(b2, 0n), b2, PK.sub_zero(b2))
    case 1n+p 0n: Empty.absurd({List.append(&2, U32, List.take(&2, U32, xs, 1n+p), List.take(&2, U32, List.drop(&2, U32, xs, 1n+p), Nat.sub(0n, 1n+p))) == List.take(&2, U32, xs, 0n) : +List<U32>}, F.false_true(order))
    case 1n+p 1n+q:
      match xs:
        case Nil{}: {==}
        case Con{h, t}:
          Equal.cong(+List<U32>, +List<U32>, ys => h <> ys, List.append(&2, U32, List.take(&2, U32, t, p), List.take(&2, U32, List.drop(&2, U32, t, p), Nat.sub(q, p))), List.take(&2, U32, t, q), take_split(p, q, t, order))

# The result of a completed walk over a region of `end` bytes at `sl`, whose
# whole part list has `fixedtotal` fixed bytes.
def walk_result(fields: T.Schema, sl: P.Slice, end: Nat, fixedtotal: Nat, total: Nat, out: D.Out) -> Type:
  match out:
    case D.Begin{r}: Empty
    case D.Parsed{v, rest}:
      Exists(+List<T.Part>, ps =>
        {SC.parts(C.to_value(v), fields) == Some{ps} : Maybe<&2, +List<T.Part>>}
        & {SL.fixed_size(ps) == fixedtotal : Nat}
        & {SL.bytes_valid(ps) == True{} : Bool}
        & {List.append(&2, U32, SL.fixed_parts(ps, fixedtotal), SL.payloads(ps)) == List.take(&2, U32, P.slice_bytes(sl), end) : +List<U32>}
        & {P.slice_bytes(rest) == List.drop(&2, U32, P.slice_bytes(sl), end) : +List<U32>}
        & {List.length(&2, U32, P.slice_bytes(rest)) == P.slice_size(rest) : Nat}
        & {SC.count(C.to_value(v)) == total : Nat})
    case _: Unit

# The already-decoded prefix of a walk, as seen by the specification: the
# context law says how the accumulated children extend to the whole field
# forest once the remaining fields are decoded.
def walk_context(fields: T.Schema, rest_fields: T.Schema, acc: C.CValue, pdone: +List<T.Part>) -> Type:
  @+suffix: C.CValue -> @+ps: +List<T.Part> ->
    {SC.parts(C.items_fwd(suffix), rest_fields) == Some{ps} : Maybe<&2, +List<T.Part>>} ->
    {SC.parts(C.to_value(D.reverse_items(suffix, acc)), fields) == Some{List.append(&2, T.Part, pdone, ps)} : Maybe<&2, +List<T.Part>>}

# How many children the accumulated prefix contributes.
def count_context(acc: C.CValue, base: Nat) -> Type:
  @+suffix: C.CValue -> @+m: Nat ->
    {SC.count(C.items_fwd(suffix)) == m : Nat} ->
    {SC.count(C.to_value(D.reverse_items(suffix, acc))) == Nat.add(base, m) : Nat}

law count_step:
  for +acc: C.CValue
  for +base: Nat
  for +cv: C.CValue
  for ctx: count_context(acc, base)
  count_context(C.CCons{cv, acc}, 1n+base)
def count_step(acc, base, cv, ctx):
  suffix => m => e =>
    Equal.trans(Nat, SC.count(C.to_value(D.reverse_items(C.CCons{cv, suffix}, acc))), Nat.add(base, 1n+m), Nat.add(1n+base, m),
      ctx(C.CCons{cv, suffix}, 1n+m, Equal.cong(Nat, Nat, x => 1n+x, SC.count(C.items_fwd(suffix)), m, e)),
      PKG.add_succ(base, m))

# ---------------------------------------------------------------------------
# The walk invariant, as the specification sees it: the header bytes consumed
# so far are the fixed region of the decoded prefix, the payload bytes
# consumed so far are its payloads, and the decoded children extend to the
# whole forest once the remaining fields are decoded. `hsrest` is the header
# width the remaining fields still occupy. The premises are stated as arrows
# so that a walk step can consume them one at a time.
def walk_goal(fields: T.Schema, fs: T.Schema, sl: P.Slice, end: Nat, fixedtotal: Nat, hsrest: Nat, h: Nat, pos: Nat, pdone: +List<T.Part>, hdr: P.Slice, pay: P.Slice, acc: C.CValue, base: Nat, krem: Nat, total: Nat, out: D.Out) -> Type:
  @+wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat} ->
  @+roomsl: {Nat.is_le(end, P.slice_size(sl)) == True{} : Bool} ->
  @+hdrview: {P.slice_bytes(hdr) == List.drop(&2, U32, P.slice_bytes(sl), h) : +List<U32>} ->
  @+wfhdr: {List.length(&2, U32, P.slice_bytes(hdr)) == P.slice_size(hdr) : Nat} ->
  @+payview: {P.slice_bytes(pay) == List.drop(&2, U32, P.slice_bytes(sl), pos) : +List<U32>} ->
  @+wfpay: {List.length(&2, U32, P.slice_bytes(pay)) == P.slice_size(pay) : Nat} ->
  @+sizedone: {SL.fixed_size(pdone) == h : Nat} ->
  @+remaining: {Nat.add(h, hsrest) == fixedtotal : Nat} ->
  @+position: {Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))) == pos : Nat} ->
  @+headerbytes: {List.take(&2, U32, P.slice_bytes(sl), h) == SL.fixed_parts(pdone, fixedtotal) : +List<U32>} ->
  @+payloadbytes: {List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(pos, fixedtotal)) == SL.payloads(pdone) : +List<U32>} ->
  @+validdone: {SL.bytes_valid(pdone) == True{} : Bool} ->
  @+fixle: {Nat.is_le(fixedtotal, pos) == True{} : Bool} ->
  @+posle: {Nat.is_le(pos, end) == True{} : Bool} ->
  @+counted: {Nat.add(base, krem) == total : Nat} ->
  count_context(acc, base) ->
  walk_context(fields, fs, acc, pdone) ->
  walk_result(fields, sl, end, fixedtotal, total, out)

law parts_bytes:
  for +xs: +List<U32>
  for +fixedtotal: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +header_bytes: {List.take(&2, U32, xs, fixedtotal) == SL.fixed_parts(pdone, fixedtotal) : +List<U32>}
  for +payload_bytes: {List.take(&2, U32, List.drop(&2, U32, xs, fixedtotal), Nat.sub(pos, fixedtotal)) == SL.payloads(pdone) : +List<U32>}
  {List.append(&2, U32, SL.fixed_parts(pdone, fixedtotal), SL.payloads(pdone)) == List.append(&2, U32, List.take(&2, U32, xs, fixedtotal), List.take(&2, U32, List.drop(&2, U32, xs, fixedtotal), Nat.sub(pos, fixedtotal))) : +List<U32>}
def parts_bytes(xs, fixedtotal, pos, pdone, header_bytes, payload_bytes):
  %Equal.sym(+List<U32>, List.take(&2, U32, xs, fixedtotal), SL.fixed_parts(pdone, fixedtotal), header_bytes) : {List.append(&2, U32, SL.fixed_parts(pdone, fixedtotal), SL.payloads(pdone)) == List.append(&2, U32, _, List.take(&2, U32, List.drop(&2, U32, xs, fixedtotal), Nat.sub(pos, fixedtotal))) : +List<U32>}
  %Equal.sym(+List<U32>, List.take(&2, U32, List.drop(&2, U32, xs, fixedtotal), Nat.sub(pos, fixedtotal)), SL.payloads(pdone), payload_bytes) : {List.append(&2, U32, SL.fixed_parts(pdone, fixedtotal), SL.payloads(pdone)) == List.append(&2, U32, SL.fixed_parts(pdone, fixedtotal), _) : +List<U32>}
  {==}

law closed_sound:
  for +ok: Bool
  for +fields: T.Schema
  for +fs: T.Schema
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +acc: C.CValue
  for +pay: P.Slice
  for +base: Nat
  for +total: Nat
  for context: walk_context(fields, fs, acc, pdone)
  for countctx: count_context(acc, base)
  for +counted: {Nat.add(base, 0n) == total : Nat}
  for +empty: {SC.parts(T.EmptyItems{}, fs) == Some{[]} : Maybe<&2, +List<T.Part>>}
  for +header_bytes: {List.take(&2, U32, P.slice_bytes(sl), fixedtotal) == SL.fixed_parts(pdone, fixedtotal) : +List<U32>}
  for +payload_bytes: {List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(pos, fixedtotal)) == SL.payloads(pdone) : +List<U32>}
  for +sized: {SL.fixed_size(pdone) == fixedtotal : Nat}
  for +valid: {SL.bytes_valid(pdone) == True{} : Bool}
  for +ordered: {Nat.is_le(fixedtotal, pos) == True{} : Bool}
  for +payload_view: {P.slice_bytes(pay) == List.drop(&2, U32, P.slice_bytes(sl), pos) : +List<U32>}
  for +wfpay: {List.length(&2, U32, P.slice_bytes(pay)) == P.slice_size(pay) : Nat}
  for +same: {D.nat_eq(pos, end) == ok : Bool}
  walk_result(fields, sl, end, fixedtotal, total, D.closed(ok, acc, pay))
def closed_sound(ok, fields, fs, sl, end, fixedtotal, pos, pdone, acc, pay, base, total, context, countctx, counted, empty, header_bytes, payload_bytes, sized, valid, ordered, payload_view, wfpay, same):
  match ok:
    case False{}: Unit{}
    case True{}:
      %CL.nat_eq_sound(pos, end, same) : walk_result(fields, sl, _, fixedtotal, total, D.closed(True{}, acc, pay))
      (pdone,
       (%L.append_empty(T.Part, pdone) : {SC.parts(C.to_value(D.reverse_items(C.CEnd{}, acc)), fields) == Some{_} : Maybe<&2, +List<T.Part>>}
        context(C.CEnd{}, [], empty),
        (sized,
         (valid,
          (Equal.trans(+List<U32>, List.append(&2, U32, SL.fixed_parts(pdone, fixedtotal), SL.payloads(pdone)), List.append(&2, U32, List.take(&2, U32, P.slice_bytes(sl), fixedtotal), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(pos, fixedtotal))), List.take(&2, U32, P.slice_bytes(sl), pos),
             parts_bytes(P.slice_bytes(sl), fixedtotal, pos, pdone, header_bytes, payload_bytes),
             take_split(fixedtotal, pos, P.slice_bytes(sl), ordered)),
           (payload_view,
            (wfpay,
             Equal.trans(Nat, SC.count(C.to_value(D.reverse_items(C.CEnd{}, acc))), Nat.add(base, 0n), total, countctx(C.CEnd{}, 0n, {==}), counted))))))))

# Closing a walk: the layout ends exactly at the region end, the accumulated
# children are the whole forest, and their specified encoding is the region.
law close_sound:
  for +fields: T.Schema
  for +fs: T.Schema
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +acc: C.CValue
  for +hdr: P.Slice
  for +pay: P.Slice
  for +base: Nat
  for +total: Nat
  for +empty: {SC.parts(T.EmptyItems{}, fs) == Some{[]} : Maybe<&2, +List<T.Part>>}
  walk_goal(fields, fs, sl, end, fixedtotal, 0n, h, pos, pdone, hdr, pay, acc, base, 0n, total, D.close(D.Settled{hdr, pay, acc}, pos, end))
def close_sound(fields, fs, sl, end, fixedtotal, h, pos, pdone, acc, hdr, pay, base, total, empty):
  wfsl => roomsl => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => headerbytes => payloadbytes => validdone => fixle => posle => counted => countctx => context =>
    +hfix = Equal.trans(Nat, h, Nat.add(h, 0n), fixedtotal, Equal.sym(Nat, Nat.add(h, 0n), h, PKG.add_zero(h)), remaining)
    +sized = Equal.trans(Nat, SL.fixed_size(pdone), h, fixedtotal, sizedone, hfix)
    closed_sound(D.nat_eq(pos, end), fields, fs, sl, end, fixedtotal, pos, pdone, acc, pay, base, total, context, countctx, counted, empty,
      Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(sl), fixedtotal), List.take(&2, U32, P.slice_bytes(sl), h), SL.fixed_parts(pdone, fixedtotal),
        Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(sl), k), fixedtotal, h, Equal.sym(Nat, h, fixedtotal, hfix)),
        headerbytes),
      payloadbytes, sized, validdone, fixle, payview, wfpay, {==})

law sub_add:
  for +a: Nat
  for +b: Nat
  {Nat.sub(Nat.add(a, b), a) == b : Nat}
def sub_add(a, b):
  match a:
    case 0n: PK.sub_zero(b)
    case 1n+p: sub_add(p, b)

# ---------------------------------------------------------------------------
# Extending the decoded prefix by one fixed-width child.
law fixed_size_snoc:
  for +ps: +List<T.Part>
  for +xs: +List<U32>
  for +h: Nat
  for +w: Nat
  for +sized: {SL.fixed_size(ps) == h : Nat}
  for +len: {List.length(&2, U32, xs) == w : Nat}
  {SL.fixed_size(List.append(&2, T.Part, ps, [T.Fixed{xs}])) == Nat.add(h, w) : Nat}
def fixed_size_snoc(ps, xs, h, w, sized, len):
  %sized : {SL.fixed_size(List.append(&2, T.Part, ps, [T.Fixed{xs}])) == Nat.add(_, w) : Nat}
  %len : {SL.fixed_size(List.append(&2, T.Part, ps, [T.Fixed{xs}])) == Nat.add(SL.fixed_size(ps), _) : Nat}
  %PKG.add_zero(List.length(&2, U32, xs)) : {SL.fixed_size(List.append(&2, T.Part, ps, [T.Fixed{xs}])) == Nat.add(SL.fixed_size(ps), _) : Nat}
  PA.fixed_size_append(ps, [T.Fixed{xs}])

law payloads_snoc_fixed:
  for +ps: +List<T.Part>
  for +xs: +List<U32>
  {SL.payloads(List.append(&2, T.Part, ps, [T.Fixed{xs}])) == SL.payloads(ps) : +List<U32>}
def payloads_snoc_fixed(ps, xs):
  Equal.trans(+List<U32>, SL.payloads(List.append(&2, T.Part, ps, [T.Fixed{xs}])), List.append(&2, U32, SL.payloads(ps), []), SL.payloads(ps),
    PA.payloads_append(ps, [T.Fixed{xs}]),
    L.append_empty(U32, SL.payloads(ps)))

law bytes_valid_snoc_fixed:
  for +ps: +List<T.Part>
  for +xs: +List<U32>
  for +valid: {SL.bytes_valid(ps) == True{} : Bool}
  for +domain: {SP.bytes_domain(xs) == True{} : Bool}
  {SL.bytes_valid(List.append(&2, T.Part, ps, [T.Fixed{xs}])) == True{} : Bool}
def bytes_valid_snoc_fixed(ps, xs, valid, domain):
  %valid : {SL.bytes_valid(List.append(&2, T.Part, ps, [T.Fixed{xs}])) == Bool.and(_, True{}) : Bool}
  %domain : {SL.bytes_valid(List.append(&2, T.Part, ps, [T.Fixed{xs}])) == Bool.and(SL.bytes_valid(ps), Bool.and(_, True{})) : Bool}
  PA.bytes_valid_append(ps, [T.Fixed{xs}])

law fixed_parts_snoc_fixed:
  for +ps: +List<T.Part>
  for +xs: +List<U32>
  for +off: Nat
  {SL.fixed_parts(List.append(&2, T.Part, ps, [T.Fixed{xs}]), off) == List.append(&2, U32, SL.fixed_parts(ps, off), xs) : +List<U32>}
def fixed_parts_snoc_fixed(ps, xs, off):
  %L.append_empty(U32, xs) : {SL.fixed_parts(List.append(&2, T.Part, ps, [T.Fixed{xs}]), off) == List.append(&2, U32, SL.fixed_parts(ps, off), _) : +List<U32>}
  PA.fixed_parts_append(ps, [T.Fixed{xs}], off)

# The decoded prefix grows by one child: the specification's parts of the
# whole forest are the prefix's parts followed by the rest.
# How a field forest splits into its first field and the rest, as the
# specification sees it. Declaration-order fields (`Chain`) and repeated
# sequence elements (`Repeat`) both satisfy it definitionally.
def forest_split(fs: T.Schema, hh: T.Schema, fsr: T.Schema) -> Type:
  @+x: C.CValue -> @+y: C.CValue ->
    {SC.parts(C.items_fwd(C.CCons{x, y}), fs) == SC.concatenate(SC.parts(C.to_value(x), hh), SC.parts(C.items_fwd(y), fsr)) : Maybe<&2, +List<T.Part>>}

law chain_split:
  for +hh: T.Schema
  for +tt: T.Schema
  forest_split(T.Chain{hh, tt}, hh, tt)
def chain_split(hh, tt): x => y => {==}

law repeat_split:
  for +e: T.Schema
  forest_split(T.Repeat{e}, e, T.Repeat{e})
def repeat_split(e): x => y => {==}

law concatenate_some:
  for +p: +List<T.Part>
  for +ps: +List<T.Part>
  for +a: Maybe<&2, +List<T.Part>>
  for +b: Maybe<&2, +List<T.Part>>
  for +ea: {a == Some{p} : Maybe<&2, +List<T.Part>>}
  for +eb: {b == Some{ps} : Maybe<&2, +List<T.Part>>}
  {SC.concatenate(a, b) == Some{List.append(&2, T.Part, p, ps)} : Maybe<&2, +List<T.Part>>}
def concatenate_some(p, ps, a, b, ea, eb):
  %Equal.sym(Maybe<&2, +List<T.Part>>, a, Some{p}, ea) : {SC.concatenate(_, b) == Some{List.append(&2, T.Part, p, ps)} : Maybe<&2, +List<T.Part>>}
  %Equal.sym(Maybe<&2, +List<T.Part>>, b, Some{ps}, eb) : {SC.concatenate(Some{p}, _) == Some{List.append(&2, T.Part, p, ps)} : Maybe<&2, +List<T.Part>>}
  {==}

law forest_parts:
  for +fs: T.Schema
  for +hh: T.Schema
  for +fsr: T.Schema
  for +cv: C.CValue
  for +suffix: C.CValue
  for +p: +List<T.Part>
  for +ps: +List<T.Part>
  for split: forest_split(fs, hh, fsr)
  for +head: {SC.parts(C.to_value(cv), hh) == Some{p} : Maybe<&2, +List<T.Part>>}
  for +tail: {SC.parts(C.items_fwd(suffix), fsr) == Some{ps} : Maybe<&2, +List<T.Part>>}
  {SC.parts(C.items_fwd(C.CCons{cv, suffix}), fs) == Some{List.append(&2, T.Part, p, ps)} : Maybe<&2, +List<T.Part>>}
def forest_parts(fs, hh, fsr, cv, suffix, p, ps, split, head, tail):
  Equal.trans(Maybe<&2, +List<T.Part>>, SC.parts(C.items_fwd(C.CCons{cv, suffix}), fs), SC.concatenate(SC.parts(C.to_value(cv), hh), SC.parts(C.items_fwd(suffix), fsr)), Some{List.append(&2, T.Part, p, ps)},
    split(cv, suffix),
    concatenate_some(p, ps, SC.parts(C.to_value(cv), hh), SC.parts(C.items_fwd(suffix), fsr), head, tail))

law context_step:
  for +fields: T.Schema
  for +fs: T.Schema
  for +hh: T.Schema
  for +fsr: T.Schema
  for +pdone: +List<T.Part>
  for +acc: C.CValue
  for +cv: C.CValue
  for +p: +List<T.Part>
  for split: forest_split(fs, hh, fsr)
  for +childparts: {SC.parts(C.to_value(cv), hh) == Some{p} : Maybe<&2, +List<T.Part>>}
  for context: walk_context(fields, fs, acc, pdone)
  walk_context(fields, fsr, C.CCons{cv, acc}, List.append(&2, T.Part, pdone, p))
def context_step(fields, fs, hh, fsr, pdone, acc, cv, p, split, childparts, context):
  suffix => ps => e =>
    %Equal.sym(+List<T.Part>, List.append(&2, T.Part, List.append(&2, T.Part, pdone, p), ps), List.append(&2, T.Part, pdone, List.append(&2, T.Part, p, ps)), L.append_associative(T.Part, pdone, p, ps)) : {SC.parts(C.to_value(D.reverse_items(C.CCons{cv, suffix}, acc)), fields) == Some{_} : Maybe<&2, +List<T.Part>>}
    context(C.CCons{cv, suffix}, List.append(&2, T.Part, p, ps), forest_parts(fs, hh, fsr, cv, suffix, p, ps, split, childparts, e))

law le_sub:
  for +a: Nat
  for +b: Nat
  for +s: Nat
  for +bound: {Nat.is_le(Nat.add(a, b), s) == True{} : Bool}
  {Nat.is_le(b, Nat.sub(s, a)) == True{} : Bool}
def le_sub(a, b, s, bound):
  match a s:
    case 0n s2:
      %Equal.sym(Nat, Nat.sub(s2, 0n), s2, PK.sub_zero(s2)) : {Nat.is_le(b, _) == True{} : Bool}
      bound
    case 1n+p 0n: Empty.absurd({Nat.is_le(b, Nat.sub(0n, 1n+p)) == True{} : Bool}, F.false_true(bound))
    case 1n+p 1n+q: le_sub(p, b, q, bound)

# The region has room for the child: the child's bytes are inside the slice.
law child_room:
  for +sl: P.Slice
  for +h: Nat
  for +w: Nat
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +bound: {Nat.is_le(Nat.add(h, w), P.slice_size(sl)) == True{} : Bool}
  {Nat.is_le(w, List.length(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h))) == True{} : Bool}
def child_room(sl, h, w, wfsl, bound):
  %Equal.sym(Nat, List.length(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h)), Nat.sub(List.length(&2, U32, P.slice_bytes(sl)), h), PK.length_drop(P.slice_bytes(sl), h)) : {Nat.is_le(w, _) == True{} : Bool}
  %Equal.sym(Nat, List.length(&2, U32, P.slice_bytes(sl)), P.slice_size(sl), wfsl) : {Nat.is_le(w, Nat.sub(_, h)) == True{} : Bool}
  le_sub(h, w, P.slice_size(sl), bound)

# ---------------------------------------------------------------------------
# Arithmetic of the header cursor: the remaining fields' slots still fit.
law remaining_fixed:
  for +h: Nat
  for +w: Nat
  for +hs: Nat
  for +fixedtotal: Nat
  for +remaining: {Nat.add(h, Nat.add(w, hs)) == fixedtotal : Nat}
  {Nat.add(Nat.add(h, w), hs) == fixedtotal : Nat}
def remaining_fixed(h, w, hs, fixedtotal, remaining):
  Equal.trans(Nat, Nat.add(Nat.add(h, w), hs), Nat.add(h, Nat.add(w, hs)), fixedtotal, LA.add_associative(h, w, hs), remaining)

law header_bound:
  for +h: Nat
  for +w: Nat
  for +hs: Nat
  for +fixedtotal: Nat
  for +remaining: {Nat.add(Nat.add(h, w), hs) == fixedtotal : Nat}
  {Nat.is_le(Nat.add(h, w), fixedtotal) == True{} : Bool}
def header_bound(h, w, hs, fixedtotal, remaining):
  %remaining : {Nat.is_le(Nat.add(h, w), _) == True{} : Bool}
  NO.below_sum(Nat.add(h, w), hs)

law child_fixed_parts:
  for +hh: T.Schema
  for +cv: C.CValue
  for +hdr: P.Slice
  for +w: Nat
  for +bytes: +List<U32>
  for +width: {SS.fixed_size(hh) == Some{w} : Maybe<&2, Nat>}
  for +same: {List.take(&2, U32, P.slice_bytes(hdr), w) == bytes : +List<U32>}
  for +childparts: {SC.parts(C.to_value(cv), hh) == Some{[SC.fragment(SS.fixed_size(hh), List.take(&2, U32, P.slice_bytes(hdr), w))]} : Maybe<&2, +List<T.Part>>}
  {SC.parts(C.to_value(cv), hh) == Some{[T.Fixed{bytes}]} : Maybe<&2, +List<T.Part>>}
def child_fixed_parts(hh, cv, hdr, w, bytes, width, same, childparts):
  %width : {SC.parts(C.to_value(cv), hh) == Some{[SC.fragment(_, bytes)]} : Maybe<&2, +List<T.Part>>}
  %same : {SC.parts(C.to_value(cv), hh) == Some{[SC.fragment(SS.fixed_size(hh), _)]} : Maybe<&2, +List<T.Part>>}
  childparts

law header_step:
  for +sl: P.Slice
  for +h: Nat
  for +w: Nat
  for +fixedtotal: Nat
  for +pdone: +List<T.Part>
  for +headerbytes: {List.take(&2, U32, P.slice_bytes(sl), h) == SL.fixed_parts(pdone, fixedtotal) : +List<U32>}
  {List.take(&2, U32, P.slice_bytes(sl), Nat.add(h, w)) == SL.fixed_parts(List.append(&2, T.Part, pdone, [T.Fixed{List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), w)}]), fixedtotal) : +List<U32>}
def header_step(sl, h, w, fixedtotal, pdone, headerbytes):
  %sub_add(h, w) : {List.take(&2, U32, P.slice_bytes(sl), Nat.add(h, w)) == SL.fixed_parts(List.append(&2, T.Part, pdone, [T.Fixed{List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), _)}]), fixedtotal) : +List<U32>}
  Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(sl), Nat.add(h, w)), List.append(&2, U32, List.take(&2, U32, P.slice_bytes(sl), h), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(Nat.add(h, w), h))), SL.fixed_parts(List.append(&2, T.Part, pdone, [T.Fixed{List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(Nat.add(h, w), h))}]), fixedtotal),
    Equal.sym(+List<U32>, List.append(&2, U32, List.take(&2, U32, P.slice_bytes(sl), h), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(Nat.add(h, w), h))), List.take(&2, U32, P.slice_bytes(sl), Nat.add(h, w)), take_split(h, Nat.add(h, w), P.slice_bytes(sl), NO.below_sum(h, w))),
    Equal.trans(+List<U32>, List.append(&2, U32, List.take(&2, U32, P.slice_bytes(sl), h), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(Nat.add(h, w), h))), List.append(&2, U32, SL.fixed_parts(pdone, fixedtotal), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(Nat.add(h, w), h))), SL.fixed_parts(List.append(&2, T.Part, pdone, [T.Fixed{List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(Nat.add(h, w), h))}]), fixedtotal),
      Equal.cong(+List<U32>, +List<U32>, ys => List.append(&2, U32, ys, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(Nat.add(h, w), h))), List.take(&2, U32, P.slice_bytes(sl), h), SL.fixed_parts(pdone, fixedtotal), headerbytes),
      Equal.sym(+List<U32>, SL.fixed_parts(List.append(&2, T.Part, pdone, [T.Fixed{List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(Nat.add(h, w), h))}]), fixedtotal), List.append(&2, U32, SL.fixed_parts(pdone, fixedtotal), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(Nat.add(h, w), h))), fixed_parts_snoc_fixed(pdone, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(Nat.add(h, w), h)), fixedtotal))))

# ---------------------------------------------------------------------------
# One walk step over a fixed-width field: the child is decoded in place at the
# header cursor, and the decoded prefix grows by one fixed part.
law step_fixed:
  for +fields: T.Schema
  for +fs: T.Schema
  for +hh: T.Schema
  for +tt: T.Schema
  for +fsr: T.Schema
  for +nk: Nat
  for +base: Nat
  for +krem: Nat
  for +total: Nat
  for split: forest_split(fs, hh, fsr)
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +pos: Nat
  for +w: Nat
  for +pdone: +List<T.Part>
  for +acc: C.CValue
  for +cv: C.CValue
  for +hdr: P.Slice
  for +crest: P.Slice
  for +pay: P.Slice
  for +width: {SS.fixed_size(hh) == Some{w} : Maybe<&2, Nat>}
  for +childparts: {SC.parts(C.to_value(cv), hh) == Some{[SC.fragment(SS.fixed_size(hh), List.take(&2, U32, P.slice_bytes(hdr), w))]} : Maybe<&2, +List<T.Part>>}
  for +childrest: {P.slice_bytes(crest) == List.drop(&2, U32, P.slice_bytes(hdr), w) : +List<U32>}
  for +wfcrest: {List.length(&2, U32, P.slice_bytes(crest)) == P.slice_size(crest) : Nat}
  for +hs: Nat
  for rec: walk_goal(fields, fsr, sl, end, fixedtotal, hs, Nat.add(h, w), pos, List.append(&2, T.Part, pdone, [T.Fixed{List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), w)}]), crest, pay, C.CCons{cv, acc}, 1n+base, krem, total, D.go(tt, 0n, nk, D.Walk{True{}, D.Parsed{cv, crest}, pay, pos, end, acc}))
  walk_goal(fields, fs, sl, end, fixedtotal, Nat.add(w, hs), h, pos, pdone, hdr, pay, acc, base, 1n+krem, total, D.go(tt, 0n, nk, D.Walk{True{}, D.Parsed{cv, crest}, pay, pos, end, acc}))
def step_fixed(fields, fs, hh, tt, fsr, nk, base, krem, total, split, sl, end, fixedtotal, h, pos, w, pdone, acc, cv, hdr, crest, pay, width, childparts, childrest, wfcrest, hs, rec):
  wfsl => roomsl => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => headerbytes => payloadbytes => validdone => fixle => posle => counted => countctx => context =>
    +bytes = List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), w)
    +remaining2 = remaining_fixed(h, w, hs, fixedtotal, remaining)
    +bound = NO.transitive(Nat.add(h, w), fixedtotal, P.slice_size(sl), header_bound(h, w, hs, fixedtotal, remaining2), NO.transitive(fixedtotal, pos, P.slice_size(sl), fixle, NO.transitive(pos, end, P.slice_size(sl), posle, roomsl)))
    +lenbytes = PK.take_length(List.drop(&2, U32, P.slice_bytes(sl), h), w, child_room(sl, h, w, wfsl, bound))
    +domain = CL.domain_take(List.drop(&2, U32, P.slice_bytes(sl), h), w, CL.domain_drop(P.slice_bytes(sl), h, CL.slice_domain(sl)))
    +hdrbytes = Equal.cong(+List<U32>, +List<U32>, ys => List.take(&2, U32, ys, w), P.slice_bytes(hdr), List.drop(&2, U32, P.slice_bytes(sl), h), hdrview)
    +childfixed = child_fixed_parts(hh, cv, hdr, w, bytes, width, hdrbytes, childparts)
    rec(wfsl, roomsl,
      Equal.trans(+List<U32>, P.slice_bytes(crest), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), w), List.drop(&2, U32, P.slice_bytes(sl), Nat.add(h, w)),
        Equal.trans(+List<U32>, P.slice_bytes(crest), List.drop(&2, U32, P.slice_bytes(hdr), w), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), w), childrest, Equal.cong(+List<U32>, +List<U32>, ys => List.drop(&2, U32, ys, w), P.slice_bytes(hdr), List.drop(&2, U32, P.slice_bytes(sl), h), hdrview)),
        W.drop_drop(P.slice_bytes(sl), h, w)),
      wfcrest,
      payview,
      wfpay,
      fixed_size_snoc(pdone, bytes, h, w, sizedone, lenbytes),
      remaining2,
      Equal.trans(Nat, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, pdone, [T.Fixed{bytes}])))), Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), pos,
        Equal.cong(+List<U32>, Nat, ys => Nat.add(fixedtotal, List.length(&2, U32, ys)), SL.payloads(List.append(&2, T.Part, pdone, [T.Fixed{bytes}])), SL.payloads(pdone), payloads_snoc_fixed(pdone, bytes)),
        position),
      header_step(sl, h, w, fixedtotal, pdone, headerbytes),
      Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(pos, fixedtotal)), SL.payloads(pdone), SL.payloads(List.append(&2, T.Part, pdone, [T.Fixed{bytes}])),
        payloadbytes,
        Equal.sym(+List<U32>, SL.payloads(List.append(&2, T.Part, pdone, [T.Fixed{bytes}])), SL.payloads(pdone), payloads_snoc_fixed(pdone, bytes))),
      bytes_valid_snoc_fixed(pdone, bytes, validdone, domain),
      fixle, posle,
      Equal.trans(Nat, Nat.add(1n+base, krem), Nat.add(base, 1n+krem), total, Equal.sym(Nat, Nat.add(base, 1n+krem), Nat.add(1n+base, krem), PKG.add_succ(base, krem)), counted),
      count_step(acc, base, cv, countctx),
      context_step(fields, fs, hh, fsr, pdone, acc, cv, [T.Fixed{bytes}], split, childfixed, context))

# ---------------------------------------------------------------------------
# An offset read from the header re-encodes to exactly the four header bytes
# it was read from: little-endian digits are canonical on byte strings.
law read_limb_at:
  for +xs: +List<U32>
  for +ys: +List<U32>
  for +e0: {IP.at(xs, 0n) == IP.at(ys, 0n) : U32}
  for +e1: {IP.at(xs, 1n) == IP.at(ys, 1n) : U32}
  for +e2: {IP.at(xs, 2n) == IP.at(ys, 2n) : U32}
  for +e3: {IP.at(xs, 3n) == IP.at(ys, 3n) : U32}
  {IP.read_limb(xs, 0n) == IP.read_limb(ys, 0n) : U32}
def read_limb_at(xs, ys, e0, e1, e2, e3):
  %e0 : {IP.read_limb(xs, 0n) == U32.or(_, U32.or(U32.shln(IP.at(ys, 1n), 8n), U32.or(U32.shln(IP.at(ys, 2n), 16n), U32.shln(IP.at(ys, 3n), 24n)))) : U32}
  %e1 : {IP.read_limb(xs, 0n) == U32.or(IP.at(xs, 0n), U32.or(U32.shln(_, 8n), U32.or(U32.shln(IP.at(ys, 2n), 16n), U32.shln(IP.at(ys, 3n), 24n)))) : U32}
  %e2 : {IP.read_limb(xs, 0n) == U32.or(IP.at(xs, 0n), U32.or(U32.shln(IP.at(xs, 1n), 8n), U32.or(U32.shln(_, 16n), U32.shln(IP.at(ys, 3n), 24n)))) : U32}
  %e3 : {IP.read_limb(xs, 0n) == U32.or(IP.at(xs, 0n), U32.or(U32.shln(IP.at(xs, 1n), 8n), U32.or(U32.shln(IP.at(xs, 2n), 16n), U32.shln(_, 24n)))) : U32}
  {==}

law read_limb_take:
  for +xs: +List<U32>
  {IP.read_limb(List.take(&2, U32, xs, 4n), 0n) == IP.read_limb(xs, 0n) : U32}
def read_limb_take(xs):
  read_limb_at(List.take(&2, U32, xs, 4n), xs,
    PK.at_take_low(xs, 4n, 0n, {==}), PK.at_take_low(xs, 4n, 1n, {==}),
    PK.at_take_low(xs, 4n, 2n, {==}), PK.at_take_low(xs, 4n, 3n, {==}))

law offset_value:
  for +s: P.Slice
  for +four: +List<U32>
  for +len4: {List.length(&2, U32, four) == 4n : Nat}
  for +dom4: {SP.bytes_domain(four) == True{} : Bool}
  for +same: {four == List.take(&2, U32, P.slice_bytes(s), 4n) : +List<U32>}
  {P.offset_at(s) == N.value(four) : Nat}
def offset_value(s, four, len4, dom4, same):
  Equal.trans(Nat, P.offset_at(s), U32.to_nat(IP.read_limb(P.slice_bytes(s), 0n)), N.value(four),
    PK.offset_at_view(s),
    Equal.trans(Nat, U32.to_nat(IP.read_limb(P.slice_bytes(s), 0n)), U32.to_nat(SP.limb_value(four, 0n)), N.value(four),
      Equal.cong(U32, Nat, u => U32.to_nat(u), IP.read_limb(P.slice_bytes(s), 0n), SP.limb_value(four, 0n),
        Equal.trans(U32, IP.read_limb(P.slice_bytes(s), 0n), IP.read_limb(four, 0n), SP.limb_value(four, 0n),
          Equal.trans(U32, IP.read_limb(P.slice_bytes(s), 0n), IP.read_limb(List.take(&2, U32, P.slice_bytes(s), 4n), 0n), IP.read_limb(four, 0n),
            Equal.sym(U32, IP.read_limb(List.take(&2, U32, P.slice_bytes(s), 4n), 0n), IP.read_limb(P.slice_bytes(s), 0n), read_limb_take(P.slice_bytes(s))),
            Equal.cong(+List<U32>, U32, ys => IP.read_limb(ys, 0n), List.take(&2, U32, P.slice_bytes(s), 4n), four, Equal.sym(+List<U32>, four, List.take(&2, U32, P.slice_bytes(s), 4n), same))),
          Integer.read_limb_correct(four, 0n, dom4))),
      LOV.scope_value(four, CL.scope_from_domain(four, 4n, len4, dom4))))

law offset_bytes_canonical:
  for +s: P.Slice
  for +room: {Nat.is_le(4n, List.length(&2, U32, P.slice_bytes(s))) == True{} : Bool}
  {N.digits(4n, P.offset_at(s)) == List.take(&2, U32, P.slice_bytes(s), 4n) : +List<U32>}
def offset_bytes_canonical(s, room):
  +four = List.take(&2, U32, P.slice_bytes(s), 4n)
  +len4 = PK.take_length(P.slice_bytes(s), 4n, room)
  +dom4 = CL.domain_take(P.slice_bytes(s), 4n, CL.slice_domain(s))
  Equal.trans(+List<U32>, N.digits(4n, P.offset_at(s)), N.digits(4n, N.value(four)), four,
    Equal.cong(Nat, +List<U32>, k => N.digits(4n, k), P.offset_at(s), N.value(four), offset_value(s, four, len4, dom4, {==})),
    OD.digits_of_value(4n, four, len4, dom4))

# ---------------------------------------------------------------------------
# Extending the decoded prefix by one variable-width child: the header gains a
# four-byte offset and the payload region gains the child's bytes.
law fixed_size_snoc_variable:
  for +ps: +List<T.Part>
  for +xs: +List<U32>
  for +h: Nat
  for +sized: {SL.fixed_size(ps) == h : Nat}
  {SL.fixed_size(List.append(&2, T.Part, ps, [T.Variable{xs}])) == Nat.add(h, 4n) : Nat}
def fixed_size_snoc_variable(ps, xs, h, sized):
  %sized : {SL.fixed_size(List.append(&2, T.Part, ps, [T.Variable{xs}])) == Nat.add(_, 4n) : Nat}
  PA.fixed_size_append(ps, [T.Variable{xs}])

law payloads_snoc_variable:
  for +ps: +List<T.Part>
  for +xs: +List<U32>
  {SL.payloads(List.append(&2, T.Part, ps, [T.Variable{xs}])) == List.append(&2, U32, SL.payloads(ps), xs) : +List<U32>}
def payloads_snoc_variable(ps, xs):
  %L.append_empty(U32, xs) : {SL.payloads(List.append(&2, T.Part, ps, [T.Variable{xs}])) == List.append(&2, U32, SL.payloads(ps), _) : +List<U32>}
  PA.payloads_append(ps, [T.Variable{xs}])

law fixed_parts_snoc_variable:
  for +ps: +List<T.Part>
  for +xs: +List<U32>
  for +off: Nat
  {SL.fixed_parts(List.append(&2, T.Part, ps, [T.Variable{xs}]), off) == List.append(&2, U32, SL.fixed_parts(ps, off), N.digits(4n, Nat.add(off, List.length(&2, U32, SL.payloads(ps))))) : +List<U32>}
def fixed_parts_snoc_variable(ps, xs, off):
  %L.append_empty(U32, N.digits(4n, Nat.add(off, List.length(&2, U32, SL.payloads(ps))))) : {SL.fixed_parts(List.append(&2, T.Part, ps, [T.Variable{xs}]), off) == List.append(&2, U32, SL.fixed_parts(ps, off), _) : +List<U32>}
  PA.fixed_parts_append(ps, [T.Variable{xs}], off)

law bytes_valid_snoc_variable:
  for +ps: +List<T.Part>
  for +xs: +List<U32>
  for +valid: {SL.bytes_valid(ps) == True{} : Bool}
  for +domain: {SP.bytes_domain(xs) == True{} : Bool}
  {SL.bytes_valid(List.append(&2, T.Part, ps, [T.Variable{xs}])) == True{} : Bool}
def bytes_valid_snoc_variable(ps, xs, valid, domain):
  %valid : {SL.bytes_valid(List.append(&2, T.Part, ps, [T.Variable{xs}])) == Bool.and(_, True{}) : Bool}
  %domain : {SL.bytes_valid(List.append(&2, T.Part, ps, [T.Variable{xs}])) == Bool.and(SL.bytes_valid(ps), Bool.and(_, True{})) : Bool}
  PA.bytes_valid_append(ps, [T.Variable{xs}])

law add_sub:
  for +a: Nat
  for +b: Nat
  for +order: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.add(a, Nat.sub(b, a)) == b : Nat}
def add_sub(a, b, order):
  match a b:
    case 0n b2: PK.sub_zero(b2)
    case 1n+p 0n: Empty.absurd({Nat.add(1n+p, Nat.sub(0n, 1n+p)) == 0n : Nat}, F.false_true(order))
    case 1n+p 1n+q: Equal.cong(Nat, Nat, n => 1n+n, Nat.add(p, Nat.sub(q, p)), q, add_sub(p, q, order))

law zero_sub:
  for +k: Nat
  {Nat.sub(0n, k) == 0n : Nat}
def zero_sub(k):
  match k:
    case 0n: {==}
    case 1n+r: {==}

law sub_sub:
  for +c: Nat
  for +a: Nat
  for +b: Nat
  for +order: {Nat.is_le(c, a) == True{} : Bool}
  {Nat.sub(Nat.sub(b, c), Nat.sub(a, c)) == Nat.sub(b, a) : Nat}
def sub_sub(c, a, b, order):
  match c a b:
    case 0n a2 b2:
      %Equal.sym(Nat, Nat.sub(a2, 0n), a2, PK.sub_zero(a2)) : {Nat.sub(Nat.sub(b2, 0n), _) == Nat.sub(b2, a2) : Nat}
      %Equal.sym(Nat, Nat.sub(b2, 0n), b2, PK.sub_zero(b2)) : {Nat.sub(_, a2) == Nat.sub(b2, a2) : Nat}
      {==}
    case 1n+p 0n b2: Empty.absurd({Nat.sub(Nat.sub(b2, 1n+p), Nat.sub(0n, 1n+p)) == Nat.sub(b2, 0n) : Nat}, F.false_true(order))
    case 1n+p 1n+q 0n: zero_sub(Nat.sub(q, p))
    case 1n+p 1n+q 1n+r: sub_sub(p, q, r, order)

law child_variable_parts:
  for +hh: T.Schema
  for +cv: C.CValue
  for +pay: P.Slice
  for +len: Nat
  for +bytes: +List<U32>
  for +width: {SS.fixed_size(hh) == None{} : Maybe<&2, Nat>}
  for +same: {List.take(&2, U32, P.slice_bytes(pay), len) == bytes : +List<U32>}
  for +childparts: {SC.parts(C.to_value(cv), hh) == Some{[SC.fragment(SS.fixed_size(hh), List.take(&2, U32, P.slice_bytes(pay), len))]} : Maybe<&2, +List<T.Part>>}
  {SC.parts(C.to_value(cv), hh) == Some{[T.Variable{bytes}]} : Maybe<&2, +List<T.Part>>}
def child_variable_parts(hh, cv, pay, len, bytes, width, same, childparts):
  %width : {SC.parts(C.to_value(cv), hh) == Some{[SC.fragment(_, bytes)]} : Maybe<&2, +List<T.Part>>}
  %same : {SC.parts(C.to_value(cv), hh) == Some{[SC.fragment(SS.fixed_size(hh), _)]} : Maybe<&2, +List<T.Part>>}
  childparts

# The payload cursor after a variable child sits exactly at the next offset.
law payload_advance:
  for +sl: P.Slice
  for +pay: P.Slice
  for +crest: P.Slice
  for +pos: Nat
  for +stop: Nat
  for +order: {Nat.is_le(pos, stop) == True{} : Bool}
  for +payview: {P.slice_bytes(pay) == List.drop(&2, U32, P.slice_bytes(sl), pos) : +List<U32>}
  for +childrest: {P.slice_bytes(crest) == List.drop(&2, U32, P.slice_bytes(pay), Nat.sub(stop, pos)) : +List<U32>}
  {P.slice_bytes(crest) == List.drop(&2, U32, P.slice_bytes(sl), stop) : +List<U32>}
def payload_advance(sl, pay, crest, pos, stop, order, payview, childrest):
  %add_sub(pos, stop, order) : {P.slice_bytes(crest) == List.drop(&2, U32, P.slice_bytes(sl), _) : +List<U32>}
  Equal.trans(+List<U32>, P.slice_bytes(crest), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), pos), Nat.sub(stop, pos)), List.drop(&2, U32, P.slice_bytes(sl), Nat.add(pos, Nat.sub(stop, pos))),
    Equal.trans(+List<U32>, P.slice_bytes(crest), List.drop(&2, U32, P.slice_bytes(pay), Nat.sub(stop, pos)), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), pos), Nat.sub(stop, pos)),
      childrest,
      Equal.cong(+List<U32>, +List<U32>, ys => List.drop(&2, U32, ys, Nat.sub(stop, pos)), P.slice_bytes(pay), List.drop(&2, U32, P.slice_bytes(sl), pos), payview)),
    W.drop_drop(P.slice_bytes(sl), pos, Nat.sub(stop, pos)))

law sub_monotone:
  for +c: Nat
  for +a: Nat
  for +b: Nat
  for +order: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(Nat.sub(a, c), Nat.sub(b, c)) == True{} : Bool}
def sub_monotone(c, a, b, order):
  match c a b:
    case 0n a2 b2:
      %Equal.sym(Nat, Nat.sub(a2, 0n), a2, PK.sub_zero(a2)) : {Nat.is_le(_, Nat.sub(b2, 0n)) == True{} : Bool}
      %Equal.sym(Nat, Nat.sub(b2, 0n), b2, PK.sub_zero(b2)) : {Nat.is_le(a2, _) == True{} : Bool}
      order
    case 1n+p 0n b2:
      %Equal.sym(Nat, Nat.sub(0n, 1n+p), 0n, zero_sub(1n+p)) : {Nat.is_le(_, Nat.sub(b2, 1n+p)) == True{} : Bool}
      NO.zero_le(Nat.sub(b2, 1n+p))
    case 1n+p 1n+q 0n: Empty.absurd({Nat.is_le(Nat.sub(1n+q, 1n+p), Nat.sub(0n, 1n+p)) == True{} : Bool}, F.false_true(order))
    case 1n+p 1n+q 1n+r: sub_monotone(p, q, r, order)

law header_step_variable:
  for +sl: P.Slice
  for +hdr: P.Slice
  for +h: Nat
  for +fixedtotal: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +bytes: +List<U32>
  for +hdrview: {P.slice_bytes(hdr) == List.drop(&2, U32, P.slice_bytes(sl), h) : +List<U32>}
  for +headerbytes: {List.take(&2, U32, P.slice_bytes(sl), h) == SL.fixed_parts(pdone, fixedtotal) : +List<U32>}
  for +position: {Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))) == pos : Nat}
  for +offsetval: {P.offset_at(hdr) == pos : Nat}
  for +room: {Nat.is_le(4n, List.length(&2, U32, P.slice_bytes(hdr))) == True{} : Bool}
  {List.take(&2, U32, P.slice_bytes(sl), Nat.add(h, 4n)) == SL.fixed_parts(List.append(&2, T.Part, pdone, [T.Variable{bytes}]), fixedtotal) : +List<U32>}
def header_step_variable(sl, hdr, h, fixedtotal, pos, pdone, bytes, hdrview, headerbytes, position, offsetval, room):
  +digits_eq = Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), 4n), List.take(&2, U32, P.slice_bytes(hdr), 4n), N.digits(4n, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone)))),
    Equal.cong(+List<U32>, +List<U32>, ys => List.take(&2, U32, ys, 4n), List.drop(&2, U32, P.slice_bytes(sl), h), P.slice_bytes(hdr), Equal.sym(+List<U32>, P.slice_bytes(hdr), List.drop(&2, U32, P.slice_bytes(sl), h), hdrview)),
    Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(hdr), 4n), N.digits(4n, P.offset_at(hdr)), N.digits(4n, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone)))),
      Equal.sym(+List<U32>, N.digits(4n, P.offset_at(hdr)), List.take(&2, U32, P.slice_bytes(hdr), 4n), offset_bytes_canonical(hdr, room)),
      Equal.cong(Nat, +List<U32>, k => N.digits(4n, k), P.offset_at(hdr), Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), Equal.trans(Nat, P.offset_at(hdr), pos, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), offsetval, Equal.sym(Nat, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), pos, position)))))
  %sub_add(h, 4n) : {List.take(&2, U32, P.slice_bytes(sl), Nat.add(h, 4n)) == SL.fixed_parts(List.append(&2, T.Part, pdone, [T.Variable{bytes}]), fixedtotal) : +List<U32>}
  Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(sl), Nat.add(h, 4n)), List.append(&2, U32, List.take(&2, U32, P.slice_bytes(sl), h), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), 4n)), SL.fixed_parts(List.append(&2, T.Part, pdone, [T.Variable{bytes}]), fixedtotal),
    Equal.sym(+List<U32>, List.append(&2, U32, List.take(&2, U32, P.slice_bytes(sl), h), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), 4n)), List.take(&2, U32, P.slice_bytes(sl), Nat.add(h, 4n)),
      Equal.trans(+List<U32>, List.append(&2, U32, List.take(&2, U32, P.slice_bytes(sl), h), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), 4n)), List.append(&2, U32, List.take(&2, U32, P.slice_bytes(sl), h), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), Nat.sub(Nat.add(h, 4n), h))), List.take(&2, U32, P.slice_bytes(sl), Nat.add(h, 4n)),
        Equal.cong(Nat, +List<U32>, k => List.append(&2, U32, List.take(&2, U32, P.slice_bytes(sl), h), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), k)), 4n, Nat.sub(Nat.add(h, 4n), h), Equal.sym(Nat, Nat.sub(Nat.add(h, 4n), h), 4n, sub_add(h, 4n))),
        take_split(h, Nat.add(h, 4n), P.slice_bytes(sl), NO.below_sum(h, 4n)))),
    Equal.trans(+List<U32>, List.append(&2, U32, List.take(&2, U32, P.slice_bytes(sl), h), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), 4n)), List.append(&2, U32, SL.fixed_parts(pdone, fixedtotal), N.digits(4n, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))))), SL.fixed_parts(List.append(&2, T.Part, pdone, [T.Variable{bytes}]), fixedtotal),
      Equal.trans(+List<U32>, List.append(&2, U32, List.take(&2, U32, P.slice_bytes(sl), h), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), 4n)), List.append(&2, U32, SL.fixed_parts(pdone, fixedtotal), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), 4n)), List.append(&2, U32, SL.fixed_parts(pdone, fixedtotal), N.digits(4n, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))))),
        Equal.cong(+List<U32>, +List<U32>, ys => List.append(&2, U32, ys, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), 4n)), List.take(&2, U32, P.slice_bytes(sl), h), SL.fixed_parts(pdone, fixedtotal), headerbytes),
        Equal.cong(+List<U32>, +List<U32>, ys => List.append(&2, U32, SL.fixed_parts(pdone, fixedtotal), ys), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), 4n), N.digits(4n, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone)))), digits_eq)),
      Equal.sym(+List<U32>, SL.fixed_parts(List.append(&2, T.Part, pdone, [T.Variable{bytes}]), fixedtotal), List.append(&2, U32, SL.fixed_parts(pdone, fixedtotal), N.digits(4n, Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))))), fixed_parts_snoc_variable(pdone, bytes, fixedtotal))))

law payload_step_variable:
  for +sl: P.Slice
  for +fixedtotal: Nat
  for +pos: Nat
  for +stop: Nat
  for +pdone: +List<T.Part>
  for +payloadbytes: {List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(pos, fixedtotal)) == SL.payloads(pdone) : +List<U32>}
  for +fixle: {Nat.is_le(fixedtotal, pos) == True{} : Bool}
  for +posstop: {Nat.is_le(pos, stop) == True{} : Bool}
  {List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(stop, fixedtotal)) == SL.payloads(List.append(&2, T.Part, pdone, [T.Variable{List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), pos), Nat.sub(stop, pos))}])) : +List<U32>}
def payload_step_variable(sl, fixedtotal, pos, stop, pdone, payloadbytes, fixle, posstop):
  +bytes = List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), pos), Nat.sub(stop, pos))
  +middle = Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(pos, fixedtotal)), Nat.sub(Nat.sub(stop, fixedtotal), Nat.sub(pos, fixedtotal))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), pos), Nat.sub(Nat.sub(stop, fixedtotal), Nat.sub(pos, fixedtotal))), bytes,
    Equal.cong(+List<U32>, +List<U32>, ys => List.take(&2, U32, ys, Nat.sub(Nat.sub(stop, fixedtotal), Nat.sub(pos, fixedtotal))), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(pos, fixedtotal)), List.drop(&2, U32, P.slice_bytes(sl), pos),
      Equal.trans(+List<U32>, List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(pos, fixedtotal)), List.drop(&2, U32, P.slice_bytes(sl), Nat.add(fixedtotal, Nat.sub(pos, fixedtotal))), List.drop(&2, U32, P.slice_bytes(sl), pos),
        W.drop_drop(P.slice_bytes(sl), fixedtotal, Nat.sub(pos, fixedtotal)),
        Equal.cong(Nat, +List<U32>, k => List.drop(&2, U32, P.slice_bytes(sl), k), Nat.add(fixedtotal, Nat.sub(pos, fixedtotal)), pos, add_sub(fixedtotal, pos, fixle)))),
    Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), pos), k), Nat.sub(Nat.sub(stop, fixedtotal), Nat.sub(pos, fixedtotal)), Nat.sub(stop, pos), sub_sub(fixedtotal, pos, stop, fixle)))
  Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(stop, fixedtotal)), List.append(&2, U32, SL.payloads(pdone), bytes), SL.payloads(List.append(&2, T.Part, pdone, [T.Variable{bytes}])),
    Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(stop, fixedtotal)), List.append(&2, U32, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(pos, fixedtotal)), List.take(&2, U32, List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(pos, fixedtotal)), Nat.sub(Nat.sub(stop, fixedtotal), Nat.sub(pos, fixedtotal)))), List.append(&2, U32, SL.payloads(pdone), bytes),
      Equal.sym(+List<U32>, List.append(&2, U32, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(pos, fixedtotal)), List.take(&2, U32, List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(pos, fixedtotal)), Nat.sub(Nat.sub(stop, fixedtotal), Nat.sub(pos, fixedtotal)))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(stop, fixedtotal)),
        take_split(Nat.sub(pos, fixedtotal), Nat.sub(stop, fixedtotal), List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), sub_monotone(fixedtotal, pos, stop, posstop))),
      Equal.trans(+List<U32>, List.append(&2, U32, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(pos, fixedtotal)), List.take(&2, U32, List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(pos, fixedtotal)), Nat.sub(Nat.sub(stop, fixedtotal), Nat.sub(pos, fixedtotal)))), List.append(&2, U32, SL.payloads(pdone), List.take(&2, U32, List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(pos, fixedtotal)), Nat.sub(Nat.sub(stop, fixedtotal), Nat.sub(pos, fixedtotal)))), List.append(&2, U32, SL.payloads(pdone), bytes),
        Equal.cong(+List<U32>, +List<U32>, ys => List.append(&2, U32, ys, List.take(&2, U32, List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(pos, fixedtotal)), Nat.sub(Nat.sub(stop, fixedtotal), Nat.sub(pos, fixedtotal)))), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(pos, fixedtotal)), SL.payloads(pdone), payloadbytes),
        Equal.cong(+List<U32>, +List<U32>, ys => List.append(&2, U32, SL.payloads(pdone), ys), List.take(&2, U32, List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), fixedtotal), Nat.sub(pos, fixedtotal)), Nat.sub(Nat.sub(stop, fixedtotal), Nat.sub(pos, fixedtotal))), bytes, middle))),
    Equal.sym(+List<U32>, SL.payloads(List.append(&2, T.Part, pdone, [T.Variable{bytes}])), List.append(&2, U32, SL.payloads(pdone), bytes), payloads_snoc_variable(pdone, bytes)))

law hdr_room:
  for +sl: P.Slice
  for +hdr: P.Slice
  for +h: Nat
  for +w: Nat
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +hdrview: {P.slice_bytes(hdr) == List.drop(&2, U32, P.slice_bytes(sl), h) : +List<U32>}
  for +bound: {Nat.is_le(Nat.add(h, w), P.slice_size(sl)) == True{} : Bool}
  {Nat.is_le(w, List.length(&2, U32, P.slice_bytes(hdr))) == True{} : Bool}
def hdr_room(sl, hdr, h, w, wfsl, hdrview, bound):
  %Equal.sym(+List<U32>, P.slice_bytes(hdr), List.drop(&2, U32, P.slice_bytes(sl), h), hdrview) : {Nat.is_le(w, List.length(&2, U32, _)) == True{} : Bool}
  child_room(sl, h, w, wfsl, bound)

law payload_room:
  for +sl: P.Slice
  for +pos: Nat
  for +stop: Nat
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +order: {Nat.is_le(pos, stop) == True{} : Bool}
  for +bound: {Nat.is_le(stop, P.slice_size(sl)) == True{} : Bool}
  {Nat.is_le(Nat.sub(stop, pos), List.length(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), pos))) == True{} : Bool}
def payload_room(sl, pos, stop, wfsl, order, bound):
  child_room(sl, pos, Nat.sub(stop, pos), wfsl,
    (%Equal.sym(Nat, Nat.add(pos, Nat.sub(stop, pos)), stop, add_sub(pos, stop, order)) : {Nat.is_le(_, P.slice_size(sl)) == True{} : Bool}
     bound))

law position_variable:
  for +fixedtotal: Nat
  for +pos: Nat
  for +stop: Nat
  for +pdone: +List<T.Part>
  for +bytes: +List<U32>
  for +position: {Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))) == pos : Nat}
  for +lenbytes: {List.length(&2, U32, bytes) == Nat.sub(stop, pos) : Nat}
  for +order: {Nat.is_le(pos, stop) == True{} : Bool}
  {Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(List.append(&2, T.Part, pdone, [T.Variable{bytes}])))) == stop : Nat}
def position_variable(fixedtotal, pos, stop, pdone, bytes, position, lenbytes, order):
  %Equal.sym(+List<U32>, SL.payloads(List.append(&2, T.Part, pdone, [T.Variable{bytes}])), List.append(&2, U32, SL.payloads(pdone), bytes), payloads_snoc_variable(pdone, bytes)) : {Nat.add(fixedtotal, List.length(&2, U32, _)) == stop : Nat}
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, SL.payloads(pdone), bytes)), Nat.add(List.length(&2, U32, SL.payloads(pdone)), List.length(&2, U32, bytes)), L.append_length(U32, SL.payloads(pdone), bytes)) : {Nat.add(fixedtotal, _) == stop : Nat}
  %Equal.sym(Nat, List.length(&2, U32, bytes), Nat.sub(stop, pos), lenbytes) : {Nat.add(fixedtotal, Nat.add(List.length(&2, U32, SL.payloads(pdone)), _)) == stop : Nat}
  Equal.trans(Nat, Nat.add(fixedtotal, Nat.add(List.length(&2, U32, SL.payloads(pdone)), Nat.sub(stop, pos))), Nat.add(pos, Nat.sub(stop, pos)), stop,
    Equal.trans(Nat, Nat.add(fixedtotal, Nat.add(List.length(&2, U32, SL.payloads(pdone)), Nat.sub(stop, pos))), Nat.add(Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), Nat.sub(stop, pos)), Nat.add(pos, Nat.sub(stop, pos)),
      Equal.sym(Nat, Nat.add(Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), Nat.sub(stop, pos)), Nat.add(fixedtotal, Nat.add(List.length(&2, U32, SL.payloads(pdone)), Nat.sub(stop, pos))), LA.add_associative(fixedtotal, List.length(&2, U32, SL.payloads(pdone)), Nat.sub(stop, pos))),
      Equal.cong(Nat, Nat, k => Nat.add(k, Nat.sub(stop, pos)), Nat.add(fixedtotal, List.length(&2, U32, SL.payloads(pdone))), pos, position)),
    add_sub(pos, stop, order))

# ---------------------------------------------------------------------------
# One walk step over a variable-width field: the header gains the field's
# offset, which the decoder has checked equals the current payload position,
# and the payload region gains the child's bytes.
law step_variable:
  for +fields: T.Schema
  for +fs: T.Schema
  for +hh: T.Schema
  for +tt: T.Schema
  for +fsr: T.Schema
  for +nk: Nat
  for +base: Nat
  for +krem: Nat
  for +total: Nat
  for split: forest_split(fs, hh, fsr)
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +pos: Nat
  for +stop: Nat
  for +pdone: +List<T.Part>
  for +acc: C.CValue
  for +cv: C.CValue
  for +hdr: P.Slice
  for +crest: P.Slice
  for +pay: P.Slice
  for +width: {SS.fixed_size(hh) == None{} : Maybe<&2, Nat>}
  for +childparts: {SC.parts(C.to_value(cv), hh) == Some{[SC.fragment(SS.fixed_size(hh), List.take(&2, U32, P.slice_bytes(pay), Nat.sub(stop, pos)))]} : Maybe<&2, +List<T.Part>>}
  for +childrest: {P.slice_bytes(crest) == List.drop(&2, U32, P.slice_bytes(pay), Nat.sub(stop, pos)) : +List<U32>}
  for +wfcrest: {List.length(&2, U32, P.slice_bytes(crest)) == P.slice_size(crest) : Nat}
  for +hs: Nat
  for +offsetval: {P.offset_at(hdr) == pos : Nat}
  for +posstop: {Nat.is_le(pos, stop) == True{} : Bool}
  for +stople: {Nat.is_le(stop, end) == True{} : Bool}
  for rec: walk_goal(fields, fsr, sl, end, fixedtotal, hs, Nat.add(h, 4n), stop, List.append(&2, T.Part, pdone, [T.Variable{List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), pos), Nat.sub(stop, pos))}]), P.adv(hdr, 4n), crest, C.CCons{cv, acc}, 1n+base, krem, total, D.go(tt, 0n, nk, D.Walk{False{}, D.Parsed{cv, crest}, P.adv(hdr, 4n), stop, end, acc}))
  walk_goal(fields, fs, sl, end, fixedtotal, Nat.add(4n, hs), h, pos, pdone, hdr, pay, acc, base, 1n+krem, total, D.go(tt, 0n, nk, D.Walk{False{}, D.Parsed{cv, crest}, P.adv(hdr, 4n), stop, end, acc}))
def step_variable(fields, fs, hh, tt, fsr, nk, base, krem, total, split, sl, end, fixedtotal, h, pos, stop, pdone, acc, cv, hdr, crest, pay, width, childparts, childrest, wfcrest, hs, offsetval, posstop, stople, rec):
  wfsl => roomsl => hdrview => wfhdr => payview => wfpay => sizedone => remaining => position => headerbytes => payloadbytes => validdone => fixle => posle => counted => countctx => context =>
    +bytes = List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), pos), Nat.sub(stop, pos))
    +remaining2 = remaining_fixed(h, 4n, hs, fixedtotal, remaining)
    +sizele = NO.transitive(fixedtotal, pos, P.slice_size(sl), fixle, NO.transitive(pos, end, P.slice_size(sl), posle, roomsl))
    +bound = NO.transitive(Nat.add(h, 4n), fixedtotal, P.slice_size(sl), header_bound(h, 4n, hs, fixedtotal, remaining2), sizele)
    +stopsize = NO.transitive(stop, end, P.slice_size(sl), stople, roomsl)
    +lenbytes = PK.take_length(List.drop(&2, U32, P.slice_bytes(sl), pos), Nat.sub(stop, pos), payload_room(sl, pos, stop, wfsl, posstop, stopsize))
    +domain = CL.domain_take(List.drop(&2, U32, P.slice_bytes(sl), pos), Nat.sub(stop, pos), CL.domain_drop(P.slice_bytes(sl), pos, CL.slice_domain(sl)))
    +paybytes = Equal.cong(+List<U32>, +List<U32>, ys => List.take(&2, U32, ys, Nat.sub(stop, pos)), P.slice_bytes(pay), List.drop(&2, U32, P.slice_bytes(sl), pos), payview)
    rec(wfsl, roomsl,
      Equal.trans(+List<U32>, P.slice_bytes(P.adv(hdr, 4n)), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), 4n), List.drop(&2, U32, P.slice_bytes(sl), Nat.add(h, 4n)),
        Equal.trans(+List<U32>, P.slice_bytes(P.adv(hdr, 4n)), List.drop(&2, U32, P.slice_bytes(hdr), 4n), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), 4n),
          PK.adv_view(hdr, 4n),
          Equal.cong(+List<U32>, +List<U32>, ys => List.drop(&2, U32, ys, 4n), P.slice_bytes(hdr), List.drop(&2, U32, P.slice_bytes(sl), h), hdrview)),
        W.drop_drop(P.slice_bytes(sl), h, 4n)),
      PK.wf_adv(hdr, 4n, wfhdr),
      payload_advance(sl, pay, crest, pos, stop, posstop, payview, childrest),
      wfcrest,
      fixed_size_snoc_variable(pdone, bytes, h, sizedone),
      remaining2,
      position_variable(fixedtotal, pos, stop, pdone, bytes, position, lenbytes, posstop),
      header_step_variable(sl, hdr, h, fixedtotal, pos, pdone, bytes, hdrview, headerbytes, position, offsetval, hdr_room(sl, hdr, h, 4n, wfsl, hdrview, bound)),
      payload_step_variable(sl, fixedtotal, pos, stop, pdone, payloadbytes, fixle, posstop),
      bytes_valid_snoc_variable(pdone, bytes, validdone, domain),
      NO.transitive(fixedtotal, pos, stop, fixle, posstop), stople,
      Equal.trans(Nat, Nat.add(1n+base, krem), Nat.add(base, 1n+krem), total, Equal.sym(Nat, Nat.add(base, 1n+krem), Nat.add(1n+base, krem), PKG.add_succ(base, krem)), counted),
      count_step(acc, base, cv, countctx),
      context_step(fields, fs, hh, fsr, pdone, acc, cv, [T.Variable{bytes}], split, child_variable_parts(hh, cv, pay, Nat.sub(stop, pos), bytes, width, paybytes, childparts), context))

# ---------------------------------------------------------------------------
# From a completed walk to the region's encoding: the specification's layout
# encoding of the decoded parts is exactly the region bytes.
law sub_self:
  for +a: Nat
  {Nat.sub(a, a) == 0n : Nat}
def sub_self(a):
  match a:
    case 0n: {==}
    case 1n+p: sub_self(p)

law region_length:
  for +sl: P.Slice
  for +n: Nat
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +roomsl: {Nat.is_le(n, P.slice_size(sl)) == True{} : Bool}
  {List.length(&2, U32, List.take(&2, U32, P.slice_bytes(sl), n)) == n : Nat}
def region_length(sl, n, wfsl, roomsl):
  PK.take_length(P.slice_bytes(sl), n, CL.sized_by_wf(sl, n, wfsl, roomsl))

law layout_total:
  for +ps: +List<T.Part>
  for +sl: P.Slice
  for +n: Nat
  for +ft: Nat
  for +sized: {SL.fixed_size(ps) == ft : Nat}
  for +bytes: {List.append(&2, U32, SL.fixed_parts(ps, ft), SL.payloads(ps)) == List.take(&2, U32, P.slice_bytes(sl), n) : +List<U32>}
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +roomsl: {Nat.is_le(n, P.slice_size(sl)) == True{} : Bool}
  {Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))) == n : Nat}
def layout_total(ps, sl, n, ft, sized, bytes, wfsl, roomsl):
  Equal.trans(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, ft), SL.payloads(ps))), n,
    Equal.trans(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), Nat.add(List.length(&2, U32, SL.fixed_parts(ps, ft)), List.length(&2, U32, SL.payloads(ps))), List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, ft), SL.payloads(ps))),
      Equal.cong(Nat, Nat, k => Nat.add(k, List.length(&2, U32, SL.payloads(ps))), SL.fixed_size(ps), List.length(&2, U32, SL.fixed_parts(ps, ft)), Equal.sym(Nat, List.length(&2, U32, SL.fixed_parts(ps, ft)), SL.fixed_size(ps), LA.fixed_parts_length(ps, ft))),
      Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, ft), SL.payloads(ps))), Nat.add(List.length(&2, U32, SL.fixed_parts(ps, ft)), List.length(&2, U32, SL.payloads(ps))), L.append_length(U32, SL.fixed_parts(ps, ft), SL.payloads(ps)))),
    Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, ft), SL.payloads(ps))), List.length(&2, U32, List.take(&2, U32, P.slice_bytes(sl), n)), n,
      Equal.cong(+List<U32>, Nat, ys => List.length(&2, U32, ys), List.append(&2, U32, SL.fixed_parts(ps, ft), SL.payloads(ps)), List.take(&2, U32, P.slice_bytes(sl), n), bytes),
      region_length(sl, n, wfsl, roomsl)))

law layout_encoding:
  for +ps: +List<T.Part>
  for +sl: P.Slice
  for +n: Nat
  for +ft: Nat
  for +sized: {SL.fixed_size(ps) == ft : Nat}
  for +valid: {SL.bytes_valid(ps) == True{} : Bool}
  for +bytes: {List.append(&2, U32, SL.fixed_parts(ps, ft), SL.payloads(ps)) == List.take(&2, U32, P.slice_bytes(sl), n) : +List<U32>}
  for +fits: {N.fits(4n, n) == True{} : Bool}
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +roomsl: {Nat.is_le(n, P.slice_size(sl)) == True{} : Bool}
  {SL.encoding(ps) == Some{List.take(&2, U32, P.slice_bytes(sl), n)} : Maybe<&2, +List<U32>>}
def layout_encoding(ps, sl, n, ft, sized, valid, bytes, fits, wfsl, roomsl):
  +cond = V.and_true(SL.bytes_valid(ps), N.fits(4n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))), valid,
    Equal.trans(Bool, N.fits(4n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))), N.fits(4n, n), True{},
      Equal.cong(Nat, Bool, k => N.fits(4n, k), Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n, layout_total(ps, sl, n, ft, sized, bytes, wfsl, roomsl)),
      fits))
  Equal.trans(Maybe<&2, +List<U32>>, SL.encoding(ps), Some{List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))}, Some{List.take(&2, U32, P.slice_bytes(sl), n)},
    Equal.cong(Bool, Maybe<&2, +List<U32>>, b => SP.optional(b, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))), Bool.and(SL.bytes_valid(ps), N.fits(4n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))))), True{}, cond),
    Equal.trans(Maybe<&2, +List<U32>>, Some{List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))}, Some{List.append(&2, U32, SL.fixed_parts(ps, ft), SL.payloads(ps))}, Some{List.take(&2, U32, P.slice_bytes(sl), n)},
      Equal.cong(Nat, Maybe<&2, +List<U32>>, k => Some{List.append(&2, U32, SL.fixed_parts(ps, k), SL.payloads(ps))}, SL.fixed_size(ps), ft, sized),
      Equal.cong(+List<U32>, Maybe<&2, +List<U32>>, ys => Some{ys}, List.append(&2, U32, SL.fixed_parts(ps, ft), SL.payloads(ps)), List.take(&2, U32, P.slice_bytes(sl), n), bytes)))

# ---------------------------------------------------------------------------
# A container region: the completed walk's parts aggregate, under the frozen
# specification, to exactly the region's bytes.
law container_sound:
  for +names: +List<String>
  for +fields: T.Schema
  for +sl: P.Slice
  for +n: Nat
  for +ft: Nat
  for +v: C.CValue
  for +rest: P.Slice
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +roomsl: {Nat.is_le(n, P.slice_size(sl)) == True{} : Bool}
  for +fitsn: {D.fits(n) == True{} : Bool}
  for +total: Nat
  for res: walk_result(fields, sl, n, ft, total, D.Parsed{v, rest})
  CL.region_sound(T.Container{names, fields}, n, sl, D.Parsed{C.CSeq{v}, rest})
def container_sound(names, fields, sl, n, ft, v, rest, wfsl, roomsl, fitsn, total, res):
  (+ps, (parts_eq, (sized, (valid, (bytes, (restview, (wfrest, counted))))))) = res
  (%Equal.sym(Maybe<&2, +List<T.Part>>, SC.parts(C.to_value(v), fields), Some{ps}, parts_eq) : {SC.aggregate(_, SS.fixed_size(fields)) == Some{[SC.fragment(SS.fixed_size(fields), List.take(&2, U32, P.slice_bytes(sl), n))]} : Maybe<&2, +List<T.Part>>}
   Equal.cong(Maybe<&2, +List<U32>>, Maybe<&2, +List<T.Part>>, e => SC.one(e, SS.fixed_size(fields)), SL.encoding(ps), Some{List.take(&2, U32, P.slice_bytes(sl), n)},
     layout_encoding(ps, sl, n, ft, sized, valid, bytes,
       Equal.trans(Bool, N.fits(4n, n), D.fits(n), True{}, Equal.sym(Bool, D.fits(n), N.fits(4n, n), CL.fits_bridge(n)), fitsn),
       wfsl, roomsl)),
   (restview, wfrest))

law progressive_container_sound:
  for +names: +List<String>
  for +active: +List<Bool>
  for +fields: T.Schema
  for +sl: P.Slice
  for +n: Nat
  for +ft: Nat
  for +v: C.CValue
  for +rest: P.Slice
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +roomsl: {Nat.is_le(n, P.slice_size(sl)) == True{} : Bool}
  for +fitsn: {D.fits(n) == True{} : Bool}
  for +total: Nat
  for res: walk_result(fields, sl, n, ft, total, D.Parsed{v, rest})
  CL.region_sound(T.ProgressiveContainer{names, fields, active}, n, sl, D.Parsed{C.CSeq{v}, rest})
def progressive_container_sound(names, active, fields, sl, n, ft, v, rest, wfsl, roomsl, fitsn, total, res):
  (+ps, (parts_eq, (sized, (valid, (bytes, (restview, (wfrest, counted))))))) = res
  (%Equal.sym(Maybe<&2, +List<T.Part>>, SC.parts(C.to_value(v), fields), Some{ps}, parts_eq) : {SC.aggregate(_, SS.fixed_size(fields)) == Some{[SC.fragment(SS.fixed_size(fields), List.take(&2, U32, P.slice_bytes(sl), n))]} : Maybe<&2, +List<T.Part>>}
   Equal.cong(Maybe<&2, +List<U32>>, Maybe<&2, +List<T.Part>>, e => SC.one(e, SS.fixed_size(fields)), SL.encoding(ps), Some{List.take(&2, U32, P.slice_bytes(sl), n)},
     layout_encoding(ps, sl, n, ft, sized, valid, bytes,
       Equal.trans(Bool, N.fits(4n, n), D.fits(n), True{}, Equal.sym(Bool, D.fits(n), N.fits(4n, n), CL.fits_bridge(n)), fitsn),
       wfsl, roomsl)),
   (restview, wfrest))

# ---------------------------------------------------------------------------
# Starting a walk: the header cursor is at the region start, the payload
# cursor at the end of the fixed part, and nothing has been decoded yet.
law layout_start:
  for +fields: T.Schema
  for +sl: P.Slice
  for +n: Nat
  for +size: Nat
  for +out: D.Out
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +roomsl: {Nat.is_le(n, P.slice_size(sl)) == True{} : Bool}
  for +sizele: {Nat.is_le(size, n) == True{} : Bool}
  for +total: Nat
  for wg: walk_goal(fields, fields, sl, n, size, size, 0n, size, [], sl, P.adv(sl, size), C.CEnd{}, 0n, total, total, out)
  walk_result(fields, sl, n, size, total, out)
def layout_start(fields, sl, n, size, out, wfsl, roomsl, sizele, total, wg):
  wg(wfsl, roomsl,
    Equal.sym(+List<U32>, List.drop(&2, U32, P.slice_bytes(sl), 0n), P.slice_bytes(sl), PK.drop_zero(P.slice_bytes(sl))),
    wfsl,
    PK.adv_view(sl, size),
    PK.wf_adv(sl, size, wfsl),
    {==},
    {==},
    PKG.add_zero(size),
    PK.take_zero(P.slice_bytes(sl)),
    Equal.trans(+List<U32>, List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), size), Nat.sub(size, size)), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), size), 0n), [],
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), size), k), Nat.sub(size, size), 0n, sub_self(size)),
      PK.take_zero(List.drop(&2, U32, P.slice_bytes(sl), size))),
    {==},
    NO.reflexive(size),
    sizele,
    {==},
    suffix => m => e =>
      (%Equal.sym(T.Value, C.to_value(D.reverse_items(suffix, C.CEnd{})), C.items_fwd(suffix), CH.fold_reversal(suffix)) : {SC.count(_) == Nat.add(0n, m) : Nat}
       e),
    suffix => ps => e =>
      (%Equal.sym(T.Value, C.to_value(D.reverse_items(suffix, C.CEnd{})), C.items_fwd(suffix), CH.fold_reversal(suffix)) : {SC.parts(_, fields) == Some{List.append(&2, T.Part, [], ps)} : Maybe<&2, +List<T.Part>>}
       e))

# ---------------------------------------------------------------------------
# An invalid cursor is refused by every schema, phase and remaining count: the
# decoder never produces a value from a rejected plan.
law invalid_refuses:
  for +schema: T.Schema
  for +phase: Nat
  for +k: Nat
  {D.go(schema, phase, k, D.Invalid{}) == D.Refused{} : D.Out}
def invalid_refuses(schema, phase, k):
  match schema:
    case T.Boolean{}: {==}
    case T.Unsigned{w}: {==}
    case T.ByteVector{m}: {==}
    case T.ByteList{m}: {==}
    case T.BitVector{m}: {==}
    case T.BitList{m}: {==}
    case T.ProgressiveBits{}: {==}
    case T.Null{}: {==}
    case T.Container{names, fields}: {==}
    case T.ProgressiveContainer{names, fields, active}: {==}
    case T.Union{options}: {==}
    case T.CompatibleUnion{selectors, options}: {==}
    case T.Named{name, inner}: {==}
    case T.Repeat{e}: {==}
    case T.Vector{e, m}:
      match phase:
        case 1n+q: {==}
        case 0n:
          match k:
            case 0n: {==}
            case 1n+p: {==}
    case T.ListOf{e, m}:
      match phase:
        case 1n+q: {==}
        case 0n:
          match k:
            case 0n: {==}
            case 1n+p: {==}
    case T.ProgressiveList{e}:
      match phase:
        case 1n+q: {==}
        case 0n:
          match k:
            case 0n: {==}
            case 1n+p: {==}
    case T.Chain{hh, tt}:
      match k:
        case 0n: {==}
        case 1n+p: {==}
    case T.End{}: {==}

# A walk whose previous child was refused decodes nothing: the plan is stuck,
# so every later cursor is invalid.
law broken_close:
  for +prior: D.Out
  for +fixed: Bool
  for +other: P.Slice
  for +acc: C.CValue
  for +pos: Nat
  for +end: Nat
  for +broken: {D.settle(prior, fixed, other, acc) == D.Broken{} : D.Settled}
  {D.close(D.settle(prior, fixed, other, acc), pos, end) == D.Refused{} : D.Out}
def broken_close(prior, fixed, other, acc, pos, end, broken):
  %Equal.sym(D.Settled, D.settle(prior, fixed, other, acc), D.Broken{}, broken) : {D.close(_, pos, end) == D.Refused{} : D.Out}
  {==}

law broken_plan_next:
  for +prior: D.Out
  for +fixed: Bool
  for +other: P.Slice
  for +acc: C.CValue
  for +width: Maybe<&2, Nat>
  for +pos: Nat
  for +end: Nat
  for +a: D.Ahead
  for +r: D.Out
  for +broken: {D.settle(prior, fixed, other, acc) == D.Broken{} : D.Settled}
  {D.plan_next(D.plan(D.settle(prior, fixed, other, acc), width, pos, end, a), r, end) == D.Invalid{} : D.Cursor}
def broken_plan_next(prior, fixed, other, acc, width, pos, end, a, r, broken):
  %Equal.sym(D.Settled, D.settle(prior, fixed, other, acc), D.Broken{}, broken) : {D.plan_next(D.plan(_, width, pos, end, a), r, end) == D.Invalid{} : D.Cursor}
  {==}

law broken_tail:
  for +next: T.Schema
  for +k: Nat
  for +prior: D.Out
  for +fixed: Bool
  for +other: P.Slice
  for +acc: C.CValue
  for +width: Maybe<&2, Nat>
  for +pos: Nat
  for +end: Nat
  for +a: D.Ahead
  for +r: D.Out
  for +broken: {D.settle(prior, fixed, other, acc) == D.Broken{} : D.Settled}
  {D.go(next, 0n, k, D.plan_next(D.plan(D.settle(prior, fixed, other, acc), width, pos, end, a), r, end)) == D.Refused{} : D.Out}
def broken_tail(next, k, prior, fixed, other, acc, width, pos, end, a, r, broken):
  Equal.trans(D.Out, D.go(next, 0n, k, D.plan_next(D.plan(D.settle(prior, fixed, other, acc), width, pos, end, a), r, end)), D.go(next, 0n, k, D.Invalid{}), D.Refused{},
    Equal.cong(D.Cursor, D.Out, c => D.go(next, 0n, k, c), D.plan_next(D.plan(D.settle(prior, fixed, other, acc), width, pos, end, a), r, end), D.Invalid{}, broken_plan_next(prior, fixed, other, acc, width, pos, end, a, r, broken)),
    invalid_refuses(next, 0n, k))

law broken_refuses:
  for +fs: T.Schema
  for +k: Nat
  for +fixed: Bool
  for +prior: D.Out
  for +other: P.Slice
  for +pos: Nat
  for +end: Nat
  for +acc: C.CValue
  for +broken: {D.settle(prior, fixed, other, acc) == D.Broken{} : D.Settled}
  {D.go(fs, 0n, k, D.Walk{fixed, prior, other, pos, end, acc}) == D.Refused{} : D.Out}
def broken_refuses(fs, k, fixed, prior, other, pos, end, acc, broken):
  match fs:
    case T.Boolean{}: {==}
    case T.Unsigned{w}: {==}
    case T.ByteVector{m}: {==}
    case T.ByteList{m}: {==}
    case T.BitVector{m}: {==}
    case T.BitList{m}: {==}
    case T.ProgressiveBits{}: {==}
    case T.Null{}: {==}
    case T.Container{names, fields}: {==}
    case T.ProgressiveContainer{names, fields, active}: {==}
    case T.Union{options}: {==}
    case T.CompatibleUnion{selectors, options}: {==}
    case T.Named{name, inner}: {==}
    case T.Repeat{e}: {==}
    case T.End{}: broken_close(prior, fixed, other, acc, pos, end, broken)
    case T.Chain{hh, tt}:
      match k:
        case 0n: broken_tail(tt, 0n, prior, fixed, other, acc, IS.fixed_size(hh), pos, end, D.Later{tt}, D.go(hh, 1n, 0n, D.plan_child(D.plan(D.settle(prior, fixed, other, acc), IS.fixed_size(hh), pos, end, D.Later{tt}))), broken)
        case 1n+p: {==}
    case T.Vector{e, m}:
      match k:
        case 0n: broken_close(prior, fixed, other, acc, pos, end, broken)
        case 1n+p: broken_tail(T.Vector{e, m}, p, prior, fixed, other, acc, IS.fixed_size(e), pos, end, D.Remaining{p}, D.go(e, 1n, 0n, D.plan_child(D.plan(D.settle(prior, fixed, other, acc), IS.fixed_size(e), pos, end, D.Remaining{p}))), broken)
    case T.ListOf{e, m}:
      match k:
        case 0n: broken_close(prior, fixed, other, acc, pos, end, broken)
        case 1n+p: broken_tail(T.ListOf{e, m}, p, prior, fixed, other, acc, IS.fixed_size(e), pos, end, D.Remaining{p}, D.go(e, 1n, 0n, D.plan_child(D.plan(D.settle(prior, fixed, other, acc), IS.fixed_size(e), pos, end, D.Remaining{p}))), broken)
    case T.ProgressiveList{e}:
      match k:
        case 0n: broken_close(prior, fixed, other, acc, pos, end, broken)
        case 1n+p: broken_tail(T.ProgressiveList{e}, p, prior, fixed, other, acc, IS.fixed_size(e), pos, end, D.Remaining{p}, D.go(e, 1n, 0n, D.plan_child(D.plan(D.settle(prior, fixed, other, acc), IS.fixed_size(e), pos, end, D.Remaining{p}))), broken)

# ---------------------------------------------------------------------------
# Sequence regions. The walk's parts aggregate to the region's bytes exactly
# as for a container; the sequence's own admission condition (positive length
# and exact count, or the list limit) is what the decoder has checked.
law nat_equal_refl:
  for +n: Nat
  {Nat.is_eq(n, n) == True{} : Bool}
def nat_equal_refl(n):
  match n:
    case 0n: {==}
    case 1n+p: nat_equal_refl(p)

law sequence_parts:
  for +e: T.Schema
  for +sl: P.Slice
  for +n: Nat
  for +ft: Nat
  for +ps: +List<T.Part>
  for +v: C.CValue
  for +width: Maybe<&2, Nat>
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +roomsl: {Nat.is_le(n, P.slice_size(sl)) == True{} : Bool}
  for +fitsn: {D.fits(n) == True{} : Bool}
  for +parts_eq: {SC.parts(C.to_value(v), T.Repeat{e}) == Some{ps} : Maybe<&2, +List<T.Part>>}
  for +sized: {SL.fixed_size(ps) == ft : Nat}
  for +valid: {SL.bytes_valid(ps) == True{} : Bool}
  for +bytes: {List.append(&2, U32, SL.fixed_parts(ps, ft), SL.payloads(ps)) == List.take(&2, U32, P.slice_bytes(sl), n) : +List<U32>}
  {SC.aggregate(SC.parts(C.to_value(v), T.Repeat{e}), width) == Some{[SC.fragment(width, List.take(&2, U32, P.slice_bytes(sl), n))]} : Maybe<&2, +List<T.Part>>}
def sequence_parts(e, sl, n, ft, ps, v, width, wfsl, roomsl, fitsn, parts_eq, sized, valid, bytes):
  %Equal.sym(Maybe<&2, +List<T.Part>>, SC.parts(C.to_value(v), T.Repeat{e}), Some{ps}, parts_eq) : {SC.aggregate(_, width) == Some{[SC.fragment(width, List.take(&2, U32, P.slice_bytes(sl), n))]} : Maybe<&2, +List<T.Part>>}
  Equal.cong(Maybe<&2, +List<U32>>, Maybe<&2, +List<T.Part>>, enc => SC.one(enc, width), SL.encoding(ps), Some{List.take(&2, U32, P.slice_bytes(sl), n)},
    layout_encoding(ps, sl, n, ft, sized, valid, bytes,
      Equal.trans(Bool, N.fits(4n, n), D.fits(n), True{}, Equal.sym(Bool, D.fits(n), N.fits(4n, n), CL.fits_bridge(n)), fitsn),
      wfsl, roomsl))

law vector_sound:
  for +e: T.Schema
  for +m: Nat
  for +sl: P.Slice
  for +n: Nat
  for +ft: Nat
  for +v: C.CValue
  for +rest: P.Slice
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +roomsl: {Nat.is_le(n, P.slice_size(sl)) == True{} : Bool}
  for +fitsn: {D.fits(n) == True{} : Bool}
  for +positive: {Nat.is_lt(0n, m) == True{} : Bool}
  for res: walk_result(T.Repeat{e}, sl, n, ft, m, D.Parsed{v, rest})
  CL.region_sound(T.Vector{e, m}, n, sl, D.Parsed{C.CSeq{v}, rest})
def vector_sound(e, m, sl, n, ft, v, rest, wfsl, roomsl, fitsn, positive, res):
  (+ps, (parts_eq, (sized, (valid, (bytes, (restview, (wfrest, counted))))))) = res
  (%Equal.sym(Nat, SC.count(C.to_value(v)), m, counted) : {SC.require(Bool.and(Nat.is_lt(0n, m), Nat.is_eq(_, m)), SC.aggregate(SC.parts(C.to_value(v), T.Repeat{e}), SS.times(m, SS.fixed_size(e)))) == Some{[SC.fragment(SS.times(m, SS.fixed_size(e)), List.take(&2, U32, P.slice_bytes(sl), n))]} : Maybe<&2, +List<T.Part>>}
   %Equal.sym(Bool, Bool.and(Nat.is_lt(0n, m), Nat.is_eq(m, m)), True{}, V.and_true(Nat.is_lt(0n, m), Nat.is_eq(m, m), positive, nat_equal_refl(m))) : {SC.require(_, SC.aggregate(SC.parts(C.to_value(v), T.Repeat{e}), SS.times(m, SS.fixed_size(e)))) == Some{[SC.fragment(SS.times(m, SS.fixed_size(e)), List.take(&2, U32, P.slice_bytes(sl), n))]} : Maybe<&2, +List<T.Part>>}
   sequence_parts(e, sl, n, ft, ps, v, SS.times(m, SS.fixed_size(e)), wfsl, roomsl, fitsn, parts_eq, sized, valid, bytes),
   (restview, wfrest))

law list_sound:
  for +e: T.Schema
  for +limit: Nat
  for +sl: P.Slice
  for +n: Nat
  for +ft: Nat
  for +m: Nat
  for +v: C.CValue
  for +rest: P.Slice
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +roomsl: {Nat.is_le(n, P.slice_size(sl)) == True{} : Bool}
  for +fitsn: {D.fits(n) == True{} : Bool}
  for +bounded: {Nat.is_le(m, limit) == True{} : Bool}
  for res: walk_result(T.Repeat{e}, sl, n, ft, m, D.Parsed{v, rest})
  CL.region_sound(T.ListOf{e, limit}, n, sl, D.Parsed{C.CSeq{v}, rest})
def list_sound(e, limit, sl, n, ft, m, v, rest, wfsl, roomsl, fitsn, bounded, res):
  (+ps, (parts_eq, (sized, (valid, (bytes, (restview, (wfrest, counted))))))) = res
  (%Equal.sym(Nat, SC.count(C.to_value(v)), m, counted) : {SC.require(Nat.is_le(_, limit), SC.aggregate(SC.parts(C.to_value(v), T.Repeat{e}), None{})) == Some{[SC.fragment(None{}, List.take(&2, U32, P.slice_bytes(sl), n))]} : Maybe<&2, +List<T.Part>>}
   %Equal.sym(Bool, Nat.is_le(m, limit), True{}, bounded) : {SC.require(_, SC.aggregate(SC.parts(C.to_value(v), T.Repeat{e}), None{})) == Some{[SC.fragment(None{}, List.take(&2, U32, P.slice_bytes(sl), n))]} : Maybe<&2, +List<T.Part>>}
   sequence_parts(e, sl, n, ft, ps, v, None{}, wfsl, roomsl, fitsn, parts_eq, sized, valid, bytes),
   (restview, wfrest))

law progressive_list_sound:
  for +e: T.Schema
  for +sl: P.Slice
  for +n: Nat
  for +ft: Nat
  for +m: Nat
  for +v: C.CValue
  for +rest: P.Slice
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +roomsl: {Nat.is_le(n, P.slice_size(sl)) == True{} : Bool}
  for +fitsn: {D.fits(n) == True{} : Bool}
  for res: walk_result(T.Repeat{e}, sl, n, ft, m, D.Parsed{v, rest})
  CL.region_sound(T.ProgressiveList{e}, n, sl, D.Parsed{C.CSeq{v}, rest})
def progressive_list_sound(e, sl, n, ft, m, v, rest, wfsl, roomsl, fitsn, res):
  (+ps, (parts_eq, (sized, (valid, (bytes, (restview, (wfrest, counted))))))) = res
  (sequence_parts(e, sl, n, ft, ps, v, None{}, wfsl, roomsl, fitsn, parts_eq, sized, valid, bytes),
   (restview, wfrest))

# ---------------------------------------------------------------------------
# Unions. The selector byte precedes the selected option's region; the
# specification tags the option's encoding with exactly that byte.
def option_sound(found: Maybe<&2, T.Schema>, +sel: U32, n: Nat, xs: P.Slice, out: D.Out) -> Type:
  match out:
    case D.Begin{r}: Empty
    case D.Parsed{v, rest}:
      Exists(C.CValue, cv =>
        {v == C.CSel{sel, cv} : C.CValue}
        & {SC.with_option(found, t => SC.tagged(sel, SC.parts(C.to_value(cv), t))) == Some{[T.Variable{sel <> List.take(&2, U32, P.slice_bytes(xs), n)}]} : Maybe<&2, +List<T.Part>>})
      & {P.slice_bytes(rest) == List.drop(&2, U32, P.slice_bytes(xs), n) : +List<U32>}
      & {List.length(&2, U32, P.slice_bytes(rest)) == P.slice_size(rest) : Nat}
    case _: Unit

def pick_sound(options: T.Schema, idx: Nat, +sel: U32, n: Nat, xs: P.Slice, out: D.Out) -> Type:
  option_sound(SS.option(options, idx), sel, n, xs, out)

law tagged_fragment:
  for +sel: U32
  for +width: Maybe<&2, Nat>
  for +bytes: +List<U32>
  {SC.tagged(sel, Some{[SC.fragment(width, bytes)]}) == Some{[T.Variable{sel <> bytes}]} : Maybe<&2, +List<T.Part>>}
def tagged_fragment(sel, width, bytes):
  match width:
    case None{}: {==}
    case Some{w}: {==}

law take_cons:
  for +xs: +List<U32>
  for +m: Nat
  for +room: {Nat.is_le(1n, List.length(&2, U32, xs)) == True{} : Bool}
  {List.take(&2, U32, xs, 1n+m) == IP.at(xs, 0n) <> List.take(&2, U32, List.drop(&2, U32, xs, 1n), m) : +List<U32>}
def take_cons(xs, m, room):
  match xs:
    case Nil{}: Empty.absurd({List.take(&2, U32, [], 1n+m) == IP.at([], 0n) <> List.take(&2, U32, List.drop(&2, U32, [], 1n), m) : +List<U32>}, F.false_true(room))
    case Con{hd, tl}: Equal.cong(+List<U32>, +List<U32>, ys => hd <> List.take(&2, U32, ys, m), tl, List.drop(&2, U32, tl, 0n), Equal.sym(+List<U32>, List.drop(&2, U32, tl, 0n), tl, PK.drop_zero(tl)))

law union_sound:
  for +options: T.Schema
  for +sl: P.Slice
  for +m: Nat
  for +v: C.CValue
  for +rest: P.Slice
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +roomsl: {Nat.is_le(1n+m, P.slice_size(sl)) == True{} : Bool}
  for res: pick_sound(options, U32.to_nat(P.byte_at(sl, 0n)), P.byte_at(sl, 0n), m, P.adv(sl, 1n), D.Parsed{v, rest})
  CL.region_sound(T.Union{options}, 1n+m, sl, D.Parsed{v, rest})
def union_sound(options, sl, m, v, rest, wfsl, roomsl, res):
  ((+cv, (shape, parts_eq)), (restview, wfrest)) = res
  +selbytes = Equal.trans(+List<U32>, P.byte_at(sl, 0n) <> List.take(&2, U32, P.slice_bytes(P.adv(sl, 1n)), m), IP.at(P.slice_bytes(sl), 0n) <> List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), 1n), m), List.take(&2, U32, P.slice_bytes(sl), 1n+m),
    Equal.trans(+List<U32>, P.byte_at(sl, 0n) <> List.take(&2, U32, P.slice_bytes(P.adv(sl, 1n)), m), P.byte_at(sl, 0n) <> List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), 1n), m), IP.at(P.slice_bytes(sl), 0n) <> List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), 1n), m),
      Equal.cong(+List<U32>, +List<U32>, ys => P.byte_at(sl, 0n) <> List.take(&2, U32, ys, m), P.slice_bytes(P.adv(sl, 1n)), List.drop(&2, U32, P.slice_bytes(sl), 1n), PK.adv_view(sl, 1n)),
      Equal.cong(U32, +List<U32>, b => b <> List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), 1n), m), P.byte_at(sl, 0n), IP.at(P.slice_bytes(sl), 0n), PK.byte_at_view(sl, 0n))),
    Equal.sym(+List<U32>, List.take(&2, U32, P.slice_bytes(sl), 1n+m), IP.at(P.slice_bytes(sl), 0n) <> List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), 1n), m),
      take_cons(P.slice_bytes(sl), m, CL.sized_by_wf(sl, 1n, wfsl, NO.transitive(1n, 1n+m, P.slice_size(sl), NO.zero_le(m), roomsl)))))
  (%Equal.sym(C.CValue, v, C.CSel{P.byte_at(sl, 0n), cv}, shape) : {SC.parts(C.to_value(_), T.Union{options}) == Some{[SC.fragment(SS.fixed_size(T.Union{options}), List.take(&2, U32, P.slice_bytes(sl), 1n+m))]} : Maybe<&2, +List<T.Part>>}
   Equal.trans(Maybe<&2, +List<T.Part>>, SC.with_option(SS.option(options, U32.to_nat(P.byte_at(sl, 0n))), t => SC.tagged(P.byte_at(sl, 0n), SC.parts(C.to_value(cv), t))), Some{[T.Variable{P.byte_at(sl, 0n) <> List.take(&2, U32, P.slice_bytes(P.adv(sl, 1n)), m)}]}, Some{[T.Variable{List.take(&2, U32, P.slice_bytes(sl), 1n+m)}]},
     parts_eq,
     Equal.cong(+List<U32>, Maybe<&2, +List<T.Part>>, ys => Some{[T.Variable{ys}]}, P.byte_at(sl, 0n) <> List.take(&2, U32, P.slice_bytes(P.adv(sl, 1n)), m), List.take(&2, U32, P.slice_bytes(sl), 1n+m), selbytes)),
   Equal.trans(+List<U32>, P.slice_bytes(rest), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), 1n), m), List.drop(&2, U32, P.slice_bytes(sl), 1n+m),
     Equal.trans(+List<U32>, P.slice_bytes(rest), List.drop(&2, U32, P.slice_bytes(P.adv(sl, 1n)), m), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), 1n), m),
       restview,
       Equal.cong(+List<U32>, +List<U32>, ys => List.drop(&2, U32, ys, m), P.slice_bytes(P.adv(sl, 1n)), List.drop(&2, U32, P.slice_bytes(sl), 1n), PK.adv_view(sl, 1n))),
     W.drop_drop(P.slice_bytes(sl), 1n, m)), wfrest)

# Compatible unions: the selector is matched against the declared selector
# list, and the selected option's region follows the selector byte.
def among_sound(selectors: +List<U32>, options: T.Schema, +sel: U32, n: Nat, xs: P.Slice, out: D.Out) -> Type:
  option_sound(SS.compatible_option(selectors, options, sel), sel, n, xs, out)

law compatible_union_sound:
  for +selectors: +List<U32>
  for +options: T.Schema
  for +sl: P.Slice
  for +m: Nat
  for +v: C.CValue
  for +rest: P.Slice
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +roomsl: {Nat.is_le(1n+m, P.slice_size(sl)) == True{} : Bool}
  for res: among_sound(selectors, options, P.byte_at(sl, 0n), m, P.adv(sl, 1n), D.Parsed{v, rest})
  CL.region_sound(T.CompatibleUnion{selectors, options}, 1n+m, sl, D.Parsed{v, rest})
def compatible_union_sound(selectors, options, sl, m, v, rest, wfsl, roomsl, res):
  ((+cv, (shape, parts_eq)), (restview, wfrest)) = res
  +selbytes = Equal.trans(+List<U32>, P.byte_at(sl, 0n) <> List.take(&2, U32, P.slice_bytes(P.adv(sl, 1n)), m), IP.at(P.slice_bytes(sl), 0n) <> List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), 1n), m), List.take(&2, U32, P.slice_bytes(sl), 1n+m),
    Equal.trans(+List<U32>, P.byte_at(sl, 0n) <> List.take(&2, U32, P.slice_bytes(P.adv(sl, 1n)), m), P.byte_at(sl, 0n) <> List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), 1n), m), IP.at(P.slice_bytes(sl), 0n) <> List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), 1n), m),
      Equal.cong(+List<U32>, +List<U32>, ys => P.byte_at(sl, 0n) <> List.take(&2, U32, ys, m), P.slice_bytes(P.adv(sl, 1n)), List.drop(&2, U32, P.slice_bytes(sl), 1n), PK.adv_view(sl, 1n)),
      Equal.cong(U32, +List<U32>, b => b <> List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), 1n), m), P.byte_at(sl, 0n), IP.at(P.slice_bytes(sl), 0n), PK.byte_at_view(sl, 0n))),
    Equal.sym(+List<U32>, List.take(&2, U32, P.slice_bytes(sl), 1n+m), IP.at(P.slice_bytes(sl), 0n) <> List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), 1n), m),
      take_cons(P.slice_bytes(sl), m, CL.sized_by_wf(sl, 1n, wfsl, NO.transitive(1n, 1n+m, P.slice_size(sl), NO.zero_le(m), roomsl)))))
  (%Equal.sym(C.CValue, v, C.CSel{P.byte_at(sl, 0n), cv}, shape) : {SC.parts(C.to_value(_), T.CompatibleUnion{selectors, options}) == Some{[SC.fragment(SS.fixed_size(T.CompatibleUnion{selectors, options}), List.take(&2, U32, P.slice_bytes(sl), 1n+m))]} : Maybe<&2, +List<T.Part>>}
   Equal.trans(Maybe<&2, +List<T.Part>>, SC.with_option(SS.compatible_option(selectors, options, P.byte_at(sl, 0n)), t => SC.tagged(P.byte_at(sl, 0n), SC.parts(C.to_value(cv), t))), Some{[T.Variable{P.byte_at(sl, 0n) <> List.take(&2, U32, P.slice_bytes(P.adv(sl, 1n)), m)}]}, Some{[T.Variable{List.take(&2, U32, P.slice_bytes(sl), 1n+m)}]},
     parts_eq,
     Equal.cong(+List<U32>, Maybe<&2, +List<T.Part>>, ys => Some{[T.Variable{ys}]}, P.byte_at(sl, 0n) <> List.take(&2, U32, P.slice_bytes(P.adv(sl, 1n)), m), List.take(&2, U32, P.slice_bytes(sl), 1n+m), selbytes)),
   Equal.trans(+List<U32>, P.slice_bytes(rest), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), 1n), m), List.drop(&2, U32, P.slice_bytes(sl), 1n+m),
     Equal.trans(+List<U32>, P.slice_bytes(rest), List.drop(&2, U32, P.slice_bytes(P.adv(sl, 1n)), m), List.drop(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), 1n), m),
       restview,
       Equal.cong(+List<U32>, +List<U32>, ys => List.drop(&2, U32, ys, m), P.slice_bytes(P.adv(sl, 1n)), List.drop(&2, U32, P.slice_bytes(sl), 1n), PK.adv_view(sl, 1n))),
     W.drop_drop(P.slice_bytes(sl), 1n, m)), wfrest)

# ---------------------------------------------------------------------------
# The decoder's own recursion, as the specification sees it.
#
# `walk_forest` is the field forest a walk over `schema` decodes (a container's
# declaration-order fields, or repeated elements for a sequence); `walk_count`
# and `walk_header` are the children and header bytes that walk still owes.
def walk_forest(schema: T.Schema) -> T.Schema:
  match schema:
    case T.Vector{e, m}: T.Repeat{e}
    case T.ListOf{e, m}: T.Repeat{e}
    case T.ProgressiveList{e}: T.Repeat{e}
    case _: schema

def walk_count(schema: T.Schema, k: Nat) -> Nat:
  match schema:
    case T.Chain{hh, tt}: 1n+walk_count(tt, k)
    case T.End{}: 0n
    case _: k

def walk_header(schema: T.Schema, k: Nat) -> Nat:
  match schema:
    case T.Chain{hh, tt}: Nat.add(IL.slot(IS.fixed_size(hh)), walk_header(tt, k))
    case T.End{}: 0n
    case T.Vector{e, m}: Nat.mul(IL.slot(IS.fixed_size(e)), k)
    case T.ListOf{e, m}: Nat.mul(IL.slot(IS.fixed_size(e)), k)
    case T.ProgressiveList{e}: Nat.mul(IL.slot(IS.fixed_size(e)), k)
    case _: 0n

law refused_walk:
  for +fields: T.Schema
  for +fs: T.Schema
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +hsrest: Nat
  for +h: Nat
  for +pos: Nat
  for +pdone: +List<T.Part>
  for +hdr: P.Slice
  for +pay: P.Slice
  for +acc: C.CValue
  for +base: Nat
  for +krem: Nat
  for +total: Nat
  walk_goal(fields, fs, sl, end, fixedtotal, hsrest, h, pos, pdone, hdr, pay, acc, base, krem, total, D.Refused{})
def refused_walk(fields, fs, sl, end, fixedtotal, hsrest, h, pos, pdone, hdr, pay, acc, base, krem, total):
  a => b => c => d => e => f => g => i => j => l => m => o => p => q => r => t => u => Unit{}

# What soundness means for each cursor shape the decoder can be in.
def cursor_goal(schema: T.Schema, phase: Nat, k: Nat, c: D.Cursor, fields: T.Schema, sl: P.Slice, fixedtotal: Nat, h: Nat, pdone: +List<T.Part>, hdr: P.Slice, pay: P.Slice, acc2: C.CValue, base: Nat, total: Nat) -> Type:
  match c:
    case D.Region{n, xs}:
      @+wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat} ->
      @+room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool} ->
      CL.region_sound(schema, n, xs, D.go(schema, phase, k, D.Region{n, xs}))
    case D.Walk{fixed, prior, other, pos, end, acc}:
      @+settled: {D.settle(prior, fixed, other, acc) == D.Settled{hdr, pay, acc2} : D.Settled} ->
      walk_goal(fields, walk_forest(schema), sl, end, fixedtotal, walk_header(schema, k), h, pos, pdone, hdr, pay, acc2, base, walk_count(schema, k), total, D.go(schema, phase, k, D.Walk{fixed, prior, other, pos, end, acc}))
    case D.Pick{sel, n, xs}:
      @+wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat} ->
      @+room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool} ->
      pick_sound(schema, k, sel, n, xs, D.go(schema, phase, k, D.Pick{sel, n, xs}))
    case D.PickAmong{selectors, sel, n, xs}:
      @+wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat} ->
      @+room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool} ->
      among_sound(selectors, schema, sel, n, xs, D.go(schema, phase, k, D.PickAmong{selectors, sel, n, xs}))
    case D.Invalid{}: Unit

# Finishing a composite region: the walk's result, whatever shape it has, is
# wrapped as the composite's value.
law vector_finish:
  for +e: T.Schema
  for +m: Nat
  for +sl: P.Slice
  for +n: Nat
  for +ft: Nat
  for out: D.Out
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +roomsl: {Nat.is_le(n, P.slice_size(sl)) == True{} : Bool}
  for +fitsn: {D.fits(n) == True{} : Bool}
  for +positive: {Nat.is_lt(0n, m) == True{} : Bool}
  for res: walk_result(T.Repeat{e}, sl, n, ft, m, out)
  CL.region_sound(T.Vector{e, m}, n, sl, D.wrap_sequence(out))
def vector_finish(e, m, sl, n, ft, out, wfsl, roomsl, fitsn, positive, res):
  match out:
    case D.Refused{}: Unit{}
    case D.Begin{r}: Empty.absurd(CL.region_sound(T.Vector{e, m}, n, sl, D.wrap_sequence(D.Begin{r})), res)
    case D.Parsed{v, rest}: vector_sound(e, m, sl, n, ft, v, rest, wfsl, roomsl, fitsn, positive, res)

law list_finish:
  for +e: T.Schema
  for +limit: Nat
  for +m: Nat
  for +sl: P.Slice
  for +n: Nat
  for +ft: Nat
  for out: D.Out
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +roomsl: {Nat.is_le(n, P.slice_size(sl)) == True{} : Bool}
  for +fitsn: {D.fits(n) == True{} : Bool}
  for +bounded: {Nat.is_le(m, limit) == True{} : Bool}
  for res: walk_result(T.Repeat{e}, sl, n, ft, m, out)
  CL.region_sound(T.ListOf{e, limit}, n, sl, D.wrap_sequence(out))
def list_finish(e, limit, m, sl, n, ft, out, wfsl, roomsl, fitsn, bounded, res):
  match out:
    case D.Refused{}: Unit{}
    case D.Begin{r}: Empty.absurd(CL.region_sound(T.ListOf{e, limit}, n, sl, D.wrap_sequence(D.Begin{r})), res)
    case D.Parsed{v, rest}: list_sound(e, limit, sl, n, ft, m, v, rest, wfsl, roomsl, fitsn, bounded, res)

law progressive_list_finish:
  for +e: T.Schema
  for +m: Nat
  for +sl: P.Slice
  for +n: Nat
  for +ft: Nat
  for out: D.Out
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +roomsl: {Nat.is_le(n, P.slice_size(sl)) == True{} : Bool}
  for +fitsn: {D.fits(n) == True{} : Bool}
  for res: walk_result(T.Repeat{e}, sl, n, ft, m, out)
  CL.region_sound(T.ProgressiveList{e}, n, sl, D.wrap_sequence(out))
def progressive_list_finish(e, m, sl, n, ft, out, wfsl, roomsl, fitsn, res):
  match out:
    case D.Refused{}: Unit{}
    case D.Begin{r}: Empty.absurd(CL.region_sound(T.ProgressiveList{e}, n, sl, D.wrap_sequence(D.Begin{r})), res)
    case D.Parsed{v, rest}: progressive_list_sound(e, sl, n, ft, m, v, rest, wfsl, roomsl, fitsn, res)

law container_finish:
  for +names: +List<String>
  for +fields: T.Schema
  for +sl: P.Slice
  for +n: Nat
  for +ft: Nat
  for +total: Nat
  for out: D.Out
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +roomsl: {Nat.is_le(n, P.slice_size(sl)) == True{} : Bool}
  for +fitsn: {D.fits(n) == True{} : Bool}
  for res: walk_result(fields, sl, n, ft, total, out)
  CL.region_sound(T.Container{names, fields}, n, sl, D.wrap_sequence(out))
def container_finish(names, fields, sl, n, ft, total, out, wfsl, roomsl, fitsn, res):
  match out:
    case D.Refused{}: Unit{}
    case D.Begin{r}: Empty.absurd(CL.region_sound(T.Container{names, fields}, n, sl, D.wrap_sequence(D.Begin{r})), res)
    case D.Parsed{v, rest}: container_sound(names, fields, sl, n, ft, v, rest, wfsl, roomsl, fitsn, total, res)

law progressive_container_finish:
  for +names: +List<String>
  for +active: +List<Bool>
  for +fields: T.Schema
  for +sl: P.Slice
  for +n: Nat
  for +ft: Nat
  for +total: Nat
  for out: D.Out
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +roomsl: {Nat.is_le(n, P.slice_size(sl)) == True{} : Bool}
  for +fitsn: {D.fits(n) == True{} : Bool}
  for res: walk_result(fields, sl, n, ft, total, out)
  CL.region_sound(T.ProgressiveContainer{names, fields, active}, n, sl, D.wrap_sequence(out))
def progressive_container_finish(names, active, fields, sl, n, ft, total, out, wfsl, roomsl, fitsn, res):
  match out:
    case D.Refused{}: Unit{}
    case D.Begin{r}: Empty.absurd(CL.region_sound(T.ProgressiveContainer{names, fields, active}, n, sl, D.wrap_sequence(D.Begin{r})), res)
    case D.Parsed{v, rest}: progressive_container_sound(names, active, fields, sl, n, ft, v, rest, wfsl, roomsl, fitsn, total, res)

# ---------------------------------------------------------------------------
# Composite regions: the admission check, then the walk, then the aggregate.
law vector_region:
  for +e: T.Schema
  for +mv: Nat
  for +n: Nat
  for +xs: P.Slice
  for +q: Nat
  for +ok: Bool
  for +oksame: {Bool.and(Nat.is_lt(0n, mv), D.sequence_ok(IS.fixed_size(e), mv, n)) == ok : Bool}
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for rec: cursor_goal(T.Vector{e, mv}, q, mv, D.layout(ok, Nat.mul(IL.slot(IS.fixed_size(e)), mv), n, xs), T.Repeat{e}, xs, Nat.mul(IL.slot(IS.fixed_size(e)), mv), 0n, [], xs, P.adv(xs, Nat.mul(IL.slot(IS.fixed_size(e)), mv)), C.CEnd{}, 0n, mv)
  CL.region_sound(T.Vector{e, mv}, n, xs, D.wrap_sequence(D.go(T.Vector{e, mv}, q, mv, D.layout(ok, Nat.mul(IL.slot(IS.fixed_size(e)), mv), n, xs))))
def vector_region(e, mv, n, xs, q, ok, oksame, wf, room, rec):
  match q:
    case 1n+q2:
      match ok:
        case False{}:
          %Equal.sym(D.Out, D.go(T.Vector{e, mv}, 1n+q2, mv, D.Invalid{}), D.Refused{}, invalid_refuses(T.Vector{e, mv}, 1n+q2, mv)) : CL.region_sound(T.Vector{e, mv}, n, xs, D.wrap_sequence(_))
          Unit{}
        case True{}: Unit{}
    case 0n:
      match ok:
        case False{}:
          %Equal.sym(D.Out, D.go(T.Vector{e, mv}, 0n, mv, D.Invalid{}), D.Refused{}, invalid_refuses(T.Vector{e, mv}, 0n, mv)) : CL.region_sound(T.Vector{e, mv}, n, xs, D.wrap_sequence(_))
          Unit{}
        case True{}:
          +seqok = V.and_right(Nat.is_lt(0n, mv), D.sequence_ok(IS.fixed_size(e), mv, n), oksame)
          vector_finish(e, mv, xs, n, Nat.mul(IL.slot(IS.fixed_size(e)), mv),
            D.go(T.Vector{e, mv}, 0n, mv, D.layout(True{}, Nat.mul(IL.slot(IS.fixed_size(e)), mv), n, xs)),
            wf, room,
            V.and_left(D.fits(n), D.nat_le(Nat.mul(IL.slot(IS.fixed_size(e)), mv), n), seqok),
            V.and_left(Nat.is_lt(0n, mv), D.sequence_ok(IS.fixed_size(e), mv, n), oksame),
            layout_start(T.Repeat{e}, xs, n, Nat.mul(IL.slot(IS.fixed_size(e)), mv),
              D.go(T.Vector{e, mv}, 0n, mv, D.layout(True{}, Nat.mul(IL.slot(IS.fixed_size(e)), mv), n, xs)),
              wf, room,
              CL.nat_le_sound(Nat.mul(IL.slot(IS.fixed_size(e)), mv), n, V.and_right(D.fits(n), D.nat_le(Nat.mul(IL.slot(IS.fixed_size(e)), mv), n), seqok)),
              mv, rec({==})))

law walk_header_zero:
  for +fs: T.Schema
  {walk_header(fs, 0n) == D.header_size(fs) : Nat}
def walk_header_zero(fs):
  match fs:
    case T.Chain{hh, tt}: Equal.cong(Nat, Nat, x => Nat.add(IL.slot(IS.fixed_size(hh)), x), walk_header(tt, 0n), D.header_size(tt), walk_header_zero(tt))
    case T.End{}: {==}
    case T.Vector{e, m}: NA.mul_zero(IL.slot(IS.fixed_size(e)))
    case T.ListOf{e, m}: NA.mul_zero(IL.slot(IS.fixed_size(e)))
    case T.ProgressiveList{e}: NA.mul_zero(IL.slot(IS.fixed_size(e)))
    case T.Boolean{}: {==}
    case T.Unsigned{w}: {==}
    case T.ByteVector{m}: {==}
    case T.ByteList{m}: {==}
    case T.BitVector{m}: {==}
    case T.BitList{m}: {==}
    case T.ProgressiveBits{}: {==}
    case T.Null{}: {==}
    case T.Container{names, fields}: {==}
    case T.ProgressiveContainer{names, fields, active}: {==}
    case T.Union{options}: {==}
    case T.CompatibleUnion{selectors, options}: {==}
    case T.Named{name, inner}: {==}
    case T.Repeat{e}: {==}

# The forest shape: Chain ... Chain End, and the structural legality the
# recursion consumes. Both are decidable predicates, so a proof of either is
# an equation and can be used by every branch that needs it.
def forest_ok(fs: T.Schema) -> Bool:
  match fs:
    case T.Chain{hh, tt}: forest_ok(tt)
    case T.End{}: True{}
    case _: False{}

def legal_go(schema: T.Schema) -> Bool:
  match schema:
    case T.Chain{hh, +tt}: Bool.and(legal_go(hh), Bool.and(forest_ok(tt), legal_go(tt)))
    case T.Vector{e, m}: legal_go(e)
    case T.ListOf{e, m}: legal_go(e)
    case T.ProgressiveList{e}: legal_go(e)
    case T.Container{names, +fields}: Bool.and(forest_ok(fields), legal_go(fields))
    case T.ProgressiveContainer{names, +fields, active}: Bool.and(forest_ok(fields), legal_go(fields))
    case T.Union{+options}: Bool.and(forest_ok(options), legal_go(options))
    case T.CompatibleUnion{selectors, +options}: Bool.and(forest_ok(options), legal_go(options))
    case _: True{}

law walk_forest_of_chain:
  for +fs: T.Schema
  for +shape: {forest_ok(fs) == True{} : Bool}
  {walk_forest(fs) == fs : T.Schema}
def walk_forest_of_chain(fs, shape):
  match fs:
    case T.Chain{hh, tt}: {==}
    case T.End{}: {==}
    case T.Boolean{}: Empty.absurd({walk_forest(T.Boolean{}) == T.Boolean{} : T.Schema}, F.false_true(shape))
    case T.Unsigned{w}: Empty.absurd({walk_forest(T.Unsigned{w}) == T.Unsigned{w} : T.Schema}, F.false_true(shape))
    case T.ByteVector{m}: Empty.absurd({walk_forest(T.ByteVector{m}) == T.ByteVector{m} : T.Schema}, F.false_true(shape))
    case T.ByteList{m}: Empty.absurd({walk_forest(T.ByteList{m}) == T.ByteList{m} : T.Schema}, F.false_true(shape))
    case T.BitVector{m}: Empty.absurd({walk_forest(T.BitVector{m}) == T.BitVector{m} : T.Schema}, F.false_true(shape))
    case T.BitList{m}: Empty.absurd({walk_forest(T.BitList{m}) == T.BitList{m} : T.Schema}, F.false_true(shape))
    case T.Vector{e, m}: Empty.absurd({walk_forest(T.Vector{e, m}) == T.Vector{e, m} : T.Schema}, F.false_true(shape))
    case T.ListOf{e, m}: Empty.absurd({walk_forest(T.ListOf{e, m}) == T.ListOf{e, m} : T.Schema}, F.false_true(shape))
    case T.Container{names, fields}: Empty.absurd({walk_forest(T.Container{names, fields}) == T.Container{names, fields} : T.Schema}, F.false_true(shape))
    case T.Union{options}: Empty.absurd({walk_forest(T.Union{options}) == T.Union{options} : T.Schema}, F.false_true(shape))
    case T.Null{}: Empty.absurd({walk_forest(T.Null{}) == T.Null{} : T.Schema}, F.false_true(shape))
    case T.Repeat{e}: Empty.absurd({walk_forest(T.Repeat{e}) == T.Repeat{e} : T.Schema}, F.false_true(shape))
    case T.Named{name, inner}: Empty.absurd({walk_forest(T.Named{name, inner}) == T.Named{name, inner} : T.Schema}, F.false_true(shape))
    case T.ProgressiveList{e}: Empty.absurd({walk_forest(T.ProgressiveList{e}) == T.ProgressiveList{e} : T.Schema}, F.false_true(shape))
    case T.ProgressiveBits{}: Empty.absurd({walk_forest(T.ProgressiveBits{}) == T.ProgressiveBits{} : T.Schema}, F.false_true(shape))
    case T.ProgressiveContainer{names, fields, active}: Empty.absurd({walk_forest(T.ProgressiveContainer{names, fields, active}) == T.ProgressiveContainer{names, fields, active} : T.Schema}, F.false_true(shape))
    case T.CompatibleUnion{selectors, options}: Empty.absurd({walk_forest(T.CompatibleUnion{selectors, options}) == T.CompatibleUnion{selectors, options} : T.Schema}, F.false_true(shape))

# A legal field forest is exactly the forest a walk decodes.
law forest_shape:
  for +fs: T.Schema
  for +legal: {IS.valid_go(fs, True{}) == True{} : Bool}
  {walk_forest(fs) == fs : T.Schema}
def forest_shape(fs, legal):
  match fs:
    case T.Chain{hh, tt}: {==}
    case T.End{}: {==}
    case T.Vector{e, m}: Empty.absurd({walk_forest(T.Vector{e, m}) == T.Vector{e, m} : T.Schema}, F.false_true(legal))
    case T.ListOf{e, m}: Empty.absurd({walk_forest(T.ListOf{e, m}) == T.ListOf{e, m} : T.Schema}, F.false_true(legal))
    case T.ProgressiveList{e}: Empty.absurd({walk_forest(T.ProgressiveList{e}) == T.ProgressiveList{e} : T.Schema}, F.false_true(legal))
    case T.Boolean{}: {==}
    case T.Unsigned{w}: {==}
    case T.ByteVector{m}: {==}
    case T.ByteList{m}: {==}
    case T.BitVector{m}: {==}
    case T.BitList{m}: {==}
    case T.ProgressiveBits{}: {==}
    case T.Null{}: {==}
    case T.Container{names, fields}: {==}
    case T.ProgressiveContainer{names, fields, active}: {==}
    case T.Union{options}: {==}
    case T.CompatibleUnion{selectors, options}: {==}
    case T.Named{name, inner}: {==}
    case T.Repeat{e}: {==}

law container_region:
  for +names: +List<String>
  for +fields: T.Schema
  for +n: Nat
  for +xs: P.Slice
  for +ok: Bool
  for +shape: {forest_ok(fields) == True{} : Bool}
  for +oksame: {Bool.and(D.fits(n), D.nat_le(D.header_size(fields), n)) == ok : Bool}
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for rec: cursor_goal(fields, 0n, 0n, D.layout(ok, D.header_size(fields), n, xs), fields, xs, D.header_size(fields), 0n, [], xs, P.adv(xs, D.header_size(fields)), C.CEnd{}, 0n, walk_count(fields, 0n))
  CL.region_sound(T.Container{names, fields}, n, xs, D.wrap_sequence(D.go(fields, 0n, 0n, D.layout(ok, D.header_size(fields), n, xs))))
def container_region(names, fields, n, xs, ok, shape, oksame, wf, room, rec):
  match ok:
    case False{}:
      %Equal.sym(D.Out, D.go(fields, 0n, 0n, D.Invalid{}), D.Refused{}, invalid_refuses(fields, 0n, 0n)) : CL.region_sound(T.Container{names, fields}, n, xs, D.wrap_sequence(_))
      Unit{}
    case True{}:
      container_finish(names, fields, xs, n, D.header_size(fields), walk_count(fields, 0n),
        D.go(fields, 0n, 0n, D.layout(True{}, D.header_size(fields), n, xs)),
        wf, room,
        V.and_left(D.fits(n), D.nat_le(D.header_size(fields), n), oksame),
        layout_start(fields, xs, n, D.header_size(fields),
          D.go(fields, 0n, 0n, D.layout(True{}, D.header_size(fields), n, xs)),
          wf, room,
          CL.nat_le_sound(D.header_size(fields), n, V.and_right(D.fits(n), D.nat_le(D.header_size(fields), n), oksame)),
          walk_count(fields, 0n),
          (%walk_header_zero(fields) : walk_goal(fields, fields, xs, n, D.header_size(fields), _, 0n, D.header_size(fields), [], xs, P.adv(xs, D.header_size(fields)), C.CEnd{}, 0n, walk_count(fields, 0n), walk_count(fields, 0n), D.go(fields, 0n, 0n, D.layout(True{}, D.header_size(fields), n, xs)))
           %walk_forest_of_chain(fields, shape) : walk_goal(fields, _, xs, n, D.header_size(fields), walk_header(fields, 0n), 0n, D.header_size(fields), [], xs, P.adv(xs, D.header_size(fields)), C.CEnd{}, 0n, walk_count(fields, 0n), walk_count(fields, 0n), D.go(fields, 0n, 0n, D.layout(True{}, D.header_size(fields), n, xs)))
           rec({==}))))

law list_region:
  for +e: T.Schema
  for +limit: Nat
  for +n: Nat
  for +xs: P.Slice
  for +cnt: Maybe<&2, Nat>
  for +q: Nat
  for +ok: Bool
  for +oksame: {Bool.and(D.count_ok(cnt, Some{limit}), D.sequence_ok(IS.fixed_size(e), D.counted(cnt), n)) == ok : Bool}
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for rec: cursor_goal(T.ListOf{e, limit}, q, D.counted(cnt), D.layout(ok, Nat.mul(IL.slot(IS.fixed_size(e)), D.counted(cnt)), n, xs), T.Repeat{e}, xs, Nat.mul(IL.slot(IS.fixed_size(e)), D.counted(cnt)), 0n, [], xs, P.adv(xs, Nat.mul(IL.slot(IS.fixed_size(e)), D.counted(cnt))), C.CEnd{}, 0n, D.counted(cnt))
  CL.region_sound(T.ListOf{e, limit}, n, xs, D.wrap_sequence(D.go(T.ListOf{e, limit}, q, D.counted(cnt), D.layout(ok, Nat.mul(IL.slot(IS.fixed_size(e)), D.counted(cnt)), n, xs))))
def list_region(e, limit, n, xs, cnt, q, ok, oksame, wf, room, rec):
  match cnt:
    case None{}:
      match ok:
        case True{}: Empty.absurd(CL.region_sound(T.ListOf{e, limit}, n, xs, D.wrap_sequence(D.go(T.ListOf{e, limit}, q, 0n, D.layout(True{}, Nat.mul(IL.slot(IS.fixed_size(e)), 0n), n, xs)))), F.false_true(oksame))
        case False{}:
          %Equal.sym(D.Out, D.go(T.ListOf{e, limit}, q, 0n, D.Invalid{}), D.Refused{}, invalid_refuses(T.ListOf{e, limit}, q, 0n)) : CL.region_sound(T.ListOf{e, limit}, n, xs, D.wrap_sequence(_))
          Unit{}
    case Some{kk}:
      match q:
        case 1n+q2:
          match ok:
            case False{}:
              %Equal.sym(D.Out, D.go(T.ListOf{e, limit}, 1n+q2, kk, D.Invalid{}), D.Refused{}, invalid_refuses(T.ListOf{e, limit}, 1n+q2, kk)) : CL.region_sound(T.ListOf{e, limit}, n, xs, D.wrap_sequence(_))
              Unit{}
            case True{}: Unit{}
        case 0n:
          match ok:
            case False{}:
              %Equal.sym(D.Out, D.go(T.ListOf{e, limit}, 0n, kk, D.Invalid{}), D.Refused{}, invalid_refuses(T.ListOf{e, limit}, 0n, kk)) : CL.region_sound(T.ListOf{e, limit}, n, xs, D.wrap_sequence(_))
              Unit{}
            case True{}:
              +seqok = V.and_right(D.nat_le(kk, limit), D.sequence_ok(IS.fixed_size(e), kk, n), oksame)
              list_finish(e, limit, kk, xs, n, Nat.mul(IL.slot(IS.fixed_size(e)), kk),
                D.go(T.ListOf{e, limit}, 0n, kk, D.layout(True{}, Nat.mul(IL.slot(IS.fixed_size(e)), kk), n, xs)),
                wf, room,
                V.and_left(D.fits(n), D.nat_le(Nat.mul(IL.slot(IS.fixed_size(e)), kk), n), seqok),
                CL.nat_le_sound(kk, limit, V.and_left(D.nat_le(kk, limit), D.sequence_ok(IS.fixed_size(e), kk, n), oksame)),
                layout_start(T.Repeat{e}, xs, n, Nat.mul(IL.slot(IS.fixed_size(e)), kk),
                  D.go(T.ListOf{e, limit}, 0n, kk, D.layout(True{}, Nat.mul(IL.slot(IS.fixed_size(e)), kk), n, xs)),
                  wf, room,
                  CL.nat_le_sound(Nat.mul(IL.slot(IS.fixed_size(e)), kk), n, V.and_right(D.fits(n), D.nat_le(Nat.mul(IL.slot(IS.fixed_size(e)), kk), n), seqok)),
                  kk, rec({==})))

law progressive_list_region:
  for +e: T.Schema
  for +n: Nat
  for +xs: P.Slice
  for +cnt: Maybe<&2, Nat>
  for +q: Nat
  for +ok: Bool
  for +oksame: {Bool.and(D.count_ok(cnt, None{}), D.sequence_ok(IS.fixed_size(e), D.counted(cnt), n)) == ok : Bool}
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for rec: cursor_goal(T.ProgressiveList{e}, q, D.counted(cnt), D.layout(ok, Nat.mul(IL.slot(IS.fixed_size(e)), D.counted(cnt)), n, xs), T.Repeat{e}, xs, Nat.mul(IL.slot(IS.fixed_size(e)), D.counted(cnt)), 0n, [], xs, P.adv(xs, Nat.mul(IL.slot(IS.fixed_size(e)), D.counted(cnt))), C.CEnd{}, 0n, D.counted(cnt))
  CL.region_sound(T.ProgressiveList{e}, n, xs, D.wrap_sequence(D.go(T.ProgressiveList{e}, q, D.counted(cnt), D.layout(ok, Nat.mul(IL.slot(IS.fixed_size(e)), D.counted(cnt)), n, xs))))
def progressive_list_region(e, n, xs, cnt, q, ok, oksame, wf, room, rec):
  match cnt:
    case None{}:
      match ok:
        case True{}: Empty.absurd(CL.region_sound(T.ProgressiveList{e}, n, xs, D.wrap_sequence(D.go(T.ProgressiveList{e}, q, 0n, D.layout(True{}, Nat.mul(IL.slot(IS.fixed_size(e)), 0n), n, xs)))), F.false_true(oksame))
        case False{}:
          %Equal.sym(D.Out, D.go(T.ProgressiveList{e}, q, 0n, D.Invalid{}), D.Refused{}, invalid_refuses(T.ProgressiveList{e}, q, 0n)) : CL.region_sound(T.ProgressiveList{e}, n, xs, D.wrap_sequence(_))
          Unit{}
    case Some{kk}:
      match q:
        case 1n+q2:
          match ok:
            case False{}:
              %Equal.sym(D.Out, D.go(T.ProgressiveList{e}, 1n+q2, kk, D.Invalid{}), D.Refused{}, invalid_refuses(T.ProgressiveList{e}, 1n+q2, kk)) : CL.region_sound(T.ProgressiveList{e}, n, xs, D.wrap_sequence(_))
              Unit{}
            case True{}: Unit{}
        case 0n:
          match ok:
            case False{}:
              %Equal.sym(D.Out, D.go(T.ProgressiveList{e}, 0n, kk, D.Invalid{}), D.Refused{}, invalid_refuses(T.ProgressiveList{e}, 0n, kk)) : CL.region_sound(T.ProgressiveList{e}, n, xs, D.wrap_sequence(_))
              Unit{}
            case True{}:
              +seqok = V.and_right(True{}, D.sequence_ok(IS.fixed_size(e), kk, n), oksame)
              progressive_list_finish(e, kk, xs, n, Nat.mul(IL.slot(IS.fixed_size(e)), kk),
                D.go(T.ProgressiveList{e}, 0n, kk, D.layout(True{}, Nat.mul(IL.slot(IS.fixed_size(e)), kk), n, xs)),
                wf, room,
                V.and_left(D.fits(n), D.nat_le(Nat.mul(IL.slot(IS.fixed_size(e)), kk), n), seqok),
                layout_start(T.Repeat{e}, xs, n, Nat.mul(IL.slot(IS.fixed_size(e)), kk),
                  D.go(T.ProgressiveList{e}, 0n, kk, D.layout(True{}, Nat.mul(IL.slot(IS.fixed_size(e)), kk), n, xs)),
                  wf, room,
                  CL.nat_le_sound(Nat.mul(IL.slot(IS.fixed_size(e)), kk), n, V.and_right(D.fits(n), D.nat_le(Nat.mul(IL.slot(IS.fixed_size(e)), kk), n), seqok)),
                  kk, rec({==})))

law progressive_container_region:
  for +names: +List<String>
  for +active: +List<Bool>
  for +fields: T.Schema
  for +n: Nat
  for +xs: P.Slice
  for +ok: Bool
  for +shape: {forest_ok(fields) == True{} : Bool}
  for +oksame: {Bool.and(D.fits(n), D.nat_le(D.header_size(fields), n)) == ok : Bool}
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for rec: cursor_goal(fields, 0n, 0n, D.layout(ok, D.header_size(fields), n, xs), fields, xs, D.header_size(fields), 0n, [], xs, P.adv(xs, D.header_size(fields)), C.CEnd{}, 0n, walk_count(fields, 0n))
  CL.region_sound(T.ProgressiveContainer{names, fields, active}, n, xs, D.wrap_sequence(D.go(fields, 0n, 0n, D.layout(ok, D.header_size(fields), n, xs))))
def progressive_container_region(names, active, fields, n, xs, ok, shape, oksame, wf, room, rec):
  match ok:
    case False{}:
      %Equal.sym(D.Out, D.go(fields, 0n, 0n, D.Invalid{}), D.Refused{}, invalid_refuses(fields, 0n, 0n)) : CL.region_sound(T.ProgressiveContainer{names, fields, active}, n, xs, D.wrap_sequence(_))
      Unit{}
    case True{}:
      progressive_container_finish(names, active, fields, xs, n, D.header_size(fields), walk_count(fields, 0n),
        D.go(fields, 0n, 0n, D.layout(True{}, D.header_size(fields), n, xs)),
        wf, room,
        V.and_left(D.fits(n), D.nat_le(D.header_size(fields), n), oksame),
        layout_start(fields, xs, n, D.header_size(fields),
          D.go(fields, 0n, 0n, D.layout(True{}, D.header_size(fields), n, xs)),
          wf, room,
          CL.nat_le_sound(D.header_size(fields), n, V.and_right(D.fits(n), D.nat_le(D.header_size(fields), n), oksame)),
          walk_count(fields, 0n),
          (%walk_header_zero(fields) : walk_goal(fields, fields, xs, n, D.header_size(fields), _, 0n, D.header_size(fields), [], xs, P.adv(xs, D.header_size(fields)), C.CEnd{}, 0n, walk_count(fields, 0n), walk_count(fields, 0n), D.go(fields, 0n, 0n, D.layout(True{}, D.header_size(fields), n, xs)))
           %walk_forest_of_chain(fields, shape) : walk_goal(fields, _, xs, n, D.header_size(fields), walk_header(fields, 0n), 0n, D.header_size(fields), [], xs, P.adv(xs, D.header_size(fields)), C.CEnd{}, 0n, walk_count(fields, 0n), walk_count(fields, 0n), D.go(fields, 0n, 0n, D.layout(True{}, D.header_size(fields), n, xs)))
           rec({==}))))


law adv_size:
  for +s: P.Slice
  for +k: Nat
  {P.slice_size(P.adv(s, k)) == Nat.sub(P.slice_size(s), k) : Nat}
def adv_size(s, k):
  match s:
    case P.Slice{cs, at, len}: PK.normalize_size(cs, Nat.add(at, k), Nat.sub(len, k))

law union_finish:
  for +options: T.Schema
  for +sl: P.Slice
  for +m: Nat
  for out: D.Out
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +roomsl: {Nat.is_le(1n+m, P.slice_size(sl)) == True{} : Bool}
  for res: pick_sound(options, U32.to_nat(P.byte_at(sl, 0n)), P.byte_at(sl, 0n), m, P.adv(sl, 1n), out)
  CL.region_sound(T.Union{options}, 1n+m, sl, out)
def union_finish(options, sl, m, out, wfsl, roomsl, res):
  match out:
    case D.Refused{}: Unit{}
    case D.Begin{r}: Empty.absurd(CL.region_sound(T.Union{options}, 1n+m, sl, D.Begin{r}), res)
    case D.Parsed{v, rest}: union_sound(options, sl, m, v, rest, wfsl, roomsl, res)

law compatible_union_finish:
  for +selectors: +List<U32>
  for +options: T.Schema
  for +sl: P.Slice
  for +m: Nat
  for out: D.Out
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +roomsl: {Nat.is_le(1n+m, P.slice_size(sl)) == True{} : Bool}
  for res: among_sound(selectors, options, P.byte_at(sl, 0n), m, P.adv(sl, 1n), out)
  CL.region_sound(T.CompatibleUnion{selectors, options}, 1n+m, sl, out)
def compatible_union_finish(selectors, options, sl, m, out, wfsl, roomsl, res):
  match out:
    case D.Refused{}: Unit{}
    case D.Begin{r}: Empty.absurd(CL.region_sound(T.CompatibleUnion{selectors, options}, 1n+m, sl, D.Begin{r}), res)
    case D.Parsed{v, rest}: compatible_union_sound(selectors, options, sl, m, v, rest, wfsl, roomsl, res)

law union_region:
  for +options: T.Schema
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for rec: cursor_goal(options, 0n, D.selector_index(D.union_start(n, xs)), D.union_start(n, xs), options, xs, 0n, 0n, [], xs, xs, C.CEnd{}, 0n, 0n)
  CL.region_sound(T.Union{options}, n, xs, D.go(options, 0n, D.selector_index(D.union_start(n, xs)), D.union_start(n, xs)))
def union_region(options, n, xs, wf, room, rec):
  match n:
    case 0n:
      %Equal.sym(D.Out, D.go(options, 0n, 0n, D.Invalid{}), D.Refused{}, invalid_refuses(options, 0n, 0n)) : CL.region_sound(T.Union{options}, 0n, xs, _)
      Unit{}
    case 1n+m:
      union_finish(options, xs, m, D.go(options, 0n, U32.to_nat(P.byte_at(xs, 0n)), D.Pick{P.byte_at(xs, 0n), m, P.adv(xs, 1n)}), wf, room,
        rec(PK.wf_adv(xs, 1n, wf),
          (%Equal.sym(Nat, P.slice_size(P.adv(xs, 1n)), Nat.sub(P.slice_size(xs), 1n), adv_size(xs, 1n)) : {Nat.is_le(m, _) == True{} : Bool}
           le_sub(1n, m, P.slice_size(xs), room))))

law compatible_union_region:
  for +selectors: +List<U32>
  for +options: T.Schema
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for rec: cursor_goal(options, 0n, 0n, D.among_start(selectors, n, xs), options, xs, 0n, 0n, [], xs, xs, C.CEnd{}, 0n, 0n)
  CL.region_sound(T.CompatibleUnion{selectors, options}, n, xs, D.go(options, 0n, 0n, D.among_start(selectors, n, xs)))
def compatible_union_region(selectors, options, n, xs, wf, room, rec):
  match n:
    case 0n:
      %Equal.sym(D.Out, D.go(options, 0n, 0n, D.Invalid{}), D.Refused{}, invalid_refuses(options, 0n, 0n)) : CL.region_sound(T.CompatibleUnion{selectors, options}, 0n, xs, _)
      Unit{}
    case 1n+m:
      compatible_union_finish(selectors, options, xs, m, D.go(options, 0n, 0n, D.PickAmong{selectors, P.byte_at(xs, 0n), m, P.adv(xs, 1n)}), wf, room,
        rec(PK.wf_adv(xs, 1n, wf),
          (%Equal.sym(Nat, P.slice_size(P.adv(xs, 1n)), Nat.sub(P.slice_size(xs), 1n), adv_size(xs, 1n)) : {Nat.is_le(m, _) == True{} : Bool}
           le_sub(1n, m, P.slice_size(xs), room))))

# The selected option of a union: its region is the bytes after the selector.
law pick_here:
  for +hh: T.Schema
  for +tt: T.Schema
  for +sel: U32
  for +n: Nat
  for +xs: P.Slice
  for r: D.Out
  for child: CL.region_sound(hh, n, xs, r)
  pick_sound(T.Chain{hh, tt}, 0n, sel, n, xs, D.wrap_selected(sel, r))
def pick_here(hh, tt, sel, n, xs, r, child):
  match r:
    case D.Refused{}: Unit{}
    case D.Begin{q}: Empty.absurd(pick_sound(T.Chain{hh, tt}, 0n, sel, n, xs, D.wrap_selected(sel, D.Begin{q})), child)
    case D.Parsed{cv, crest}:
      (childparts, (restview, wfrest)) = child
      ((cv,
        ({==},
         Equal.trans(Maybe<&2, +List<T.Part>>, SC.tagged(sel, SC.parts(C.to_value(cv), hh)), SC.tagged(sel, Some{[SC.fragment(SS.fixed_size(hh), List.take(&2, U32, P.slice_bytes(xs), n))]}), Some{[T.Variable{sel <> List.take(&2, U32, P.slice_bytes(xs), n)}]},
           Equal.cong(Maybe<&2, +List<T.Part>>, Maybe<&2, +List<T.Part>>, ee => SC.tagged(sel, ee), SC.parts(C.to_value(cv), hh), Some{[SC.fragment(SS.fixed_size(hh), List.take(&2, U32, P.slice_bytes(xs), n))]}, childparts),
           tagged_fragment(sel, SS.fixed_size(hh), List.take(&2, U32, P.slice_bytes(xs), n))))),
       (restview, wfrest))

law among_here_sound:
  for +hh: T.Schema
  for +tt: T.Schema
  for +rest: +List<U32>
  for +s: U32
  for +sel: U32
  for +n: Nat
  for +xs: P.Slice
  for r: D.Out
  for +hit: {U32.is_eq(s, sel) == True{} : Bool}
  for child: CL.region_sound(hh, n, xs, r)
  among_sound(s <> rest, T.Chain{hh, tt}, sel, n, xs, D.wrap_selected(sel, r))
def among_here_sound(hh, tt, rest, s, sel, n, xs, r, hit, child):
  match r:
    case D.Refused{}: Unit{}
    case D.Begin{q}: Empty.absurd(among_sound(s <> rest, T.Chain{hh, tt}, sel, n, xs, D.wrap_selected(sel, D.Begin{q})), child)
    case D.Parsed{cv, crest}:
      (childparts, (restview, wfrest)) = child
      ((cv,
        ({==},
         %Equal.sym(Bool, U32.is_eq(s, sel), True{}, hit) : {SC.with_option(SS.selected(_, hh, SS.compatible_option(rest, tt, sel)), t => SC.tagged(sel, SC.parts(C.to_value(cv), t))) == Some{[T.Variable{sel <> List.take(&2, U32, P.slice_bytes(xs), n)}]} : Maybe<&2, +List<T.Part>>}
         Equal.trans(Maybe<&2, +List<T.Part>>, SC.tagged(sel, SC.parts(C.to_value(cv), hh)), SC.tagged(sel, Some{[SC.fragment(SS.fixed_size(hh), List.take(&2, U32, P.slice_bytes(xs), n))]}), Some{[T.Variable{sel <> List.take(&2, U32, P.slice_bytes(xs), n)}]},
           Equal.cong(Maybe<&2, +List<T.Part>>, Maybe<&2, +List<T.Part>>, ee => SC.tagged(sel, ee), SC.parts(C.to_value(cv), hh), Some{[SC.fragment(SS.fixed_size(hh), List.take(&2, U32, P.slice_bytes(xs), n))]}, childparts),
           tagged_fragment(sel, SS.fixed_size(hh), List.take(&2, U32, P.slice_bytes(xs), n))))),
       (restview, wfrest))

law among_later_sound:
  for +hh: T.Schema
  for +tt: T.Schema
  for +rest: +List<U32>
  for +s: U32
  for +sel: U32
  for +n: Nat
  for +xs: P.Slice
  for +miss: {U32.is_eq(s, sel) == False{} : Bool}
  for later: among_sound(rest, tt, sel, n, xs, D.go(tt, 0n, 0n, D.PickAmong{rest, sel, n, xs}))
  among_sound(s <> rest, T.Chain{hh, tt}, sel, n, xs, D.go(tt, 0n, 0n, D.PickAmong{rest, sel, n, xs}))
def among_later_sound(hh, tt, rest, s, sel, n, xs, miss, later):
  %Equal.sym(Bool, U32.is_eq(s, sel), False{}, miss) : option_sound(SS.selected(_, hh, SS.compatible_option(rest, tt, sel)), sel, n, xs, D.go(tt, 0n, 0n, D.PickAmong{rest, sel, n, xs}))
  later

# ---------------------------------------------------------------------------
# One walk step, dispatched on the child's result: a refused child refuses the
# whole walk, and a parsed child extends the decoded prefix.
law step_dispatch_fixed:
  for +fields: T.Schema
  for +fs: T.Schema
  for +hh: T.Schema
  for +tt: T.Schema
  for +fsr: T.Schema
  for +nk: Nat
  for +base: Nat
  for +krem: Nat
  for +total: Nat
  for split: forest_split(fs, hh, fsr)
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +pos: Nat
  for +w: Nat
  for +hs: Nat
  for +pdone: +List<T.Part>
  for +acc: C.CValue
  for +hdr: P.Slice
  for +pay: P.Slice
  for +width: {SS.fixed_size(hh) == Some{w} : Maybe<&2, Nat>}
  for r: D.Out
  for child: CL.region_sound(hh, w, hdr, r)
  for rec: @+cv: C.CValue -> @+crest: P.Slice -> walk_goal(fields, fsr, sl, end, fixedtotal, hs, Nat.add(h, w), pos, List.append(&2, T.Part, pdone, [T.Fixed{List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), h), w)}]), crest, pay, C.CCons{cv, acc}, 1n+base, krem, total, D.go(tt, 0n, nk, D.Walk{True{}, D.Parsed{cv, crest}, pay, pos, end, acc}))
  walk_goal(fields, fs, sl, end, fixedtotal, Nat.add(w, hs), h, pos, pdone, hdr, pay, acc, base, 1n+krem, total, D.go(tt, 0n, nk, D.Walk{True{}, r, pay, pos, end, acc}))
def step_dispatch_fixed(fields, fs, hh, tt, fsr, nk, base, krem, total, split, sl, end, fixedtotal, h, pos, w, hs, pdone, acc, hdr, pay, width, r, child, rec):
  match r:
    case D.Begin{q}: Empty.absurd(walk_goal(fields, fs, sl, end, fixedtotal, Nat.add(w, hs), h, pos, pdone, hdr, pay, acc, base, 1n+krem, total, D.go(tt, 0n, nk, D.Walk{True{}, D.Begin{q}, pay, pos, end, acc})), child)
    case D.Refused{}:
      %Equal.sym(D.Out, D.go(tt, 0n, nk, D.Walk{True{}, D.Refused{}, pay, pos, end, acc}), D.Refused{}, broken_refuses(tt, nk, True{}, D.Refused{}, pay, pos, end, acc, {==})) : walk_goal(fields, fs, sl, end, fixedtotal, Nat.add(w, hs), h, pos, pdone, hdr, pay, acc, base, 1n+krem, total, _)
      refused_walk(fields, fs, sl, end, fixedtotal, Nat.add(w, hs), h, pos, pdone, hdr, pay, acc, base, 1n+krem, total)
    case D.Parsed{+cv, +crest}:
      (childparts, (childrest, wfcrest)) = child
      step_fixed(fields, fs, hh, tt, fsr, nk, base, krem, total, split, sl, end, fixedtotal, h, pos, w, pdone, acc, cv, hdr, crest, pay, width, childparts, childrest, wfcrest, hs, rec(cv, crest))

law step_dispatch_variable_ok:
  for +fields: T.Schema
  for +fs: T.Schema
  for +hh: T.Schema
  for +tt: T.Schema
  for +fsr: T.Schema
  for +nk: Nat
  for +base: Nat
  for +krem: Nat
  for +total: Nat
  for split: forest_split(fs, hh, fsr)
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +pos: Nat
  for +stop: Nat
  for +hs: Nat
  for +pdone: +List<T.Part>
  for +acc: C.CValue
  for +hdr: P.Slice
  for +pay: P.Slice
  for +width: {SS.fixed_size(hh) == None{} : Maybe<&2, Nat>}
  for r: D.Out
  for +offsetval: {P.offset_at(hdr) == pos : Nat}
  for +posstop: {Nat.is_le(pos, stop) == True{} : Bool}
  for +stople: {Nat.is_le(stop, end) == True{} : Bool}
  for child: CL.region_sound(hh, Nat.sub(stop, pos), pay, r)
  for rec: @+cv: C.CValue -> @+crest: P.Slice -> walk_goal(fields, fsr, sl, end, fixedtotal, hs, Nat.add(h, 4n), stop, List.append(&2, T.Part, pdone, [T.Variable{List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), pos), Nat.sub(stop, pos))}]), P.adv(hdr, 4n), crest, C.CCons{cv, acc}, 1n+base, krem, total, D.go(tt, 0n, nk, D.Walk{False{}, D.Parsed{cv, crest}, P.adv(hdr, 4n), stop, end, acc}))
  walk_goal(fields, fs, sl, end, fixedtotal, Nat.add(4n, hs), h, pos, pdone, hdr, pay, acc, base, 1n+krem, total, D.go(tt, 0n, nk, D.Walk{False{}, r, P.adv(hdr, 4n), stop, end, acc}))
def step_dispatch_variable_ok(fields, fs, hh, tt, fsr, nk, base, krem, total, split, sl, end, fixedtotal, h, pos, stop, hs, pdone, acc, hdr, pay, width, r, offsetval, posstop, stople, child, rec):
  match r:
    case D.Begin{q}: Empty.absurd(walk_goal(fields, fs, sl, end, fixedtotal, Nat.add(4n, hs), h, pos, pdone, hdr, pay, acc, base, 1n+krem, total, D.go(tt, 0n, nk, D.Walk{False{}, D.Begin{q}, P.adv(hdr, 4n), stop, end, acc})), child)
    case D.Refused{}:
      %Equal.sym(D.Out, D.go(tt, 0n, nk, D.Walk{False{}, D.Refused{}, P.adv(hdr, 4n), stop, end, acc}), D.Refused{}, broken_refuses(tt, nk, False{}, D.Refused{}, P.adv(hdr, 4n), stop, end, acc, {==})) : walk_goal(fields, fs, sl, end, fixedtotal, Nat.add(4n, hs), h, pos, pdone, hdr, pay, acc, base, 1n+krem, total, _)
      refused_walk(fields, fs, sl, end, fixedtotal, Nat.add(4n, hs), h, pos, pdone, hdr, pay, acc, base, 1n+krem, total)
    case D.Parsed{+cv, +crest}:
      (childparts, (childrest, wfcrest)) = child
      step_variable(fields, fs, hh, tt, fsr, nk, base, krem, total, split, sl, end, fixedtotal, h, pos, stop, pdone, acc, cv, hdr, crest, pay, width, childparts, childrest, wfcrest, hs, offsetval, posstop, stople, rec(cv, crest))

law step_dispatch_variable:
  for +fields: T.Schema
  for +fs: T.Schema
  for +hh: T.Schema
  for +tt: T.Schema
  for +fsr: T.Schema
  for +nk: Nat
  for +base: Nat
  for +krem: Nat
  for +total: Nat
  for split: forest_split(fs, hh, fsr)
  for +sl: P.Slice
  for +end: Nat
  for +fixedtotal: Nat
  for +h: Nat
  for +pos: Nat
  for +stop: Nat
  for +hs: Nat
  for +pdone: +List<T.Part>
  for +acc: C.CValue
  for +hdr: P.Slice
  for +pay: P.Slice
  for +width: {SS.fixed_size(hh) == None{} : Maybe<&2, Nat>}
  for +ok: Bool
  for +oksame: {Bool.and(D.nat_eq(P.offset_at(hdr), pos), Bool.and(D.nat_le(P.offset_at(hdr), stop), D.nat_le(stop, end))) == ok : Bool}
  for r: D.Out
  for +rsame: {D.go(hh, 1n, 0n, D.region_if(ok, Nat.sub(stop, P.offset_at(hdr)), pay)) == r : D.Out}
  for child: CL.region_sound(hh, Nat.sub(stop, P.offset_at(hdr)), pay, r)
  for rec: @+cv: C.CValue -> @+crest: P.Slice -> walk_goal(fields, fsr, sl, end, fixedtotal, hs, Nat.add(h, 4n), stop, List.append(&2, T.Part, pdone, [T.Variable{List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(sl), pos), Nat.sub(stop, pos))}]), P.adv(hdr, 4n), crest, C.CCons{cv, acc}, 1n+base, krem, total, D.go(tt, 0n, nk, D.Walk{False{}, D.Parsed{cv, crest}, P.adv(hdr, 4n), stop, end, acc}))
  walk_goal(fields, fs, sl, end, fixedtotal, Nat.add(4n, hs), h, pos, pdone, hdr, pay, acc, base, 1n+krem, total, D.go(tt, 0n, nk, D.Walk{False{}, r, P.adv(hdr, 4n), stop, end, acc}))
def step_dispatch_variable(fields, fs, hh, tt, fsr, nk, base, krem, total, split, sl, end, fixedtotal, h, pos, stop, hs, pdone, acc, hdr, pay, width, ok, oksame, r, rsame, child, rec):
  match ok:
    case False{}:
      %Equal.sym(D.Out, r, D.Refused{}, Equal.trans(D.Out, r, D.go(hh, 1n, 0n, D.Invalid{}), D.Refused{}, Equal.sym(D.Out, D.go(hh, 1n, 0n, D.Invalid{}), r, rsame), invalid_refuses(hh, 1n, 0n))) : walk_goal(fields, fs, sl, end, fixedtotal, Nat.add(4n, hs), h, pos, pdone, hdr, pay, acc, base, 1n+krem, total, D.go(tt, 0n, nk, D.Walk{False{}, _, P.adv(hdr, 4n), stop, end, acc}))
      %Equal.sym(D.Out, D.go(tt, 0n, nk, D.Walk{False{}, D.Refused{}, P.adv(hdr, 4n), stop, end, acc}), D.Refused{}, broken_refuses(tt, nk, False{}, D.Refused{}, P.adv(hdr, 4n), stop, end, acc, {==})) : walk_goal(fields, fs, sl, end, fixedtotal, Nat.add(4n, hs), h, pos, pdone, hdr, pay, acc, base, 1n+krem, total, _)
      refused_walk(fields, fs, sl, end, fixedtotal, Nat.add(4n, hs), h, pos, pdone, hdr, pay, acc, base, 1n+krem, total)
    case True{}:
      +startpos = CL.nat_eq_sound(P.offset_at(hdr), pos, V.and_left(D.nat_eq(P.offset_at(hdr), pos), Bool.and(D.nat_le(P.offset_at(hdr), stop), D.nat_le(stop, end)), oksame))
      +bounds = V.and_right(D.nat_eq(P.offset_at(hdr), pos), Bool.and(D.nat_le(P.offset_at(hdr), stop), D.nat_le(stop, end)), oksame)
      step_dispatch_variable_ok(fields, fs, hh, tt, fsr, nk, base, krem, total, split, sl, end, fixedtotal, h, pos, stop, hs, pdone, acc, hdr, pay, width, r,
        startpos,
        CL.nat_le_sound(pos, stop, (%startpos : {D.nat_le(_, stop) == True{} : Bool}
                                    V.and_left(D.nat_le(P.offset_at(hdr), stop), D.nat_le(stop, end), bounds))),
        CL.nat_le_sound(stop, end, V.and_right(D.nat_le(P.offset_at(hdr), stop), D.nat_le(stop, end), bounds)),
        (%startpos : CL.region_sound(hh, Nat.sub(stop, _), pay, r)
         child),
        rec)

# The child region of a fixed-width field sits at the header cursor and fits.
law fixed_child_room:
  for +sl: P.Slice
  for +hdr: P.Slice
  for +h: Nat
  for +w: Nat
  for +hs: Nat
  for +fixedtotal: Nat
  for +pos: Nat
  for +end: Nat
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +wfhdr: {List.length(&2, U32, P.slice_bytes(hdr)) == P.slice_size(hdr) : Nat}
  for +hdrview: {P.slice_bytes(hdr) == List.drop(&2, U32, P.slice_bytes(sl), h) : +List<U32>}
  for +remaining: {Nat.add(h, Nat.add(w, hs)) == fixedtotal : Nat}
  for +fixle: {Nat.is_le(fixedtotal, pos) == True{} : Bool}
  for +posle: {Nat.is_le(pos, end) == True{} : Bool}
  for +roomsl: {Nat.is_le(end, P.slice_size(sl)) == True{} : Bool}
  {Nat.is_le(w, P.slice_size(hdr)) == True{} : Bool}
def fixed_child_room(sl, hdr, h, w, hs, fixedtotal, pos, end, wfsl, wfhdr, hdrview, remaining, fixle, posle, roomsl):
  %wfhdr : {Nat.is_le(w, _) == True{} : Bool}
  hdr_room(sl, hdr, h, w, wfsl, hdrview,
    NO.transitive(Nat.add(h, w), fixedtotal, P.slice_size(sl),
      header_bound(h, w, hs, fixedtotal, remaining_fixed(h, w, hs, fixedtotal, remaining)),
      NO.transitive(fixedtotal, pos, P.slice_size(sl), fixle, NO.transitive(pos, end, P.slice_size(sl), posle, roomsl))))

law variable_child_room:
  for +sl: P.Slice
  for +pay: P.Slice
  for +pos: Nat
  for +stop: Nat
  for +end: Nat
  for +wfsl: {List.length(&2, U32, P.slice_bytes(sl)) == P.slice_size(sl) : Nat}
  for +wfpay: {List.length(&2, U32, P.slice_bytes(pay)) == P.slice_size(pay) : Nat}
  for +payview: {P.slice_bytes(pay) == List.drop(&2, U32, P.slice_bytes(sl), pos) : +List<U32>}
  for +posstop: {Nat.is_le(pos, stop) == True{} : Bool}
  for +stople: {Nat.is_le(stop, end) == True{} : Bool}
  for +roomsl: {Nat.is_le(end, P.slice_size(sl)) == True{} : Bool}
  {Nat.is_le(Nat.sub(stop, pos), P.slice_size(pay)) == True{} : Bool}
def variable_child_room(sl, pay, pos, stop, end, wfsl, wfpay, payview, posstop, stople, roomsl):
  %wfpay : {Nat.is_le(Nat.sub(stop, pos), _) == True{} : Bool}
  %Equal.sym(+List<U32>, P.slice_bytes(pay), List.drop(&2, U32, P.slice_bytes(sl), pos), payview) : {Nat.is_le(Nat.sub(stop, pos), List.length(&2, U32, _)) == True{} : Bool}
  payload_room(sl, pos, stop, wfsl, posstop, NO.transitive(stop, end, P.slice_size(sl), stople, roomsl))

# Case analysis on a field's declared width, as a value rather than a match.
law width_cases:
  for +hh: T.Schema
  for +wopt: Maybe<&2, Nat>
  for -G: Type
  for +wsame: {IS.fixed_size(hh) == wopt : Maybe<&2, Nat>}
  for fixedcase: @+w: Nat -> @+wfix: {IS.fixed_size(hh) == Some{w} : Maybe<&2, Nat>} -> G
  for varcase: @+wvar: {IS.fixed_size(hh) == None{} : Maybe<&2, Nat>} -> G
  G
def width_cases(hh, wopt, G, wsame, fixedcase, varcase):
  match wopt:
    case Some{w}: fixedcase(w, wsame)
    case None{}: varcase(wsame)

# ---------------------------------------------------------------------------
# What remains: the single recursive `go_sound` over (schema, phase, k,
# cursor) that dispatches to the leaf lemmas, the two walk steps and the
# region assemblies above, and the top-level composition to
# `accepted_serializes_exactly`. The pieces it needs are all in this file and
# in proofs/cursor_leaves.bend; the missing ingredient is a legality predicate
# usable inside unions: `src/schema.valid_go` rejects `Null` everywhere except
# as a union's first option, so the recursion needs the structural predicate
# that a union's option list satisfies.
