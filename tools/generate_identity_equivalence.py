"""Identity equivalence on public schema representations (no Named helpers)."""
from pathlib import Path
ns={}
exec(Path('tools/generate_compatibility_monotone.py').read_text().split("out='''")[0],ns)
cs,variants,pp=ns['cs'],ns['variants'],ns['pp']
out='''import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../src/primitives.bend as IP
import ../spec/compatibility.bend as S
import ../spec/primitives.bend as SP
import ./primitives.bend as P
import ./validator_metadata.bend as M
import ./primitive_invariants.bend as V
import ./word_facts.bend as W

# Named nodes belong to expanded compatibility slots, never public type trees.
# Null is allowed here because ordinary Union's first option may be Null.
def unnamed(schema: T.Schema) -> Bool:
  match schema:
'''
children={'Vector':[0],'ListOf':[0],'ProgressiveList':[0],'Repeat':[0],'Container':[1],'ProgressiveContainer':[1],'Union':[0],'CompatibleUnion':[1],'Chain':[0,1]}
for n,k in cs:
 args=[f'a{i}' for i in range(k)]
 expr='False{}' if n=='Named' else 'True{}'
 if n in children:
  es=[f'unnamed({args[i]})' for i in children[n]]
  expr=es[0] if len(es)==1 else f'Bool.and({es[0]}, {es[1]})'
 out+=f'    case {pp((n,args))}: {expr}\n'
out+='''
law and_equal:
  for +a: Bool
  for +b: Bool
  for +c: Bool
  for +d: Bool
  for ab: {a == b : Bool}
  for cd: {c == d : Bool}
  {Bool.and(a, c) == Bool.and(b, d) : Bool}
def and_equal(a, b, c, d, ab, cd):
  %ab : {Bool.and(a, c) == Bool.and(_, d) : Bool}
  %cd : {Bool.and(a, c) == Bool.and(a, _) : Bool}
  {==}

law equal:
  for +a: T.Schema
  for +b: T.Schema
  for +public: {unnamed(a) == True{} : Bool}
  {I.identical(a, b) == S.identical(a, b) : Bool}
def equal(a, b, public):
  match a b:
'''
def andp(a,b,c,d,p,q):return f'and_equal({a}, {b}, {c}, {d}, {p}, {q})'
def child(x,y,p='public'):return f'equal({pp(x)}, {pp(y)}, {p})'
def rec(x,y,p='public'):return (f'I.identical({pp(x)}, {pp(y)})',f'S.identical({pp(x)}, {pp(y)})',child(x,y,p))
def join(x,y):return (f'Bool.and({x[0]}, {y[0]})',f'Bool.and({x[1]}, {y[1]})',andp(x[0],x[1],y[0],y[1],x[2],y[2]))
def same(s):return (s,s,'{==}')
for a in variants('a',['Vector','ListOf']):
 for b in variants('b',['Vector','ListOf']):
  n,x=a;m,y=b
  proof='{==}'
  if n==m=='Named':proof=f'Empty.absurd({{I.identical({pp(a)}, {pp(b)}) == S.identical({pp(a)}, {pp(b)}) : Bool}}, W.false_true(public))'
  elif n==m=='Unsigned':
   proof=f'''%P.width_correct({x[0]}) : {{Nat.is_eq(IP.width({x[0]}), IP.width({y[0]})) == Nat.is_eq(_, SP.byte_width({y[0]})) : Bool}}
      %P.width_correct({y[0]}) : {{Nat.is_eq(IP.width({x[0]}), IP.width({y[0]})) == Nat.is_eq(IP.width({x[0]}), _) : Bool}}
      {{==}}'''
  elif (n,m) in [('ByteVector','Vector'),('ByteList','ListOf'),('Vector','ByteVector'),('ListOf','ByteList')]:
   left=n in ['Vector','ListOf'];v=x[0] if left else y[0]
   if v[0]=='Unsigned':
    cap=x[1] if left else x[0];cap2=y[0] if left else y[1];w=v[1][0]
    proof=f'%P.width_correct({w}) : {{Bool.and(Nat.is_eq({cap}, {cap2}), Nat.is_eq(IP.width({w}), 1n)) == Bool.and(Nat.is_eq({cap}, {cap2}), Nat.is_eq(_, 1n)) : Bool}}\n      {{==}}'
  elif n==m:
   if n in ['Vector','ListOf']:proof=join(same(f'Nat.is_eq({x[1]}, {y[1]})'),rec(x[0],y[0]))[2]
   elif n in ['ProgressiveList','Union']:proof=child(x[0],y[0])
   elif n=='Chain':
    p=f'V.and_left(unnamed({x[0]}), unnamed({x[1]}), public)';q=f'V.and_right(unnamed({x[0]}), unnamed({x[1]}), public)'
    proof=join(rec(x[0],y[0],p),rec(x[1],y[1],q))[2]
   elif n in ['Container','CompatibleUnion','ProgressiveContainer']:
    f='selectors_equal' if n=='CompatibleUnion' else 'names_equal'
    pre=(f'I.{f}({x[0]}, {y[0]})',f'S.{f}({x[0]}, {y[0]})',f'M.{f}({x[0]}, {y[0]})')
    tail=rec(x[1],y[1])
    if n=='ProgressiveContainer':tail=join((f'I.bools_equal({x[2]}, {y[2]})',f'S.bits_equal({x[2]}, {y[2]})',f'M.bits_equal({x[2]}, {y[2]})'),tail)
    proof=join(pre,tail)[2]
  out+=f'    case {pp(a)} {pp(b)}: {proof}\n'
Path('proofs/identity_equivalence.bend').write_text(out)
