"""Generate structural cases for validator metadata refinement (no fixtures)."""
from pathlib import Path
import re
constructors=[]
for name, fields in re.findall(r'^  (\w+)\{([^}]*)\}', Path('types/schema.bend').read_text().split('type Value')[0], re.M):
    constructors.append((name, len(fields.split(',')) if fields else 0))
def pat(name,n): return 'T.'+name+'{'+', '.join('x'+str(i) for i in range(n))+'}'
out='''import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../spec/compatibility.bend as C
import ../spec/type_legality.bend as S
import ./packing.bend as Pack
import ./nat_order.bend as Order

# These laws compare independent metadata definitions; no compatibility or
# validator conclusion is assumed. Slot bounds hold even for malformed inputs.
'''
for law,impl,spec,typ in [('names_equal','names_equal','C.names_equal','String'),('bits_equal','bools_equal','C.bits_equal','Bool'),('selectors_equal','selectors_equal','C.selectors_equal','U32')]:
    out+=f'''\nlaw {law}:
  for +a: +List<{typ}>
  for +b: +List<{typ}>
  {{I.{impl}(a, b) == {spec}(a, b) : Bool}}
def {law}(a, b):
  match a b:
    case Nil{{}} Nil{{}}: {{==}}
    case Nil{{}} Con{{y, ys}}: {{==}}
    case Con{{x, xs}} Nil{{}}: {{==}}
    case Con{{x, xs}} Con{{y, ys}}:
      %{law}(xs, ys) : {{I.{impl}(x <> xs, y <> ys) == Bool.and('''+({'String':'String.eq(x, y)','Bool':'Bool.not(Bool.xor(x, y))','U32':'U32.is_eq(x, y)'}[typ])+''', _) : Bool}
      {==}
'''
out+='''
law field_count:
  for +schema: T.Schema
  {I.count(schema) == S.field_count(schema) : Nat}
def field_count(schema):
  match schema:
'''
for name,n in constructors: out+=f'    case {pat(name,n)}: '+('Equal.cong(Nat, Nat, k => 1n+k, I.count(x1), S.field_count(x1), field_count(x1))' if name=='Chain' else '{==}')+'\n'
for law,impl,spec,typ in [('contains_name','contains_name','S.contains_name','String'),('contains_selector','has_selector','S.contains_selector','U32')]:
    eq='String.eq' if typ=='String' else 'U32.is_eq'
    out+=f'''
law {law}:
  for +name: {typ}
  for +names: +List<{typ}>
  {{I.{impl}(name, names) == {spec}(name, names) : Bool}}
def {law}(name, names):
  match names:
    case Nil{{}}: {{==}}
    case Con{{h, t}}:
      %{law}(name, t) : {{I.{impl}(name, h <> t) == Bool.or({eq}(name, h), _) : Bool}}
      {{==}}
'''
out+='''
law unique_names:
  for +names: +List<String>
  {I.unique_names(names) == S.distinct_names(names) : Bool}
def unique_names(names):
  match names:
    case Nil{}: {==}
    case Con{h, t}:
      %contains_name(h, t) : {I.unique_names(h <> t) == Bool.and(Bool.not(_), S.distinct_names(t)) : Bool}
      %unique_names(t) : {I.unique_names(h <> t) == Bool.and(Bool.not(I.contains_name(h, t)), _) : Bool}
      {==}

law active_count_acc:
  for +active: +List<Bool>
  for +acc: Nat
  {I.active_count(active, acc) == Nat.add(S.active_count(active), acc) : Nat}
def active_count_acc(active, acc):
  match active:
    case Nil{}: {==}
    case Con{False{}, tail}: active_count_acc(tail, acc)
    case Con{True{}, tail}:
      %Pack.add_succ(S.active_count(tail), acc) : {I.active_count(tail, 1n+acc) == _ : Nat}
      active_count_acc(tail, 1n+acc)

law active_count:
  for +active: +List<Bool>
  {I.active_count(active, 0n) == S.active_count(active) : Nat}
def active_count(active):
  Equal.trans(Nat, I.active_count(active, 0n), Nat.add(S.active_count(active), 0n), S.active_count(active), active_count_acc(active, 0n), Pack.add_zero(S.active_count(active)))

law active_slots:
  for +active: +List<Bool>
  for +names: +List<String>
  for +fields: T.Schema
  {I.active_fields(active, names, fields) == C.slots(active, names, fields) : T.Schema}
def active_slots(active, names, fields):
  match active:
    case Nil{}: {==}
    case Con{False{}, tail}:
      Equal.cong(T.Schema, T.Schema, rest => T.Chain{T.Null{}, rest}, I.active_fields(tail, names, fields), C.slots(tail, names, fields), active_slots(tail, names, fields))
    case Con{True{}, tail}:
      match names fields:
'''
for name,n in constructors:
    out+=f'        case Nil{{}} {pat(name,n)}: {{==}}\n'
    if name=='Chain':
        out+='''        case Con{name, ns} T.Chain{field, fs}:
          Equal.cong(T.Schema, T.Schema, rest => T.Chain{T.Named{name, field}, rest}, I.active_fields(tail, ns, fs), C.slots(tail, ns, fs), active_slots(tail, ns, fs))
'''
    else: out+=f'        case Con{{name, ns}} {pat(name,n)}: {{==}}\n'
out+='''
law slot_count_bound:
  for +active: +List<Bool>
  for +names: +List<String>
  for +fields: T.Schema
  {Nat.is_le(I.count(I.active_fields(active, names, fields)), List.length(&2, Bool, active)) == True{} : Bool}
def slot_count_bound(active, names, fields):
  match active:
    case Nil{}: {==}
    case Con{False{}, tail}: slot_count_bound(tail, names, fields)
    case Con{True{}, tail}:
      match names fields:
'''
for name,n in constructors:
    out+=f'        case Nil{{}} {pat(name,n)}: {{==}}\n'
    out+=('        case Con{name, ns} T.Chain{field, fs}: slot_count_bound(tail, ns, fs)\n' if name=='Chain' else f'        case Con{{name, ns}} {pat(name,n)}: {{==}}\n')
Path('proofs/validator_metadata.bend').write_text(out)
