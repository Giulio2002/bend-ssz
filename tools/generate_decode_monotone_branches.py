"""Append the higher-order decoder branches to the handwritten induction."""
from pathlib import Path
p=Path('proofs/decode_monotone.bend');s=p.read_text();marker='        # Generated layout/selection branches.';s=s.split(marker)[0];s+=marker+'\n'
small='p';big='Nat.add(p, extra)'
def decoded(f,schema,xs='xs',parts='[]'):return f'I.decode_go({f}, {schema}, {xs}, {parts}, T.EmptyItems{{}})'
def repeated(f,n):return f'I.slices(L.decode(Lists.replicate(Maybe<&2, Nat>, {n}, S.fixed_size(e)), xs), ps => I.sequence({decoded(f,"T.Repeat{e}","[]","ps")}))'
def repeated_proof(n):
 a=decoded(small,'T.Repeat{e}','[]','ps');b=decoded(big,'T.Repeat{e}','[]','ps')
 return f'slices(L.decode(Lists.replicate(Maybe<&2, Nat>, {n}, S.fixed_size(e)), xs), ps => I.sequence({a}), ps => I.sequence({b}), ps => sequence({a}, {b}, grow(p, extra, T.Repeat{{e}}, [], ps, T.EmptyItems{{}})))'
for ctor,fields,cond,n in [('Vector','e, n','Nat.is_eq(k, n)','n'),('ListOf','e, limit','Nat.is_le(k, limit)','k'),('ProgressiveList','e',None,'k')]:
 f=repeated(small,n);g=repeated(big,n);proof=repeated_proof(n)
 if cond:
  proof=f'gate({cond}, u => {f}, u => {g}, {proof})';f=f'I.gate({cond}, u => {f})';g=f'I.gate({cond}, u => {g})'
 s+=f'        case T.{ctor}{{{fields}}}:\n          count(I.item_count(S.fixed_size(e), xs), k => {f}, k => {g}, k => {proof})\n'
for ctor,fields in [('Container','names, fields'),('ProgressiveContainer','names, fields, active')]:
 a=decoded(small,'fields','[]','ps');b=decoded(big,'fields','[]','ps')
 s+=f'        case T.{ctor}{{{fields}}}:\n          slices(L.decode(S.widths(fields), xs), ps => I.sequence({a}), ps => I.sequence({b}), ps => sequence({a}, {b}, grow(p, extra, fields, [], ps, T.EmptyItems{{}})))\n'
for ctor,fields,select in [('Union','options','S.get(options, U32.to_nat(selector))'),('CompatibleUnion','selectors, options','C.selected_schema(selectors, options, selector)')]:
 a=decoded(small,'child','tail');b=decoded(big,'child','tail')
 s+=f'''        case T.{ctor}{{{fields}}}:
          match xs:
            case Nil{{}}: Unit{{}}
            case Con{{selector, tail}}:
              option({select}, child => I.selected(selector, {a}), child => I.selected(selector, {b}), child => selected(selector, {a}, {b}, grow(p, extra, child, tail, [], T.EmptyItems{{}})))
'''
s+='''
# Successful raw traversals retain precisely the same value, even for malformed
# input schemas. Public completeness needs the separate sufficient-budget proof.
law successful_extension:
  for +fuel: Nat
  for +extra: Nat
  for +schema: T.Schema
  for +xs: +List<U32>
  for +parts: +List<+List<U32>>
  for +acc: T.Value
  for +value: T.Value
  for success: {I.decode_go(fuel, schema, xs, parts, acc) == Some{value} : Maybe<&2, T.Value>}
  {I.decode_go(Nat.add(fuel, extra), schema, xs, parts, acc) == Some{value} : Maybe<&2, T.Value>}
def successful_extension(fuel, extra, schema, xs, parts, acc, value, success):
  %success : preserved(_, I.decode_go(Nat.add(fuel, extra), schema, xs, parts, acc))
  grow(fuel, extra, schema, xs, parts, acc)
'''
p.write_text(s)
