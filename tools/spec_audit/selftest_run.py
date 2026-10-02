#!/usr/bin/env python3
"""tools/spec_audit/selftest_run.py: show that run_bend.py would see a disagreement. Takes 400 cases of a corpus, corrupts the
reference expectation of half of them (flips the verdict, or one byte of the expected root) and runs them; every corrupted
case must be reported."""
import json, os, random, subprocess, sys
src, out = sys.argv[1], sys.argv[2]
rng = random.Random(1)
cases = [json.loads(l) for i, l in zip(range(60000), open(src))]
cases = [c for c in cases if c['hex'] is not None and c['len'] < 5000]
pick = rng.sample(cases, 400)
n = 0
for i, c in enumerate(pick):
    if i % 2:
        n += 1
        if c['verdict'] == 'accept' and i % 4 == 1:
            c['verdict'] = 'reject'
        elif c['verdict'] == 'reject':
            c['verdict'], c['root'] = 'accept', '00' * 32
        else:
            c['root'] = ('ff' if c['root'][:2] != 'ff' else '00') + c['root'][2:]
os.makedirs(out, exist_ok=True)
with open(out + '/cases.jsonl', 'w') as f:
    for c in pick:
        f.write(json.dumps(c) + '\n')
r = subprocess.run([sys.executable, os.path.join(os.path.dirname(os.path.abspath(__file__)), 'run_bend.py'), '--repo', '.', '--cases', out + '/cases.jsonl', '--out', out], capture_output=True, text=True)
line = [l for l in r.stdout.splitlines() if l.startswith('disagreements')][0]
print('corrupted', n, '|', line)
