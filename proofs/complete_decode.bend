import Base
import ../types/schema.bend as T
import ../types/primitive.bend as Primitive
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
import ./complete_step.bend as CStep
import ./decode_facts.bend as FA
import ./decode_shape.bend as Shape
import ./primitive_invariants.bend as V
import ./bit_vector_inverse.bend as BVI
import ./schema_width.bend as SW
import ../src/lists.bend as Lists

# What completeness means at each cursor the decoder can be in, and the
# recursion that proves it. The shape of this file mirrors
# `cursor_sound.go_sound`: one law over (schema, phase, count, cursor) whose
# case split is the decoder's own.
def region_obligation(+schema: T.Schema, +value: T.Value, +n: Nat, +xs: P.Slice) -> Type:
  CLeaf.parsed_as(value, xs, n, D.go(schema, 1n, 0n, D.Region{n, xs}))

def pick_obligation(+schema: T.Schema, +k: Nat, +sel: U32, +n: Nat, +xs: P.Slice, +value: T.Value) -> Type:
  CLeaf.parsed_as(T.Selected{sel, value}, xs, n, D.go(schema, 0n, k, D.Pick{sel, n, xs}))

def among_obligation(+selectors: +List<U32>, +schema: T.Schema, +sel: U32, +n: Nat, +xs: P.Slice, +value: T.Value) -> Type:
  CLeaf.parsed_as(T.Selected{sel, value}, xs, n, D.go(schema, 0n, 0n, D.PickAmong{selectors, sel, n, xs}))

# A schema is walkable as a field forest, or as a sequence of elements.
def walk_legal(+schema: T.Schema) -> Bool:
  match schema:
    case T.Chain{hh, tt}: IS.valid_go(T.Chain{hh, tt}, True{})
    case T.End{}: True{}
    case T.Vector{e, m}: IS.valid_go(e, False{})
    case T.ListOf{e, m}: IS.valid_go(e, False{})
    case T.ProgressiveList{e}: IS.valid_go(e, False{})
    case _: False{}

def walk_k_ok(+schema: T.Schema, +k: Nat) -> Bool:
  match schema:
    case T.Vector{e, m}: True{}
    case T.ListOf{e, m}: True{}
    case T.ProgressiveList{e}: True{}
    case _: Nat.is_eq(k, 0n)

# Every option of a union is legal in region position.
def opts_legal(+schema: T.Schema) -> Bool:
  match schema:
    case T.Chain{h, t}: Bool.and(CReg.region_legal(h), opts_legal(t))
    case T.End{}: True{}
    case _: False{}

def walk_obligation(+schema: T.Schema, +k: Nat, +sl: P.Slice, +end: Nat, +fixedtotal: Nat, +h: Nat, +pos: Nat, +pdone: +List<T.Part>, +ps: +List<T.Part>, +hdr: P.Slice, +pay: P.Slice, +acc: C.CValue, +rest: T.Value, +out: D.Out) -> Type:
  match schema:
    case T.Vector{e, m}: CWalk.walk_goal_seq(e, k, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc, rest, out)
    case T.ListOf{e, m}: CWalk.walk_goal_seq(e, k, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc, rest, out)
    case T.ProgressiveList{e}: CWalk.walk_goal_seq(e, k, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc, rest, out)
    case _: CWalk.walk_goal(sl, end, fixedtotal, h, pos, pdone, ps, schema, hdr, pay, acc, rest, out)

def complete_goal(+schema: T.Schema, +phase: Nat, +k: Nat, +c: D.Cursor, +value: T.Value, +opt: T.Schema, +sl: P.Slice, +fixedtotal: Nat, +h: Nat, +pdone: +List<T.Part>, +ps: +List<T.Part>, +hdr: P.Slice, +pay: P.Slice, +acc2: C.CValue) -> Type:
  match c:
    case D.Region{n, xs}:
      @+wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat} ->
      @+room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool} ->
      @+legal: {CReg.region_legal(schema) == True{} : Bool} ->
      @+phaseok: {Nat.is_eq(phase, 1n) == True{} : Bool} ->
      CLeaf.holds(schema, value, xs, n) ->
      region_obligation(schema, value, n, xs)
    case D.Walk{fixed, prior, other, pos, end, acc}:
      @+settled: {D.settle(prior, fixed, other, acc) == D.Settled{hdr, pay, acc2} : D.Settled} ->
      @+legal: {walk_legal(schema) == True{} : Bool} ->
      @+kok: {walk_k_ok(schema, k) == True{} : Bool} ->
      walk_obligation(schema, k, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, D.go(schema, 0n, k, D.Walk{fixed, prior, other, pos, end, acc}))
    case D.Pick{sel, n, xs}:
      @+wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat} ->
      @+room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool} ->
      @+legal: {opts_legal(schema) == True{} : Bool} ->
      @+found: {SS.option(schema, k) == Some{opt} : Maybe<&2, T.Schema>} ->
      CLeaf.holds(opt, value, xs, n) ->
      pick_obligation(schema, k, sel, n, xs, value)
    case D.PickAmong{selectors, sel, n, xs}:
      @+wf: {List.length(&2, U32, P.slice_bytes(xs)) == P.slice_size(xs) : Nat} ->
      @+room: {Nat.is_le(n, P.slice_size(xs)) == True{} : Bool} ->
      @+legal: {opts_legal(schema) == True{} : Bool} ->
      @+found: {SS.compatible_option(selectors, schema, sel) == Some{opt} : Maybe<&2, T.Schema>} ->
      CLeaf.holds(opt, value, xs, n) ->
      among_obligation(selectors, schema, sel, n, xs, value)
    case D.Invalid{}: Unit

law or_right:
  for +a: Bool
  for +b: Bool
  for +pb: {b == True{} : Bool}
  {Bool.or(a, b) == True{} : Bool}
def or_right(a, b, pb):
  match a:
    case True{}: {==}
    case False{}: pb

# A union is never a legal field forest; reducing that needs the head of its
# option list, because the validator special-cases a `Null` first option.
law union_not_forest:
  for +z0: T.Schema
  {IS.valid_go(T.Union{z0}, True{}) == False{} : Bool}
def union_not_forest(z0):
  match z0:
    case T.Boolean{}: {==}
    case T.Unsigned{y0}: {==}
    case T.ByteVector{y0}: {==}
    case T.ByteList{y0}: {==}
    case T.BitVector{y0}: {==}
    case T.BitList{y0}: {==}
    case T.Vector{y0, y1}: {==}
    case T.ListOf{y0, y1}: {==}
    case T.Container{y0, y1}: {==}
    case T.Union{y0}: {==}
    case T.Null{}: {==}
    case T.Chain{y0, y1}:
      match y0:
        case T.Boolean{}: {==}
        case T.Unsigned{w0}: {==}
        case T.ByteVector{w0}: {==}
        case T.ByteList{w0}: {==}
        case T.BitVector{w0}: {==}
        case T.BitList{w0}: {==}
        case T.Vector{w0, w1}: {==}
        case T.ListOf{w0, w1}: {==}
        case T.Container{w0, w1}: {==}
        case T.Union{w0}: {==}
        case T.Null{}: {==}
        case T.Chain{w0, w1}: {==}
        case T.End{}: {==}
        case T.Repeat{w0}: {==}
        case T.Named{w0, w1}: {==}
        case T.ProgressiveList{w0}: {==}
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{w0, w1, w2}: {==}
        case T.CompatibleUnion{w0, w1}: {==}
    case T.End{}: {==}
    case T.Repeat{y0}: {==}
    case T.Named{y0, y1}: {==}
    case T.ProgressiveList{y0}: {==}
    case T.ProgressiveBits{}: {==}
    case T.ProgressiveContainer{y0, y1, y2}: {==}
    case T.CompatibleUnion{y0, y1}: {==}

# A walk obligation at a field forest is the field-forest walk goal.
law walk_as_chain:
  for +tt: T.Schema
  for +k: Nat
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
  for +out: D.Out
  for +legal: {IS.valid_go(tt, True{}) == True{} : Bool}
  for obl: walk_obligation(tt, k, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc, rest, out)
  CWalk.walk_goal(sl, end, fixedtotal, h, pos, pdone, ps, tt, hdr, pay, acc, rest, out)
def walk_as_chain(tt, k, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc, rest, out, legal, obl):
  match tt:
    case T.Boolean{}: obl
    case T.Unsigned{z0}: obl
    case T.ByteVector{z0}: obl
    case T.ByteList{z0}: obl
    case T.BitVector{z0}: obl
    case T.BitList{z0}: obl
    case T.Vector{z0, z1}: Empty.absurd(CWalk.walk_goal(sl, end, fixedtotal, h, pos, pdone, ps, T.Vector{z0, z1}, hdr, pay, acc, rest, out), F.false_true(legal))
    case T.ListOf{z0, z1}: Empty.absurd(CWalk.walk_goal(sl, end, fixedtotal, h, pos, pdone, ps, T.ListOf{z0, z1}, hdr, pay, acc, rest, out), F.false_true(legal))
    case T.Container{z0, z1}: obl
    case T.Union{z0}: obl
    case T.Null{}: obl
    case T.Chain{z0, z1}: obl
    case T.End{}: obl
    case T.Repeat{z0}: obl
    case T.Named{z0, z1}: obl
    case T.ProgressiveList{z0}: Empty.absurd(CWalk.walk_goal(sl, end, fixedtotal, h, pos, pdone, ps, T.ProgressiveList{z0}, hdr, pay, acc, rest, out), F.false_true(legal))
    case T.ProgressiveBits{}: obl
    case T.ProgressiveContainer{z0, z1, z2}: obl
    case T.CompatibleUnion{z0, z1}: obl

# The single-fragment shape of a `Null` option, which is not `valid_go`.
law null_fact:
  for +v: T.Value
  FA.single_result(SS.fixed_size(T.Null{}), SC.parts(v, T.Null{}))
def null_fact(v):
  match v:
    case T.BooleanValue{b0}: Unit{}
    case T.UnsignedValue{u0}: Unit{}
    case T.BytesValue{y0}: Unit{}
    case T.BitsValue{q0}: Unit{}
    case T.Sequence{i0}: Unit{}
    case T.Items{i0, i1}: Unit{}
    case T.EmptyItems{}: Unit{}
    case T.Selected{s0, w0}: Unit{}
    case T.NullValue{}: {==}

law region_single:
  for +schema: T.Schema
  for +v: T.Value
  for +legal: {CReg.region_legal(schema) == True{} : Bool}
  FA.single_result(SS.fixed_size(schema), SC.parts(v, schema))
def region_single(schema, v, legal):
  match schema:
    case T.Boolean{}: Shape.head_single(T.Boolean{}, v, SC.parts(v, T.Boolean{}), legal, Shape.facts(v, T.Boolean{}, Shape.ok_single(T.Boolean{}, legal)))
    case T.Unsigned{z0}: Shape.head_single(T.Unsigned{z0}, v, SC.parts(v, T.Unsigned{z0}), legal, Shape.facts(v, T.Unsigned{z0}, Shape.ok_single(T.Unsigned{z0}, legal)))
    case T.ByteVector{z0}: Shape.head_single(T.ByteVector{z0}, v, SC.parts(v, T.ByteVector{z0}), legal, Shape.facts(v, T.ByteVector{z0}, Shape.ok_single(T.ByteVector{z0}, legal)))
    case T.ByteList{z0}: Shape.head_single(T.ByteList{z0}, v, SC.parts(v, T.ByteList{z0}), legal, Shape.facts(v, T.ByteList{z0}, Shape.ok_single(T.ByteList{z0}, legal)))
    case T.BitVector{z0}: Shape.head_single(T.BitVector{z0}, v, SC.parts(v, T.BitVector{z0}), legal, Shape.facts(v, T.BitVector{z0}, Shape.ok_single(T.BitVector{z0}, legal)))
    case T.BitList{z0}: Shape.head_single(T.BitList{z0}, v, SC.parts(v, T.BitList{z0}), legal, Shape.facts(v, T.BitList{z0}, Shape.ok_single(T.BitList{z0}, legal)))
    case T.Vector{z0, z1}: Shape.head_single(T.Vector{z0, z1}, v, SC.parts(v, T.Vector{z0, z1}), legal, Shape.facts(v, T.Vector{z0, z1}, Shape.ok_single(T.Vector{z0, z1}, legal)))
    case T.ListOf{z0, z1}: Shape.head_single(T.ListOf{z0, z1}, v, SC.parts(v, T.ListOf{z0, z1}), legal, Shape.facts(v, T.ListOf{z0, z1}, Shape.ok_single(T.ListOf{z0, z1}, legal)))
    case T.Container{z0, z1}: Shape.head_single(T.Container{z0, z1}, v, SC.parts(v, T.Container{z0, z1}), legal, Shape.facts(v, T.Container{z0, z1}, Shape.ok_single(T.Container{z0, z1}, legal)))
    case T.Union{z0}: Shape.head_single(T.Union{z0}, v, SC.parts(v, T.Union{z0}), legal, Shape.facts(v, T.Union{z0}, Shape.ok_single(T.Union{z0}, legal)))
    case T.Null{}: null_fact(v)
    case T.Chain{z0, z1}: Shape.head_single(T.Chain{z0, z1}, v, SC.parts(v, T.Chain{z0, z1}), legal, Shape.facts(v, T.Chain{z0, z1}, Shape.ok_single(T.Chain{z0, z1}, legal)))
    case T.End{}: Shape.head_single(T.End{}, v, SC.parts(v, T.End{}), legal, Shape.facts(v, T.End{}, Shape.ok_single(T.End{}, legal)))
    case T.Repeat{z0}: Shape.head_single(T.Repeat{z0}, v, SC.parts(v, T.Repeat{z0}), legal, Shape.facts(v, T.Repeat{z0}, Shape.ok_single(T.Repeat{z0}, legal)))
    case T.Named{z0, z1}: Shape.head_single(T.Named{z0, z1}, v, SC.parts(v, T.Named{z0, z1}), legal, Shape.facts(v, T.Named{z0, z1}, Shape.ok_single(T.Named{z0, z1}, legal)))
    case T.ProgressiveList{z0}: Shape.head_single(T.ProgressiveList{z0}, v, SC.parts(v, T.ProgressiveList{z0}), legal, Shape.facts(v, T.ProgressiveList{z0}, Shape.ok_single(T.ProgressiveList{z0}, legal)))
    case T.ProgressiveBits{}: Shape.head_single(T.ProgressiveBits{}, v, SC.parts(v, T.ProgressiveBits{}), legal, Shape.facts(v, T.ProgressiveBits{}, Shape.ok_single(T.ProgressiveBits{}, legal)))
    case T.ProgressiveContainer{z0, z1, z2}: Shape.head_single(T.ProgressiveContainer{z0, z1, z2}, v, SC.parts(v, T.ProgressiveContainer{z0, z1, z2}), legal, Shape.facts(v, T.ProgressiveContainer{z0, z1, z2}, Shape.ok_single(T.ProgressiveContainer{z0, z1, z2}, legal)))
    case T.CompatibleUnion{z0, z1}: Shape.head_single(T.CompatibleUnion{z0, z1}, v, SC.parts(v, T.CompatibleUnion{z0, z1}), legal, Shape.facts(v, T.CompatibleUnion{z0, z1}, Shape.ok_single(T.CompatibleUnion{z0, z1}, legal)))

# Every option of a legal option list is legal in region position.
law option_single:
  for +opts: T.Schema
  for +i: Nat
  for +s: T.Schema
  for +v: T.Value
  for +legal: {opts_legal(opts) == True{} : Bool}
  for +found: {SS.option(opts, i) == Some{s} : Maybe<&2, T.Schema>}
  FA.single_result(SS.fixed_size(s), SC.parts(v, s))
def option_single(opts, i, s, v, legal, found):
  match opts:
    case T.Chain{hh, tt}:
      match i:
        case 0n:
          %Equal.cong(Maybe<&2, T.Schema>, T.Schema, r => CWalk.schema_of(r, hh), Some{hh}, Some{s}, found) : FA.single_result(SS.fixed_size(_), SC.parts(v, _))
          region_single(hh, v, V.and_left(CReg.region_legal(hh), opts_legal(tt), legal))
        case 1n+p: option_single(tt, p, s, v, V.and_right(CReg.region_legal(hh), opts_legal(tt), legal), found)
    case T.Boolean{}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Boolean{}, i), Some{s}, found)))
    case T.Unsigned{z0}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Unsigned{z0}, i), Some{s}, found)))
    case T.ByteVector{z0}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ByteVector{z0}, i), Some{s}, found)))
    case T.ByteList{z0}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ByteList{z0}, i), Some{s}, found)))
    case T.BitVector{z0}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.BitVector{z0}, i), Some{s}, found)))
    case T.BitList{z0}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.BitList{z0}, i), Some{s}, found)))
    case T.Vector{z0, z1}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Vector{z0, z1}, i), Some{s}, found)))
    case T.ListOf{z0, z1}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ListOf{z0, z1}, i), Some{s}, found)))
    case T.Container{z0, z1}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Container{z0, z1}, i), Some{s}, found)))
    case T.Union{z0}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Union{z0}, i), Some{s}, found)))
    case T.Null{}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Null{}, i), Some{s}, found)))
    case T.End{}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.End{}, i), Some{s}, found)))
    case T.Repeat{z0}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Repeat{z0}, i), Some{s}, found)))
    case T.Named{z0, z1}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Named{z0, z1}, i), Some{s}, found)))
    case T.ProgressiveList{z0}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ProgressiveList{z0}, i), Some{s}, found)))
    case T.ProgressiveBits{}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ProgressiveBits{}, i), Some{s}, found)))
    case T.ProgressiveContainer{z0, z1, z2}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ProgressiveContainer{z0, z1, z2}, i), Some{s}, found)))
    case T.CompatibleUnion{z0, z1}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.CompatibleUnion{z0, z1}, i), Some{s}, found)))

# A legal field forest is a legal option list.
law forest_opts_legal:
  for +t: T.Schema
  for +legal: {IS.valid_go(t, True{}) == True{} : Bool}
  {opts_legal(t) == True{} : Bool}
def forest_opts_legal(t, legal):
  match t:
    case T.Chain{hh, tt}:
      V.and_true(CReg.region_legal(hh), opts_legal(tt),
        or_right(CReg.is_null(hh), IS.valid_go(hh, False{}), V.and_left(IS.valid_go(hh, False{}), IS.valid_go(tt, True{}), legal)),
        forest_opts_legal(tt, V.and_right(IS.valid_go(hh, False{}), IS.valid_go(tt, True{}), legal)))
    case T.End{}: {==}
    case T.Boolean{}: Empty.absurd({opts_legal(T.Boolean{}) == True{} : Bool}, F.false_true(legal))
    case T.Unsigned{z0}: Empty.absurd({opts_legal(T.Unsigned{z0}) == True{} : Bool}, F.false_true(legal))
    case T.ByteVector{z0}: Empty.absurd({opts_legal(T.ByteVector{z0}) == True{} : Bool}, F.false_true(legal))
    case T.ByteList{z0}: Empty.absurd({opts_legal(T.ByteList{z0}) == True{} : Bool}, F.false_true(legal))
    case T.BitVector{z0}: Empty.absurd({opts_legal(T.BitVector{z0}) == True{} : Bool}, F.false_true(legal))
    case T.BitList{z0}: Empty.absurd({opts_legal(T.BitList{z0}) == True{} : Bool}, F.false_true(legal))
    case T.Vector{z0, z1}: Empty.absurd({opts_legal(T.Vector{z0, z1}) == True{} : Bool}, F.false_true(legal))
    case T.ListOf{z0, z1}: Empty.absurd({opts_legal(T.ListOf{z0, z1}) == True{} : Bool}, F.false_true(legal))
    case T.Container{z0, z1}: Empty.absurd({opts_legal(T.Container{z0, z1}) == True{} : Bool}, F.false_true(legal))
    case T.Union{z0}: Empty.absurd({opts_legal(T.Union{z0}) == True{} : Bool}, F.false_true(Equal.trans(Bool, False{}, IS.valid_go(T.Union{z0}, True{}), True{}, Equal.sym(Bool, IS.valid_go(T.Union{z0}, True{}), False{}, union_not_forest(z0)), legal)))
    case T.Null{}: Empty.absurd({opts_legal(T.Null{}) == True{} : Bool}, F.false_true(legal))
    case T.Repeat{z0}: Empty.absurd({opts_legal(T.Repeat{z0}) == True{} : Bool}, F.false_true(legal))
    case T.Named{z0, z1}: Empty.absurd({opts_legal(T.Named{z0, z1}) == True{} : Bool}, F.false_true(legal))
    case T.ProgressiveList{z0}: Empty.absurd({opts_legal(T.ProgressiveList{z0}) == True{} : Bool}, F.false_true(legal))
    case T.ProgressiveBits{}: Empty.absurd({opts_legal(T.ProgressiveBits{}) == True{} : Bool}, F.false_true(legal))
    case T.ProgressiveContainer{z0, z1, z2}: Empty.absurd({opts_legal(T.ProgressiveContainer{z0, z1, z2}) == True{} : Bool}, F.false_true(legal))
    case T.CompatibleUnion{z0, z1}: Empty.absurd({opts_legal(T.CompatibleUnion{z0, z1}) == True{} : Bool}, F.false_true(legal))

law end_walk_complete:
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
  CWalk.walk_goal(sl, end, fixedtotal, h, pos, pdone, ps, T.End{}, hdr, pay, acc2, value, D.go(T.End{}, 0n, k, D.Walk{fixed, prior, other, pos, end, acc}))
def end_walk_complete(k, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, settled):
  %Equal.sym(D.Settled, D.settle(prior, fixed, other, acc), D.Settled{hdr, pay, acc2}, settled) : CWalk.walk_goal(sl, end, fixedtotal, h, pos, pdone, ps, T.End{}, hdr, pay, acc2, value, D.close(_, pos, end))
  CWalk.close_complete(sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value)

law holds_cast:
  for +a: T.Schema
  for +b: T.Schema
  for +value: T.Value
  for +xs: P.Slice
  for +n: Nat
  for +eq: {a == b : T.Schema}
  for e: CLeaf.holds(b, value, xs, n)
  CLeaf.holds(a, value, xs, n)
def holds_cast(a, b, value, xs, n, eq, e):
  %Equal.sym(T.Schema, a, b, eq) : CLeaf.holds(_, value, xs, n)
  e

# One option of a compatible union: either the declared selector matches here,
# or the search continues in the tail.
law among_dispatch:
  for +hit: Bool
  for +s0: U32
  for +sel: U32
  for +hh: T.Schema
  for +tt: T.Schema
  for +rest: +List<U32>
  for +opt: T.Schema
  for +n: Nat
  for +xs: P.Slice
  for +value: T.Value
  for +iseq: {U32.is_eq(s0, sel) == hit : Bool}
  for +found: {SS.selected(hit, hh, SS.compatible_option(rest, tt, sel)) == Some{opt} : Maybe<&2, T.Schema>}
  for encp: CLeaf.holds(opt, value, xs, n)
  for here: @+eq: {hh == opt : T.Schema} -> CLeaf.holds(hh, value, xs, n) -> CLeaf.parsed_as(value, xs, n, D.go(hh, 1n, 0n, D.Region{n, xs}))
  for later: @+eq: {SS.compatible_option(rest, tt, sel) == Some{opt} : Maybe<&2, T.Schema>} -> CLeaf.holds(opt, value, xs, n) -> CLeaf.parsed_as(T.Selected{sel, value}, xs, n, D.go(tt, 0n, 0n, D.PickAmong{rest, sel, n, xs}))
  CLeaf.parsed_as(T.Selected{sel, value}, xs, n, D.go(T.Chain{hh, tt}, 0n, 0n, D.PickAmong{s0 <> rest, sel, n, xs}))
def among_dispatch(hit, s0, sel, hh, tt, rest, opt, n, xs, value, iseq, found, encp, here, later):
  match hit:
    case True{}:
      %Equal.sym(Bool, U32.is_eq(s0, sel), True{}, iseq) : CLeaf.parsed_as(T.Selected{sel, value}, xs, n, D.among(_, sel, D.go(hh, 1n, 0n, D.among_here(_, n, xs)), D.go(tt, 0n, 0n, D.among_later(_, rest, sel, n, xs))))
      CWalk.selected_complete(D.go(hh, 1n, 0n, D.Region{n, xs}), xs, n, sel, value,
        here(Equal.cong(Maybe<&2, T.Schema>, T.Schema, r => CWalk.schema_of(r, hh), Some{hh}, Some{opt}, found),
          holds_cast(hh, opt, value, xs, n, Equal.cong(Maybe<&2, T.Schema>, T.Schema, r => CWalk.schema_of(r, hh), Some{hh}, Some{opt}, found), encp)))
    case False{}:
      %Equal.sym(Bool, U32.is_eq(s0, sel), False{}, iseq) : CLeaf.parsed_as(T.Selected{sel, value}, xs, n, D.among(_, sel, D.go(hh, 1n, 0n, D.among_here(_, n, xs)), D.go(tt, 0n, 0n, D.among_later(_, rest, sel, n, xs))))
      later(found, encp)

law forest_walk_legal:
  for +fields: T.Schema
  for +legal: {IS.valid_go(fields, True{}) == True{} : Bool}
  {walk_legal(fields) == True{} : Bool}
def forest_walk_legal(fields, legal):
  match fields:
    case T.Boolean{}: Empty.absurd({walk_legal(T.Boolean{}) == True{} : Bool}, F.false_true(legal))
    case T.Unsigned{z0}: Empty.absurd({walk_legal(T.Unsigned{z0}) == True{} : Bool}, F.false_true(legal))
    case T.ByteVector{z0}: Empty.absurd({walk_legal(T.ByteVector{z0}) == True{} : Bool}, F.false_true(legal))
    case T.ByteList{z0}: Empty.absurd({walk_legal(T.ByteList{z0}) == True{} : Bool}, F.false_true(legal))
    case T.BitVector{z0}: Empty.absurd({walk_legal(T.BitVector{z0}) == True{} : Bool}, F.false_true(legal))
    case T.BitList{z0}: Empty.absurd({walk_legal(T.BitList{z0}) == True{} : Bool}, F.false_true(legal))
    case T.Vector{z0, z1}: Empty.absurd({walk_legal(T.Vector{z0, z1}) == True{} : Bool}, F.false_true(legal))
    case T.ListOf{z0, z1}: Empty.absurd({walk_legal(T.ListOf{z0, z1}) == True{} : Bool}, F.false_true(legal))
    case T.Container{z0, z1}: Empty.absurd({walk_legal(T.Container{z0, z1}) == True{} : Bool}, F.false_true(legal))
    case T.Union{z0}: Empty.absurd({walk_legal(T.Union{z0}) == True{} : Bool}, F.false_true(Equal.trans(Bool, False{}, IS.valid_go(T.Union{z0}, True{}), True{}, Equal.sym(Bool, IS.valid_go(T.Union{z0}, True{}), False{}, union_not_forest(z0)), legal)))
    case T.Null{}: Empty.absurd({walk_legal(T.Null{}) == True{} : Bool}, F.false_true(legal))
    case T.Chain{z0, z1}: legal
    case T.End{}: {==}
    case T.Repeat{z0}: Empty.absurd({walk_legal(T.Repeat{z0}) == True{} : Bool}, F.false_true(legal))
    case T.Named{z0, z1}: Empty.absurd({walk_legal(T.Named{z0, z1}) == True{} : Bool}, F.false_true(legal))
    case T.ProgressiveList{z0}: Empty.absurd({walk_legal(T.ProgressiveList{z0}) == True{} : Bool}, F.false_true(legal))
    case T.ProgressiveBits{}: Empty.absurd({walk_legal(T.ProgressiveBits{}) == True{} : Bool}, F.false_true(legal))
    case T.ProgressiveContainer{z0, z1, z2}: Empty.absurd({walk_legal(T.ProgressiveContainer{z0, z1, z2}) == True{} : Bool}, F.false_true(legal))
    case T.CompatibleUnion{z0, z1}: Empty.absurd({walk_legal(T.CompatibleUnion{z0, z1}) == True{} : Bool}, F.false_true(legal))

# The options of a legal union are each legal in region position. The head is
# read separately because the validator allows a `Null` first option.
law union_opts_legal:
  for +options: T.Schema
  for +legal: {IS.valid_go(T.Union{options}, False{}) == True{} : Bool}
  {opts_legal(options) == True{} : Bool}
def union_opts_legal(options, legal):
  match options:
    case T.Chain{z0, z1}:
      match z0:
        case T.Boolean{}:
          V.and_true(CReg.region_legal(T.Boolean{}), opts_legal(z1),
            or_right(CReg.is_null(T.Boolean{}), IS.valid_go(T.Boolean{}, False{}), V.and_left(IS.valid_go(T.Boolean{}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Boolean{}, False{}), IS.valid_go(z1, True{})), legal))),
            forest_opts_legal(z1, V.and_right(IS.valid_go(T.Boolean{}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Boolean{}, False{}), IS.valid_go(z1, True{})), legal))))
        case T.Unsigned{w0}:
          V.and_true(CReg.region_legal(T.Unsigned{w0}), opts_legal(z1),
            or_right(CReg.is_null(T.Unsigned{w0}), IS.valid_go(T.Unsigned{w0}, False{}), V.and_left(IS.valid_go(T.Unsigned{w0}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Unsigned{w0}, False{}), IS.valid_go(z1, True{})), legal))),
            forest_opts_legal(z1, V.and_right(IS.valid_go(T.Unsigned{w0}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Unsigned{w0}, False{}), IS.valid_go(z1, True{})), legal))))
        case T.ByteVector{w0}:
          V.and_true(CReg.region_legal(T.ByteVector{w0}), opts_legal(z1),
            or_right(CReg.is_null(T.ByteVector{w0}), IS.valid_go(T.ByteVector{w0}, False{}), V.and_left(IS.valid_go(T.ByteVector{w0}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.ByteVector{w0}, False{}), IS.valid_go(z1, True{})), legal))),
            forest_opts_legal(z1, V.and_right(IS.valid_go(T.ByteVector{w0}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.ByteVector{w0}, False{}), IS.valid_go(z1, True{})), legal))))
        case T.ByteList{w0}:
          V.and_true(CReg.region_legal(T.ByteList{w0}), opts_legal(z1),
            or_right(CReg.is_null(T.ByteList{w0}), IS.valid_go(T.ByteList{w0}, False{}), V.and_left(IS.valid_go(T.ByteList{w0}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.ByteList{w0}, False{}), IS.valid_go(z1, True{})), legal))),
            forest_opts_legal(z1, V.and_right(IS.valid_go(T.ByteList{w0}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.ByteList{w0}, False{}), IS.valid_go(z1, True{})), legal))))
        case T.BitVector{w0}:
          V.and_true(CReg.region_legal(T.BitVector{w0}), opts_legal(z1),
            or_right(CReg.is_null(T.BitVector{w0}), IS.valid_go(T.BitVector{w0}, False{}), V.and_left(IS.valid_go(T.BitVector{w0}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.BitVector{w0}, False{}), IS.valid_go(z1, True{})), legal))),
            forest_opts_legal(z1, V.and_right(IS.valid_go(T.BitVector{w0}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.BitVector{w0}, False{}), IS.valid_go(z1, True{})), legal))))
        case T.BitList{w0}:
          V.and_true(CReg.region_legal(T.BitList{w0}), opts_legal(z1),
            or_right(CReg.is_null(T.BitList{w0}), IS.valid_go(T.BitList{w0}, False{}), V.and_left(IS.valid_go(T.BitList{w0}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.BitList{w0}, False{}), IS.valid_go(z1, True{})), legal))),
            forest_opts_legal(z1, V.and_right(IS.valid_go(T.BitList{w0}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.BitList{w0}, False{}), IS.valid_go(z1, True{})), legal))))
        case T.Vector{w0, w1}:
          V.and_true(CReg.region_legal(T.Vector{w0, w1}), opts_legal(z1),
            or_right(CReg.is_null(T.Vector{w0, w1}), IS.valid_go(T.Vector{w0, w1}, False{}), V.and_left(IS.valid_go(T.Vector{w0, w1}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Vector{w0, w1}, False{}), IS.valid_go(z1, True{})), legal))),
            forest_opts_legal(z1, V.and_right(IS.valid_go(T.Vector{w0, w1}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Vector{w0, w1}, False{}), IS.valid_go(z1, True{})), legal))))
        case T.ListOf{w0, w1}:
          V.and_true(CReg.region_legal(T.ListOf{w0, w1}), opts_legal(z1),
            or_right(CReg.is_null(T.ListOf{w0, w1}), IS.valid_go(T.ListOf{w0, w1}, False{}), V.and_left(IS.valid_go(T.ListOf{w0, w1}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.ListOf{w0, w1}, False{}), IS.valid_go(z1, True{})), legal))),
            forest_opts_legal(z1, V.and_right(IS.valid_go(T.ListOf{w0, w1}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.ListOf{w0, w1}, False{}), IS.valid_go(z1, True{})), legal))))
        case T.Container{w0, w1}:
          V.and_true(CReg.region_legal(T.Container{w0, w1}), opts_legal(z1),
            or_right(CReg.is_null(T.Container{w0, w1}), IS.valid_go(T.Container{w0, w1}, False{}), V.and_left(IS.valid_go(T.Container{w0, w1}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Container{w0, w1}, False{}), IS.valid_go(z1, True{})), legal))),
            forest_opts_legal(z1, V.and_right(IS.valid_go(T.Container{w0, w1}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Container{w0, w1}, False{}), IS.valid_go(z1, True{})), legal))))
        case T.Union{w0}:
          V.and_true(CReg.region_legal(T.Union{w0}), opts_legal(z1),
            or_right(CReg.is_null(T.Union{w0}), IS.valid_go(T.Union{w0}, False{}), V.and_left(IS.valid_go(T.Union{w0}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Union{w0}, False{}), IS.valid_go(z1, True{})), legal))),
            forest_opts_legal(z1, V.and_right(IS.valid_go(T.Union{w0}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Union{w0}, False{}), IS.valid_go(z1, True{})), legal))))
        case T.Null{}:
          V.and_true(CReg.region_legal(T.Null{}), opts_legal(z1), {==},
            forest_opts_legal(z1, V.and_right(Nat.is_le(IS.count(z1), 127n), IS.valid_go(z1, True{}), V.and_right(Nat.is_lt(0n, IS.count(z1)), Bool.and(Nat.is_le(IS.count(z1), 127n), IS.valid_go(z1, True{})), legal))))
        case T.Chain{w0, w1}:
          V.and_true(CReg.region_legal(T.Chain{w0, w1}), opts_legal(z1),
            or_right(CReg.is_null(T.Chain{w0, w1}), IS.valid_go(T.Chain{w0, w1}, False{}), V.and_left(IS.valid_go(T.Chain{w0, w1}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Chain{w0, w1}, False{}), IS.valid_go(z1, True{})), legal))),
            forest_opts_legal(z1, V.and_right(IS.valid_go(T.Chain{w0, w1}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Chain{w0, w1}, False{}), IS.valid_go(z1, True{})), legal))))
        case T.End{}:
          V.and_true(CReg.region_legal(T.End{}), opts_legal(z1),
            or_right(CReg.is_null(T.End{}), IS.valid_go(T.End{}, False{}), V.and_left(IS.valid_go(T.End{}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.End{}, False{}), IS.valid_go(z1, True{})), legal))),
            forest_opts_legal(z1, V.and_right(IS.valid_go(T.End{}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.End{}, False{}), IS.valid_go(z1, True{})), legal))))
        case T.Repeat{w0}:
          V.and_true(CReg.region_legal(T.Repeat{w0}), opts_legal(z1),
            or_right(CReg.is_null(T.Repeat{w0}), IS.valid_go(T.Repeat{w0}, False{}), V.and_left(IS.valid_go(T.Repeat{w0}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Repeat{w0}, False{}), IS.valid_go(z1, True{})), legal))),
            forest_opts_legal(z1, V.and_right(IS.valid_go(T.Repeat{w0}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Repeat{w0}, False{}), IS.valid_go(z1, True{})), legal))))
        case T.Named{w0, w1}:
          V.and_true(CReg.region_legal(T.Named{w0, w1}), opts_legal(z1),
            or_right(CReg.is_null(T.Named{w0, w1}), IS.valid_go(T.Named{w0, w1}, False{}), V.and_left(IS.valid_go(T.Named{w0, w1}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Named{w0, w1}, False{}), IS.valid_go(z1, True{})), legal))),
            forest_opts_legal(z1, V.and_right(IS.valid_go(T.Named{w0, w1}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.Named{w0, w1}, False{}), IS.valid_go(z1, True{})), legal))))
        case T.ProgressiveList{w0}:
          V.and_true(CReg.region_legal(T.ProgressiveList{w0}), opts_legal(z1),
            or_right(CReg.is_null(T.ProgressiveList{w0}), IS.valid_go(T.ProgressiveList{w0}, False{}), V.and_left(IS.valid_go(T.ProgressiveList{w0}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.ProgressiveList{w0}, False{}), IS.valid_go(z1, True{})), legal))),
            forest_opts_legal(z1, V.and_right(IS.valid_go(T.ProgressiveList{w0}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.ProgressiveList{w0}, False{}), IS.valid_go(z1, True{})), legal))))
        case T.ProgressiveBits{}:
          V.and_true(CReg.region_legal(T.ProgressiveBits{}), opts_legal(z1),
            or_right(CReg.is_null(T.ProgressiveBits{}), IS.valid_go(T.ProgressiveBits{}, False{}), V.and_left(IS.valid_go(T.ProgressiveBits{}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.ProgressiveBits{}, False{}), IS.valid_go(z1, True{})), legal))),
            forest_opts_legal(z1, V.and_right(IS.valid_go(T.ProgressiveBits{}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.ProgressiveBits{}, False{}), IS.valid_go(z1, True{})), legal))))
        case T.ProgressiveContainer{w0, w1, w2}:
          V.and_true(CReg.region_legal(T.ProgressiveContainer{w0, w1, w2}), opts_legal(z1),
            or_right(CReg.is_null(T.ProgressiveContainer{w0, w1, w2}), IS.valid_go(T.ProgressiveContainer{w0, w1, w2}, False{}), V.and_left(IS.valid_go(T.ProgressiveContainer{w0, w1, w2}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.ProgressiveContainer{w0, w1, w2}, False{}), IS.valid_go(z1, True{})), legal))),
            forest_opts_legal(z1, V.and_right(IS.valid_go(T.ProgressiveContainer{w0, w1, w2}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.ProgressiveContainer{w0, w1, w2}, False{}), IS.valid_go(z1, True{})), legal))))
        case T.CompatibleUnion{w0, w1}:
          V.and_true(CReg.region_legal(T.CompatibleUnion{w0, w1}), opts_legal(z1),
            or_right(CReg.is_null(T.CompatibleUnion{w0, w1}), IS.valid_go(T.CompatibleUnion{w0, w1}, False{}), V.and_left(IS.valid_go(T.CompatibleUnion{w0, w1}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.CompatibleUnion{w0, w1}, False{}), IS.valid_go(z1, True{})), legal))),
            forest_opts_legal(z1, V.and_right(IS.valid_go(T.CompatibleUnion{w0, w1}, False{}), IS.valid_go(z1, True{}), V.and_right(Nat.is_le(IS.count(z1), 127n), Bool.and(IS.valid_go(T.CompatibleUnion{w0, w1}, False{}), IS.valid_go(z1, True{})), legal))))
    case T.Boolean{}: Empty.absurd({opts_legal(T.Boolean{}) == True{} : Bool}, F.false_true(legal))
    case T.Unsigned{z0}: Empty.absurd({opts_legal(T.Unsigned{z0}) == True{} : Bool}, F.false_true(legal))
    case T.ByteVector{z0}: Empty.absurd({opts_legal(T.ByteVector{z0}) == True{} : Bool}, F.false_true(legal))
    case T.ByteList{z0}: Empty.absurd({opts_legal(T.ByteList{z0}) == True{} : Bool}, F.false_true(legal))
    case T.BitVector{z0}: Empty.absurd({opts_legal(T.BitVector{z0}) == True{} : Bool}, F.false_true(legal))
    case T.BitList{z0}: Empty.absurd({opts_legal(T.BitList{z0}) == True{} : Bool}, F.false_true(legal))
    case T.Vector{z0, z1}: Empty.absurd({opts_legal(T.Vector{z0, z1}) == True{} : Bool}, F.false_true(legal))
    case T.ListOf{z0, z1}: Empty.absurd({opts_legal(T.ListOf{z0, z1}) == True{} : Bool}, F.false_true(legal))
    case T.Container{z0, z1}: Empty.absurd({opts_legal(T.Container{z0, z1}) == True{} : Bool}, F.false_true(legal))
    case T.Union{z0}: Empty.absurd({opts_legal(T.Union{z0}) == True{} : Bool}, F.false_true(legal))
    case T.Null{}: Empty.absurd({opts_legal(T.Null{}) == True{} : Bool}, F.false_true(legal))
    case T.End{}: Empty.absurd({opts_legal(T.End{}) == True{} : Bool}, F.false_true(legal))
    case T.Repeat{z0}: Empty.absurd({opts_legal(T.Repeat{z0}) == True{} : Bool}, F.false_true(legal))
    case T.Named{z0, z1}: Empty.absurd({opts_legal(T.Named{z0, z1}) == True{} : Bool}, F.false_true(legal))
    case T.ProgressiveList{z0}: Empty.absurd({opts_legal(T.ProgressiveList{z0}) == True{} : Bool}, F.false_true(legal))
    case T.ProgressiveBits{}: Empty.absurd({opts_legal(T.ProgressiveBits{}) == True{} : Bool}, F.false_true(legal))
    case T.ProgressiveContainer{z0, z1, z2}: Empty.absurd({opts_legal(T.ProgressiveContainer{z0, z1, z2}) == True{} : Bool}, F.false_true(legal))
    case T.CompatibleUnion{z0, z1}: Empty.absurd({opts_legal(T.CompatibleUnion{z0, z1}) == True{} : Bool}, F.false_true(legal))

law compatible_single_at:
  for +hit: Bool
  for +hh: T.Schema
  for +tt: T.Schema
  for +rest: +List<U32>
  for +sel: U32
  for +s: T.Schema
  for +v: T.Value
  for +hlegal: {CReg.region_legal(hh) == True{} : Bool}
  for +found: {SS.selected(hit, hh, SS.compatible_option(rest, tt, sel)) == Some{s} : Maybe<&2, T.Schema>}
  for rec: @+f2: {SS.compatible_option(rest, tt, sel) == Some{s} : Maybe<&2, T.Schema>} -> FA.single_result(SS.fixed_size(s), SC.parts(v, s))
  FA.single_result(SS.fixed_size(s), SC.parts(v, s))
def compatible_single_at(hit, hh, tt, rest, sel, s, v, hlegal, found, rec):
  match hit:
    case True{}:
      %Equal.cong(Maybe<&2, T.Schema>, T.Schema, r => CWalk.schema_of(r, hh), Some{hh}, Some{s}, found) : FA.single_result(SS.fixed_size(_), SC.parts(v, _))
      region_single(hh, v, hlegal)
    case False{}: rec(found)

law compatible_single:
  for +selectors: +List<U32>
  for +opts: T.Schema
  for +sel: U32
  for +s: T.Schema
  for +v: T.Value
  for +legal: {opts_legal(opts) == True{} : Bool}
  for +found: {SS.compatible_option(selectors, opts, sel) == Some{s} : Maybe<&2, T.Schema>}
  FA.single_result(SS.fixed_size(s), SC.parts(v, s))
def compatible_single(selectors, opts, sel, s, v, legal, found):
  match selectors:
    case Nil{}:
      Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)),
        F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], opts, sel), Some{s}, found)))
    case Con{sh, st}:
      match opts:
        case T.Chain{hh, tt}:
          compatible_single_at(U32.is_eq(sh, sel), hh, tt, st, sel, s, v,
            V.and_left(CReg.region_legal(hh), opts_legal(tt), legal), found,
            f2 => compatible_single(st, tt, sel, s, v, V.and_right(CReg.region_legal(hh), opts_legal(tt), legal), f2))
        case T.Boolean{}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.Boolean{}, sel), Some{s}, found)))
        case T.Unsigned{z0}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.Unsigned{z0}, sel), Some{s}, found)))
        case T.ByteVector{z0}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.ByteVector{z0}, sel), Some{s}, found)))
        case T.ByteList{z0}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.ByteList{z0}, sel), Some{s}, found)))
        case T.BitVector{z0}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.BitVector{z0}, sel), Some{s}, found)))
        case T.BitList{z0}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.BitList{z0}, sel), Some{s}, found)))
        case T.Vector{z0, z1}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.Vector{z0, z1}, sel), Some{s}, found)))
        case T.ListOf{z0, z1}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.ListOf{z0, z1}, sel), Some{s}, found)))
        case T.Container{z0, z1}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.Container{z0, z1}, sel), Some{s}, found)))
        case T.Union{z0}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.Union{z0}, sel), Some{s}, found)))
        case T.Null{}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.Null{}, sel), Some{s}, found)))
        case T.End{}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.End{}, sel), Some{s}, found)))
        case T.Repeat{z0}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.Repeat{z0}, sel), Some{s}, found)))
        case T.Named{z0, z1}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.Named{z0, z1}, sel), Some{s}, found)))
        case T.ProgressiveList{z0}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.ProgressiveList{z0}, sel), Some{s}, found)))
        case T.ProgressiveBits{}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.ProgressiveBits{}, sel), Some{s}, found)))
        case T.ProgressiveContainer{z0, z1, z2}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.ProgressiveContainer{z0, z1, z2}, sel), Some{s}, found)))
        case T.CompatibleUnion{z0, z1}: Empty.absurd(FA.single_result(SS.fixed_size(s), SC.parts(v, s)), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.CompatibleUnion{z0, z1}, sel), Some{s}, found)))

law walk_k_ok_zero:
  for +s: T.Schema
  {walk_k_ok(s, 0n) == True{} : Bool}
def walk_k_ok_zero(s):
  match s:
    case T.Boolean{}: {==}
    case T.Unsigned{z0}: {==}
    case T.ByteVector{z0}: {==}
    case T.ByteList{z0}: {==}
    case T.BitVector{z0}: {==}
    case T.BitList{z0}: {==}
    case T.Vector{z0, z1}: {==}
    case T.ListOf{z0, z1}: {==}
    case T.Container{z0, z1}: {==}
    case T.Union{z0}: {==}
    case T.Null{}: {==}
    case T.Chain{z0, z1}: {==}
    case T.End{}: {==}
    case T.Repeat{z0}: {==}
    case T.Named{z0, z1}: {==}
    case T.ProgressiveList{z0}: {==}
    case T.ProgressiveBits{}: {==}
    case T.ProgressiveContainer{z0, z1, z2}: {==}
    case T.CompatibleUnion{z0, z1}: {==}

# Completeness of the packed cursor decoder, by the decoder's own recursion.
#
# `cursor_sound.go_sound` says that whatever this decoder accepts re-encodes to
# the bytes it read. This law is the converse: a region that already holds the
# independent encoding of a value of a legal type is accepted, and the value it
# yields is exactly that value. The case split, and the order in which the
# arguments shrink, are the decoder's own.
law go_complete:
  for +schema: T.Schema
  for +phase: Nat
  for +k: Nat
  for +c: D.Cursor
  for +value: T.Value
  for +opt: T.Schema
  for +sl: P.Slice
  for +fixedtotal: Nat
  for +h: Nat
  for +pdone: +List<T.Part>
  for +ps: +List<T.Part>
  for +hdr: P.Slice
  for +pay: P.Slice
  for +acc2: C.CValue
  complete_goal(schema, phase, k, c, value, opt, sl, fixedtotal, h, pdone, ps, hdr, pay, acc2)
def go_complete(schema, phase, k, c, value, opt, sl, fixedtotal, h, pdone, ps, hdr, pay, acc2):
  match schema:
    case T.Boolean{}:
      match c:
        case D.Region{n, xs}:
          match value:
            case T.BooleanValue{b0}:
              wf => room => legal => phaseok => enc =>
                CLeaf.boolean_complete(b0, n, xs, wf, room, enc)
            case T.UnsignedValue{u0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Boolean{}, T.UnsignedValue{u0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.UnsignedValue{u0}, T.Boolean{}), Some{[SC.fragment(SS.fixed_size(T.Boolean{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.BytesValue{y0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Boolean{}, T.BytesValue{y0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BytesValue{y0}, T.Boolean{}), Some{[SC.fragment(SS.fixed_size(T.Boolean{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.BitsValue{q0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Boolean{}, T.BitsValue{q0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BitsValue{q0}, T.Boolean{}), Some{[SC.fragment(SS.fixed_size(T.Boolean{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Sequence{i0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Boolean{}, T.Sequence{i0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Sequence{i0}, T.Boolean{}), Some{[SC.fragment(SS.fixed_size(T.Boolean{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Items{i0, i1}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Boolean{}, T.Items{i0, i1}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Items{i0, i1}, T.Boolean{}), Some{[SC.fragment(SS.fixed_size(T.Boolean{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.EmptyItems{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Boolean{}, T.EmptyItems{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.EmptyItems{}, T.Boolean{}), Some{[SC.fragment(SS.fixed_size(T.Boolean{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Selected{v0, m0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Boolean{}, T.Selected{v0, m0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Selected{v0, m0}, T.Boolean{}), Some{[SC.fragment(SS.fixed_size(T.Boolean{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.NullValue{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Boolean{}, T.NullValue{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.NullValue{}, T.Boolean{}), Some{[SC.fragment(SS.fixed_size(T.Boolean{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
        case D.Walk{fixed, prior, other, pos, end, acc}:
          settled => legal => kok =>
            Empty.absurd(walk_obligation(T.Boolean{}, k, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, D.go(T.Boolean{}, 0n, k, D.Walk{fixed, prior, other, pos, end, acc})), F.false_true(legal))
        case D.Pick{sel, n, xs}:
          wf => room => legal => found => enc =>
            Empty.absurd(pick_obligation(T.Boolean{}, k, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Boolean{}, k), Some{opt}, found)))
        case D.PickAmong{selectors, sel, n, xs}:
          match selectors:
            case Nil{}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation([], T.Boolean{}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.Boolean{}, sel), Some{opt}, found)))
            case Con{sh, st}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation(sh <> st, T.Boolean{}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.Boolean{}, sel), Some{opt}, found)))
        case D.Invalid{}: Unit{}
    case T.Unsigned{z0}:
      match c:
        case D.Region{n, xs}:
          match value:
            case T.BooleanValue{b0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Unsigned{z0}, T.BooleanValue{b0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BooleanValue{b0}, T.Unsigned{z0}), Some{[SC.fragment(SS.fixed_size(T.Unsigned{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.UnsignedValue{u0}:
              wf => room => legal => phaseok => enc =>
                CLeaf.uint_complete(z0, u0, n, xs, wf, room, enc)
            case T.BytesValue{y0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Unsigned{z0}, T.BytesValue{y0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BytesValue{y0}, T.Unsigned{z0}), Some{[SC.fragment(SS.fixed_size(T.Unsigned{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.BitsValue{q0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Unsigned{z0}, T.BitsValue{q0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BitsValue{q0}, T.Unsigned{z0}), Some{[SC.fragment(SS.fixed_size(T.Unsigned{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Sequence{i0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Unsigned{z0}, T.Sequence{i0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Sequence{i0}, T.Unsigned{z0}), Some{[SC.fragment(SS.fixed_size(T.Unsigned{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Items{i0, i1}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Unsigned{z0}, T.Items{i0, i1}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Items{i0, i1}, T.Unsigned{z0}), Some{[SC.fragment(SS.fixed_size(T.Unsigned{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.EmptyItems{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Unsigned{z0}, T.EmptyItems{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.EmptyItems{}, T.Unsigned{z0}), Some{[SC.fragment(SS.fixed_size(T.Unsigned{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Selected{v0, m0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Unsigned{z0}, T.Selected{v0, m0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Selected{v0, m0}, T.Unsigned{z0}), Some{[SC.fragment(SS.fixed_size(T.Unsigned{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.NullValue{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Unsigned{z0}, T.NullValue{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.NullValue{}, T.Unsigned{z0}), Some{[SC.fragment(SS.fixed_size(T.Unsigned{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
        case D.Walk{fixed, prior, other, pos, end, acc}:
          settled => legal => kok =>
            Empty.absurd(walk_obligation(T.Unsigned{z0}, k, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, D.go(T.Unsigned{z0}, 0n, k, D.Walk{fixed, prior, other, pos, end, acc})), F.false_true(legal))
        case D.Pick{sel, n, xs}:
          wf => room => legal => found => enc =>
            Empty.absurd(pick_obligation(T.Unsigned{z0}, k, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Unsigned{z0}, k), Some{opt}, found)))
        case D.PickAmong{selectors, sel, n, xs}:
          match selectors:
            case Nil{}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation([], T.Unsigned{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.Unsigned{z0}, sel), Some{opt}, found)))
            case Con{sh, st}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation(sh <> st, T.Unsigned{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.Unsigned{z0}, sel), Some{opt}, found)))
        case D.Invalid{}: Unit{}
    case T.ByteVector{z0}:
      match c:
        case D.Region{n, xs}:
          match value:
            case T.BooleanValue{b0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ByteVector{z0}, T.BooleanValue{b0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BooleanValue{b0}, T.ByteVector{z0}), Some{[SC.fragment(SS.fixed_size(T.ByteVector{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.UnsignedValue{u0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ByteVector{z0}, T.UnsignedValue{u0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.UnsignedValue{u0}, T.ByteVector{z0}), Some{[SC.fragment(SS.fixed_size(T.ByteVector{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.BytesValue{y0}:
              wf => room => legal => phaseok => enc =>
                CLeaf.byte_vector_complete(z0, y0, n, xs, wf, room, enc)
            case T.BitsValue{q0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ByteVector{z0}, T.BitsValue{q0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BitsValue{q0}, T.ByteVector{z0}), Some{[SC.fragment(SS.fixed_size(T.ByteVector{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Sequence{i0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ByteVector{z0}, T.Sequence{i0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Sequence{i0}, T.ByteVector{z0}), Some{[SC.fragment(SS.fixed_size(T.ByteVector{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Items{i0, i1}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ByteVector{z0}, T.Items{i0, i1}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Items{i0, i1}, T.ByteVector{z0}), Some{[SC.fragment(SS.fixed_size(T.ByteVector{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.EmptyItems{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ByteVector{z0}, T.EmptyItems{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.EmptyItems{}, T.ByteVector{z0}), Some{[SC.fragment(SS.fixed_size(T.ByteVector{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Selected{v0, m0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ByteVector{z0}, T.Selected{v0, m0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Selected{v0, m0}, T.ByteVector{z0}), Some{[SC.fragment(SS.fixed_size(T.ByteVector{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.NullValue{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ByteVector{z0}, T.NullValue{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.NullValue{}, T.ByteVector{z0}), Some{[SC.fragment(SS.fixed_size(T.ByteVector{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
        case D.Walk{fixed, prior, other, pos, end, acc}:
          settled => legal => kok =>
            Empty.absurd(walk_obligation(T.ByteVector{z0}, k, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, D.go(T.ByteVector{z0}, 0n, k, D.Walk{fixed, prior, other, pos, end, acc})), F.false_true(legal))
        case D.Pick{sel, n, xs}:
          wf => room => legal => found => enc =>
            Empty.absurd(pick_obligation(T.ByteVector{z0}, k, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ByteVector{z0}, k), Some{opt}, found)))
        case D.PickAmong{selectors, sel, n, xs}:
          match selectors:
            case Nil{}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation([], T.ByteVector{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.ByteVector{z0}, sel), Some{opt}, found)))
            case Con{sh, st}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation(sh <> st, T.ByteVector{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.ByteVector{z0}, sel), Some{opt}, found)))
        case D.Invalid{}: Unit{}
    case T.ByteList{z0}:
      match c:
        case D.Region{n, xs}:
          match value:
            case T.BooleanValue{b0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ByteList{z0}, T.BooleanValue{b0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BooleanValue{b0}, T.ByteList{z0}), Some{[SC.fragment(SS.fixed_size(T.ByteList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.UnsignedValue{u0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ByteList{z0}, T.UnsignedValue{u0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.UnsignedValue{u0}, T.ByteList{z0}), Some{[SC.fragment(SS.fixed_size(T.ByteList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.BytesValue{y0}:
              wf => room => legal => phaseok => enc =>
                CLeaf.byte_list_complete(z0, y0, n, xs, wf, room, enc)
            case T.BitsValue{q0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ByteList{z0}, T.BitsValue{q0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BitsValue{q0}, T.ByteList{z0}), Some{[SC.fragment(SS.fixed_size(T.ByteList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Sequence{i0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ByteList{z0}, T.Sequence{i0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Sequence{i0}, T.ByteList{z0}), Some{[SC.fragment(SS.fixed_size(T.ByteList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Items{i0, i1}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ByteList{z0}, T.Items{i0, i1}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Items{i0, i1}, T.ByteList{z0}), Some{[SC.fragment(SS.fixed_size(T.ByteList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.EmptyItems{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ByteList{z0}, T.EmptyItems{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.EmptyItems{}, T.ByteList{z0}), Some{[SC.fragment(SS.fixed_size(T.ByteList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Selected{v0, m0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ByteList{z0}, T.Selected{v0, m0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Selected{v0, m0}, T.ByteList{z0}), Some{[SC.fragment(SS.fixed_size(T.ByteList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.NullValue{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ByteList{z0}, T.NullValue{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.NullValue{}, T.ByteList{z0}), Some{[SC.fragment(SS.fixed_size(T.ByteList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
        case D.Walk{fixed, prior, other, pos, end, acc}:
          settled => legal => kok =>
            Empty.absurd(walk_obligation(T.ByteList{z0}, k, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, D.go(T.ByteList{z0}, 0n, k, D.Walk{fixed, prior, other, pos, end, acc})), F.false_true(legal))
        case D.Pick{sel, n, xs}:
          wf => room => legal => found => enc =>
            Empty.absurd(pick_obligation(T.ByteList{z0}, k, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ByteList{z0}, k), Some{opt}, found)))
        case D.PickAmong{selectors, sel, n, xs}:
          match selectors:
            case Nil{}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation([], T.ByteList{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.ByteList{z0}, sel), Some{opt}, found)))
            case Con{sh, st}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation(sh <> st, T.ByteList{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.ByteList{z0}, sel), Some{opt}, found)))
        case D.Invalid{}: Unit{}
    case T.BitVector{z0}:
      match c:
        case D.Region{n, xs}:
          match value:
            case T.BooleanValue{b0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.BitVector{z0}, T.BooleanValue{b0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BooleanValue{b0}, T.BitVector{z0}), Some{[SC.fragment(SS.fixed_size(T.BitVector{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.UnsignedValue{u0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.BitVector{z0}, T.UnsignedValue{u0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.UnsignedValue{u0}, T.BitVector{z0}), Some{[SC.fragment(SS.fixed_size(T.BitVector{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.BytesValue{y0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.BitVector{z0}, T.BytesValue{y0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BytesValue{y0}, T.BitVector{z0}), Some{[SC.fragment(SS.fixed_size(T.BitVector{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.BitsValue{q0}:
              wf => room => legal => phaseok => enc =>
                CLeaf.bit_vector_complete(z0, q0, n, xs, wf, room, enc)
            case T.Sequence{i0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.BitVector{z0}, T.Sequence{i0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Sequence{i0}, T.BitVector{z0}), Some{[SC.fragment(SS.fixed_size(T.BitVector{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Items{i0, i1}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.BitVector{z0}, T.Items{i0, i1}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Items{i0, i1}, T.BitVector{z0}), Some{[SC.fragment(SS.fixed_size(T.BitVector{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.EmptyItems{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.BitVector{z0}, T.EmptyItems{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.EmptyItems{}, T.BitVector{z0}), Some{[SC.fragment(SS.fixed_size(T.BitVector{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Selected{v0, m0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.BitVector{z0}, T.Selected{v0, m0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Selected{v0, m0}, T.BitVector{z0}), Some{[SC.fragment(SS.fixed_size(T.BitVector{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.NullValue{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.BitVector{z0}, T.NullValue{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.NullValue{}, T.BitVector{z0}), Some{[SC.fragment(SS.fixed_size(T.BitVector{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
        case D.Walk{fixed, prior, other, pos, end, acc}:
          settled => legal => kok =>
            Empty.absurd(walk_obligation(T.BitVector{z0}, k, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, D.go(T.BitVector{z0}, 0n, k, D.Walk{fixed, prior, other, pos, end, acc})), F.false_true(legal))
        case D.Pick{sel, n, xs}:
          wf => room => legal => found => enc =>
            Empty.absurd(pick_obligation(T.BitVector{z0}, k, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.BitVector{z0}, k), Some{opt}, found)))
        case D.PickAmong{selectors, sel, n, xs}:
          match selectors:
            case Nil{}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation([], T.BitVector{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.BitVector{z0}, sel), Some{opt}, found)))
            case Con{sh, st}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation(sh <> st, T.BitVector{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.BitVector{z0}, sel), Some{opt}, found)))
        case D.Invalid{}: Unit{}
    case T.BitList{z0}:
      match c:
        case D.Region{n, xs}:
          match value:
            case T.BooleanValue{b0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.BitList{z0}, T.BooleanValue{b0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BooleanValue{b0}, T.BitList{z0}), Some{[SC.fragment(SS.fixed_size(T.BitList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.UnsignedValue{u0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.BitList{z0}, T.UnsignedValue{u0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.UnsignedValue{u0}, T.BitList{z0}), Some{[SC.fragment(SS.fixed_size(T.BitList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.BytesValue{y0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.BitList{z0}, T.BytesValue{y0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BytesValue{y0}, T.BitList{z0}), Some{[SC.fragment(SS.fixed_size(T.BitList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.BitsValue{q0}:
              wf => room => legal => phaseok => enc =>
                CLeaf.bit_list_complete(z0, q0, n, xs, wf, room, enc)
            case T.Sequence{i0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.BitList{z0}, T.Sequence{i0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Sequence{i0}, T.BitList{z0}), Some{[SC.fragment(SS.fixed_size(T.BitList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Items{i0, i1}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.BitList{z0}, T.Items{i0, i1}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Items{i0, i1}, T.BitList{z0}), Some{[SC.fragment(SS.fixed_size(T.BitList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.EmptyItems{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.BitList{z0}, T.EmptyItems{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.EmptyItems{}, T.BitList{z0}), Some{[SC.fragment(SS.fixed_size(T.BitList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Selected{v0, m0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.BitList{z0}, T.Selected{v0, m0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Selected{v0, m0}, T.BitList{z0}), Some{[SC.fragment(SS.fixed_size(T.BitList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.NullValue{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.BitList{z0}, T.NullValue{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.NullValue{}, T.BitList{z0}), Some{[SC.fragment(SS.fixed_size(T.BitList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
        case D.Walk{fixed, prior, other, pos, end, acc}:
          settled => legal => kok =>
            Empty.absurd(walk_obligation(T.BitList{z0}, k, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, D.go(T.BitList{z0}, 0n, k, D.Walk{fixed, prior, other, pos, end, acc})), F.false_true(legal))
        case D.Pick{sel, n, xs}:
          wf => room => legal => found => enc =>
            Empty.absurd(pick_obligation(T.BitList{z0}, k, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.BitList{z0}, k), Some{opt}, found)))
        case D.PickAmong{selectors, sel, n, xs}:
          match selectors:
            case Nil{}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation([], T.BitList{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.BitList{z0}, sel), Some{opt}, found)))
            case Con{sh, st}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation(sh <> st, T.BitList{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.BitList{z0}, sel), Some{opt}, found)))
        case D.Invalid{}: Unit{}
    case T.ProgressiveBits{}:
      match c:
        case D.Region{n, xs}:
          match value:
            case T.BooleanValue{b0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ProgressiveBits{}, T.BooleanValue{b0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BooleanValue{b0}, T.ProgressiveBits{}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveBits{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.UnsignedValue{u0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ProgressiveBits{}, T.UnsignedValue{u0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.UnsignedValue{u0}, T.ProgressiveBits{}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveBits{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.BytesValue{y0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ProgressiveBits{}, T.BytesValue{y0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BytesValue{y0}, T.ProgressiveBits{}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveBits{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.BitsValue{q0}:
              wf => room => legal => phaseok => enc =>
                CLeaf.progressive_bits_complete(q0, n, xs, wf, room, enc)
            case T.Sequence{i0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ProgressiveBits{}, T.Sequence{i0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Sequence{i0}, T.ProgressiveBits{}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveBits{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Items{i0, i1}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ProgressiveBits{}, T.Items{i0, i1}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Items{i0, i1}, T.ProgressiveBits{}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveBits{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.EmptyItems{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ProgressiveBits{}, T.EmptyItems{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.EmptyItems{}, T.ProgressiveBits{}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveBits{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Selected{v0, m0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ProgressiveBits{}, T.Selected{v0, m0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Selected{v0, m0}, T.ProgressiveBits{}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveBits{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.NullValue{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ProgressiveBits{}, T.NullValue{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.NullValue{}, T.ProgressiveBits{}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveBits{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
        case D.Walk{fixed, prior, other, pos, end, acc}:
          settled => legal => kok =>
            Empty.absurd(walk_obligation(T.ProgressiveBits{}, k, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, D.go(T.ProgressiveBits{}, 0n, k, D.Walk{fixed, prior, other, pos, end, acc})), F.false_true(legal))
        case D.Pick{sel, n, xs}:
          wf => room => legal => found => enc =>
            Empty.absurd(pick_obligation(T.ProgressiveBits{}, k, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ProgressiveBits{}, k), Some{opt}, found)))
        case D.PickAmong{selectors, sel, n, xs}:
          match selectors:
            case Nil{}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation([], T.ProgressiveBits{}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.ProgressiveBits{}, sel), Some{opt}, found)))
            case Con{sh, st}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation(sh <> st, T.ProgressiveBits{}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.ProgressiveBits{}, sel), Some{opt}, found)))
        case D.Invalid{}: Unit{}
    case T.Null{}:
      match c:
        case D.Region{n, xs}:
          match value:
            case T.BooleanValue{b0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Null{}, T.BooleanValue{b0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BooleanValue{b0}, T.Null{}), Some{[SC.fragment(SS.fixed_size(T.Null{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.UnsignedValue{u0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Null{}, T.UnsignedValue{u0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.UnsignedValue{u0}, T.Null{}), Some{[SC.fragment(SS.fixed_size(T.Null{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.BytesValue{y0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Null{}, T.BytesValue{y0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BytesValue{y0}, T.Null{}), Some{[SC.fragment(SS.fixed_size(T.Null{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.BitsValue{q0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Null{}, T.BitsValue{q0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BitsValue{q0}, T.Null{}), Some{[SC.fragment(SS.fixed_size(T.Null{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Sequence{i0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Null{}, T.Sequence{i0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Sequence{i0}, T.Null{}), Some{[SC.fragment(SS.fixed_size(T.Null{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Items{i0, i1}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Null{}, T.Items{i0, i1}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Items{i0, i1}, T.Null{}), Some{[SC.fragment(SS.fixed_size(T.Null{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.EmptyItems{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Null{}, T.EmptyItems{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.EmptyItems{}, T.Null{}), Some{[SC.fragment(SS.fixed_size(T.Null{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Selected{v0, m0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Null{}, T.Selected{v0, m0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Selected{v0, m0}, T.Null{}), Some{[SC.fragment(SS.fixed_size(T.Null{}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.NullValue{}:
              wf => room => legal => phaseok => enc =>
                CLeaf.null_complete(n, xs, wf, room, enc)
        case D.Walk{fixed, prior, other, pos, end, acc}:
          settled => legal => kok =>
            Empty.absurd(walk_obligation(T.Null{}, k, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, D.go(T.Null{}, 0n, k, D.Walk{fixed, prior, other, pos, end, acc})), F.false_true(legal))
        case D.Pick{sel, n, xs}:
          wf => room => legal => found => enc =>
            Empty.absurd(pick_obligation(T.Null{}, k, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Null{}, k), Some{opt}, found)))
        case D.PickAmong{selectors, sel, n, xs}:
          match selectors:
            case Nil{}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation([], T.Null{}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.Null{}, sel), Some{opt}, found)))
            case Con{sh, st}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation(sh <> st, T.Null{}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.Null{}, sel), Some{opt}, found)))
        case D.Invalid{}: Unit{}
    case T.Repeat{z0}:
      match c:
        case D.Region{n, xs}:
          wf => room => legal => phaseok => enc =>
            Empty.absurd(region_obligation(T.Repeat{z0}, value, n, xs), F.false_true(legal))
        case D.Walk{fixed, prior, other, pos, end, acc}:
          settled => legal => kok =>
            Empty.absurd(walk_obligation(T.Repeat{z0}, k, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, D.go(T.Repeat{z0}, 0n, k, D.Walk{fixed, prior, other, pos, end, acc})), F.false_true(legal))
        case D.Pick{sel, n, xs}:
          wf => room => legal => found => enc =>
            Empty.absurd(pick_obligation(T.Repeat{z0}, k, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Repeat{z0}, k), Some{opt}, found)))
        case D.PickAmong{selectors, sel, n, xs}:
          match selectors:
            case Nil{}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation([], T.Repeat{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.Repeat{z0}, sel), Some{opt}, found)))
            case Con{sh, st}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation(sh <> st, T.Repeat{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.Repeat{z0}, sel), Some{opt}, found)))
        case D.Invalid{}: Unit{}
    case T.Named{z0, z1}:
      match c:
        case D.Region{n, xs}:
          wf => room => legal => phaseok => enc =>
            Empty.absurd(region_obligation(T.Named{z0, z1}, value, n, xs), F.false_true(legal))
        case D.Walk{fixed, prior, other, pos, end, acc}:
          settled => legal => kok =>
            Empty.absurd(walk_obligation(T.Named{z0, z1}, k, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, D.go(T.Named{z0, z1}, 0n, k, D.Walk{fixed, prior, other, pos, end, acc})), F.false_true(legal))
        case D.Pick{sel, n, xs}:
          wf => room => legal => found => enc =>
            Empty.absurd(pick_obligation(T.Named{z0, z1}, k, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Named{z0, z1}, k), Some{opt}, found)))
        case D.PickAmong{selectors, sel, n, xs}:
          match selectors:
            case Nil{}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation([], T.Named{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.Named{z0, z1}, sel), Some{opt}, found)))
            case Con{sh, st}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation(sh <> st, T.Named{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.Named{z0, z1}, sel), Some{opt}, found)))
        case D.Invalid{}: Unit{}
    case T.End{}:
      match c:
        case D.Region{n, xs}:
          wf => room => legal => phaseok => enc =>
            Empty.absurd(region_obligation(T.End{}, value, n, xs), F.false_true(legal))
        case D.Walk{fixed, prior, other, pos, end, acc}:
          settled => legal => kok =>
            end_walk_complete(k, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, settled)
        case D.Pick{sel, n, xs}:
          wf => room => legal => found => enc =>
            Empty.absurd(pick_obligation(T.End{}, k, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.End{}, k), Some{opt}, found)))
        case D.PickAmong{selectors, sel, n, xs}:
          match selectors:
            case Nil{}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation([], T.End{}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.End{}, sel), Some{opt}, found)))
            case Con{sh, st}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation(sh <> st, T.End{}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.End{}, sel), Some{opt}, found)))
        case D.Invalid{}: Unit{}
    case T.Container{z0, z1}:
      match c:
        case D.Region{n, xs}:
          match value:
            case T.BooleanValue{b0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Container{z0, z1}, T.BooleanValue{b0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BooleanValue{b0}, T.Container{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Container{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.UnsignedValue{u0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Container{z0, z1}, T.UnsignedValue{u0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.UnsignedValue{u0}, T.Container{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Container{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.BytesValue{y0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Container{z0, z1}, T.BytesValue{y0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BytesValue{y0}, T.Container{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Container{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.BitsValue{q0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Container{z0, z1}, T.BitsValue{q0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BitsValue{q0}, T.Container{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Container{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Sequence{i0}:
              wf => room => legal => phaseok => enc =>
                CReg.aggregate_elim(region_obligation(T.Container{z0, z1}, T.Sequence{i0}, n, xs), SC.parts(i0, z1), SS.fixed_size(z1), List.take(&2, U32, P.slice_bytes(xs), n), enc,
                  qs => partsof => encq =>
                    CReg.container_region(z0, z1, i0, n, xs, qs, wf, room, V.and_right(IS.named_fields_valid(z0, z1), IS.valid_go(z1, True{}), legal), partsof, encq,
                      walk_as_chain(z1, 0n, xs, n, SL.fixed_size(qs), 0n, SL.fixed_size(qs), [], qs, xs, P.adv(xs, SL.fixed_size(qs)), C.CEnd{}, i0, D.go(z1, 0n, 0n, D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(qs)), SL.fixed_size(qs), n, C.CEnd{}}), V.and_right(IS.named_fields_valid(z0, z1), IS.valid_go(z1, True{}), legal),
                        go_complete(z1, 0n, 0n, D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(qs)), SL.fixed_size(qs), n, C.CEnd{}}, i0, opt, xs, SL.fixed_size(qs), 0n, [], qs, xs, P.adv(xs, SL.fixed_size(qs)), C.CEnd{})({==}, forest_walk_legal(z1, V.and_right(IS.named_fields_valid(z0, z1), IS.valid_go(z1, True{}), legal)), walk_k_ok_zero(z1)))))
            case T.Items{i0, i1}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Container{z0, z1}, T.Items{i0, i1}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Items{i0, i1}, T.Container{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Container{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.EmptyItems{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Container{z0, z1}, T.EmptyItems{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.EmptyItems{}, T.Container{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Container{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Selected{v0, m0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Container{z0, z1}, T.Selected{v0, m0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Selected{v0, m0}, T.Container{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Container{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.NullValue{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Container{z0, z1}, T.NullValue{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.NullValue{}, T.Container{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Container{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
        case D.Walk{fixed, prior, other, pos, end, acc}:
          settled => legal => kok =>
            Empty.absurd(walk_obligation(T.Container{z0, z1}, k, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, D.go(T.Container{z0, z1}, 0n, k, D.Walk{fixed, prior, other, pos, end, acc})), F.false_true(legal))
        case D.Pick{sel, n, xs}:
          wf => room => legal => found => enc =>
            Empty.absurd(pick_obligation(T.Container{z0, z1}, k, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Container{z0, z1}, k), Some{opt}, found)))
        case D.PickAmong{selectors, sel, n, xs}:
          match selectors:
            case Nil{}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation([], T.Container{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.Container{z0, z1}, sel), Some{opt}, found)))
            case Con{sh, st}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation(sh <> st, T.Container{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.Container{z0, z1}, sel), Some{opt}, found)))
        case D.Invalid{}: Unit{}
    case T.ProgressiveContainer{z0, z1, z2}:
      match c:
        case D.Region{n, xs}:
          match value:
            case T.BooleanValue{b0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ProgressiveContainer{z0, z1, z2}, T.BooleanValue{b0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BooleanValue{b0}, T.ProgressiveContainer{z0, z1, z2}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveContainer{z0, z1, z2}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.UnsignedValue{u0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ProgressiveContainer{z0, z1, z2}, T.UnsignedValue{u0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.UnsignedValue{u0}, T.ProgressiveContainer{z0, z1, z2}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveContainer{z0, z1, z2}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.BytesValue{y0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ProgressiveContainer{z0, z1, z2}, T.BytesValue{y0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BytesValue{y0}, T.ProgressiveContainer{z0, z1, z2}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveContainer{z0, z1, z2}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.BitsValue{q0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ProgressiveContainer{z0, z1, z2}, T.BitsValue{q0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BitsValue{q0}, T.ProgressiveContainer{z0, z1, z2}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveContainer{z0, z1, z2}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Sequence{i0}:
              wf => room => legal => phaseok => enc =>
                CReg.aggregate_elim(region_obligation(T.ProgressiveContainer{z0, z1, z2}, T.Sequence{i0}, n, xs), SC.parts(i0, z1), SS.fixed_size(z1), List.take(&2, U32, P.slice_bytes(xs), n), enc,
                  qs => partsof => encq =>
                    CReg.progressive_container_region(z0, z1, z2, i0, n, xs, qs, wf, room, V.and_left(IS.valid_go(z1, True{}), Bool.and(Nat.is_le(Lists.length(Bool, z2), 256n), Bool.and(IS.ends_active(z2, False{}), Nat.is_eq(IS.active_count(z2, 0n), IS.count(z1)))), V.and_right(IS.named_fields_valid(z0, z1), Bool.and(IS.valid_go(z1, True{}), Bool.and(Nat.is_le(Lists.length(Bool, z2), 256n), Bool.and(IS.ends_active(z2, False{}), Nat.is_eq(IS.active_count(z2, 0n), IS.count(z1))))), legal)), partsof, encq,
                      walk_as_chain(z1, 0n, xs, n, SL.fixed_size(qs), 0n, SL.fixed_size(qs), [], qs, xs, P.adv(xs, SL.fixed_size(qs)), C.CEnd{}, i0, D.go(z1, 0n, 0n, D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(qs)), SL.fixed_size(qs), n, C.CEnd{}}), V.and_left(IS.valid_go(z1, True{}), Bool.and(Nat.is_le(Lists.length(Bool, z2), 256n), Bool.and(IS.ends_active(z2, False{}), Nat.is_eq(IS.active_count(z2, 0n), IS.count(z1)))), V.and_right(IS.named_fields_valid(z0, z1), Bool.and(IS.valid_go(z1, True{}), Bool.and(Nat.is_le(Lists.length(Bool, z2), 256n), Bool.and(IS.ends_active(z2, False{}), Nat.is_eq(IS.active_count(z2, 0n), IS.count(z1))))), legal)),
                        go_complete(z1, 0n, 0n, D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(qs)), SL.fixed_size(qs), n, C.CEnd{}}, i0, opt, xs, SL.fixed_size(qs), 0n, [], qs, xs, P.adv(xs, SL.fixed_size(qs)), C.CEnd{})({==}, forest_walk_legal(z1, V.and_left(IS.valid_go(z1, True{}), Bool.and(Nat.is_le(Lists.length(Bool, z2), 256n), Bool.and(IS.ends_active(z2, False{}), Nat.is_eq(IS.active_count(z2, 0n), IS.count(z1)))), V.and_right(IS.named_fields_valid(z0, z1), Bool.and(IS.valid_go(z1, True{}), Bool.and(Nat.is_le(Lists.length(Bool, z2), 256n), Bool.and(IS.ends_active(z2, False{}), Nat.is_eq(IS.active_count(z2, 0n), IS.count(z1))))), legal))), walk_k_ok_zero(z1)))))
            case T.Items{i0, i1}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ProgressiveContainer{z0, z1, z2}, T.Items{i0, i1}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Items{i0, i1}, T.ProgressiveContainer{z0, z1, z2}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveContainer{z0, z1, z2}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.EmptyItems{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ProgressiveContainer{z0, z1, z2}, T.EmptyItems{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.EmptyItems{}, T.ProgressiveContainer{z0, z1, z2}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveContainer{z0, z1, z2}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Selected{v0, m0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ProgressiveContainer{z0, z1, z2}, T.Selected{v0, m0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Selected{v0, m0}, T.ProgressiveContainer{z0, z1, z2}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveContainer{z0, z1, z2}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.NullValue{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.ProgressiveContainer{z0, z1, z2}, T.NullValue{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.NullValue{}, T.ProgressiveContainer{z0, z1, z2}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveContainer{z0, z1, z2}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
        case D.Walk{fixed, prior, other, pos, end, acc}:
          settled => legal => kok =>
            Empty.absurd(walk_obligation(T.ProgressiveContainer{z0, z1, z2}, k, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, D.go(T.ProgressiveContainer{z0, z1, z2}, 0n, k, D.Walk{fixed, prior, other, pos, end, acc})), F.false_true(legal))
        case D.Pick{sel, n, xs}:
          wf => room => legal => found => enc =>
            Empty.absurd(pick_obligation(T.ProgressiveContainer{z0, z1, z2}, k, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ProgressiveContainer{z0, z1, z2}, k), Some{opt}, found)))
        case D.PickAmong{selectors, sel, n, xs}:
          match selectors:
            case Nil{}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation([], T.ProgressiveContainer{z0, z1, z2}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.ProgressiveContainer{z0, z1, z2}, sel), Some{opt}, found)))
            case Con{sh, st}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation(sh <> st, T.ProgressiveContainer{z0, z1, z2}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.ProgressiveContainer{z0, z1, z2}, sel), Some{opt}, found)))
        case D.Invalid{}: Unit{}
    case T.Union{z0}:
      match c:
        case D.Region{n, xs}:
          match value:
            case T.BooleanValue{b0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Union{z0}, T.BooleanValue{b0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BooleanValue{b0}, T.Union{z0}), Some{[SC.fragment(SS.fixed_size(T.Union{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.UnsignedValue{u0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Union{z0}, T.UnsignedValue{u0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.UnsignedValue{u0}, T.Union{z0}), Some{[SC.fragment(SS.fixed_size(T.Union{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.BytesValue{y0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Union{z0}, T.BytesValue{y0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BytesValue{y0}, T.Union{z0}), Some{[SC.fragment(SS.fixed_size(T.Union{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.BitsValue{q0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Union{z0}, T.BitsValue{q0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BitsValue{q0}, T.Union{z0}), Some{[SC.fragment(SS.fixed_size(T.Union{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Sequence{i0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Union{z0}, T.Sequence{i0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Sequence{i0}, T.Union{z0}), Some{[SC.fragment(SS.fixed_size(T.Union{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Items{i0, i1}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Union{z0}, T.Items{i0, i1}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Items{i0, i1}, T.Union{z0}), Some{[SC.fragment(SS.fixed_size(T.Union{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.EmptyItems{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Union{z0}, T.EmptyItems{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.EmptyItems{}, T.Union{z0}), Some{[SC.fragment(SS.fixed_size(T.Union{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Selected{v0, m0}:
              wf => room => legal => phaseok => enc =>
                CReg.union_region(z0, v0, m0, n, xs, wf, room,
                  s2 => f2 => option_single(z0, U32.to_nat(v0), s2, m0, union_opts_legal(z0, legal), f2),
                  s2 => m2 => wfp => roomp => f2 => hp => go_complete(z0, 0n, U32.to_nat(v0), D.Pick{v0, m2, P.adv(xs, 1n)}, m0, s2, sl, fixedtotal, h, pdone, ps, hdr, pay, acc2)(wfp, roomp, union_opts_legal(z0, legal), f2, hp),
                  enc)
            case T.NullValue{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Union{z0}, T.NullValue{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.NullValue{}, T.Union{z0}), Some{[SC.fragment(SS.fixed_size(T.Union{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
        case D.Walk{fixed, prior, other, pos, end, acc}:
          settled => legal => kok =>
            Empty.absurd(walk_obligation(T.Union{z0}, k, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, D.go(T.Union{z0}, 0n, k, D.Walk{fixed, prior, other, pos, end, acc})), F.false_true(legal))
        case D.Pick{sel, n, xs}:
          wf => room => legal => found => enc =>
            Empty.absurd(pick_obligation(T.Union{z0}, k, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Union{z0}, k), Some{opt}, found)))
        case D.PickAmong{selectors, sel, n, xs}:
          match selectors:
            case Nil{}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation([], T.Union{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.Union{z0}, sel), Some{opt}, found)))
            case Con{sh, st}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation(sh <> st, T.Union{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.Union{z0}, sel), Some{opt}, found)))
        case D.Invalid{}: Unit{}
    case T.CompatibleUnion{z0, z1}:
      match c:
        case D.Region{n, xs}:
          match value:
            case T.BooleanValue{b0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.CompatibleUnion{z0, z1}, T.BooleanValue{b0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BooleanValue{b0}, T.CompatibleUnion{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.CompatibleUnion{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.UnsignedValue{u0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.CompatibleUnion{z0, z1}, T.UnsignedValue{u0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.UnsignedValue{u0}, T.CompatibleUnion{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.CompatibleUnion{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.BytesValue{y0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.CompatibleUnion{z0, z1}, T.BytesValue{y0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BytesValue{y0}, T.CompatibleUnion{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.CompatibleUnion{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.BitsValue{q0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.CompatibleUnion{z0, z1}, T.BitsValue{q0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BitsValue{q0}, T.CompatibleUnion{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.CompatibleUnion{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Sequence{i0}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.CompatibleUnion{z0, z1}, T.Sequence{i0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Sequence{i0}, T.CompatibleUnion{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.CompatibleUnion{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Items{i0, i1}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.CompatibleUnion{z0, z1}, T.Items{i0, i1}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Items{i0, i1}, T.CompatibleUnion{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.CompatibleUnion{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.EmptyItems{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.CompatibleUnion{z0, z1}, T.EmptyItems{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.EmptyItems{}, T.CompatibleUnion{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.CompatibleUnion{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
            case T.Selected{v0, m0}:
              wf => room => legal => phaseok => enc =>
                CReg.compatible_union_region(z0, z1, v0, m0, n, xs, wf, room,
                  s2 => f2 => compatible_single(z0, z1, v0, s2, m0, forest_opts_legal(z1, V.and_left(IS.valid_go(z1, True{}), IS.compatible_go(Nat.mul(1024n, 1n+IS.weight(z1)), 1, z1, z1), V.and_right(IS.selectors_valid(z0, []), Bool.and(IS.valid_go(z1, True{}), IS.compatible_go(Nat.mul(1024n, 1n+IS.weight(z1)), 1, z1, z1)), V.and_right(Nat.is_eq(Lists.length(U32, z0), IS.count(z1)), Bool.and(IS.selectors_valid(z0, []), Bool.and(IS.valid_go(z1, True{}), IS.compatible_go(Nat.mul(1024n, 1n+IS.weight(z1)), 1, z1, z1))), V.and_right(Nat.is_lt(0n, IS.count(z1)), Bool.and(Nat.is_eq(Lists.length(U32, z0), IS.count(z1)), Bool.and(IS.selectors_valid(z0, []), Bool.and(IS.valid_go(z1, True{}), IS.compatible_go(Nat.mul(1024n, 1n+IS.weight(z1)), 1, z1, z1)))), legal))))), f2),
                  s2 => m2 => wfp => roomp => f2 => hp => go_complete(z1, 0n, 0n, D.PickAmong{z0, v0, m2, P.adv(xs, 1n)}, m0, s2, sl, fixedtotal, h, pdone, ps, hdr, pay, acc2)(wfp, roomp, forest_opts_legal(z1, V.and_left(IS.valid_go(z1, True{}), IS.compatible_go(Nat.mul(1024n, 1n+IS.weight(z1)), 1, z1, z1), V.and_right(IS.selectors_valid(z0, []), Bool.and(IS.valid_go(z1, True{}), IS.compatible_go(Nat.mul(1024n, 1n+IS.weight(z1)), 1, z1, z1)), V.and_right(Nat.is_eq(Lists.length(U32, z0), IS.count(z1)), Bool.and(IS.selectors_valid(z0, []), Bool.and(IS.valid_go(z1, True{}), IS.compatible_go(Nat.mul(1024n, 1n+IS.weight(z1)), 1, z1, z1))), V.and_right(Nat.is_lt(0n, IS.count(z1)), Bool.and(Nat.is_eq(Lists.length(U32, z0), IS.count(z1)), Bool.and(IS.selectors_valid(z0, []), Bool.and(IS.valid_go(z1, True{}), IS.compatible_go(Nat.mul(1024n, 1n+IS.weight(z1)), 1, z1, z1)))), legal))))), f2, hp),
                  enc)
            case T.NullValue{}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.CompatibleUnion{z0, z1}, T.NullValue{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.NullValue{}, T.CompatibleUnion{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.CompatibleUnion{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
        case D.Walk{fixed, prior, other, pos, end, acc}:
          settled => legal => kok =>
            Empty.absurd(walk_obligation(T.CompatibleUnion{z0, z1}, k, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, D.go(T.CompatibleUnion{z0, z1}, 0n, k, D.Walk{fixed, prior, other, pos, end, acc})), F.false_true(legal))
        case D.Pick{sel, n, xs}:
          wf => room => legal => found => enc =>
            Empty.absurd(pick_obligation(T.CompatibleUnion{z0, z1}, k, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.CompatibleUnion{z0, z1}, k), Some{opt}, found)))
        case D.PickAmong{selectors, sel, n, xs}:
          match selectors:
            case Nil{}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation([], T.CompatibleUnion{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.CompatibleUnion{z0, z1}, sel), Some{opt}, found)))
            case Con{sh, st}:
              wf => room => legal => found => enc =>
                Empty.absurd(among_obligation(sh <> st, T.CompatibleUnion{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.CompatibleUnion{z0, z1}, sel), Some{opt}, found)))
        case D.Invalid{}: Unit{}
    case T.Chain{z0, z1}:
      match k:
        case 0n:
          match c:
            case D.Region{n, xs}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Chain{z0, z1}, value, n, xs), F.false_true(legal))
            case D.Walk{fixed, prior, other, pos, end, acc}:
              settled => legal => kok =>
                CStep.chain_walk_complete(z0, z1, 0n, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, settled, legal, kok,
                  cv0 => n2 => xs2 => wfx2 => roomx2 => hx2 => go_complete(z0, 1n, 0n, D.Region{n2, xs2}, cv0, opt, sl, fixedtotal, h, pdone, ps, hdr, pay, acc2)(wfx2, roomx2, or_right(CReg.is_null(z0), IS.valid_go(z0, False{}), V.and_left(IS.valid_go(z0, False{}), IS.valid_go(z1, True{}), legal)), {==}, hx2),
                  h2 => pos2 => pdone2 => ps2 => hdr2 => pay2 => acc3 => value2 => fixed2 => prior2 => other2 => settled2 =>
                    walk_as_chain(z1, 0n, sl, end, fixedtotal, h2, pos2, pdone2, ps2, hdr2, pay2, acc3, value2, D.go(z1, 0n, 0n, D.Walk{fixed2, prior2, other2, pos2, end, acc2}), V.and_right(IS.valid_go(z0, False{}), IS.valid_go(z1, True{}), legal),
                      go_complete(z1, 0n, 0n, D.Walk{fixed2, prior2, other2, pos2, end, acc2}, value2, opt, sl, fixedtotal, h2, pdone2, ps2, hdr2, pay2, acc3)(settled2, forest_walk_legal(z1, V.and_right(IS.valid_go(z0, False{}), IS.valid_go(z1, True{}), legal)), walk_k_ok_zero(z1))))
            case D.Pick{sel, n, xs}:
              wf => room => legal => found => enc =>
                CWalk.selected_complete(D.go(z0, 1n, 0n, D.Region{n, xs}), xs, n, sel, value,
                  go_complete(z0, 1n, 0n, D.Region{n, xs}, value, opt, sl, fixedtotal, h, pdone, ps, hdr, pay, acc2)(wf, room, V.and_left(CReg.region_legal(z0), opts_legal(z1), legal), {==}, holds_cast(z0, opt, value, xs, n, Equal.cong(Maybe<&2, T.Schema>, T.Schema, r => CWalk.schema_of(r, z0), Some{z0}, Some{opt}, found), enc)))
            case D.PickAmong{selectors, sel, n, xs}:
              match selectors:
                case Nil{}:
                  wf => room => legal => found => enc =>
                    Empty.absurd(among_obligation([], T.Chain{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.Chain{z0, z1}, sel), Some{opt}, found)))
                case Con{sh, st}:
                  wf => room => legal => found => enc =>
                    among_dispatch(U32.is_eq(sh, sel), sh, sel, z0, z1, st, opt, n, xs, value, {==}, found, enc,
                      eq2 => hc2 => go_complete(z0, 1n, 0n, D.Region{n, xs}, value, opt, sl, fixedtotal, h, pdone, ps, hdr, pay, acc2)(wf, room, V.and_left(CReg.region_legal(z0), opts_legal(z1), legal), {==}, hc2),
                      f2 => ec2 => go_complete(z1, 0n, 0n, D.PickAmong{st, sel, n, xs}, value, opt, sl, fixedtotal, h, pdone, ps, hdr, pay, acc2)(wf, room, V.and_right(CReg.region_legal(z0), opts_legal(z1), legal), f2, ec2))
            case D.Invalid{}: Unit{}
        case 1n+p:
          match c:
            case D.Region{n, xs}:
              wf => room => legal => phaseok => enc =>
                Empty.absurd(region_obligation(T.Chain{z0, z1}, value, n, xs), F.false_true(legal))
            case D.Walk{fixed, prior, other, pos, end, acc}:
              settled => legal => kok =>
                CStep.chain_walk_complete(z0, z1, 1n+p, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, settled, legal, kok,
                  cv0 => n2 => xs2 => wfx2 => roomx2 => hx2 => go_complete(z0, 1n, 0n, D.Region{n2, xs2}, cv0, opt, sl, fixedtotal, h, pdone, ps, hdr, pay, acc2)(wfx2, roomx2, or_right(CReg.is_null(z0), IS.valid_go(z0, False{}), V.and_left(IS.valid_go(z0, False{}), IS.valid_go(z1, True{}), legal)), {==}, hx2),
                  h2 => pos2 => pdone2 => ps2 => hdr2 => pay2 => acc3 => value2 => fixed2 => prior2 => other2 => settled2 =>
                    walk_as_chain(z1, 0n, sl, end, fixedtotal, h2, pos2, pdone2, ps2, hdr2, pay2, acc3, value2, D.go(z1, 0n, 0n, D.Walk{fixed2, prior2, other2, pos2, end, acc2}), V.and_right(IS.valid_go(z0, False{}), IS.valid_go(z1, True{}), legal),
                      go_complete(z1, 0n, 0n, D.Walk{fixed2, prior2, other2, pos2, end, acc2}, value2, opt, sl, fixedtotal, h2, pdone2, ps2, hdr2, pay2, acc3)(settled2, forest_walk_legal(z1, V.and_right(IS.valid_go(z0, False{}), IS.valid_go(z1, True{}), legal)), walk_k_ok_zero(z1))))
            case D.Pick{sel, n, xs}:
              wf => room => legal => found => enc =>
                go_complete(z1, 0n, p, D.Pick{sel, n, xs}, value, opt, sl, fixedtotal, h, pdone, ps, hdr, pay, acc2)(wf, room, V.and_right(CReg.region_legal(z0), opts_legal(z1), legal), found, enc)
            case D.PickAmong{selectors, sel, n, xs}:
              match selectors:
                case Nil{}:
                  wf => room => legal => found => enc =>
                    Empty.absurd(among_obligation([], T.Chain{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.Chain{z0, z1}, sel), Some{opt}, found)))
                case Con{sh, st}:
                  wf => room => legal => found => enc =>
                    among_dispatch(U32.is_eq(sh, sel), sh, sel, z0, z1, st, opt, n, xs, value, {==}, found, enc,
                      eq2 => hc2 => go_complete(z0, 1n, 0n, D.Region{n, xs}, value, opt, sl, fixedtotal, h, pdone, ps, hdr, pay, acc2)(wf, room, V.and_left(CReg.region_legal(z0), opts_legal(z1), legal), {==}, hc2),
                      f2 => ec2 => go_complete(z1, 0n, 0n, D.PickAmong{st, sel, n, xs}, value, opt, sl, fixedtotal, h, pdone, ps, hdr, pay, acc2)(wf, room, V.and_right(CReg.region_legal(z0), opts_legal(z1), legal), f2, ec2))
            case D.Invalid{}: Unit{}
    case T.Vector{z0, z1}:
      match phase:
        case 0n:
          match k:
            case 0n:
              match c:
                case D.Region{n, xs}:
                  wf => room => legal => phaseok => enc =>
                    Empty.absurd(region_obligation(T.Vector{z0, z1}, value, n, xs), F.false_true(phaseok))
                case D.Walk{fixed, prior, other, pos, end, acc}:
                  settled => legal => kok =>
                    CStep.seq_close_complete(T.Vector{z0, z1}, z0, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, settled, {==})
                case D.Pick{sel, n, xs}:
                  wf => room => legal => found => enc =>
                    Empty.absurd(pick_obligation(T.Vector{z0, z1}, 0n, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Vector{z0, z1}, 0n), Some{opt}, found)))
                case D.PickAmong{selectors, sel, n, xs}:
                  match selectors:
                    case Nil{}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation([], T.Vector{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.Vector{z0, z1}, sel), Some{opt}, found)))
                    case Con{sh, st}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation(sh <> st, T.Vector{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.Vector{z0, z1}, sel), Some{opt}, found)))
                case D.Invalid{}: Unit{}
            case 1n+p:
              match c:
                case D.Region{n, xs}:
                  wf => room => legal => phaseok => enc =>
                    Empty.absurd(region_obligation(T.Vector{z0, z1}, value, n, xs), F.false_true(phaseok))
                case D.Walk{fixed, prior, other, pos, end, acc}:
                  settled => legal => kok =>
                    CStep.seq_step_complete(T.Vector{z0, z1}, z0, p, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, settled, legal, {==},
                      cv0 => n2 => xs2 => wfx2 => roomx2 => hx2 => go_complete(z0, 1n, 0n, D.Region{n2, xs2}, cv0, opt, sl, fixedtotal, h, pdone, ps, hdr, pay, acc2)(wfx2, roomx2, or_right(CReg.is_null(z0), IS.valid_go(z0, False{}), legal), {==}, hx2),
                      h2 => pos2 => pdone2 => ps2 => hdr2 => pay2 => acc3 => value2 => fixed2 => prior2 => other2 => settled2 =>
                        go_complete(T.Vector{z0, z1}, 0n, p, D.Walk{fixed2, prior2, other2, pos2, end, acc2}, value2, opt, sl, fixedtotal, h2, pdone2, ps2, hdr2, pay2, acc3)(settled2, legal, {==}))
                case D.Pick{sel, n, xs}:
                  wf => room => legal => found => enc =>
                    Empty.absurd(pick_obligation(T.Vector{z0, z1}, 1n+p, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Vector{z0, z1}, 1n+p), Some{opt}, found)))
                case D.PickAmong{selectors, sel, n, xs}:
                  match selectors:
                    case Nil{}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation([], T.Vector{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.Vector{z0, z1}, sel), Some{opt}, found)))
                    case Con{sh, st}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation(sh <> st, T.Vector{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.Vector{z0, z1}, sel), Some{opt}, found)))
                case D.Invalid{}: Unit{}
        case 1n+q:
          match k:
            case 0n:
              match c:
                case D.Region{n, xs}:
                  match value:
                    case T.BooleanValue{b0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.Vector{z0, z1}, T.BooleanValue{b0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BooleanValue{b0}, T.Vector{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Vector{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.UnsignedValue{u0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.Vector{z0, z1}, T.UnsignedValue{u0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.UnsignedValue{u0}, T.Vector{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Vector{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.BytesValue{y0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.Vector{z0, z1}, T.BytesValue{y0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BytesValue{y0}, T.Vector{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Vector{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.BitsValue{q0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.Vector{z0, z1}, T.BitsValue{q0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BitsValue{q0}, T.Vector{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Vector{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.Sequence{i0}:
                      wf => room => legal => phaseok => enc =>
                        CReg.require_elim(region_obligation(T.Vector{z0, z1}, T.Sequence{i0}, n, xs),
                          Bool.and(Nat.is_lt(0n, z1), Nat.is_eq(SC.count(i0), z1)),
                          SC.aggregate(SC.parts(i0, T.Repeat{z0}), SS.times(z1, SS.fixed_size(z0))),
                          [SC.fragment(SS.fixed_size(T.Vector{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))], enc,
                          okeq => aggeq =>
                            CReg.aggregate_elim(region_obligation(T.Vector{z0, z1}, T.Sequence{i0}, n, xs), SC.parts(i0, T.Repeat{z0}), SS.times(z1, SS.fixed_size(z0)), List.take(&2, U32, P.slice_bytes(xs), n), aggeq,
                              qs => partsof => encq =>
                                CReg.vector_region(z0, z1, i0, n, xs, qs, wf, room, V.and_right(Nat.is_lt(0n, z1), IS.valid_go(z0, False{}), legal),
                                  V.and_left(Nat.is_lt(0n, z1), Nat.is_eq(SC.count(i0), z1), okeq),
                                  BVI.nat_equal_sound(SC.count(i0), z1, V.and_right(Nat.is_lt(0n, z1), Nat.is_eq(SC.count(i0), z1), okeq)),
                                  partsof, encq,
                                  go_complete(T.Vector{z0, z1}, q, z1, D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(qs)), SL.fixed_size(qs), n, C.CEnd{}}, i0, opt, xs, SL.fixed_size(qs), 0n, [], qs, xs, P.adv(xs, SL.fixed_size(qs)), C.CEnd{})({==}, V.and_right(Nat.is_lt(0n, z1), IS.valid_go(z0, False{}), legal), {==}))))
                    case T.Items{i0, i1}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.Vector{z0, z1}, T.Items{i0, i1}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Items{i0, i1}, T.Vector{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Vector{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.EmptyItems{}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.Vector{z0, z1}, T.EmptyItems{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.EmptyItems{}, T.Vector{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Vector{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.Selected{v0, m0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.Vector{z0, z1}, T.Selected{v0, m0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Selected{v0, m0}, T.Vector{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Vector{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.NullValue{}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.Vector{z0, z1}, T.NullValue{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.NullValue{}, T.Vector{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Vector{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                case D.Walk{fixed, prior, other, pos, end, acc}:
                  settled => legal => kok =>
                    CStep.seq_close_complete(T.Vector{z0, z1}, z0, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, settled, {==})
                case D.Pick{sel, n, xs}:
                  wf => room => legal => found => enc =>
                    Empty.absurd(pick_obligation(T.Vector{z0, z1}, 0n, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Vector{z0, z1}, 0n), Some{opt}, found)))
                case D.PickAmong{selectors, sel, n, xs}:
                  match selectors:
                    case Nil{}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation([], T.Vector{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.Vector{z0, z1}, sel), Some{opt}, found)))
                    case Con{sh, st}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation(sh <> st, T.Vector{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.Vector{z0, z1}, sel), Some{opt}, found)))
                case D.Invalid{}: Unit{}
            case 1n+p:
              match c:
                case D.Region{n, xs}:
                  match value:
                    case T.BooleanValue{b0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.Vector{z0, z1}, T.BooleanValue{b0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BooleanValue{b0}, T.Vector{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Vector{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.UnsignedValue{u0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.Vector{z0, z1}, T.UnsignedValue{u0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.UnsignedValue{u0}, T.Vector{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Vector{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.BytesValue{y0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.Vector{z0, z1}, T.BytesValue{y0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BytesValue{y0}, T.Vector{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Vector{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.BitsValue{q0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.Vector{z0, z1}, T.BitsValue{q0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BitsValue{q0}, T.Vector{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Vector{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.Sequence{i0}:
                      wf => room => legal => phaseok => enc =>
                        CReg.require_elim(region_obligation(T.Vector{z0, z1}, T.Sequence{i0}, n, xs),
                          Bool.and(Nat.is_lt(0n, z1), Nat.is_eq(SC.count(i0), z1)),
                          SC.aggregate(SC.parts(i0, T.Repeat{z0}), SS.times(z1, SS.fixed_size(z0))),
                          [SC.fragment(SS.fixed_size(T.Vector{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))], enc,
                          okeq => aggeq =>
                            CReg.aggregate_elim(region_obligation(T.Vector{z0, z1}, T.Sequence{i0}, n, xs), SC.parts(i0, T.Repeat{z0}), SS.times(z1, SS.fixed_size(z0)), List.take(&2, U32, P.slice_bytes(xs), n), aggeq,
                              qs => partsof => encq =>
                                CReg.vector_region(z0, z1, i0, n, xs, qs, wf, room, V.and_right(Nat.is_lt(0n, z1), IS.valid_go(z0, False{}), legal),
                                  V.and_left(Nat.is_lt(0n, z1), Nat.is_eq(SC.count(i0), z1), okeq),
                                  BVI.nat_equal_sound(SC.count(i0), z1, V.and_right(Nat.is_lt(0n, z1), Nat.is_eq(SC.count(i0), z1), okeq)),
                                  partsof, encq,
                                  go_complete(T.Vector{z0, z1}, q, z1, D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(qs)), SL.fixed_size(qs), n, C.CEnd{}}, i0, opt, xs, SL.fixed_size(qs), 0n, [], qs, xs, P.adv(xs, SL.fixed_size(qs)), C.CEnd{})({==}, V.and_right(Nat.is_lt(0n, z1), IS.valid_go(z0, False{}), legal), {==}))))
                    case T.Items{i0, i1}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.Vector{z0, z1}, T.Items{i0, i1}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Items{i0, i1}, T.Vector{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Vector{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.EmptyItems{}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.Vector{z0, z1}, T.EmptyItems{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.EmptyItems{}, T.Vector{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Vector{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.Selected{v0, m0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.Vector{z0, z1}, T.Selected{v0, m0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Selected{v0, m0}, T.Vector{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Vector{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.NullValue{}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.Vector{z0, z1}, T.NullValue{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.NullValue{}, T.Vector{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.Vector{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                case D.Walk{fixed, prior, other, pos, end, acc}:
                  settled => legal => kok =>
                    CStep.seq_step_complete(T.Vector{z0, z1}, z0, p, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, settled, legal, {==},
                      cv0 => n2 => xs2 => wfx2 => roomx2 => hx2 => go_complete(z0, 1n, 0n, D.Region{n2, xs2}, cv0, opt, sl, fixedtotal, h, pdone, ps, hdr, pay, acc2)(wfx2, roomx2, or_right(CReg.is_null(z0), IS.valid_go(z0, False{}), legal), {==}, hx2),
                      h2 => pos2 => pdone2 => ps2 => hdr2 => pay2 => acc3 => value2 => fixed2 => prior2 => other2 => settled2 =>
                        go_complete(T.Vector{z0, z1}, 1n+q, p, D.Walk{fixed2, prior2, other2, pos2, end, acc2}, value2, opt, sl, fixedtotal, h2, pdone2, ps2, hdr2, pay2, acc3)(settled2, legal, {==}))
                case D.Pick{sel, n, xs}:
                  wf => room => legal => found => enc =>
                    Empty.absurd(pick_obligation(T.Vector{z0, z1}, 1n+p, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.Vector{z0, z1}, 1n+p), Some{opt}, found)))
                case D.PickAmong{selectors, sel, n, xs}:
                  match selectors:
                    case Nil{}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation([], T.Vector{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.Vector{z0, z1}, sel), Some{opt}, found)))
                    case Con{sh, st}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation(sh <> st, T.Vector{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.Vector{z0, z1}, sel), Some{opt}, found)))
                case D.Invalid{}: Unit{}
    case T.ListOf{z0, z1}:
      match phase:
        case 0n:
          match k:
            case 0n:
              match c:
                case D.Region{n, xs}:
                  wf => room => legal => phaseok => enc =>
                    Empty.absurd(region_obligation(T.ListOf{z0, z1}, value, n, xs), F.false_true(phaseok))
                case D.Walk{fixed, prior, other, pos, end, acc}:
                  settled => legal => kok =>
                    CStep.seq_close_complete(T.ListOf{z0, z1}, z0, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, settled, {==})
                case D.Pick{sel, n, xs}:
                  wf => room => legal => found => enc =>
                    Empty.absurd(pick_obligation(T.ListOf{z0, z1}, 0n, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ListOf{z0, z1}, 0n), Some{opt}, found)))
                case D.PickAmong{selectors, sel, n, xs}:
                  match selectors:
                    case Nil{}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation([], T.ListOf{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.ListOf{z0, z1}, sel), Some{opt}, found)))
                    case Con{sh, st}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation(sh <> st, T.ListOf{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.ListOf{z0, z1}, sel), Some{opt}, found)))
                case D.Invalid{}: Unit{}
            case 1n+p:
              match c:
                case D.Region{n, xs}:
                  wf => room => legal => phaseok => enc =>
                    Empty.absurd(region_obligation(T.ListOf{z0, z1}, value, n, xs), F.false_true(phaseok))
                case D.Walk{fixed, prior, other, pos, end, acc}:
                  settled => legal => kok =>
                    CStep.seq_step_complete(T.ListOf{z0, z1}, z0, p, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, settled, legal, {==},
                      cv0 => n2 => xs2 => wfx2 => roomx2 => hx2 => go_complete(z0, 1n, 0n, D.Region{n2, xs2}, cv0, opt, sl, fixedtotal, h, pdone, ps, hdr, pay, acc2)(wfx2, roomx2, or_right(CReg.is_null(z0), IS.valid_go(z0, False{}), legal), {==}, hx2),
                      h2 => pos2 => pdone2 => ps2 => hdr2 => pay2 => acc3 => value2 => fixed2 => prior2 => other2 => settled2 =>
                        go_complete(T.ListOf{z0, z1}, 0n, p, D.Walk{fixed2, prior2, other2, pos2, end, acc2}, value2, opt, sl, fixedtotal, h2, pdone2, ps2, hdr2, pay2, acc3)(settled2, legal, {==}))
                case D.Pick{sel, n, xs}:
                  wf => room => legal => found => enc =>
                    Empty.absurd(pick_obligation(T.ListOf{z0, z1}, 1n+p, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ListOf{z0, z1}, 1n+p), Some{opt}, found)))
                case D.PickAmong{selectors, sel, n, xs}:
                  match selectors:
                    case Nil{}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation([], T.ListOf{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.ListOf{z0, z1}, sel), Some{opt}, found)))
                    case Con{sh, st}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation(sh <> st, T.ListOf{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.ListOf{z0, z1}, sel), Some{opt}, found)))
                case D.Invalid{}: Unit{}
        case 1n+q:
          match k:
            case 0n:
              match c:
                case D.Region{n, xs}:
                  match value:
                    case T.BooleanValue{b0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ListOf{z0, z1}, T.BooleanValue{b0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BooleanValue{b0}, T.ListOf{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.ListOf{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.UnsignedValue{u0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ListOf{z0, z1}, T.UnsignedValue{u0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.UnsignedValue{u0}, T.ListOf{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.ListOf{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.BytesValue{y0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ListOf{z0, z1}, T.BytesValue{y0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BytesValue{y0}, T.ListOf{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.ListOf{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.BitsValue{q0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ListOf{z0, z1}, T.BitsValue{q0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BitsValue{q0}, T.ListOf{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.ListOf{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.Sequence{i0}:
                      wf => room => legal => phaseok => enc =>
                        CReg.require_elim(region_obligation(T.ListOf{z0, z1}, T.Sequence{i0}, n, xs), Nat.is_le(SC.count(i0), z1),
                          SC.aggregate(SC.parts(i0, T.Repeat{z0}), None{}),
                          [SC.fragment(SS.fixed_size(T.ListOf{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))], enc,
                          okeq => aggeq =>
                            CReg.aggregate_elim(region_obligation(T.ListOf{z0, z1}, T.Sequence{i0}, n, xs), SC.parts(i0, T.Repeat{z0}), None{}, List.take(&2, U32, P.slice_bytes(xs), n), aggeq,
                              qs => partsof => encq =>
                                CReg.list_region(z0, z1, SC.count(i0), i0, n, xs, qs, wf, room, legal, okeq, {==}, partsof, encq,
                                  go_complete(T.ListOf{z0, z1}, q, SC.count(i0), D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(qs)), SL.fixed_size(qs), n, C.CEnd{}}, i0, opt, xs, SL.fixed_size(qs), 0n, [], qs, xs, P.adv(xs, SL.fixed_size(qs)), C.CEnd{})({==}, legal, {==}))))
                    case T.Items{i0, i1}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ListOf{z0, z1}, T.Items{i0, i1}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Items{i0, i1}, T.ListOf{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.ListOf{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.EmptyItems{}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ListOf{z0, z1}, T.EmptyItems{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.EmptyItems{}, T.ListOf{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.ListOf{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.Selected{v0, m0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ListOf{z0, z1}, T.Selected{v0, m0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Selected{v0, m0}, T.ListOf{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.ListOf{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.NullValue{}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ListOf{z0, z1}, T.NullValue{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.NullValue{}, T.ListOf{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.ListOf{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                case D.Walk{fixed, prior, other, pos, end, acc}:
                  settled => legal => kok =>
                    CStep.seq_close_complete(T.ListOf{z0, z1}, z0, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, settled, {==})
                case D.Pick{sel, n, xs}:
                  wf => room => legal => found => enc =>
                    Empty.absurd(pick_obligation(T.ListOf{z0, z1}, 0n, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ListOf{z0, z1}, 0n), Some{opt}, found)))
                case D.PickAmong{selectors, sel, n, xs}:
                  match selectors:
                    case Nil{}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation([], T.ListOf{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.ListOf{z0, z1}, sel), Some{opt}, found)))
                    case Con{sh, st}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation(sh <> st, T.ListOf{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.ListOf{z0, z1}, sel), Some{opt}, found)))
                case D.Invalid{}: Unit{}
            case 1n+p:
              match c:
                case D.Region{n, xs}:
                  match value:
                    case T.BooleanValue{b0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ListOf{z0, z1}, T.BooleanValue{b0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BooleanValue{b0}, T.ListOf{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.ListOf{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.UnsignedValue{u0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ListOf{z0, z1}, T.UnsignedValue{u0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.UnsignedValue{u0}, T.ListOf{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.ListOf{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.BytesValue{y0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ListOf{z0, z1}, T.BytesValue{y0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BytesValue{y0}, T.ListOf{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.ListOf{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.BitsValue{q0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ListOf{z0, z1}, T.BitsValue{q0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BitsValue{q0}, T.ListOf{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.ListOf{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.Sequence{i0}:
                      wf => room => legal => phaseok => enc =>
                        CReg.require_elim(region_obligation(T.ListOf{z0, z1}, T.Sequence{i0}, n, xs), Nat.is_le(SC.count(i0), z1),
                          SC.aggregate(SC.parts(i0, T.Repeat{z0}), None{}),
                          [SC.fragment(SS.fixed_size(T.ListOf{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))], enc,
                          okeq => aggeq =>
                            CReg.aggregate_elim(region_obligation(T.ListOf{z0, z1}, T.Sequence{i0}, n, xs), SC.parts(i0, T.Repeat{z0}), None{}, List.take(&2, U32, P.slice_bytes(xs), n), aggeq,
                              qs => partsof => encq =>
                                CReg.list_region(z0, z1, SC.count(i0), i0, n, xs, qs, wf, room, legal, okeq, {==}, partsof, encq,
                                  go_complete(T.ListOf{z0, z1}, q, SC.count(i0), D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(qs)), SL.fixed_size(qs), n, C.CEnd{}}, i0, opt, xs, SL.fixed_size(qs), 0n, [], qs, xs, P.adv(xs, SL.fixed_size(qs)), C.CEnd{})({==}, legal, {==}))))
                    case T.Items{i0, i1}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ListOf{z0, z1}, T.Items{i0, i1}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Items{i0, i1}, T.ListOf{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.ListOf{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.EmptyItems{}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ListOf{z0, z1}, T.EmptyItems{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.EmptyItems{}, T.ListOf{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.ListOf{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.Selected{v0, m0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ListOf{z0, z1}, T.Selected{v0, m0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Selected{v0, m0}, T.ListOf{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.ListOf{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.NullValue{}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ListOf{z0, z1}, T.NullValue{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.NullValue{}, T.ListOf{z0, z1}), Some{[SC.fragment(SS.fixed_size(T.ListOf{z0, z1}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                case D.Walk{fixed, prior, other, pos, end, acc}:
                  settled => legal => kok =>
                    CStep.seq_step_complete(T.ListOf{z0, z1}, z0, p, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, settled, legal, {==},
                      cv0 => n2 => xs2 => wfx2 => roomx2 => hx2 => go_complete(z0, 1n, 0n, D.Region{n2, xs2}, cv0, opt, sl, fixedtotal, h, pdone, ps, hdr, pay, acc2)(wfx2, roomx2, or_right(CReg.is_null(z0), IS.valid_go(z0, False{}), legal), {==}, hx2),
                      h2 => pos2 => pdone2 => ps2 => hdr2 => pay2 => acc3 => value2 => fixed2 => prior2 => other2 => settled2 =>
                        go_complete(T.ListOf{z0, z1}, 1n+q, p, D.Walk{fixed2, prior2, other2, pos2, end, acc2}, value2, opt, sl, fixedtotal, h2, pdone2, ps2, hdr2, pay2, acc3)(settled2, legal, {==}))
                case D.Pick{sel, n, xs}:
                  wf => room => legal => found => enc =>
                    Empty.absurd(pick_obligation(T.ListOf{z0, z1}, 1n+p, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ListOf{z0, z1}, 1n+p), Some{opt}, found)))
                case D.PickAmong{selectors, sel, n, xs}:
                  match selectors:
                    case Nil{}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation([], T.ListOf{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.ListOf{z0, z1}, sel), Some{opt}, found)))
                    case Con{sh, st}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation(sh <> st, T.ListOf{z0, z1}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.ListOf{z0, z1}, sel), Some{opt}, found)))
                case D.Invalid{}: Unit{}
    case T.ProgressiveList{z0}:
      match phase:
        case 0n:
          match k:
            case 0n:
              match c:
                case D.Region{n, xs}:
                  wf => room => legal => phaseok => enc =>
                    Empty.absurd(region_obligation(T.ProgressiveList{z0}, value, n, xs), F.false_true(phaseok))
                case D.Walk{fixed, prior, other, pos, end, acc}:
                  settled => legal => kok =>
                    CStep.seq_close_complete(T.ProgressiveList{z0}, z0, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, settled, {==})
                case D.Pick{sel, n, xs}:
                  wf => room => legal => found => enc =>
                    Empty.absurd(pick_obligation(T.ProgressiveList{z0}, 0n, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ProgressiveList{z0}, 0n), Some{opt}, found)))
                case D.PickAmong{selectors, sel, n, xs}:
                  match selectors:
                    case Nil{}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation([], T.ProgressiveList{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.ProgressiveList{z0}, sel), Some{opt}, found)))
                    case Con{sh, st}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation(sh <> st, T.ProgressiveList{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.ProgressiveList{z0}, sel), Some{opt}, found)))
                case D.Invalid{}: Unit{}
            case 1n+p:
              match c:
                case D.Region{n, xs}:
                  wf => room => legal => phaseok => enc =>
                    Empty.absurd(region_obligation(T.ProgressiveList{z0}, value, n, xs), F.false_true(phaseok))
                case D.Walk{fixed, prior, other, pos, end, acc}:
                  settled => legal => kok =>
                    CStep.seq_step_complete(T.ProgressiveList{z0}, z0, p, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, settled, legal, {==},
                      cv0 => n2 => xs2 => wfx2 => roomx2 => hx2 => go_complete(z0, 1n, 0n, D.Region{n2, xs2}, cv0, opt, sl, fixedtotal, h, pdone, ps, hdr, pay, acc2)(wfx2, roomx2, or_right(CReg.is_null(z0), IS.valid_go(z0, False{}), legal), {==}, hx2),
                      h2 => pos2 => pdone2 => ps2 => hdr2 => pay2 => acc3 => value2 => fixed2 => prior2 => other2 => settled2 =>
                        go_complete(T.ProgressiveList{z0}, 0n, p, D.Walk{fixed2, prior2, other2, pos2, end, acc2}, value2, opt, sl, fixedtotal, h2, pdone2, ps2, hdr2, pay2, acc3)(settled2, legal, {==}))
                case D.Pick{sel, n, xs}:
                  wf => room => legal => found => enc =>
                    Empty.absurd(pick_obligation(T.ProgressiveList{z0}, 1n+p, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ProgressiveList{z0}, 1n+p), Some{opt}, found)))
                case D.PickAmong{selectors, sel, n, xs}:
                  match selectors:
                    case Nil{}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation([], T.ProgressiveList{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.ProgressiveList{z0}, sel), Some{opt}, found)))
                    case Con{sh, st}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation(sh <> st, T.ProgressiveList{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.ProgressiveList{z0}, sel), Some{opt}, found)))
                case D.Invalid{}: Unit{}
        case 1n+q:
          match k:
            case 0n:
              match c:
                case D.Region{n, xs}:
                  match value:
                    case T.BooleanValue{b0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ProgressiveList{z0}, T.BooleanValue{b0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BooleanValue{b0}, T.ProgressiveList{z0}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.UnsignedValue{u0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ProgressiveList{z0}, T.UnsignedValue{u0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.UnsignedValue{u0}, T.ProgressiveList{z0}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.BytesValue{y0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ProgressiveList{z0}, T.BytesValue{y0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BytesValue{y0}, T.ProgressiveList{z0}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.BitsValue{q0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ProgressiveList{z0}, T.BitsValue{q0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BitsValue{q0}, T.ProgressiveList{z0}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.Sequence{i0}:
                      wf => room => legal => phaseok => enc =>
                        CReg.aggregate_elim(region_obligation(T.ProgressiveList{z0}, T.Sequence{i0}, n, xs), SC.parts(i0, T.Repeat{z0}), None{}, List.take(&2, U32, P.slice_bytes(xs), n), enc,
                          qs => partsof => encq =>
                            CReg.progressive_list_region(z0, SC.count(i0), i0, n, xs, qs, wf, room, legal, {==}, partsof, encq,
                              go_complete(T.ProgressiveList{z0}, q, SC.count(i0), D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(qs)), SL.fixed_size(qs), n, C.CEnd{}}, i0, opt, xs, SL.fixed_size(qs), 0n, [], qs, xs, P.adv(xs, SL.fixed_size(qs)), C.CEnd{})({==}, legal, {==})))
                    case T.Items{i0, i1}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ProgressiveList{z0}, T.Items{i0, i1}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Items{i0, i1}, T.ProgressiveList{z0}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.EmptyItems{}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ProgressiveList{z0}, T.EmptyItems{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.EmptyItems{}, T.ProgressiveList{z0}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.Selected{v0, m0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ProgressiveList{z0}, T.Selected{v0, m0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Selected{v0, m0}, T.ProgressiveList{z0}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.NullValue{}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ProgressiveList{z0}, T.NullValue{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.NullValue{}, T.ProgressiveList{z0}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                case D.Walk{fixed, prior, other, pos, end, acc}:
                  settled => legal => kok =>
                    CStep.seq_close_complete(T.ProgressiveList{z0}, z0, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, settled, {==})
                case D.Pick{sel, n, xs}:
                  wf => room => legal => found => enc =>
                    Empty.absurd(pick_obligation(T.ProgressiveList{z0}, 0n, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ProgressiveList{z0}, 0n), Some{opt}, found)))
                case D.PickAmong{selectors, sel, n, xs}:
                  match selectors:
                    case Nil{}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation([], T.ProgressiveList{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.ProgressiveList{z0}, sel), Some{opt}, found)))
                    case Con{sh, st}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation(sh <> st, T.ProgressiveList{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.ProgressiveList{z0}, sel), Some{opt}, found)))
                case D.Invalid{}: Unit{}
            case 1n+p:
              match c:
                case D.Region{n, xs}:
                  match value:
                    case T.BooleanValue{b0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ProgressiveList{z0}, T.BooleanValue{b0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BooleanValue{b0}, T.ProgressiveList{z0}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.UnsignedValue{u0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ProgressiveList{z0}, T.UnsignedValue{u0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.UnsignedValue{u0}, T.ProgressiveList{z0}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.BytesValue{y0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ProgressiveList{z0}, T.BytesValue{y0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BytesValue{y0}, T.ProgressiveList{z0}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.BitsValue{q0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ProgressiveList{z0}, T.BitsValue{q0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.BitsValue{q0}, T.ProgressiveList{z0}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.Sequence{i0}:
                      wf => room => legal => phaseok => enc =>
                        CReg.aggregate_elim(region_obligation(T.ProgressiveList{z0}, T.Sequence{i0}, n, xs), SC.parts(i0, T.Repeat{z0}), None{}, List.take(&2, U32, P.slice_bytes(xs), n), enc,
                          qs => partsof => encq =>
                            CReg.progressive_list_region(z0, SC.count(i0), i0, n, xs, qs, wf, room, legal, {==}, partsof, encq,
                              go_complete(T.ProgressiveList{z0}, q, SC.count(i0), D.Walk{True{}, D.Begin{xs}, P.adv(xs, SL.fixed_size(qs)), SL.fixed_size(qs), n, C.CEnd{}}, i0, opt, xs, SL.fixed_size(qs), 0n, [], qs, xs, P.adv(xs, SL.fixed_size(qs)), C.CEnd{})({==}, legal, {==})))
                    case T.Items{i0, i1}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ProgressiveList{z0}, T.Items{i0, i1}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Items{i0, i1}, T.ProgressiveList{z0}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.EmptyItems{}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ProgressiveList{z0}, T.EmptyItems{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.EmptyItems{}, T.ProgressiveList{z0}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.Selected{v0, m0}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ProgressiveList{z0}, T.Selected{v0, m0}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.Selected{v0, m0}, T.ProgressiveList{z0}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                    case T.NullValue{}:
                      wf => room => legal => phaseok => enc =>
                        Empty.absurd(region_obligation(T.ProgressiveList{z0}, T.NullValue{}, n, xs), F.false_true(Equal.cong(Maybe<&2, +List<T.Part>>, Bool, CReg.is_some_parts, SC.parts(T.NullValue{}, T.ProgressiveList{z0}), Some{[SC.fragment(SS.fixed_size(T.ProgressiveList{z0}), List.take(&2, U32, P.slice_bytes(xs), n))]}, enc)))
                case D.Walk{fixed, prior, other, pos, end, acc}:
                  settled => legal => kok =>
                    CStep.seq_step_complete(T.ProgressiveList{z0}, z0, p, fixed, prior, other, acc, sl, end, fixedtotal, h, pos, pdone, ps, hdr, pay, acc2, value, settled, legal, {==},
                      cv0 => n2 => xs2 => wfx2 => roomx2 => hx2 => go_complete(z0, 1n, 0n, D.Region{n2, xs2}, cv0, opt, sl, fixedtotal, h, pdone, ps, hdr, pay, acc2)(wfx2, roomx2, or_right(CReg.is_null(z0), IS.valid_go(z0, False{}), legal), {==}, hx2),
                      h2 => pos2 => pdone2 => ps2 => hdr2 => pay2 => acc3 => value2 => fixed2 => prior2 => other2 => settled2 =>
                        go_complete(T.ProgressiveList{z0}, 1n+q, p, D.Walk{fixed2, prior2, other2, pos2, end, acc2}, value2, opt, sl, fixedtotal, h2, pdone2, ps2, hdr2, pay2, acc3)(settled2, legal, {==}))
                case D.Pick{sel, n, xs}:
                  wf => room => legal => found => enc =>
                    Empty.absurd(pick_obligation(T.ProgressiveList{z0}, 1n+p, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.option(T.ProgressiveList{z0}, 1n+p), Some{opt}, found)))
                case D.PickAmong{selectors, sel, n, xs}:
                  match selectors:
                    case Nil{}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation([], T.ProgressiveList{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option([], T.ProgressiveList{z0}, sel), Some{opt}, found)))
                    case Con{sh, st}:
                      wf => room => legal => found => enc =>
                        Empty.absurd(among_obligation(sh <> st, T.ProgressiveList{z0}, sel, n, xs, value), F.false_true(Equal.cong(Maybe<&2, T.Schema>, Bool, CWalk.is_some_schema, SS.compatible_option(sh <> st, T.ProgressiveList{z0}, sel), Some{opt}, found)))
                case D.Invalid{}: Unit{}
