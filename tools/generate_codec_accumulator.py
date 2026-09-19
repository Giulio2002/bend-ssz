"""Exhaustive structural induction under the required forest invariant."""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
p=ROOT/'proofs/codec_accumulator.bend'
s=p.read_text().split('# Generated forest cases.')[0]
ctors={'Boolean':[], 'Unsigned':['w'], 'ByteVector':['n'], 'ByteList':['n'], 'BitVector':['n'], 'BitList':['n'], 'Vector':['e','n'], 'ListOf':['e','n'], 'Container':['names','fields'], 'Union':['options'], 'Null':[], 'Chain':['h','t'], 'End':[], 'Repeat':['e'], 'Named':['name','e'], 'ProgressiveList':['e'], 'ProgressiveBits':[], 'ProgressiveContainer':['names','fields','active'], 'CompatibleUnion':['selectors','options']}
values={'BooleanValue':['b'], 'UnsignedValue':['v'], 'BytesValue':['xs'], 'BitsValue':['bs'], 'Sequence':['items'], 'Items':['head','tail'], 'EmptyItems':[], 'Selected':['selector','v'], 'NullValue':[]}
possible={'BooleanValue':['Boolean'],'UnsignedValue':['Unsigned'],'BytesValue':['ByteVector','ByteList'],'BitsValue':['BitVector','BitList','ProgressiveBits'],'Sequence':['Vector','ListOf','Container','ProgressiveContainer','ProgressiveList'],'Selected':['Union','CompatibleUnion'],'NullValue':['Null']}
def term(k,vs):return 'T.'+k+'{'+', '.join(vs)+'}'
s+='''# Generated forest cases.
law finite_is_forest:
  for +schema: T.Schema
  for finite: {Forest.finite(schema) == True{} : Bool}
  {forest(schema) == True{} : Bool}
def finite_is_forest(schema, finite):
  match schema:
'''
for k,vs in ctors.items():s+='    case '+term(k,vs)+': '+('{==}' if k=='Repeat' else 'finite')+'\n'
s+='''
law forest_accumulator:
  for +value: T.Value
  for +schema: T.Schema
  for +acc: +List<T.Part>
  for +well_formed: {forest(schema) == True{} : Bool}
  {I.encode_go(value, schema, acc) == prefix(acc, I.encode(value, schema)) : Maybe<&2, +List<T.Part>>}
def forest_accumulator(value, schema, acc, well_formed):
  match value:
'''
for vk,vs in values.items():
 s+='    case '+term(vk,vs)+':\n      match schema:\n'
 for sk,args in ctors.items():
  args=['s_'+x for x in args];st=term(sk,args);body='{==}'
  if sk in possible.get(vk,[]):body='impossible('+term(vk,vs)+', '+st+', acc, well_formed)'
  if vk=='Items' and sk in ('Chain','Repeat'):
   child=args[0];rest=args[1] if sk=='Chain' else st
   wf='finite_is_forest('+rest+', well_formed)' if sk=='Chain' else '{==}'
   ih='prior => forest_accumulator(tail, '+rest+', prior, '+wf+')'
   body='accumulated_prefix(I.encode(head, '+child+'), acc, I.encode(tail, '+rest+'), prior => I.encode_go(tail, '+rest+', prior), '+ih+', '+ih+')'
  s+='        case '+st+': '+body+'\n'
p.write_text(s)
