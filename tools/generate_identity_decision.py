"""Normalization preserves the entire independent identity decision."""
from pathlib import Path
ns={};exec(Path('tools/generate_compatibility_monotone.py').read_text().split("out='''")[0],ns)
cs,variants,pp=ns['cs'],ns['variants'],ns['pp']
s='''import Base
import ../types/schema.bend as T
import ../spec/compatibility.bend as S
import ../spec/primitives.bend as P
import ./identity_normalization.bend as N
import ./identity_equivalence.bend as E
import ./identity_logic.bend as L
import ./identity_unsigned.bend as U
import ../types/primitive.bend as Width

law decision:
  for +a: T.Schema
  for +b: T.Schema
  {S.identical(a, b) == S.identical(N.normalize(a), N.normalize(b)) : Bool}
def decision(a, b):
  match a b:
'''
def same(t):return t,t,'{==}'
def rec(a,b):return f'S.identical({pp(a)}, {pp(b)})',f'S.identical(N.normalize({pp(a)}), N.normalize({pp(b)}))',f'decision({pp(a)}, {pp(b)})'
def both(p,q):return f'Bool.and({p[0]}, {q[0]})',f'Bool.and({p[1]}, {q[1]})',f'E.and_equal({p[0]}, {p[1]}, {q[0]}, {q[1]}, {p[2]}, {q[2]})'
for a in variants('a',['Vector','ListOf']):
 for b in variants('b',['Vector','ListOf']):
  n,x=a;m,y=b;proof='{==}'
  if (n,m) in [('ByteVector','Vector'),('ByteList','ListOf'),('Vector','ByteVector'),('ListOf','ByteList')]:
   left=n in ['Vector','ListOf'];v=x[0] if left else y[0];cap=x[1] if left else x[0];cap2=y[0] if left else y[1];eq=f'Nat.is_eq({cap}, {cap2})'
   if v[0]=='Unsigned':
    if not left:
     w=f'P.byte_width({v[1][0]})';proof=both(same(eq),(f'Nat.is_eq({w}, 1n)',f'Nat.is_eq(1n, {w})',f'L.natural_symmetry({w}, 1n)'))[2]
   else:
    proof=f'L.and_right_false({eq})'
    if v[0] in ['Vector','ListOf']:
     term=f'T.{v[0]}{{N.normalize({v[1][0]}), {v[1][1]}}}';one='T.Unsigned{Width.U8{}}'
     lhs,rhs=(term,one) if left else (one,term)
     proof=f'U.false_conjunction({eq}, S.identical({lhs}, {rhs}), U.{v[0]}_{"left" if left else "right"}(N.normalize({v[1][0]}), {v[1][1]}, Width.U8{{}}))' 
  elif n==m:
   if n in ['ByteVector','ByteList']:proof=f'L.and_right_true(Nat.is_eq({x[0]}, {y[0]}))'
   elif n in ['Vector','ListOf']:proof=both(same(f'Nat.is_eq({x[1]}, {y[1]})'),rec(x[0],y[0]))[2]
   elif n in ['ProgressiveList','Union']:proof=rec(x[0],y[0])[2]
   elif n=='Chain':proof=both(rec(x[0],y[0]),rec(x[1],y[1]))[2]
   elif n in ['Container','Named','CompatibleUnion','ProgressiveContainer']:
    fun={'Container':'S.names_equal','Named':'String.eq','CompatibleUnion':'S.selectors_equal','ProgressiveContainer':'S.names_equal'}[n];tail=rec(x[1],y[1])
    if n=='ProgressiveContainer':tail=both(same(f'S.bits_equal({x[2]}, {y[2]})'),tail)
    proof=both(same(f'{fun}({x[0]}, {y[0]})'),tail)[2]
  s+=f'    case {pp(a)} {pp(b)}: {proof}\n'
s+='''
# Replacement of an identical option preserves the entire identity decision,
# including rejection. This is needed by ordinary unions inside compatibility.
law replace_right:
  for +a: T.Schema
  for +b: T.Schema
  for +c: T.Schema
  for same: {S.identical(b, c) == True{} : Bool}
  {S.identical(a, b) == S.identical(a, c) : Bool}
def replace_right(a, b, c, same):
  Equal.trans(Bool, S.identical(a, b), S.identical(N.normalize(a), N.normalize(b)), S.identical(a, c), decision(a, b), Equal.trans(Bool, S.identical(N.normalize(a), N.normalize(b)), S.identical(N.normalize(a), N.normalize(c)), S.identical(a, c), Equal.cong(T.Schema, Bool, x => S.identical(N.normalize(a), x), N.normalize(b), N.normalize(c), N.reflect(b, c, same)), Equal.sym(Bool, S.identical(a, c), S.identical(N.normalize(a), N.normalize(c)), decision(a, c))))

law transitive:
  for +a: T.Schema
  for +b: T.Schema
  for +c: T.Schema
  for ab: {S.identical(a, b) == True{} : Bool}
  for bc: {S.identical(b, c) == True{} : Bool}
  {S.identical(a, c) == True{} : Bool}
def transitive(a, b, c, ab, bc):
  %replace_right(a, b, c, bc) : {_ == True{} : Bool}
  ab
'''
Path('proofs/identity_decision.bend').write_text(s)
