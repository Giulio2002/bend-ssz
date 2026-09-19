"""Induction from independent finite derivations to actual finite traversals."""
from pathlib import Path
ns={};exec(Path('tools/generate_compatibility_monotone.py').read_text().split("out='''")[0],ns)
variants,pp=ns['variants'],ns['pp']
def derive(w,mode,a,b):return f'S.derives({w}, S.{mode}{{}}, {pp(a)}, {pp(b)})'
def rec(w,mode,a,b,h):return f'complete({w}, S.{mode}{{}}, {pp(a)}, {pp(b)}, {h})'
def al(a,b,h='accepted'):return f'V.and_left({a}, {b}, {h})'
def ar(a,b,h='accepted'):return f'V.and_right({a}, {b}, {h})'
def bad(mode,a,b):return f'Empty.absurd(F.finite(S.{mode}{{}}, {pp(a)}, {pp(b)}), W.false_true(accepted))'
s='''import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../spec/compatibility.bend as S
import ./compatibility_finite.bend as F
import ./compatibility_finite_identity.bend as Identity
import ./compatibility_positions.bend as Positions
import ./validator_metadata.bend as M
import ./primitive_invariants.bend as V
import ./word_facts.bend as W

law progressive:
  for +na: +List<String>
  for +fa: T.Schema
  for +aa: +List<Bool>
  for +nb: +List<String>
  for +fb: T.Schema
  for +ab: +List<Bool>
  for positions: {S.shared_positions(S.slots(aa, na, fa), S.slots(ab, nb, fb), 0n) == True{} : Bool}
  for child: F.finite(S.Slots{}, S.slots(aa, na, fa), S.slots(ab, nb, fb))
  F.finite(S.Pair{}, T.ProgressiveContainer{na, fa, aa}, T.ProgressiveContainer{nb, fb, ab})
def progressive(na, fa, aa, nb, fb, ab, positions, child):
  F.progressive(na, fa, aa, nb, fb, ab,
    %Equal.sym(Bool, I.shared_positions(I.active_fields(aa, na, fa), I.active_fields(ab, nb, fb), 0n), S.shared_positions(I.active_fields(aa, na, fa), I.active_fields(ab, nb, fb), 0n), Positions.shared_positions(I.active_fields(aa, na, fa), I.active_fields(ab, nb, fb), 0n)) : {_ == True{} : Bool}
    %Equal.sym(T.Schema, I.active_fields(aa, na, fa), S.slots(aa, na, fa), M.active_slots(aa, na, fa)) : {S.shared_positions(_, I.active_fields(ab, nb, fb), 0n) == True{} : Bool}
    %Equal.sym(T.Schema, I.active_fields(ab, nb, fb), S.slots(ab, nb, fb), M.active_slots(ab, nb, fb)) : {S.shared_positions(S.slots(aa, na, fa), _, 0n) == True{} : Bool}
    positions,
    %Equal.sym(T.Schema, I.active_fields(aa, na, fa), S.slots(aa, na, fa), M.active_slots(aa, na, fa)) : F.finite(S.Slots{}, _, I.active_fields(ab, nb, fb))
    %Equal.sym(T.Schema, I.active_fields(ab, nb, fb), S.slots(ab, nb, fb), M.active_slots(ab, nb, fb)) : F.finite(S.Slots{}, S.slots(aa, na, fa), _)
    child)

# Witness induction is unrestricted; no implementation success is a premise.
law complete:
  for +witness: S.Derivation
  for +mode: S.Judgement
  for +a: T.Schema
  for +b: T.Schema
  for +accepted: {S.derives(witness, mode, a, b) == True{} : Bool}
  F.finite(mode, a, b)
def complete(witness, mode, a, b, accepted):
  match witness:
    case S.Leaf{}:
      match mode:
        case S.Pair{}: Identity.finite_identity(a, b, accepted)
'''
for mode in ['All','Row']:
 s+=f'        case S.{mode}{{}}:\n          match '+('a' if mode=='All' else 'b')+':\n'
 for obj in variants('x',[]):
  body='(1n, {==})' if obj[0]=='End' else bad(mode,obj if mode=='All' else 'a','b' if mode=='All' else obj)
  s+=f'            case {pp(obj)}: {body}\n'
s+='        case S.Slots{}:\n          match a b:\n'
for a in variants('a',[]):
 for b in variants('b',[]):
  body='F.slots_end_left('+pp(b)+')' if a[0]=='End' else 'F.slots_end_right('+pp(a)+')' if b[0]=='End' else bad('Slots',a,b)
  s+=f'            case {pp(a)} {pp(b)}: {body}\n'
s+='    case S.Step{child}:\n      match mode:\n        case S.Pair{}:\n          match a b:\n'
for a in variants('a',[]):
 for b in variants('b',[]):
  n,x=a;m,y=b
  if n!=m:body=bad('Pair',a,b)
  elif n in ['Vector','ListOf','Container','Named']:
   idx=0 if n in ['Vector','ListOf'] else 1;ch=derive('child','Pair',x[idx],y[idx]);meta=f'Nat.is_eq({x[1]}, {y[1]})' if idx==0 else f'S.names_equal({x[0]}, {y[0]})' if n=='Container' else f'String.eq({x[0]}, {y[0]})';mp=al(meta,ch)
   if n=='Container':mp=f'%Equal.sym(Bool, I.names_equal({x[0]}, {y[0]}), {meta}, M.names_equal({x[0]}, {y[0]})) : {{_ == True{{}} : Bool}}\n              '+mp
   args=[x[0],y[0],x[1],y[1]] if idx==0 else [x[1],y[1],x[0],y[0]]
   body=f'F.{n}('+', '.join(args)+f', {mp}, '+rec('child','Pair',x[idx],y[idx],ar(meta,ch))+')'
  elif n=='ProgressiveList':body=f'F.progressive_list({x[0]}, {y[0]}, '+rec('child','Pair',x[0],y[0],'accepted')+')'
  elif n=='CompatibleUnion':body=f'F.compatible_union({x[0]}, {y[0]}, {x[1]}, {y[1]}, '+rec('child','All',x[1],y[1],'accepted')+')'
  elif n=='ProgressiveContainer':
   ax=f'S.slots({x[2]}, {x[0]}, {x[1]})';by=f'S.slots({y[2]}, {y[0]}, {y[1]})';meta=f'S.shared_positions({ax}, {by}, 0n)';ch=derive('child','Slots',ax,by)
   body='progressive('+', '.join(x+y)+', '+al(meta,ch)+', '+rec('child','Slots',ax,by,ar(meta,ch))+')'
  else:body=bad('Pair',a,b)
  s+=f'            case {pp(a)} {pp(b)}: {body}\n'
s+='        case S.Slots{}:\n          match a b:\n'
for a in variants('a',['Chain']):
 for b in variants('b',['Chain']):
  n,x=a;m,y=b
  if n==m=='Chain' and x[0][0]=='Null':body=f'F.skip_left({x[1]}, {pp(y[0])}, {y[1]}, '+rec('child','Slots',x[1],y[1],'accepted')+')'
  elif n==m=='Chain' and y[0][0]=='Null':body=f'F.skip_right({pp(x[0])}, {x[1]}, {y[1]}, '+rec('child','Slots',x[1],y[1],'accepted')+')'
  else:body=bad('Slots',a,b)
  s+=f'            case {pp(a)} {pp(b)}: {body}\n'
for mode in ['All','Row']:s+=f'        case S.{mode}{{}}: '+bad(mode,'a','b')+'\n'
s+='    case S.Fork{left, right}:\n      match mode:\n'
for mode in ['Pair','Slots']:
 s+=f'        case S.{mode}{{}}:\n          match a b:\n'
 for a in variants('a',['Chain'] if mode=='Slots' else []):
  for b in variants('b',['Chain'] if mode=='Slots' else []):
   n,x=a;m,y=b
   if n==m=='Chain' and mode=='Pair':
    l=derive('left','Pair',x[0],y[0]);r=derive('right','Pair',x[1],y[1]);body=f'F.chain({x[0]}, {x[1]}, {y[0]}, {y[1]}, '+rec('left','Pair',x[0],y[0],al(l,r))+', '+rec('right','Pair',x[1],y[1],ar(l,r))+')'
   elif n==m=='Chain' and x[0][0]==y[0][0]=='Named' and mode=='Slots':
    na,fa=x[0][1];nb,fb=y[0][1];l=derive('left','Pair',fa,fb);r=derive('right','Slots',x[1],y[1]);names=f'String.eq({na}, {nb})';rest=f'Bool.and({l}, {r})';rp=ar(names,rest)
    body=f'F.slots_named({na}, {fa}, {x[1]}, {nb}, {fb}, {y[1]}, '+al(names,rest)+', '+rec('left','Pair',fa,fb,al(l,r,rp))+', '+rec('right','Slots',x[1],y[1],ar(l,r,rp))+')'
   else:body=bad(mode,a,b)
   s+=f'            case {pp(a)} {pp(b)}: {body}\n'
for mode in ['All','Row']:
 s+=f'        case S.{mode}{{}}:\n          match '+('a' if mode=='All' else 'b')+':\n'
 for obj in variants('x',[]):
  n,x=obj
  if n=='Chain':
   la,lb,lm,ra,rb,rm=(x[0],'b','Row',x[1],'b','All') if mode=='All' else ('a',x[0],'Pair','a',x[1],'Row')
   l=derive('left',lm,la,lb);r=derive('right',rm,ra,rb)
   args=f'{x[0]}, {x[1]}, b' if mode=='All' else f'a, {x[0]}, {x[1]}'
   body=f'F.{mode.lower()}({args}, '+rec('left',lm,la,lb,al(l,r))+', '+rec('right',rm,ra,rb,ar(l,r))+')'
  else:body=bad(mode,obj if mode=='All' else 'a','b' if mode=='All' else obj)
  s+=f'            case {pp(obj)}: {body}\n'
Path('proofs/compatibility_complete.bend').write_text(s)
