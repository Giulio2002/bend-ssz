"""Independent schema transcription and an UNVERIFIED named-proof scratch candidate.
The only protocol input is schemas/fulu_mainnet.json; no test outputs are read.
"""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
frozen=json.loads((ROOT/'schemas/fulu_mainnet.json').read_text())
source=(ROOT/'types/fulu.bend').read_text()
widths={1:'U8',2:'U16',4:'U32Width',8:'U64',16:'U128',32:'U256'}
def nat(n):
 n=int(n)
 if n<4096:return str(n)+'n'
 if n<2**32:return f'U32.to_nat({n})'
 return f'Nat.mul(U32.to_nat({n//1024}), 1024n)' if n%1024==0 else f'Nat.add(Nat.mul(U32.to_nat({n//1024}), 1024n), {n%1024}n)'
lines=['import Base','import ../types/schema.bend as T','import ../types/primitive.bend as P','', '# Exact frozen mainnet Fulu schema constants; no source/proof dependencies.']
seen={}
def emit(schema):
 key=json.dumps(schema,sort_keys=True)
 if key in seen:return seen[key]+'()'
 kind=schema['kind']
 if kind=='bool':body='T.Boolean{}'
 elif kind=='uint':body='T.Unsigned{P.'+widths[schema['size']]+'{}}'
 elif kind in ('bytes','bytelist','bits','bitlist'):
  ctor={'bytes':'ByteVector','bytelist':'ByteList','bits':'BitVector','bitlist':'BitList'}[kind]
  body='T.'+ctor+'{'+nat(schema.get('length',schema.get('limit')))+'}'
 elif kind in ('vector','list'):
  body='T.'+('Vector' if kind=='vector' else 'ListOf')+'{'+emit(schema['element'])+', '+nat(schema.get('length',schema.get('limit')))+'}'
 elif kind=='container':
  elements=[emit(s) for _,s in schema['fields']];chain='T.End{}'
  for e in reversed(elements):chain='T.Chain{'+e+', '+chain+'}'
  body='T.Container{['+', '.join(json.dumps(n) for n,_ in schema['fields'])+'], '+chain+'}'
 else:raise ValueError(kind)
 name='Schema'+str(len(seen));seen[key]=name
 lines.append('def '+name+'() -> T.Schema: '+body)
 return name+'()'
for name,schema in frozen.items():lines.append('def '+name+'() -> T.Schema: '+emit(schema))
(ROOT/'spec/fulu_schemas.bend').write_text('\n'.join(lines)+'\n')
proof=['import Base','import ../types/fulu_model.bend as F','import ../spec/fulu_schemas.bend as Schemas','import ../spec/codec.bend as S','import ../types/schema.bend as T','import ../src/schema.bend as Actual','import ../proofs/codec_composition.bend as Codec','']
for name,schema in frozen.items():
 declaration=next(line for line in source.splitlines() if line.startswith('def '+name+'.to_ssz(v: '))
 typ=declaration.split('.to_ssz(v: ')[1].split(') -> T.Value: ')[0]
 proof += [f'''law {name}_schema_correct:
  {{F.{name}.schema() == Schemas.{name}() : T.Schema}}
def {name}_schema_correct(): {{==}}

law {name}_schema_accepted:
  {{Actual.valid(F.{name}.schema()) == True{{}} : Bool}}
def {name}_schema_accepted(): {{==}}

law {name}_serialize_correct:
  for +value: F.{typ}
  {{F.{name}.serialize(value) == S.encoding_for_legal_type(Schemas.{name}(), F.{name}.to_ssz(value)) : Maybe<&2, +List<U32>>}}
def {name}_serialize_correct(value):
  %{name}_schema_correct() : {{F.{name}.serialize(value) == S.encoding_for_legal_type(_, F.{name}.to_ssz(value)) : Maybe<&2, +List<U32>>}}
  Codec.serialize_for_valid_type(F.{name}.schema(), F.{name}.to_ssz(value), {name}_schema_accepted())
''']
(ROOT/'build').mkdir(exist_ok=True)
(ROOT/'build/fulu_serialization.candidate.bend').write_text('\n'.join(proof)+'\n')
