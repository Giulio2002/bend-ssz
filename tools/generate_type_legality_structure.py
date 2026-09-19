"""Independent normative legality implies well-formed representation forests."""
from pathlib import Path
import re
root=Path(__file__).resolve().parents[1];path=root/'proofs/type_legality_structure.bend'
text=path.read_text().split('# Generated structural induction')[0]+'# Generated structural induction; compatibility witnesses are not assumed away.\n'
ctors=[]
for c,args in re.findall(r'^  (\w+)\{([^}]*)\}',(root/'types/schema.bend').read_text().split('type Value')[0],re.M):ctors.append((c,len(args.split(',')) if args else 0))
lines=['law legal_structure:','  for +schema: T.Schema','  for +forest: Bool','  for legal: S.legal(schema, forest)','  structure(schema, forest)','def legal_structure(schema, forest, legal):','  match schema:']
for c,n in ctors:
 vs=['s'+str(i) for i in range(n)];schema='T.'+c+'{'+', '.join(vs)+'}';lines+=['    case T.'+c+'{'+', '.join(v if c=='Union' else '+'+v for v in vs)+'}:'];indent='      '
 if c in ['Boolean','Unsigned','ByteList','BitList','ProgressiveBits']:
  body=[f'({{==}}, public_context(forest, {schema}, legal))']
 elif c in ['ByteVector','BitVector']:
  body=['(context, positive) = legal',f'({{==}}, public_context(forest, {schema}, context))']
 elif c in ['Vector','ListOf','ProgressiveList']:
  body=['(context, (positive, element)) = legal' if c=='Vector' else '(context, element) = legal',f'(well_formed_of(s0, False{{}}, legal_structure(s0, False{{}}, element)), public_context(forest, {schema}, context))']
 elif c in ['Container','ProgressiveContainer','CompatibleUnion']:
  if c=='Container':decomp='(context, (names, fields)) = legal'
  elif c=='ProgressiveContainer':decomp='(context, (names, (fields, (limit, (last, count))))) = legal'
  else:decomp='(context, (positive, (count, (selectors, (fields, compatible))))) = legal'
  body=[decomp,f'(fields_body(s1, legal_structure(s1, True{{}}, fields)), public_context(forest, {schema}, context))']
 elif c=='Chain':
  body=['(context, (head, tail)) = legal', 'chain_body(forest, s0, s1, context, well_formed_of(s0, False{}, legal_structure(s0, False{}, head)), legal_structure(s1, True{}, tail))']
 elif c=='End':body=[f'({{==}}, forest_context(forest, {schema}, legal, {{==}}))']
 elif c=='Union':
  lines+=['      match s0:']
  for opt,k in ctors:
   ps=['o'+str(i) for i in range(k)];pat='T.'+opt+'{'+', '.join(p if opt=='Chain' and p=='o0' else '+'+p for p in ps)+'}';optexpr='T.'+opt+'{'+', '.join(ps)+'}'
   lines+=['        case '+pat+':']
   if opt!='Chain':lines+=['          Empty.absurd(structure(T.Union{'+optexpr+'}, forest), legal)'];continue
   lines+=['          match o0:']
   for head,j in ctors:
    hs=['h'+str(i) for i in range(j)];headexpr='T.'+head+'{'+', '.join(hs)+'}';pattern='T.'+head+'{'+', '.join('+'+h for h in hs)+'}'
    lines+=['            case '+pattern+':']
    if head=='Null':body=['(context, (positive, (limit, tail))) = legal',f'(union_body({headexpr}, o1, {{==}}, legal_structure(o1, True{{}}, tail)), public_context(forest, T.Union{{T.Chain{{{headexpr}, o1}}}}, context))']
    else:body=['(context, (limit, (head, tail))) = legal',f'(union_body({headexpr}, o1, well_formed_of({headexpr}, False{{}}, legal_structure({headexpr}, False{{}}, head)), legal_structure(o1, True{{}}, tail)), public_context(forest, T.Union{{T.Chain{{{headexpr}, o1}}}}, context))']
    lines+=['              '+b for b in body]
  continue
 else:body=[f'Empty.absurd(structure({schema}, forest), legal)']
 lines+=[indent+b for b in body]
lines+=['','law public_legal_well_formed:','  for +schema: T.Schema','  for legal: S.type_legal(schema)','  {F.well_formed(schema) == True{} : Bool}','def public_legal_well_formed(schema, legal):','  well_formed_of(schema, False{}, legal_structure(schema, False{}, legal))']
path.write_text(text+'\n'.join(lines)+'\n')
