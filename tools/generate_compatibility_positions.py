"""Generate exhaustive structural refinement for active field positions."""
from pathlib import Path
import re
cs=[(n,len(f.split(',')) if f else 0) for n,f in re.findall(r'^  (\w+)\{([^}]*)\}',Path('types/schema.bend').read_text().split('type Value')[0],re.M)]
def pat(n,k):return 'T.'+n+'{'+', '.join('x'+str(i) for i in range(k))+'}'
s='''import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../spec/compatibility.bend as S
import ./packing.bend as Pack

def offset(value: Maybe<&2, Nat>, +start: Nat) -> Maybe<&2, Nat>:
  match value:
    case None{}: None{}
    case Some{n}: Some{Nat.add(n, start)}

law offset_shift:
  for +value: Maybe<&2, Nat>
  for +start: Nat
  {offset(value, 1n+start) == offset(S.shift(value), start) : Maybe<&2, Nat>}
def offset_shift(value, start):
  match value:
    case None{}: {==}
    case Some{n}: Equal.cong(Nat, Maybe<&2, Nat>, x => Some{x}, Nat.add(n, 1n+start), 1n+Nat.add(n, start), Pack.add_succ(n, start))

law offset_zero:
  for +value: Maybe<&2, Nat>
  {offset(value, 0n) == value : Maybe<&2, Nat>}
def offset_zero(value):
  match value:
    case None{}: {==}
    case Some{n}: Equal.cong(Nat, Maybe<&2, Nat>, x => Some{x}, Nat.add(n, 0n), n, Pack.add_zero(n))

law choice:
  for +found: Bool
  for +start: Nat
  for next: Unit -> Maybe<&2, Nat>
  for +tail: Maybe<&2, Nat>
  for correct: {next(Unit{}) == offset(tail, 1n+start) : Maybe<&2, Nat>}
  {I.position_choice(found, start, next) == offset(S.choose(found, tail), start) : Maybe<&2, Nat>}
def choice(found, start, next, tail, correct):
  match found:
    case True{}: {==}
    case False{}: Equal.trans(Maybe<&2, Nat>, next(Unit{}), offset(tail, 1n+start), offset(S.shift(tail), start), correct, offset_shift(tail, start))

law field_position:
  for +fields: T.Schema
  for +name: String
  for +start: Nat
  {I.field_position(fields, name, start) == offset(S.position(name, fields), start) : Maybe<&2, Nat>}
def field_position(fields, name, start):
  match fields:
'''
for n,k in cs:
 if n!='Chain':s+=f'    case {pat(n,k)}: {{==}}\n'
 else:
  s+='    case T.Chain{head, tail}:\n      match head:\n'
  for h,l in cs:
   if h=='Named':s+='''        case T.Named{n, f}:
          choice(String.eq(name, n), start, u => I.field_position(tail, name, 1n+start), S.position(name, tail), field_position(tail, name, 1n+start))
'''
   else:s+=f'''        case {pat(h,l)}:
          Equal.trans(Maybe<&2, Nat>, I.field_position(tail, name, 1n+start), offset(S.position(name, tail), 1n+start), offset(S.shift(S.position(name, tail)), start), field_position(tail, name, 1n+start), offset_shift(S.position(name, tail), start))
'''
s+='''
law position:
  for +fields: T.Schema
  for +name: String
  {I.field_position(fields, name, 0n) == S.position(name, fields) : Maybe<&2, Nat>}
def position(fields, name):
  Equal.trans(Maybe<&2, Nat>, I.field_position(fields, name, 0n), offset(S.position(name, fields), 0n), S.position(name, fields), field_position(fields, name, 0n), offset_zero(S.position(name, fields)))

law eq_symmetric:
  for +a: Nat
  for +b: Nat
  {Nat.is_eq(a, b) == Nat.is_eq(b, a) : Bool}
def eq_symmetric(a, b):
  match a b:
    case 0n 0n: {==}
    case 0n 1n+y: {==}
    case 1n+x 0n: {==}
    case 1n+x 1n+y: eq_symmetric(x, y)

law agrees:
  for +value: Maybe<&2, Nat>
  for +index: Nat
  {I.same_position(value, index) == S.agrees(index, value) : Bool}
def agrees(value, index):
  match value:
    case None{}: {==}
    case Some{n}: eq_symmetric(n, index)

law shared_positions:
  for +a: T.Schema
  for +b: T.Schema
  for +index: Nat
  {I.shared_positions(a, b, index) == S.shared_positions(a, b, index) : Bool}
def shared_positions(a, b, index):
  match a:
'''
for n,k in cs:
 if n!='Chain':s+=f'    case {pat(n,k)}: {{==}}\n'
 else:
  s+='    case T.Chain{head, tail}:\n      match head:\n'
  for h,l in cs:
   if h=='Named':s+='''        case T.Named{n, f}:
          %position(b, n) : {I.shared_positions(T.Chain{T.Named{n, f}, tail}, b, index) == Bool.and(S.agrees(index, _), S.shared_positions(tail, b, 1n+index)) : Bool}
          %agrees(I.field_position(b, n, 0n), index) : {I.shared_positions(T.Chain{T.Named{n, f}, tail}, b, index) == Bool.and(_, S.shared_positions(tail, b, 1n+index)) : Bool}
          %shared_positions(tail, b, 1n+index) : {I.shared_positions(T.Chain{T.Named{n, f}, tail}, b, index) == Bool.and(I.same_position(I.field_position(b, n, 0n), index), _) : Bool}
          {==}
'''
   else:s+=f'        case {pat(h,l)}: shared_positions(tail, b, 1n+index)\n'
Path('proofs/compatibility_positions.bend').write_text(s)
