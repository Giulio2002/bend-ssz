from pathlib import Path
ns={};exec(Path('tools/generate_compatibility_monotone.py').read_text().split("out='''")[0],ns)
cs,pp=ns['cs'],ns['pp']
s='''import Base
import ../types/schema.bend as T
import ../types/primitive.bend as P
import ../spec/compatibility.bend as S
import ./identity_logic.bend as L

law false_conjunction:
  for +a: Bool
  for +b: Bool
  for no: {b == False{} : Bool}
  {False{} == Bool.and(a, b) : Bool}
def false_conjunction(a, b, no):
  %Equal.sym(Bool, b, False{}, no) : {False{} == Bool.and(a, _) : Bool}
  L.and_right_false(a)
'''
for ctor in ['Vector','ListOf']:
 for side in ['left','right']:
  a=f'T.{ctor}{{child, n}}';b='T.Unsigned{w}'
  if side=='right':a,b=b,a
  s+=f'''\nlaw {ctor}_{side}:
  for +child: T.Schema
  for +n: Nat
  for +w: P.Width
  {{S.identical({a}, {b}) == False{{}} : Bool}}
def {ctor}_{side}(child, n, w):
  match child:
'''
  for tag,arity in cs:s+=f'    case {pp((tag,[f"x{i}" for i in range(arity)]))}: {{==}}\n'
Path('proofs/identity_unsigned.bend').write_text(s)
