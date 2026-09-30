#!/usr/bin/env python3
"""The stamp of a full check, and its verification against a tree.

    python3 tools/check_stamp.py write DIR OUT.json   # tools/check_fast.sh: stamp DIR/summary.tsv
    python3 tools/check_stamp.py verify FILE.json     # does the stamp describe this tree?

A stamp records the commit (git, or EVIDENCE_COMMIT where the tree is a copy without .git), UTC
time, the checker commit and the sha256 of toolchain.lock.json and frozen.lock.json, the sha256
of the checked sources (every .bend file outside tools/, vendor/ and build/: sorted
"path\\0sha256\\n" lines), the number of files, every umbrella's result (exit, whether the exact
line "All terms check." was printed, seconds, peak MB, number of roots) and the verdict.
benchmarks/evidence/check_fast.json is the committed stamp of the last full check.
"""
import datetime
import hashlib
import json
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def sha(b):
    return hashlib.sha256(b).hexdigest()


def sources():
    files = []
    for d, ds, fs in os.walk(ROOT):
        rel = os.path.relpath(d, ROOT)
        ds[:] = sorted(x for x in ds if not x.startswith('.') and x not in ('build', 'node_modules')
                       and not (rel == '.' and x in ('tools', 'vendor')))
        files += [os.path.relpath(os.path.join(d, f), ROOT) for f in fs if f.endswith('.bend')]
    h = hashlib.sha256()
    for f in sorted(files):
        with open(os.path.join(ROOT, f), 'rb') as x:
            h.update(f.encode() + b'\0' + sha(x.read()).encode() + b'\n')
    return h.hexdigest(), len(files)


def commit():
    try:
        return subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True, stderr=subprocess.DEVNULL).strip()
    except (OSError, subprocess.CalledProcessError):
        return os.environ.get('EVIDENCE_COMMIT', 'unknown')


def write(d, out):
    rows = []
    for line in open(os.path.join(d, 'summary.tsv')):
        u, rc, ok, s, mb, roots = line.rstrip('\n').split('\t')
        rows.append({'umbrella': u, 'exit': int(rc), 'all_terms_check': int(ok) > 0, 'seconds': float(s),
                     'peak_mb': int(mb), 'roots': len(roots.split())})
    rows.sort(key=lambda r: r['umbrella'])
    digest, n = sources()
    lock = json.load(open(os.path.join(ROOT, 'toolchain.lock.json')))
    st = {'commit': commit(), 'utc': datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ'),
          'checker_commit': lock['checker']['commit'],
          'toolchain_lock_sha256': sha(open(os.path.join(ROOT, 'toolchain.lock.json'), 'rb').read()),
          'frozen_lock_sha256': sha(open(os.path.join(ROOT, 'frozen.lock.json'), 'rb').read()),
          'sources_sha256': digest, 'files': n, 'umbrellas': rows,
          'verdict': 'all files check' if rows and all(r['exit'] == 0 and r['all_terms_check'] for r in rows) else 'FAILED'}
    with open(out, 'w') as h:
        h.write(json.dumps(st, indent=1) + '\n')


def verify(f):
    st = json.load(open(f))
    digest, n = sources()
    same = st['sources_sha256'] == digest
    print('%s: %s at %s (commit %s, checker %s): %s' % (f, st['verdict'], st['utc'], st['commit'][:12], st['checker_commit'][:8],
          'sources match this tree' if same else 'sources differ from this tree'))
    sys.exit(0 if same and st['verdict'] == 'all files check' else 1)


if __name__ == '__main__':
    if sys.argv[1:2] == ['write']:
        write(sys.argv[2], sys.argv[3])
    elif sys.argv[1:2] == ['verify']:
        verify(sys.argv[2])
    else:
        sys.exit(__doc__)
