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
import ./decode_facts.bend as FA
import ./decode_shape.bend as Shape
import ./layout_image_headers.bend as HW
import ./primitive_invariants.bend as V
import ./lists.bend as L
import ./cursor_leaves.bend as CL
import ./schema_width.bend as SW
import ../spec/nat_bytes.bend as N
import ./bit_vector_inverse.bend as BVI
import ../src/primitives.bend as IP

# Turning the uniform region premise into the inputs each composite region law
# needs. `holds(schema, value, xs, n)` says the region's bytes are exactly the
# independent encoding of the value as one fragment; the specification builds
# that fragment with `require`, `aggregate` and `one`, so these eliminators
# read the pieces back out of it.
def is_some_parts(r: Maybe<&2, +List<T.Part>>) -> Bool:
  match r:
    case Some{ps}: True{}
    case None{}: False{}

def is_some_bytes(r: Maybe<&2, +List<U32>>) -> Bool:
  match r:
    case Some{ys}: True{}
    case None{}: False{}

def parts_of(r: Maybe<&2, +List<T.Part>>) -> +List<T.Part>:
  match r:
    case Some{ps}: ps
    case None{}: []

def bytes_of(r: Maybe<&2, +List<U32>>) -> +List<U32>:
  match r:
    case Some{ys}: ys
    case None{}: []

law one_elim:
  for +w: Maybe<&2, Nat>
  for +enc: Maybe<&2, +List<U32>>
  for +zs: +List<U32>
  for +known: {SC.one(enc, w) == Some{[SC.fragment(w, zs)]} : Maybe<&2, +List<T.Part>>}
  {enc == Some{zs} : Maybe<&2, +List<U32>>}
def one_elim(w, enc, zs, known):
  match w:
    case Some{q}:
      match enc:
        case None{}:
          Empty.absurd({None{} == Some{zs} : Maybe<&2, +List<U32>>},
            F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, is_some_parts, SC.one(None{}, Some{q}), Some{[SC.fragment(Some{q}, zs)]}, known)))
        case Some{ys}:
          Equal.cong(+List<U32>, Maybe<&2, +List<U32>>, us => Some{us}, ys, zs,
            Equal.cong(Maybe<&2, +List<T.Part>>, +List<U32>, CLeaf.fragment_bytes, Some{[T.Fixed{ys}]}, Some{[T.Fixed{zs}]}, known))
    case None{}:
      match enc:
        case None{}:
          Empty.absurd({None{} == Some{zs} : Maybe<&2, +List<U32>>},
            F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, is_some_parts, SC.one(None{}, None{}), Some{[SC.fragment(None{}, zs)]}, known)))
        case Some{ys}:
          Equal.cong(+List<U32>, Maybe<&2, +List<U32>>, us => Some{us}, ys, zs,
            Equal.cong(Maybe<&2, +List<T.Part>>, +List<U32>, CLeaf.fragment_bytes, Some{[T.Variable{ys}]}, Some{[T.Variable{zs}]}, known))

law aggregate_elim:
  for -G: Type
  for +r: Maybe<&2, +List<T.Part>>
  for +w: Maybe<&2, Nat>
  for +zs: +List<U32>
  for +known: {SC.aggregate(r, w) == Some{[SC.fragment(w, zs)]} : Maybe<&2, +List<T.Part>>}
  for k: @+ps: +List<T.Part> -> @+same: {r == Some{ps} : Maybe<&2, +List<T.Part>>} -> @+enc: {SL.encoding(ps) == Some{zs} : Maybe<&2, +List<U32>>} -> G
  G
def aggregate_elim(G, r, w, zs, known, k):
  match r:
    case None{}:
      Empty.absurd(G, F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, is_some_parts, SC.aggregate(None{}, w), Some{[SC.fragment(w, zs)]}, known)))
    case Some{ps}: k(ps, {==}, one_elim(w, SL.encoding(ps), zs, known))

law require_elim:
  for -G: Type
  for +ok: Bool
  for +r: Maybe<&2, +List<T.Part>>
  for +target: +List<T.Part>
  for +known: {SC.require(ok, r) == Some{target} : Maybe<&2, +List<T.Part>>}
  for k: @+okay: {ok == True{} : Bool} -> @+same: {r == Some{target} : Maybe<&2, +List<T.Part>>} -> G
  G
def require_elim(G, ok, r, target, known, k):
  match ok:
    case False{}:
      Empty.absurd(G, F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, is_some_parts, SC.require(False{}, r), Some{target}, known)))
    case True{}: k({==}, known)

# Reading the width alignment out of the shape facts once the parts are known.
law chain_fact_widths:
  for +ws: +List<Maybe<&2, Nat>>
  for +size: Maybe<&2, Nat>
  for +r: Maybe<&2, +List<T.Part>>
  for +ps: +List<T.Part>
  for +same: {r == Some{ps} : Maybe<&2, +List<T.Part>>}
  for known: FA.chain_fact(ws, size, r)
  {HW.widths(ps) == ws : +List<Maybe<&2, Nat>>}
def chain_fact_widths(ws, size, r, ps, same, known):
  match r:
    case None{}:
      Empty.absurd({HW.widths(ps) == ws : +List<Maybe<&2, Nat>>},
        F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, is_some_parts, None{}, Some{ps}, same)))
    case Some{qs}:
      (align, total) = known
      Equal.trans(+List<Maybe<&2, Nat>>, HW.widths(ps), HW.widths(qs), ws,
        Equal.cong(+List<T.Part>, +List<Maybe<&2, Nat>>, HW.widths, ps, qs,
          Equal.sym(+List<T.Part>, qs, ps, Equal.cong(Maybe<&2, +List<T.Part>>, +List<T.Part>, parts_of, Some{qs}, Some{ps}, same))),
        align)

law repeat_fact_widths:
  for +ws: +List<Maybe<&2, Nat>>
  for +r: Maybe<&2, +List<T.Part>>
  for +ps: +List<T.Part>
  for +same: {r == Some{ps} : Maybe<&2, +List<T.Part>>}
  for known: FA.repeat_fact(ws, r)
  {HW.widths(ps) == ws : +List<Maybe<&2, Nat>>}
def repeat_fact_widths(ws, r, ps, same, known):
  match r:
    case None{}:
      Empty.absurd({HW.widths(ps) == ws : +List<Maybe<&2, Nat>>},
        F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, is_some_parts, None{}, Some{ps}, same)))
    case Some{qs}:
      Equal.trans(+List<Maybe<&2, Nat>>, HW.widths(ps), HW.widths(qs), ws,
        Equal.cong(+List<T.Part>, +List<Maybe<&2, Nat>>, HW.widths, ps, qs,
          Equal.sym(+List<T.Part>, qs, ps, Equal.cong(Maybe<&2, +List<T.Part>>, +List<T.Part>, parts_of, Some{qs}, Some{ps}, same))),
        known)

# ---------------------------------------------------------------------------
# Container and progressive container regions.
law container_region:
  for +names: +List<String>
  for +fields: T.Schema
  for +items: T.Value
  for +n: Nat
  for +xs: P.Slice
  for +ps: +List<T.Part>
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +forest: {IS.valid_go(fields, True{}) == True{} : Bool}
  for +partsof: {SC.parts(items, fields) == Some{ps} : Maybe<&2, +List<T.Part>>}
  for +enc: {SL.encoding(ps) == Some{List.take(&2, U32, P.slice_bytes(xs), n)} : Maybe<&2, +List<U32>>}
  for walk: CWalk.walk_goal(xs, n, SL.fixed_size(ps), 0n, SL.fixed_size(ps), [], ps, fields, xs, P.adv(xs, SL.fixed_size(ps)), C.CEnd{}, items, D.go(fields, 0n, 0n, D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(ps)), SL.fixed_size(ps), n, C.CEnd{}}))
  CLeaf.parsed_as(T.Sequence{items}, xs, n, D.go(T.Container{names, fields}, 1n, 0n, D.Region{n, xs}))
def container_region(names, fields, items, n, xs, ps, wf, room, forest, partsof, enc, walk):
  CWalk.container_complete(names, fields, items, ps, n, xs, wf, room, partsof,
    chain_fact_widths(FA.widths(fields), SS.fixed_size(fields), SC.parts(items, fields), ps, partsof,
      Shape.forest_view(fields, items, SC.parts(items, fields), forest,
        Shape.facts(items, fields, Shape.ok_forest(fields, forest)))),
    enc, walk)

law progressive_container_region:
  for +names: +List<String>
  for +fields: T.Schema
  for +active: +List<Bool>
  for +items: T.Value
  for +n: Nat
  for +xs: P.Slice
  for +ps: +List<T.Part>
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +forest: {IS.valid_go(fields, True{}) == True{} : Bool}
  for +partsof: {SC.parts(items, fields) == Some{ps} : Maybe<&2, +List<T.Part>>}
  for +enc: {SL.encoding(ps) == Some{List.take(&2, U32, P.slice_bytes(xs), n)} : Maybe<&2, +List<U32>>}
  for walk: CWalk.walk_goal(xs, n, SL.fixed_size(ps), 0n, SL.fixed_size(ps), [], ps, fields, xs, P.adv(xs, SL.fixed_size(ps)), C.CEnd{}, items, D.go(fields, 0n, 0n, D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(ps)), SL.fixed_size(ps), n, C.CEnd{}}))
  CLeaf.parsed_as(T.Sequence{items}, xs, n, D.go(T.ProgressiveContainer{names, fields, active}, 1n, 0n, D.Region{n, xs}))
def progressive_container_region(names, fields, active, items, n, xs, ps, wf, room, forest, partsof, enc, walk):
  CWalk.progressive_container_complete(names, fields, active, items, ps, n, xs, wf, room, partsof,
    chain_fact_widths(FA.widths(fields), SS.fixed_size(fields), SC.parts(items, fields), ps, partsof,
      Shape.forest_view(fields, items, SC.parts(items, fields), forest,
        Shape.facts(items, fields, Shape.ok_forest(fields, forest)))),
    enc, walk)

# ---------------------------------------------------------------------------
# Sequence regions. The parts of a `Repeat` value have uniform width, and the
# region's bytes are their layout.
law repeat_align:
  for +e: T.Schema
  for +m: Nat
  for +items: T.Value
  for +ps: +List<T.Part>
  for +legal: {IS.valid_go(e, False{}) == True{} : Bool}
  for +counted: {SC.count(items) == m : Nat}
  for +partsof: {SC.parts(items, T.Repeat{e}) == Some{ps} : Maybe<&2, +List<T.Part>>}
  {HW.widths(ps) == List.replicate(Maybe<&2, Nat>, m, SS.fixed_size(e)) : +List<Maybe<&2, Nat>>}
def repeat_align(e, m, items, ps, legal, counted, partsof):
  Equal.trans(+List<Maybe<&2, Nat>>, HW.widths(ps), List.replicate(Maybe<&2, Nat>, SC.count(items), SS.fixed_size(e)), List.replicate(Maybe<&2, Nat>, m, SS.fixed_size(e)),
    repeat_fact_widths(List.replicate(Maybe<&2, Nat>, SC.count(items), SS.fixed_size(e)), SC.parts(items, T.Repeat{e}), ps, partsof,
      Shape.facts(items, T.Repeat{e}, legal)),
    Equal.cong(Nat, +List<Maybe<&2, Nat>>, k => List.replicate(Maybe<&2, Nat>, k, SS.fixed_size(e)), SC.count(items), m, counted))

law region_lenn:
  for +ps: +List<T.Part>
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +enc: {SL.encoding(ps) == Some{List.take(&2, U32, P.slice_bytes(xs), n)} : Maybe<&2, +List<U32>>}
  {Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))) == n : Nat}
def region_lenn(ps, n, xs, wf, room, enc):
  CWalk.region_prefix(P.slice_bytes(xs), ps, n, CL.sized_by_wf(xs, n, wf, room),
    CWalk.encoding_layout(ps, List.take(&2, U32, P.slice_bytes(xs), n), enc))

law region_starts:
  for +ps: +List<T.Part>
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +enc: {SL.encoding(ps) == Some{List.take(&2, U32, P.slice_bytes(xs), n)} : Maybe<&2, +List<U32>>}
  CWalk.starts_with(xs, SL.fixed_parts(ps, SL.fixed_size(ps)))
def region_starts(ps, n, xs, wf, room, enc):
  +layout = CWalk.encoding_layout(ps, List.take(&2, U32, P.slice_bytes(xs), n), enc)
  +lenn = region_lenn(ps, n, xs, wf, room, enc)
  CWalk.starts_head(P.slice_bytes(xs), SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps),
    Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(xs), List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)))), List.take(&2, U32, P.slice_bytes(xs), n), List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)),
      Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))), n,
        Equal.trans(Nat, List.length(&2, U32, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps))), Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n,
          CWalk.layout_length_parts(ps), lenn)),
      Equal.sym(+List<U32>, List.append(&2, U32, SL.fixed_parts(ps, SL.fixed_size(ps)), SL.payloads(ps)), List.take(&2, U32, P.slice_bytes(xs), n), layout)))

law region_fits:
  for +ps: +List<T.Part>
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +enc: {SL.encoding(ps) == Some{List.take(&2, U32, P.slice_bytes(xs), n)} : Maybe<&2, +List<U32>>}
  {N.fits(4n, n) == True{} : Bool}
def region_fits(ps, n, xs, wf, room, enc):
  Equal.trans(Bool, N.fits(4n, n), N.fits(4n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps)))), True{},
    Equal.cong(Nat, Bool, k => N.fits(4n, k), n, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))),
      Equal.sym(Nat, Nat.add(SL.fixed_size(ps), List.length(&2, U32, SL.payloads(ps))), n, region_lenn(ps, n, xs, wf, room, enc))),
    CWalk.encoding_fits(ps, List.take(&2, U32, P.slice_bytes(xs), n), enc))

# The decoder's element count agrees with the specification's, whichever width
# the element type has.
law sequence_count:
  for +e: T.Schema
  for +m: Nat
  for +items: T.Value
  for +ps: +List<T.Part>
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +legal: {IS.valid_go(e, False{}) == True{} : Bool}
  for +counted: {SC.count(items) == m : Nat}
  for +partsof: {SC.parts(items, T.Repeat{e}) == Some{ps} : Maybe<&2, +List<T.Part>>}
  for +enc: {SL.encoding(ps) == Some{List.take(&2, U32, P.slice_bytes(xs), n)} : Maybe<&2, +List<U32>>}
  {D.list_count(IS.fixed_size(e), n, xs) == Some{m} : Maybe<&2, Nat>}
def sequence_count(e, m, items, ps, n, xs, wf, room, legal, counted, partsof, enc):
  +align = repeat_align(e, m, items, ps, legal, counted, partsof)
  +lenn = region_lenn(ps, n, xs, wf, room, enc)
  SW.width_elim({D.list_count(IS.fixed_size(e), n, xs) == Some{m} : Maybe<&2, Nat>}, SS.fixed_size(e), SW.width_positive(e, legal),
    q => weq => CWalk.list_count_fixed(e, q, m, ps, n, xs, weq, align, lenn),
    weq => CWalk.list_count_variable(e, m, ps, n, xs, weq, align, lenn,
      region_fits(ps, n, xs, wf, room, enc),
      region_starts(ps, n, xs, wf, room, enc)))

law vector_region:
  for +e: T.Schema
  for +m: Nat
  for +items: T.Value
  for +n: Nat
  for +xs: P.Slice
  for +ps: +List<T.Part>
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +legal: {IS.valid_go(e, False{}) == True{} : Bool}
  for +positive: {Nat.is_lt(0n, m) == True{} : Bool}
  for +counted: {SC.count(items) == m : Nat}
  for +partsof: {SC.parts(items, T.Repeat{e}) == Some{ps} : Maybe<&2, +List<T.Part>>}
  for +enc: {SL.encoding(ps) == Some{List.take(&2, U32, P.slice_bytes(xs), n)} : Maybe<&2, +List<U32>>}
  for walk: CWalk.walk_goal_seq(e, m, xs, n, SL.fixed_size(ps), 0n, SL.fixed_size(ps), [], ps, xs, P.adv(xs, SL.fixed_size(ps)), C.CEnd{}, items, D.go(T.Vector{e, m}, 0n, m, D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(ps)), SL.fixed_size(ps), n, C.CEnd{}}))
  CLeaf.parsed_as(T.Sequence{items}, xs, n, D.go(T.Vector{e, m}, 1n, 0n, D.Region{n, xs}))
def vector_region(e, m, items, n, xs, ps, wf, room, legal, positive, counted, partsof, enc, walk):
  CWalk.vector_complete(e, m, items, ps, n, xs, wf, room, partsof, counted, positive,
    repeat_align(e, m, items, ps, legal, counted, partsof), enc, walk)

law list_region:
  for +e: T.Schema
  for +limit: Nat
  for +m: Nat
  for +items: T.Value
  for +n: Nat
  for +xs: P.Slice
  for +ps: +List<T.Part>
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +legal: {IS.valid_go(e, False{}) == True{} : Bool}
  for +bound: {Nat.is_le(m, limit) == True{} : Bool}
  for +counted: {SC.count(items) == m : Nat}
  for +partsof: {SC.parts(items, T.Repeat{e}) == Some{ps} : Maybe<&2, +List<T.Part>>}
  for +enc: {SL.encoding(ps) == Some{List.take(&2, U32, P.slice_bytes(xs), n)} : Maybe<&2, +List<U32>>}
  for walk: CWalk.walk_goal_seq(e, m, xs, n, SL.fixed_size(ps), 0n, SL.fixed_size(ps), [], ps, xs, P.adv(xs, SL.fixed_size(ps)), C.CEnd{}, items, D.go(T.ListOf{e, limit}, 0n, m, D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(ps)), SL.fixed_size(ps), n, C.CEnd{}}))
  CLeaf.parsed_as(T.Sequence{items}, xs, n, D.go(T.ListOf{e, limit}, 1n, 0n, D.Region{n, xs}))
def list_region(e, limit, m, items, n, xs, ps, wf, room, legal, bound, counted, partsof, enc, walk):
  CWalk.list_complete(e, limit, m, items, ps, n, xs, wf, room, partsof, counted, bound,
    repeat_align(e, m, items, ps, legal, counted, partsof), enc,
    sequence_count(e, m, items, ps, n, xs, wf, room, legal, counted, partsof, enc), walk)

law progressive_list_region:
  for +e: T.Schema
  for +m: Nat
  for +items: T.Value
  for +n: Nat
  for +xs: P.Slice
  for +ps: +List<T.Part>
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for +legal: {IS.valid_go(e, False{}) == True{} : Bool}
  for +counted: {SC.count(items) == m : Nat}
  for +partsof: {SC.parts(items, T.Repeat{e}) == Some{ps} : Maybe<&2, +List<T.Part>>}
  for +enc: {SL.encoding(ps) == Some{List.take(&2, U32, P.slice_bytes(xs), n)} : Maybe<&2, +List<U32>>}
  for walk: CWalk.walk_goal_seq(e, m, xs, n, SL.fixed_size(ps), 0n, SL.fixed_size(ps), [], ps, xs, P.adv(xs, SL.fixed_size(ps)), C.CEnd{}, items, D.go(T.ProgressiveList{e}, 0n, m, D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(ps)), SL.fixed_size(ps), n, C.CEnd{}}))
  CLeaf.parsed_as(T.Sequence{items}, xs, n, D.go(T.ProgressiveList{e}, 1n, 0n, D.Region{n, xs}))
def progressive_list_region(e, m, items, n, xs, ps, wf, room, legal, counted, partsof, enc, walk):
  CWalk.progressive_list_complete(e, m, items, ps, n, xs, wf, room, partsof, counted,
    repeat_align(e, m, items, ps, legal, counted, partsof), enc,
    sequence_count(e, m, items, ps, n, xs, wf, room, legal, counted, partsof, enc), walk)

# ---------------------------------------------------------------------------
# Union regions: one selector byte, then the selected option's encoding.
def single_parts(r: Maybe<&2, +List<T.Part>>) -> Bool:
  match r:
    case Some{Con{T.Fixed{xs}, Nil{}}}: True{}
    case Some{Con{T.Variable{xs}, Nil{}}}: True{}
    case _: False{}

law with_option_elim:
  for -G: Type
  for +r: Maybe<&2, T.Schema>
  for f: T.Schema -> Maybe<&2, +List<T.Part>>
  for +target: +List<T.Part>
  for +known: {SC.with_option(r, f) == Some{target} : Maybe<&2, +List<T.Part>>}
  for k: @+s: T.Schema -> @+same: {r == Some{s} : Maybe<&2, T.Schema>} -> @+app: {f(s) == Some{target} : Maybe<&2, +List<T.Part>>} -> G
  G
def with_option_elim(G, r, f, target, known, k):
  match r:
    case None{}:
      Empty.absurd(G, F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, is_some_parts, SC.with_option(None{}, f), Some{target}, known)))
    case Some{s}: k(s, {==}, known)

law tagged_elim:
  for -G: Type
  for +sel: U32
  for +content: Maybe<&2, +List<T.Part>>
  for +zs: +List<U32>
  for +known: {SC.tagged(sel, content) == Some{[T.Variable{zs}]} : Maybe<&2, +List<T.Part>>}
  for k: @+issingle: {single_parts(content) == True{} : Bool} -> @+byteseq: {sel <> CLeaf.fragment_bytes(content) == zs : +List<U32>} -> G
  G
def tagged_elim(G, sel, content, zs, known, k):
  match content:
    case Some{Con{T.Fixed{ys}, Nil{}}}:
      k({==}, Equal.cong(Maybe<&2, +List<T.Part>>, +List<U32>, CLeaf.fragment_bytes, Some{[T.Variable{sel <> ys}]}, Some{[T.Variable{zs}]}, known))
    case Some{Con{T.Variable{ys}, Nil{}}}:
      k({==}, Equal.cong(Maybe<&2, +List<T.Part>>, +List<U32>, CLeaf.fragment_bytes, Some{[T.Variable{sel <> ys}]}, Some{[T.Variable{zs}]}, known))
    case Some{Nil{}}:
      Empty.absurd(G, F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, is_some_parts, SC.tagged(sel, Some{[]}), Some{[T.Variable{zs}]}, known)))
    case Some{Con{T.Fixed{ys}, Con{p, q}}}:
      Empty.absurd(G, F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, is_some_parts, SC.tagged(sel, Some{T.Fixed{ys} <> (p <> q)}), Some{[T.Variable{zs}]}, known)))
    case Some{Con{T.Variable{ys}, Con{p, q}}}:
      Empty.absurd(G, F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, is_some_parts, SC.tagged(sel, Some{T.Variable{ys} <> (p <> q)}), Some{[T.Variable{zs}]}, known)))
    case None{}:
      Empty.absurd(G, F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, is_some_parts, SC.tagged(sel, None{}), Some{[T.Variable{zs}]}, known)))

# A single-fragment parts result is the fragment of its own bytes at the
# schema's width.
law single_holds:
  for +s: T.Schema
  for +r: Maybe<&2, +List<T.Part>>
  for known: FA.single_result(SS.fixed_size(s), r)
  for +issingle: {single_parts(r) == True{} : Bool}
  {r == Some{[SC.fragment(SS.fixed_size(s), CLeaf.fragment_bytes(r))]} : Maybe<&2, +List<T.Part>>}
def single_holds(s, r, known, issingle):
  match r:
    case Some{Con{T.Fixed{ys}, Nil{}}}:
      %Equal.sym(Maybe<&2, Nat>, SS.fixed_size(s), Some{List.length(&2, U32, ys)}, known) : {Some{[T.Fixed{ys}]} == Some{[SC.fragment(_, ys)]} : Maybe<&2, +List<T.Part>>}
      {==}
    case Some{Con{T.Variable{ys}, Nil{}}}:
      %Equal.sym(Maybe<&2, Nat>, SS.fixed_size(s), None{}, known) : {Some{[T.Variable{ys}]} == Some{[SC.fragment(_, ys)]} : Maybe<&2, +List<T.Part>>}
      {==}
    case Some{Nil{}}: Empty.absurd({Some{[]} == Some{[SC.fragment(SS.fixed_size(s), CLeaf.fragment_bytes(Some{[]}))]} : Maybe<&2, +List<T.Part>>}, F.false_true(issingle))
    case Some{Con{T.Fixed{ys}, Con{p, q}}}: Empty.absurd({Some{T.Fixed{ys} <> (p <> q)} == Some{[SC.fragment(SS.fixed_size(s), CLeaf.fragment_bytes(Some{T.Fixed{ys} <> (p <> q)}))]} : Maybe<&2, +List<T.Part>>}, F.false_true(issingle))
    case Some{Con{T.Variable{ys}, Con{p, q}}}: Empty.absurd({Some{T.Variable{ys} <> (p <> q)} == Some{[SC.fragment(SS.fixed_size(s), CLeaf.fragment_bytes(Some{T.Variable{ys} <> (p <> q)}))]} : Maybe<&2, +List<T.Part>>}, F.false_true(issingle))
    case None{}: Empty.absurd({None{} == Some{[SC.fragment(SS.fixed_size(s), CLeaf.fragment_bytes(None{}))]} : Maybe<&2, +List<T.Part>>}, F.false_true(issingle))

law tail_prefix:
  for +bytes: +List<U32>
  for +m: Nat
  for +sel: U32
  for +ys: +List<U32>
  for +prefix: {List.take(&2, U32, bytes, 1n+m) == sel <> ys : +List<U32>}
  {ys == List.take(&2, U32, List.drop(&2, U32, bytes, 1n), m) : +List<U32>}
def tail_prefix(bytes, m, sel, ys, prefix):
  match bytes:
    case Nil{}:
      Empty.absurd({ys == List.take(&2, U32, List.drop(&2, U32, [], 1n), m) : +List<U32>},
        F.false_true(Equal.cong(+List<U32>, Bool, CWalk.is_cons, List.take(&2, U32, [], 1n+m), sel <> ys, prefix)))
    case Con{b, t}:
      Equal.trans(+List<U32>, ys, List.take(&2, U32, t, m), List.take(&2, U32, List.drop(&2, U32, t, 0n), m),
        Equal.sym(+List<U32>, List.take(&2, U32, t, m), ys,
          Equal.cong(+List<U32>, +List<U32>, CWalk.tail_of, List.take(&2, U32, b <> t, 1n+m), sel <> ys, prefix)),
        Equal.cong(+List<U32>, +List<U32>, us => List.take(&2, U32, us, m), t, List.drop(&2, U32, t, 0n),
          Equal.sym(+List<U32>, List.drop(&2, U32, t, 0n), t, PK.drop_zero(t))))

law adv_size:
  for +s: P.Slice
  for +k: Nat
  {P.slice_size(P.adv(s, k)) == Nat.sub(P.slice_size(s), k) : Nat}
def adv_size(s, k):
  match s:
    case P.Slice{cs, at, len}: PK.normalize_size(cs, Nat.add(at, k), Nat.sub(len, k))

law le_pred:
  for +m: Nat
  for +sz: Nat
  for +small: {Nat.is_le(1n+m, sz) == True{} : Bool}
  {Nat.is_le(m, Nat.sub(sz, 1n)) == True{} : Bool}
def le_pred(m, sz, small):
  match sz:
    case 0n: Empty.absurd({Nat.is_le(m, Nat.sub(0n, 1n)) == True{} : Bool}, F.false_true(small))
    case 1n+q:
      Equal.trans(Bool, Nat.is_le(m, Nat.sub(q, 0n)), Nat.is_le(m, q), True{},
        Equal.cong(Nat, Bool, k => Nat.is_le(m, k), Nat.sub(q, 0n), q, PK.sub_zero(q)),
        small)

law union_region:
  for +options: T.Schema
  for +sel: U32
  for +v: T.Value
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for shape: @+s: T.Schema -> {SS.option(options, U32.to_nat(sel)) == Some{s} : Maybe<&2, T.Schema>} -> FA.single_result(SS.fixed_size(s), SC.parts(v, s))
  for picked: @+s: T.Schema -> @+m: Nat ->
    {List.length(&2, U32, P.slice_bytes(P.adv(xs, 1n))) == P.slice_size(P.adv(xs, 1n)) : Nat} ->
    {Nat.is_le(m, P.slice_size(P.adv(xs, 1n))) == True{} : Bool} ->
    {SS.option(options, U32.to_nat(sel)) == Some{s} : Maybe<&2, T.Schema>} ->
    CLeaf.holds(s, v, P.adv(xs, 1n), m) ->
    CLeaf.parsed_as(T.Selected{sel, v}, P.adv(xs, 1n), m, D.go(options, 0n, U32.to_nat(sel), D.Pick{sel, m, P.adv(xs, 1n)}))
  for encoded: CLeaf.holds(T.Union{options}, T.Selected{sel, v}, xs, n)
  CLeaf.parsed_as(T.Selected{sel, v}, xs, n, D.go(T.Union{options}, 1n, 0n, D.Region{n, xs}))
def union_region(options, sel, v, n, xs, wf, room, shape, picked, encoded):
  with_option_elim(CLeaf.parsed_as(T.Selected{sel, v}, xs, n, D.go(T.Union{options}, 1n, 0n, D.Region{n, xs})),
    SS.option(options, U32.to_nat(sel)),
    s => SC.tagged(sel, SC.parts(v, s)),
    [SC.fragment(SS.fixed_size(T.Union{options}), List.take(&2, U32, P.slice_bytes(xs), n))],
    encoded,
    s => found => tagged_eq =>
      tagged_elim(CLeaf.parsed_as(T.Selected{sel, v}, xs, n, D.go(T.Union{options}, 1n, 0n, D.Region{n, xs})),
        sel, SC.parts(v, s), List.take(&2, U32, P.slice_bytes(xs), n), tagged_eq,
        issingle => bytes_eq =>
          +size = Equal.trans(Nat, 1n+List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), List.length(&2, U32, List.take(&2, U32, P.slice_bytes(xs), n)), n,
            Equal.cong(+List<U32>, Nat, us => List.length(&2, U32, us), sel <> CLeaf.fragment_bytes(SC.parts(v, s)), List.take(&2, U32, P.slice_bytes(xs), n), bytes_eq),
            PK.take_length(P.slice_bytes(xs), n, CL.sized_by_wf(xs, n, wf, room)))
          +prefix = Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(xs), 1n+List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s)))), List.take(&2, U32, P.slice_bytes(xs), n), sel <> CLeaf.fragment_bytes(SC.parts(v, s)),
            Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), 1n+List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), n, size),
            Equal.sym(+List<U32>, sel <> CLeaf.fragment_bytes(SC.parts(v, s)), List.take(&2, U32, P.slice_bytes(xs), n), bytes_eq))
          +childholds = Equal.trans(Maybe<&2, +List<T.Part>>, SC.parts(v, s), Some{[SC.fragment(SS.fixed_size(s), CLeaf.fragment_bytes(SC.parts(v, s)))]}, Some{[SC.fragment(SS.fixed_size(s), List.take(&2, U32, P.slice_bytes(P.adv(xs, 1n)), List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s)))))]},
            single_holds(s, SC.parts(v, s), shape(s, found), issingle),
            Equal.cong(+List<U32>, Maybe<&2, +List<T.Part>>, us => Some{[SC.fragment(SS.fixed_size(s), us)]}, CLeaf.fragment_bytes(SC.parts(v, s)), List.take(&2, U32, P.slice_bytes(P.adv(xs, 1n)), List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s)))),
              Equal.trans(+List<U32>, CLeaf.fragment_bytes(SC.parts(v, s)), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), 1n), List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s)))), List.take(&2, U32, P.slice_bytes(P.adv(xs, 1n)), List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s)))),
                tail_prefix(P.slice_bytes(xs), List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), sel, CLeaf.fragment_bytes(SC.parts(v, s)), prefix),
                Equal.cong(+List<U32>, +List<U32>, us => List.take(&2, U32, us, List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s)))), List.drop(&2, U32, P.slice_bytes(xs), 1n), P.slice_bytes(P.adv(xs, 1n)),
                  Equal.sym(+List<U32>, P.slice_bytes(P.adv(xs, 1n)), List.drop(&2, U32, P.slice_bytes(xs), 1n), PK.adv_view(xs, 1n))))))
          +bsel = Equal.trans(U32, P.byte_at(xs, 0n), IP.at(P.slice_bytes(xs), 0n), sel,
            PK.byte_at_view(xs, 0n),
            CWalk.first_byte_of(P.slice_bytes(xs), List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), sel, CLeaf.fragment_bytes(SC.parts(v, s)), prefix))
          +roomchild = Equal.trans(Bool, Nat.is_le(List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), P.slice_size(P.adv(xs, 1n))), Nat.is_le(List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), Nat.sub(P.slice_size(xs), 1n)), True{},
            Equal.cong(Nat, Bool, k => Nat.is_le(List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), k), P.slice_size(P.adv(xs, 1n)), Nat.sub(P.slice_size(xs), 1n), adv_size(xs, 1n)),
            le_pred(List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), P.slice_size(xs),
              Equal.trans(Bool, Nat.is_le(1n+List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), P.slice_size(xs)), Nat.is_le(n, P.slice_size(xs)), True{},
                Equal.cong(Nat, Bool, k => Nat.is_le(k, P.slice_size(xs)), 1n+List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), n, size),
                room)))
          %size : CLeaf.parsed_as(T.Selected{sel, v}, xs, _, D.go(T.Union{options}, 1n, 0n, D.Region{_, xs}))
          %Equal.sym(U32, P.byte_at(xs, 0n), sel, bsel) : CLeaf.parsed_as(T.Selected{sel, v}, xs, 1n+List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), D.go(options, 0n, U32.to_nat(_), D.Pick{_, List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), P.adv(xs, 1n)}))
          CWalk.shift_region(D.go(options, 0n, U32.to_nat(sel), D.Pick{sel, List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), P.adv(xs, 1n)}), xs, List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), T.Selected{sel, v},
            picked(s, List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), PK.wf_adv(xs, 1n, wf), roomchild, found, childholds))))

law compatible_union_region:
  for +selectors: +List<U32>
  for +options: T.Schema
  for +sel: U32
  for +v: T.Value
  for +n: Nat
  for +xs: P.Slice
  for +wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat}
  for +room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool}
  for shape: @+s: T.Schema -> {SS.compatible_option(selectors, options, sel) == Some{s} : Maybe<&2, T.Schema>} -> FA.single_result(SS.fixed_size(s), SC.parts(v, s))
  for picked: @+s: T.Schema -> @+m: Nat ->
    {List.length(&2, U32, P.slice_bytes(P.adv(xs, 1n))) == P.slice_size(P.adv(xs, 1n)) : Nat} ->
    {Nat.is_le(m, P.slice_size(P.adv(xs, 1n))) == True{} : Bool} ->
    {SS.compatible_option(selectors, options, sel) == Some{s} : Maybe<&2, T.Schema>} ->
    CLeaf.holds(s, v, P.adv(xs, 1n), m) ->
    CLeaf.parsed_as(T.Selected{sel, v}, P.adv(xs, 1n), m, D.go(options, 0n, 0n, D.PickAmong{selectors, sel, m, P.adv(xs, 1n)}))
  for encoded: CLeaf.holds(T.CompatibleUnion{selectors, options}, T.Selected{sel, v}, xs, n)
  CLeaf.parsed_as(T.Selected{sel, v}, xs, n, D.go(T.CompatibleUnion{selectors, options}, 1n, 0n, D.Region{n, xs}))
def compatible_union_region(selectors, options, sel, v, n, xs, wf, room, shape, picked, encoded):
  with_option_elim(CLeaf.parsed_as(T.Selected{sel, v}, xs, n, D.go(T.CompatibleUnion{selectors, options}, 1n, 0n, D.Region{n, xs})),
    SS.compatible_option(selectors, options, sel),
    s => SC.tagged(sel, SC.parts(v, s)),
    [SC.fragment(SS.fixed_size(T.CompatibleUnion{selectors, options}), List.take(&2, U32, P.slice_bytes(xs), n))],
    encoded,
    s => found => tagged_eq =>
      tagged_elim(CLeaf.parsed_as(T.Selected{sel, v}, xs, n, D.go(T.CompatibleUnion{selectors, options}, 1n, 0n, D.Region{n, xs})),
        sel, SC.parts(v, s), List.take(&2, U32, P.slice_bytes(xs), n), tagged_eq,
        issingle => bytes_eq =>
          +size = Equal.trans(Nat, 1n+List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), List.length(&2, U32, List.take(&2, U32, P.slice_bytes(xs), n)), n,
            Equal.cong(+List<U32>, Nat, us => List.length(&2, U32, us), sel <> CLeaf.fragment_bytes(SC.parts(v, s)), List.take(&2, U32, P.slice_bytes(xs), n), bytes_eq),
            PK.take_length(P.slice_bytes(xs), n, CL.sized_by_wf(xs, n, wf, room)))
          +prefix = Equal.trans(+List<U32>, List.take(&2, U32, P.slice_bytes(xs), 1n+List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s)))), List.take(&2, U32, P.slice_bytes(xs), n), sel <> CLeaf.fragment_bytes(SC.parts(v, s)),
            Equal.cong(Nat, +List<U32>, k => List.take(&2, U32, P.slice_bytes(xs), k), 1n+List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), n, size),
            Equal.sym(+List<U32>, sel <> CLeaf.fragment_bytes(SC.parts(v, s)), List.take(&2, U32, P.slice_bytes(xs), n), bytes_eq))
          +childholds = Equal.trans(Maybe<&2, +List<T.Part>>, SC.parts(v, s), Some{[SC.fragment(SS.fixed_size(s), CLeaf.fragment_bytes(SC.parts(v, s)))]}, Some{[SC.fragment(SS.fixed_size(s), List.take(&2, U32, P.slice_bytes(P.adv(xs, 1n)), List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s)))))]},
            single_holds(s, SC.parts(v, s), shape(s, found), issingle),
            Equal.cong(+List<U32>, Maybe<&2, +List<T.Part>>, us => Some{[SC.fragment(SS.fixed_size(s), us)]}, CLeaf.fragment_bytes(SC.parts(v, s)), List.take(&2, U32, P.slice_bytes(P.adv(xs, 1n)), List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s)))),
              Equal.trans(+List<U32>, CLeaf.fragment_bytes(SC.parts(v, s)), List.take(&2, U32, List.drop(&2, U32, P.slice_bytes(xs), 1n), List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s)))), List.take(&2, U32, P.slice_bytes(P.adv(xs, 1n)), List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s)))),
                tail_prefix(P.slice_bytes(xs), List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), sel, CLeaf.fragment_bytes(SC.parts(v, s)), prefix),
                Equal.cong(+List<U32>, +List<U32>, us => List.take(&2, U32, us, List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s)))), List.drop(&2, U32, P.slice_bytes(xs), 1n), P.slice_bytes(P.adv(xs, 1n)),
                  Equal.sym(+List<U32>, P.slice_bytes(P.adv(xs, 1n)), List.drop(&2, U32, P.slice_bytes(xs), 1n), PK.adv_view(xs, 1n))))))
          +bsel = Equal.trans(U32, P.byte_at(xs, 0n), IP.at(P.slice_bytes(xs), 0n), sel,
            PK.byte_at_view(xs, 0n),
            CWalk.first_byte_of(P.slice_bytes(xs), List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), sel, CLeaf.fragment_bytes(SC.parts(v, s)), prefix))
          +roomchild = Equal.trans(Bool, Nat.is_le(List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), P.slice_size(P.adv(xs, 1n))), Nat.is_le(List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), Nat.sub(P.slice_size(xs), 1n)), True{},
            Equal.cong(Nat, Bool, k => Nat.is_le(List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), k), P.slice_size(P.adv(xs, 1n)), Nat.sub(P.slice_size(xs), 1n), adv_size(xs, 1n)),
            le_pred(List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), P.slice_size(xs),
              Equal.trans(Bool, Nat.is_le(1n+List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), P.slice_size(xs)), Nat.is_le(n, P.slice_size(xs)), True{},
                Equal.cong(Nat, Bool, k => Nat.is_le(k, P.slice_size(xs)), 1n+List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), n, size),
                room)))
          %size : CLeaf.parsed_as(T.Selected{sel, v}, xs, _, D.go(T.CompatibleUnion{selectors, options}, 1n, 0n, D.Region{_, xs}))
          %Equal.sym(U32, P.byte_at(xs, 0n), sel, bsel) : CLeaf.parsed_as(T.Selected{sel, v}, xs, 1n+List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), D.go(options, 0n, 0n, D.PickAmong{selectors, _, List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), P.adv(xs, 1n)}))
          CWalk.shift_region(D.go(options, 0n, 0n, D.PickAmong{selectors, sel, List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), P.adv(xs, 1n)}), xs, List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), T.Selected{sel, v},
            picked(s, List.length(&2, U32, CLeaf.fragment_bytes(SC.parts(v, s))), PK.wf_adv(xs, 1n, wf), roomchild, found, childholds))))

# Reading the kind of a one-fragment parts result.
law single_shape_elim:
  for -G: Type
  for +w: Maybe<&2, Nat>
  for +r: Maybe<&2, +List<T.Part>>
  for +us: +List<T.Part>
  for +same: {r == Some{us} : Maybe<&2, +List<T.Part>>}
  for known: FA.single_result(w, r)
  for k1: @+ys: +List<U32> -> @+shape: {us == [T.Fixed{ys}] : +List<T.Part>} -> @+width: {w == Some{List.length(&2, U32, ys)} : Maybe<&2, Nat>} -> G
  for k2: @+ys: +List<U32> -> @+shape: {us == [T.Variable{ys}] : +List<T.Part>} -> @+width: {w == None{} : Maybe<&2, Nat>} -> G
  G
def single_shape_elim(G, w, r, us, same, known, k1, k2):
  match r:
    case None{}:
      Empty.absurd(G, F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, is_some_parts, None{}, Some{us}, same)))
    case Some{qs}:
      match qs:
        case Nil{}: Empty.absurd(G, known)
        case Con{T.Fixed{ys}, Nil{}}:
          k1(ys, Equal.sym(+List<T.Part>, [T.Fixed{ys}], us,
            Equal.cong(Maybe<&2, +List<T.Part>>, +List<T.Part>, parts_of, Some{[T.Fixed{ys}]}, Some{us}, same)), known)
        case Con{T.Variable{ys}, Nil{}}:
          k2(ys, Equal.sym(+List<T.Part>, [T.Variable{ys}], us,
            Equal.cong(Maybe<&2, +List<T.Part>>, +List<T.Part>, parts_of, Some{[T.Variable{ys}]}, Some{us}, same)), known)
        case Con{T.Fixed{ys}, Con{a, b}}: Empty.absurd(G, known)
        case Con{T.Variable{ys}, Con{a, b}}: Empty.absurd(G, known)

# The same fragment-kind reading, as a value that a law can match on. The CPS
# form above cannot be used where the two branches share a linear premise.
type FragShape is Data:
  FixedShape{bytes: +List<U32>}
  VarShape{bytes: +List<U32>}

def shape_of(us: +List<T.Part>) -> FragShape:
  match us:
    case Con{T.Fixed{ys}, Nil{}}: FixedShape{ys}
    case Con{T.Variable{ys}, Nil{}}: VarShape{ys}
    case _: FixedShape{[]}

def shape_ok(w: Maybe<&2, Nat>, us: +List<T.Part>, f: FragShape) -> Type:
  match f:
    case FixedShape{ys}:
      {us == [T.Fixed{ys}] : +List<T.Part>} & {w == Some{List.length(&2, U32, ys)} : Maybe<&2, Nat>}
    case VarShape{ys}:
      {us == [T.Variable{ys}] : +List<T.Part>} & {w == None{} : Maybe<&2, Nat>}

law single_shape:
  for +w: Maybe<&2, Nat>
  for +r: Maybe<&2, +List<T.Part>>
  for +us: +List<T.Part>
  for +same: {r == Some{us} : Maybe<&2, +List<T.Part>>}
  for known: FA.single_result(w, r)
  shape_ok(w, us, shape_of(us))
def single_shape(w, r, us, same, known):
  single_shape_elim(shape_ok(w, us, shape_of(us)), w, r, us, same, known,
    ys => shape => width =>
      %Equal.sym(+List<T.Part>, us, [T.Fixed{ys}], shape) : shape_ok(w, _, shape_of(_))
      ({==}, width),
    ys => shape => width =>
      %Equal.sym(+List<T.Part>, us, [T.Variable{ys}], shape) : shape_ok(w, _, shape_of(_))
      ({==}, width))

# Legality in region position. `Null` is legal only as a union option, so it
# is not `valid_go(_, False{})`; it is still a decodable region.
def is_null(schema: T.Schema) -> Bool:
  match schema:
    case T.Null{}: True{}
    case _: False{}

def region_legal(+schema: T.Schema) -> Bool:
  Bool.or(is_null(schema), IS.valid_go(schema, False{}))
