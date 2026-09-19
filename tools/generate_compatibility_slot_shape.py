"""Prove the public active-slot expansion establishes its internal invariant."""
from pathlib import Path
import re
cs=[(n,len(f.split(',')) if f else 0) for n,f in re.findall(r'^  (\w+)\{([^}]*)\}',Path('types/schema.bend').read_text().split('type Value')[0],re.M)]
def pat(n,k):return 'T.'+n+'{'+', '.join('x'+str(i) for i in range(k))+'}'
s='''import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../spec/compatibility.bend as S
import ./validator_metadata.bend as M

# Invariant required when relating mode 3 to the independent Slots judgement.
# Arbitrary raw Chain forests need not satisfy it, even if mode 3 accepts them.
def slot_forest(schema: T.Schema) -> Bool:
  match schema:
    case T.End{}: True{}
    case T.Chain{T.Null{}, tail}: slot_forest(tail)
    case T.Chain{T.Named{name, field}, tail}: slot_forest(tail)
    case _: False{}

law active_fields_establish_slots:
  for +active: +List<Bool>
  for +names: +List<String>
  for +fields: T.Schema
  {slot_forest(I.active_fields(active, names, fields)) == True{} : Bool}
def active_fields_establish_slots(active, names, fields):
  match active:
    case Nil{}: {==}
    case Con{False{}, tail}: active_fields_establish_slots(tail, names, fields)
    case Con{True{}, tail}:
      match names fields:
'''
for n,k in cs:
 s+=f'        case Nil{{}} {pat(n,k)}: {{==}}\n'
 s+='        case Con{name, ns} T.Chain{field, fs}: active_fields_establish_slots(tail, ns, fs)\n' if n=='Chain' else f'        case Con{{name, ns}} {pat(n,k)}: {{==}}\n'
s+='''
law normative_slots_establish_slots:
  for +active: +List<Bool>
  for +names: +List<String>
  for +fields: T.Schema
  {slot_forest(S.slots(active, names, fields)) == True{} : Bool}
def normative_slots_establish_slots(active, names, fields):
  %M.active_slots(active, names, fields) : {slot_forest(_) == True{} : Bool}
  active_fields_establish_slots(active, names, fields)
'''
Path('proofs/compatibility_slot_shape.bend').write_text(s)
