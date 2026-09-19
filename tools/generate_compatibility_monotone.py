"""Generate exhaustive induction for compatibility fuel monotonicity.
No public fuel sufficiency or normative compatibility is assumed.
"""
from pathlib import Path
import re
cs=[(n,len(f.split(',')) if f else 0) for n,f in re.findall(r'^  (\w+)\{([^}]*)\}',Path('types/schema.bend').read_text().split('type Value')[0],re.M)]
def variants(prefix,expand):
 out=[]
 for n,k in cs:
  args=[prefix+str(i) for i in range(k)]
  if n in expand:
   for m,l in cs:out.append((n,[(m,[prefix+'c'+str(i) for i in range(l)])]+args[1:]))
  else:out.append((n,args))
 return out
def pp(x):return x if isinstance(x,str) else 'T.'+x[0]+'{'+', '.join(map(pp,x[1]))+'}'
def call(mode,a,b):return f'I.compatible_go(p, {mode}, {pp(a)}, {pp(b)})'
def both(a,b):return f'Bool.and({a}, {b})'
def eq(a,b):return f'Nat.is_eq({pp(a)}, {pp(b)})'
def pair(a,b):
 n,x=a;m,y=b
 if (n,m) in [('ByteVector','Vector'),('ByteList','ListOf'),('Vector','ByteVector'),('ListOf','ByteList')]:
  left=n in ('Vector','ListOf');v=x[0] if left else y[0]
  if v[0]!='Unsigned':return 'False{}'
  return both(eq(x[1] if left else x[0],y[0] if left else y[1]),f'Nat.is_eq(P.width({pp(v[1][0])}), 1n)')
 if n!=m or n=='Repeat':return 'False{}'
 if n in ['Boolean','ProgressiveBits','Null','End']:return 'True{}'
 if n=='Unsigned':return f'Nat.is_eq(P.width({x[0]}), P.width({y[0]}))'
 if n in ['ByteVector','ByteList','BitVector','BitList']:return eq(x[0],y[0])
 if n in ['Vector','ListOf']:return both(eq(x[1],y[1]),call(0,x[0],y[0]))
 if n=='ProgressiveList':return call(0,x[0],y[0])
 if n=='Container':return both(f'I.names_equal({x[0]}, {y[0]})',call(0,x[1],y[1]))
 if n=='Named':return both(f'String.eq({x[0]}, {y[0]})',call(0,x[1],y[1]))
 if n=='Union':return f'I.identical({x[0]}, {y[0]})'
 if n=='Chain':return both(call(0,x[0],y[0]),call(0,x[1],y[1]))
 if n=='CompatibleUnion':return f'Bool.or(I.identical({pp(a)}, {pp(b)}), {call(1,x[1],y[1])})'
 if n=='ProgressiveContainer':
  ax=f'I.active_fields({x[2]}, {x[0]}, {x[1]})';by=f'I.active_fields({y[2]}, {y[0]}, {y[1]})'
  return f'Bool.or(I.identical({pp(a)}, {pp(b)}), '+both(f'I.shared_positions({ax}, {by}, 0n)',call(3,ax,by))+')'
 raise ValueError(n)
def splitargs(s):
 out=[];start=0;depth=0
 for i,c in enumerate(s):
  if c in '({[':depth+=1
  elif c in ')}]':depth-=1
  elif c==',' and depth==0:out.append(s[start:i].strip());start=i+1
 out.append(s[start:].strip());return out
def newer(s):return s.replace('I.compatible_go(p,','I.compatible_go(Nat.add(p, extra),')
def proof(s,h):
 if s.startswith('Bool.or('):
  a,b=splitargs(s[8:-1]);return f'Choice.monotone({a}, {b}, {newer(b)}, accepted_tail => {proof(b,"accepted_tail")}, {h})'
 if s.startswith('Bool.and('):
  a,b=splitargs(s[9:-1]);return f'V.and_true({newer(a)}, {newer(b)}, {proof(a,f"V.and_left({a}, {b}, {h})")}, {proof(b,f"V.and_right({a}, {b}, {h})")})'
 if s.startswith('I.compatible_go('):
  args=splitargs(s[16:-1])[1:];args[0]={'0':'Pair{}','1':'All{}','2':'Row{}','3':'Slots{}'}[args[0]];return 'monotone(p, extra, '+', '.join(args)+', '+h+')'
 return h
out='''import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../src/primitives.bend as P
import ./primitive_invariants.bend as V
import ./word_facts.bend as W
import ./compatibility_choice.bend as Choice

type Mode is Data:
  Pair{}
  All{}
  Row{}
  Slots{}

def code(mode: Mode) -> U32:
  match mode:
    case Pair{}: 0
    case All{}: 1
    case Row{}: 2
    case Slots{}: 3

# Increasing fuel preserves every successful auxiliary/public-mode traversal.
# Sufficiency of the public input-derived budget remains a separate obligation.
law monotone:
  for +fuel: Nat
  for +extra: Nat
  for +mode: Mode
  for +a: T.Schema
  for +b: T.Schema
  for +accepted: {I.compatible_go(fuel, code(mode), a, b) == True{} : Bool}
  {I.compatible_go(Nat.add(fuel, extra), code(mode), a, b) == True{} : Bool}
def monotone(fuel, extra, mode, a, b, accepted):
  match fuel:
    case 0n: Empty.absurd({I.compatible_go(extra, code(mode), a, b) == True{} : Bool}, W.false_true(accepted))
    case 1n+p:
      match mode:
'''
for mode in [1,2]:
 out+=f'        case '+('All{}' if mode==1 else 'Row{}')+':\n          match '+('a' if mode==1 else 'b')+':\n'
 for a in variants('x',[]):
  n,x=a
  expr=both(call(2,x[0],'b'),call(1,x[1],'b')) if mode==1 and n=='Chain' else both(call(0,'a',x[0]),call(2,'a',x[1])) if mode==2 and n=='Chain' else 'True{}' if n=='End' else 'False{}'
  out+=f'            case {pp(a)}: {proof(expr,"accepted")}\n'
out+='        case Slots{}:\n          match a b:\n'
for a in variants('a',['Chain']):
 for b in variants('b',['Chain']):
  n,x=a;m,y=b
  if n=='End' or m=='End':expr='True{}'
  elif n==m=='Chain':expr=call(3,x[1],y[1]) if x[0][0]=='Null' or y[0][0]=='Null' else both(call(0,x[0],y[0]),call(3,x[1],y[1]))
  else:expr='False{}'
  out+=f'            case {pp(a)} {pp(b)}: {proof(expr,"accepted")}\n'
out+='        case Pair{}:\n          match a b:\n'
for a in variants('a',['Vector','ListOf']):
 for b in variants('b',['Vector','ListOf']):out+=f'            case {pp(a)} {pp(b)}: {proof(pair(a,b),"accepted")}\n'
Path('proofs/compatibility_monotone.bend').write_text(out)
