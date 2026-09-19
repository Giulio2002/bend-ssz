import Base
import ../types/schema.bend as T
import ../src/codec.bend as I
import ../spec/codec.bend as S
import ../spec/schema_forest.bend as Forest
import ./lists.bend as Lists
import ./word_facts.bend as W

# Only well-terminated field forests and Repeat accumulate parts.
def forest(schema: T.Schema) -> Bool:
  match schema:
    case T.Repeat{element}: True{}
    case _: Forest.finite(schema)

def prefix(acc: +List<T.Part>, result: Maybe<&2, +List<T.Part>>) -> Maybe<&2, +List<T.Part>>:
  match result:
    case None{}: None{}
    case Some{parts}: Some{List.reverse.go(&2, T.Part, acc, parts)}

law prefix_accumulate:
  for +parts: +List<T.Part>
  for +acc: +List<T.Part>
  for +tail: Maybe<&2, +List<T.Part>>
  {prefix(List.reverse.go(&2, T.Part, parts, acc), tail) == prefix(acc, S.concatenate(Some{parts}, tail)) : Maybe<&2, +List<T.Part>>}
def prefix_accumulate(parts, acc, tail):
  match tail:
    case None{}: {==}
    case Some{xs}: Equal.cong(+List<T.Part>, Maybe<&2, +List<T.Part>>, ys => Some{ys}, List.reverse.go(&2, T.Part, List.reverse.go(&2, T.Part, parts, acc), xs), List.reverse.go(&2, T.Part, acc, List.append(&2, T.Part, parts, xs)), Lists.reverse_acc(T.Part, parts, acc, xs))

law accumulate_forward:
  for +encoded: Maybe<&2, +List<T.Part>>
  for +acc: +List<T.Part>
  for +tail: Maybe<&2, +List<T.Part>>
  for -next: +List<T.Part> -> Maybe<&2, +List<T.Part>>
  for recur: @+prior: +List<T.Part> -> {next(prior) == prefix(prior, tail) : Maybe<&2, +List<T.Part>>}
  {I.accumulate(encoded, acc, next) == prefix(acc, S.concatenate(encoded, tail)) : Maybe<&2, +List<T.Part>>}
def accumulate_forward(encoded, acc, tail, next, recur):
  match encoded:
    case None{}: {==}
    case Some{parts}: Equal.trans(Maybe<&2, +List<T.Part>>, next(List.reverse.go(&2, T.Part, parts, acc)), prefix(List.reverse.go(&2, T.Part, parts, acc), tail), prefix(acc, S.concatenate(Some{parts}, tail)), recur(List.reverse.go(&2, T.Part, parts, acc)), prefix_accumulate(parts, acc, tail))

law prefix_empty:
  for +result: Maybe<&2, +List<T.Part>>
  {prefix([], result) == result : Maybe<&2, +List<T.Part>>}
def prefix_empty(result):
  match result:
    case None{}: {==}
    case Some{parts}: {==}

law accumulated_prefix:
  for +encoded: Maybe<&2, +List<T.Part>>
  for +acc: +List<T.Part>
  for +tail: Maybe<&2, +List<T.Part>>
  for -next: +List<T.Part> -> Maybe<&2, +List<T.Part>>
  for recur_zero: @+prior: +List<T.Part> -> {next(prior) == prefix(prior, tail) : Maybe<&2, +List<T.Part>>}
  for recur_acc: @+prior: +List<T.Part> -> {next(prior) == prefix(prior, tail) : Maybe<&2, +List<T.Part>>}
  {I.accumulate(encoded, acc, next) == prefix(acc, I.accumulate(encoded, [], next)) : Maybe<&2, +List<T.Part>>}
def accumulated_prefix(encoded, acc, tail, next, recur_zero, recur_acc):
  %Equal.sym(Maybe<&2, +List<T.Part>>, I.accumulate(encoded, [], next), prefix([], S.concatenate(encoded, tail)), accumulate_forward(encoded, [], tail, next, recur_zero)) : {I.accumulate(encoded, acc, next) == prefix(acc, _) : Maybe<&2, +List<T.Part>>}
  %Equal.sym(Maybe<&2, +List<T.Part>>, prefix([], S.concatenate(encoded, tail)), S.concatenate(encoded, tail), prefix_empty(S.concatenate(encoded, tail))) : {I.accumulate(encoded, acc, next) == prefix(acc, _) : Maybe<&2, +List<T.Part>>}
  accumulate_forward(encoded, acc, tail, next, recur_acc)

law impossible:
  for +value: T.Value
  for +schema: T.Schema
  for +acc: +List<T.Part>
  for absurd: {False{} == True{} : Bool}
  {I.encode_go(value, schema, acc) == prefix(acc, I.encode(value, schema)) : Maybe<&2, +List<T.Part>>}
def impossible(value, schema, acc, absurd):
  Empty.absurd({I.encode_go(value, schema, acc) == prefix(acc, I.encode(value, schema)) : Maybe<&2, +List<T.Part>>}, W.false_true(absurd))
# Generated forest cases.
law finite_is_forest:
  for +schema: T.Schema
  for finite: {Forest.finite(schema) == True{} : Bool}
  {forest(schema) == True{} : Bool}
def finite_is_forest(schema, finite):
  match schema:
    case T.Boolean{}: finite
    case T.Unsigned{w}: finite
    case T.ByteVector{n}: finite
    case T.ByteList{n}: finite
    case T.BitVector{n}: finite
    case T.BitList{n}: finite
    case T.Vector{e, n}: finite
    case T.ListOf{e, n}: finite
    case T.Container{names, fields}: finite
    case T.Union{options}: finite
    case T.Null{}: finite
    case T.Chain{h, t}: finite
    case T.End{}: finite
    case T.Repeat{e}: {==}
    case T.Named{name, e}: finite
    case T.ProgressiveList{e}: finite
    case T.ProgressiveBits{}: finite
    case T.ProgressiveContainer{names, fields, active}: finite
    case T.CompatibleUnion{selectors, options}: finite

law forest_accumulator:
  for +value: T.Value
  for +schema: T.Schema
  for +acc: +List<T.Part>
  for +well_formed: {forest(schema) == True{} : Bool}
  {I.encode_go(value, schema, acc) == prefix(acc, I.encode(value, schema)) : Maybe<&2, +List<T.Part>>}
def forest_accumulator(value, schema, acc, well_formed):
  match value:
    case T.BooleanValue{b}:
      match schema:
        case T.Boolean{}: impossible(T.BooleanValue{b}, T.Boolean{}, acc, well_formed)
        case T.Unsigned{s_w}: {==}
        case T.ByteVector{s_n}: {==}
        case T.ByteList{s_n}: {==}
        case T.BitVector{s_n}: {==}
        case T.BitList{s_n}: {==}
        case T.Vector{s_e, s_n}: {==}
        case T.ListOf{s_e, s_n}: {==}
        case T.Container{s_names, s_fields}: {==}
        case T.Union{s_options}: {==}
        case T.Null{}: {==}
        case T.Chain{s_h, s_t}: {==}
        case T.End{}: {==}
        case T.Repeat{s_e}: {==}
        case T.Named{s_name, s_e}: {==}
        case T.ProgressiveList{s_e}: {==}
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{s_names, s_fields, s_active}: {==}
        case T.CompatibleUnion{s_selectors, s_options}: {==}
    case T.UnsignedValue{v}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{s_w}: impossible(T.UnsignedValue{v}, T.Unsigned{s_w}, acc, well_formed)
        case T.ByteVector{s_n}: {==}
        case T.ByteList{s_n}: {==}
        case T.BitVector{s_n}: {==}
        case T.BitList{s_n}: {==}
        case T.Vector{s_e, s_n}: {==}
        case T.ListOf{s_e, s_n}: {==}
        case T.Container{s_names, s_fields}: {==}
        case T.Union{s_options}: {==}
        case T.Null{}: {==}
        case T.Chain{s_h, s_t}: {==}
        case T.End{}: {==}
        case T.Repeat{s_e}: {==}
        case T.Named{s_name, s_e}: {==}
        case T.ProgressiveList{s_e}: {==}
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{s_names, s_fields, s_active}: {==}
        case T.CompatibleUnion{s_selectors, s_options}: {==}
    case T.BytesValue{xs}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{s_w}: {==}
        case T.ByteVector{s_n}: impossible(T.BytesValue{xs}, T.ByteVector{s_n}, acc, well_formed)
        case T.ByteList{s_n}: impossible(T.BytesValue{xs}, T.ByteList{s_n}, acc, well_formed)
        case T.BitVector{s_n}: {==}
        case T.BitList{s_n}: {==}
        case T.Vector{s_e, s_n}: {==}
        case T.ListOf{s_e, s_n}: {==}
        case T.Container{s_names, s_fields}: {==}
        case T.Union{s_options}: {==}
        case T.Null{}: {==}
        case T.Chain{s_h, s_t}: {==}
        case T.End{}: {==}
        case T.Repeat{s_e}: {==}
        case T.Named{s_name, s_e}: {==}
        case T.ProgressiveList{s_e}: {==}
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{s_names, s_fields, s_active}: {==}
        case T.CompatibleUnion{s_selectors, s_options}: {==}
    case T.BitsValue{bs}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{s_w}: {==}
        case T.ByteVector{s_n}: {==}
        case T.ByteList{s_n}: {==}
        case T.BitVector{s_n}: impossible(T.BitsValue{bs}, T.BitVector{s_n}, acc, well_formed)
        case T.BitList{s_n}: impossible(T.BitsValue{bs}, T.BitList{s_n}, acc, well_formed)
        case T.Vector{s_e, s_n}: {==}
        case T.ListOf{s_e, s_n}: {==}
        case T.Container{s_names, s_fields}: {==}
        case T.Union{s_options}: {==}
        case T.Null{}: {==}
        case T.Chain{s_h, s_t}: {==}
        case T.End{}: {==}
        case T.Repeat{s_e}: {==}
        case T.Named{s_name, s_e}: {==}
        case T.ProgressiveList{s_e}: {==}
        case T.ProgressiveBits{}: impossible(T.BitsValue{bs}, T.ProgressiveBits{}, acc, well_formed)
        case T.ProgressiveContainer{s_names, s_fields, s_active}: {==}
        case T.CompatibleUnion{s_selectors, s_options}: {==}
    case T.Sequence{items}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{s_w}: {==}
        case T.ByteVector{s_n}: {==}
        case T.ByteList{s_n}: {==}
        case T.BitVector{s_n}: {==}
        case T.BitList{s_n}: {==}
        case T.Vector{s_e, s_n}: impossible(T.Sequence{items}, T.Vector{s_e, s_n}, acc, well_formed)
        case T.ListOf{s_e, s_n}: impossible(T.Sequence{items}, T.ListOf{s_e, s_n}, acc, well_formed)
        case T.Container{s_names, s_fields}: impossible(T.Sequence{items}, T.Container{s_names, s_fields}, acc, well_formed)
        case T.Union{s_options}: {==}
        case T.Null{}: {==}
        case T.Chain{s_h, s_t}: {==}
        case T.End{}: {==}
        case T.Repeat{s_e}: {==}
        case T.Named{s_name, s_e}: {==}
        case T.ProgressiveList{s_e}: impossible(T.Sequence{items}, T.ProgressiveList{s_e}, acc, well_formed)
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{s_names, s_fields, s_active}: impossible(T.Sequence{items}, T.ProgressiveContainer{s_names, s_fields, s_active}, acc, well_formed)
        case T.CompatibleUnion{s_selectors, s_options}: {==}
    case T.Items{head, tail}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{s_w}: {==}
        case T.ByteVector{s_n}: {==}
        case T.ByteList{s_n}: {==}
        case T.BitVector{s_n}: {==}
        case T.BitList{s_n}: {==}
        case T.Vector{s_e, s_n}: {==}
        case T.ListOf{s_e, s_n}: {==}
        case T.Container{s_names, s_fields}: {==}
        case T.Union{s_options}: {==}
        case T.Null{}: {==}
        case T.Chain{s_h, s_t}: accumulated_prefix(I.encode(head, s_h), acc, I.encode(tail, s_t), prior => I.encode_go(tail, s_t, prior), prior => forest_accumulator(tail, s_t, prior, finite_is_forest(s_t, well_formed)), prior => forest_accumulator(tail, s_t, prior, finite_is_forest(s_t, well_formed)))
        case T.End{}: {==}
        case T.Repeat{s_e}: accumulated_prefix(I.encode(head, s_e), acc, I.encode(tail, T.Repeat{s_e}), prior => I.encode_go(tail, T.Repeat{s_e}, prior), prior => forest_accumulator(tail, T.Repeat{s_e}, prior, {==}), prior => forest_accumulator(tail, T.Repeat{s_e}, prior, {==}))
        case T.Named{s_name, s_e}: {==}
        case T.ProgressiveList{s_e}: {==}
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{s_names, s_fields, s_active}: {==}
        case T.CompatibleUnion{s_selectors, s_options}: {==}
    case T.EmptyItems{}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{s_w}: {==}
        case T.ByteVector{s_n}: {==}
        case T.ByteList{s_n}: {==}
        case T.BitVector{s_n}: {==}
        case T.BitList{s_n}: {==}
        case T.Vector{s_e, s_n}: {==}
        case T.ListOf{s_e, s_n}: {==}
        case T.Container{s_names, s_fields}: {==}
        case T.Union{s_options}: {==}
        case T.Null{}: {==}
        case T.Chain{s_h, s_t}: {==}
        case T.End{}: {==}
        case T.Repeat{s_e}: {==}
        case T.Named{s_name, s_e}: {==}
        case T.ProgressiveList{s_e}: {==}
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{s_names, s_fields, s_active}: {==}
        case T.CompatibleUnion{s_selectors, s_options}: {==}
    case T.Selected{selector, v}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{s_w}: {==}
        case T.ByteVector{s_n}: {==}
        case T.ByteList{s_n}: {==}
        case T.BitVector{s_n}: {==}
        case T.BitList{s_n}: {==}
        case T.Vector{s_e, s_n}: {==}
        case T.ListOf{s_e, s_n}: {==}
        case T.Container{s_names, s_fields}: {==}
        case T.Union{s_options}: impossible(T.Selected{selector, v}, T.Union{s_options}, acc, well_formed)
        case T.Null{}: {==}
        case T.Chain{s_h, s_t}: {==}
        case T.End{}: {==}
        case T.Repeat{s_e}: {==}
        case T.Named{s_name, s_e}: {==}
        case T.ProgressiveList{s_e}: {==}
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{s_names, s_fields, s_active}: {==}
        case T.CompatibleUnion{s_selectors, s_options}: impossible(T.Selected{selector, v}, T.CompatibleUnion{s_selectors, s_options}, acc, well_formed)
    case T.NullValue{}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{s_w}: {==}
        case T.ByteVector{s_n}: {==}
        case T.ByteList{s_n}: {==}
        case T.BitVector{s_n}: {==}
        case T.BitList{s_n}: {==}
        case T.Vector{s_e, s_n}: {==}
        case T.ListOf{s_e, s_n}: {==}
        case T.Container{s_names, s_fields}: {==}
        case T.Union{s_options}: {==}
        case T.Null{}: impossible(T.NullValue{}, T.Null{}, acc, well_formed)
        case T.Chain{s_h, s_t}: {==}
        case T.End{}: {==}
        case T.Repeat{s_e}: {==}
        case T.Named{s_name, s_e}: {==}
        case T.ProgressiveList{s_e}: {==}
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{s_names, s_fields, s_active}: {==}
        case T.CompatibleUnion{s_selectors, s_options}: {==}
