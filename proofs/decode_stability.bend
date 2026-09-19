import Base
import ../types/schema.bend as T
import ../src/decode.bend as I
import ../src/schema.bend as S
import ../src/codec.bend as C
import ../src/layout.bend as L
import ../src/lists.bend as Lists
import ../spec/schema_forest.bend as F
import ./decode_rank.bend as R
import ./decode_inputs.bend as Inputs
import ./decode_congruence.bend as Cong
import ./decode_selection_bound.bend as Selection
import ./schema_selection_shape.bend as SelectionShape
import ./schema_forest.bend as Forest
import ./compatibility_rank.bend as Children
import ./layout_bounds.bend as B
import ./nat_order.bend as O
import ./primitive_invariants.bend as V
import ./word_facts.bend as W
import ./lists.bend as ListProof

# The rank decreases along every reachable call. Bounds are propagated from
# the real layout decoder and option selectors, not assumed codec correctness.
law stable:
  for +fuel: Nat
  for +extra: Nat
  for +maximum: Nat
  for +schema: T.Schema
  for +xs: +List<U32>
  for +parts: +List<+List<U32>>
  for +acc: T.Value
  for +shape: {F.well_formed(schema) == True{} : Bool}
  for +input: {Nat.is_le(List.length(&2, U32, xs), maximum) == True{} : Bool}
  for slices: B.slices(maximum, parts)
  for +enough: {Nat.is_le(R.rank(schema, parts, maximum), fuel) == True{} : Bool}
  {I.decode_go(fuel, schema, xs, parts, acc) == I.decode_go(Nat.add(fuel, extra), schema, xs, parts, acc) : Maybe<&2, T.Value>}
def stable(fuel, extra, maximum, schema, xs, parts, acc, shape, input, slices, enough):
  match fuel:
    case 0n: Empty.absurd({I.decode_go(0n, schema, xs, parts, acc) == I.decode_go(extra, schema, xs, parts, acc) : Maybe<&2, T.Value>}, W.false_true(O.transitive(1n, R.rank(schema, parts, maximum), 0n, R.positive(schema, parts, maximum), enough)))
    case 1n+p:
      match schema:
        case T.Boolean{}: {==}
        case T.Unsigned{w}: {==}
        case T.ByteVector{n}: {==}
        case T.ByteList{n}: {==}
        case T.BitVector{n}: {==}
        case T.BitList{n}: {==}
        case T.ProgressiveBits{}: {==}
        case T.Named{name, child}: {==}
        case T.Null{}:
          match xs:
            case Nil{}: {==}
            case Con{h, t}: {==}
        case T.End{}:
          match parts:
            case Nil{}: {==}
            case Con{h, t}: {==}
        case T.Chain{h, t}:
          match parts:
            case Nil{}: {==}
            case Con{first, rest}:
              (head_bound, tail_bounds) = slices
              Cong.accumulate(I.decode_go(p, h, first, [], T.EmptyItems{}), I.decode_go(Nat.add(p, extra), h, first, [], T.EmptyItems{}), acc, next => I.decode_go(p, t, [], rest, next), next => I.decode_go(Nat.add(p, extra), t, [], rest, next), stable(p, extra, maximum, h, first, [], T.EmptyItems{}, Forest.chain_head_well_formed(h, t, shape), head_bound, Unit{}, R.child_budget(R.rank(h, [], maximum), R.rank(T.Chain{h, t}, first <> rest, maximum), p, R.child_step(h, T.Chain{h, t}, maximum, Children.chain_head(h, t)), enough)), next => stable(p, extra, maximum, t, [], rest, next, Forest.chain_tail_well_formed(h, t, shape), O.zero_le(maximum), tail_bounds, R.child_budget(R.rank(t, rest, maximum), R.rank(T.Chain{h, t}, first <> rest, maximum), p, O.transitive(1n+R.rank(t, rest, maximum), 1n+R.regular(t, maximum), R.regular(T.Chain{h, t}, maximum), R.finite_bound(t, rest, maximum, Forest.chain_tail_finite(h, t, shape)), R.regular_step(t, T.Chain{h, t}, maximum, Children.chain_tail(h, t))), enough)))
        case T.Repeat{e}:
          match parts:
            case Nil{}: {==}
            case Con{first, rest}:
              (head_bound, tail_bounds) = slices
              Cong.accumulate(I.decode_go(p, e, first, [], T.EmptyItems{}), I.decode_go(Nat.add(p, extra), e, first, [], T.EmptyItems{}), acc, next => I.decode_go(p, T.Repeat{e}, [], rest, next), next => I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], rest, next), stable(p, extra, maximum, e, first, [], T.EmptyItems{}, shape, head_bound, Unit{}, R.child_budget(R.rank(e, [], maximum), R.rank(T.Repeat{e}, first <> rest, maximum), p, R.repeat_head(e, first, rest, maximum), enough)), next => stable(p, extra, maximum, T.Repeat{e}, [], rest, next, shape, O.zero_le(maximum), tail_bounds, R.child_budget(R.rank(T.Repeat{e}, rest, maximum), R.rank(T.Repeat{e}, first <> rest, maximum), p, R.repeat_tail(e, first, rest, maximum), enough)))
        case T.Vector{e, n}:
          Cong.count(I.item_count(S.fixed_size(e), xs), k => I.gate(Nat.is_eq(k, n), u => I.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, n, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{})))), k => I.gate(Nat.is_eq(k, n), u => I.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, n, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{})))), k => counted => Cong.gate(Nat.is_eq(k, n), u => I.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, n, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{}))), u => I.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, n, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{}))), accepted => Cong.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, n, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{})), ps => I.sequence(I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{})), ps => decoded => Equal.cong(Maybe<&2, T.Value>, Maybe<&2, T.Value>, I.sequence, I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{}), I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{}), stable(p, extra, maximum, T.Repeat{e}, [], ps, T.EmptyItems{}, shape, O.zero_le(maximum), Inputs.layout(Lists.replicate(Maybe<&2, Nat>, n, S.fixed_size(e)), xs, ps, maximum, input, decoded), R.child_budget(R.rank(T.Repeat{e}, ps, maximum), R.rank(T.Vector{e, n}, parts, maximum), p, R.enter_sequence(e, ps, maximum, Inputs.repeated_count(n, S.fixed_size(e), xs, ps, maximum, Inputs.vector_count(k, n, S.fixed_size(e), xs, counted, accepted), decoded, input)), enough))))))
        case T.ListOf{e, limit}:
          Cong.count(I.item_count(S.fixed_size(e), xs), k => I.gate(Nat.is_le(k, limit), u => I.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, k, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{})))), k => I.gate(Nat.is_le(k, limit), u => I.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, k, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{})))), k => counted => Cong.gate(Nat.is_le(k, limit), u => I.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, k, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{}))), u => I.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, k, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{}))), accepted => Cong.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, k, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{})), ps => I.sequence(I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{})), ps => decoded => Equal.cong(Maybe<&2, T.Value>, Maybe<&2, T.Value>, I.sequence, I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{}), I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{}), stable(p, extra, maximum, T.Repeat{e}, [], ps, T.EmptyItems{}, shape, O.zero_le(maximum), Inputs.layout(Lists.replicate(Maybe<&2, Nat>, k, S.fixed_size(e)), xs, ps, maximum, input, decoded), R.child_budget(R.rank(T.Repeat{e}, ps, maximum), R.rank(T.ListOf{e, limit}, parts, maximum), p, R.enter_sequence(e, ps, maximum, Inputs.repeated_count(k, S.fixed_size(e), xs, ps, maximum, counted, decoded, input)), enough))))))
        case T.ProgressiveList{e}:
          Cong.count(I.item_count(S.fixed_size(e), xs), k => I.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, k, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{}))), k => I.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, k, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{}))), k => counted => Cong.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, k, S.fixed_size(e)), xs), ps => I.sequence(I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{})), ps => I.sequence(I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{})), ps => decoded => Equal.cong(Maybe<&2, T.Value>, Maybe<&2, T.Value>, I.sequence, I.decode_go(p, T.Repeat{e}, [], ps, T.EmptyItems{}), I.decode_go(Nat.add(p, extra), T.Repeat{e}, [], ps, T.EmptyItems{}), stable(p, extra, maximum, T.Repeat{e}, [], ps, T.EmptyItems{}, shape, O.zero_le(maximum), Inputs.layout(Lists.replicate(Maybe<&2, Nat>, k, S.fixed_size(e)), xs, ps, maximum, input, decoded), R.child_budget(R.rank(T.Repeat{e}, ps, maximum), R.rank(T.ProgressiveList{e}, parts, maximum), p, R.enter_sequence(e, ps, maximum, Inputs.repeated_count(k, S.fixed_size(e), xs, ps, maximum, counted, decoded, input)), enough)))))
        case T.Container{names, fields}:
          Cong.slices(L.decode(S.widths(fields), xs), ps => I.sequence(I.decode_go(p, fields, [], ps, T.EmptyItems{})), ps => I.sequence(I.decode_go(Nat.add(p, extra), fields, [], ps, T.EmptyItems{})), ps => decoded => Equal.cong(Maybe<&2, T.Value>, Maybe<&2, T.Value>, I.sequence, I.decode_go(p, fields, [], ps, T.EmptyItems{}), I.decode_go(Nat.add(p, extra), fields, [], ps, T.EmptyItems{}), stable(p, extra, maximum, fields, [], ps, T.EmptyItems{}, V.and_right(F.finite(fields), F.well_formed(fields), shape), O.zero_le(maximum), Inputs.layout(S.widths(fields), xs, ps, maximum, input, decoded), R.child_budget(R.rank(fields, ps, maximum), R.rank(T.Container{names, fields}, parts, maximum), p, R.enter_forest(fields, ps, maximum, Inputs.forest_count(fields, xs, ps, decoded)), enough))))
        case T.ProgressiveContainer{names, fields, active}:
          Cong.slices(L.decode(S.widths(fields), xs), ps => I.sequence(I.decode_go(p, fields, [], ps, T.EmptyItems{})), ps => I.sequence(I.decode_go(Nat.add(p, extra), fields, [], ps, T.EmptyItems{})), ps => decoded => Equal.cong(Maybe<&2, T.Value>, Maybe<&2, T.Value>, I.sequence, I.decode_go(p, fields, [], ps, T.EmptyItems{}), I.decode_go(Nat.add(p, extra), fields, [], ps, T.EmptyItems{}), stable(p, extra, maximum, fields, [], ps, T.EmptyItems{}, V.and_right(F.finite(fields), F.well_formed(fields), shape), O.zero_le(maximum), Inputs.layout(S.widths(fields), xs, ps, maximum, input, decoded), R.child_budget(R.rank(fields, ps, maximum), R.rank(T.ProgressiveContainer{names, fields, active}, parts, maximum), p, R.enter_forest(fields, ps, maximum, Inputs.forest_count(fields, xs, ps, decoded)), enough))))
        case T.Union{options}:
          match xs:
            case Nil{}: {==}
            case Con{selector, tail}:
              Cong.option(S.get(options, U32.to_nat(selector)), child => I.selected(selector, I.decode_go(p, child, tail, [], T.EmptyItems{})), child => I.selected(selector, I.decode_go(Nat.add(p, extra), child, tail, [], T.EmptyItems{})), child => chosen => Equal.cong(Maybe<&2, T.Value>, Maybe<&2, T.Value>, r => I.selected(selector, r), I.decode_go(p, child, tail, [], T.EmptyItems{}), I.decode_go(Nat.add(p, extra), child, tail, [], T.EmptyItems{}), stable(p, extra, maximum, child, tail, [], T.EmptyItems{}, (%chosen : SelectionShape.result_shape(_) SelectionShape.get(options, U32.to_nat(selector), V.and_right(F.finite(options), F.well_formed(options), shape))), O.transitive(List.length(&2, U32, tail), 1n+List.length(&2, U32, tail), maximum, O.step_right(List.length(&2, U32, tail), List.length(&2, U32, tail), O.reflexive(List.length(&2, U32, tail))), input), Unit{}, R.child_budget(R.rank(child, [], maximum), R.rank(T.Union{options}, parts, maximum), p, R.child_step(child, T.Union{options}, maximum, (%chosen : Selection.bound(S.weight(options), _) Selection.get(options, U32.to_nat(selector)))), enough))))
        case T.CompatibleUnion{selectors, options}:
          match xs:
            case Nil{}: {==}
            case Con{selector, tail}:
              Cong.option(C.selected_schema(selectors, options, selector), child => I.selected(selector, I.decode_go(p, child, tail, [], T.EmptyItems{})), child => I.selected(selector, I.decode_go(Nat.add(p, extra), child, tail, [], T.EmptyItems{})), child => chosen => Equal.cong(Maybe<&2, T.Value>, Maybe<&2, T.Value>, r => I.selected(selector, r), I.decode_go(p, child, tail, [], T.EmptyItems{}), I.decode_go(Nat.add(p, extra), child, tail, [], T.EmptyItems{}), stable(p, extra, maximum, child, tail, [], T.EmptyItems{}, (%chosen : SelectionShape.result_shape(_) SelectionShape.selected(selectors, options, selector, V.and_right(F.finite(options), F.well_formed(options), shape))), O.transitive(List.length(&2, U32, tail), 1n+List.length(&2, U32, tail), maximum, O.step_right(List.length(&2, U32, tail), List.length(&2, U32, tail), O.reflexive(List.length(&2, U32, tail))), input), Unit{}, R.child_budget(R.rank(child, [], maximum), R.rank(T.CompatibleUnion{selectors, options}, parts, maximum), p, R.child_step(child, T.CompatibleUnion{selectors, options}, maximum, (%chosen : Selection.bound(S.weight(options), _) Selection.selected(selectors, options, selector))), enough))))

# Every public validity premise establishes the schema invariant; the actual
# public fuel formula dominates the initial rank. No size/resource cap occurs.
law public_budget:
  for +schema: T.Schema
  for +xs: +List<U32>
  for +extra: Nat
  for legal: {S.valid(schema) == True{} : Bool}
  {I.decode_go(Nat.mul(2n+S.weight(schema), 2n+Lists.length(U32, xs)), schema, xs, [], T.EmptyItems{}) == I.decode_go(Nat.add(Nat.mul(2n+S.weight(schema), 2n+Lists.length(U32, xs)), extra), schema, xs, [], T.EmptyItems{}) : Maybe<&2, T.Value>}
def public_budget(schema, xs, extra, legal):
  %Equal.sym(Nat, Lists.length(U32, xs), List.length(&2, U32, xs), ListProof.length_correct(U32, xs)) : {I.decode_go(Nat.mul(2n+S.weight(schema), 2n+_), schema, xs, [], T.EmptyItems{}) == I.decode_go(Nat.add(Nat.mul(2n+S.weight(schema), 2n+_), extra), schema, xs, [], T.EmptyItems{}) : Maybe<&2, T.Value>}
  stable(R.regular(schema, List.length(&2, U32, xs)), extra, List.length(&2, U32, xs), schema, xs, [], T.EmptyItems{}, Forest.valid_well_formed(schema, False{}, legal), O.reflexive(List.length(&2, U32, xs)), Unit{}, R.empty_bound(schema, List.length(&2, U32, xs)))
