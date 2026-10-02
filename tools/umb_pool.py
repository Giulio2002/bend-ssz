#!/usr/bin/env python3
"""tools/umb_pool.py --jobs N [--plan plan.tsv] [--budget-mb M] [--reserve-mb R] -- cmd... {} ...

A memory-aware replacement for `xargs -P N` in tools/check_fast.sh: runs `cmd` once per umbrella (the first
column of plan.tsv, in file order: largest first) with `{}` replaced by its name, at most N at a time, and starts
the next one only when
  - the sum of the running umbrellas' expected peaks plus the next one's is at most --budget-mb (default
    UMB_BUDGET_MB or 200000: the server is shared), and
  - /proc/meminfo's MemAvailable stays above --reserve-mb (default UMB_RESERVE_MB or 40000) after it.
The expected peak of an umbrella is 4000 + 50 MB per estimated second (plan.tsv column 2), at most 14000
(fitted to the recorded stamps: 334 s -> 11.6 GB, 129 s -> 12.4 GB, 92 s -> 8.5 GB). A slot that cannot start
waits for a running umbrella to finish; one umbrella always runs (no deadlock). Only WHEN an umbrella runs
changes, never what is checked (--jobs is capped at 24); the exit status is 0 (check_fast.sh reads the verdicts from summary.tsv).
"""
import argparse
import os
import re
import subprocess
import sys
import time


MAX_JOBS = 24   # never more than this many umbrellas at once, whatever --jobs says


def avail_mb():
    try:
        for l in open('/proc/meminfo'):
            if l.startswith('MemAvailable:'):
                return int(l.split()[1]) // 1024
    except OSError:
        pass
    return 1 << 30


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--jobs', type=int, default=12)
    ap.add_argument('--plan', required=True)
    ap.add_argument('--budget-mb', type=int, default=int(os.environ.get('UMB_BUDGET_MB', 200000)))
    ap.add_argument('--reserve-mb', type=int, default=int(os.environ.get('UMB_RESERVE_MB', 40000)))
    ap.add_argument('--big-re', default=os.environ.get('UMB_BIG_RE', ''), help='roots matching this regex: expected peak --big-mb')
    ap.add_argument('--big-mb', type=int, default=int(os.environ.get('UMB_BIG_MB', 30000)))
    ap.add_argument('cmd', nargs=argparse.REMAINDER)
    a = ap.parse_args()
    a.jobs = min(a.jobs, MAX_JOBS)
    cmd = a.cmd[1:] if a.cmd and a.cmd[0] == '--' else a.cmd
    todo = []
    for line in open(a.plan):
        p = line.rstrip('\n').split('\t')
        if p and p[0]:
            est = min(14000, 4000 + 50 * float(p[1]) if len(p) > 1 else 8000)
            if a.big_re and len(p) > 3 and re.search(a.big_re, p[3]):
                est = a.big_mb
            todo.append((p[0], est))
    running = {}   # pid -> (Popen, est)
    t0 = time.time()
    peak = 0
    while todo or running:
        for pid in [pid for pid, (pr, _) in running.items() if pr.poll() is not None]:
            del running[pid]
        while todo and len(running) < a.jobs:
            name, est = todo[0]
            used = sum(e for _, e in running.values())
            if running and (used + est > a.budget_mb or avail_mb() - est < a.reserve_mb):
                break
            todo.pop(0)
            pr = subprocess.Popen([c.replace('{}', name) for c in cmd])
            running[pr.pid] = (pr, est)
            peak = max(peak, len(running))
        time.sleep(0.5)
    print(f'umb_pool: {int(time.time() - t0)} s, at most {peak} at once', file=sys.stderr)


if __name__ == '__main__':
    main()
