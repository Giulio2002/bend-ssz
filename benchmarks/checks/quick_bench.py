"""Quick per-op timings of the compact bench programs on one fixture per type
(min of 3 runs); a development aid, not the contract measurement."""
import json, subprocess, os, re, snappy, pathlib, sys
names = json.load(open('build/cschema-index.json'))
cases = [c for c in json.load(open('cases.json')) if '/ssz_static/' in c]
pick = {}
for c in cases: pick.setdefault(c.split('/')[4], c)
tmp = pathlib.Path('build/performance/inputs'); tmp.mkdir(parents=True, exist_ok=True)
types = sys.argv[1].split(',')
ops = {t: '20' if t == 'BeaconState' else '50000' for t in types}
for t in types:
    data = snappy.decompress((pathlib.Path('fixtures') / pick[t] / 'serialized.ssz_snappy').read_bytes())
    f = tmp / f'{t}.quick.ssz'; f.write_bytes(data); o = tmp / 'quick-out.ssz'
    row = []
    for prog in ('dec', 'enc', 'root'):
        best = None
        for _ in range(3):
            n = ops[t] if prog != 'root' or t == 'BeaconState' else '5000'
            env = {**os.environ, 'SSZ_INDEX': str(names.index(t)), 'SSZ_OPS': n, 'SSZ_INPUT': str(f), 'SSZ_OUTPUT': str(o)}
            r = subprocess.run([f'build/compact-{prog}', '--threads', '1', '--gpu', 'off'], env=env, capture_output=True, text=True)
            ns = int(re.search(r'\bMS=(\d+)', r.stdout).group(1)) * 1e6 / int(n)
            best = ns if best is None else min(best, ns)
        row.append(f'{prog} {best:>11.0f} ns')
    print(f'{t:22} {len(data):>8}  ' + '  '.join(row))
