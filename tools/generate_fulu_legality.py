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
# fulu_normative.bend: the normative legality witnesses alone (fulu_named, and through it
# END_TO_END, needs only these: the validator laws evaluated every schema's validator on
# each import); fulu_legality.bend re-exports them next to the validator laws.
norm=['import Base','import ../types/fulu_model.bend as F','import ../spec/type_legality.bend as S','',
      '# The normative legality of every Fulu name (spec/type_legality), alone: fulu_named',
      '# (and through it END_TO_END) needs only these; fulu_legality.bend re-exports them next',
      "# to the validator's acceptance laws.",'']
lines=['import Base','import ../types/fulu_model.bend as F','import ../spec/type_legality.bend as S','import ./fulu_normative.bend as N','import ../src/schema.bend as Actual','']
for name,s in frozen.items():
 norm += [f'''law {name}_normative_legal:
  S.type_legal(F.{name}.schema())
def {name}_normative_legal(): {legal(s)}
''']
 lines += [f'''law {name}_normative_legal:
  S.type_legal(F.{name}.schema())
def {name}_normative_legal(): N.{name}_normative_legal()

law {name}_validator_accepts:
  {{Actual.valid(F.{name}.schema()) == True{{}} : Bool}}
def {name}_validator_accepts(): {{==}}
''']
(ROOT/'proofs/fulu_normative.bend').write_text('\n'.join(norm))
(ROOT/'proofs/fulu_legality.bend').write_text('\n'.join(lines))
