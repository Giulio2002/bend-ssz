"""Generate proof cases constructing independent finite derivations.
Only Schema constructors are enumerated; no fixtures or expected test outputs.
"""
from pathlib import Path
exec(Path('tools/generate_compatibility_monotone.py').read_text().split("out='''")[0])
# Reuse only neutral constructor rendering/actual branch-expression helpers.
def rec(f,mode,a,b,h,domain='Unit{}'):
 return f'sound({f}, S.{mode}{{}}, {pp(a)}, {pp(b)}, {domain}, {h})'
def al(a,b,h):return f'V.and_left({a}, {b}, {h})'
def ar(a,b,h):return f'V.and_right({a}, {b}, {h})'
def impossible(mode,a,b,h):return f'Empty.absurd(D.evidence(S.{mode}{{}}, {pp(a)}, {pp(b)}), W.false_true({h}))'
s='''import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../src/primitives.bend as P
import ../spec/compatibility.bend as S
import ./compatibility_derivation.bend as D
import ./compatibility_named.bend as Named
import ./compatibility_identity.bend as Identity
import ./compatibility_positions.bend as Positions
import ./compatibility_slot_shape.bend as Shape
import ./validator_metadata.bend as M
import ./primitive_invariants.bend as V
import ./word_facts.bend as W
import ./compatibility_choice.bend as Choice

def code(mode: S.Judgement) -> U32:
  match mode:
    case S.Pair{}: 0
    case S.All{}: 1
    case S.Row{}: 2
    case S.Slots{}: 3

def requirement(mode: S.Judgement, a: T.Schema, b: T.Schema) -> Type:
  match mode:
    case S.Slots{}: {Shape.slot_forest(a) == True{} : Bool} & {Shape.slot_forest(b) == True{} : Bool}
    case _: Unit

law progressive:
  for +na: +List<String>
  for +fa: T.Schema
  for +aa: +List<Bool>
  for +nb: +List<String>
  for +fb: T.Schema
  for +ab: +List<Bool>
  for positions: {I.shared_positions(I.active_fields(aa, na, fa), I.active_fields(ab, nb, fb), 0n) == True{} : Bool}
  for child: D.evidence(S.Slots{}, I.active_fields(aa, na, fa), I.active_fields(ab, nb, fb))
  S.compatible(T.ProgressiveContainer{na, fa, aa}, T.ProgressiveContainer{nb, fb, ab})
def progressive(na, fa, aa, nb, fb, ab, positions, child):
  D.progressive_container(na, fa, aa, nb, fb, ab,
    %M.active_slots(aa, na, fa) : {S.shared_positions(_, S.slots(ab, nb, fb), 0n) == True{} : Bool}
    %M.active_slots(ab, nb, fb) : {S.shared_positions(I.active_fields(aa, na, fa), _, 0n) == True{} : Bool}
    %Positions.shared_positions(I.active_fields(aa, na, fa), I.active_fields(ab, nb, fb), 0n) : {_ == True{} : Bool}
    positions,
    %M.active_slots(aa, na, fa) : D.evidence(S.Slots{}, _, S.slots(ab, nb, fb))
    %M.active_slots(ab, nb, fb) : D.evidence(S.Slots{}, I.active_fields(aa, na, fa), _)
    child)

# Every successful actual traversal has an independent finite derivation.
# The sole auxiliary invariant (for Slots) is established by active expansion.
law sound:
  for +fuel: Nat
  for +mode: S.Judgement
  for +a: T.Schema
  for +b: T.Schema
  for slots: requirement(mode, a, b)
  for +accepted: {I.compatible_go(fuel, code(mode), a, b) == True{} : Bool}
  D.evidence(mode, a, b)
def sound(fuel, mode, a, b, slots, accepted):
  match fuel:
    case 0n: Empty.absurd(D.evidence(mode, a, b), W.false_true(accepted))
    case 1n+p:
      match mode:
'''
for mode in ['All','Row']:
 s+=f'        case S.{mode}{{}}:\n          match '+('a' if mode=='All' else 'b')+':\n'
 for a in variants('x',[]):
  n,x=a
  if n=='End':body='(S.Leaf{}, {==})'
  elif n=='Chain':
   if mode=='All':
    l=call(2,x[0],'b');r=call(1,x[1],'b');body=f'D.all({x[0]}, {x[1]}, b, '+rec('p','Row',x[0],'b',al(l,r,'accepted'))+', '+rec('p','All',x[1],'b',ar(l,r,'accepted'))+')'
   else:
    l=call(0,'a',x[0]);r=call(2,'a',x[1]);body=f'D.row(a, {x[0]}, {x[1]}, '+rec('p','Pair','a',x[0],al(l,r,'accepted'))+', '+rec('p','Row','a',x[1],ar(l,r,'accepted'))+')'
  else:body=impossible(mode,a if mode=='All' else 'a','b' if mode=='All' else a,'accepted')
  s+=f'            case {pp(a)}: {body}\n'
s+='        case S.Slots{}:\n          match a b:\n'
for a in variants('a',['Chain']):
 for b in variants('b',['Chain']):
  n,x=a;m,y=b
  s+=f'            case {pp(a)} {pp(b)}:\n'
  pad='              '
  if n=='End' or m=='End':body='(S.Leaf{}, {==})'
  elif n!='Chain' or x[0][0] not in ['Null','Named']:body=impossible('Slots',a,b,'left')
  elif m!='Chain' or y[0][0] not in ['Null','Named']:body=impossible('Slots',a,b,'right')
  else:
   hx,hy=x[0][0],y[0][0]
   if hx=='Null' or hy=='Null':
    rest=rec('p','Slots',x[1],y[1],'accepted','(left, right)')
    if hx==hy=='Null':body=f'D.skip_both({x[1]}, {y[1]}, {rest})'
    elif hx=='Null':body=f'D.skip_left({x[1]}, '+', '.join(y[0][1])+f', {y[1]}, {rest})'
    else:body='D.skip_right('+', '.join(x[0][1])+f', {x[1]}, {y[1]}, {rest})'
   else:
    na,fa=x[0][1];nb,fb=y[0][1];paircall=call(0,x[0],y[0]);tailcall=call(3,x[1],y[1]);hp=al(paircall,tailcall,'accepted');tp=ar(paircall,tailcall,'accepted')
    body=f'D.slots_named({na}, {fa}, {x[1]}, {nb}, {fb}, {y[1]}, Named.names(p, {na}, {fa}, {nb}, {fb}, {hp}), '+rec('p','Pair',fa,fb,f'Named.child(p, {na}, {fa}, {nb}, {fb}, {hp})')+', '+rec('p','Slots',x[1],y[1],tp,'(left, right)')+')'
  s+=pad+'(left, right) = slots\n'+pad+body+'\n'
s+='        case S.Pair{}:\n          match a b:\n'
for a in variants('a',['Vector','ListOf']):
 for b in variants('b',['Vector','ListOf']):
  n,x=a;m,y=b;expr=pair(a,b);choice=None
  if expr.startswith('Bool.or('):choice,expr=splitargs(expr[8:-1])
  s+=f'            case {pp(a)} {pp(b)}:\n';pad='              '
  if expr=='False{}':body=impossible('Pair',a,b,'accepted')
  elif n!=m or n in ['Boolean','Unsigned','ByteVector','ByteList','BitVector','BitList','ProgressiveBits','Null','End','Union']:
   body=f'(S.Leaf{{}}, Identity.identical_sound({pp(a)}, {pp(b)}, accepted))'
  elif n in ['Vector','ListOf','Container','Named']:
   l,r=splitargs(expr[9:-1]);meta=al(l,r,'accepted');child=rec('p','Pair',x[0] if n in ['Vector','ListOf'] else x[1],y[0] if n in ['Vector','ListOf'] else y[1],ar(l,r,'accepted'))
   if n=='Container':meta=f'%M.names_equal({x[0]}, {y[0]}) : {{_ == True{{}} : Bool}}\n'+pad+'  '+meta
   args=[pp(x[0]),pp(y[0]),pp(x[1]),pp(y[1])] if n in ['Vector','ListOf'] else [x[0],y[0],x[1],y[1]]
   body='D.'+{'Vector':'vector','ListOf':'list','Container':'container','Named':'named'}[n]+'('+', '.join(args)+', '+meta+', '+child+')'
  elif n=='ProgressiveList':body='D.progressive_list('+pp(x[0])+', '+pp(y[0])+', '+rec('p','Pair',x[0],y[0],'accepted')+')'
  elif n=='CompatibleUnion':body=f'D.union({x[0]}, {y[0]}, {x[1]}, {y[1]}, '+rec('p','All',x[1],y[1],'accepted')+')'
  elif n=='Chain':
   l,r=splitargs(expr[9:-1]);body=f'D.chain({x[0]}, {x[1]}, {y[0]}, {y[1]}, '+rec('p','Pair',x[0],y[0],al(l,r,'accepted'))+', '+rec('p','Pair',x[1],y[1],ar(l,r,'accepted'))+')'
  elif n=='ProgressiveContainer':
   l,r=splitargs(expr[9:-1]);ax=f'I.active_fields({x[2]}, {x[0]}, {x[1]})';by=f'I.active_fields({y[2]}, {y[0]}, {y[1]})'
   domain=f'(Shape.active_fields_establish_slots({x[2]}, {x[0]}, {x[1]}), Shape.active_fields_establish_slots({y[2]}, {y[0]}, {y[1]}))'
   body='progressive('+', '.join(x+y)+', '+al(l,r,'accepted')+', '+rec('p','Slots',ax,by,ar(l,r,'accepted'),domain)+')'
  else:raise ValueError(n)
  if choice is not None:
   body=f'Choice.sound({pp(a)}, {pp(b)}, {choice}, {expr}, direct => Identity.identical_sound({pp(a)}, {pp(b)}, direct), accepted_tail => '+body.replace('accepted','accepted_tail')+', accepted)'
  s+=pad+body+'\n'
s+='''
law public_sound:
  for +a: T.Schema
  for +b: T.Schema
  for accepted: {I.compatible(a, b) == True{} : Bool}
  S.compatible(a, b)
def public_sound(a, b, accepted):
  sound(Nat.mul(1024n, 1n+Nat.add(I.weight(a), I.weight(b))), S.Pair{}, a, b, Unit{}, accepted)

law options_sound:
  for +options: T.Schema
  for accepted: {I.compatible_go(Nat.mul(1024n, 1n+I.weight(options)), 1, options, options) == True{} : Bool}
  S.mutually_compatible(options)
def options_sound(options, accepted):
  sound(Nat.mul(1024n, 1n+I.weight(options)), S.All{}, options, options, Unit{}, accepted)
'''
Path('proofs/compatibility_soundness.bend').write_text(s)
