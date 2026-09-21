import ast
from pathlib import Path
s=Path('benchmarks/run.py').read_text()
t=ast.parse(s)
ns={'TARGET_SECONDS':0.25,'MAX_OPS':5_000_000}
selected=ast.Module(body=[n for n in t.body if isinstance(n,ast.FunctionDef) and n.name in ['calibrate','measure_pair']],type_ignores=[])
exec(compile(selected,'benchmark-calibration','exec'),ns)
for a,b in [(1,200000),(200000,1),(1000,1000)]:
    calls=[]
    def measure(side,cost):
        def f(n):
            calls.append((side,n))
            return {'ns':n*cost}
        return f
    x,y,aa,bb=ns['measure_pair'](measure('bend',a),measure('go',b),5)
    assert aa==[a]*5 and bb==[b]*5
    assert [q[0] for q in calls[-10:]]==['bend','go','go','bend','bend','go','go','bend','bend','go']
    assert all(q[1]==(x if q[0]=='bend' else y) for q in calls[-10:])
    if a!=b: assert (x>y)==(a<b)
    print(a,b,'ns/op: counts',x,y,'correct normalization and alternation')
