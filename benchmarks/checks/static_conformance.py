"""Every official ssz_static case through the compact primary API, natively:
build/compact-dec must accept it (API.validate) and build/compact-root must give
the full 32-byte root in roots.yaml (API.root)."""
import json, subprocess, os, re, snappy, pathlib, collections, sys
names = json.load(open('build/cschema-index.json'))
cases = [c for c in json.load(open('cases.json')) if '/ssz_static/' in c]
tmp = pathlib.Path('build/performance/inputs'); tmp.mkdir(parents=True, exist_ok=True)
res = collections.Counter(); fails = []
for c in cases:
    t = c.split('/')[4]; d = pathlib.Path('fixtures') / c
    data = snappy.decompress((d / 'serialized.ssz_snappy').read_bytes())
    want = re.search(r"0x([0-9a-f]{64})", (d / 'roots.yaml').read_text()).group(1)
    f = tmp / 'static.ssz'; f.write_bytes(data)
    env = {**os.environ, 'SSZ_INDEX': str(names.index(t)), 'SSZ_OPS': '1', 'SSZ_INPUT': str(f)}
    v = subprocess.run(['build/compact-dec', '--threads', '1', '--gpu', 'off'], env=env, capture_output=True, text=True)
    r = subprocess.run(['build/compact-root', '--threads', '1', '--gpu', 'off'], env=env, capture_output=True, text=True)
    m = re.search(r'ROOTWORDS=([\d,]+)', r.stdout)
    got = b''.join(int(w).to_bytes(4, 'big') for w in m.group(1).split(',')).hex() if m else None
    ok = v.returncode == 0 and r.returncode == 0 and got == want
    res['pass' if ok else 'fail'] += 1
    if not ok: fails.append((c, r.returncode, r.stdout[-120:], r.stderr[-120:]))
print(dict(res), 'types', len({c.split('/')[4] for c in cases}))
for f in fails[:10]: print(f)
json.dump({'cases': len(cases), 'result': dict(res), 'failures': fails}, open('benchmarks/evidence/static_conformance.json', 'w'), indent=1)
sys.exit(1 if fails else 0)
