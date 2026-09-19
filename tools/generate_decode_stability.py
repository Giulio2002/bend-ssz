"""Decoder budget stabilization using checked sizes, counts and forest shape."""
from pathlib import Path
s='''import Base
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
'''
for tag,args in [('Boolean',''),('Unsigned','w'),('ByteVector','n'),('ByteList','n'),('BitVector','n'),('BitList','n'),('ProgressiveBits',''),('Named','name, child')]:s+=f'        case T.{tag}{{{args}}}: {{==}}\n'
s+='''        case T.Null{}:
          match xs:
            case Nil{}: {==}
            case Con{h, t}: {==}
        case T.End{}:
          match parts:
            case Nil{}: {==}
            case Con{h, t}: {==}
'''
small='p';big='Nat.add(p, extra)'
def dec(f,schema,xs='xs',parts='[]',acc='T.EmptyItems{}'):return f'I.decode_go({f}, {schema}, {xs}, {parts}, {acc})'
def budget(child,ps,parent,parentparts,step):return f'R.child_budget(R.rank({child}, {ps}, maximum), R.rank({parent}, {parentparts}, maximum), p, {step}, enough)'
def rec(child,xs,ps,acc,shape,input,bounds,bd):return f'stable(p, extra, maximum, {child}, {xs}, {ps}, {acc}, {shape}, {input}, {bounds}, {bd})'
def cong_seq(a,b,pr):return f'Equal.cong(Maybe<&2, T.Value>, Maybe<&2, T.Value>, I.sequence, {a}, {b}, {pr})'
for tag,args in [('Chain','h, t'),('Repeat','e')]:
 parent=f'T.{tag}{{{args}}}';child='h' if tag=='Chain' else 'e';tail='t' if tag=='Chain' else parent
 sh=f'Forest.chain_head_well_formed(h, t, shape)' if tag=='Chain' else 'shape'
 st=f'Forest.chain_tail_well_formed(h, t, shape)' if tag=='Chain' else 'shape'
 hs=f'R.child_step(h, {parent}, maximum, Children.chain_head(h, t))' if tag=='Chain' else 'R.repeat_head(e, first, rest, maximum)'
 ts=f'O.transitive(1n+R.rank(t, rest, maximum), 1n+R.regular(t, maximum), R.regular({parent}, maximum), R.finite_bound(t, rest, maximum, Forest.chain_tail_finite(h, t, shape)), R.regular_step(t, {parent}, maximum, Children.chain_tail(h, t)))' if tag=='Chain' else 'R.repeat_tail(e, first, rest, maximum)'
 a=dec(small,child,'first');b=dec(big,child,'first');f=f'next => {dec(small,tail,"[]","rest","next")}';g=f'next => {dec(big,tail,"[]","rest","next")}'
 hp=rec(child,'first','[]','T.EmptyItems{}',sh,'head_bound','Unit{}',budget(child,'[]',parent,'first <> rest',hs))
 tp=rec(tail,'[]','rest','next',st,'O.zero_le(maximum)','tail_bounds',budget(tail,'rest',parent,'first <> rest',ts))
 # The tail proof is used once through the pointwise callback; affine Type bounds
 # are valid for every accumulator because the argument is a value, not a schema.
 s+=f'''        case {parent}:
          match parts:
            case Nil{{}}: {{==}}
            case Con{{first, rest}}:
              (head_bound, tail_bounds) = slices
              Cong.accumulate({a}, {b}, acc, {f}, {g}, {hp}, next => {tp})
'''
for ctor,fields,cond,n in [('Vector','e, n','Nat.is_eq(k, n)','n'),('ListOf','e, limit','Nat.is_le(k, limit)','k'),('ProgressiveList','e',None,'k')]:
 parent=f'T.{ctor}{{{fields}}}';layout=f'L.decode(Lists.replicate(Maybe<&2, Nat>, {n}, S.fixed_size(e)), xs)'
 a=dec(small,'T.Repeat{e}','[]','ps');b=dec(big,'T.Repeat{e}','[]','ps')
 counted='Inputs.vector_count(k, n, S.fixed_size(e), xs, counted, accepted)' if ctor=='Vector' else 'counted'
 step=f'R.enter_sequence(e, ps, maximum, Inputs.repeated_count({n}, S.fixed_size(e), xs, ps, maximum, {counted}, decoded, input))'
 pr=rec('T.Repeat{e}','[]','ps','T.EmptyItems{}','shape','O.zero_le(maximum)',f'Inputs.layout(Lists.replicate(Maybe<&2, Nat>, {n}, S.fixed_size(e)), xs, ps, maximum, input, decoded)',budget('T.Repeat{e}','ps',parent,'parts',step))
 proof=f'Cong.slices({layout}, ps => I.sequence({a}), ps => I.sequence({b}), ps => decoded => {cong_seq(a,b,pr)})'
 fa=f'I.slices({layout}, ps => I.sequence({a}))';fb=f'I.slices({layout}, ps => I.sequence({b}))'
 if cond:
  proof=f'Cong.gate({cond}, u => {fa}, u => {fb}, accepted => {proof})';fa=f'I.gate({cond}, u => {fa})';fb=f'I.gate({cond}, u => {fb})'
 s+=f'        case {parent}:\n          Cong.count(I.item_count(S.fixed_size(e), xs), k => {fa}, k => {fb}, k => counted => {proof})\n'
for ctor,fields in [('Container','names, fields'),('ProgressiveContainer','names, fields, active')]:
 parent=f'T.{ctor}{{{fields}}}';layout='L.decode(S.widths(fields), xs)';a=dec(small,'fields','[]','ps');b=dec(big,'fields','[]','ps')
 step='R.enter_forest(fields, ps, maximum, Inputs.forest_count(fields, xs, ps, decoded))'
 pr=rec('fields','[]','ps','T.EmptyItems{}','V.and_right(F.finite(fields), F.well_formed(fields), shape)','O.zero_le(maximum)','Inputs.layout(S.widths(fields), xs, ps, maximum, input, decoded)',budget('fields','ps',parent,'parts',step))
 s+=f'        case {parent}:\n          Cong.slices({layout}, ps => I.sequence({a}), ps => I.sequence({b}), ps => decoded => {cong_seq(a,b,pr)})\n'
for ctor,fields,select in [('Union','options','S.get(options, U32.to_nat(selector))'),('CompatibleUnion','selectors, options','C.selected_schema(selectors, options, selector)')]:
 parent=f'T.{ctor}{{{fields}}}';a=dec(small,'child','tail');b=dec(big,'child','tail')
 weight_call='Selection.get(options, U32.to_nat(selector))' if ctor=='Union' else 'Selection.selected(selectors, options, selector)'
 shape_call='SelectionShape.get(options, U32.to_nat(selector), V.and_right(F.finite(options), F.well_formed(options), shape))' if ctor=='Union' else 'SelectionShape.selected(selectors, options, selector, V.and_right(F.finite(options), F.well_formed(options), shape))'
 wt=f'(%chosen : Selection.bound(S.weight(options), _) {weight_call})';sh=f'(%chosen : SelectionShape.result_shape(_) {shape_call})'
 step=f'R.child_step(child, {parent}, maximum, {wt})';length='List.length(&2, U32, tail)';sz=f'O.transitive({length}, 1n+{length}, maximum, O.step_right({length}, {length}, O.reflexive({length})), input)'
 pr=rec('child','tail','[]','T.EmptyItems{}',sh,sz,'Unit{}',budget('child','[]',parent,'parts',step))
 cp=f'Equal.cong(Maybe<&2, T.Value>, Maybe<&2, T.Value>, r => I.selected(selector, r), {a}, {b}, {pr})'
 s+=f'''        case {parent}:
          match xs:
            case Nil{{}}: {{==}}
            case Con{{selector, tail}}:
              Cong.option({select}, child => I.selected(selector, {a}), child => I.selected(selector, {b}), child => chosen => {cp})
'''
s+='''
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
'''
Path('proofs/decode_stability.bend').write_text(s)
