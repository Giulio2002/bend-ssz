"""Structural accepted-encoding representation-shape proof, no fixtures."""
from pathlib import Path
import re
root=Path(__file__).resolve().parents[1]
path=root/'proofs/codec_shape.bend'
original=path.read_text()
footer='\n\n# Public encoding-image consequence'+original.split('# Public encoding-image consequence',1)[1] if '# Public encoding-image consequence' in original else ''
text=original.split('# Generated structural proof below.')[0]+'# Generated structural proof below.\n'
schemas=[]
for ctor,args in re.findall(r'^  (\w+)\{([^}]*)\}',(root/'types/schema.bend').read_text().split('type Value')[0],re.M):
 vs=[f's{i}' for i in range(len(args.split(',')))] if args else []
 schemas.append((ctor,vs))
values=[('BooleanValue',['v'],{'Boolean'}),('UnsignedValue',['v'],{'Unsigned'}),('BytesValue',['v'],{'ByteVector','ByteList'}),('BitsValue',['v'],{'BitVector','BitList','ProgressiveBits'}),('NullValue',[],{'Null'}),('EmptyItems',[],{'End','Repeat'}),('Items',['h','t'],{'Chain','Repeat'}),('Sequence',['items'],{'Vector','ListOf','ProgressiveList','Container','ProgressiveContainer'}),('Selected',['selector','v'],{'Union','CompatibleUnion'})]
lines=['law parts_shape:','  for +value: T.Value','  for +schema: T.Schema','  result_shape(Shape.shape(value, schema), S.parts(value, schema))','def parts_shape(value, schema):','  match value:']
for vc,args,allowed in values:
 value='T.'+vc+'{'+', '.join(args)+'}'
 lines+=['    case T.'+vc+'{'+', '.join('+'+a for a in args)+'}:','      match schema:']
 for sc,ss in schemas:
  schema='T.'+sc+'{'+', '.join(ss)+'}';patt='T.'+sc+'{'+', '.join('+'+s for s in ss)+'}'
  body='Unit{}'
  if sc in allowed:
   if vc not in ['Items','Sequence','Selected']:body=f'true_result(S.parts({value}, {schema}))'
   elif vc=='Items':
    a=ss[0];b=ss[1] if sc=='Chain' else f'T.Repeat{{{a}}}'
    body=f'concatenate(S.parts(h, {a}), S.parts(t, {b}), Shape.shape(h, {a}), Shape.shape(t, {b}), parts_shape(h, {a}), parts_shape(t, {b}))'
   elif vc=='Selected':
    option=f'Schema.option({ss[0]}, U32.to_nat(selector))' if sc=='Union' else f'Schema.compatible_option({ss[0]}, {ss[1]}, selector)'
    body=f'selected({option}, v, selector, s => parts_shape(v, s))'
   else:
    inner=f'T.Repeat{{{ss[0]}}}' if sc in ['Vector','ListOf','ProgressiveList'] else ss[1]
    shape=f'Shape.shape(items, {inner})';parts=f'S.parts(items, {inner})'
    width=f'Schema.times({ss[1]}, Schema.fixed_size({ss[0]}))' if sc=='Vector' else f'Schema.fixed_size({ss[1]})' if sc in ['Container','ProgressiveContainer'] else 'None{}'
    agg=f'aggregate({shape}, {parts}, {width}, parts_shape(items, {inner}))'
    if sc in ['Vector','ListOf']:
     ok=f'Bool.and(Nat.is_lt(0n, {ss[1]}), Nat.is_eq(S.count(items), {ss[1]}))' if sc=='Vector' else f'Nat.is_le(S.count(items), {ss[1]})'
     body=f'require({shape}, {ok}, S.aggregate({parts}, {width}), {agg})'
    else:body=agg
  lines+=['        case '+patt+': '+body]
text+='\n'.join(lines)+'\n'
path.write_text(text+footer)
