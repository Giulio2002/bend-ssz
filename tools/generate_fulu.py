"""Generate typed Bend containers and exact schema-directed APIs from frozen metadata.
No fixtures or expected outputs are read. Named schemas are the independent
frozen constants of spec/fulu_schemas.bend (single source of truth); every
public X.* function is an alias of the closed name-indexed dispatch Name.*,
over which END_TO_END.fulu_types_correct is proven.
"""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
F=json.loads((ROOT/'schemas/fulu_mainnet.json').read_text())
key=lambda x:json.dumps(x,separators=(',',':'),sort_keys=True)
containers={key(s):n for n,s in F.items() if s['kind']=='container'}
lines=['import Base','import ../types/schema.bend as T','import ../types/primitive.bend as P','import ../src/ssz.bend as API','import ../spec/fulu_schemas.bend as Spec','']
# Monomorphic per-element sequence conversions (no ~ template instances: the
# pinned checker counts every template instance as an unsafe annotation).
seq_done=set()
def seq_helpers(c):
 if c in seq_done:return
 seq_done.add(c)
 lines.append(f'''def {c}.seq_to_go(xs: +List<{c}()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{{}}: acc
    case Con{{h, t}}: {c}.seq_to_go(t, T.Items{{{c}.to_value(h), acc}})

def {c}.seq_to(xs: +List<{c}()>) -> T.Value:
  {c}.seq_to_go(List.reverse(&2, {c}(), xs), T.EmptyItems{{}})

def {c}.seq_step(result: Maybe<&2, {c}()>, acc: +List<{c}()>, next: +List<{c}()> -> Maybe<&2, +List<{c}()>>) -> Maybe<&2, +List<{c}()>>:
  match result:
    case None{{}}: None{{}}
    case Some{{x}}: next(x <> acc)

def {c}.seq_from_go(value: T.Value, acc: +List<{c}()>) -> Maybe<&2, +List<{c}()>>:
  match value:
    case T.EmptyItems{{}}: Some{{List.reverse(&2, {c}(), acc)}}
    case T.Items{{h, t}}: {c}.seq_step({c}.from_value(h), acc, next => {c}.seq_from_go(t, next))
    case _: None{{}}

def {c}.seq_from(value: T.Value) -> Maybe<&2, +List<{c}()>>:
  {c}.seq_from_go(value, [])
''')

entries={}
spec_names={}
def spec_emit(schema):
 k=json.dumps(schema,sort_keys=True)
 if k in spec_names:return
 if schema['kind'] in ('vector','list'):spec_emit(schema['element'])
 if schema['kind']=='container':
  for _,t in schema['fields']:spec_emit(t)
 spec_names[k]='Schema'+str(len(spec_names))
for _s in F.values():spec_emit(_s)
def spec_of(schema):return 'Spec.'+spec_names[json.dumps(schema,sort_keys=True)]+'()'
def nat(n):
 n=int(n)
 if n<4096:return str(n)+'n'
 if n<2**32:return f'U32.to_nat({n})'
 return f'Nat.mul(U32.to_nat({n//1024}), 1024n)' if n%1024==0 else f'Nat.add(Nat.mul(U32.to_nat({n//1024}), 1024n), {n%1024}n)'
def chain(xs):
 r='T.End{}'
 for x in reversed(xs):r='T.Chain{'+x+', '+r+'}'
 return r
def items(xs):
 r='T.EmptyItems{}'
 for x in reversed(xs):r='T.Items{'+x+', '+r+'}'
 return r
width={1:'U8',2:'U16',4:'U32Width',8:'U64',16:'U128',32:'U256'}
def emit(s):
 k=key(s)
 if k in entries:return entries[k]
 kind=s['kind'];n=containers.get(k,'Node'+str(len(entries)))
 entries[k]=n
 if kind in ('vector','list'):child=emit(s['element'])
 if kind=='container':children=[emit(t) for _,t in s['fields']]
 if kind=='container':
  typ=n
  lines.append('type '+n+' is Data:\n  '+n+'{'+', '.join(f'{name}: {c}()' for (name,_),c in zip(s['fields'],children))+'}')
  # A type constructor itself is a Type, unlike aliases defined by functions.
  # Uniform adapter types use a generated alias for container representations.
  lines.append(f'def {n}Value() -> Data: {n}')
  alias=n+'Value'
  body='T.Container{['+', '.join(json.dumps(x[0]) for x in s['fields'])+'], '+chain([c+'.schema()' for c in children])+'}'
  fields=[x[0] for x in s['fields']]
  lines.append(f'def {alias}.to_value(v: {alias}()) -> T.Value:\n  {n}'+'{'+', '.join(fields)+'} = v\n  T.Sequence{'+items([f'{c}.to_value({name})' for name,c in zip(fields,children)])+'}')
  # Match typed optional fields in a separate constructor helper.
  params=', '.join(f'a{i}: Maybe<&2, {c}()>' for i,c in enumerate(children))
  pat=' '.join('Some{v'+str(i)+'}' for i in range(len(children)))
  lines.append(f'def {alias}.assemble({params}) -> Maybe<&2, {alias}()>:\n  match '+' '.join('a'+str(i) for i in range(len(children)))+':\n    case '+pat+': Some{'+n+'{'+', '.join('v'+str(i) for i in range(len(children)))+'}}\n    case '+' '.join('_' for _ in children)+': None{}')
  patval=items(['v'+str(i) for i in range(len(children))])
  lines.append(f'def {alias}.from_value(v: T.Value) -> Maybe<&2, {alias}()>:\n  match v:\n    case T.Sequence'+'{'+patval+'}: '+alias+'.assemble('+', '.join(c+'.from_value(v'+str(i)+')' for i,c in enumerate(children))+')\n    case _: None{}')
  n=alias;entries[k]=n
 else:
  if kind=='bool':typ='Bool';body='T.Boolean{}';val='T.BooleanValue{v}';pat='T.BooleanValue{v}'
  elif kind=='uint':typ='P.UInt';body='T.Unsigned{P.'+width[s['size']]+'{}}';val='T.UnsignedValue{v}';pat='T.UnsignedValue{v}'
  elif kind in ('bytes','bytelist','bits','bitlist'):
   typ='+List<'+('Bool' if kind in ('bits','bitlist') else 'U32')+'>';ctor={'bytes':'ByteVector','bytelist':'ByteList','bits':'BitVector','bitlist':'BitList'}[kind]
   body='T.'+ctor+'{'+nat(s.get('length',s.get('limit')))+'}';tag='BitsValue' if kind in ('bits','bitlist') else 'BytesValue';val='T.'+tag+'{v}';pat=val
  else:
   typ='+List<'+child+'()>';body='T.'+('Vector' if kind=='vector' else 'ListOf')+'{'+child+'.schema(), '+nat(s.get('length',s.get('limit')))+'}'
   seq_helpers(child);val='T.Sequence{'+child+'.seq_to(v)}';pat='T.Sequence{v}'
  lines.append(f'def {n}() -> Data: {typ}')
  lines.append(f'def {n}.to_value(v: {n}()) -> T.Value: {val}')
  un=child+'.seq_from(v)' if kind in ('vector','list') else 'Some{v}'
  lines.append(f'def {n}.from_value(value: T.Value) -> Maybe<&2, {n}()>:\n  match value:\n    case {pat}: {un}\n    case _: None{{}}')
 lines.append(f'def {n}.schema() -> T.Schema: {spec_of(s)}\n')
 return n
for s in F.values():emit(s)
names=list(F.items())
lines.append('# Closed name index of the frozen mainnet Fulu inventory.')
lines.append('type Name is Data:')
for name,_ in names:lines.append(f'  Name_{name}{{}}')
lines.append('')
def typ_of(name,s):
 return name if s['kind']=='container' else entries[key(s)]+'()'
lines.append('def Name.Value(name: Name) -> Data:\n  match name:')
for name,s in names:lines.append(f'    case Name_{name}{{}}: {typ_of(name,s)}')
lines.append('\ndef Name.schema(name: Name) -> T.Schema:\n  match name:')
for name,s in names:lines.append(f'    case Name_{name}{{}}: Spec.{name}()')
lines.append('\ndef Name.to_ssz(name: Name, v: Name.Value(name)) -> T.Value:\n  match name:')
for name,s in names:lines.append(f'    case Name_{name}{{}}: {entries[key(s)]}.to_value(v)')
lines.append('\ndef Name.from_ssz(name: Name, value: T.Value) -> Maybe<&2, Name.Value(name)>:\n  match name:')
for name,s in names:lines.append(f'    case Name_{name}{{}}: {entries[key(s)]}.from_value(value)')
lines += ['',
 'def Name.valid(+name: Name, v: Name.Value(name)) -> Bool: API.valid(Name.schema(name), Name.to_ssz(name, v))',
 'def Name.serialize(+name: Name, v: Name.Value(name)) -> Maybe<&2, +List<U32>>: API.serialize(Name.schema(name), Name.to_ssz(name, v))',
 'def Name.decode_result(name: Name, result: Maybe<&2, T.Value>) -> Maybe<&2, Name.Value(name)>:\n  match result:\n    case None{}: None{}\n    case Some{v}: Name.from_ssz(name, v)',
 'def Name.deserialize(+name: Name, xs: +List<U32>) -> Maybe<&2, Name.Value(name)>: Name.decode_result(name, API.deserialize(Name.schema(name), xs))',
 'def Name.hash_tree_root(+name: Name, v: Name.Value(name)) -> Maybe<&2, +List<U32>>: API.hash_tree_root(Name.schema(name), Name.to_ssz(name, v))','']
for name,s in names:
 h=entries[key(s)]
 if s['kind']=='container':typ=name
 else:
  typ=name+'()';lines.append(f'def {name}() -> Data: {h}()')
 N=f'Name_{name}{{}}'
 lines += [f'def {name}.schema() -> T.Schema: Name.schema({N})',f'def {name}.to_ssz(v: {typ}) -> T.Value: Name.to_ssz({N}, v)',f'def {name}.from_ssz(v: T.Value) -> Maybe<&2, {typ}>: Name.from_ssz({N}, v)',f'def {name}.valid(v: {typ}) -> Bool: Name.valid({N}, v)',f'def {name}.serialize(v: {typ}) -> Maybe<&2, +List<U32>>: Name.serialize({N}, v)',f'def {name}.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, {typ}>: Name.decode_result({N}, result)',f'def {name}.deserialize(xs: +List<U32>) -> Maybe<&2, {typ}>: Name.deserialize({N}, xs)',f'def {name}.hash_tree_root(v: {typ}) -> Maybe<&2, +List<U32>>: Name.hash_tree_root({N}, v)','']
(ROOT/'types/fulu.bend').write_text('\n'.join(lines)+'\n')
