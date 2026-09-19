"""Generate structural invariant proofs; the installed Bend checker checks every term."""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
ctors={'Boolean':[], 'Unsigned':['w'], 'ByteVector':['n'], 'ByteList':['n'], 'BitVector':['n'], 'BitList':['n'], 'Vector':['e','n'], 'ListOf':['e','n'], 'Container':['names','fields'], 'Union':['options'], 'Null':[], 'Chain':['h','t'], 'End':[], 'Repeat':['e'], 'Named':['name','e'], 'ProgressiveList':['e'], 'ProgressiveBits':[], 'ProgressiveContainer':['names','fields','active'], 'CompatibleUnion':['selectors','options']}
def term(k,vs):return 'T.'+k+'{'+', '.join(vs)+'}'
def expr(ts):return ts[0] if len(ts)==1 else 'Bool.and('+ts[0]+', '+expr(ts[1:])+')'
def get(ts,i,p='legal'):
 if len(ts)==1:return p
 if i==0:return 'V.and_left('+ts[0]+', '+expr(ts[1:])+', '+p+')'
 return get(ts[1:],i-1,'V.and_right('+ts[0]+', '+expr(ts[1:])+', '+p+')')
def both(a,b,pa,pb):return 'V.and_true('+a+', '+b+', '+pa+', '+pb+')'
s='''import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../src/lists.bend as Lists
import ../spec/schema_forest.bend as S
import ./primitive_invariants.bend as V
import ./word_facts.bend as W

law valid_forest:
  for +schema: T.Schema
  for legal: {I.valid_go(schema, True{}) == True{} : Bool}
  {S.finite(schema) == True{} : Bool}
def valid_forest(schema, legal):
  match schema:
'''
for k,vs in ctors.items():
 if k=='Chain':s+='    case T.Chain{h, t}: valid_forest(t, V.and_right(I.valid_go(h, False{}), I.valid_go(t, True{}), legal))\n'
 elif k=='End':s+='    case T.End{}: {==}\n'
 elif k=='Union':
  s+='    case T.Union{options}:\n      match options:\n'
  for j,ws in ctors.items():
   if j=='Chain':
    s+='        case T.Chain{h, t}:\n          match h:\n'
    for q,rs in ctors.items():s+='            case '+term(q,['v'+str(i) for i in range(len(rs))])+': Empty.absurd({False{} == True{} : Bool}, W.false_true(legal))\n'
   else:s+='        case '+term(j,['v'+str(i) for i in range(len(ws))])+': Empty.absurd({False{} == True{} : Bool}, W.false_true(legal))\n'
 else:s+='    case '+term(k,vs)+': Empty.absurd({False{} == True{} : Bool}, W.false_true(legal))\n'
for label,index in [('head_well_formed',0),('tail_finite',1),('tail_well_formed',2)]:
 ts=['S.well_formed(h)','S.finite(t)','S.well_formed(t)']
 s+='\nlaw chain_'+label+':\n  for +h: T.Schema\n  for +t: T.Schema\n  for legal: {S.well_formed(T.Chain{h, t}) == True{} : Bool}\n  {'+ts[index]+' == True{} : Bool}\ndef chain_'+label+'(h, t, legal):\n  '+get(ts,index)+'\n'
def forest_result(fields,proof):return both('S.finite('+fields+')','S.well_formed('+fields+')','valid_forest('+fields+', '+proof+')','valid_well_formed('+fields+', True{}, '+proof+')')
s+='''
law valid_well_formed:
  for +schema: T.Schema
  for +forest: Bool
  for +legal: {I.valid_go(schema, forest) == True{} : Bool}
  {S.well_formed(schema) == True{} : Bool}
def valid_well_formed(schema, forest, legal):
  match schema:
'''
for k,vs in ctors.items():
 body='{==}'
 if k=='Vector':body='valid_well_formed(e, False{}, '+get(['Bool.not(forest)','Nat.is_lt(0n, n)','I.valid_go(e, False{})'],2)+')'
 elif k in ('ListOf','ProgressiveList'):body='valid_well_formed(e, False{}, '+get(['Bool.not(forest)','I.valid_go(e, False{})'],1)+')'
 elif k in ('Repeat','Named'):body='Empty.absurd({S.well_formed(e) == True{} : Bool}, W.false_true(legal))'
 elif k=='Chain':
  ts=['forest','I.valid_go(h, False{})','I.valid_go(t, True{})'];body=both('S.well_formed(h)','Bool.and(S.finite(t), S.well_formed(t))','valid_well_formed(h, False{}, '+get(ts,1)+')',forest_result('t',get(ts,2)))
 elif k in ('Container','ProgressiveContainer'):
  ts=['Bool.not(forest)','I.named_fields_valid(names, fields)','I.valid_go(fields, True{})']
  if k=='ProgressiveContainer':ts+=['Bool.and(Nat.is_le(Lists.length(Bool, active), 256n), Bool.and(I.ends_active(active, False{}), Nat.is_eq(I.active_count(active, 0n), I.count(fields))))']
  body=forest_result('fields',get(ts,2))
 elif k=='CompatibleUnion':
  ts=['Bool.not(forest)','Nat.is_lt(0n, I.count(options))','Nat.is_eq(Lists.length(U32, selectors), I.count(options))','I.selectors_valid(selectors, [])','I.valid_go(options, True{})','I.compatible_go(Nat.mul(1024n, 1n+I.weight(options)), 1, options, options)'];body=forest_result('options',get(ts,4))
 elif k=='Union':
  s+='    case T.Union{options}:\n      match options:\n'
  for j,ws in ctors.items():
   if j!='Chain':
    opt=term(j,['v'+str(i) for i in range(len(ws))]);s+='        case '+opt+': Empty.absurd({S.well_formed(T.Union{'+opt+'}) == True{} : Bool}, W.false_true(legal))\n';continue
   s+='        case T.Chain{h, t}:\n          match h:\n'
   for q,rs in ctors.items():
    h=term(q,['v'+str(i) for i in range(len(rs))])
    if q=='Null':
     ts=['Bool.not(forest)','Nat.is_lt(0n, I.count(t))','Nat.is_le(I.count(t), 127n)','I.valid_go(t, True{})'];tp=get(ts,3);hp='{==}'
    else:
     ts=['Bool.not(forest)','Nat.is_le(I.count(t), 127n)','I.valid_go('+h+', False{})','I.valid_go(t, True{})'];tp=get(ts,3);hp='valid_well_formed('+h+', False{}, '+get(ts,2)+')'
    inner=both('S.well_formed('+h+')','Bool.and(S.finite(t), S.well_formed(t))',hp,forest_result('t',tp))
    body=both('S.finite(t)','S.well_formed(T.Chain{'+h+', t})','valid_forest(t, '+tp+')',inner)
    s+='            case '+h+': '+body+'\n'
  continue
 s+='    case '+term(k,vs)+': '+body+'\n'
(ROOT/'proofs/schema_forest.bend').write_text(s)
