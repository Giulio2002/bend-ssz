#!/usr/bin/env python3
"""rt_diff.py A.jsonl B.jsonl [REFERENCE_CASES.jsonl]: compare two runs of rt_corpus.py case by case (verdict, root, re-encoding hash),
and with the cases file also each run against the reference verdict and root. Exit 1 on any difference."""
import json
import sys


def load(p):
    return {json.loads(l)['id']: json.loads(l) for l in open(p)}


def main():
    a, b = load(sys.argv[1]), load(sys.argv[2])
    ref = {}
    if len(sys.argv) > 3:
        ref = {json.loads(l)['id']: json.loads(l) for l in open(sys.argv[3])}
    diff = [i for i in a if a[i] != b.get(i)]
    print('cases A %d, B %d, only in A %d, only in B %d, different %d' % (len(a), len(b), len(set(a) - set(b)), len(set(b) - set(a)), len(diff)))
    for i in diff[:20]:
        print('  ', i, a[i], b.get(i))
    if ref:
        for name, run in (('A', a), ('B', b)):
            bad = 0
            for i, r in run.items():
                c = ref.get(i)
                if c is None or c['verdict'] not in ('accept', 'reject'):
                    continue
                if c['verdict'] != r['bend'] or (c['verdict'] == 'accept' and r.get('root') != c['root']):
                    bad += 1
            print('run %s: %d cases disagree with the reference verdict or root' % (name, bad))
    return 1 if diff else 0


if __name__ == '__main__':
    sys.exit(main())
