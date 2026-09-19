"""Structural measures for compatibility, with public expansion bounds."""
from pathlib import Path
import re
cs=[(n,len(f.split(',')) if f else 0) for n,f in re.findall(r'^  (\w+)\{([^}]*)\}',Path('types/schema.bend').read_text().split('type Value')[0],re.M)]
def pat(n,k):return 'T.'+n+'{'+', '.join('x'+str(i) for i in range(k))+'}'
s='''import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../spec/compatibility.bend as S
import ./nat_order.bend as Order
import ./validator_metadata.bend as Metadata

# Count field subtrees once while ignoring inserted inactive slots and names.
# This is a proof measure, never a protocol capacity or an execution limit.
def payload(schema: T.Schema) -> Nat:
  match schema:
    case T.Chain{T.Null{}, tail}: payload(tail)
    case T.Chain{T.Named{name, field}, tail}: 1n+Nat.add(I.weight(field), payload(tail))
    case _: 1n

law weight_positive:
  for +schema: T.Schema
  {Nat.is_le(1n, I.weight(schema)) == True{} : Bool}
def weight_positive(schema):
  match schema:
'''
for n,k in cs:
 if n in ['Vector','ListOf','Repeat','ProgressiveList']: body='Order.zero_le(I.weight(x0))'
 elif n in ['Named','Container','ProgressiveContainer','CompatibleUnion']:body='Order.zero_le(I.weight(x1))'
 elif n=='Union':body='Order.zero_le(I.weight(x0))'
 elif n=='Chain':body='Order.zero_le(Nat.add(I.weight(x0), I.weight(x1)))'
 else:body='{==}'
 s+=f'    case {pat(n,k)}: {body}\n' 
s+='''
law expansion_payload_bound:
  for +active: +List<Bool>
  for +names: +List<String>
  for +fields: T.Schema
  {Nat.is_le(payload(I.active_fields(active, names, fields)), I.weight(fields)) == True{} : Bool}
def expansion_payload_bound(active, names, fields):
  match active:
    case Nil{}: weight_positive(fields)
    case Con{False{}, tail}: expansion_payload_bound(tail, names, fields)
    case Con{True{}, tail}:
      match names fields:
'''
for n,k in cs:
 s+=f'        case Nil{{}} {pat(n,k)}: weight_positive({pat(n,k)})\n'
 if n=='Chain':s+='''        case Con{name, ns} T.Chain{field, fs}:
          Order.add_left(I.weight(field), payload(I.active_fields(tail, ns, fs)), I.weight(fs), expansion_payload_bound(tail, ns, fs))
'''
 else:s+=f'        case Con{{name, ns}} {pat(n,k)}: weight_positive({pat(n,k)})\n'
s+='''
law normative_expansion_payload_bound:
  for +active: +List<Bool>
  for +names: +List<String>
  for +fields: T.Schema
  {Nat.is_le(payload(S.slots(active, names, fields)), I.weight(fields)) == True{} : Bool}
def normative_expansion_payload_bound(active, names, fields):
  %Metadata.active_slots(active, names, fields) : {Nat.is_le(payload(_), I.weight(fields)) == True{} : Bool}
  expansion_payload_bound(active, names, fields)
'''
Path('proofs/compatibility_measure.bend').write_text(s)
