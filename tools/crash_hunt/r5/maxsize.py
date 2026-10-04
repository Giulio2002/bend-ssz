"""Round 5: the largest encoding of every type (fuzz_objects' schema table), against NMAX, and whether its _valid has the size test (_vsz)."""
import json, os, pathlib, sys
ROOT = pathlib.Path(__file__).resolve().parents[3]
os.chdir(ROOT); sys.path.insert(0, str(ROOT)); sys.path.insert(0, str(ROOT / 'tools'))
from codegen.core import generic_form_schemas as GEN
from codegen.core import fulu_schema_loader as schema
NMAX = 4294967264
TY = dict(schema.load('codegen/fulu.yaml').items())
GI = json.loads((ROOT / 'types/generic_obj_index.json').read_text())['generated']
for n, (t, _r) in GEN.inventory().items():
    if n in GI and n not in TY:
        TY[n] = t
def mx(t):
    k = t.kind
    if t.fixed():
        return t.fixed_size()
    if k == 'bytelist': return t.size
    if k == 'bitlist': return t.size // 8 + 1
    if k == 'pbits': return (2**32 - 1) // 8 + 1
    if k == 'list':
        e = t.elem
        return t.size * (mx(e) + (0 if e.fixed() else 4))
    if k == 'plist':
        return 2**64
    if k == 'vector':
        return t.size * (mx(t.elem) + (0 if t.elem.fixed() else 4))
    if k in ('container', 'pcontainer'):
        return sum((ft.fixed_size() if ft.fixed() else 4 + mx(ft)) for _, ft in t.fields)
    if k == 'cunion':
        return 1 + max(mx(ft) for _, ft in t.fields)
    raise SystemExit(k)
vsz = set()
for f in (ROOT / 'types').glob('*_encode_ssz_generated.bend'):
    if '_vsz' in f.read_text():
        vsz.add(f.name[:-len('_encode_ssz_generated.bend')])
print('names', len(TY))
for n, t in sorted(TY.items()):
    m = mx(t)
    if m > NMAX:
        print('%-50s kind=%-10s max=%s vsz_files=%s' % (n, t.kind, m if m < 2**64 else 'unbounded', [v for v in vsz if v.endswith(n) or v == n]))
