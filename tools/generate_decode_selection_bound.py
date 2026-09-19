"""Bound actual union lookup results by the source option forest weight."""
from pathlib import Path
ns={};exec(Path('tools/generate_compatibility_monotone.py').read_text().split("out='''")[0],ns)
cs,pp=ns['cs'],ns['pp']
s='''import Base
import ../types/schema.bend as T
import ../src/schema.bend as S
import ../src/codec.bend as C
import ./nat_order.bend as O

def bound(maximum: Nat, result: Maybe<&2, T.Schema>) -> Type:
  match result:
    case None{}: Unit
    case Some{schema}: {Nat.is_le(S.weight(schema), maximum) == True{} : Bool}

law weaken:
  for +a: Nat
  for +b: Nat
  for +result: Maybe<&2, T.Schema>
  for limit: {Nat.is_le(a, b) == True{} : Bool}
  for child: bound(a, result)
  bound(b, result)
def weaken(a, b, result, limit, child):
  match result:
    case None{}: Unit{}
    case Some{schema}: O.transitive(S.weight(schema), a, b, child, limit)

law head:
  for +h: T.Schema
  for +t: T.Schema
  {Nat.is_le(S.weight(h), S.weight(T.Chain{h, t})) == True{} : Bool}
def head(h, t):
  O.step_right(S.weight(h), Nat.add(S.weight(h), S.weight(t)), O.below_sum(S.weight(h), S.weight(t)))

law tail:
  for +h: T.Schema
  for +t: T.Schema
  {Nat.is_le(S.weight(t), S.weight(T.Chain{h, t})) == True{} : Bool}
def tail(h, t):
  O.step_right(S.weight(t), Nat.add(S.weight(h), S.weight(t)), O.left_below_sum(S.weight(h), S.weight(t)))

law get:
  for +schema: T.Schema
  for +index: Nat
  bound(S.weight(schema), S.get(schema, index))
def get(schema, index):
  match schema:
'''
for n,k in cs:
 pat=pp((n,[f'x{i}' for i in range(k)]))
 if n=='Chain':s+='''    case T.Chain{h, t}:
      match index:
        case 0n: head(h, t)
        case 1n+p: weaken(S.weight(t), S.weight(T.Chain{h, t}), S.get(t, p), tail(h, t), get(t, p))
'''
 else:s+=f'    case {pat}: Unit{{}}\n'
s+='''
law select:
  for +ok: Bool
  for +schema: T.Schema
  for +maximum: Nat
  for -next: Unit -> Maybe<&2, T.Schema>
  for item: {Nat.is_le(S.weight(schema), maximum) == True{} : Bool}
  for rest: bound(maximum, next(Unit{}))
  bound(maximum, C.select_option(ok, schema, next))
def select(ok, schema, maximum, next, item, rest):
  match ok:
    case False{}: rest
    case True{}: item

law selected:
  for +ids: +List<U32>
  for +options: T.Schema
  for +selector: U32
  bound(S.weight(options), C.selected_schema(ids, options, selector))
def selected(ids, options, selector):
  match ids options:
'''
for n,k in cs:
 pat=pp((n,[f'x{i}' for i in range(k)]))
 s+=f'    case Nil{{}} {pat}: Unit{{}}\n'
 if n=='Chain':s+='''    case Con{id, ids_tail} T.Chain{h, t}:
      select(U32.is_eq(id, selector), h, S.weight(T.Chain{h, t}), u => C.selected_schema(ids_tail, t, selector), head(h, t), weaken(S.weight(t), S.weight(T.Chain{h, t}), C.selected_schema(ids_tail, t, selector), tail(h, t), selected(ids_tail, t, selector)))
'''
 else:s+=f'    case Con{{id, ids_tail}} {pat}: Unit{{}}\n'
Path('proofs/decode_selection_bound.bend').write_text(s)
