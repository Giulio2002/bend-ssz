#!/usr/bin/env python3
"""tools/file_times.py: time every root .bend file on its own with tools/check.sh (stdlib only; run on the server).

    python3 tools/file_times.py --out DIR [--jobs 12] [--timeout 600] [--first PREFIX,PREFIX,..] [--files LIST] [--resume]
                                [--lock /srv/ssz-optimization/agents/.fullcheck.lock] [--report [SECONDS]]

Giulio's rule: no file may take more than two minutes to check. A file's time is the time of `tools/check.sh <file>`
alone (the whole import closure is re-checked, as in the mutation harness and in a single-file iteration), so a file
that imports a slow one is slow too: the report lists the slow files and, for each, its slowest import, so the root
of a family shows up as the file none of whose imports is slow.

DIR is outside the repository (the umbrella planner collects every .bend file under the tree; DIR must not be in it):
  DIR/results.jsonl   one JSON line per file as it finishes (appended: --resume skips the files already in it)
  DIR/file_times.json {commit, jobs, timeout, files: [{file, seconds, peak_mb, result, rc}] sorted by seconds descending}
  DIR/logs/<n>.log    the checker's output of the files that did not pass, or took over 120 s

`result` is pass (ALL PROOFS CHECK), fail (SOME PROOFS FAIL), timeout (the 600 s limit of check.sh) or error.
Yields to the full check: before starting each file it tests `flock -n LOCK true`; while a full check holds LOCK it waits.
--first lists path prefixes timed first (default: e2e/, proofs/api/, proofs/gate/, proofs/obj/, benchmarks/, tests_generated/),
then the rest. Roots are every .bend file outside tools/ and vendor/.
--report prints the files over SECONDS (default 120) grouped by family and exits (it reads DIR/results.jsonl).
"""
import argparse
import concurrent.futures as cf
import json
import os
import re
import subprocess
import sys
import threading
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_FIRST = 'e2e/,proofs/api/,proofs/gate/,proofs/obj/,benchmarks/,tests_generated/'
LOCK = '/srv/ssz-optimization/agents/.fullcheck.lock'


def roots():
    out = []
    for p in ROOT.rglob('*.bend'):
        r = p.relative_to(ROOT).as_posix()
        if r.startswith(('tools/', 'vendor/', '.git/', 'build/')):
            continue
        out.append(r)
    return sorted(out)


def order(files, first):
    pre = [x for x in first.split(',') if x]
    rank = lambda f: next((i for i, x in enumerate(pre) if f.startswith(x)), len(pre))   # noqa: E731
    return sorted(files, key=lambda f: (rank(f), f))


def family(f):
    b = f.rsplit('/', 1)[-1]
    if f.startswith('e2e/'):
        for tag in ('witness', 'decrep', 'comp', 'bridge', 'dwh', 'set', 'enc', 'dec'):
            if f'_e2e_{tag}' in b or b.startswith(f'e2e_{tag}'):
                return 'witness' if tag in ('witness', 'dwh', 'set') else 'decrep/comp' if tag in ('decrep', 'comp') else 'e2e ' + tag
        return 'e2e other'
    if f.startswith('proofs/api/'):
        return 'facade'
    if f.startswith('proofs/gate/'):
        return 'gate'
    if f.startswith(('benchmarks/', 'native_bench/', 'tests_generated/')):
        return 'benchmark'
    if re.search(r'(coll_|cached_|bl\d|l\d+_|var_win|vlist)', f):
        return 'collection law'
    if f.startswith('proofs/obj/'):
        return 'law'
    return 'other'


def check(f, timeout):
    env = dict(os.environ, CHECK_PINS_VERIFIED='1')
    t0 = time.time()
    try:
        r = subprocess.run(['tools/check.sh', f], cwd=ROOT, capture_output=True, text=True, env=env, timeout=timeout + 60)
        out, rc = r.stdout + r.stderr, r.returncode
    except subprocess.TimeoutExpired as e:
        out, rc = (e.stdout or b'').decode() if isinstance(e.stdout, bytes) else (e.stdout or ''), 124
    wall = time.time() - t0
    m = re.search(r'CHECK_TIME ([\d.]+) (\d+)', out)
    sec, kb = (float(m.group(1)), int(m.group(2))) if m else (wall, 0)
    if 'ALL PROOFS CHECK' in out:
        res = 'pass'
    elif 'SOME PROOFS FAIL' in out:
        res = 'fail'
    elif rc == 124:
        res = 'timeout'
    else:
        res = 'error'
    return {'file': f, 'seconds': round(sec, 2), 'peak_mb': round(kb / 1024), 'result': res, 'rc': rc}, out


def full_check_running(lock):
    if not os.path.exists(lock):
        return False
    return subprocess.run(['flock', '-n', lock, 'true']).returncode != 0


def commit():
    try:
        return subprocess.run(['git', 'rev-parse', 'HEAD'], cwd=ROOT, capture_output=True, text=True).stdout.strip()
    except OSError:
        return ''


def report(out, limit):
    rows = [json.loads(l) for l in open(Path(out) / 'results.jsonl')]
    over = [r for r in rows if r['seconds'] > limit or r['result'] in ('timeout', 'error')]
    fam = {}
    for r in over:
        fam.setdefault(family(r['file']), []).append(r)
    print(f'{len(rows)} files timed, {len(over)} over {limit:.0f} s (or timeout/error)')
    for k, v in sorted(fam.items(), key=lambda kv: -sum(x['seconds'] for x in kv[1])):
        print(f'\n{k}: {len(v)} files, {sum(x["seconds"] for x in v):.0f} s')
        for r in sorted(v, key=lambda x: -x['seconds'])[:40]:
            print(f'  {r["seconds"]:8.1f} s {r["peak_mb"]:6d} MB {r["result"]:7s} {r["file"]}')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', required=True)
    ap.add_argument('--jobs', type=int, default=12)
    ap.add_argument('--timeout', type=int, default=600)
    ap.add_argument('--first', default=DEFAULT_FIRST)
    ap.add_argument('--files')
    ap.add_argument('--resume', action='store_true')
    ap.add_argument('--lock', default=LOCK)
    ap.add_argument('--report', nargs='?', const=120.0, type=float)
    a = ap.parse_args()
    out = Path(a.out).resolve()
    if ROOT in out.parents or out == ROOT:
        sys.exit('file_times: --out must be outside the repository (the umbrella planner collects every .bend file under it)')
    if a.report is not None:
        return report(out, a.report)
    (out / 'logs').mkdir(parents=True, exist_ok=True)
    done = set()
    rj = out / 'results.jsonl'
    if a.resume and rj.exists():
        done = {json.loads(l)['file'] for l in open(rj)}
    elif rj.exists():
        rj.unlink()
    files = [l.strip() for l in open(a.files)] if a.files else roots()
    todo = [f for f in order(files, a.first) if f not in done]
    lk = threading.Lock()
    n = [0]
    t0 = time.time()

    def job(f):
        while full_check_running(a.lock):
            time.sleep(30)
        r, log = check(f, a.timeout)
        with lk:
            n[0] += 1
            with open(rj, 'a') as fh:
                fh.write(json.dumps(r) + '\n')
            if r['result'] != 'pass' or r['seconds'] > 120:
                (out / 'logs' / (f.replace('/', '__') + '.log')).write_text(log[-20000:])
            if n[0] % 100 == 0:
                print(f'{n[0]}/{len(todo)} files, {time.time() - t0:.0f} s', flush=True)
        return r

    with cf.ThreadPoolExecutor(a.jobs) as ex:
        list(ex.map(job, todo))
    rows = sorted((json.loads(l) for l in open(rj)), key=lambda r: -r['seconds'])
    (out / 'file_times.json').write_text(json.dumps({'commit': commit(), 'jobs': a.jobs, 'timeout': a.timeout, 'files': rows}, indent=1) + '\n')
    print(f'{len(rows)} files; slowest: ' + ', '.join(f'{r["file"]} {r["seconds"]}s' for r in rows[:5]))


if __name__ == '__main__':
    main()
