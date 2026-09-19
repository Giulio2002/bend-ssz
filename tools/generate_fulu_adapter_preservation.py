"""Generate actual unified-adapter preservation laws; no fixture outputs read."""
import re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
source=(ROOT/'types/fulu.bend').read_text()
dispatch=dict(re.findall(r'case Name_(\w+)\{\}: (\w+)\.to_value\(v\)', source[source.index('def Name.to_ssz('):source.index('def Name.from_ssz(')]))
lines=['import Base','import ../types/fulu.bend as F','import ../types/schema.bend as T','import ./lists.bend as Lists','']
def items(vs):
 out='T.EmptyItems{}'
 for v in reversed(vs):out='T.Items{'+v+', '+out+'}'
 return out
def seq(vs):return 'T.Sequence{'+items(vs)+'}'
ctors={'BooleanValue':1,'UnsignedValue':1,'BytesValue':1,'BitsValue':1,'Sequence':1,'Items':2,'EmptyItems':0,'Selected':2,'NullValue':0}
def negatives(excluded,indent='    '):
 return '\n'.join(indent+'case T.'+c+'{'+', '.join('bad'+str(i) for i in range(n))+'}: Unit{}' for c,n in ctors.items() if c not in excluded)
def container_negatives(n):
 out=negatives({'Sequence'}).splitlines()
 for i in range(n+1):
  for c,k in ctors.items():
   if c==('Items' if i<n else 'EmptyItems'):continue
   tree='T.'+c+'{'+', '.join('bad'+str(j) for j in range(k))+'}'
   for j in reversed(range(i)):tree='T.Items{o'+str(j)+', '+tree+'}'
   out+=['    case T.Sequence{'+tree+'}: Unit{}']
 return out
for match in re.finditer(r'^def (\w+)\(\) -> Data: (.+)$',source,re.M):
 name,typ=match.groups();decl=re.search(r'^def '+name+r'\.to_value\(.*$',source,re.M)
 if not decl:continue
 lines += [f'''def {name}_preserves(original: T.Value, result: Maybe<&2, F.{name}()>) -> Type:
  match result:
    case None{{}}: Unit
    case Some{{value}}: {{F.{name}.to_value(value) == original : T.Value}}
''']
 sequence=re.search(r'T\.Sequence\{(\w+)\.seq_to\(',decl[0])
 if sequence:
  child=sequence[1];A='F.'+child+'()';conv='~('+A+'), ~(F.'+child+'.to_value)';unconv='~('+A+'), ~(F.'+child+'.from_value)'
  to=lambda xs:'F.'+child+'.seq_to('+xs+')'
  go=lambda xs,acc:'F.'+child+'.seq_to_go('+xs+', '+acc+')'
  fr=lambda v,acc:'F.'+child+'.seq_from_go('+v+', '+acc+')'
  lines += [f'''def {name}_items_preserve(original: T.Value, result: Maybe<&2, +List<{A}>>) -> Type:
  match result:
    case None{{}}: Unit
    case Some{{values}}: {{{to('values')} == original : T.Value}}

law {name}_step:
  for +h: T.Value
  for +t: T.Value
  for +acc: +List<{A}>
  for +head: Maybe<&2, {A}>
  for next: +List<{A}> -> Maybe<&2, +List<{A}>>
  for head_preserves: {child}_preserves(h, head)
  for tail_preserves: @+a: +List<{A}> -> {name}_items_preserve({go('a','t')}, next(a))
  {name}_items_preserve({go('acc','T.Items{h, t}')}, F.{child}.seq_step(head, acc, next))
def {name}_step(h, t, acc, head, next, head_preserves, tail_preserves):
  match head:
    case None{{}}: Unit{{}}
    case Some{{x}}:
      %head_preserves : {name}_items_preserve({go('acc','T.Items{_, t}')}, next(x <> acc))
      tail_preserves(x <> acc)

law {name}_items_sound:
  for +original: T.Value
  for +acc: +List<{A}>
  {name}_items_preserve({go('acc','original')}, {fr('original','acc')})
def {name}_items_sound(original, acc):
  match original:
    case T.EmptyItems{{}}: Equal.cong(+List<{A}>, T.Value, xs => {go('xs','T.EmptyItems{}')}, List.reverse(&2, {A}, List.reverse(&2, {A}, acc)), acc, Lists.reverse_twice({A}, acc))
    case T.Items{{h, t}}: {name}_step(h, t, acc, F.{child}.from_value(h), next => {fr('t','next')}, {child}_sound(h), next => {name}_items_sound(t, next))
{negatives({'EmptyItems','Items'})}

law {name}_sequence_sound:
  for +original: T.Value
  for +result: Maybe<&2, +List<{A}>>
  for preserved: {name}_items_preserve(original, result)
  {name}_preserves(T.Sequence{{original}}, result)
def {name}_sequence_sound(original, result, preserved):
  match result:
    case None{{}}: Unit{{}}
    case Some{{xs}}: Equal.cong(T.Value, T.Value, value => T.Sequence{{value}}, {to('xs')}, original, preserved)

law {name}_sound:
  for +original: T.Value
  {name}_preserves(original, F.{name}.from_value(original))
def {name}_sound(original):
  match original:
    case T.Sequence{{values}}: {name}_sequence_sound(values, {fr('values','[]')}, {name}_items_sound(values, []))
{negatives({'Sequence'})}
''' ]
 elif typ.startswith(('+List<','P.','Bool')):
  ctor=re.search(r'-> T.Value: T\.(\w+)\{v\}',decl[0])[1]
  lines += [f'''law {name}_sound:
  for +original: T.Value
  {name}_preserves(original, F.{name}.from_value(original))
def {name}_sound(original):
  match original:
    case T.{ctor}{{value}}: {{==}}
{negatives({ctor})}
''' ]
 else:
  record=re.search(r'^type '+typ+r' is Data:\n  '+typ+r'\{([^\n]+)\}',source,re.M);assert record,(name,typ)
  fields=[item.strip().split(': ') for item in record[1].split(',')];children=[x[1][:-2] for x in fields];n=len(fields)
  originals=['o'+str(i) for i in range(n)];results=['a'+str(i) for i in range(n)];vs=['v'+str(i) for i in range(n)]
  lines+=['law '+name+'_assemble_sound:']
  lines+=['  for +'+v+': T.Value' for v in originals]
  lines+=['  for +'+a+': Maybe<&2, F.'+c+'()>' for a,c in zip(results,children)]
  lines+=['  for p'+str(i)+': '+c+'_preserves('+originals[i]+', '+results[i]+')' for i,c in enumerate(children)]
  lines+=['  '+name+'_preserves('+seq(originals)+', F.'+name+'.assemble('+', '.join(results)+'))', 'def '+name+'_assemble_sound('+', '.join(originals+results+['p'+str(i) for i in range(n)])+'):', '  match '+' '.join(results)+':', '    case '+' '.join('Some{'+v+'}' for v in vs)+':']
  actual=['F.'+c+'.to_value('+v+')' for c,v in zip(children,vs)]
  recordvalue='F.'+typ+'{'+', '.join(vs)+'}'
  for i in range(n):
   terms=[actual[j] if j<i else '_' if j==i else originals[j] for j in range(n)]
   lines+=['      %p'+str(i)+' : {F.'+name+'.to_value('+recordvalue+') == '+seq(terms)+' : T.Value}']
  lines+=['      {==}', *['    case '+' '.join('Some{'+vs[j]+'}' if j<i else 'None{}' if j==i else '_' for j in range(n))+': Unit{}' for i in range(n)],'', 'law '+name+'_sound:', '  for +original: T.Value', '  '+name+'_preserves(original, F.'+name+'.from_value(original))', 'def '+name+'_sound(original):', '  match original:', '    case '+seq(originals)+': '+name+'_assemble_sound('+', '.join(originals+['F.'+c+'.from_value('+o+')' for c,o in zip(children,originals)]+[c+'_sound('+o+')' for c,o in zip(children,originals)])+')',*container_negatives(n),'']
count=0
for line in source.splitlines():
 if '.to_ssz(v: ' not in line:continue
 name=line.split()[1].split('.')[0];typ=line.split('.to_ssz(v: ')[1].split(') -> T.Value: ')[0];alias=dispatch[name]
 lines += [f'''law {name}_representation_preserved:
  for +original: T.Value
  {alias}_preserves(original, F.{name}.from_ssz(original))
def {name}_representation_preserved(original): {alias}_sound(original)
''']
 count+=1
assert count==109,count
(ROOT/'proofs/fulu_adapter_preservation.bend').write_text('\n'.join(lines)+'\n')
