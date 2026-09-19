"""Independent static AST comparison, without executing the reference spec."""
import ast,json,operator,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
env={'boolean':{'kind':'bool','size':1}}
env.update({f'uint{i}':{'kind':'uint','size':i//8} for i in [8,16,32,64,128,256]})
env.update({f'Bytes{i}':{'kind':'bytes','length':i} for i in [1,4,8,20,32,48,96]})
ops={ast.Add:operator.add,ast.Sub:operator.sub,ast.Mult:operator.mul,ast.Pow:operator.pow,ast.FloorDiv:operator.floordiv}
def value(n):
 if isinstance(n,ast.Name):return env[n.id]
 if isinstance(n,ast.Constant):return n.value
 if isinstance(n,ast.BinOp):return ops[type(n.op)](value(n.left),value(n.right))
 if isinstance(n,ast.Call) and isinstance(n.func,ast.Name) and (n.func.id.startswith('uint') or n.func.id=='GeneralizedIndex'):return int(value(n.args[0]))
 if isinstance(n,ast.Call) and isinstance(n.func,ast.Name) and n.func.id=='floorlog2':return int(value(n.args[0])).bit_length()-1
 if isinstance(n,ast.Subscript):
  name=n.value.id;a=n.slice.elts if isinstance(n.slice,ast.Tuple) else [n.slice]
  if name in ['List','Vector']:return {'kind':'list' if name=='List' else 'vector','element':value(a[0]),'limit' if name=='List' else 'length':value(a[1])}
  if name in ['ByteList','ByteVector','Bitlist','Bitvector']:return {'kind':{'ByteList':'bytelist','ByteVector':'bytes','Bitlist':'bitlist','Bitvector':'bits'}[name],'limit' if name.endswith('list') or name=='ByteList' else 'length':value(a[0])}
 raise ValueError(ast.dump(n))
module=ast.parse((ROOT/'vendor/consensus-specs/fulu_mainnet.py').read_text())
for _ in range(6):
 for n in module.body:
  try:
   if isinstance(n,ast.Assign) and len(n.targets)==1 and isinstance(n.targets[0],ast.Name):env[n.targets[0].id]=value(n.value)
   elif isinstance(n,ast.AnnAssign) and isinstance(n.target,ast.Name):env[n.target.id]=value(n.value)
   elif isinstance(n,ast.ClassDef) and len(n.bases)==1:
    if isinstance(n.bases[0],ast.Name) and n.bases[0].id=='Container':env[n.name]={'kind':'container','fields':[[f.target.id,value(f.annotation)] for f in n.body if isinstance(f,ast.AnnAssign)]}
    else:env[n.name]=value(n.bases[0])
  except (KeyError,ValueError,TypeError,AttributeError):pass
def normalize(x):
 if isinstance(x,dict):return {k:int(v) if k in ['limit','length','size'] else normalize(v) for k,v in x.items()}
 if isinstance(x,list):return [normalize(v) for v in x]
 return x
frozen=json.loads((ROOT/'schemas/fulu_mainnet.json').read_text());missing=[n for n in frozen if n not in env];different=[n for n in frozen if n in env and normalize(frozen[n])!=normalize(env[n])]
result={'compared':len(frozen)-len(missing),'missing':missing,'different':different,'source':'vendor/consensus-specs/fulu_mainnet.py','method':'static AST independently expanded annotations/constants; no execution of eth2spec or existing generator'}
print(json.dumps(result,indent=2))
if missing or different:raise SystemExit(1)
