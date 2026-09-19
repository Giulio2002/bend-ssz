"""Discharge the identity-helper representation premise from legal types."""
from pathlib import Path
ns={}
exec(Path('tools/generate_compatibility_bounded.py').read_text().split("s='''")[0],ns)
cs,pat=ns['cs'],ns['pat']
s='''import Base
import ../types/schema.bend as T
import ../spec/type_legality.bend as S
import ../spec/compatibility.bend as C
import ../src/schema.bend as I
import ./identity_equivalence.bend as E
import ./primitive_invariants.bend as V

law legal_unnamed:
  for +schema: T.Schema
  for +forest: Bool
  for legal: S.legal(schema, forest)
  {E.unnamed(schema) == True{} : Bool}
def legal_unnamed(schema, forest, legal):
  match schema:
'''
for n,k in cs:
 if n=='Union':continue
 s+=f'    case {pat(n,k)}:\n'
 if n in ['Null','Named','Repeat']:body=f'Empty.absurd({{E.unnamed({pat(n,k)}) == True{{}} : Bool}}, legal)'
 elif n=='Vector':body='(context, positive, child) = legal\n      legal_unnamed(x0, False{}, child)'
 elif n in ['ListOf','ProgressiveList']:body='(context, child) = legal\n      legal_unnamed(x0, False{}, child)'
 elif n=='Container':body='(context, names, child) = legal\n      legal_unnamed(x1, True{}, child)'
 elif n=='ProgressiveContainer':body='(context, names, child, limit, last, count) = legal\n      legal_unnamed(x1, True{}, child)'
 elif n=='CompatibleUnion':body='(context, nonempty, count, selectors, child, compatibility) = legal\n      legal_unnamed(x1, True{}, child)'
 elif n=='Chain':body='(context, head, tail) = legal\n      V.and_true(E.unnamed(x0), E.unnamed(x1), legal_unnamed(x0, False{}, head), legal_unnamed(x1, True{}, tail))'
 else:body='{==}'
 s+='      '+body+'\n'
for n,k in cs:
 if n!='Chain':s+=f'    case T.Union{{{pat(n,k)}}}: Empty.absurd({{E.unnamed(T.Union{{{pat(n,k)}}}) == True{{}} : Bool}}, legal)\n';continue
 for h,l in cs:
  head=pat(h,l,'h');s+=f'    case T.Union{{T.Chain{{{head}, tail}}}}:\n'
  if h=='Null':s+='      (context, nonempty, limit, rest) = legal\n      legal_unnamed(tail, True{}, rest)\n'
  else:s+=f'      (context, limit, child, rest) = legal\n      V.and_true(E.unnamed({head}), E.unnamed(tail), legal_unnamed({head}, False{{}}, child), legal_unnamed(tail, True{{}}, rest))\n'
s+='''
# Equality of identity decisions, not merely sound acceptance. The second
# argument may be any schema; only the first needs public representation.
law identity_correct:
  for +a: T.Schema
  for +b: T.Schema
  for +forest: Bool
  for legal: S.legal(a, forest)
  {I.identical(a, b) == C.identical(a, b) : Bool}
def identity_correct(a, b, forest, legal):
  E.equal(a, b, legal_unnamed(a, forest, legal))
'''
Path('proofs/identity_legality.bend').write_text(s)
