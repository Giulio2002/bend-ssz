#!/usr/bin/env python3
"""targeted.py --tree TREE --work WORK --out targeted.json [PATCH...]   (server)
Compiles targeted/oinvalid2.bend on the unmutated tree (every line must have its expected value) and on each mutant, and reports which
lines changed. These cases reach code that only invalid objects reach (checked-serializer refusal tables in src/obj.bend), which the
decode-first reference corpus cannot construct."""
import argparse, json, os, re, shutil, subprocess, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from runner import header, cone
REL = 'tools/mutation_testing/manual_spec_mutants/targeted/oinvalid2.bend'
EXPECT = {'vecbool5_two': 0, 'vecbool5_ok': 1, 'vecbool16_two': 0, 'vecbool16_ok': 1, 'proglistbool_two': 0, 'proglistbool_ok': 1,
          'fixed_300': 0, 'fixed_200': 1, 'small_b70000': 0, 'small_ok': 1, 'single_300': 0, 'single_200': 1, 'psingle_300': 0, 'psingle_200': 1,
          'bitlist5_stray': 0, 'bitlist5_ok': 1, 'nbytes_top': 1}
ap = argparse.ArgumentParser()
ap.add_argument('--tree', required=True); ap.add_argument('--work', required=True); ap.add_argument('--out', required=True)
ap.add_argument('--bend', default='/srv/ssz-optimization/toolchain-2.0.34/bin/bend')
ap.add_argument('patches', nargs='*')
a = ap.parse_args()
tree, work = os.path.abspath(a.tree), os.path.abspath(a.work)
src = os.path.join(HERE, 'targeted/oinvalid2.bend')
res = []
def go(name, patch):
    d = os.path.join(work, 't_' + name)
    shutil.rmtree(d, ignore_errors=True)
    # the program's cone lives in the real tree; the program itself is linked in at its relative path
    os.makedirs(os.path.join(d, os.path.dirname(REL)))
    shutil.copy(src, os.path.join(d, REL))
    def deps(rel, base):
        out, todo = set(), [rel]
        while todo:
            r = todo.pop()
            if r in out: continue
            out.add(r)
            p = os.path.join(d, r) if r == REL else os.path.join(tree, r)
            for m in re.finditer(r'^import\s+(\S+)', open(p).read(), re.M):
                t = m.group(1)
                if t == 'Base' or not t.endswith('.bend'): continue
                q = os.path.normpath(os.path.join(os.path.dirname(r), t))
                if os.path.exists(os.path.join(tree, q)): todo.append(q)
        return out
    files = deps(REL, None) - {REL}
    for r in files:
        dst = os.path.join(d, r); os.makedirs(os.path.dirname(dst), exist_ok=True); os.link(os.path.join(tree, r), dst)
    if patch:
        t = patch['file']
        if os.path.exists(os.path.join(d, t)): os.unlink(os.path.join(d, t))
        os.makedirs(os.path.dirname(os.path.join(d, t)), exist_ok=True)
        shutil.copy(os.path.join(tree, t), os.path.join(d, t))
        subprocess.run(['patch', '-p1', '--no-backup-if-mismatch', '-s', '-i', patch['path']], cwd=d, check=True)
    env = dict(os.environ, BEND_NO_TELEMETRY='1', BUN_JSC_forceRAMSize='3000000000')
    c = subprocess.run(['nice', '-n', '19', a.bend, REL, '-o', os.path.join(d, 'prog')], cwd=d, env=env, capture_output=True, text=True)
    if c.returncode:
        return {'id': name, 'T': 'ERROR', 'msg': (c.stdout + c.stderr)[-500:]}
    r = subprocess.run([os.path.join(d, 'prog'), '--threads', '1', '--gpu', 'off'], capture_output=True, text=True)
    got = {}
    for line in r.stdout.splitlines():
        if '=' in line:
            k, v = line.split('=', 1); got[k.strip()] = int(v.strip())
    shutil.rmtree(d, ignore_errors=True)
    bad = sorted(k for k, w in EXPECT.items() if got.get(k) != w)
    return {'id': name, 'T': 'KILLED' if bad else 'SURVIVED', 'flipped': bad, 'got': got}
res.append(go('baseline', None)); print(res[-1], flush=True)
for p in a.patches:
    p = os.path.abspath(p); h = header(p); h['path'] = p
    res.append(go(h['id'], h)); print(res[-1]['id'], res[-1]['T'], res[-1].get('flipped'), flush=True)
    json.dump(res, open(a.out, 'w'), indent=1)
json.dump(res, open(a.out, 'w'), indent=1)
