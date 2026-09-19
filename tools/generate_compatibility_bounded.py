"""Derive recursive active-slot bounds from independent type legality."""
from pathlib import Path
import re
cs=[(n,len(f.split(',')) if f else 0) for n,f in re.findall(r'^  (\w+)\{([^}]*)\}',Path('types/schema.bend').read_text().split('type Value')[0],re.M)]
def pat(n,k,p='x'):return 'T.'+n+'{'+', '.join(p+str(i) for i in range(k))+'}'
s='''import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../spec/type_legality.bend as S
import ./primitive_invariants.bend as V

# Recursive protocol invariant used only for compatibility termination bounds.
def bounded(schema: T.Schema) -> Bool:
  match schema:
    case T.Vector{child, n}: bounded(child)
    case T.ListOf{child, n}: bounded(child)
    case T.ProgressiveList{child}: bounded(child)
    case T.Repeat{child}: bounded(child)
    case T.Named{name, child}: bounded(child)
    case T.Container{names, fields}: bounded(fields)
    case T.ProgressiveContainer{names, fields, active}: Bool.and(Nat.is_le(List.length(&2, Bool, active), 256n), bounded(fields))
    case T.Union{options}: bounded(options)
    case T.CompatibleUnion{ids, options}: bounded(options)
    case T.Chain{head, tail}: Bool.and(bounded(head), bounded(tail))
    case _: True{}

law legal_bounded:
  for +schema: T.Schema
  for +forest: Bool
  for legal: S.legal(schema, forest)
  {bounded(schema) == True{} : Bool}
def legal_bounded(schema, forest, legal):
  match schema:
'''
for n,k in cs:
 if n=='Union':continue
 s+=f'    case {pat(n,k)}:\n'
 if n in ['Null','Named','Repeat']:body=f'Empty.absurd({{bounded({pat(n,k)}) == True{{}} : Bool}}, legal)'
 elif n=='Vector':body='(context, positive, child) = legal\n      legal_bounded(x0, False{}, child)'
 elif n in ['ListOf','ProgressiveList']:body='(context, child) = legal\n      legal_bounded(x0, False{}, child)'
 elif n=='Container':body='(context, names, child) = legal\n      legal_bounded(x1, True{}, child)'
 elif n=='ProgressiveContainer':body='(context, names, child, limit, last, count) = legal\n      V.and_true(Nat.is_le(List.length(&2, Bool, x2), 256n), bounded(x1), limit, legal_bounded(x1, True{}, child))'
 elif n=='CompatibleUnion':body='(context, nonempty, count, selectors, child, compatibility) = legal\n      legal_bounded(x1, True{}, child)'
 elif n=='Chain':body='(context, head, tail) = legal\n      V.and_true(bounded(x0), bounded(x1), legal_bounded(x0, False{}, head), legal_bounded(x1, True{}, tail))'
 else:body='{==}'
 s+='      '+body+'\n'
for n,k in cs:
 if n!='Chain':s+=f'    case T.Union{{{pat(n,k)}}}: Empty.absurd({{bounded(T.Union{{{pat(n,k)}}}) == True{{}} : Bool}}, legal)\n';continue
 for h,l in cs:
  head=pat(h,l,'h');s+=f'    case T.Union{{T.Chain{{{head}, tail}}}}:\n'
  if h=='Null':s+='      (context, nonempty, limit, rest) = legal\n      legal_bounded(tail, True{}, rest)\n'
  else:s+=f'      (context, limit, child, rest) = legal\n      V.and_true(bounded({head}), bounded(tail), legal_bounded({head}, False{{}}, child), legal_bounded(tail, True{{}}, rest))\n'
s+="""
law expansion_bounded:
  for +active: +List<Bool>
  for +names: +List<String>
  for +fields: T.Schema
  for +safe: {bounded(fields) == True{} : Bool}
  {bounded(I.active_fields(active, names, fields)) == True{} : Bool}
def expansion_bounded(active, names, fields, safe):
  match active:
    case Nil{}: {==}
    case Con{False{}, tail}: expansion_bounded(tail, names, fields, safe)
    case Con{True{}, tail}:
      match names fields:
"""
for n,k in cs:
 s+=f'        case Nil{{}} {pat(n,k)}: {{==}}\n'
 if n=='Chain':s+="""        case Con{name, ns} T.Chain{field, fs}:
          V.and_true(bounded(field), bounded(I.active_fields(tail, ns, fs)), V.and_left(bounded(field), bounded(fs), safe), expansion_bounded(tail, ns, fs, V.and_right(bounded(field), bounded(fs), safe)))
"""
 else:s+=f'        case Con{{name, ns}} {pat(n,k)}: {{==}}\n'
Path('proofs/compatibility_bounded.bend').write_text(s)
