"""Closed independent legality witnesses for every frozen named actual schema."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
frozen=json.loads((ROOT/'schemas/fulu_mainnet.json').read_text())
def pair(a,b):return '('+a+', '+b+')'
def forest(fields):
 out='{==}'
 for _,s in reversed(fields):out=pair('{==}',pair(legal(s),out))
 return out
def legal(s):
 k=s['kind']
 if k in ['bool','uint','bytelist','bitlist']:return '{==}'
 if k in ['bytes','bits']:return pair('{==}','{==}')
 if k=='vector':return pair('{==}',pair('{==}',legal(s['element'])))
 if k=='list':return pair('{==}',legal(s['element']))
 if k=='container':return pair('{==}',pair(pair('{==}',pair('{==}','{==}')),forest(s['fields'])))
 raise ValueError(k)
lines=['import Base','import ../types/fulu_model.bend as F','import ../spec/type_legality.bend as S','import ../src/schema.bend as Actual','']
for name,s in frozen.items():
 lines += [f'''law {name}_normative_legal:
  S.type_legal(F.{name}.schema())
def {name}_normative_legal(): {legal(s)}

law {name}_validator_accepts:
  {{Actual.valid(F.{name}.schema()) == True{{}} : Bool}}
def {name}_validator_accepts(): {{==}}
''']
(ROOT/'proofs/fulu_legality.bend').write_text('\n'.join(lines))
