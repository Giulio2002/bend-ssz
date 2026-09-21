"""Generate universally checked inverses for all unified named representations.
No fixture or expected result is read. These are adapter laws, not SSZ round trips.
"""
import re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
source=(ROOT/'types/fulu.bend').read_text()
dispatch=dict(re.findall(r'case Name_(\w+)\{\}: (\w+)\.to_value\(v\)', source[source.index('def Name.to_ssz('):source.index('def Name.from_ssz(')]))
lines=['import Base','import ../types/fulu_model.bend as F','import ../types/schema.bend as T','import ./lists.bend as L','']
for match in re.finditer(r'^def (\w+)\(\) -> Data: (.+)$',source,re.M):
 name,typ=match.groups();declaration=re.search(r'^def '+name+r'\.to_value\(.*$',source,re.M)
 if not declaration:continue
 seq=re.search(r'T\.Sequence\{(\w+)\.seq_to\(',declaration[0])
 if seq:
  child=seq[1];A='F.'+child+'()';conv='~('+A+'), ~(F.'+child+'.to_value)';unconv='~('+A+'), ~(F.'+child+'.from_value)'
  go=lambda xs,acc:'F.'+child+'.seq_to_go('+xs+', '+acc+')'
  to=lambda xs:'F.'+child+'.seq_to('+xs+')'
  fr=lambda v,acc:'F.'+child+'.seq_from_go('+v+', '+acc+')'
  rev=lambda xs,acc:'List.reverse.go(&2, '+A+', '+xs+', '+acc+')'
  app=lambda xs,ys:'List.append(&2, '+A+', '+xs+', '+ys+')'
  lines += [f'''law {name}_append:
  for +xs: +List<{A}>
  for +ys: +List<{A}>
  for +acc: T.Value
  {{{go(app('xs','ys'),'acc')} == {go('ys',go('xs','acc'))} : T.Value}}
def {name}_append(xs, ys, acc):
  match xs:
    case Nil{{}}: {{==}}
    case Con{{h, t}}: {name}_append(t, ys, T.Items{{F.{child}.to_value(h), acc}})

law {name}_cons:
  for +h: {A}
  for +t: +List<{A}>
  {{{to('h <> t')} == T.Items{{F.{child}.to_value(h), {to('t')}}} : T.Value}}
def {name}_cons(h, t):
  %Equal.sym(+List<{A}>, {rev('t','[h]')}, {app('List.reverse(&2, '+A+', t)','[h]')}, L.reverse_acc_append({A}, t, [], [h])) : {{{go('_','T.EmptyItems{}')} == T.Items{{F.{child}.to_value(h), {to('t')}}} : T.Value}}
  {name}_append(List.reverse(&2, {A}, t), [h], T.EmptyItems{{}})

law {name}_inverse_go:
  for +xs: +List<{A}>
  for +acc: +List<{A}>
  {{{fr(to('xs'),'acc')} == Some{{{rev('acc','xs')}}} : Maybe<&2, +List<{A}>>}}
def {name}_inverse_go(xs, acc):
  match xs:
    case Nil{{}}: {{==}}
    case Con{{h, t}}:
      %Equal.sym(T.Value, {to('h <> t')}, T.Items{{F.{child}.to_value(h), {to('t')}}}, {name}_cons(h, t)) : {{{fr('_','acc')} == Some{{{rev('acc','h <> t')}}} : Maybe<&2, +List<{A}>>}}
      %Equal.sym(Maybe<&2, {A}>, F.{child}.from_value(F.{child}.to_value(h)), Some{{h}}, {child}_inverse(h)) : {{F.{child}.seq_step(_, acc, next => {fr(to('t'),'next')}) == Some{{{rev('acc','h <> t')}}} : Maybe<&2, +List<{A}>>}}
      {name}_inverse_go(t, h <> acc)
''']
 lines += [f'law {name}_inverse:',f'  for +value: F.{name}()',f'  {{F.{name}.from_value(F.{name}.to_value(value)) == Some{{value}} : Maybe<&2, F.{name}()>}}',f'def {name}_inverse(value):']
 if seq:lines+=['  '+name+'_inverse_go(value, [])']
 elif typ.startswith(('+List<','P.','Bool')):lines+=['  {==}']
 else:
  record=re.search(r'^type '+typ+r' is Data:\n  '+typ+r'\{([^\n]+)\}',source,re.M);assert record,(name,typ)
  fields=[item.strip().split(': ') for item in record[1].split(',')]
  variables=[x[0] for x in fields];children=[x[1][:-2] for x in fields]
  recordvalue='F.'+typ+'{'+', '.join(variables)+'}'
  lines+=['  F.'+typ+'{'+', '.join(variables)+'} = value']
  actual=[f'F.{c}.from_value(F.{c}.to_value({v}))' for v,c in zip(variables,children)]
  for i,(v,c) in enumerate(zip(variables,children)):
   args=[('Some{'+variables[j]+'}' if j<i else '_' if j==i else actual[j]) for j in range(len(fields))]
   lines += [f'  %Equal.sym(Maybe<&2, F.{c}()>, {actual[i]}, Some{{{v}}}, {c}_inverse({v})) : {{F.{name}.assemble('+', '.join(args)+f') == Some{{{recordvalue}}} : Maybe<&2, F.{name}()>}}']
  lines+=['  {==}']
 lines+=['']
count=0
for line in source.splitlines():
 if '.to_ssz(v: ' not in line:continue
 name=line.split()[1].split('.')[0];typ=line.split('.to_ssz(v: ')[1].split(') -> T.Value: ')[0];alias=dispatch[name]
 lines += [f'law {name}_representation_inverse:',f'  for +value: F.{typ}',f'  {{F.{name}.from_ssz(F.{name}.to_ssz(value)) == Some{{value}} : Maybe<&2, F.{typ}>}}',f'def {name}_representation_inverse(value): {alias}_inverse(value)','']
 count+=1
assert count==109,count
(ROOT/'proofs/fulu_adapter_inverse.bend').write_text('\n'.join(lines)+'\n')
