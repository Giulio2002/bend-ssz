"""Prove stabilization above a structural rank for all public-path modes."""
from pathlib import Path
exec(Path('tools/generate_compatibility_monotone.py').read_text().split("out='''")[0])
def al(a,b,h):return f'V.and_left({a}, {b}, {h})'
def ar(a,b,h):return f'V.and_right({a}, {b}, {h})'
def safe(s):return f'B.bounded({pp(s)})'
def weight(s):return f'I.weight({pp(s)})'
def rank(mode,a,b):return f'R.rank(S.{mode}{{}}, {pp(a)}, {pp(b)})'
def rec(mode,a,b,pa,pb,pm,sa,sb,step,sh='Unit{}'):
 return f'stable(p, extra, S.{mode}{{}}, {pp(a)}, {pp(b)}, {sh}, {sa}, {sb}, R.child_budget({rank(mode,a,b)}, {rank(pm,pa,pb)}, p, {step}, enough))'
def leftstep(a,b,pa,pb,l,r):return f'R.left_step({pp(a)}, {pp(b)}, {pp(pa)}, {pp(pb)}, {l}, {r})'
def rightstep(a,b,pa,pb,l,r):return f'R.right_step({pp(a)}, {pp(b)}, {pp(pa)}, {pp(pb)}, {l}, {r})'
def eqand(a,b,left,right):return f'and_equal({a}, {b}, {newer(a)}, {newer(b)}, {left}, {right})'
s='''import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../spec/compatibility.bend as S
import ./compatibility_soundness.bend as Sound
import ./compatibility_bounded.bend as B
import ./compatibility_slot_shape.bend as Shape
import ./compatibility_rank.bend as R
import ./nat_order.bend as O
import ./primitive_invariants.bend as V
import ./word_facts.bend as W
import ./compatibility_choice.bend as Choice

law and_equal:
  for +a: Bool
  for +b: Bool
  for +c: Bool
  for +d: Bool
  for left: {a == c : Bool}
  for right: {b == d : Bool}
  {Bool.and(a, b) == Bool.and(c, d) : Bool}
def and_equal(a, b, c, d, left, right):
  %left : {Bool.and(a, b) == Bool.and(_, d) : Bool}
  %right : {Bool.and(a, b) == Bool.and(a, _) : Bool}
  {==}

# Extra fuel cannot affect a traversal once the structural rank is met.
# Recursive active-list bounds are derived from legal public types separately.
law stable:
  for +fuel: Nat
  for +extra: Nat
  for +mode: S.Judgement
  for +a: T.Schema
  for +b: T.Schema
  for shape: Sound.requirement(mode, a, b)
  for +safe_a: {B.bounded(a) == True{} : Bool}
  for +safe_b: {B.bounded(b) == True{} : Bool}
  for +enough: {Nat.is_le(R.rank(mode, a, b), fuel) == True{} : Bool}
  {I.compatible_go(fuel, Sound.code(mode), a, b) == I.compatible_go(Nat.add(fuel, extra), Sound.code(mode), a, b) : Bool}
def stable(fuel, extra, mode, a, b, shape, safe_a, safe_b, enough):
  match fuel:
    case 0n: Empty.absurd({I.compatible_go(0n, Sound.code(mode), a, b) == I.compatible_go(extra, Sound.code(mode), a, b) : Bool}, W.false_true(O.transitive(1n, R.rank(mode, a, b), 0n, R.positive(mode, a, b), enough)))
    case 1n+p:
      match mode:
'''
for mode in ['All','Row']:
 s+=f'        case S.{mode}{{}}:\n          match '+('a' if mode=='All' else 'b')+':\n'
 for obj in variants('x',[]):
  n,x=obj;s+=f'            case {pp(obj)}: '
  if n!='Chain':s+='{==}\n';continue
  head,tail=x;hbound=al(safe(head),safe(tail),'safe_a' if mode=='All' else 'safe_b');tbound=ar(safe(head),safe(tail),'safe_a' if mode=='All' else 'safe_b')
  if mode=='All':
   lc=call(2,head,'b');rc=call(1,tail,'b')
   left=rec('Row',head,'b',obj,'b',mode,hbound,'safe_b',leftstep(head,'b',obj,'b',f'R.chain_head({head}, {tail})','O.reflexive(I.weight(b))'))
   right=rec('All',tail,'b',obj,'b',mode,tbound,'safe_b',leftstep(tail,'b',obj,'b',f'R.chain_tail({head}, {tail})','O.reflexive(I.weight(b))'))
  else:
   lc=call(0,'a',head);rc=call(2,'a',tail)
   left=rec('Pair','a',head,'a',obj,mode,'safe_a',hbound,rightstep('a',head,'a',obj,'O.reflexive(I.weight(a))',f'R.chain_head({head}, {tail})'))
   right=rec('Row','a',tail,'a',obj,mode,'safe_a',tbound,rightstep('a',tail,'a',obj,'O.reflexive(I.weight(a))',f'R.chain_tail({head}, {tail})'))
  s+=eqand(lc,rc,left,right)+'\n'
s+='        case S.Slots{}:\n          match a b:\n'
for a in variants('a',['Chain']):
 for b in variants('b',['Chain']):
  n,x=a;m,y=b;s+=f'            case {pp(a)} {pp(b)}:\n';pad='              '
  if n=='End' or m=='End':s+=pad+'{==}\n';continue
  s+=pad+'(left_shape, right_shape) = shape\n'
  if n!='Chain' or x[0][0] not in ['Null','Named']:
   s+=pad+f'Empty.absurd({{I.compatible_go(1n+p, 3, {pp(a)}, {pp(b)}) == I.compatible_go(1n+Nat.add(p, extra), 3, {pp(a)}, {pp(b)}) : Bool}}, W.false_true(left_shape))\n';continue
  if m!='Chain' or y[0][0] not in ['Null','Named']:
   s+=pad+f'Empty.absurd({{I.compatible_go(1n+p, 3, {pp(a)}, {pp(b)}) == I.compatible_go(1n+Nat.add(p, extra), 3, {pp(a)}, {pp(b)}) : Bool}}, W.false_true(right_shape))\n';continue
  ha,ta=x;hb,tb=y
  def payload(h,t):return f'R.null_payload({t})' if h[0]=='Null' else 'R.named_payload('+', '.join(h[1])+f', {t})'
  step=f'R.slots_tail_step({pp(ha)}, {ta}, {pp(hb)}, {tb}, {payload(ha,ta)}, {payload(hb,tb)})'
  tail=rec('Slots',ta,tb,a,b,'Slots',ar(safe(ha),safe(ta),'safe_a'),ar(safe(hb),safe(tb),'safe_b'),step,'(left_shape, right_shape)')
  if ha[0]=='Null' or hb[0]=='Null':body=tail
  else:
   steph='R.named_slot_pair_step('+', '.join(ha[1]+[ta]+hb[1]+[tb])+')'
   head=rec('Pair',ha,hb,a,b,'Slots',al(safe(ha),safe(ta),'safe_a'),al(safe(hb),safe(tb),'safe_b'),steph)
   body=eqand(call(0,ha,hb),call(3,ta,tb),head,tail)
  s+=pad+body+'\n'
s+='        case S.Pair{}:\n          match a b:\n'
for a in variants('a',['Vector','ListOf']):
 for b in variants('b',['Vector','ListOf']):
  n,x=a;m,y=b;expr=pair(a,b);choice=None
  if expr.startswith('Bool.or('):choice,expr=splitargs(expr[8:-1])
  s+=f'            case {pp(a)} {pp(b)}:\n';pad='              '
  if 'I.compatible_go(' not in expr:body='{==}'
  elif n=='Chain':
   headA=al(safe(x[0]),safe(x[1]),'safe_a');tailA=ar(safe(x[0]),safe(x[1]),'safe_a');headB=al(safe(y[0]),safe(y[1]),'safe_b');tailB=ar(safe(y[0]),safe(y[1]),'safe_b')
   def chainweak(h,t,which):return f'O.transitive({weight(which)}, 1n+{weight(which)}, {weight(b)}, O.step_right({weight(which)}, {weight(which)}, O.reflexive({weight(which)})), R.chain_'+('head' if which==h else 'tail')+f'({h}, {t}))'
   lh=leftstep(x[0],y[0],a,b,f'R.chain_head({x[0]}, {x[1]})',chainweak(y[0],y[1],y[0]))
   lt=leftstep(x[1],y[1],a,b,f'R.chain_tail({x[0]}, {x[1]})',chainweak(y[0],y[1],y[1]))
   body=eqand(call(0,x[0],y[0]),call(0,x[1],y[1]),rec('Pair',x[0],y[0],a,b,'Pair',headA,headB,lh),rec('Pair',x[1],y[1],a,b,'Pair',tailA,tailB,lt))
  elif n=='ProgressiveContainer':
   la=f'Nat.is_le(List.length(&2, Bool, {x[2]}), 256n)';lb=f'Nat.is_le(List.length(&2, Bool, {y[2]}), 256n)'
   ax=f'I.active_fields({x[2]}, {x[0]}, {x[1]})';by=f'I.active_fields({y[2]}, {y[0]}, {y[1]})'
   sa=f'B.expansion_bounded({x[2]}, {x[0]}, {x[1]}, '+ar(la,safe(x[1]),'safe_a')+')';sb=f'B.expansion_bounded({y[2]}, {y[0]}, {y[1]}, '+ar(lb,safe(y[1]),'safe_b')+')'
   step='R.progressive_step('+', '.join(x+y)+', '+al(la,safe(x[1]),'safe_a')+', '+al(lb,safe(y[1]),'safe_b')+')'
   sh=f'(Shape.active_fields_establish_slots({x[2]}, {x[0]}, {x[1]}), Shape.active_fields_establish_slots({y[2]}, {y[0]}, {y[1]}))'
   l,r=splitargs(expr[9:-1]);body=eqand(l,r,'{==}',rec('Slots',ax,by,a,b,'Pair',sa,sb,step,sh))
  else:
   idx=1 if n in ['Container','Named','CompatibleUnion'] else 0;ca=x[idx];cb=y[idx];mode='All' if n=='CompatibleUnion' else 'Pair'
   step=leftstep(ca,cb,a,b,f'O.reflexive(1n+{weight(ca)})',f'O.step_right({weight(cb)}, {weight(cb)}, O.reflexive({weight(cb)}))')
   child=rec(mode,ca,cb,a,b,'Pair','safe_a','safe_b',step)
   if expr.startswith('Bool.and('):l,r=splitargs(expr[9:-1]);body=eqand(l,r,'{==}',child)
   else:body=child
  if choice is not None:
   body=f'Choice.stable({choice}, {expr}, {newer(expr)}, {body})'
  s+=pad+body+'\n'
Path('proofs/compatibility_stability.bend').write_text(s)
