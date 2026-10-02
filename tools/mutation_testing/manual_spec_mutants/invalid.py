#!/usr/bin/env python3
"""invalid.py --tree TREE --work WORK --out invalid.json PATCH...  (server)
Verdict B2: the repository's finite invalid-object regressions (tests_generated/invalid_objects.py: benchmarks/compact/oinvalid.bend
builds invalid but representable objects and prints whether each <Name>_serialize accepted it) on the mutated tree."""
import argparse, json, os, re, shutil, subprocess, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from runner import header, cone   # noqa

ap = argparse.ArgumentParser()
ap.add_argument('--tree', required=True); ap.add_argument('--work', required=True); ap.add_argument('--out', required=True)
ap.add_argument('--bend', default='/srv/ssz-optimization/toolchain-2.0.34/bin/bend')
ap.add_argument('patches', nargs='+')
a = ap.parse_args()
tree = os.path.abspath(a.tree); work = os.path.abspath(a.work)
src = open(os.path.join(tree, 'tests_generated/invalid_objects.py')).read()
EXPECT = eval(re.search(r'EXPECT = (\{.*?\})\n', src, re.S).group(1))
res = json.load(open(a.out)) if os.path.exists(a.out) else []
done = {r['id'] for r in res}
for p in a.patches:
    p = os.path.abspath(p); h = header(p); h['path'] = p
    if h['id'] in done:
        continue
    d = os.path.join(work, 'i_' + h['id'].replace('/', '_'))
    shutil.rmtree(d, ignore_errors=True)
    files = cone(tree, 'benchmarks/compact/oinvalid.bend')
    for r in files:
        dst = os.path.join(d, r); os.makedirs(os.path.dirname(dst), exist_ok=True); os.link(os.path.join(tree, r), dst)
    t = h['file']
    os.makedirs(os.path.dirname(os.path.join(d, t)), exist_ok=True)
    if os.path.exists(os.path.join(d, t)):
        os.unlink(os.path.join(d, t))
    shutil.copy(os.path.join(tree, t), os.path.join(d, t))
    subprocess.run(['patch', '-p1', '--no-backup-if-mismatch', '-s', '-i', p], cwd=d, check=True)
    env = dict(os.environ, BEND_NO_TELEMETRY='1', BUN_JSC_forceRAMSize='3000000000')
    c = subprocess.run(['nice', '-n', '19', a.bend, 'benchmarks/compact/oinvalid.bend', '-o', os.path.join(d, 'oinvalid')], cwd=d, env=env, capture_output=True, text=True)
    if c.returncode:
        res.append({'id': h['id'], 'B2': 'ERROR', 'msg': (c.stdout + c.stderr)[-300:]})
    else:
        r = subprocess.run([os.path.join(d, 'oinvalid'), '--threads', '1', '--gpu', 'off'], capture_output=True, text=True)
        got = {}
        for line in r.stdout.splitlines():
            if '=' in line:
                k, v = line.split('=', 1); got[k.strip()] = int(v.strip())
        bad = [k for k, w in EXPECT.items() if got.get(k) != w]
        res.append({'id': h['id'], 'B2': 'KILLED' if bad else 'SURVIVED', 'failing_cases': bad})
    print(res[-1], flush=True)
    json.dump(res, open(a.out, 'w'), indent=1)
    shutil.rmtree(d, ignore_errors=True)
