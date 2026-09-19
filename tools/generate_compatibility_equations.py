"""Expose sequence compatibility equations without constructor matcher residuals."""
from pathlib import Path
ns={};exec(Path('tools/generate_compatibility_monotone.py').read_text().split("out='''")[0],ns)
cs,variants,pp=ns['cs'],ns['variants'],ns['pp']
s='''import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
'''
for ctor in ['Vector','ListOf']:
 s+=f'''
law {ctor}:
  for +fuel: Nat
  for +a: T.Schema
  for +b: T.Schema
  for +n: Nat
  for +m: Nat
  {{I.compatible_go(1n+fuel, 0, T.{ctor}{{a, n}}, T.{ctor}{{b, m}}) == Bool.and(Nat.is_eq(n, m), I.compatible_go(fuel, 0, a, b)) : Bool}}
def {ctor}(fuel, a, b, n, m):
  match a b:
'''
 for a in variants('a',[]):
  for b in variants('b',[]):s+=f'    case {pp(a)} {pp(b)}: {{==}}\n'
Path('proofs/compatibility_equations.bend').write_text(s)
