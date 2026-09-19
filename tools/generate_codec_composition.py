"""Generate structural value induction composing independent serialization laws."""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
p=ROOT/'proofs/codec_composition.bend'
s=p.read_text().split('# Generated recursive composition.')[0]
ctors={'Boolean':[], 'Unsigned':['w'], 'ByteVector':['n'], 'ByteList':['n'], 'BitVector':['n'], 'BitList':['n'], 'Vector':['e','n'], 'ListOf':['e','n'], 'Container':['names','fields'], 'Union':['options'], 'Null':[], 'Chain':['h','t'], 'End':[], 'Repeat':['e'], 'Named':['name','e'], 'ProgressiveList':['e'], 'ProgressiveBits':[], 'ProgressiveContainer':['names','fields','active'], 'CompatibleUnion':['selectors','options']}
values={'BooleanValue':['b'], 'UnsignedValue':['v'], 'BytesValue':['xs'], 'BitsValue':['bs'], 'Sequence':['items'], 'Items':['head','tail'], 'EmptyItems':[], 'Selected':['selector','v'], 'NullValue':[]}
def term(k,vs):return 'T.'+k+'{'+', '.join(vs)+'}'
s+='''# Generated recursive composition.
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
'''
for k,vs in ctors.items():
 if k!='Chain':s+='    case '+term(k,vs)+': Unit{}\n'
s+='''
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
'''
for k,vs in ctors.items():
 if k!='Chain':s+='        case '+term(k,vs)+': Unit{}\n'
s+='''
law parts_correct:
  for +value: T.Value
  for +schema: T.Schema
  for +well_formed: {F.well_formed(schema) == True{} : Bool}
  {I.encode(value, schema) == S.parts(value, schema) : Maybe<&2, +List<T.Part>>}
def parts_correct(value, schema, well_formed):
  match value:
'''
def rhswf(x):return 'V.and_right(F.finite('+x+'), F.well_formed('+x+'), well_formed)'
def agg(items,schema,w1,w2,ih,width):return 'aggregate_refinement(I.encode('+items+', '+schema+'), S.parts('+items+', '+schema+'), '+w1+', '+w2+', '+ih+', '+width+')'
leaves={'BooleanValue':'boolean','UnsignedValue':'unsigned','BytesValue':'bytes','BitsValue':'bits'}
for vk,vs in values.items():
 if vk in leaves:
  s+='    case '+term(vk,vs)+': Leaves.'+leaves[vk]+'_parts_correct('+vs[0]+', schema, [])\n';continue
 s+='    case '+term(vk,vs)+':\n      match schema:\n'
 for sk,args in ctors.items():
  st=term(sk,args);body='{==}';extra=[]
  if vk=='Items' and sk in ('Chain','Repeat'):
   el='h' if sk=='Chain' else 'e';rest='t' if sk=='Chain' else st
   wf='Acc.finite_is_forest(t, Forest.chain_tail_finite(h, t, well_formed))' if sk=='Chain' else '{==}'
   hwf='Forest.chain_head_well_formed(h, t, well_formed)' if sk=='Chain' else 'well_formed'
   twf='Forest.chain_tail_well_formed(h, t, well_formed)' if sk=='Chain' else 'well_formed'
   body='forest_step(head, tail, '+el+', '+rest+', '+wf+', parts_correct(head, '+el+', '+hwf+'), parts_correct(tail, '+rest+', '+twf+'))'
  elif vk=='Sequence' and sk in ('Vector','ListOf','ProgressiveList','Container','ProgressiveContainer'):
   inner='T.Repeat{e}' if sk in ('Vector','ListOf','ProgressiveList') else 'fields'
   wf='well_formed' if inner!='fields' else rhswf('fields')
   ih='parts_correct(items, '+inner+', '+wf+')'
   w1='None{}';w2='None{}';wproof='{==}'
   if sk=='Vector':
    w1='IS.scale_size(n, IS.fixed_size(e))';w2='SS.times(n, SS.fixed_size(e))'
    wproof='Equal.trans(Maybe<&2, Nat>, '+w1+', IS.scale_size(n, SS.fixed_size(e)), '+w2+', Equal.cong(Maybe<&2, Nat>, Maybe<&2, Nat>, w => IS.scale_size(n, w), IS.fixed_size(e), SS.fixed_size(e), Schema.fixed_size_correct(e)), Schema.times_correct(n, SS.fixed_size(e)))'
   elif inner=='fields':w1='IS.fixed_size(fields)';w2='SS.fixed_size(fields)';wproof='Schema.fixed_size_correct(fields)'
   aggregate=agg('items',inner,w1,w2,ih,wproof);body=aggregate
   if sk in ('Vector','ListOf'):
    if sk=='Vector':ci='Bool.and(Nat.is_lt(0n, n), Nat.is_eq(I.count(items), n))';fun='k => Bool.and(Nat.is_lt(0n, n), Nat.is_eq(k, n))'
    else:ci='Nat.is_le(I.count(items), n)';fun='k => Nat.is_le(k, n)'
    cs=ci.replace('I.count','S.count')
    body='gate_refinement('+ci+', '+cs+', u => I.layout(I.encode(items, '+inner+'), '+w1+'), S.aggregate(S.parts(items, '+inner+'), '+w2+'), Equal.cong(Nat, Bool, '+fun+', I.count(items), S.count(items), Count.count_correct(items)), '+aggregate+')'
  elif vk=='Selected' and sk in ('Union','CompatibleUnion'):
   option='IS.get(options, U32.to_nat(selector))' if sk=='Union' else 'I.selected_schema(selectors, options, selector)'
   eq='Schema.option_correct(options, U32.to_nat(selector))' if sk=='Union' else 'H.selected_schema_correct(selectors, options, selector)'
   specfun='s => S.tagged(selector, S.parts(v, s))'
   extra=['%'+eq+' : {I.encode(T.Selected{selector, v}, '+st+') == S.with_option(_, '+specfun+') : Maybe<&2, +List<T.Part>>}']
   wf='option_well_formed(options, U32.to_nat(selector), '+rhswf('options')+')' if sk=='Union' else 'selected_schema_well_formed(selectors, options, selector, '+rhswf('options')+')'
   body='with_schema_refinement('+option+', s => I.wrap(IL.append(Some{[selector]}, I.unwrap(I.encode(v, s))), None{}), '+specfun+', '+wf+', s => proper => tagged_refinement(selector, I.encode(v, s), S.parts(v, s), parts_correct(v, s, proper)))'
  if extra:s+='        case '+st+':\n'+''.join('          '+x+'\n' for x in extra)+'          '+body+'\n'
  else:s+='        case '+st+': '+body+'\n'
s+='''
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
'''
p.write_text(s)
