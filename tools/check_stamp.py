#!/usr/bin/env python3
"""The stamp of a full check, and its verification against a tree.

    python3 tools/check_stamp.py write DIR OUT.json   # tools/check_fast.sh: stamp DIR/summary.tsv
    python3 tools/check_stamp.py verify FILE.json     # does the stamp describe this tree?

A stamp records the commit (git, or EVIDENCE_COMMIT where the tree is a copy without .git), UTC
time, the checker commit and the sha256 of toolchain.lock.json and frozen.lock.json, the sha256
of the checked sources (every .bend file outside tools/, vendor/ and build/: sorted
"path\\0sha256\\n" lines; the vendored SHA-256 package is pinned by toolchain.lock.json), the
number of files, the sha256 of each harness script (HARNESS: the runners, the umbrella planner and
the four pre-checks), the sha256 of the umbrella plan (DIR/umb/plan.tsv) with its umbrella and
root counts, the scope (all files, or the --files list), the path of the toolchain lock, the
stack limit (ulimit -s, KB) and the JSC stack budget (bytes) the umbrellas ran under, every planned umbrella's result (exit, whether the exact
line "ALL PROOFS CHECK" was printed, seconds, peak MB, number of roots) and the verdict.

The verdict is "all files check" only if the scope is every file, every umbrella of the plan has
exactly one result row, and every row exited 0 with the exact line. An umbrella whose run died
before writing its row is recorded with "result": "missing" and fails the stamp; `write` exits 1
then, and tools/check_fast.sh fails too.

`verify` recomputes the sources, harness and lock hashes on the current tree (the toolchain lock at
the path the stamp records; a BEND_LOCK naming another path is a difference): it exits 0 only if
all of them equal the stamp's and the verdict is "all files check". So the committed
benchmarks/evidence/check_fast.json (written by every full tools/check_fast.sh run) says whether
the tree in hand is the one that was checked.
"""
import datetime
import hashlib
import json
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HARNESS = ['tools/check.sh', 'tools/check_fast.sh', 'tools/umbrellas.py', 'tools/umb_pool.py', 'tools/check_stamp.py',
           'tools/verify_pins.py', 'tools/verify_frozen.py', 'tools/verify_no_escapes.py',
           'tools/verify_schemas.py', 'tools/test_schemas.py', 'tools/verify_fixtures.py']


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


# the toolchain lock the run verified against (tools/check.sh BEND_LOCK)
LOCK = os.environ.get('BEND_LOCK') or 'toolchain.lock.json'


def harness():
    return {f: sha(open(os.path.join(ROOT, f), 'rb').read()) for f in HARNESS}


def locks(lock=LOCK):
    return {k: sha(open(os.path.join(ROOT, f), 'rb').read())
            for k, f in (('toolchain_lock_sha256', lock), ('frozen_lock_sha256', 'frozen.lock.json'))}


def fixtures_record(d):
    """tools/check_fast.sh --tarballs DIR runs tools/verify_fixtures.py --tarballs DIR --record DIR/fixtures.json; the stamp
    says whether the fixtures were checked against the pinned release tarballs in this run, and which tarballs"""
    f = os.path.join(d, 'fixtures.json')
    if os.path.exists(f):
        return json.load(open(f))
    return {'fixtures_tarballs_verified': False}


def write(d, out):
    plan_path = os.path.join(d, 'umb', 'plan.tsv')
    plan = [line.rstrip('\n').split('\t') for line in open(plan_path) if line.strip()]
    got = {}
    dup = []
    for line in open(os.path.join(d, 'summary.tsv')):
        u, rc, ok, s, mb, roots = line.rstrip('\n').split('\t')
        if u in got:
            dup.append(u)
        got[u] = {'umbrella': u, 'exit': int(rc), 'all_terms_check': int(ok) > 0, 'seconds': float(s),
                  'peak_mb': int(mb), 'roots': len(roots.split())}
    rows = []
    for p in plan:
        r = got.pop(p[0], None)
        if r is None:
            r = {'umbrella': p[0], 'exit': None, 'all_terms_check': False, 'seconds': None, 'peak_mb': None,
                 'roots': len(p[3].split()), 'result': 'missing'}
        else:
            r['result'] = 'pass' if r['exit'] == 0 and r['all_terms_check'] else 'fail'
        rows.append(r)
    extra = sorted(got)  # rows for umbrellas not in the plan (bisection never writes summary rows)
    rows.sort(key=lambda r: r['umbrella'])
    digest, n = sources()
    lock = json.load(open(os.path.join(ROOT, LOCK)))
    scope = os.environ.get('CHECK_FAST_FILES') or 'all'
    missing = [r['umbrella'] for r in rows if r['result'] == 'missing']
    ok = bool(rows) and all(r['result'] == 'pass' for r in rows) and not dup and not extra
    st = {'commit': commit(), 'utc': datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ'),
          'checker_commit': lock['checker']['commit'], 'toolchain_lock': LOCK, **locks(),
          'stack_kb': int(os.environ.get('CHECK_STACK_KB') or 8192),
          'jsc_stack_bytes': int(os.environ.get('CHECK_JSC_STACK') or 5242880),
          'sources_sha256': digest, 'files': n, 'harness_sha256': harness(),
          'plan_sha256': sha(open(plan_path, 'rb').read()), 'plan_umbrellas': len(plan),
          'plan_roots': sum(len(p[3].split()) for p in plan), 'scope': scope,
          'totals': {'umbrellas': len(rows), 'passed': sum(r['result'] == 'pass' for r in rows),
                     'failed': sum(r['result'] == 'fail' for r in rows), 'missing': len(missing),
                     'cpu_seconds': round(sum(r['seconds'] or 0 for r in rows), 1),
                     'slowest_umbrella_seconds': max([r['seconds'] or 0 for r in rows] or [0]),
                     'wall_seconds': int(os.environ['CHECK_FAST_WALL']) if os.environ.get('CHECK_FAST_WALL') else None},
          **fixtures_record(d),
          'missing': missing, 'duplicate_rows': dup, 'unplanned_rows': extra, 'umbrellas': rows,
          'verdict': ('all files check' if scope == 'all' else 'listed files check') if ok else 'FAILED'}
    with open(out, 'w') as h:
        h.write(json.dumps(st, indent=1) + '\n')
    if missing or dup or extra:
        print('check_stamp: %d planned umbrella(s) have no result row (%s); duplicate rows: %s; unplanned rows: %s'
              % (len(missing), ' '.join(missing) or '-', ' '.join(dup) or '-', ' '.join(extra) or '-'))
        sys.exit(1)


def verify(f):
    st = json.load(open(f))
    digest, n = sources()
    diff = []
    if st['sources_sha256'] != digest:
        diff.append('sources (%d files stamped, %d here)' % (st['files'], n))
    slock = st.get('toolchain_lock', 'toolchain.lock.json')
    if os.environ.get('BEND_LOCK') and os.path.normpath(os.environ['BEND_LOCK']) != os.path.normpath(slock):
        diff.append('toolchain lock path (stamped %s, BEND_LOCK %s)' % (slock, os.environ['BEND_LOCK']))
    diff += [k for k, v in locks(slock).items() if st.get(k) != v]
    # the stack the umbrellas ran under: tools/check.sh's pin, or the headroom run's JSC budget
    # (a check_fast_jsc<BYTES>.json stamp)
    import re
    mj = re.search(r'_jsc(\d+)\.json$', f)
    want = (8192, int(mj.group(1)) if mj else 5242880)
    if (st.get('stack_kb'), st.get('jsc_stack_bytes')) != want:
        diff.append('stack (stamped %s KB / %s bytes, expected %s KB / %s bytes)' % (st.get('stack_kb'), st.get('jsc_stack_bytes'), *want))
    h = harness()
    diff += ['harness ' + k for k in sorted(set(h) | set(st.get('harness_sha256', {})))
             if st.get('harness_sha256', {}).get(k) != h.get(k)]
    print('%s: %s at %s (commit %s, checker %s, %s umbrellas, scope %s): %s' % (
        f, st['verdict'], st['utc'], st['commit'][:12], st['checker_commit'][:8], st.get('plan_umbrellas', '?'),
        st.get('scope', '?'), 'this tree is the one checked' if not diff else 'differs from this tree: ' + ', '.join(diff)))
    sys.exit(0 if not diff and st['verdict'] == 'all files check' else 1)


if __name__ == '__main__':
    if sys.argv[1:2] == ['write']:
        write(sys.argv[2], sys.argv[3])
    elif sys.argv[1:2] == ['verify']:
        verify(sys.argv[2])
    else:
        sys.exit(__doc__)
