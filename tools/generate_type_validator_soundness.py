"""Structural validator soundness, including finite compatibility witnesses."""
from pathlib import Path
import re
cs=[(n,len(f.split(',')) if f else 0) for n,f in re.findall(r'^  (\w+)\{([^}]*)\}',Path('types/schema.bend').read_text().split('type Value')[0],re.M)]
def pp(n,args):return 'T.'+n+'{'+', '.join(args)+'}'
def tree(xs):return xs[0] if len(xs)==1 else f'Bool.and({xs[0]}, {tree(xs[1:])})'
def get(xs,i,h='accepted'):
 if len(xs)==1:return h
 l,r=xs[0],tree(xs[1:]);return f'V.and_left({l}, {r}, {h})' if i==0 else get(xs[1:],i-1,f'V.and_right({l}, {r}, {h})')
s='''import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../src/lists.bend as Lists
import ../spec/type_legality.bend as S
import ./compatibility_soundness.bend as Compatibility
import ./validator_selectors.bend as Selectors
import ./validator_metadata.bend as Metadata
import ./validator_fields.bend as Fields
import ./primitive_invariants.bend as V
import ./bit_vector_inverse.bend as Eq
import ./lists.bend as L
import ./word_facts.bend as W

law positive:
  for +fields: T.Schema
  for accepted: {Nat.is_lt(0n, I.count(fields)) == True{} : Bool}
  {Nat.is_lt(0n, S.field_count(fields)) == True{} : Bool}
def positive(fields, accepted):
  %Metadata.field_count(fields) : {Nat.is_lt(0n, _) == True{} : Bool}
  accepted

law limited:
  for +fields: T.Schema
  for +limit: Nat
  for accepted: {Nat.is_le(I.count(fields), limit) == True{} : Bool}
  {Nat.is_le(S.field_count(fields), limit) == True{} : Bool}
def limited(fields, limit, accepted):
  %Metadata.field_count(fields) : {Nat.is_le(_, limit) == True{} : Bool}
  accepted

law active_length:
  for +active: +List<Bool>
  for accepted: {Nat.is_le(Lists.length(Bool, active), 256n) == True{} : Bool}
  {Nat.is_le(List.length(&2, Bool, active), 256n) == True{} : Bool}
def active_length(active, accepted):
  %L.length_correct(Bool, active) : {Nat.is_le(_, 256n) == True{} : Bool}
  accepted

law active_count:
  for +active: +List<Bool>
  for +fields: T.Schema
  for accepted: {Nat.is_eq(I.active_count(active, 0n), I.count(fields)) == True{} : Bool}
  {S.active_count(active) == S.field_count(fields) : Nat}
def active_count(active, fields, accepted):
  %Metadata.active_count(active) : {_ == S.field_count(fields) : Nat}
  %Metadata.field_count(fields) : {I.active_count(active, 0n) == _ : Nat}
  Eq.nat_equal_sound(I.active_count(active, 0n), I.count(fields), accepted)

law selector_count:
  for +ids: +List<U32>
  for +fields: T.Schema
  for accepted: {Nat.is_eq(Lists.length(U32, ids), I.count(fields)) == True{} : Bool}
  {List.length(&2, U32, ids) == S.field_count(fields) : Nat}
def selector_count(ids, fields, accepted):
  %L.length_correct(U32, ids) : {_ == S.field_count(fields) : Nat}
  %Metadata.field_count(fields) : {Lists.length(U32, ids) == _ : Nat}
  Eq.nat_equal_sound(Lists.length(U32, ids), I.count(fields), accepted)

law last_active:
  for +active: +List<Bool>
  for accepted: {I.ends_active(active, False{}) == True{} : Bool}
  {S.last_active(active) == True{} : Bool}
def last_active(active, accepted):
  %Fields.last_active(active) : {_ == True{} : Bool}
  accepted

law sound:
  for +schema: T.Schema
  for +forest: Bool
  for +accepted: {I.valid_go(schema, forest) == True{} : Bool}
  S.legal(schema, forest)
def sound(schema, forest, accepted):
  match schema:
'''
for n,k in cs:
 if n=='Union':continue
 x=['x'+str(i) for i in range(k)];a=pp(n,x);leaves=['Bool.not(forest)'];parts=[]
 if n in ['Null','Repeat','Named']:
  s+=f'    case {a}: W.false_true(accepted)\n';continue
 if n=='End':s+=f'    case {a}: accepted\n';continue
 if n=='Chain':
  leaves=['forest',f'I.valid_go({x[0]}, False{{}})',f'I.valid_go({x[1]}, True{{}})'];parts=[get(leaves,0),f'sound({x[0]}, False{{}}, {get(leaves,1)})',f'sound({x[1]}, True{{}}, {get(leaves,2)})']
 else:
  if n in ['ByteVector','BitVector']:leaves+=[f'Nat.is_lt(0n, {x[0]})']
  elif n=='Vector':leaves +=[f'Nat.is_lt(0n, {x[1]})',f'I.valid_go({x[0]}, False{{}})']
  elif n in ['ListOf','ProgressiveList']:leaves +=[f'I.valid_go({x[0]}, False{{}})']
  elif n in ['Container','ProgressiveContainer']:
   leaves +=[f'I.named_fields_valid({x[0]}, {x[1]})',f'I.valid_go({x[1]}, True{{}})']
   if n=='ProgressiveContainer':leaves +=[f'Nat.is_le(Lists.length(Bool, {x[2]}), 256n)',f'I.ends_active({x[2]}, False{{}})',f'Nat.is_eq(I.active_count({x[2]}, 0n), I.count({x[1]}))']
  elif n=='CompatibleUnion':leaves +=[f'Nat.is_lt(0n, I.count({x[1]}))',f'Nat.is_eq(Lists.length(U32, {x[0]}), I.count({x[1]}))',f'I.selectors_valid({x[0]}, [])',f'I.valid_go({x[1]}, True{{}})',f'I.compatible_go(Nat.mul(1024n, 1n+I.weight({x[1]})), 1, {x[1]}, {x[1]})']
  parts=[f'Selectors.not_true(forest, {get(leaves,0)})']
  if n in ['ByteVector','BitVector']:parts +=[get(leaves,1)]
  elif n=='Vector':parts +=[get(leaves,1),f'sound({x[0]}, False{{}}, {get(leaves,2)})']
  elif n in ['ListOf','ProgressiveList']:parts +=[f'sound({x[0]}, False{{}}, {get(leaves,1)})']
  elif n in ['Container','ProgressiveContainer']:
   parts +=[f'Fields.named_sound({x[0]}, {x[1]}, {get(leaves,1)})',f'sound({x[1]}, True{{}}, {get(leaves,2)})']
   if n=='ProgressiveContainer':parts +=[f'active_length({x[2]}, {get(leaves,3)})',f'last_active({x[2]}, {get(leaves,4)})',f'active_count({x[2]}, {x[1]}, {get(leaves,5)})']
  elif n=='CompatibleUnion':parts +=[f'positive({x[1]}, {get(leaves,1)})',f'selector_count({x[0]}, {x[1]}, {get(leaves,2)})',f'Selectors.sound({x[0]}, [], {get(leaves,3)})',f'sound({x[1]}, True{{}}, {get(leaves,4)})',f'Compatibility.options_sound({x[1]}, {get(leaves,5)})']
 s+=f'    case {a}: '+ ('('+', '.join(parts)+')' if len(parts)>1 else parts[0])+'\n'
for n,k in cs:
 x=['u'+str(i) for i in range(k)]
 if n!='Chain':s+=f'    case T.Union{{{pp(n,x)}}}: W.false_true(accepted)\n';continue
 for h,l in cs:
  z=['h'+str(i) for i in range(l)];head=pp(h,z);tail='tail';case=f'T.Union{{T.Chain{{{head}, tail}}}}'
  if h=='Null':leaves=['Bool.not(forest)','Nat.is_lt(0n, I.count(tail))','Nat.is_le(I.count(tail), 127n)','I.valid_go(tail, True{})'];parts=[f'Selectors.not_true(forest, {get(leaves,0)})',f'positive(tail, {get(leaves,1)})',f'limited(tail, 127n, {get(leaves,2)})',f'sound(tail, True{{}}, {get(leaves,3)})']
  else:
   leaves=['Bool.not(forest)','Nat.is_le(I.count(tail), 127n)',f'I.valid_go({head}, False{{}})','I.valid_go(tail, True{})'];parts=[f'Selectors.not_true(forest, {get(leaves,0)})',f'limited(tail, 127n, {get(leaves,1)})',f'sound({head}, False{{}}, {get(leaves,2)})',f'sound(tail, True{{}}, {get(leaves,3)})']
  s+=f'    case {case}: ('+', '.join(parts)+')\n'
s+='''
law public_sound:
  for +schema: T.Schema
  for accepted: {I.valid(schema) == True{} : Bool}
  S.type_legal(schema)
def public_sound(schema, accepted): sound(schema, False{}, accepted)
'''
Path('proofs/type_validator_soundness.bend').write_text(s)
