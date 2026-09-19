"""Proof that adapter-only structural erasure preserves every value shape."""
from pathlib import Path
import re
root=Path(__file__).resolve().parents[1];path=root/'proofs/representation_erasure.bend'
original=path.read_text()
footer='\n\nlaw shape_erased_true:'+original.split('law shape_erased_true:',1)[1] if 'law shape_erased_true:' in original else ''
text=original.split('# Generated lookup erasure')[0]+'# Generated lookup erasure and structural value proof.\n'
schemas=[]
for ctor,args in re.findall(r'^  (\w+)\{([^}]*)\}',(root/'types/schema.bend').read_text().split('type Value')[0],re.M):
 vs=[f's{i}' for i in range(len(args.split(',')))] if args else [];schemas.append((ctor,vs))
lines=['law option_erases:','  for +schema: T.Schema','  for +index: Nat','  {Schema.option(S.erase(schema), index) == erase_option(Schema.option(schema, index)) : Maybe<&2, T.Schema>}','def option_erases(schema, index):','  match schema:']
for c,vs in schemas:
 lines+=['    case T.'+c+'{'+', '.join(vs)+'}:']
 if c=='Chain':lines+=['      match index:','        case 0n: {==}','        case 1n+p: option_erases(s1, p)']
 else:lines+=['      {==}']
lines+=['','law compatible_option_erases:','  for +selectors: +List<U32>','  for +schema: T.Schema','  for +selector: U32','  {Schema.compatible_option(selectors, S.erase(schema), selector) == erase_option(Schema.compatible_option(selectors, schema, selector)) : Maybe<&2, T.Schema>}','def compatible_option_erases(selectors, schema, selector):','  match selectors:','    case Nil{}: {==}','    case Con{s, ss}:','      match schema:']
for c,vs in schemas:
 lines+=['        case T.'+c+'{'+', '.join('+'+v for v in vs)+'}:']
 if c=='Chain':lines+=['          %Equal.sym(Maybe<&2, T.Schema>, Schema.compatible_option(ss, S.erase(s1), selector), erase_option(Schema.compatible_option(ss, s1, selector)), compatible_option_erases(ss, s1, selector)) : {Schema.selected(U32.is_eq(s, selector), S.erase(s0), _) == erase_option(Schema.compatible_option(s <> ss, T.Chain{s0, s1}, selector)) : Maybe<&2, T.Schema>}','          selected_erases(U32.is_eq(s, selector), s0, Schema.compatible_option(ss, s1, selector))']
 else:lines+=['          {==}']
lines += ['''
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
  match value:''']
values=[('BooleanValue',['v']),('UnsignedValue',['v']),('BytesValue',['v']),('BitsValue',['v']),('NullValue',[]),('EmptyItems',[]),('Items',['h','t']),('Sequence',['items']),('Selected',['selector','v'])]
for vc,args in values:
 lines+=['    case T.'+vc+'{'+', '.join('+'+a for a in args)+'}:','      match schema:']
 for sc,ss in schemas:
  body='{==}'
  if vc=='Items' and sc in ['Chain','Repeat']:
   a=ss[0];b=ss[1] if sc=='Chain' else f'T.Repeat{{{a}}}'
   body=f'and_equal(S.shape(h, {a}), S.shape(t, {b}), S.shape(h, S.erase({a})), S.shape(t, S.erase({b})), shape_erases(h, {a}), shape_erases(t, {b}))'
  elif vc=='Sequence' and sc in ['Vector','ListOf','ProgressiveList','Container','ProgressiveContainer']:
   inner=f'T.Repeat{{{ss[0]}}}' if sc in ['Vector','ListOf','ProgressiveList'] else ss[1]
   body=f'shape_erases(items, {inner})'
  elif vc=='Selected' and sc in ['Union','CompatibleUnion']:
   if sc=='Union':opt=f'Schema.option({ss[0]}, U32.to_nat(selector))';er=f'Schema.option(S.erase({ss[0]}), U32.to_nat(selector))';proof=f'option_erases({ss[0]}, U32.to_nat(selector))'
   else:opt=f'Schema.compatible_option({ss[0]}, {ss[1]}, selector)';er=f'Schema.compatible_option({ss[0]}, S.erase({ss[1]}), selector)';proof=f'compatible_option_erases({ss[0]}, {ss[1]}, selector)'
   body=f'selected_lookup({opt}, {er}, v, {proof}, s => shape_erases(v, s))'
  lines+=['        case T.'+sc+'{'+', '.join('+'+s for s in ss)+'}: '+body]
path.write_text(text+'\n'.join(lines)+'\n'+footer)
