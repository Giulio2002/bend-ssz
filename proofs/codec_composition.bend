import Base
import ../types/schema.bend as T
import ../src/codec.bend as I
import ../src/schema.bend as IS
import ../src/layout.bend as IL
import ../spec/codec.bend as S
import ../spec/schema.bend as SS
import ../spec/schema_forest.bend as F
import ./schema_forest.bend as Forest
import ./schema.bend as Schema
import ./codec_helpers.bend as H
import ./codec_leaves.bend as Leaves
import ./codec_count.bend as Count
import ./codec_accumulator.bend as Acc
import ./primitive_invariants.bend as V

law aggregate_refinement:
  for +actual: Maybe<&2, +List<T.Part>>
  for +expected: Maybe<&2, +List<T.Part>>
  for +width: Maybe<&2, Nat>
  for +spec_width: Maybe<&2, Nat>
  for parts: {actual == expected : Maybe<&2, +List<T.Part>>}
  for widths: {width == spec_width : Maybe<&2, Nat>}
  {I.layout(actual, width) == S.aggregate(expected, spec_width) : Maybe<&2, +List<T.Part>>}
def aggregate_refinement(actual, expected, width, spec_width, parts, widths):
  %parts : {I.layout(actual, width) == S.aggregate(_, spec_width) : Maybe<&2, +List<T.Part>>}
  %widths : {I.layout(actual, width) == S.aggregate(actual, _) : Maybe<&2, +List<T.Part>>}
  H.layout_correct(actual, width)

law gate_refinement:
  for +ok: Bool
  for +spec_ok: Bool
  for -next: Unit -> Maybe<&2, +List<T.Part>>
  for +expected: Maybe<&2, +List<T.Part>>
  for condition: {ok == spec_ok : Bool}
  for body: {next(Unit{}) == expected : Maybe<&2, +List<T.Part>>}
  {I.gate(ok, next) == S.require(spec_ok, expected) : Maybe<&2, +List<T.Part>>}
def gate_refinement(ok, spec_ok, next, expected, condition, body):
  %condition : {I.gate(ok, next) == S.require(_, expected) : Maybe<&2, +List<T.Part>>}
  %body : {I.gate(ok, next) == S.require(ok, _) : Maybe<&2, +List<T.Part>>}
  H.gate_correct(ok, next)

law tagged_refinement:
  for +selector: U32
  for +actual: Maybe<&2, +List<T.Part>>
  for +expected: Maybe<&2, +List<T.Part>>
  for body: {actual == expected : Maybe<&2, +List<T.Part>>}
  {I.wrap(IL.append(Some{[selector]}, I.unwrap(actual)), None{}) == S.tagged(selector, expected) : Maybe<&2, +List<T.Part>>}
def tagged_refinement(selector, actual, expected, body):
  %body : {I.wrap(IL.append(Some{[selector]}, I.unwrap(actual)), None{}) == S.tagged(selector, _) : Maybe<&2, +List<T.Part>>}
  H.tagged_correct(selector, actual)

def selected_well_formed(result: Maybe<&2, T.Schema>) -> Type:
  match result:
    case None{}: Unit
    case Some{s}: {F.well_formed(s) == True{} : Bool}

law with_schema_refinement:
  for +option: Maybe<&2, T.Schema>
  for -actual: T.Schema -> Maybe<&2, +List<T.Part>>
  for -expected: T.Schema -> Maybe<&2, +List<T.Part>>
  for well_formed: selected_well_formed(option)
  for body: @+schema: T.Schema -> {F.well_formed(schema) == True{} : Bool} -> {actual(schema) == expected(schema) : Maybe<&2, +List<T.Part>>}
  {I.with_schema(option, actual) == S.with_option(option, expected) : Maybe<&2, +List<T.Part>>}
def with_schema_refinement(option, actual, expected, well_formed, body):
  match option:
    case None{}: {==}
    case Some{s}: body(s, well_formed)

law select_well_formed:
  for +ok: Bool
  for +schema: T.Schema
  for -next: Unit -> Maybe<&2, T.Schema>
  for head: {F.well_formed(schema) == True{} : Bool}
  for tail: selected_well_formed(next(Unit{}))
  selected_well_formed(I.select_option(ok, schema, next))
def select_well_formed(ok, schema, next, head, tail):
  match ok:
    case False{}: tail
    case True{}: head

law forest_step:
  for +head: T.Value
  for +tail: T.Value
  for +element: T.Schema
  for +rest: T.Schema
  for +well_formed: {Acc.forest(rest) == True{} : Bool}
  for head_refines: {I.encode(head, element) == S.parts(head, element) : Maybe<&2, +List<T.Part>>}
  for tail_refines: {I.encode(tail, rest) == S.parts(tail, rest) : Maybe<&2, +List<T.Part>>}
  {I.accumulate(I.encode(head, element), [], prior => I.encode_go(tail, rest, prior)) == S.concatenate(S.parts(head, element), S.parts(tail, rest)) : Maybe<&2, +List<T.Part>>}
def forest_step(head, tail, element, rest, well_formed, head_refines, tail_refines):
  %head_refines : {I.accumulate(I.encode(head, element), [], prior => I.encode_go(tail, rest, prior)) == S.concatenate(_, S.parts(tail, rest)) : Maybe<&2, +List<T.Part>>}
  %tail_refines : {I.accumulate(I.encode(head, element), [], prior => I.encode_go(tail, rest, prior)) == S.concatenate(I.encode(head, element), _) : Maybe<&2, +List<T.Part>>}
  Equal.trans(Maybe<&2, +List<T.Part>>, I.accumulate(I.encode(head, element), [], prior => I.encode_go(tail, rest, prior)), Acc.prefix([], S.concatenate(I.encode(head, element), I.encode(tail, rest))), S.concatenate(I.encode(head, element), I.encode(tail, rest)), Acc.accumulate_forward(I.encode(head, element), [], I.encode(tail, rest), prior => I.encode_go(tail, rest, prior), prior => Acc.forest_accumulator(tail, rest, prior, well_formed)), Acc.prefix_empty(S.concatenate(I.encode(head, element), I.encode(tail, rest))))
# Generated recursive composition.
law option_well_formed:
  for +options: T.Schema
  for +index: Nat
  for +well_formed: {F.well_formed(options) == True{} : Bool}
  selected_well_formed(IS.get(options, index))
def option_well_formed(options, index, well_formed):
  match options:
    case T.Chain{h, t}:
      match index:
        case 0n: Forest.chain_head_well_formed(h, t, well_formed)
        case 1n+p: option_well_formed(t, p, Forest.chain_tail_well_formed(h, t, well_formed))
    case T.Boolean{}: Unit{}
    case T.Unsigned{w}: Unit{}
    case T.ByteVector{n}: Unit{}
    case T.ByteList{n}: Unit{}
    case T.BitVector{n}: Unit{}
    case T.BitList{n}: Unit{}
    case T.Vector{e, n}: Unit{}
    case T.ListOf{e, n}: Unit{}
    case T.Container{names, fields}: Unit{}
    case T.Union{options}: Unit{}
    case T.Null{}: Unit{}
    case T.End{}: Unit{}
    case T.Repeat{e}: Unit{}
    case T.Named{name, e}: Unit{}
    case T.ProgressiveList{e}: Unit{}
    case T.ProgressiveBits{}: Unit{}
    case T.ProgressiveContainer{names, fields, active}: Unit{}
    case T.CompatibleUnion{selectors, options}: Unit{}

law selected_schema_well_formed:
  for +selectors: +List<U32>
  for +options: T.Schema
  for +selector: U32
  for +well_formed: {F.well_formed(options) == True{} : Bool}
  selected_well_formed(I.selected_schema(selectors, options, selector))
def selected_schema_well_formed(selectors, options, selector, well_formed):
  match selectors:
    case Nil{}: Unit{}
    case Con{a, tail}:
      match options:
        case T.Chain{h, t}: select_well_formed(U32.is_eq(a, selector), h, u => I.selected_schema(tail, t, selector), Forest.chain_head_well_formed(h, t, well_formed), selected_schema_well_formed(tail, t, selector, Forest.chain_tail_well_formed(h, t, well_formed)))
        case T.Boolean{}: Unit{}
        case T.Unsigned{w}: Unit{}
        case T.ByteVector{n}: Unit{}
        case T.ByteList{n}: Unit{}
        case T.BitVector{n}: Unit{}
        case T.BitList{n}: Unit{}
        case T.Vector{e, n}: Unit{}
        case T.ListOf{e, n}: Unit{}
        case T.Container{names, fields}: Unit{}
        case T.Union{options}: Unit{}
        case T.Null{}: Unit{}
        case T.End{}: Unit{}
        case T.Repeat{e}: Unit{}
        case T.Named{name, e}: Unit{}
        case T.ProgressiveList{e}: Unit{}
        case T.ProgressiveBits{}: Unit{}
        case T.ProgressiveContainer{names, fields, active}: Unit{}
        case T.CompatibleUnion{selectors, options}: Unit{}

law parts_correct:
  for +value: T.Value
  for +schema: T.Schema
  for +well_formed: {F.well_formed(schema) == True{} : Bool}
  {I.encode(value, schema) == S.parts(value, schema) : Maybe<&2, +List<T.Part>>}
def parts_correct(value, schema, well_formed):
  match value:
    case T.BooleanValue{b}: Leaves.boolean_parts_correct(b, schema, [])
    case T.UnsignedValue{v}: Leaves.unsigned_parts_correct(v, schema, [])
    case T.BytesValue{xs}: Leaves.bytes_parts_correct(xs, schema, [])
    case T.BitsValue{bs}: Leaves.bits_parts_correct(bs, schema, [])
    case T.Sequence{items}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{w}: {==}
        case T.ByteVector{n}: {==}
        case T.ByteList{n}: {==}
        case T.BitVector{n}: {==}
        case T.BitList{n}: {==}
        case T.Vector{e, n}: gate_refinement(Bool.and(Nat.is_lt(0n, n), Nat.is_eq(I.count(items), n)), Bool.and(Nat.is_lt(0n, n), Nat.is_eq(S.count(items), n)), u => I.layout(I.encode(items, T.Repeat{e}), IS.scale_size(n, IS.fixed_size(e))), S.aggregate(S.parts(items, T.Repeat{e}), SS.times(n, SS.fixed_size(e))), Equal.cong(Nat, Bool, k => Bool.and(Nat.is_lt(0n, n), Nat.is_eq(k, n)), I.count(items), S.count(items), Count.count_correct(items)), aggregate_refinement(I.encode(items, T.Repeat{e}), S.parts(items, T.Repeat{e}), IS.scale_size(n, IS.fixed_size(e)), SS.times(n, SS.fixed_size(e)), parts_correct(items, T.Repeat{e}, well_formed), Equal.trans(Maybe<&2, Nat>, IS.scale_size(n, IS.fixed_size(e)), IS.scale_size(n, SS.fixed_size(e)), SS.times(n, SS.fixed_size(e)), Equal.cong(Maybe<&2, Nat>, Maybe<&2, Nat>, w => IS.scale_size(n, w), IS.fixed_size(e), SS.fixed_size(e), Schema.fixed_size_correct(e)), Schema.times_correct(n, SS.fixed_size(e)))))
        case T.ListOf{e, n}: gate_refinement(Nat.is_le(I.count(items), n), Nat.is_le(S.count(items), n), u => I.layout(I.encode(items, T.Repeat{e}), None{}), S.aggregate(S.parts(items, T.Repeat{e}), None{}), Equal.cong(Nat, Bool, k => Nat.is_le(k, n), I.count(items), S.count(items), Count.count_correct(items)), aggregate_refinement(I.encode(items, T.Repeat{e}), S.parts(items, T.Repeat{e}), None{}, None{}, parts_correct(items, T.Repeat{e}, well_formed), {==}))
        case T.Container{names, fields}: aggregate_refinement(I.encode(items, fields), S.parts(items, fields), IS.fixed_size(fields), SS.fixed_size(fields), parts_correct(items, fields, V.and_right(F.finite(fields), F.well_formed(fields), well_formed)), Schema.fixed_size_correct(fields))
        case T.Union{options}: {==}
        case T.Null{}: {==}
        case T.Chain{h, t}: {==}
        case T.End{}: {==}
        case T.Repeat{e}: {==}
        case T.Named{name, e}: {==}
        case T.ProgressiveList{e}: aggregate_refinement(I.encode(items, T.Repeat{e}), S.parts(items, T.Repeat{e}), None{}, None{}, parts_correct(items, T.Repeat{e}, well_formed), {==})
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{names, fields, active}: aggregate_refinement(I.encode(items, fields), S.parts(items, fields), IS.fixed_size(fields), SS.fixed_size(fields), parts_correct(items, fields, V.and_right(F.finite(fields), F.well_formed(fields), well_formed)), Schema.fixed_size_correct(fields))
        case T.CompatibleUnion{selectors, options}: {==}
    case T.Items{head, tail}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{w}: {==}
        case T.ByteVector{n}: {==}
        case T.ByteList{n}: {==}
        case T.BitVector{n}: {==}
        case T.BitList{n}: {==}
        case T.Vector{e, n}: {==}
        case T.ListOf{e, n}: {==}
        case T.Container{names, fields}: {==}
        case T.Union{options}: {==}
        case T.Null{}: {==}
        case T.Chain{h, t}: forest_step(head, tail, h, t, Acc.finite_is_forest(t, Forest.chain_tail_finite(h, t, well_formed)), parts_correct(head, h, Forest.chain_head_well_formed(h, t, well_formed)), parts_correct(tail, t, Forest.chain_tail_well_formed(h, t, well_formed)))
        case T.End{}: {==}
        case T.Repeat{e}: forest_step(head, tail, e, T.Repeat{e}, {==}, parts_correct(head, e, well_formed), parts_correct(tail, T.Repeat{e}, well_formed))
        case T.Named{name, e}: {==}
        case T.ProgressiveList{e}: {==}
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{names, fields, active}: {==}
        case T.CompatibleUnion{selectors, options}: {==}
    case T.EmptyItems{}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{w}: {==}
        case T.ByteVector{n}: {==}
        case T.ByteList{n}: {==}
        case T.BitVector{n}: {==}
        case T.BitList{n}: {==}
        case T.Vector{e, n}: {==}
        case T.ListOf{e, n}: {==}
        case T.Container{names, fields}: {==}
        case T.Union{options}: {==}
        case T.Null{}: {==}
        case T.Chain{h, t}: {==}
        case T.End{}: {==}
        case T.Repeat{e}: {==}
        case T.Named{name, e}: {==}
        case T.ProgressiveList{e}: {==}
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{names, fields, active}: {==}
        case T.CompatibleUnion{selectors, options}: {==}
    case T.Selected{selector, v}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{w}: {==}
        case T.ByteVector{n}: {==}
        case T.ByteList{n}: {==}
        case T.BitVector{n}: {==}
        case T.BitList{n}: {==}
        case T.Vector{e, n}: {==}
        case T.ListOf{e, n}: {==}
        case T.Container{names, fields}: {==}
        case T.Union{options}:
          %Schema.option_correct(options, U32.to_nat(selector)) : {I.encode(T.Selected{selector, v}, T.Union{options}) == S.with_option(_, s => S.tagged(selector, S.parts(v, s))) : Maybe<&2, +List<T.Part>>}
          with_schema_refinement(IS.get(options, U32.to_nat(selector)), s => I.wrap(IL.append(Some{[selector]}, I.unwrap(I.encode(v, s))), None{}), s => S.tagged(selector, S.parts(v, s)), option_well_formed(options, U32.to_nat(selector), V.and_right(F.finite(options), F.well_formed(options), well_formed)), s => proper => tagged_refinement(selector, I.encode(v, s), S.parts(v, s), parts_correct(v, s, proper)))
        case T.Null{}: {==}
        case T.Chain{h, t}: {==}
        case T.End{}: {==}
        case T.Repeat{e}: {==}
        case T.Named{name, e}: {==}
        case T.ProgressiveList{e}: {==}
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{names, fields, active}: {==}
        case T.CompatibleUnion{selectors, options}:
          %H.selected_schema_correct(selectors, options, selector) : {I.encode(T.Selected{selector, v}, T.CompatibleUnion{selectors, options}) == S.with_option(_, s => S.tagged(selector, S.parts(v, s))) : Maybe<&2, +List<T.Part>>}
          with_schema_refinement(I.selected_schema(selectors, options, selector), s => I.wrap(IL.append(Some{[selector]}, I.unwrap(I.encode(v, s))), None{}), s => S.tagged(selector, S.parts(v, s)), selected_schema_well_formed(selectors, options, selector, V.and_right(F.finite(options), F.well_formed(options), well_formed)), s => proper => tagged_refinement(selector, I.encode(v, s), S.parts(v, s), parts_correct(v, s, proper)))
    case T.NullValue{}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{w}: {==}
        case T.ByteVector{n}: {==}
        case T.ByteList{n}: {==}
        case T.BitVector{n}: {==}
        case T.BitList{n}: {==}
        case T.Vector{e, n}: {==}
        case T.ListOf{e, n}: {==}
        case T.Container{names, fields}: {==}
        case T.Union{options}: {==}
        case T.Null{}: {==}
        case T.Chain{h, t}: {==}
        case T.End{}: {==}
        case T.Repeat{e}: {==}
        case T.Named{name, e}: {==}
        case T.ProgressiveList{e}: {==}
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{names, fields, active}: {==}
        case T.CompatibleUnion{selectors, options}: {==}

# Every structural helper premise is discharged by the public type validator.
# Its independent normative legality equivalence remains a separate obligation.
law serialize_for_valid_type:
  for +schema: T.Schema
  for +value: T.Value
  for +legal: {IS.valid(schema) == True{} : Bool}
  {I.serialize(schema, value) == S.encoding_for_legal_type(schema, value) : Maybe<&2, +List<U32>>}
def serialize_for_valid_type(schema, value, legal):
  %Equal.sym(Bool, IS.valid(schema), True{}, legal) : {I.unwrap(I.gate(_, u => I.encode(value, schema))) == S.encoding_for_legal_type(schema, value) : Maybe<&2, +List<U32>>}
  %parts_correct(value, schema, Forest.valid_well_formed(schema, False{}, legal)) : {I.unwrap(I.encode(value, schema)) == S.bytes(_) : Maybe<&2, +List<U32>>}
  H.unwrap_correct(I.encode(value, schema))
