"""Structural decoder rank, with separate progress for Repeat forests."""
from pathlib import Path
ns={};exec(Path('tools/generate_compatibility_monotone.py').read_text().split("out='''")[0],ns)
cs,pp=ns['cs'],ns['pp']
s='''import Base
import ../types/schema.bend as T
import ../src/schema.bend as S
import ../spec/schema_forest.bend as F
import ./word_facts.bend as W
import ./nat_order.bend as O
import ./nat_algebra.bend as A
import ./packing.bend as P

# maximum bounds all byte slices reachable from the original input. Repeat
# spends one step per remaining slice; ordinary nodes decrease schema weight.
def regular(schema: T.Schema, +maximum: Nat) -> Nat:
  Nat.mul(2n+S.weight(schema), 2n+maximum)

def rank(schema: T.Schema, parts: +List<+List<U32>>, +maximum: Nat) -> Nat:
  match schema:
    case T.Repeat{e}: Nat.add(1n+List.length(&2, +List<U32>, parts), regular(e, maximum))
    case _: regular(schema, maximum)

law coefficient_strict:
  for +a: Nat
  for +b: Nat
  for +k: Nat
  for positive: {Nat.is_le(1n, k) == True{} : Bool}
  for increase: {Nat.is_le(1n+a, b) == True{} : Bool}
  {Nat.is_le(1n+Nat.mul(a, k), Nat.mul(b, k)) == True{} : Bool}
def coefficient_strict(a, b, k, positive, increase):
  O.transitive(1n+Nat.mul(a, k), Nat.mul(1n+a, k), Nat.mul(b, k), O.add_right(1n, k, Nat.mul(a, k), positive), A.mul_coefficient(1n+a, b, k, increase))

law regular_step:
  for +child: T.Schema
  for +parent: T.Schema
  for +maximum: Nat
  for smaller: {Nat.is_le(1n+S.weight(child), S.weight(parent)) == True{} : Bool}
  {Nat.is_le(1n+regular(child, maximum), regular(parent, maximum)) == True{} : Bool}
def regular_step(child, parent, maximum, smaller):
  coefficient_strict(2n+S.weight(child), 2n+S.weight(parent), 2n+maximum, O.zero_le(1n+maximum), smaller)

law empty_bound:
  for +schema: T.Schema
  for +maximum: Nat
  {Nat.is_le(rank(schema, [], maximum), regular(schema, maximum)) == True{} : Bool}
def empty_bound(schema, maximum):
  match schema:
'''
for n,k in cs:
 pat=pp((n,[f'x{i}' for i in range(k)]));proof=f'O.reflexive(regular({pat}, maximum))'
 if n=='Repeat':proof='O.add_right(1n, 2n+maximum, regular(x0, maximum), O.zero_le(1n+maximum))'
 s+=f'    case {pat}: {proof}\n'
s+='''
law forest_bound:
  for +schema: T.Schema
  for +parts: +List<+List<U32>>
  for +maximum: Nat
  for count: {List.length(&2, +List<U32>, parts) == S.count(schema) : Nat}
  {Nat.is_le(rank(schema, parts, maximum), regular(schema, maximum)) == True{} : Bool}
def forest_bound(schema, parts, maximum, count):
  match schema:
'''
for n,k in cs:
 pat=pp((n,[f'x{i}' for i in range(k)]));proof=f'O.reflexive(regular({pat}, maximum))'
 if n=='Repeat':proof='''%Equal.sym(Nat, List.length(&2, +List<U32>, parts), 0n, count) : {Nat.is_le(Nat.add(1n+_, regular(x0, maximum)), regular(T.Repeat{x0}, maximum)) == True{} : Bool}
      empty_bound(T.Repeat{x0}, maximum)'''
 s+=f'    case {pat}: {proof}\n'
s+='''
law positive:
  for +schema: T.Schema
  for +parts: +List<+List<U32>>
  for +maximum: Nat
  {Nat.is_le(1n, rank(schema, parts, maximum)) == True{} : Bool}
def positive(schema, parts, maximum):
  match schema:
'''
for n,k in cs:
 pat=pp((n,[f'x{i}' for i in range(k)]));proof=f'O.zero_le(Nat.add(1n+maximum, Nat.mul(1n+S.weight({pat}), 2n+maximum)))'
 if n=='Repeat':proof='O.zero_le(Nat.add(List.length(&2, +List<U32>, parts), regular(x0, maximum)))'
 s+=f'    case {pat}: {proof}\n'
s+="""
law finite_bound:
  for +schema: T.Schema
  for +parts: +List<+List<U32>>
  for +maximum: Nat
  for finite: {F.finite(schema) == True{} : Bool}
  {Nat.is_le(rank(schema, parts, maximum), regular(schema, maximum)) == True{} : Bool}
def finite_bound(schema, parts, maximum, finite):
  match schema:
"""
for n,k in cs:
 pat=pp((n,[f'x{i}' for i in range(k)]));proof=f'O.reflexive(regular({pat}, maximum))'
 if n=='Repeat':proof=f'Empty.absurd({{Nat.is_le(rank({pat}, parts, maximum), regular({pat}, maximum)) == True{{}} : Bool}}, W.false_true(finite))'
 s+=f'    case {pat}: {proof}\n'
s+='''
law child_step:
  for +child: T.Schema
  for +parent: T.Schema
  for +maximum: Nat
  for smaller: {Nat.is_le(1n+S.weight(child), S.weight(parent)) == True{} : Bool}
  {Nat.is_le(1n+rank(child, [], maximum), regular(parent, maximum)) == True{} : Bool}
def child_step(child, parent, maximum, smaller):
  O.transitive(1n+rank(child, [], maximum), 1n+regular(child, maximum), regular(parent, maximum), empty_bound(child, maximum), regular_step(child, parent, maximum, smaller))

law repeat_head:
  for +element: T.Schema
  for +first: +List<U32>
  for +rest: +List<+List<U32>>
  for +maximum: Nat
  {Nat.is_le(1n+rank(element, [], maximum), rank(T.Repeat{element}, first <> rest, maximum)) == True{} : Bool}
def repeat_head(element, first, rest, maximum):
  O.transitive(1n+rank(element, [], maximum), 1n+regular(element, maximum), rank(T.Repeat{element}, first <> rest, maximum), empty_bound(element, maximum), O.add_right(1n, 2n+List.length(&2, +List<U32>, rest), regular(element, maximum), O.zero_le(1n+List.length(&2, +List<U32>, rest))))

law repeat_tail:
  for +element: T.Schema
  for +first: +List<U32>
  for +rest: +List<+List<U32>>
  for +maximum: Nat
  {Nat.is_le(1n+rank(T.Repeat{element}, rest, maximum), rank(T.Repeat{element}, first <> rest, maximum)) == True{} : Bool}
def repeat_tail(element, first, rest, maximum):
  O.reflexive(rank(T.Repeat{element}, first <> rest, maximum))

law enter_sequence:
  for +element: T.Schema
  for +parts: +List<+List<U32>>
  for +maximum: Nat
  for count: {Nat.is_le(List.length(&2, +List<U32>, parts), maximum) == True{} : Bool}
  {Nat.is_le(1n+rank(T.Repeat{element}, parts, maximum), Nat.mul(3n+S.weight(element), 2n+maximum)) == True{} : Bool}
def enter_sequence(element, parts, maximum, count):
  O.add_right(2n+List.length(&2, +List<U32>, parts), 2n+maximum, regular(element, maximum), count)

law enter_forest:
  for +fields: T.Schema
  for +parts: +List<+List<U32>>
  for +maximum: Nat
  for count: {List.length(&2, +List<U32>, parts) == S.count(fields) : Nat}
  {Nat.is_le(1n+rank(fields, parts, maximum), Nat.mul(3n+S.weight(fields), 2n+maximum)) == True{} : Bool}
def enter_forest(fields, parts, maximum, count):
  O.transitive(1n+rank(fields, parts, maximum), 1n+regular(fields, maximum), Nat.mul(3n+S.weight(fields), 2n+maximum), forest_bound(fields, parts, maximum, count), O.add_right(1n, 2n+maximum, regular(fields, maximum), O.zero_le(1n+maximum)))

law child_budget:
  for +child: Nat
  for +parent: Nat
  for +fuel: Nat
  for step: {Nat.is_le(1n+child, parent) == True{} : Bool}
  for enough: {Nat.is_le(parent, 1n+fuel) == True{} : Bool}
  {Nat.is_le(child, fuel) == True{} : Bool}
def child_budget(child, parent, fuel, step, enough):
  O.transitive(1n+child, parent, 1n+fuel, step, enough)
'''
Path('proofs/decode_rank.bend').write_text(s)
