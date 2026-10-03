#!/usr/bin/env python3
"""rt_laws.py TREE FILE...: check every law of the given generated law files ONE BY ONE with the pinned checker (tools/check.sh).

A law file is a list of `def name(..) -> {statement}:` blocks over a header of imports and a few helper defs. The checker stops at the first
failing def, so a file reports one failure; here each law is written to a scratch file with the header and the helpers (defs that are not laws:
their type is not `{...}`) and checked alone. Prints `PASS|FAIL law` and a summary; the scratch files are deleted.

    python3 rt_laws.py /srv/.../sizelimit-rt/sl2 proofs/slop/crash/crash_fix_laws_generated.bend proofs/slop/validity/fulu_marker_poison_generated.bend
"""
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor


def blocks(text):
    lines = text.split('\n')
    head, defs, cur = [], [], None
    for l in lines:
        if l.startswith('def '):
            cur = [l]
            defs.append(cur)
        elif cur is not None and (l.startswith(' ') or l == ''):
            cur.append(l)
        elif cur is None:
            head.append(l)
        else:
            cur = None
    return head, ['\n'.join(d).rstrip('\n') for d in defs]


def check(tree, scratch):
    r = subprocess.run(['nice', '-n', '19', 'bash', 'tools/check.sh', scratch], cwd=tree, capture_output=True, text=True, timeout=1200)
    out = r.stdout + r.stderr
    ok = 'ALL PROOFS CHECK' in out
    why = ''
    if not ok:
        m = re.search(r'^- (?:expected|message)\s*:(.*)$', out, re.M)
        loc = re.search(r'^Location: (\S+)', out, re.M)
        why = ((loc.group(1) + ' ') if loc else '') + (m.group(1).strip()[:90] if m else out.strip()[-90:])
    return ok, why


def main():
    tree = os.path.abspath(sys.argv[1])
    rows = []
    jobs = []
    for f in sys.argv[2:]:
        text = open(os.path.join(tree, f)).read()
        head, defs = blocks(text)
        isdef = lambda d: re.match(r'def (\w+)\(.*?\)\s*(?:\n\s*)?-> \{', d, re.S) is not None
        laws = [d for d in defs if isdef(d)]
        helpers = [d for d in defs if not isdef(d)]
        for i, d in enumerate(laws):
            name = re.match(r'def (\w+)', d).group(1)
            scratch = os.path.join(os.path.dirname(f), 'zz_one_%d_%s' % (i, os.path.basename(f)))
            open(os.path.join(tree, scratch), 'w').write('\n'.join(head) + '\n' + '\n\n'.join(helpers + [d]) + '\n')
            jobs.append((f, name, scratch))
    with ThreadPoolExecutor(4) as ex:
        res = list(ex.map(lambda j: check(tree, j[2]), jobs))
    for (f, name, scratch), (ok, why) in zip(jobs, res):
        os.unlink(os.path.join(tree, scratch))
        rows.append((f, name, ok, why))
        print('%s %s %s %s' % ('PASS' if ok else 'FAIL', os.path.basename(f), name, why))
    print('%d laws, %d pass, %d fail' % (len(rows), sum(1 for r in rows if r[2]), sum(1 for r in rows if not r[2])))


if __name__ == '__main__':
    main()
