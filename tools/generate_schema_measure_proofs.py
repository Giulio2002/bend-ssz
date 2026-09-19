"""Emit structural schema-size invariants used by decoder traversal proofs."""
from pathlib import Path
root=Path(__file__).resolve().parents[1]
ctors={'Boolean':0,'Unsigned':1,'ByteVector':1,'ByteList':1,'BitVector':1,'BitList':1,'Vector':2,'ListOf':2,'Container':2,'Union':1,'Null':0,'Chain':2,'End':0,'Repeat':1,'Named':2,'ProgressiveList':1,'ProgressiveBits':0,'ProgressiveContainer':3,'CompatibleUnion':2}
s='''import Base
import ../types/schema.bend as T
import ../src/schema.bend as I
import ../src/lists.bend as Lists
import ./lists.bend as L
import ./nat_order.bend as Order

law fields_bounded_by_weight:
  for +schema: T.Schema
  {Nat.is_le(I.count(schema), I.weight(schema)) == True{} : Bool}
def fields_bounded_by_weight(schema):
  match schema:
'''
for c,n in ctors.items():
 pat='T.'+c+'{'+', '.join('x'+str(i) for i in range(n))+'}'
 proof='Order.zero_le(I.weight('+pat+'))'
 if c=='Chain':proof='Order.transitive(I.count(x1), I.weight(x1), Nat.add(I.weight(x0), I.weight(x1)), fields_bounded_by_weight(x1), Order.left_below_sum(I.weight(x0), I.weight(x1)))'
 s+=f'    case {pat}: {proof}\n'
s+='''
law widths_count:
  for +schema: T.Schema
  {List.length(&2, Maybe<&2, Nat>, I.widths(schema)) == I.count(schema) : Nat}
def widths_count(schema):
  match schema:
'''
for c,n in ctors.items():
 pat='T.'+c+'{'+', '.join('x'+str(i) for i in range(n))+'}'
 proof='{==}' if c!='Chain' else 'Equal.cong(Nat, Nat, n => 1n+n, List.length(&2, Maybe<&2, Nat>, I.widths(x1)), I.count(x1), widths_count(x1))'
 s+=f'    case {pat}: {proof}\n'
s+='''
law replicated_widths_count:
  for +n: Nat
  for +width: Maybe<&2, Nat>
  {List.length(&2, Maybe<&2, Nat>, Lists.replicate(Maybe<&2, Nat>, n, width)) == n : Nat}
def replicated_widths_count(n, width):
  %Equal.sym(+List<Maybe<&2, Nat>>, Lists.replicate(Maybe<&2, Nat>, n, width), List.replicate(Maybe<&2, Nat>, n, width), L.replicate_correct(Maybe<&2, Nat>, n, width)) : {List.length(&2, Maybe<&2, Nat>, _) == n : Nat}
  replicate_length(n, width)
'''
# Declare the ordinary recursive list lemma before its tail-runtime composition.
pos=s.index('law replicated_widths_count:')
s=s[:pos]+'''law replicate_length:
  for +n: Nat
  for +width: Maybe<&2, Nat>
  {List.length(&2, Maybe<&2, Nat>, List.replicate(Maybe<&2, Nat>, n, width)) == n : Nat}
def replicate_length(n, width):
  match n:
    case 0n: {==}
    case 1n+p: Equal.cong(Nat, Nat, k => 1n+k, List.length(&2, Maybe<&2, Nat>, List.replicate(Maybe<&2, Nat>, p, width)), p, replicate_length(p, width))

'''+s[pos:]
(root/'proofs/schema_measure.bend').write_text(s)
