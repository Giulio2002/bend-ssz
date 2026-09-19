"""Actual option selection preserves the checked schema-forest invariant."""
from pathlib import Path
ns={};exec(Path('tools/generate_compatibility_monotone.py').read_text().split("out='''")[0],ns)
cs,pp=ns['cs'],ns['pp']
s='''import Base
import ../types/schema.bend as T
import ../src/schema.bend as S
import ../src/codec.bend as C
import ../spec/schema_forest.bend as F
import ./primitive_invariants.bend as V

def result_shape(result: Maybe<&2, T.Schema>) -> Type:
  match result:
    case None{}: Unit
    case Some{schema}: {F.well_formed(schema) == True{} : Bool}

law get:
  for +schema: T.Schema
  for +index: Nat
  for +shape: {F.well_formed(schema) == True{} : Bool}
  result_shape(S.get(schema, index))
def get(schema, index, shape):
  match schema:
'''
for n,k in cs:
 pat=pp((n,[f'x{i}' for i in range(k)]))
 if n=='Chain':s+='''    case T.Chain{h, t}:
      match index:
        case 0n: V.and_left(F.well_formed(h), Bool.and(F.finite(t), F.well_formed(t)), shape)
        case 1n+p: get(t, p, V.and_right(F.finite(t), F.well_formed(t), V.and_right(F.well_formed(h), Bool.and(F.finite(t), F.well_formed(t)), shape)))
'''
 else:s+=f'    case {pat}: Unit{{}}\n'
s+='''
law select:
  for +ok: Bool
  for +schema: T.Schema
  for -next: Unit -> Maybe<&2, T.Schema>
  for item: {F.well_formed(schema) == True{} : Bool}
  for rest: result_shape(next(Unit{}))
  result_shape(C.select_option(ok, schema, next))
def select(ok, schema, next, item, rest):
  match ok:
    case False{}: rest
    case True{}: item

law selected:
  for +ids: +List<U32>
  for +options: T.Schema
  for +selector: U32
  for +shape: {F.well_formed(options) == True{} : Bool}
  result_shape(C.selected_schema(ids, options, selector))
def selected(ids, options, selector, shape):
  match ids options:
'''
for n,k in cs:
 pat=pp((n,[f'x{i}' for i in range(k)]));s+=f'    case Nil{{}} {pat}: Unit{{}}\n'
 if n=='Chain':s+='''    case Con{id, ids_tail} T.Chain{h, t}:
      select(U32.is_eq(id, selector), h, u => C.selected_schema(ids_tail, t, selector), V.and_left(F.well_formed(h), Bool.and(F.finite(t), F.well_formed(t)), shape), selected(ids_tail, t, selector, V.and_right(F.finite(t), F.well_formed(t), V.and_right(F.well_formed(h), Bool.and(F.finite(t), F.well_formed(t)), shape))))
'''
 else:s+=f'    case Con{{id, ids_tail}} {pat}: Unit{{}}\n'
Path('proofs/schema_selection_shape.bend').write_text(s)
