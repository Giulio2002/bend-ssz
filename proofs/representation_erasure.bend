import Base
import ../types/schema.bend as T
import ../spec/schema.bend as Schema
import ../spec/representation.bend as S

def erase_option(option: Maybe<&2, T.Schema>) -> Maybe<&2, T.Schema>:
  match option:
    case None{}: None{}
    case Some{s}: Some{S.erase(s)}

law selected_erases:
  for +ok: Bool
  for +s: T.Schema
  for +tail: Maybe<&2, T.Schema>
  {Schema.selected(ok, S.erase(s), erase_option(tail)) == erase_option(Schema.selected(ok, s, tail)) : Maybe<&2, T.Schema>}
def selected_erases(ok, s, tail):
  match ok:
    case False{}: {==}
    case True{}: {==}

# Generated lookup erasure and structural value proof.
law option_erases:
  for +schema: T.Schema
  for +index: Nat
  {Schema.option(S.erase(schema), index) == erase_option(Schema.option(schema, index)) : Maybe<&2, T.Schema>}
def option_erases(schema, index):
  match schema:
    case T.Boolean{}:
      {==}
    case T.Unsigned{s0}:
      {==}
    case T.ByteVector{s0}:
      {==}
    case T.ByteList{s0}:
      {==}
    case T.BitVector{s0}:
      {==}
    case T.BitList{s0}:
      {==}
    case T.Vector{s0, s1}:
      {==}
    case T.ListOf{s0, s1}:
      {==}
    case T.Container{s0, s1}:
      {==}
    case T.Union{s0}:
      {==}
    case T.Null{}:
      {==}
    case T.Chain{s0, s1}:
      match index:
        case 0n: {==}
        case 1n+p: option_erases(s1, p)
    case T.End{}:
      {==}
    case T.Repeat{s0}:
      {==}
    case T.Named{s0, s1}:
      {==}
    case T.ProgressiveList{s0}:
      {==}
    case T.ProgressiveBits{}:
      {==}
    case T.ProgressiveContainer{s0, s1, s2}:
      {==}
    case T.CompatibleUnion{s0, s1}:
      {==}

law compatible_option_erases:
  for +selectors: +List<U32>
  for +schema: T.Schema
  for +selector: U32
  {Schema.compatible_option(selectors, S.erase(schema), selector) == erase_option(Schema.compatible_option(selectors, schema, selector)) : Maybe<&2, T.Schema>}
def compatible_option_erases(selectors, schema, selector):
  match selectors:
    case Nil{}: {==}
    case Con{s, ss}:
      match schema:
        case T.Boolean{}:
          {==}
        case T.Unsigned{+s0}:
          {==}
        case T.ByteVector{+s0}:
          {==}
        case T.ByteList{+s0}:
          {==}
        case T.BitVector{+s0}:
          {==}
        case T.BitList{+s0}:
          {==}
        case T.Vector{+s0, +s1}:
          {==}
        case T.ListOf{+s0, +s1}:
          {==}
        case T.Container{+s0, +s1}:
          {==}
        case T.Union{+s0}:
          {==}
        case T.Null{}:
          {==}
        case T.Chain{+s0, +s1}:
          %Equal.sym(Maybe<&2, T.Schema>, Schema.compatible_option(ss, S.erase(s1), selector), erase_option(Schema.compatible_option(ss, s1, selector)), compatible_option_erases(ss, s1, selector)) : {Schema.selected(U32.is_eq(s, selector), S.erase(s0), _) == erase_option(Schema.compatible_option(s <> ss, T.Chain{s0, s1}, selector)) : Maybe<&2, T.Schema>}
          selected_erases(U32.is_eq(s, selector), s0, Schema.compatible_option(ss, s1, selector))
        case T.End{}:
          {==}
        case T.Repeat{+s0}:
          {==}
        case T.Named{+s0, +s1}:
          {==}
        case T.ProgressiveList{+s0}:
          {==}
        case T.ProgressiveBits{}:
          {==}
        case T.ProgressiveContainer{+s0, +s1, +s2}:
          {==}
        case T.CompatibleUnion{+s0, +s1}:
          {==}

law and_equal:
  for +a: Bool
  for +b: Bool
  for +c: Bool
  for +d: Bool
  for ea: {a == c : Bool}
  for eb: {b == d : Bool}
  {Bool.and(a, b) == Bool.and(c, d) : Bool}
def and_equal(a, b, c, d, ea, eb):
  %ea : {Bool.and(a, b) == Bool.and(_, d) : Bool}
  %eb : {Bool.and(a, b) == Bool.and(a, _) : Bool}
  {==}

law selected_shape:
  for +option: Maybe<&2, T.Schema>
  for +value: T.Value
  for recur: @+s: T.Schema -> {S.shape(value, s) == S.shape(value, S.erase(s)) : Bool}
  {S.selected(option, s => S.shape(value, s)) == S.selected(erase_option(option), s => S.shape(value, s)) : Bool}
def selected_shape(option, value, recur):
  match option:
    case None{}: {==}
    case Some{s}: recur(s)

law selected_lookup:
  for +option: Maybe<&2, T.Schema>
  for +erased: Maybe<&2, T.Schema>
  for +value: T.Value
  for lookup: {erased == erase_option(option) : Maybe<&2, T.Schema>}
  for recur: @+s: T.Schema -> {S.shape(value, s) == S.shape(value, S.erase(s)) : Bool}
  {S.selected(option, s => S.shape(value, s)) == S.selected(erased, s => S.shape(value, s)) : Bool}
def selected_lookup(option, erased, value, lookup, recur):
  %Equal.sym(Maybe<&2, T.Schema>, erased, erase_option(option), lookup) : {S.selected(option, s => S.shape(value, s)) == S.selected(_, s => S.shape(value, s)) : Bool}
  selected_shape(option, value, recur)

law shape_erases:
  for +value: T.Value
  for +schema: T.Schema
  {S.shape(value, schema) == S.shape(value, S.erase(schema)) : Bool}
def shape_erases(value, schema):
  match value:
    case T.BooleanValue{+v}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{+s0}: {==}
        case T.ByteVector{+s0}: {==}
        case T.ByteList{+s0}: {==}
        case T.BitVector{+s0}: {==}
        case T.BitList{+s0}: {==}
        case T.Vector{+s0, +s1}: {==}
        case T.ListOf{+s0, +s1}: {==}
        case T.Container{+s0, +s1}: {==}
        case T.Union{+s0}: {==}
        case T.Null{}: {==}
        case T.Chain{+s0, +s1}: {==}
        case T.End{}: {==}
        case T.Repeat{+s0}: {==}
        case T.Named{+s0, +s1}: {==}
        case T.ProgressiveList{+s0}: {==}
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{+s0, +s1, +s2}: {==}
        case T.CompatibleUnion{+s0, +s1}: {==}
    case T.UnsignedValue{+v}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{+s0}: {==}
        case T.ByteVector{+s0}: {==}
        case T.ByteList{+s0}: {==}
        case T.BitVector{+s0}: {==}
        case T.BitList{+s0}: {==}
        case T.Vector{+s0, +s1}: {==}
        case T.ListOf{+s0, +s1}: {==}
        case T.Container{+s0, +s1}: {==}
        case T.Union{+s0}: {==}
        case T.Null{}: {==}
        case T.Chain{+s0, +s1}: {==}
        case T.End{}: {==}
        case T.Repeat{+s0}: {==}
        case T.Named{+s0, +s1}: {==}
        case T.ProgressiveList{+s0}: {==}
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{+s0, +s1, +s2}: {==}
        case T.CompatibleUnion{+s0, +s1}: {==}
    case T.BytesValue{+v}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{+s0}: {==}
        case T.ByteVector{+s0}: {==}
        case T.ByteList{+s0}: {==}
        case T.BitVector{+s0}: {==}
        case T.BitList{+s0}: {==}
        case T.Vector{+s0, +s1}: {==}
        case T.ListOf{+s0, +s1}: {==}
        case T.Container{+s0, +s1}: {==}
        case T.Union{+s0}: {==}
        case T.Null{}: {==}
        case T.Chain{+s0, +s1}: {==}
        case T.End{}: {==}
        case T.Repeat{+s0}: {==}
        case T.Named{+s0, +s1}: {==}
        case T.ProgressiveList{+s0}: {==}
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{+s0, +s1, +s2}: {==}
        case T.CompatibleUnion{+s0, +s1}: {==}
    case T.BitsValue{+v}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{+s0}: {==}
        case T.ByteVector{+s0}: {==}
        case T.ByteList{+s0}: {==}
        case T.BitVector{+s0}: {==}
        case T.BitList{+s0}: {==}
        case T.Vector{+s0, +s1}: {==}
        case T.ListOf{+s0, +s1}: {==}
        case T.Container{+s0, +s1}: {==}
        case T.Union{+s0}: {==}
        case T.Null{}: {==}
        case T.Chain{+s0, +s1}: {==}
        case T.End{}: {==}
        case T.Repeat{+s0}: {==}
        case T.Named{+s0, +s1}: {==}
        case T.ProgressiveList{+s0}: {==}
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{+s0, +s1, +s2}: {==}
        case T.CompatibleUnion{+s0, +s1}: {==}
    case T.NullValue{}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{+s0}: {==}
        case T.ByteVector{+s0}: {==}
        case T.ByteList{+s0}: {==}
        case T.BitVector{+s0}: {==}
        case T.BitList{+s0}: {==}
        case T.Vector{+s0, +s1}: {==}
        case T.ListOf{+s0, +s1}: {==}
        case T.Container{+s0, +s1}: {==}
        case T.Union{+s0}: {==}
        case T.Null{}: {==}
        case T.Chain{+s0, +s1}: {==}
        case T.End{}: {==}
        case T.Repeat{+s0}: {==}
        case T.Named{+s0, +s1}: {==}
        case T.ProgressiveList{+s0}: {==}
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{+s0, +s1, +s2}: {==}
        case T.CompatibleUnion{+s0, +s1}: {==}
    case T.EmptyItems{}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{+s0}: {==}
        case T.ByteVector{+s0}: {==}
        case T.ByteList{+s0}: {==}
        case T.BitVector{+s0}: {==}
        case T.BitList{+s0}: {==}
        case T.Vector{+s0, +s1}: {==}
        case T.ListOf{+s0, +s1}: {==}
        case T.Container{+s0, +s1}: {==}
        case T.Union{+s0}: {==}
        case T.Null{}: {==}
        case T.Chain{+s0, +s1}: {==}
        case T.End{}: {==}
        case T.Repeat{+s0}: {==}
        case T.Named{+s0, +s1}: {==}
        case T.ProgressiveList{+s0}: {==}
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{+s0, +s1, +s2}: {==}
        case T.CompatibleUnion{+s0, +s1}: {==}
    case T.Items{+h, +t}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{+s0}: {==}
        case T.ByteVector{+s0}: {==}
        case T.ByteList{+s0}: {==}
        case T.BitVector{+s0}: {==}
        case T.BitList{+s0}: {==}
        case T.Vector{+s0, +s1}: {==}
        case T.ListOf{+s0, +s1}: {==}
        case T.Container{+s0, +s1}: {==}
        case T.Union{+s0}: {==}
        case T.Null{}: {==}
        case T.Chain{+s0, +s1}: and_equal(S.shape(h, s0), S.shape(t, s1), S.shape(h, S.erase(s0)), S.shape(t, S.erase(s1)), shape_erases(h, s0), shape_erases(t, s1))
        case T.End{}: {==}
        case T.Repeat{+s0}: and_equal(S.shape(h, s0), S.shape(t, T.Repeat{s0}), S.shape(h, S.erase(s0)), S.shape(t, S.erase(T.Repeat{s0})), shape_erases(h, s0), shape_erases(t, T.Repeat{s0}))
        case T.Named{+s0, +s1}: {==}
        case T.ProgressiveList{+s0}: {==}
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{+s0, +s1, +s2}: {==}
        case T.CompatibleUnion{+s0, +s1}: {==}
    case T.Sequence{+items}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{+s0}: {==}
        case T.ByteVector{+s0}: {==}
        case T.ByteList{+s0}: {==}
        case T.BitVector{+s0}: {==}
        case T.BitList{+s0}: {==}
        case T.Vector{+s0, +s1}: shape_erases(items, T.Repeat{s0})
        case T.ListOf{+s0, +s1}: shape_erases(items, T.Repeat{s0})
        case T.Container{+s0, +s1}: shape_erases(items, s1)
        case T.Union{+s0}: {==}
        case T.Null{}: {==}
        case T.Chain{+s0, +s1}: {==}
        case T.End{}: {==}
        case T.Repeat{+s0}: {==}
        case T.Named{+s0, +s1}: {==}
        case T.ProgressiveList{+s0}: shape_erases(items, T.Repeat{s0})
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{+s0, +s1, +s2}: shape_erases(items, s1)
        case T.CompatibleUnion{+s0, +s1}: {==}
    case T.Selected{+selector, +v}:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{+s0}: {==}
        case T.ByteVector{+s0}: {==}
        case T.ByteList{+s0}: {==}
        case T.BitVector{+s0}: {==}
        case T.BitList{+s0}: {==}
        case T.Vector{+s0, +s1}: {==}
        case T.ListOf{+s0, +s1}: {==}
        case T.Container{+s0, +s1}: {==}
        case T.Union{+s0}: selected_lookup(Schema.option(s0, U32.to_nat(selector)), Schema.option(S.erase(s0), U32.to_nat(selector)), v, option_erases(s0, U32.to_nat(selector)), s => shape_erases(v, s))
        case T.Null{}: {==}
        case T.Chain{+s0, +s1}: {==}
        case T.End{}: {==}
        case T.Repeat{+s0}: {==}
        case T.Named{+s0, +s1}: {==}
        case T.ProgressiveList{+s0}: {==}
        case T.ProgressiveBits{}: {==}
        case T.ProgressiveContainer{+s0, +s1, +s2}: {==}
        case T.CompatibleUnion{+s0, +s1}: selected_lookup(Schema.compatible_option(s0, s1, selector), Schema.compatible_option(s0, S.erase(s1), selector), v, compatible_option_erases(s0, s1, selector), s => shape_erases(v, s))


law shape_erased_true:
  for +value: T.Value
  for +schema: T.Schema
  for valid: {S.shape(value, schema) == True{} : Bool}
  {S.shape(value, S.erase(schema)) == True{} : Bool}
def shape_erased_true(value, schema, valid):
  Equal.trans(Bool, S.shape(value, S.erase(schema)), S.shape(value, schema), True{}, Equal.sym(Bool, S.shape(value, schema), S.shape(value, S.erase(schema)), shape_erases(value, schema)), valid)
