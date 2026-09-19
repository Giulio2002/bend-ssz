"""Reflect normative type identity into equality modulo SSZ byte aliases."""
from pathlib import Path
ns={};exec(Path('tools/generate_compatibility_monotone.py').read_text().split("out='''")[0],ns)
cs,variants,pp=ns['cs'],ns['variants'],ns['pp']
s='''import Base
import ../types/schema.bend as T
import ../types/primitive.bend as P
import ../spec/primitives.bend as SP
import ../spec/compatibility.bend as S
import ./metadata_reflection.bend as M
import ./bit_vector_inverse.bend as N
import ./primitive_invariants.bend as V
import ./word_facts.bend as W

# Proof-only normalization of the normative ByteVector/Vector[uint8] and
# ByteList/List[uint8] aliases. Runtime types and limits are not changed.
def normalize(schema: T.Schema) -> T.Schema:
  match schema:
'''
children={'Vector':[0],'ListOf':[0],'ProgressiveList':[0],'Repeat':[0],'Named':[1],'Container':[1],'ProgressiveContainer':[1],'Union':[0],'CompatibleUnion':[1],'Chain':[0,1]}
for n,k in cs:
 xs=[f'x{i}' for i in range(k)];ys=xs.copy()
 for i in children.get(n,[]):ys[i]=f'normalize({xs[i]})'
 body=pp((n,ys))
 if n in ['ByteVector','ByteList']:body=pp(('Vector' if n=='ByteVector' else 'ListOf',['T.Unsigned{P.U8{}}',xs[0]]))
 s+=f'    case {pp((n,xs))}: {body}\n'
s+='''
law width_sound:
  for +a: P.Width
  for +b: P.Width
  for same: {Nat.is_eq(SP.byte_width(a), SP.byte_width(b)) == True{} : Bool}
  {a == b : P.Width}
def width_sound(a, b, same):
  match a b:
'''
ws=['U8','U16','U32Width','U64','U128','U256']
for a in ws:
 for b in ws:s+=f'    case P.{a}{{}} P.{b}{{}}: '+('{==}' if a==b else f'Empty.absurd({{P.{a}{{}} == P.{b}{{}} : P.Width}}, W.false_true(same))')+'\n'
s+='''
law reflect:
  for +a: T.Schema
  for +b: T.Schema
  for +same: {S.identical(a, b) == True{} : Bool}
  {normalize(a) == normalize(b) : T.Schema}
def reflect(a, b, same):
  match a b:
'''
def eqnat(x,y,p):return f'N.nat_equal_sound({x}, {y}, {p})'
def andleft(x,y,p):return f'V.and_left({x}, {y}, {p})'
def andright(x,y,p):return f'V.and_right({x}, {y}, {p})'
def rec(x,y,p):return f'reflect({pp(x)}, {pp(y)}, {p})'
def norm(x):return f'normalize({pp(x)})'
for a in variants('a',['Vector','ListOf']):
 for b in variants('b',['Vector','ListOf']):
  n,x=a;m,y=b;proof=None;lhs=[];rhs=[];ps=[];ctor=n
  alias=(n,m) in [('ByteVector','Vector'),('ByteList','ListOf'),('Vector','ByteVector'),('ListOf','ByteList')]
  if alias:
   left=n in ['Vector','ListOf'];v=x[0] if left else y[0]
   if v[0]=='Unsigned':
    cap=x[1] if left else x[0];cap2=y[0] if left else y[1];w=v[1][0]
    cp=f'Nat.is_eq({cap}, {cap2})';wp=f'Nat.is_eq(SP.byte_width({w}), 1n)';we=f'width_sound({w}, P.U8{{}}, {andright(cp,wp,"same")})'
    lp=f'P.U8{{}}';rp=w
    if left:lp,rp=w,'P.U8{}'
    else:we=f'Equal.sym(P.Width, {w}, P.U8{{}}, {we})'
    ctor='Vector' if 'Vector' in n or 'Vector' in m else 'ListOf'
    lhs=[f'T.Unsigned{{{lp}}}',cap];rhs=[f'T.Unsigned{{{rp}}}',cap2]
    ps=[f'Equal.cong(P.Width, T.Schema, w => T.Unsigned{{w}}, {lp}, {rp}, {we})',eqnat(cap,cap2,andleft(cp,wp,'same'))]
  elif n==m and n!='Repeat':
   if n=='Unsigned':lhs=x;rhs=y;ps=[f'width_sound({x[0]}, {y[0]}, same)']
   elif n in ['ByteVector','ByteList']:
    ctor='Vector' if n=='ByteVector' else 'ListOf';lhs=['T.Unsigned{P.U8{}}',x[0]];rhs=['T.Unsigned{P.U8{}}',y[0]];ps=['{==}',eqnat(x[0],y[0],'same')]
   elif n in ['BitVector','BitList']:lhs=x;rhs=y;ps=[eqnat(x[0],y[0],'same')]
   elif n in ['Vector','ListOf']:
    cp=f'Nat.is_eq({x[1]}, {y[1]})';rp=f'S.identical({pp(x[0])}, {pp(y[0])})'
    lhs=[norm(x[0]),x[1]];rhs=[norm(y[0]),y[1]];ps=[rec(x[0],y[0],andright(cp,rp,'same')),eqnat(x[1],y[1],andleft(cp,rp,'same'))]
   elif n in ['ProgressiveList','Union']:lhs=[norm(x[0])];rhs=[norm(y[0])];ps=[rec(x[0],y[0],'same')]
   elif n=='Chain':
    p=f'S.identical({x[0]}, {y[0]})';q=f'S.identical({x[1]}, {y[1]})';lhs=list(map(norm,x));rhs=list(map(norm,y));ps=[rec(x[0],y[0],andleft(p,q,'same')),rec(x[1],y[1],andright(p,q,'same'))]
   elif n in ['Container','CompatibleUnion','Named','ProgressiveContainer']:
    f={'Container':'names_equal','CompatibleUnion':'selectors_equal','Named':'String.eq','ProgressiveContainer':'names_equal'}[n]
    p=(f'S.{f}' if f!='String.eq' else f)+f'({x[0]}, {y[0]})';q=f'S.identical({x[1]}, {y[1]})'
    if n=='ProgressiveContainer':q=f'Bool.and(S.bits_equal({x[2]}, {y[2]}), {q})'
    mp={'Container':'names_sound','CompatibleUnion':'selectors_sound','Named':'string_sound','ProgressiveContainer':'names_sound'}[n]
    lhs=[x[0],norm(x[1])];rhs=[y[0],norm(y[1])];ps=[f'M.{mp}({x[0]}, {y[0]}, {andleft(p,q,"same")})']
    tail=andright(p,q,'same')
    if n=='ProgressiveContainer':
     bp=f'S.bits_equal({x[2]}, {y[2]})';ip=f'S.identical({x[1]}, {y[1]})'
     ps+=[rec(x[1],y[1],andright(bp,ip,tail)),f'M.bits_sound({x[2]}, {y[2]}, {andleft(bp,ip,tail)})'];lhs+=[x[2]];rhs+=[y[2]]
    else:ps+=[rec(x[1],y[1],tail)]
   else:proof='{==}'
  if ps:
   lines=[]
   for i,p in enumerate(ps):
    if p == "{==}": continue
    target=lhs[:i]+['_']+rhs[i+1:]
    lines.append(f'%{p} : {{{pp((ctor,lhs))} == {pp((ctor,target))} : T.Schema}}')
   proof='\n      '.join(lines+['{==}'])
  if proof is None:proof=f'Empty.absurd({{normalize({pp(a)}) == normalize({pp(b)}) : T.Schema}}, W.false_true(same))'
  s+=f'    case {pp(a)} {pp(b)}: {proof}\n'
Path('proofs/identity_normalization.bend').write_text(s)
