"""Read pinned type declarations as metadata; never execute reference SSZ code."""
import ast
import json
import re
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
FROZEN = json.loads((ROOT/'schemas/fulu_mainnet.json').read_text())
TYPES = {'boolean': {'kind':'bool','size':1}, 'bool': {'kind':'bool','size':1}, 'byte': {'kind':'uint','size':1}, 'ProgressiveBitlist': {'kind':'progressive_bits'}}
TYPES.update({f'uint{n}': {'kind':'uint','size':n//8} for n in (8,16,32,64,128,256)})

def expr(node):
    if isinstance(node, ast.Name): return TYPES[node.id]
    if isinstance(node, ast.Subscript):
        name=node.value.id
        args=node.slice.elts if isinstance(node.slice,ast.Tuple) else [node.slice]
        if name in ('List','Vector'):
            return {'kind': 'list' if name=='List' else 'vector', 'element':expr(args[0]), 'limit' if name=='List' else 'length':ast.literal_eval(args[1])}
        if name in ('ByteList','ByteVector','Bitlist','Bitvector'):
            return {'kind':{'ByteList':'bytelist','ByteVector':'bytes','Bitlist':'bitlist','Bitvector':'bits'}[name], 'limit' if name.endswith('list') or name=='ByteList' else 'length':ast.literal_eval(args[0])}
        if name=='ProgressiveList':return {'kind':'progressive_list','element':expr(args[0])}
    if isinstance(node,ast.Call) and node.func.id=='CompatibleUnion':
        d=node.args[0]
        return {'kind':'compatible_union','selectors':[ast.literal_eval(k) for k in d.keys], 'options':[expr(v) for v in d.values]}
    raise ValueError('unknown normative type expression: '+ast.dump(node))

for block in re.findall(r'```python\n(.*?)```', (ROOT/'vendor/consensus-specs/test_formats/ssz_generic/README.md').read_text(), re.S):
    if not re.search(r'^class |^CompatibleUnion',block,re.M):continue
    for node in ast.parse(block).body:
        if isinstance(node,ast.ClassDef):
            base=node.bases[0]
            s={'kind':'container','fields':[[x.target.id,expr(x.annotation)] for x in node.body if isinstance(x,ast.AnnAssign)]}
            if isinstance(base,ast.Call):
                assert base.func.id=='ProgressiveContainer'
                s.update(kind='progressive_container',active=ast.literal_eval(base.keywords[0].value))
            TYPES[node.name]=s
        elif isinstance(node,ast.Assign):TYPES[node.targets[0].id]=expr(node.value)

def for_case(case):
    parts=case.split('/')
    if '/ssz_static/' in case:return FROZEN[parts[4]]
    family,name=parts[4],parts[-1]
    if family=='boolean':return TYPES['bool']
    if family=='uints':return TYPES['uint'+re.fullmatch(r'uint_(8|16|32|64|128|256)_.+',name)[1]]
    if family=='basic_vector':
        m=re.fullmatch(r'vec_(bool|uint8|uint16|uint32|uint64|uint128|uint256)_(\d+)(?:_.+)?',name)
        return {'kind':'vector','element':TYPES[m[1]],'length':int(m[2])}
    if family=='basic_progressive_list':
        m=re.fullmatch(r'proglist_(bool|uint8|uint16|uint32|uint64|uint128|uint256)(?:_.+)?',name)
        return {'kind':'progressive_list','element':TYPES[m[1]]}
    if family in ('bitlist','bitvector'):
        m=re.fullmatch(r'(?:bitlist|bitvec)_(\d+)(?:_.+)?',name)
        return {'kind':'bitlist' if family=='bitlist' else 'bits','limit' if family=='bitlist' else 'length':int(m[1])}
    if family=='progressive_bitlist':return {'kind':'progressive_bits'}
    for key in sorted(TYPES,key=len,reverse=True):
        if name==key or name.startswith(key+'_'):return TYPES[key]
    raise ValueError('unrecognized official type '+case)

def normalize(s,v):
    kind=s['kind']
    if kind=='uint':return str(int(v))
    if kind=='bool':
        if type(v) is not bool:raise ValueError('boolean metadata')
        return v
    if kind in ('bytes','bytelist'):
        if not isinstance(v,str) or not re.fullmatch(r'0x(?:[0-9a-fA-F]{2})*',v):raise ValueError('byte metadata')
        return list(bytes.fromhex(v[2:]))
    if kind in ('bits','bitlist','progressive_bits'):
        if not isinstance(v,str) or not re.fullmatch(r'0x(?:[0-9a-fA-F]{2})*',v):raise ValueError('bit metadata')
        raw=bytes.fromhex(v[2:])
        if kind=='bits':
            n=int(s['length'])
            if len(raw)!=(n+7)//8 or (n%8 and raw[-1]>>(n%8)):raise ValueError('bitvector metadata scope')
        else:
            if not raw or not raw[-1]:raise ValueError('missing metadata delimiter')
            n=(len(raw)-1)*8+raw[-1].bit_length()-1
            if kind=='bitlist' and n>int(s['limit']):raise ValueError('bitlist metadata capacity')
        return [bool(raw[i//8]&(1<<(i%8))) for i in range(n)]
    if kind in ('list','vector','progressive_list'):
        if isinstance(v,str) and v.startswith('0x') and s['element']==TYPES['byte']:v=list(bytes.fromhex(v[2:]))
        if not isinstance(v,list):raise ValueError('sequence metadata')
        return [normalize(s['element'],x) for x in v]
    if kind in ('container','progressive_container'):return {n:normalize(t,v[n]) for n,t in s['fields']}
    if kind in ('union','compatible_union'):
        selector=int(v['selector']);idx=selector if kind=='union' else s['selectors'].index(selector)
        return {'selector':selector,'value':normalize(s['options'][idx],v.get('data',v.get('value')))}
    if kind=='none':return None
    raise ValueError('unrecognized metadata kind')
