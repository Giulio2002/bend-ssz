"""Construct finite actual compatibility from the independent identity rule."""
from pathlib import Path
ns={}
exec(Path('tools/generate_compatibility_monotone.py').read_text().split("out='''")[0],ns)
variants,pp=ns['variants'],ns['pp']
s='''import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../spec/compatibility.bend as S
import ./compatibility_finite.bend as F
import ./identity_total.bend as Identity
import ./compatibility_choice.bend as Choice
import ./primitive_invariants.bend as V
import ./validator_metadata.bend as M
import ./word_facts.bend as W

law actual_identity:
  for +a: T.Schema
  for +b: T.Schema
  for accepted: {S.identical(a, b) == True{} : Bool}
  {I.identical(a, b) == True{} : Bool}
def actual_identity(a, b, accepted):
  %Equal.sym(Bool, I.identical(a, b), S.identical(a, b), Identity.equal(a, b)) : {_ == True{} : Bool}
  accepted

# A finite implementation witness for every independent identity derivation.
law finite_identity:
  for +a: T.Schema
  for +b: T.Schema
  for +accepted: {S.identical(a, b) == True{} : Bool}
  F.finite(S.Pair{}, a, b)
def finite_identity(a, b, accepted):
  match a b:
'''
for a in variants('a',['Vector','ListOf']):
 for b in variants('b',['Vector','ListOf']):
  n,x=a;m,y=b;aa,bb=pp(a),pp(b)
  cross=(n,m) in [('ByteVector','Vector'),('Vector','ByteVector'),('ByteList','ListOf'),('ListOf','ByteList')]
  if n!=m and not cross or n==m=='Repeat':body=f'Empty.absurd(F.finite(S.Pair{{}}, {aa}, {bb}), W.false_true(accepted))'
  elif n==m and n in ['Vector','ListOf']:
   meta=f'Nat.is_eq({x[1]}, {y[1]})';child=f'S.identical({pp(x[0])}, {pp(y[0])})'
   body=f'F.{n}({pp(x[0])}, {pp(y[0])}, {x[1]}, {y[1]}, V.and_left({meta}, {child}, accepted), finite_identity({pp(x[0])}, {pp(y[0])}, V.and_right({meta}, {child}, accepted)))'
  elif n==m and n in ['Container','Named']:
   meta=f'S.names_equal({x[0]}, {y[0]})' if n=='Container' else f'String.eq({x[0]}, {y[0]})';child=f'S.identical({x[1]}, {y[1]})';mp=f'V.and_left({meta}, {child}, accepted)'
   if n=='Container':mp=f'%Equal.sym(Bool, I.names_equal({x[0]}, {y[0]}), {meta}, M.names_equal({x[0]}, {y[0]})) : {{_ == True{{}} : Bool}}\n      '+mp
   body=f'F.{n}({x[1]}, {y[1]}, {x[0]}, {y[0]}, {mp}, finite_identity({x[1]}, {y[1]}, V.and_right({meta}, {child}, accepted)))'
  elif n==m=='ProgressiveList':body=f'F.progressive_list({x[0]}, {y[0]}, finite_identity({x[0]}, {y[0]}, accepted))'
  elif n==m=='Chain':
   l=f'S.identical({x[0]}, {y[0]})';r=f'S.identical({x[1]}, {y[1]})'
   body=f'F.chain({x[0]}, {x[1]}, {y[0]}, {y[1]}, finite_identity({x[0]}, {y[0]}, V.and_left({l}, {r}, accepted)), finite_identity({x[1]}, {y[1]}, V.and_right({l}, {r}, accepted)))'
  elif n==m and n in ['ProgressiveContainer','CompatibleUnion']:
   rec='False{}' if n=='CompatibleUnion' else f'Bool.and(I.shared_positions(I.active_fields({x[2]}, {x[0]}, {x[1]}), I.active_fields({y[2]}, {y[0]}, {y[1]}), 0n), False{{}})'
   body=f'(1n, Choice.identity_accepts(I.identical({aa}, {bb}), {rec}, actual_identity({aa}, {bb}, accepted)))'
  else:body=f'(1n, actual_identity({aa}, {bb}, accepted))'
  s+=f'    case {aa} {bb}: {body}\n'
Path('proofs/compatibility_finite_identity.bend').write_text(s)
