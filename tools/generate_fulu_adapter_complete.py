"""All unified adapters accept every value with the corresponding neutral shape."""
import re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
source=(ROOT/'types/fulu.bend').read_text()
dispatch=dict(re.findall(r'case Name_(\w+)\{\}: (\w+)\.to_value\(v\)', source[source.index('def Name.to_ssz('):source.index('def Name.from_ssz(')]))
path=ROOT/'proofs/fulu_adapter_complete.bend'
marker='# Generated adapter completeness'
text=path.read_text().split(marker)[0]+marker+' for representation shape (not numeric validity).\n'
ctors={'BooleanValue':1,'UnsignedValue':1,'BytesValue':1,'BitsValue':1,'Sequence':1,'Items':2,'EmptyItems':0,'Selected':2,'NullValue':0}
def pattern(c):return 'T.'+c+'{'+', '.join('bad'+str(j) for j in range(ctors[c]))+'}'
def tree(vs,tail='T.EmptyItems{}'):
 for v in reversed(vs):tail='T.Items{'+v+', '+tail+'}'
 return tail
def schema(children):
 tail='T.End{}'
 for c in reversed(children):tail='T.Chain{F.'+c+'.schema(), '+tail+'}'
 return tail
def right(children,values,end,i):
 out='valid'
 for j in range(i):out='V.and_right(S.shape('+values[j]+', F.'+children[j]+'.schema()), S.shape('+tree(values[j+1:],end)+', '+schema(children[j+1:])+'), '+out+')'
 return out
def header(name):return ['law '+name+'_complete:','  for +original: T.Value','  for +valid: {S.shape(original, F.'+name+'.schema()) == True{} : Bool}','  {present(F.'+name+'(), F.'+name+'.from_value(original)) == True{} : Bool}','def '+name+'_complete(original, valid):','  match original:']
lines=[]
# One generic field-peeler, shared by every record adapter below. The previous
# form inlined a refutation per (field position, wrong constructor) whose
# pattern repeated the whole prefix and whose body re-derived the remaining
# shape conjunct: cubic in the field count (BeaconStateValue_complete alone was
# 8.4 MB of source). Peeling one field at a time through a continuation keeps
# each record quadratic and the refutations shared.
lines+=['law peel:','  for +goal: Bool','  for +rest: T.Value','  for +s: T.Schema','  for +ss: T.Schema',
        '  for +valid: {S.shape(rest, T.Chain{s, ss}) == True{} : Bool}',
        '  for k: @+h: T.Value -> @+head_ok: {S.shape(h, s) == True{} : Bool} -> @+t: T.Value -> @+tail_ok: {S.shape(t, ss) == True{} : Bool} -> @+shape: {rest == T.Items{h, t} : T.Value} -> {goal == True{} : Bool}',
        '  {goal == True{} : Bool}',
        'def peel(goal, rest, s, ss, valid, k):','  match rest:',
        '    case T.Items{h, t}: k(h, V.and_left(S.shape(h, s), S.shape(t, ss), valid), t, V.and_right(S.shape(h, s), S.shape(t, ss), valid), {==})']
lines+=['    case '+pattern(c)+': impossible(goal, valid)' for c in ctors if c!='Items']
lines+=['','law finish:','  for +goal: Bool','  for +rest: T.Value',
        '  for +valid: {S.shape(rest, T.End{}) == True{} : Bool}',
        '  for k: @+shape: {rest == T.EmptyItems{} : T.Value} -> {goal == True{} : Bool}',
        '  {goal == True{} : Bool}',
        'def finish(goal, rest, valid, k):','  match rest:','    case T.EmptyItems{}: k({==})']
lines+=['    case '+pattern(c)+': impossible(goal, valid)' for c in ctors if c!='EmptyItems']
lines+=['']
for match in re.finditer(r'^def (\w+)\(\) -> Data: (.+)$',source,re.M):
 name,typ=match.groups();decl=re.search(r'^def '+name+r'\.to_value\(.*$',source,re.M)
 if not decl:continue
 sequence=re.search(r'T\.Sequence\{(\w+)\.seq_to\(',decl[0])
 if sequence:
  child=sequence[1];A='F.'+child+'()';unconv='~('+A+'), ~(F.'+child+'.from_value)';fr=lambda v,a:'F.'+child+'.seq_from_go('+v+', '+a+')';sh=lambda v:'S.shape('+v+', T.Repeat{F.'+child+'.schema()})'
  lines += [f'''law {name}_step_complete:
  for +head: Maybe<&2, {A}>
  for +acc: +List<{A}>
  for next: +List<{A}> -> Maybe<&2, +List<{A}>>
  for head_ok: {{present({A}, head) == True{{}} : Bool}}
  for tail_ok: @+a: +List<{A}> -> {{present(+List<{A}>, next(a)) == True{{}} : Bool}}
  {{present(+List<{A}>, F.{child}.seq_step(head, acc, next)) == True{{}} : Bool}}
def {name}_step_complete(head, acc, next, head_ok, tail_ok):
  match head:
    case None{{}}: impossible(False{{}}, head_ok)
    case Some{{x}}: tail_ok(x <> acc)

law {name}_items_complete:
  for +original: T.Value
  for +acc: +List<{A}>
  for +valid: {{{sh('original')} == True{{}} : Bool}}
  {{present(+List<{A}>, {fr('original','acc')}) == True{{}} : Bool}}
def {name}_items_complete(original, acc, valid):
  match original:
    case T.EmptyItems{{}}: {{==}}
    case T.Items{{h, t}}: {name}_step_complete(F.{child}.from_value(h), acc, next => {fr('t','next')}, {child}_complete(h, V.and_left(S.shape(h, F.{child}.schema()), {sh('t')}, valid)), next => {name}_items_complete(t, next, V.and_right(S.shape(h, F.{child}.schema()), {sh('t')}, valid)))''']
  lines+=['    case '+pattern(c)+': impossible(False{}, valid)' for c in ctors if c not in ['EmptyItems','Items']]
  lines+=['']+header(name)+[f'    case T.Sequence{{values}}: {name}_items_complete(values, [], valid)']
  lines+=['    case '+pattern(c)+': impossible(False{}, valid)' for c in ctors if c!='Sequence']
 elif typ.startswith(('+List<','P.','Bool')):
  ctor=re.search(r'-> T.Value: T\.(\w+)\{v\}',decl[0])[1]
  lines+=header(name)+['    case T.'+ctor+'{value}: {==}']
  lines+=['    case '+pattern(c)+': impossible(False{}, valid)' for c in ctors if c!=ctor]
 else:
  record=re.search(r'^type '+typ+r' is Data:\n  '+typ+r'\{([^\n]+)\}',source,re.M);assert record,(name,typ)
  fields=[item.strip().split(': ') for item in record[1].split(',')];children=[x[1][:-2] for x in fields];n=len(fields)
  vs=['o'+str(i) for i in range(n)];rs=['a'+str(i) for i in range(n)]
  lines+=['law '+name+'_assemble_complete:']+['  for +'+a+': Maybe<&2, F.'+c+'()>' for a,c in zip(rs,children)]+['  for p'+str(i)+': {present(F.'+c+'(), '+rs[i]+') == True{} : Bool}' for i,c in enumerate(children)]
  lines+=['  {present(F.'+name+'(), F.'+name+'.assemble('+', '.join(rs)+')) == True{} : Bool}','def '+name+'_assemble_complete('+', '.join(rs+['p'+str(i) for i in range(n)])+'):', '  match '+' '.join(rs)+':','    case '+' '.join('Some{v'+str(i)+'}' for i in range(n))+': {==}']
  lines+=['    case '+' '.join('Some{v'+str(j)+'}' if j<i else 'None{}' if j==i else '_' for j in range(n))+': impossible(False{}, p'+str(i)+')' for i in range(n)]
  # Field walk through the shared peeler: one `peel` per field, each naming
  # only that field's schema and the remaining chain.
  chain=[schema(children[i:]) for i in range(n+1)]
  # Goal and rewrite motive at depth i: the fields already peeled are spelled
  # out, the remainder is still the bound variable (or the motive hole).
  goal=lambda i,tail:'present(F.'+name+'(), F.'+name+'.from_value(T.Sequence{'+tree(vs[:i],tail)+'}))'
  body=['law '+name+'_fields_complete:','  for +items: T.Value',
        '  for +valid: {S.shape(items, '+chain[0]+') == True{} : Bool}',
        '  {'+goal(0,'items')+' == True{} : Bool}',
        'def '+name+'_fields_complete(items, valid):']
  pad='  '
  prev=('items','valid')
  for i in range(n):
    body+= [pad+'peel('+goal(i,prev[0])+', '+prev[0]+', F.'+children[i]+'.schema(), '+chain[i+1]+', '+prev[1]+
            ', o'+str(i)+' => h'+str(i)+' => r'+str(i)+' => t'+str(i)+' => e'+str(i)+' =>']
    pad+='  '
    body+= [pad+'%Equal.sym(T.Value, '+prev[0]+', T.Items{o'+str(i)+', r'+str(i)+'}, e'+str(i)+') : {'+goal(i,'_')+' == True{} : Bool}']
    prev=('r'+str(i),'t'+str(i))
  body+= [pad+'finish('+goal(n,prev[0])+', '+prev[0]+', '+prev[1]+', e'+str(n)+' =>',
          pad+'  %Equal.sym(T.Value, '+prev[0]+', T.EmptyItems{}, e'+str(n)+') : {'+goal(n,'_')+' == True{} : Bool}',
          pad+'  '+name+'_assemble_complete('+
          ', '.join(['F.'+c+'.from_value(o'+str(i)+')' for i,c in enumerate(children)]+
                    [c+'_complete(o'+str(i)+', h'+str(i)+')' for i,c in enumerate(children)])+'))'+')'*n]
  lines+=body+['']
  lines+=header(name)+['    case T.Sequence{items}: '+name+'_fields_complete(items, valid)']
  lines+=['    case '+pattern(c)+': impossible(False{}, valid)' for c in ctors if c!='Sequence']

 lines+=['']
count=0
for line in source.splitlines():
 if '.to_ssz(v: ' not in line:continue
 name=line.split()[1].split('.')[0];typ=line.split('.to_ssz(v: ')[1].split(') -> T.Value: ')[0];alias=dispatch[name]
 lines += [f'''law {name}_conversion_complete_erased:
  for +original: T.Value
  for +valid: {{S.shape(original, F.{name}.schema()) == True{{}} : Bool}}
  {{present(F.{typ}, F.{name}.from_ssz(original)) == True{{}} : Bool}}
def {name}_conversion_complete_erased(original, valid): {alias}_complete(original, valid)
''']
 count+=1
assert count==109,count
generated='\n'.join(lines)+'\n'
generated=re.sub(r'F\.(\w+)\.schema\(\)',r'S.erase(F.\1.schema())',generated)
path.write_text(text+generated)
